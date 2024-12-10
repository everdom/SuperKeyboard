;OPTIMIZATIONS START
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
; SetMouseDelay, -1
; SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
; SendMode Input
DllCall("ntdll\ZwSetTimerResolution","Int",5000,"Int",1,"Int*",MyCurrentTimerResolution) ;setting the Windows Timer Resolution to 0.5ms, THIS IS A GLOBAL CHANGE
;OPTIMIZATIONS END
;YOUR SCRIPT GOES HERE
DllCall("Sleep","UInt",1) ;I just slept exactly 1ms!
DllCall("ntdll\ZwDelayExecution","Int",0,"Int64*",-5000) ;you can use this to sleep in increments of 0.5ms if you need even more granularity 

#InstallKeybdHook
; vim_mouse_2.ahk
; vim (and now also WASD!) bindings to control the mouse with the keyboard
; 
; Astrid Ivy
; 2019-04-14
;
; Last updated 2022-02-05


;@include-winapi
; --------------------------------------------------------------------------------
#MaxThreads 255 ; Allows a maximum of 255 instead of default threads.
; #Warn All, OutputDebug
#SingleInstance Force
; --------------------------------------------------------------------------------
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
; DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
; --------------------------------------------------------------------------------
global currentDPI := A_ScreenDPI
global DPI_Ratio := currentDPI/96
; global A_ScreenWidth_DPI := A_ScreenWidth / DPI_Ratio
; global A_ScreenHeight_DPI :=A_ScreenHeight / DPI_Ratio

; #Include Gdip_All.ahk

global INSERT_MODE := false
global INSERT_QUICK := false
global INSERT_AUTO_QUICK:=true
global NORMAL_MODE := false
global NORMAL_QUICK := false
global NUMPAD := false
global SMALL_MODE := false
global WASD := false
global FAST_MODE:=false
global EXT_DRAGGING_MODE:=false
global EXT_DRAGGING_APPS := ["Autodesk Fusion", "SOLIDWORKS"]
global EXT_DRAGGING_HINT := true

; Drag takes care of this now
;global MAX_VELOCITY := 72

; mouse speed variables
global FORCE := 7
global RESISTANCE := 0.982

global VELOCITY_X := 0
global VELOCITY_Y := 0

global POP_UP := false

global DRAGGING := false
global SHIFT_DRAGGING := false
global CTRL_DRAGGING := false
; global CROSS_RULER := false

global FAST_MODE_X :=10
global FAST_MODE_Y :=6
global FAST_MODE_FONT_SIZE :=48
; global FAST_MODE_FONT_COLOR :="01AFFD"
global FAST_MODE_FONT_COLOR :="Red"
global FAST_MODE_EXT := true
global FAST_MODE_EXT_X := 5
global FAST_MODE_EXT_Y := 5
global FAST_MODE_EXT_FONT_SIZE :=15
global FAST_MODE_EXT_FONT_COLOR :="Red"

global CHROME_VIM_MODE :=true
;; auto acrivate chrome core when it's under mouse
global CHROME_VIM_MODE_AUTO_ACTIVATE :=true
global CHROME_VIM_MODE_HINT := true
global NORMAL_MODE_HINT := true
global OLD_WASD := false

global CHROME_VIM_MODE_BROSWERS_TITLE := ["Edge", "Google Chrome", "Firefox"]
global CHROME_VIM_MODE_BROSWERS_EXE := ["msedge.exe", "chrome.exe", "firefox.exe"]

global IS_EDIT := false
global THEME_DARK := true

global curX := 0
global MonitorWidth :=0
global MonitorHeight :=0
global MonitorLeft :=0
global MonitorTop :=0
global Monitor1Width:=0
global Monitor1Height:=0
global Monitor2Width:=0
global Monitor2Height:=0
global Monitor3Width:=0
global Monitor3Height:=0
global Monitor4Width:=0
global Monitor4Height:=0
global Mon1Left:=0
global Mon1Top:=0
global Mon2Left:=0
global Mon2Top:=0
global Mon3Left:=0
global Mon3Top:=0
; global Mon4Left:=Monitor3Left
; global Mon4Top:=Monitor3Top

global lastScreenNum:=1
global screenNum:=1


; 这里加个判断，检测一下初始化是否成功，失败就弹窗告知，并退出程序。
; If !pToken := Gdip_Startup()
; {
; 	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
; 	ExitApp
; }

; Insert Mode by default
InitScreenInfo()
EnterInsertMode()

DPI_v(v){
  Return v*DPI_Ratio
}

;; Tigger two same keys
Trigger2(timeout) 
{
    if(timeout == 0){
      return (A_ThisHotkey = A_PriorHotkey)
    }else{
      return (A_ThisHotkey = A_PriorHotkey) and (A_TimeSincePriorHotkey < timeout)
    }
}

gg(){
  if(Trigger2(0)){
    Send {Home}
  }
}

; 声明 DllCall 需要用到的 Windows API 函数  
GetDPI() {  
    hDC := DllCall("GetDC", "ptr", 0) ; 获取桌面设备上下文  
    DPI := DllCall("GetDeviceCaps", "ptr", hDC, "int", 88) ; 88 是 LOGPIXELSX 的值  
    DllCall("ReleaseDC", "ptr", 0, "ptr", hDC) ; 释放设备上下文  
    return DPI  
}  


InitScreenInfo(){
  SysGet, Monitor1, Monitor, 1
  ; SysGet, MonitorWorkArea1, MonitorWorkArea, 1
  SysGet, Monitor2, Monitor, 2
  ; SysGet, MonitorWorkArea2, MonitorWorkArea, 2
  SysGet, Monitor3, Monitor, 3
  ; SysGet, MonitorWorkArea3, MonitorWorkArea, 3
  ; SysGet, Monitor4, Monitor, 4
  ; SysGet, MonitorWorkArea4, MonitorWorkArea, 4


  Monitor1Width:=Monitor1Right-Monitor1Left
  Monitor1Height:=Monitor1Bottom-Monitor1Top
  Monitor2Width:=Monitor2Right-Monitor2Left
  Monitor2Height:=Monitor2Bottom-Monitor2Top
  Monitor3Width:=Monitor3Right-Monitor3Left
  Monitor3Height:=Monitor3Bottom-Monitor3Top

  Mon1Left:=Monitor1Left
  Mon1Top:=Monitor1Top
  Mon2Left:=Monitor2Left
  Mon2Top:=Monitor2Top
  Mon3Left:=Monitor3Left
  Mon3Top:=Monitor3Top
}

GetCurrentScreenInfo(){
    InitScreenInfo()
    CoordMode, Mouse, Screen
    MouseGetPos, curX
    
    currentDPI := GetDPI()  
    DPI_Ratio := currentDPI / 96

    if (curX>=0 && curX<= Monitor1Width){
      MonitorLeft:=Mon1Left
      MonitorTop:=Mon1Top
      MonitorWidth:=Monitor1Width
      MonitorHeight:=Monitor1Height
      screenNum:=1
    }else if(curX<0 && curX>= -Monitor2Width){
      MonitorLeft:=Mon2Left
      MonitorTop:=Mon2Top
      MonitorWidth:=Monitor2Width
      MonitorHeight:=Monitor2Height
      screenNum:=2
    }else if(curX>Monitor1Width && curX<=Monitor1Width+Moniter3Width){
      MonitorLeft:=Mon3Left
      MonitorTop:=Mon3Top
      MonitorWidth:=Monitor3Width
      MonitorHeight:=Monitor3Height
      screenNum:=3
    }else{
      ; MonitorLeft:=Mon4Left
      ; MonitorTop:=Mon4Top
      ; MonitorWidth:=Monitor4Right-Monitor4Left
      ; MonitorHeight:=Monitor4Bottom-Monitor4Top
      screenNum:=4
    }
}

InStrs(s, strings){
  for i,str in strings{
    if(InStr(s, str)){
      return true
    }
  }
  return false
}

WinActiveInTitle(title){
  WinGetActiveTitle, activeTitle   
  ; 检查窗口标题是否包含 title  
  if(InStr(activeTitle, title)){
    return true
  }else{
    return false
  }
}

WinActiveInTitles(titles){
  for i,title in titles{
    WinGetActiveTitle, activeTitle   
    ; 检查窗口标题是否包含 title  
    if(InStr(activeTitle, title)){
      return true
    } 
  }

  return false
}

WinActiveBrowser(){
    ; 获取当前激活窗口的 ID  
  WinGet, activeWindowId, ID, A  ; "A" 表示激活的窗口  

  return WinIsBrowser(activeWindowId)
}

WinIsBrowser(winId){
  WinGetTitle, winTitle, ahk_id %winId%  ; 获取窗口类名  
  WinGet, winProcessName, ProcessName, ahk_id %winId%  ; 获取窗口类名  

  for i,title in CHROME_VIM_MODE_BROSWERS_TITLE{
    ; 检查窗口标题是否包含 title  
    exe:= CHROME_VIM_MODE_BROSWERS_EXE[i]

    if(InStr(winTitle, title) || winProcessName == exe){
      return true
    } 
  }
  return false
}

Accelerate(velocity, pos, neg) {
  If (pos == 0 && neg == 0) {
    Return 0
  }
  ; smooth deceleration :)
  Else If (pos + neg == 0) {
    Return velocity * 0.666
  }

  If (velocity > 0 && pos+neg <0) {
    Return 0
  }

  If (velocity < 0 && pos+neg >0) {
    Return 0
  }

  ; physicszzzzz
  Else {
    Return velocity * RESISTANCE + FORCE * (pos + neg)
  }
}

MoveCursor() {
  If (WinActive("ahk_class CabinetWClass")){
    ALT := GetKeyState("Alt", "P")
    if(ALT){
      return
    }
  }

  CTRL := GetKeyState("Ctrl", "P")
  h := GetKeyState("H", "P")
  j := GetKeyState("J", "P")
  k := GetKeyState("K", "P")
  l := GetKeyState("L", "P")
  if(CTRL && (h||j||k||l)){
    return
  }

  if(CHROME_VIM_MODE){
    ; chrome enter vim mode
    if(WinActiveBrowser()){
      if(CHROME_VIM_MODE_HINT){
        ShowModePopup("CHROME VIM")
        CHROME_VIM_MODE_HINT := false
        NORMAL_MODE_HINT := true
      }
      if(WASD == true ){
        OLD_WASD := WASD
      }
      WASD := false
    }else{
      WASD := OLD_WASD
      if(NORMAL_MODE_HINT){
        NORMAL_MODE_HINT := false
        ToggleExtDraggingMode(false)
        msg := "NORMAL"
        If (WASD == false) {
          msg := msg . " (VIM)"
        }
        If (quick) {
          msg := msg . " (QUICK)"
        }
        ShowModePopup(msg)
      }
    }
  }

  if(WinActiveInTitles(EXT_DRAGGING_APPS)){
    if(EXT_DRAGGING_HINT){
      EXT_DRAGGING_HINT:=false
      ToggleExtDraggingMode(true)
      ShowModePopup("EXT DRAG ON")
    }else{
      ToggleExtDraggingMode(false)
    }
  }
  


  LEFT := 0
  DOWN := 0
  UP := 0
  RIGHT := 0
  
  LEFT := LEFT - GetKeyState("h", "P")
  DOWN := DOWN + GetKeyState("j", "P")
  UP := UP - GetKeyState("k", "P")
  RIGHT := RIGHT + GetKeyState("l", "P")
  
  if (WASD) {
    UP := UP -  GetKeyState("w", "P")
    LEFT := LEFT - GetKeyState("a", "P")
    DOWN := DOWN + GetKeyState("s", "P")
    RIGHT := RIGHT + GetKeyState("d", "P")
  }
  
  If (NORMAL_QUICK) {
    caps_down := GetKeyState("Capslock", "P")
    IF (caps_down == 0) {
      EnterInsertMode()
    }
  }
  
  If (NORMAL_MODE == false) {
    VELOCITY_X := 0
    VELOCITY_Y := 0
    SetTimer,, Off
  }
  
  VELOCITY_X := Accelerate(VELOCITY_X, LEFT, RIGHT)
  VELOCITY_Y := Accelerate(VELOCITY_Y, UP, DOWN)

  RestoreDPI:=DllCall("SetThreadDpiAwarenessContext","ptr",-3,"ptr") ; enable per-monitor DPI awareness

  MouseMove, %VELOCITY_X%, %VELOCITY_Y%, 0, R

  if(INSERT_AUTO_QUICK){
    if A_Cursor = IBeam 
    {  
      IS_EDIT := true
    }
    else
    {
      IS_EDIT := false
    }
  }
}

EnterNormalMode(quick:=false, force:=false) {
  ;MsgBox, "Welcome to Normal Mode"
  NORMAL_QUICK := quick

  if(force == false){
    ; 检查窗口标题是否包含 "uTools"  
    if(WinActiveInTitle("uTools")){
      ;; 二次检测若关闭则进入normal模式
      Sleep 100
      if(WinActiveInTitle("uTools") ){
        return
      }
    }
  }

  CHROME_VIM_MODE_HINT := true
  EXT_DRAGGING_HINT :=true
  msg := "NORMAL"
  If (WASD == false || (CHROME_VIM_MODE && WinActiveBrowser())) {
    msg := msg . " (VIM)"
  }
  If (quick) {
    msg := msg . " (QUICK)"
  }
  ShowModePopup(msg)

  If (NORMAL_MODE) {
    Return
  }
  NORMAL_MODE := true
  FAST_MODE := false
  INSERT_MODE := false
  INSERT_QUICK := false

  SetTimer, MoveCursor, 16
}

EnterWASDMode(quick:=false) {
  CHROME_VIM_MODE_HINT := true
  If(CHROME_VIM_MODE && WinActiveBrowser()){
    ExitWASDMode()
    return
  }
  msg := "NORMAL"
  If (quick) {
    msg := msg . " (QUICK)"
  }
  ShowModePopup(msg)
  WASD := true
  OLD_WASD :=WASD
  EnterNormalMode(quick)
}

ExitWASDMode() {
  CHROME_VIM_MODE_HINT := true
  ShowModePopup("NORMAL (VIM)")
  WASD := false
  OLD_WASD :=WASD
}

EnterInsertMode(quick:=false) {
  ;MsgBox, "Welcome to Insert Mode"
  msg := "INSERT"
  If (quick) {
    msg := msg . " (QUICK)"
  }
  ShowModePopup(msg)
  INSERT_MODE := true
  INSERT_QUICK := quick
  NUMPAD := false
  NORMAL_MODE := false
  NORMAL_QUICK := false
  FAST_MODE := false
}

EnterNumpadMode(quick:=false) {
  ;MsgBox, "Welcome to Insert Mode"
  msg := "INSERT (NUMPAD)"
  ShowModePopup(msg)
  INSERT_MODE := true
  INSERT_QUICK := quick
  NUMPAD := true
  NORMAL_MODE := false
  NORMAL_QUICK := false
  FAST_MODE := false
}

EnterFastMode(mode:=true, ext:=false){
  ; msg := "FAST"
  ; ShowModePopup(msg)
  
  If (FAST_MODE) {
    Return
  }

  FAST_MODE_EXT:=ext

  FAST_MODE := true
  NORMAL_MODE := false
  ; NORMAL_QUICK := false
  INSERT_MODE := false
  INSERT_QUICK := false

    MouseGetPos, , , windowUnderMouse  ; 获取鼠标位置和窗口句柄  
    if(windowUnderMouse)
    {  
      ; WinGetTitle, winTitle, ahk_id %windowUnderMouse%  ; 获取窗口类名  
      ; ToolTip, 鼠标下方窗口类: %className%  ; 显示窗口类名  
      ; ToolTip, title: %winTitle%  ; 显示窗口类名  
      ; WinActivate, ahk_id %windowUnderMouse%  ; 激活鼠标下方的窗口  
      if(mode){
        if(CHROME_VIM_MODE && WinIsBrowser(windowUnderMouse)){
            if(CHROME_VIM_MODE_AUTO_ACTIVATE){
              WinActivate, ahk_id %windowUnderMouse%  ; 激活鼠标下方的窗口  
              EnterInsertMode(true)
              Send {f}
            }else if(WinActiveBrowser()){
              EnterInsertMode(true)
              Send {f}
            }else{
              SetTimer FastModeHints, -10
            }
        }else{
          SetTimer FastModeHints, -10
        }
      }else{
        SetTimer FastModeHints, -10
      }
    }else{
      SetTimer FastModeHints, -10
    }

}

ToggleChromeVimMode(){
  CHROME_VIM_MODE := !CHROME_VIM_MODE
  if(CHROME_VIM_MODE){
    ShowModePopup("CHROME VIM ON")
  }else{
    ShowModePopup("CHROME VIM OFF")
  }
}

ToggleExtDraggingMode(open:=false){
  EXT_DRAGGING_MODE := open

}
SetMouseSpeedMode(speedMode){
  if(speedMode == 1){
    SetForce(7)
  } else if(speedMode == 2){
    SetForce(20)
  } else if(speedMode == 0){
    SetForce(2)
  }
}

ClickInsert(quick:=true) {
  Click
  EnterInsertMode(quick)
}

DoubleClick() {
  Click
  Sleep, 100
  Click
}

; FIXME:
; doesn't really work well
DoubleClickInsert(quick:=true) {
  Click
  Sleep, 100
  Click
  EnterInsertMode(quick)
}

ShowPopup(msg) {
  ; clean up any lingering popups
  ; ClosePopup()
  GetCurrentScreenInfo()
  centerx := MonitorLeft + (MonitorWidth // 2)
  centery := MonitorHeight // 2
  right := MonitorLeft + MonitorWidth
  bottom := MonitorTop + MonitorHeight
  popx := right - DPI_v(170*2)
  popy := bottom - DPI_v(28*2) - DPI_v(50)
  if(THEME_DARK){
    Progress, b x%popx% y%popy% zh0 w340 h56 fm24 ctFBFBFB cw2D2D2D,, %msg%,,Microsoft YaHei
  }else{
    Progress, b x%popx% y%popy% zh0 w340 h56 fm24 ct2D2D2D cwFBFBFB,, %msg%,,Microsoft YaHei
  }
  POP_UP := true
}

ShowModePopup(msg) {
  ; clean up any lingering popups
  ClosePopup()
  ShowPopup(msg)
  SetTimer, ClosePopup, -1600
}

ClosePopup() {
  Progress, Off
  POP_UP := false
}

Drag() {
  If (DRAGGING) {
    Click, Left, Up
    DRAGGING := false
    ClosePopup() 
  } else {
    ShowPopup("DRAG")
    Click, Left, Down
    DRAGGING := true
  }
}

RightDrag() {
  If (DRAGGING) {
    Click, Right, Up
    DRAGGING := false
    ClosePopup() 
  } else {
    ShowPopup("RIGHT DRAG")
    Click, Right, Down
    DRAGGING := true
  }
}

MiddleDrag() {
  If (DRAGGING) {
    Click, Middle, Up
    DRAGGING := false
    ClosePopup() 
  } else {
    ShowPopup("MIDDLE DRAG")
    Send {MButton down}
    DRAGGING := true
  }
}

; For Fusion360
ShiftMiddleDrag() {
  If(EXT_DRAGGING_MODE == false){
    return
  }
  If (DRAGGING) {
    KeyWait Shift
    Click, Middle, Up
    DRAGGING := false
    SHIFT_DRAGGING := false
    Send {Shift up}
    ClosePopup() 
  } else {
    KeyWait Shift
    ShowPopup("SHIFT MIDDLE DRAG")
    Send {Shift down}
    Send {MButton down}
    DRAGGING := true
    SHIFT_DRAGGING := true
  }
}

CtrlMiddleDrag() {
  If(EXT_DRAGGING_MODE == false){
    return
  }
  If (DRAGGING) {
    KeyWait Ctrl
    Click, Middle, Up
    DRAGGING := false
    CTRL_DRAGGING := false
    Send {Ctrl up}
    ClosePopup() 
  } else {
    KeyWait Ctrl
    ShowPopup("CTRL MIDDLE DRAG")
    Send {Ctrl down}
    Send {MButton down}
    DRAGGING := true
    CTRL_DRAGGING := true
  }
}

ReleaseDrag(button) {
  if(SHIFT_DRAGGING){
    Send {Shift up}
  }
  if(CTRL_DRAGGING){
    Send {Ctrl up}
  }
  if(button == 1){
    Click, Left, Up
  }

  if(button == 2){
    Click, Middle, Up
  }

  if(button == 3){
    Click, Right, Up
  }
  DRAGGING := false
  SHIFT_DRAGGING := false
  CTRL_DRAGGING := false
  ClosePopup()
}

ReleaseAllDrag() {
  If (DRAGGING) {
    if(SHIFT_DRAGGING){
      Send {Shift up}
    }
    if(CTRL_DRAGGING){
      Send {Ctrl up}
    }

    lState := GetKeyState("LButton")
    MState := GetKeyState("MButton")
    RState := GetKeyState("RButton")
    if(LState){
      Click, Left, Up
    }

    if(MState){
      Click, Middle, Up
    }

    if(RState){
      Click, Right, Up
    }

    DRAGGING := false
    SHIFT_DRAGGING := false
    CTRL_DRAGGING := false
    ClosePopup() 
  }
}

Yank() {
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx + width - DPI_v(180)-DPI_v(24)
  y := wy + DPI_v(12)
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
  Drag()
}

Close(){
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx + width - DPI_v(24)
  y := wy + DPI_v(12)
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
}

Min(){
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx + width - DPI_v(24)-DPI_v(48*2)
  y := wy + DPI_v(12)
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
}

Max(){
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx + width - DPI_v(24) -DPI_v(48)
  y := wy + DPI_v(12)
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
}

Back(){
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  MouseMove, wx+DPI_v(24), wy + DPI_v(24)
  ;MsgBox, Hello %width% %center%
}

DialogBtnLeft(){
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  MouseMove, wx+width-DPI_v(68+96*2), wy+height - DPI_v(32)
  ;MsgBox, Hello %width% %center%
}

DialogBtnCenter(){
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  MouseMove, wx+width-DPI_v(68+96), wy+height - DPI_v(32)
}
DialogBtnRight(){
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  MouseMove, wx+width-DPI_v(68), wy+height - DPI_v(32)
}

Resize(){
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  x := wx + width - DPI_v(12) 
  y := wy + height - DPI_v(6)
  ;MsgBox, Hello %width% %x%
  MouseMove, x, y
  Drag()
}

MouseLeft() {
  if (SHIFT_DRAGGING){
    Send {Shift up}
  }
  if (CTRL_DRAGGING){
    Send {Ctrl up}
  }

  if(INSERT_AUTO_QUICK && NORMAL_QUICK ==false && IS_EDIT && NORMAL_MODE)
  {  
    EnterInsertMode(true)
  }

  Click
  DRAGGING := false
  SHIFT_DRAGGING := false
  CTRL_DRAGGING := false

}

MouseRight() {
  if (SHIFT_DRAGGING){
    Send {Shift up}
  }
  if (CTRL_DRAGGING){
    Send {Ctrl up}
  }
  Click, Right
  DRAGGING := false
  SHIFT_DRAGGING := false
  CTRL_DRAGGING := false
}

MouseMiddle() {
  if (SHIFT_DRAGGING){
    Send {Shift up}
  }
  if (CTRL_DRAGGING){
    Send {Ctrl up}
  }
  Click, Middle
  DRAGGING := false
  SHIFT_DRAGGING := false
  CTRL_DRAGGING := false
}

global WINDOW_MARGIN:=5
JumpWindowLeftEdge() {
  if(SHIFT_DRAGGING){
    return
  }
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  ;MsgBox, Hello %width% %center%
  x := 0
  CoordMode, Mouse, Screen
  MouseGetPos,,y
  MouseMove, wx+DPI_v(WINDOW_MARGIN),y
}

JumpWindowBottomEdge() {
  if(SHIFT_DRAGGING){
    return
  }

  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  ;MsgBox, Hello %width% %center%
  x := 0
  CoordMode, Mouse, Screen
  MouseGetPos, x
  MouseMove, x,(wy+height - DPI_v(WINDOW_MARGIN))
}

JumpWindowTopEdge() {
  if(SHIFT_DRAGGING){
    return
  }

  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  ;MsgBox, Hello %width% %center%
  x := 0
  CoordMode, Mouse, Screen
  MouseGetPos, x
  MouseMove, x,wy+DPI_v(WINDOW_MARGIN)

}

JumpWindowRightEdge() {
  if(SHIFT_DRAGGING){
    return
  }

  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  ;MsgBox, Hello %width% %center%
  x := 0
  y := 0
  CoordMode, Mouse, Screen
  MouseGetPos,,y
  MouseMove, wx+width-DPI_v(WINDOW_MARGIN),y
}

; TODO: When we have more monitors, set up H and L to use current screen as basis
; hard to test when I only have the one

JumpCurrentMiddle() {
  GetCurrentScreenInfo()
  CoordMode, Mouse, Screen
  MouseMove, MonitorLeft + (MonitorWidth // 2), MonitorTop+(MonitorHeight // 2)
}

JumpMiddle_1() {
  CoordMode, Mouse, Screen
  MouseMove, (-A_ScreenWidth // 2), (A_ScreenHeight // 2)
}

JumpMiddle() {
  CoordMode, Mouse, Screen
  MouseMove, (A_ScreenWidth // 2), (A_ScreenHeight // 2)
}

JumpMiddle2() {
  CoordMode, Mouse, Screen
  MouseMove, (A_ScreenWidth + A_ScreenWidth // 2), (A_ScreenHeight // 2)
}

JumpMiddle3() {
  CoordMode, Mouse, Screen
  MouseMove, (A_ScreenWidth * 2 + A_ScreenWidth // 2), (A_ScreenHeight // 2)
}

JumpWindowMiddle() {
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  centerx := wx + width//2
  centery := wy + height//2
  ;MsgBox, Hello %width% %center%
  MouseMove, centerx, centery
}

MonitorLeftEdge() {
  mx := 0
  CoordMode, Mouse, Screen
  MouseGetPos, mx
  monitor := (mx // A_ScreenWidth)

  return monitor * A_ScreenWidth
}

JumpLeftEdge() {
  if(SHIFT_DRAGGING){
    return
  }
  x := MonitorLeftEdge() + 2
  y := 0
  CoordMode, Mouse, Screen
  MouseGetPos,,y
  MouseMove, x,y
}

JumpBottomEdge() {
  if(SHIFT_DRAGGING){
    return
  }
  x := 0
  CoordMode, Mouse, Screen
  MouseGetPos, x
  MouseMove, x,(A_ScreenHeight - 0)
}

JumpTopEdge() {
  if(SHIFT_DRAGGING){
    return
  }
  x := 0
  CoordMode, Mouse, Screen
  MouseGetPos, x
  MouseMove, x,0
}

JumpRightEdge() {
  if(SHIFT_DRAGGING){
    return
  }
  x := MonitorLeftEdge() + A_ScreenWidth - 2
  y := 0
  CoordMode, Mouse, Screen
  MouseGetPos,,y
  MouseMove, x,y
}

MouseBack() {
  Click, X1
}

MouseForward() {
  Click, X2
}

ScrollUp() {
  Click, WheelUp
  Click, WheelUp
}

ScrollDown() {
  Click, WheelDown
  Click, WheelDown
}

ScrollUpMore() {
  ; Click, WheelUp
  ; Click, WheelUp
  ; Click, WheelUp
  ; Click, WheelUp
  Send {PgUp}
  Return
}

ScrollDownMore() {
  ; Click, WheelDown
  ; Click, WheelDown
  ; Click, WheelDown
  ; Click, WheelDown
  Send {PgDn}
  Return
}
SetCapslock(){
  state := GetKeyState("CapsLock", "T")
  IF(state == 0){
    SetCapsLockState, On
    ShowModePopup("CapsLock(ON)")
  }Else{
    SetCapsLockState, Off
    ShowModePopup("CapsLock(OFF)")
  }
}
SetVolume(volume){
 If(volume>0){
   SoundSet, +volume 
 }Else{
   SoundSet, volume 
 }
 SoundGet, masterVolume
 ShowModePopup(Format("Volume: {:d}%", Round(masterVolume)))
}

SetForce(v, relative:=0){
  if(relative == 1){
    if(FORCE+v>0){
      FORCE += v
    }
  }else{
   FORCE:=v
  }
  ShowModePopup(Format("Speed: {:.1f}", FORCE))
}

SwitchSmallMode(){
  SMALL_MODE := !SMALL_MODE
  if(SMALL_MODE){
    ShowModePopup("SMALL MODE ON")
  }else{
    ShowModePopup("SMALL MODE OFF")
  }
}

; Gui, 1:+LastFound +AlwaysOnTop +ToolWindow
; Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
; Gui, 1:Show, NA
; Gui, 1:Maximize
; GuiHwnd := WinExist() ; capture window handle
; Gui, 1:Hide

; global hDc:=0
; global hCurrPen:=0
global fastModeCache := false
global alphaTable:=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

FastModeLabel(show:=true){
  ClosePopup()
  if(show){
    GetCurrentScreenInfo()

    MonitorWidthDPI:=MonitorWidth/DPI_Ratio
    MonitorHeightDPI:=MonitorHeight/DPI_Ratio

    if(screenNum != lastScreenNum){
      fastModeCache := false
      lastScreenNum := screenNum
    }

    ; add cache to show quickly
    if(fastModeCache == true){
      Gui Show, % "x" MonitorLeft " y" MonitorTop " w"MonitorWidthDPI " h"MonitorHeightDPI, TRANS-WIN
      WinSet TransColor, 888888, TRANS-WIN
      Gui,3: Show, % "x" MonitorLeft " y" MonitorTop " w"MonitorWidthDPI " h"MonitorHeightDPI, TRANS-WIN
        WinSet TransColor, 777777, TRANS-WIN
      return
    }

    Gui, destroy
    Gui Color, 888888
    Gui -caption +toolwindow +AlwaysOnTop
    Gui font,% "s" FAST_MODE_FONT_SIZE, Microsoft YaHei

    Gui, 3:destroy
    Gui, 3:Color, 777777
    Gui, 3:-caption +toolwindow +AlwaysOnTop
    Gui, 3:font,% "s" FAST_MODE_EXT_FONT_SIZE, Microsoft YaHei
    ; if(THEME_DARK){
    ;   FAST_MODE_FONT_COLOR := "Red"
    ; }else{
    ;   FAST_MODE_FONT_COLOR := "Red"
    ; }

    i:=0
    Loop,%FAST_MODE_Y%{
      j:=0
      Loop, %FAST_MODE_X%{
        k:=i*FAST_MODE_X+j
        alpha1 :=alphaTable[k//26+1]
        alpha2 :=alphaTable[Mod(k, 26)+1]
        label:= alpha1 alpha2
        
        Gui add, text,% "c" FAST_MODE_FONT_COLOR  " TransColor White " "X" MonitorWidthDPI/FAST_MODE_X*j+1 " Y" MonitorHeightDPI/FAST_MODE_Y*i+1 " W"MonitorWidthDPI/FAST_MODE_X-2 " H"MonitorHeightDPI/FAST_MODE_Y-2, %label% 
        j+=1
      }
      i+=1
    }

    i:=1
    ly:=FAST_MODE_Y-1
    lx:=FAST_MODE_X-1
    Loop, %ly%{
      gui, 3: add, text, % "x0" " y" MonitorHeightDPI/FAST_MODE_Y*i " w" MonitorWidthDPI " 0x10"  ;Horizontal Line > Etched Gray
      i+=1
    }

    j:=1
    Loop, %lx%{
      gui, 3:add, text, % "x" MonitorWidthDPI/FAST_MODE_X*j " y0" " h" MonitorHeightDPI " 0x11"  ;Horizontal Line >% Etched Gray
      j+=1
    }

    Gui Show, % "x" MonitorLeft " y" MonitorTop " w"MonitorWidthDPI " h"MonitorHeightDPI, TRANS-WIN
    WinSet TransColor, 888888, TRANS-WIN

    Gui,3: Show, % "x" MonitorLeft " y" MonitorTop " w"MonitorWidthDPI " h"MonitorHeightDPI, TRANS-WIN
    WinSet TransColor, 777777, TRANS-WIN

    fastModeCache := true
  }else{
    Gui Hide
    Gui,3: Hide
  }
}

HideFastModeJustLabel(){
    Gui Hide
}

global fstModeExtCache:=false

FastModeExtLabel(show:=true, row:=0, col:=0){
  ClosePopup()
  if(show){
    MonitorWidthDPI:=MonitorWidth/DPI_Ratio
    MonitorHeightDPI:=MonitorHeight/DPI_Ratio
    FastModeWidth:= MonitorWidth/FAST_MODE_X
    FastModeHeight:= MonitorHeight/FAST_MODE_Y
    FastModeWidthDPI:= MonitorWidth/FAST_MODE_X/DPI_Ratio
    FastModeHeightDPI:= MonitorHeight/FAST_MODE_Y/DPI_Ratio

    ; add cache to show quickly
    if(fastModeExtCache == true){
      Gui,2: Show, % "x" MonitorWidth/FAST_MODE_X*col " y" MonitorHeight/FAST_MODE_Y*row " w"FastModeWidthDPI " h"FastModeHeightDPI, TRANS-WIN
      WinSet TransColor, 888888, TRANS-WIN
      return
    }

    Gui, 2:destroy
    Gui, 2:Color, 888888
    Gui, 2:-caption +toolwindow +AlwaysOnTop
    Gui, 2:font,% "s" FAST_MODE_EXT_FONT_SIZE, Microsoft YaHei
    ; if(THEME_DARK){
    ;   FAST_MODE_FONT_COLOR := "Red"
    ; }else{
    ;   FAST_MODE_FONT_COLOR := "Red"
    ; }

    i:=0
    Loop,%FAST_MODE_EXT_Y%{
      j:=0
      Loop, %FAST_MODE_EXT_X%{
        k:=i*FAST_MODE_EXT_X+j
        alpha2 :=alphaTable[Mod(k,26)+1]
        label:= alpha2
        
        x:=FastModeWidthDPI/FAST_MODE_EXT_X*j+1
        y:=FastModeHeightDPI/FAST_MODE_EXT_Y*i+1
        Gui,2: add, text,% "c" FAST_MODE_EXT_FONT_COLOR  " TransColor White " "X"x  " Y"y " W"FastModeWidthDPI/FAST_MODE_EXT_X-2 " H"FastModeHeightDPI/FAST_MODE_EXT_Y-2, %label% 
        j+=1
      }
      i+=1
    }


    i:=0
    ly:=FAST_MODE_EXT_Y+1
    lx:=FAST_MODE_EXT_X+1
    Loop, %ly%{
      gui,2: add, text, % "x0" " y" FastModeHeightDPI/FAST_MODE_EXT_Y*i " w" FastModeWidthDPI+2 " 0x10"  ;Horizontal Line > Etched Gray
      i+=1
    }

    j:=0
    Loop, %lx%{
      gui,2: add, text, % "x" FastModeWidthDPI/FAST_MODE_EXT_X*j " y0" " h" FastModeHeightDPI+2 " 0x11"  ;Horizontal Line >% Etched Gray
      j+=1
    }

    Gui,2:Show, % "x" MonitorLeft+FastModeWidth*col " y" MonitorTop+FastModeHeight*row " w"FastModeWidthDPI+2 " h"FastModeHeightDPI+2, TRANS-WIN
    WinSet TransColor, 888888, TRANS-WIN

    fastModeExtCache := true
  }else{
    Gui,2: Hide
  }
}

global fastModeRow:=0
global fastModeCol:=0
FastModeHints(){
    SetTimer FastModeLabel, -1
    matches:=""
    i:=0
    Loop,%FAST_MODE_Y%{
      j:=0
      Loop, %FAST_MODE_X%{
        k:=i*FAST_MODE_X+j
        alpha1 :=alphaTable[k//26+1]
        alpha2 :=alphaTable[Mod(k, 26)+1]
        label:= alpha1 alpha2
        matches:=matches label ","
        j+=1
      }
      i+=1
    }
    matches:=SubStr(matches, 1, StrLen(matches)-1)

    Input, UserInput, B L2, {esc}.{enter}, %matches%

    if (ErrorLevel = "Max")
    {
        ; MsgBox, You entered "%UserInput%", which is the maximum length of text.
        ; Gui, 1:Hide
        FastModeLabel(false)
        if(NORMAL_QUICK == false){
          EnterNormalMode()
        }else{
          EnterInsertMode()
        }
        return
    }
    ; if (ErrorLevel = "Timeout")
    ; {
    ;     ; MsgBox, You entered "%UserInput%" at which time the input timed out.
    ;     ; Gui, 1:Hide
    ;     FastModeLabel(false)
    ;     EnterNormalMode()
    ;     return
    ; }

    If InStr(ErrorLevel, "EndKey:")
    {
        ; MsgBox, You entered "%UserInput%" and terminated the input with %ErrorLevel%.
        ; Gui, 1:Hide
        FastModeLabel(false)
        if(NORMAL_QUICK == false){
          EnterNormalMode()
        }else{
          EnterInsertMode()
        }
        return
    }
    if (ErrorLevel = "Match")
    {
      i:=0
      Loop,%FAST_MODE_Y%{
        j:=0
        Loop, %FAST_MODE_X%{
          k:=i*FAST_MODE_X+j
          alpha1 :=alphaTable[k//26+1]
          alpha2 :=alphaTable[Mod(k, 26)+1]
          label:= alpha1 alpha2
          if (UserInput == label)
          {
              MouseMove, MonitorLeft+MonitorWidth/(FAST_MODE_X*2)*(j*2+1), MonitorTop+MonitorHeight/(FAST_MODE_Y*2)*(i*2+1)
              fastModeRow:=i
              fastModeCol:=j
              break
          }
          j+=1
        }
        i+=1
      }

      if(FAST_MODE_EXT){
        HideFastModeJustLabel()
        FastModeExtHints()
      }else{
        FastModeLabel(false)
        if(NORMAL_QUICK == false){
          EnterNormalMode()
        }else{
          EnterInsertMode()
        }
      }
      return
    }
    if (ErrorLevel = "NewInput"){
      ; MsgBox, You entered "%UserInput%" and terminated the input with %ErrorLevel%.
      ; Gui, 1:Hide
      FastModeLabel(false)
      if(NORMAL_QUICK == false){
        EnterNormalMode()
      }else{
        EnterInsertMode()
      }
      return
    }
}

FastModeExtLabelTimer(){
  FastModeExtLabel(true, fastModeRow, fastModeCol)
}

FastModeExtHints(){
    SetTimer FastModeExtLabelTimer, -1

    FastModeWidth:= MonitorWidth/FAST_MODE_X
    FastModeHeight:= MonitorHeight/FAST_MODE_Y
    FastModeWidthDPI:= MonitorWidth/FAST_MODE_X/DPI_Ratio
    FastModeHeightDPI:= MonitorHeight/FAST_MODE_Y/DPI_Ratio

    matches:=""
    i:=0
    Loop,%FAST_MODE_EXT_Y%{
      j:=0
      Loop, %FAST_MODE_EXT_X%{
        k:=i*FAST_MODE_EXT_X+j
        ; alpha1 :=alphaTable[k//26+1]
        alpha2 :=alphaTable[Mod(k, 26)+1]
        label:= alpha2
        matches:=matches label ","
        j+=1
      }
      i+=1
    }
    matches:=SubStr(matches, 1, StrLen(matches)-1)
    Input, UserInput, B L1, {esc}.{enter}, %matches%

    if (ErrorLevel = "Max")
    {
        ; MsgBox, You entered "%UserInput%", which is the maximum length of text.
        ; Gui, 1:Hide
        FastModeLabel(false)
        FastModeExtLabel(false)
        if(NORMAL_QUICK == false){
          EnterNormalMode()
        }else{
          EnterInsertMode()
        }
        return
    }
    ; if (ErrorLevel = "Timeout")
    ; {
    ;     ; MsgBox, You entered "%UserInput%" at which time the input timed out.
    ;     ; Gui, 1:Hide
    ;     FastModeLabel(false)
    ;     EnterNormalMode()
    ;     return
    ; }

    If InStr(ErrorLevel, "EndKey:")
    {
        ; MsgBox, You entered "%UserInput%" and terminated the input with %ErrorLevel%.
        ; Gui, 1:Hide
        FastModeLabel(false)
        FastModeExtLabel(false)
        if(NORMAL_QUICK == false){
          EnterNormalMode()
        }else{
          EnterInsertMode()
        }
        return
    }
    if (ErrorLevel = "Match")
    {
      i:=0
      Loop,%FAST_MODE_EXT_Y%{
        j:=0
        Loop, %FAST_MODE_EXT_X%{
          k:=i*FAST_MODE_EXT_X+j
          alpha2 :=alphaTable[Mod(k, 26)+1]
          label:= alpha2
          if (UserInput == label)
          {
              MouseMove, MonitorLeft+FastModeWidth*fastModeCol+FastModeWidth/(FAST_MODE_EXT_X*2)*(j*2+1), MonitorTop+FastModeHeight*fastModeRow+FastModeHeight/(FAST_MODE_EXT_Y*2)*(i*2+1)
              break
          }
          j+=1
        }
        i+=1
      }

      FastModeLabel(false)
      FastModeExtLabel(false)
      if(NORMAL_QUICK == false){
        EnterNormalMode()
      }else{
        EnterInsertMode()
      }
      return
    }

    if (ErrorLevel = "NewInput"){
      ; MsgBox, You entered "%UserInput%" and terminated the input with %ErrorLevel%.
      ; Gui, 1:Hide
      FastModeLabel(false)
      FastModeExtLabel(false)
      if(NORMAL_QUICK == false){
        EnterNormalMode()
      }else{
        EnterInsertMode()
      }
      return
    }
}

; Canvas_Open(hWnd, p_color, p_w){
;  hDC := DllCall("GetDC", UInt, hWnd)
;  hCurrPen := DllCall("CreatePen", UInt, 0, UInt, p_w, UInt, p_color)
; }
; Canvas_DrawLine(hWnd, p_x1, p_y1, p_x2, p_y2)
; {
;  p_x1 -= 1, p_y1 -= 1, p_x2 -= 1, p_y2 -= 1
;  DllCall("SelectObject", UInt,hdc, UInt,hCurrPen)
;  DllCall("gdi32.dll\MoveToEx", UInt, hdc, Uint,p_x1, Uint, p_y1, Uint, 0 )
;  DllCall("gdi32.dll\LineTo", UInt, hdc, Uint, p_x2, Uint, p_y2 )
; }
; Canvas_Close(){
;  DllCall("ReleaseDC", UInt, 0, UInt, hDC)  ; Clean-up.
;  DllCall("DeleteObject", UInt,hCurrPen)
; }

; global M_x:=0
; global M_y := 0
; global Old_M_x:=0
; global Old_M_y := 0

; UpdatePos(){
;   MouseGetPos, M_x, M_y
; }
; CrossRuler(){
;     If (M_x != Old_M_x or M_y != Old_M_y){
;       WinSet, Redraw,, ahk_id %GuiHwnd%
;     }
;     if(Abs(VELOCITY_X) <10 && Abs(VELOCITY_Y) <10){
;       Canvas_DrawLine(GuiHwnd, M_x, 0, M_x, A_ScreenHeight_DPI)
;       Canvas_DrawLine(GuiHwnd, 0, M_y, A_ScreenWidth_DPI, M_y)
;     }
;     Old_M_x := M_x
;     Old_M_y := M_y
; }

; ShowCrossRuler(){
;   CROSS_RULER := !CROSS_RULER
;   if(CROSS_RULER){
;     Canvas_Open(GuiHwnd, "0x00FF00", 1)
;     SetTimer, UpdatePos, 50
;     SetTimer, CrossRuler, 10
;   }else{
;     Canvas_Close()
;     Gui, 1:Hide
;     SetTimer, CrossRuler, OFF
;   }
; }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "FINAL" MODE SWITCH BINDINGS
;Home:: EnterNormalMode()
;Insert:: EnterInsertMode()
#!n:: EnterNormalMode()
#!i:: EnterInsertMode()
#!p:: EnterNumpadMode()
#!c:: ToggleChromeVimMode()
; <#<!f:: EnterFastMode()

; escape hatches
;+Home:: Send {Home}
;+Insert:: Send {Insert}
;FIXME
; doesn't turn caplsock off.
; ^Capslock:: Send {Capslock}
; ; meh. good enough.
; ^+Capslock:: SetCapsLockState, Off

; disable ctrl+Capslock, use win+Capslock
^Capslock:: SetCapslock()
*^+Capslock:: Return
*!Capslock:: Return
; !+Capslock:: Return
; ^!+Capslock:: Return
*#Capslock:: Return
; #+Capslock:: Return
; ^#+Capslock:: Return

#If (NORMAL_MODE)
  ; focus window and enter Insert
  +`:: ClickInsert(false)
  ; Many paths to Quick Insert
  `:: ClickInsert(true)
  ; +S:: DoubleClickInsert()
  ; passthru for Vimium hotlinks 
  ; ~f:: EnterInsertMode(true)
  ; passthru to common "search" hotkey
  ~^f:: EnterInsertMode(true)
  f:: EnterFastMode(true)
  +F:: EnterFastMode(false, true)
  ; passthru for new tab
 ; ~^t:: EnterInsertMode(true)
  ; passthru for quick edits
  ~Delete:: EnterInsertMode(true)
  ;; passthru for everything or utools.
  ~!Space:: EnterInsertMode(true)  
  ~LWin:: EnterInsertMode(true)  
  ; do not pass thru
  ; +;:: EnterInsertMode(true)
  ; intercept movement keys
  h:: Return
  j:: Return
  k:: Return
  l:: Return
  +H:: JumpWindowLeftEdge()
  +J:: JumpWindowBottomEdge()
  +K:: JumpWindowTopEdge()
  +L:: JumpWindowRightEdge()

  ^o:: Send {AppsKey}
  ^h:: Send {Left}
  ^j:: Send {Down}
  ^k:: Send {Up}
  ^l:: Send {Right}

  ; commands
  *i:: MouseLeft()
  *o:: MouseRight()
  *p:: MouseMiddle()
  ; do not conflict with y as in "scroll up"
  +Y:: Yank()
  ; +X:: Close()
  +Z:: Resize()
  v:: Drag()
  ; x:: RightDrag()
  c:: MiddleDrag()
  +c:: ShiftMiddleDrag()
  ~^c:: CtrlMiddleDrag()
  m:: JumpCurrentMiddle()
  +,:: JumpMiddle_1()
  +.:: JumpMiddle()
  +?:: JumpMiddle2()

  !,:: DialogBtnLeft()
  !.:: DialogBtnCenter()
  !/:: DialogBtnRight()
  ; ahh what the heck, remove shift requirements for jump bindings
  ; maybe take "m" back if we ever make marks
  +M:: JumpWindowMiddle()
  ; ,:: JumpMiddle2()
  ; .:: JumpMiddle3()
  n:: MouseForward()
  b:: MouseBack()
  ; allow for modifier keys (or more importantly a lack of them) by lifting ctrl requirement for these hotkeys

  *]:: End
  *[:: Home
  *`;:: ScrollDown()
  *':: ScrollUp()
  ; #`;:: ScrollDownMore()
  ; #':: ScrollUpMore()
  ::: ScrollDownMore()
  ":: ScrollUpMore()
  =:: Send {Volume_Up}
  -:: Send {Volume_Down}
  0:: Send {Volume_Mute}
  f12:: SetForce(+1, 1)
  f11:: SetForce(-1, 1)
  f10:: SetForce(7, 0)
  +=:: SetForce(+1, 1)
  +-:: SetForce(-1, 1)
  +0:: SetForce(7, 0)
  !=:: SetMouseSpeedMode(2)
  !-:: SetMouseSpeedMode(0)
  !0:: SetMouseSpeedMode(1)
  ,:: Min()
  .:: Max()
  /:: Close()
  Backspace:: Back()
  !p:: Send {PrintScreen}
  ; !=:: ShowCrossRuler()
  End:: Click, Up


#If (NORMAL_MODE && NORMAL_QUICK == false)
  Capslock:: EnterInsertMode(true)
  +Capslock:: EnterInsertMode()
; Addl Vimik hotkeys that conflict with WASD mode
#If (NORMAL_MODE && WASD == false)
  <#<!v:: EnterWASDMode()
  e:: ScrollUpMore()
  ; y:: ScrollUp()
  d:: ScrollDownMore()
  u:: ScrollUpMore()
  g:: gg()
  +g::Send {End}
; No shift requirements in normal quick mode
#If (NORMAL_MODE && WASD == false && WinActiveBrowser() == false)
  ;; avoid accidental touch
  q:: Return
  w:: Return
  r:: Return
  t:: Return
  y:: Return
  a:: Return
  s:: Return
  z:: Return

#If (NORMAL_MODE && NORMAL_QUICK)
  Capslock:: Return
  m:: JumpCurrentMiddle()
  ,:: JumpMiddle_1()
  .:: JumpMiddle()
  ?:: JumpMiddle2()
  y:: Yank()
  ; x:: Close()
  z:: Resize()
  ; for windows explorer

;; windows explorer
#If (WinActive("ahk_class CabinetWClass"))
  !h:: Up
  !j:: Send {Down}
  !k:: Send {Up}
  ; !l:: Send {Right}
  ; !u:: Send !{Up}
  !l:: SendInput, {Enter}
  !b:: MouseBack()
  !n:: MouseForward()
  !x:: Send ^{w}

#If (NORMAL_MODE && WinActive("ahk_class CabinetWClass")==false)
  !i:: DoubleClick()
#If (NORMAL_MODE && (WinActive("ahk_class CabinetWClass") || WinActiveBrowser() || WinActive("ahk_class Notepad") || WinActive("ahk_class Notepad++")))
  x:: Send ^{w}
  +e:: Send ^+{Tab}''''
  +r:: Send ^{Tab}
; windows terminal
#If (NORMAL_MODE && (WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS"))) ;;; windows terminal
  x:: Send ^+{w}
  +e:: Send ^+{Tab}
  +r:: Send ^{Tab}
#If ((WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")))
  ^t:: Send ^+{t}
#If ((WinActive("ahk_class ahk_class Notepad++")))
  ^t:: Send ^{n}
#If (NORMAL_MODE && WinActiveBrowser()==false)
  x:: RightDrag()
#If (NORMAL_MODE && CHROME_VIM_MODE && WinActiveBrowser())
  ; ~f:: EnterInsertMode(true)
  ~t:: EnterInsertMode(true)
  ~g:: EnterInsertMode(true)
  ~^t:: EnterInsertMode(true)
  r:: F5
#If (NORMAL_MODE && WinActiveBrowser())
  !x:: Send ^{w}
#If (INSERT_MODE && WinActiveBrowser())
  !x:: Send ^{w}
#If (NORMAL_MODE && WASD == false && WinActiveInTitle("CrossCore Embedded Studio"))
  +E::Send ^{PgUp}
  +R::Send ^{PgDn}
#If (FAST_MODE)
  ; f:: FastModeHints()
#If (INSERT_MODE)
  ; Normal (Quick) Mode
#If (INSERT_MODE && INSERT_QUICK == false)
  Capslock:: EnterNormalMode(true)
  +Capslock:: EnterNormalMode()
#If (INSERT_MODE && NUMPAD && SMALL_MODE)
  !u::Send {Numpad7}
  !i::Send {Numpad8}
  !o::Send {Numpad9}
  !j::Send {Numpad4}
  !k::Send {Numpad5}
  !l::Send {Numpad6}
  !m::Send {Numpad1}
  !,::Send {Numpad2}
  !.::Send {Numpad3}
  !n::Send {Numpad0}
  !Backspace::Send {Backspace}
  !`;::Send {+}
  !'::Send {-}
  ![::Send {*}
  !]::Send {/}
  !Enter::Send {Enter}

  ; small keyboard layout
  !1::Send {f1}
  !2::Send {f2}
  !3::Send {f3} 
  !4::Send {f4}
  !5::Send {f5}
  !6::Send {f6}
  !7::Send {f7}
  !8::Send {f8}
  !9::Send {f9}
  !0::Send {f10}
  !-::Send {f11}
  !=::Send {f12}
  `:: Esc
  ^`::Send {``}
  +`::~

  !`:: SwitchSmallMode()
#If (INSERT_MODE && NUMPAD && SMALL_MODE == false)
  u::Send {Numpad7}
  i::Send {Numpad8}
  o::Send {Numpad9}
  j::Send {Numpad4}
  k::Send {Numpad5}
  l::Send {Numpad6}
  m::Send {Numpad1}
  ,::Send {Numpad2}
  .::Send {Numpad3}
  n::Send {Numpad0}
  `;::Send {+}
  '::Send {-}
  [::Send {*}
  ]::Send {/}
  !u::Send {u}
  !i::Send {i}
  !o::Send {o}
  !j::Send {j}
  !k::Send {k}
  !l::Send {l}
  !m::Send {m}
  !,::Send {,}
  !.::Send {.}
  !n::Send {n}
  !`;::Send {;}
  !'::Send {'}
  ![::Send {[}
  !]::Send {]}
  /::Send {=}

  ; left hand mode
  w::Send {Numpad7}
  e::Send {Numpad8}
  r::Send {Numpad9}
  s::Send {Numpad4}
  d::Send {Numpad5}
  f::Send {Numpad6}
  x::Send {Numpad1}
  c::Send {Numpad2}
  v::Send {Numpad3}
  z::Send {Numpad0}
  a::Send {+}
  q::Send {-}
  g::Send {*}
  t::Send {/}
  b::Send {.}
  `::Send {Backspace}
  Tab::Send {=}
  !`:: SwitchSmallMode()

#If (INSERT_MODE && INSERT_QUICK)
  ; ~Enter:: EnterNormalMode()
  ; Copy and return to Normal Mode
  ; ~^c:: EnterNormalMode()
  ~Escape:: EnterNormalMode()
  Capslock:: EnterNormalMode(false, true)
  +Capslock:: EnterNormalMode(false,  true)
#If (NORMAL_MODE && WASD)
  <#<!v:: ExitWASDMode()
  ; Intercept movement keys
  w:: Return
  a:: Return
  s:: Return
  d:: Return
  u:: Return
  z:: JumpCurrentMiddle()
  +W:: JumpTopEdge()
  +A:: JumpLeftEdge()
  +S:: JumpBottomEdge()
  +D:: JumpRightEdge()
  1:: ScrollDown()
  2:: ScrollUp()
  !:: ScrollDownMore()
  @:: ScrollUpMore()
  3:: Home
  4:: End
  *q:: MouseLeft()
  *e:: MouseRight()
  *r:: MouseMiddle()

#IF (DRAGGING)
  LButton:: ReleaseAllDrag()
  MButton:: ReleaseAllDrag()
  RButton:: ReleaseAllDrag()
  i:: ReleaseAllDrag()
  o:: ReleaseAllDrag()
  p:: ReleaseAllDrag()
#If (DRAGGING && WASD)
  r:: ReleaseAllDrag()
  t:: ReleaseAllDrag()
  y:: ReleaseAllDrag()
#IF (CTRL_DRAGGING)
  ^LButton:: ReleaseAllDrag()
  ^MButton:: ReleaseAllDrag()
  ^RButton:: ReleaseAllDrag()
  ^i:: ReleaseAllDrag()
  ^o:: ReleaseAllDrag()
  ^p:: ReleaseAllDrag()
#If (CTRL_DRAGGING && WASD)
  ^r:: ReleaseAllDrag()
  ^t:: ReleaseAllDrag()
  ^y:: ReleaseAllDrag()
#IF (SHIFT_DRAGGING )
  +lbutton:: releasealldrag()
  +mbutton:: releasealldrag()
  +rbutton:: releasealldrag()
  +i:: ReleaseAllDrag()
  +o:: ReleaseAllDrag()
  +p:: ReleaseAllDrag()
#If (SHIFT_DRAGGING && WASD)
  +r:: ReleaseAllDrag()
  +t:: ReleaseAllDrag()
  +y:: ReleaseAllDrag()
#If (POP_UP && DRAGGING == false)
  Escape:: ClosePopup()
#If (DRAGGING)
  *Escape:: ReleaseAllDrag()
#If

; FUTURE CONSIDERATIONS
; AwaitKey function for vimesque multi keystroke commands (gg, yy, 2M, etc)
; "Marks" for remembering and restoring mouse positions (needs AwaitKey)
; v to let go of mouse when mouse is down with v (lemme crop in Paint.exe)
; z for click and release middle mouse? this has historically not worked well
; c guess that leaves c for hold / release right mouse (x is useful in chronmium)
; Whatever you can think of! Github issues and pull requests welcome
