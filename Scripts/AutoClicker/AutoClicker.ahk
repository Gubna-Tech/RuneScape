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
SetTimer, AutoClickerStatusCountdown, Off

LastClickTime := 0
LLARS_SetStatus("Clicking", "Target")
LLARS_Click("Click")
LastClickTime := A_TickCount
AutoClickerTimerID := LLARS_TimerOnce("Timer", Func("RandomClick"))
AutoClickerShowNextAction()
SetTimer, AutoClickerStatusCountdown, 250

Loop, 100
{
	MouseGetPos, xm, ym
	ToolTip, Activated AutoClicker, (xm+15), (ym+15), 1
	Sleep, 25
}
ToolTip
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

AutoClickerStatusCountdown:
AutoClickerShowNextAction()
return

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

RandomClick()
{
    global LastClickTime, AutoClickerTimerID, scriptname

    if !LLARS_RunActive()
        return

    SetTimer, AutoClickerStatusCountdown, Off
    LLARS_SetStatus("Clicking", "Target")
    DisableButton()

    LLARS_Click("Click")

    if (LastClickTime = 0)
        TimeSinceClick := "N/A - first click"
    else
        TimeSinceClick := A_TickCount - LastClickTime " ms since previous click"
    LastClickTime := A_TickCount

    ; Start the next randomized interval before the tooltip delay so callback time does not extend the configured interval.
    AutoClickerTimerID := LLARS_TimerOnce("Timer", Func("RandomClick"))
    AutoClickerShowNextAction()
    SetTimer, AutoClickerStatusCountdown, 250

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated AutoClicker, (xm+15), (ym+15), 1
        Sleep, 25
    }
    ToolTip
}

AutoClickerShowNextAction()
{
    global AutoClickerTimerID

    if !LLARS_RunActive()
    {
        SetTimer, AutoClickerStatusCountdown, Off
        return
    }

    remaining := LLARS_CreatorTimerRemaining(AutoClickerTimerID)
    if (remaining < 0)
        return

    nextText := "Next click in " . LLARS_TimerRemainingText(remaining)
    GuiControlGet, shownActivity, 1:, ScriptBlue
    if (shownActivity != "AutoClicker")
        GuiControl, 1:, ScriptBlue, AutoClicker
    GuiControlGet, shownStatus, 1:, State3
    if (shownStatus != nextText)
        GuiControl, 1:, State3, %nextText%
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
SetTimer, AutoClickerStatusCountdown, Off
LLARS_TimerStopAll()
ToolTip
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
