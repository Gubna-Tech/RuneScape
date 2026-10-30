; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
SetBatchLines, -1

LLARS_SCRIPT_TYPE := "Timer"
LLARS_COMBO_TIMER_LABEL := "AntiAFKTimer"

if !LLARS_FrameworkAvailable()
	LLARS_FrameworkError()

LLARS_Initialize()

return

Start:

if (!LLARS_StartTimerRun())
	return

SetTimer, Countdown, 1000
SetTimer, AntiAFKStatusCountdown, Off

LLARS_DeveloperAntiAFKAction("ANTI-AFK", "Anti-AFK system started")
AntiAFKScheduleNext()

return

; =====================================================================
; |     TIMER COUNTDOWN     -     TIMER COUNTDOWN     -     TIMER     |
; =====================================================================

Countdown:
RemainingTime := endTime - A_TickCount

if (RemainingTime > 0)
{
	GuiControl,, TimerCount, % LLARS_TimerRemainingText(RemainingTime)
	return
}

GuiControl,, TimerCount, Done
GuiControl,, State3, Done
SetTimer, Countdown, Off

Goto, EndMsg

AntiAFKStatusCountdown:
AntiAFKShowNextAction()
return

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

AntiAFK()
{
    global AntiAFKTimerID

    if !LLARS_RunActive()
        return

    ; A one-shot timer owns only the idle interval. Do not start the next
    ; interval until this movement has completely finished.
    SetTimer, AntiAFKStatusCountdown, Off
    AntiAFKTimerID := 0
    LLARS_SetStatus("Moving Mouse", "Anti-AFK")
    moved := AntiAFKMoveOnce()

    if (moved)
        LLARS_DeveloperAntiAFKAction("ANTI-AFK", "Anti-AFK activation completed")

    if LLARS_RunActive()
        AntiAFKScheduleNext()
}

AntiAFKScheduleNext()
{
    global AntiAFKTimerID

    if !LLARS_RunActive()
        return 0

    AntiAFKTimerID := LLARS_TimerOnce("AFK", Func("AntiAFK"))
    if (AntiAFKTimerID)
    {
        AntiAFKShowNextAction()
        SetTimer, AntiAFKStatusCountdown, 250
    }
    return AntiAFKTimerID
}

AntiAFKShowNextAction()
{
    global AntiAFKTimerID

    if !LLARS_RunActive()
    {
        SetTimer, AntiAFKStatusCountdown, Off
        return
    }

    remaining := LLARS_CreatorTimerRemaining(AntiAFKTimerID)
    if (remaining < 0)
        return

    GuiControl, 1:, ScriptBlue, Anti-AFK
    GuiControl, 1:, State3, % "Next move in " . LLARS_TimerRemainingText(remaining)
}

AntiAFKMoveOnce()
{
    global LLARS_RunRuneScapeHwnd

    if !LLARS_WaitForRuneScape("Anti-AFK MouseMove")
        return false

    VarSetCapacity(clientRect, 16, 0)
    if !DllCall("GetClientRect", "Ptr", LLARS_RunRuneScapeHwnd, "Ptr", &clientRect)
        return false
    clientW := NumGet(clientRect, 8, "Int")
    clientH := NumGet(clientRect, 12, "Int")
    if (clientW <= 1 || clientH <= 1)
        return false

    if !AntiAFKChooseTarget(clientW, clientH, x, y)
        return false

    if !AntiAFKNaturalClick(x, y, "AntiAFKShortMove")
        return false

    LLARS_DeveloperAntiAFKAction("ANTI-AFK MOVE", "Mouse moved | X=" x " Y=" y)
    return true
}

AntiAFKChooseTarget(clientW, clientH, ByRef x, ByRef y)
{
    MouseGetPos, currentX, currentY
    margin := 12
    maxX := clientW - 1 - margin
    maxY := clientH - 1 - margin
    if (maxX <= margin || maxY <= margin)
        return false

    smallerDimension := (clientW < clientH) ? clientW : clientH
    maxDistance := Round(smallerDimension * 0.30)
    if (maxDistance > 300)
        maxDistance := 300
    if (maxDistance < 120)
        maxDistance := 120
    minDistance := Round(maxDistance * 0.35)
    if (minDistance < 55)
        minDistance := 55

    Loop, 16
    {
        Random, angleMilli, 0, 6283
        Random, moveDistance, %minDistance%, %maxDistance%
        angle := angleMilli / 1000.0
        candidateX := Round(currentX + (Cos(angle) * moveDistance))
        candidateY := Round(currentY + (Sin(angle) * moveDistance))

        if (candidateX < margin || candidateX > maxX || candidateY < margin || candidateY > maxY)
            continue

        dx := candidateX - currentX
        dy := candidateY - currentY
        actualDistance := Sqrt((dx * dx) + (dy * dy))
        if (actualDistance < minDistance)
            continue

        x := candidateX
        y := candidateY
        return true
    }

    ; If the cursor is close to an edge, move toward the client center but cap
    ; the fallback to the same short/medium distance envelope.
    centerX := clientW / 2
    centerY := clientH / 2
    dx := centerX - currentX
    dy := centerY - currentY
    centerDistance := Sqrt((dx * dx) + (dy * dy))
    if (centerDistance <= 2)
        return false
    scale := (centerDistance > maxDistance) ? (maxDistance / centerDistance) : 1
    x := Round(currentX + (dx * scale))
    y := Round(currentY + (dy * scale))
    if (x < margin)
        x := margin
    if (x > maxX)
        x := maxX
    if (y < margin)
        y := margin
    if (y > maxY)
        y := maxY
    return true
}

; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

; ======================================================================
; |     TIMER BUTTON     -     TIMER BUTTON     -     TIMER BUTTON     |
; ======================================================================
; Opens Anti-AFK's randomized idle-interval editor from the LLARS Combo menu.
AntiAFKTimer:

Gui 1: Hide
Gui Combo: Destroy
DisableHotkey()

sa1 := LLARS_ConfigRead("AFK", "min", "ERROR")
sa2 := LLARS_ConfigRead("AFK", "max", "ERROR")

Gui 5: +LastFound +AlwaysOnTop +OwnDialogs
LLARS_VisualPrepare("5")
Gui 5: Font, bold s12
Gui 5: Add, Text, x5 w210 center, Anti-AFK Timer Interval
Gui 5: Font, s10
Gui 5: Add, Text, x5 w210 center, timers are in ms`n60000ms = 1min
Gui 5: Add, Text,,
Gui 5: Font, s11
Gui 5: Add, Text, center x5 w210, Minimum AFK timer
Gui 5: Add, Edit, vMinEdit center x55 w100, % sa1
Gui 5: Add, Text,,
Gui 5: Add, Text, center x5 w210, Maximum AFK timer
Gui 5: Add, Edit, vMaxEdit center x55 w100, % sa2
Gui 5: Add, Text,,
Gui 5: Add, Button, Default gAntiAFKTimerSave x55 w100, Save Timer
Gui 5: +ToolWindow
Gui 5: -caption
Gui 5: Show, center w220, Timer
LLARS_VisualFinish("5")
return

AntiAFKTimerSave:
GuiControlGet, NewMin,, MinEdit
GuiControlGet, NewMax,, MaxEdit
NewMin := Trim(NewMin)
NewMax := Trim(NewMax)

if (NewMin = "" || NewMax = "")
{
	MsgBox, 48, Timer Error, Minimum and maximum timer values cannot be blank.
	return
}

if !RegExMatch(NewMin, "^\d+$") || !RegExMatch(NewMax, "^\d+$")
{
	MsgBox, 48, Timer Error, Minimum and maximum timer values must contain numbers only.
	return
}

if (NewMin > NewMax)
{
	MsgBox, 48, Timer Error, Minimum timer cannot be greater than maximum timer.
	return
}

LLARS_ConfigWrite("AFK", "min", NewMin)
LLARS_ConfigWrite("AFK", "max", NewMax)

Gui 5: Destroy
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center, ----Timer has been updated in the Config.ini file`n----
Gui 13u: +ToolWindow
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI
Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, cGreen
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, Timer has been updated in the Config.ini file
Gui 13: +ToolWindow
Gui 13: -caption
Gui 13: Show, NoActivate xcenter y9999, TopGUI
WinGetPos,,,,bottomH, BottomGUI
WinGetPos,,,,topH, TopGUI
topPOS := (bottomH - topH) / 2
Gui, TopGUI: +LabelTopGUI
WinMove, TopGUI,, , %topPOS%
Sleep, 1500
Gui 13u: Destroy
Gui 13: Destroy
Gui 1: Show
EnableHotkey()
return

EndMsg:

hours := timeToRunMinutes // 60
minutes := Mod(timeToRunMinutes, 60)
SetTimer, Countdown, Off
SetTimer, AntiAFKStatusCountdown, Off
LLARS_TimerStopAll()
LLARS_EndTimerRun()
Logout()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done


SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nTotal time: %hours%h %minutes%m
return

LLARS_FrameworkAvailable()
{
	dir := A_ScriptDir

	Loop, 12
	{
		if (FileExist(dir . "\Core\LLARS.ahk") && FileExist(dir . "\LLARS Config.ini"))
			return true

		SplitPath, dir,, parentDir

		if (parentDir = "" || parentDir = dir)
			break

		dir := parentDir
	}

	return false
}

LLARS_FrameworkError()
{
	Menu, Tray, NoIcon

	MsgBox, 4112, LLARS Error, The complete LLARS project could not be found.`n`nIf you opened this script from a ZIP, RAR, or 7Z archive, extract the entire LLARS folder before running it.

	ExitApp
}

; Automatically searches upward for the LLARS Core bootstrap.
#Include *i %A_ScriptDir%\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
