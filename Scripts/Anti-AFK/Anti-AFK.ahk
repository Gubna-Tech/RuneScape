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

    nextText := "Next move in " . LLARS_TimerRemainingText(remaining)
    GuiControlGet, shownActivity, 1:, ScriptBlue
    if (shownActivity != "Anti-AFK")
        GuiControl, 1:, ScriptBlue, Anti-AFK
    GuiControlGet, shownStatus, 1:, State3
    if (shownStatus != nextText)
        GuiControl, 1:, State3, %nextText%
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

; Timer ranges are now edited by the shared Setup > Timer interface.

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
