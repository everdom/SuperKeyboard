#InstallKeybdHook

; vim_mouse_2.ahk
; vim (and now also WASD!) bindings to control the mouse with the keyboard
; 
; Astrid Ivy
; 2019-04-14
;
; Last updated 2022-02-05

global INSERT_MODE := false
global INSERT_QUICK := false
global NORMAL_MODE := false
global NORMAL_QUICK := false
global NUMPAD := false
global WASD := true

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

; Insert Mode by default
EnterInsertMode()

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

  ;(humble beginnings)
  ;MsgBox, %NORMAL_MODE%
  ;msg1 := "h " . LEFT . " j  " . DOWN . " k " . UP . " l " . RIGHT
  ;MsgBox, %msg1%
  ;msg2 := "Moving " . VELOCITY_X . " " . VELOCITY_Y
  ;MsgBox, %msg2%
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
}

ClickInsert(quick:=true) {
  Click
  EnterInsertMode(quick)
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
  popx := right - 150*2
  popy := bottom - 28*2 - 50
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
  popx := right - 150*2
  popy := bottom - 28*2 - 50
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
    Send, {MButton down}
    DRAGGING := true
  }
}

; For Fusion360
ShiftMiddleDrag() {
  If (DRAGGING) {
    Click, Middle, Up
    DRAGGING := false
    SHIFT_DRAGGING := false
    Send, {Shift up}
    ClosePopup() 
  } else {
    ShowPopup("SHIFT MIDDLE DRAG")
    Send, {Shift down}
    Send, {MButton down}
    DRAGGING := true
    SHIFT_DRAGGING := true
  }
}

ReleaseDrag(button) {
  Send, {Shift up}
  Click, Middle, Up
  Click, button
  DRAGGING := false
  SHIFT_DRAGGING := false
  ClosePopup()
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
    Send, {Shift up}
  }
  Click
  DRAGGING := false
  SHIFT_DRAGGING := false
}

MouseRight() {
  if (SHIFT_DRAGGING){
    Send, {Shift up}
  }
  Click, Right
  DRAGGING := false
  SHIFT_DRAGGING := false
}

MouseMiddle() {
  if (SHIFT_DRAGGING){
    Send, {Shift up}
  }
  Click, Middle
  DRAGGING := false
  SHIFT_DRAGGING := false
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
; "FINAL" MODE SWITCH BINDINGS
Home:: EnterNormalMode()
Insert:: EnterInsertMode()
<#<!n:: EnterNormalMode()
<#<!i:: EnterInsertMode()
<#<!p:: EnterNumpadMode()

; escape hatches
+Home:: Send, {Home}
+Insert:: Send, {Insert}
;FIXME
; doesn't turn caplsock off.
; ^Capslock:: Send, {Capslock}
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
  +S:: DoubleClickInsert()
  ; passthru for Vimium hotlinks 
  ~f:: EnterInsertMode(true)
  ; passthru to common "search" hotkey
  ~^f:: EnterInsertMode(true)
  ; passthru for new tab
  ~^t:: EnterInsertMode(true)
  ; passthru for quick edits
  ~Delete:: EnterInsertMode(true)
  ; do not pass thru
  +;:: EnterInsertMode(true)
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
  x:: RightDrag()
  c:: MiddleDrag()
  ^c:: ShiftMiddleDrag()
  ^+C:: ShiftMiddleDrag()
  +M:: JumpMiddle()
  +,:: JumpMiddle2()
  +.:: JumpMiddle3()
  ; ahh what the heck, remove shift requirements for jump bindings
  ; maybe take "m" back if we ever make marks
  m:: JumpMiddle()
  ; ,:: JumpMiddle2()
  ; .:: JumpMiddle3()
  n:: MouseForward()
  b:: MouseBack()
  ; allow for modifier keys (or more importantly a lack of them) by lifting ctrl requirement for these hotkeys
  *]:: End
  *[:: Home
  `;:: ScrollDown()
  ':: ScrollUp()
  ; }:: ScrollDownMore()
  ; {:: ScrollUpMore()
  ::: ScrollDownMore()
  ":: ScrollUpMore()
  =:: SetVolume(+6)
  -:: SetVolume(-6)
  f12:: SetForce(+3, 1)
  f11:: SetForce(-3, 1)
  f10:: SetForce(10, 0)
  +=:: SetForce(+3, 1)
  +-:: SetForce(-3, 1)
  +0:: SetForce(10, 0)
  ,:: Min()
  .:: Max()
  /:: Close()
  !p:: Send {PrintScreen}
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
  g:: Home
  +g::End
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
#If (INSERT_MODE)
  ; Normal (Quick) Mode
#If (INSERT_MODE && INSERT_QUICK == false)
  Capslock:: EnterNormalMode(true)
  +Capslock:: EnterNormalMode()
#If (INSERT_MODE && NUMPAD)
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
  !=::Send {+}
  !-::Send {-}
  !8::Send {*}
  !/::Send {/}
  !Enter::Send {Enter}
#If (INSERT_MODE && INSERT_QUICK)
  ~Enter:: EnterNormalMode()
  ; Copy and return to Normal Mode
  ~^c:: EnterNormalMode()
  Escape:: EnterNormalMode()
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
  +C:: JumpMiddle()
  +W:: JumpTopEdge()
  +A:: JumpLeftEdge()
  +S:: JumpBottomEdge()
  +D:: JumpRightEdge()
  *e:: ScrollDown()
  *q:: ScrollUp()
  *r:: MouseLeft()
  t:: MouseRight()
  +T:: MouseRight()
  *y:: MouseMiddle()
#IF (DRAGGING)
  LButton:: ReleaseDrag(1)
  MButton:: ReleaseDrag(2)
  RButton:: ReleaseDrag(3)
  i:: ReleaseDrag(1)
  p:: ReleaseDrag(2)
  o:: ReleaseDrag(3)
#IF (SHIFT_DRAGGING)
  LButton:: ReleaseDrag(1)
  MButton:: ReleaseDrag(2)
  RButton:: ReleaseDrag(3)
  +i:: ReleaseDrag(1)
  +p:: ReleaseDrag(2)
  +o:: ReleaseDrag(3)
#If (POP_UP)
  Escape:: 
    ClosePopup()
    ReleaseDrag(1)
    ReleaseDrag(2)
    ReleaseDrag(3)
  +Escape:: 
    ClosePopup()
    ReleaseDrag(1)
    ReleaseDrag(2)
    ReleaseDrag(3)
#If

; FUTURE CONSIDERATIONS
; AwaitKey function for vimesque multi keystroke commands (gg, yy, 2M, etc)
; "Marks" for remembering and restoring mouse positions (needs AwaitKey)
; v to let go of mouse when mouse is down with v (lemme crop in Paint.exe)
; z for click and release middle mouse? this has historically not worked well
; c guess that leaves c for hold / release right mouse (x is useful in chronmium)
; Whatever you can think of! Github issues and pull requests welcome
