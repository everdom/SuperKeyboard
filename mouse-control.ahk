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
#Warn All, OutputDebug
#SingleInstance Force
; --------------------------------------------------------------------------------
DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
; DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
; --------------------------------------------------------------------------------
global DPI_Ratio := A_ScreenDPI/96
global A_ScreenWidth_DPI := A_ScreenWidth / DPI_Ratio
global A_ScreenHeight_DPI :=A_ScreenHeight / DPI_Ratio

; #Include Gdip_All.ahk

global INSERT_MODE := false
global INSERT_QUICK := false
global INSERT_AUTO_QUICK:=true
global NORMAL_MODE := false
global NORMAL_QUICK := false
global NUMPAD := false
global SMALL_MODE := false
global WASD := true
global FAST_MODE:=false

; Drag takes care of this now
;global MAX_VELOCITY := 72

; mouse speed variables
global FORCE := 10
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

global CHROME_VIM_MODE :=true

global IS_EDIT := false
; 这里加个判断，检测一下初始化是否成功，失败就弹窗告知，并退出程序。
; If !pToken := Gdip_Startup()
; {
; 	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
; 	ExitApp
; }

; Insert Mode by default
EnterInsertMode()

DPI_v(v){
  Return v*DPI_Ratio
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
    CTRL := GetKeyState("Ctrl", "P")
    if(CTRL){
      return
    }
  }

  if(CHROME_VIM_MODE){
    ; chrome enter vim mode
    if(WinActive("ahk_class Chrome_WidgetWin_1")){
      WASD := false
    }else{
      WASD := true
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

EnterNormalMode(quick:=false) {
  ;MsgBox, "Welcome to Normal Mode"
  NORMAL_QUICK := quick


  msg := "NORMAL"
  If (WASD == false) {
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
  msg := "NORMAL"
  If (quick) {
    msg := msg . " (QUICK)"
  }
  ShowModePopup(msg)
  WASD := true
  EnterNormalMode(quick)
}

ExitWASDMode() {
  ShowModePopup("NORMAL (VIM)")
  WASD := false
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

EnterFastMode(){
  msg := "FAST"
  ShowModePopup(msg)

  If (FAST_MODE) {
    Return
  }
  FAST_MODE := true
  NORMAL_MODE := false
  NORMAL_QUICK := false
  INSERT_MODE := false
  INSERT_QUICK := false
  SetTimer FastModeHints, -10
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
  centerx := MonitorLeftEdge() + (A_ScreenWidth // 2)
  centery := A_ScreenHeight // 2
  right := MonitorLeftEdge() + A_ScreenWidth
  bottom := A_ScreenHeight
  popx := right - DPI_v(150*2)
  popy := bottom - DPI_v(28*2) - DPI_v(50)
  Progress, b x%popx% y%popy% zh0 w300 h56 fm24,, %msg%,,SimSun
  POP_UP := true
}

ShowModePopup(msg) {
  ; clean up any lingering popups
  ClosePopup()
  centerx := MonitorLeftEdge() + (A_ScreenWidth // 2)
  centery := A_ScreenHeight // 2
  right := MonitorLeftEdge() + A_ScreenWidth
  bottom := A_ScreenHeight
  popx := right - DPI_v(150*2)
  popy := bottom - DPI_v(28*2) - DPI_v(50)
  Progress, b x%popx% y%popy% zh0 w300 h56 fm24,, %msg%,,SimSun
  SetTimer, ClosePopup, -1600
  POP_UP := true
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
  center := wx + width - 180-24
  y := wy + 12
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
  Drag()
}

Close(){
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx + width - 24
  y := wy + 12
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
}

Min(){
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx + width - 24-48*2
  y := wy + 12
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
}

Max(){
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx + width - 24 -48
  y := wy + 12
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
}

Back(){
  wx := 0
  wy := 0
  width := 0
  WinGetPos,wx,wy,width,,A
  center := wx +24
  y := wy + 12
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
}

Resize(){
  wx := 0
  wy := 0
  width := 0
  height := 0
  WinGetPos,wx,wy,width,height,A
  center := wx + width - 6 
  y := wy + height - 6
  ;MsgBox, Hello %width% %center%
  MouseMove, center, y
  Drag()
}

MouseLeft() {
  if (SHIFT_DRAGGING){
    Send {Shift up}
  }
  if (CTRL_DRAGGING){
    Send {Ctrl up}
  }

  Click
  DRAGGING := false
  SHIFT_DRAGGING := false
  CTRL_DRAGGING := false

  if(INSERT_AUTO_QUICK && NORMAL_QUICK ==false && IS_EDIT && NORMAL_MODE)
  {  
    EnterInsertMode(true)
  }
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

; TODO: When we have more monitors, set up H and L to use current screen as basis
; hard to test when I only have the one

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

SetForce(v, relative){
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
    ShowPopup("SMALL MODE ON")
  }else{
    ShowPopup("SMALL MODE OFF")
  }
}

; Gui, 1:+LastFound +AlwaysOnTop +ToolWindow
; Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
; Gui, 1:Show, NA
; Gui, 1:Maximize
; GuiHwnd := WinExist() ; capture window handle
; Gui, 1:Hide

global hDc:=0
global hCurrPen:=0
global fastModeCache := false
global alphaTable:=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

FastModeLabel(show:=true){
  if(show){
    Gui Color, White
    Gui -caption +toolwindow +AlwaysOnTop
    Gui font,% "s" FAST_MODE_FONT_SIZE, Arial
    ; add cache to show quickly
    if(fastModeCache == true){
      Gui Show, % "x" 0 " y" 0 " w"A_ScreenWidth_DPI " h"A_ScreenHeight_DPI, TRANS-WIN
      WinSet TransColor, White, TRANS-WIN
      return
    }
    i:=0
    Loop,%FAST_MODE_Y%{
      j:=0
      Loop, %FAST_MODE_X%{
        k:=i*FAST_MODE_X+j
        alpha1 :=alphaTable[k//26+1]
        alpha2 :=alphaTable[Mod(k, 26)+1]
        label:= alpha1 alpha2
        
        Gui add, text,% "c" FAST_MODE_FONT_COLOR  " TransColor " "X" A_ScreenWidth_DPI/FAST_MODE_X*j+1 " Y" A_ScreenHeight_DPI/FAST_MODE_Y*i+1 " W"A_ScreenWidth_DPI/FAST_MODE_X-2 " H"A_ScreenHeight_DPI/FAST_MODE_Y-2, %label% 
        j+=1
      }
      i+=1
    }

    i:=1
    ly:=FAST_MODE_Y-1
    lx:=FAST_MODE_X-1
    Loop, %ly%{
      gui, add, text, % "x0" " y" A_ScreenHeight_DPI/FAST_MODE_Y*i " w" A_ScreenWidth_DPI " 0x10"  ;Horizontal Line > Etched Gray
      i+=1
    }

    j:=1
    Loop, %lx%{
      gui, add, text, % "x" A_ScreenWidth_DPI/FAST_MODE_X*j " y0" " h" A_ScreenHeight_DPI " 0x11"  ;Horizontal Line >% Etched Gray
      j+=1
    }
    firstRun := true
    Gui Show, % "x" 0 " y" 0 " w"A_ScreenWidth_DPI " h"A_ScreenHeight_DPI, TRANS-WIN
    WinSet TransColor, White, TRANS-WIN
  }else{
    Gui Hide
  }
}
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

    Input, UserInput, B L2, {enter}.{esc}, %matches%

    if (ErrorLevel = "Max")
    {
        ; MsgBox, You entered "%UserInput%", which is the maximum length of text.
        ; Gui, 1:Hide
        FastModeLabel(false)
        EnterNormalMode()
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
        EnterNormalMode()
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
          if (UserInput = label)
            MouseMove, A_ScreenWidth/(FAST_MODE_X*2)*(j*2+1), A_ScreenHeight/(FAST_MODE_Y*2)*(i*2+1)
          j+=1
        }
        i+=1
      }
      FastModeLabel(false)
      EnterNormalMode()
      return
    }
    if (ErrorLevel = "NewInput"){
      ; MsgBox, You entered "%UserInput%" and terminated the input with %ErrorLevel%.
      ; Gui, 1:Hide
      FastModeLabel(false)
      EnterNormalMode()
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
  ; f:: EnterFastMode()
  ; passthru for new tab
 ; ~^t:: EnterInsertMode(true)
  ; passthru for quick edits
  ~Delete:: EnterInsertMode(true)
  ; do not pass thru
  ; +;:: EnterInsertMode(true)
  ; intercept movement keys
  h:: Return
  j:: Return
  k:: Return
  l:: Return
  +H:: JumpLeftEdge()
  +J:: JumpBottomEdge()
  +K:: JumpTopEdge()
  +L:: JumpRightEdge()
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
  +M:: JumpMiddle()
  +,:: JumpMiddle2()
  +.:: JumpMiddle3()
  ; ahh what the heck, remove shift requirements for jump bindings
  ; maybe take "m" back if we ever make marks
  m:: JumpWindowMiddle()
  ; ,:: JumpMiddle2()
  ; .:: JumpMiddle3()
  n:: MouseForward()
  b:: MouseBack()
  ; allow for modifier keys (or more importantly a lack of them) by lifting ctrl requirement for these hotkeys
  *]:: End
  *[:: Home
  *`;:: ScrollDown()
  *':: ScrollUp()
  #`;:: ScrollDownMore()
  #':: ScrollUpMore()
  ::: ScrollDown()
  ":: ScrollUp()
  =:: Send {Volume_Up}
  -:: Send {Volume_Down}
  0:: Send {Volume_Mute}
  f12:: SetForce(+3, 1)
  f11:: SetForce(-3, 1)
  f10:: SetForce(10, 0)
  +=:: SetForce(+3, 1)
  +-:: SetForce(-3, 1)
  +0:: SetForce(10, 0)
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
  ::gg:: Send {Home}
  +g::Send {End}
; No shift requirements in normal quick mode
#If (NORMAL_MODE && NORMAL_QUICK)
  Capslock:: Return
  m:: JumpMiddle()
  ,:: JumpMiddle2()
  .:: JumpMiddle3()
  y:: Yank()
  ; x:: Close()
  z:: Resize()
  ; for windows explorer

#If (WinActive("ahk_class CabinetWClass"))
  !h:: Send {Left}
  !j:: Send {Down}
  !k:: Send {Up}
  !l:: Send {Right}
  !u:: Send !{Up}
  !i:: Send {Enter}
  !b:: MouseBack()
  !n:: MouseForward()
  ^o:: Send {AppsKey}
  ^h:: Send {Left}
  ^j:: Send {Down}
  ^k:: Send {Up}
  ^l:: Send {Right}
  !x:: Send ^{w}
#If (NORMAL_MODE && WinActive("ahk_class CabinetWClass")==false)
  !i:: DoubleClick()
#If (NORMAL_MODE && (WinActive("ahk_class CabinetWClass") || WinActive("ahk_class Chrome_WidgetWin_1") || WinActive("ahk_class Notepad") || WinActive("ahk_class Notepad++")))
  x:: Send ^{w}
; windows terminal
#If (NORMAL_MODE && (WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")))
  x:: Send ^+{w}
#If ((WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")))
  ^t:: Send ^+{t}
#If ((WinActive("ahk_class ahk_class Notepad++")))
  ^t:: Send ^{n}
#If (NORMAL_MODE && WinActive("ahk_class Chrome_WidgetWin_1")==false)
  x:: RightDrag()
  f:: EnterFastMode()
#If (NORMAL_MODE && WinActive("ahk_class Chrome_WidgetWin_1"))
  ~f:: EnterInsertMode(true)
  ~t:: EnterInsertMode(true)
  ~g:: EnterInsertMode(true)
#If (INSERT_MODE && WinActive("ahk_class Chrome_WidgetWin_1"))
  !x:: Send ^{w}
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
  1::f1
  2::f2
  3::f3
  4::f4
  5::f5
  6::f6
  7::f7
  8::f8
  9::f9
  0::f10
  -::f11
  =::f12
  +1::!
  +2::@
  +3::#
  +4::$
  +5::Send {`%}
  +6::^
  +7::&
  +8::*
  +9::(
  +0::)
  +-::-
  +=::=
  !1::1
  !2::2
  !3::3
  !4::4
  !5::5
  !6::6
  !7::7
  !8::8
  !9::9
  !0::0
  ^1::1
  ^2::2
  ^3::3
  ^4::4
  ^5::5
  ^6::6
  ^7::7
  ^8::8
  ^9::9
  ^0::0
  ^-::-
  ^=::=
  #1::1
  #2::2
  #3::3
  #4::4
  #5::5
  #6::6
  #7::7
  #8::8
  #9::9
  #0::0
  #-::-
  #=::=
  +`::
  `::Esc
  ^`::Send {``}

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
  ~Enter:: EnterNormalMode()
  ; Copy and return to Normal Mode
  ; ~^c:: EnterNormalMode()
  ~Escape:: EnterNormalMode()
  Capslock:: EnterNormalMode()
  +Capslock:: EnterNormalMode()
#If (NORMAL_MODE && WASD)
  <#<!v:: ExitWASDMode()
  ; Intercept movement keys
  w:: Return
  a:: Return
  s:: Return
  d:: Return
  u:: Return
  z:: JumpMiddle()
  +W:: JumpTopEdge()
  +A:: JumpLeftEdge()
  +S:: JumpBottomEdge()
  +D:: JumpRightEdge()
  e:: ScrollDown()
  q:: ScrollUp()
  +e:: ScrollDownMore()
  +q:: ScrollUpMore()
  *r:: MouseLeft()
  t:: MouseRight()
  +T:: MouseRight()
  *y:: MouseMiddle()

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
#IF (CTRL_DRAGGING && WASD)
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
