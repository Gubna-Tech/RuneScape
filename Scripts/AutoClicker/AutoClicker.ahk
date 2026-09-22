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
LLARS_COMBO_TIMER_LABEL := "AutoClickerTimer"

if !LLARS_FrameworkAvailable()
	LLARS_FrameworkError()

LLARS_Initialize()

return

Start:

if (!LLARS_StartTimerRun())
	return

SetTimer, Countdown, 1000

LastClickTime := 0
LLARS_SetStatus("Clicking", "Target")
LLARS_Click("Click")
LastClickTime := A_TickCount
AutoClickerTimerID := LLARS_TimerOnce("Timer", Func("RandomClick"))

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

    LLARS_SetStatus("Clicking", "Target")
    DisableButton()

    LLARS_Click("Click")

    if (LastClickTime = 0)
        TimeSinceClick := "N/A - first click"
    else
        TimeSinceClick := A_TickCount - LastClickTime " ms since previous click"
    LastClickTime := A_TickCount

    ; Match the old script: start the next randomized interval before the tooltip delay, rather than waiting until this callback fully returns.
    AutoClickerTimerID := LLARS_TimerOnce("Timer", Func("RandomClick"))

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated AutoClicker, (xm+15), (ym+15), 1
        Sleep, 25
    }
    ToolTip
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
; Opens AutoClicker's click-interval editor from the LLARS Combo menu.
AutoClickerTimer:

Gui 1: Hide
Gui Combo: Destroy
DisableHotkey()

IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max


Gui 5: +LastFound +AlwaysOnTop +OwnDialogs
Gui 5: Font, bold s12
Gui 5: Add, Text, x5 w190 center, Click Timer Interval
Gui 5: Font, s10
Gui 5: Add, Text, x5 w190 center, timers are in ms`n1000ms = 1sec
Gui 5: Add, Text,,
Gui 5: Font, s11
Gui 5: Add, Text, center x5 w190, Minimum click timer
Gui 5: Add, Edit, vMinEdit center x50 w100, % sa1
Gui 5: Add, Text,,
Gui 5: Add, Text, center x5 w190, Maximum click timer
Gui 5: Add, Edit, vMaxEdit center x50 w100, % sa2
Gui 5: Add, Text,,
Gui 5: Add, Button, Default gAutoClickerTimerSave x50 w100, Save Timer
Gui 5: +ToolWindow
Gui 5: -caption
Gui 5: Show, center w200, Timer
return

; Validates and saves AutoClicker's minimum and maximum click intervals.
AutoClickerTimerSave:
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

IniWrite, %NewMin%, Config.ini, Timer, min
IniWrite, %NewMax%, Config.ini, Timer, max


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
