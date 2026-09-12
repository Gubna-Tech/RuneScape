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

IfWinNotActive, RuneScape
{
	WinActivate, RuneScape
}

LastClickTime := 0

Log("AUTOCLICKER", "Random click routine started")

IniRead, x1, Config.ini, Click, xmin
IniRead, x2, Config.ini, Click, xmax
IniRead, y1, Config.ini, Click, ymin
IniRead, y2, Config.ini, Click, ymax
Random, x, %x1%, %x2%
Random, y, %y1%, %y2%

NaturalClick(x, y)

LastClickTime := A_TickCount

Log("CLICK", "Click Location X=" x " Y=" y " | N/A - first click")

IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max
Random, SleepClick, %sa1%, %sa2%
SetTimer, RandomClick, %SleepClick%

Log("WAIT", "Random sleep before click: " SleepClick " ms")

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

Log("TIMER COMPLETE", "Timed run reached zero")
Goto, EndMsg

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

RandomClick:
if (!LLARS_RUNNING)
	return

GuiControl,, ScriptBlue, %scriptname%
GuiControl,, State3, Running

IfWinNotActive, RuneScape
{
	WinActivate, RuneScape
}

DisableButton()

IniRead, x1, Config.ini, Click, xmin
IniRead, x2, Config.ini, Click, xmax
IniRead, y1, Config.ini, Click, ymin
IniRead, y2, Config.ini, Click, ymax
Random, x, %x1%, %x2%
Random, y, %y1%, %y2%

NaturalClick(x, y)

if (LastClickTime = 0)
{
	TimeSinceClick := "N/A - first click"
}
else
{
	TimeSinceClick := A_TickCount - LastClickTime " ms since previous click"
}

LastClickTime := A_TickCount

Log("CLICK", "Click Location X=" x " Y=" y " | " TimeSinceClick)

IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max
Random, SleepClick, %sa1%, %sa2%
SetTimer, RandomClick, %SleepClick%

Log("WAIT", "Random sleep before click: " SleepClick " ms")

Loop, 100
{
	MouseGetPos, xm, ym
	ToolTip, Activated AutoClicker, (xm+15), (ym+15), 1
	Sleep, 25
}
ToolTip
return

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
Log("TIMER CONFIG", "Opening Timer configuration editor")

Gui 1: Hide
Gui Combo: Destroy
DisableHotkey()

IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max

Log("TIMER CONFIG", "Current values loaded - Min=" sa1 "ms, Max=" sa2 "ms")

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
WinSet, ExStyle, ^0x80
Gui 5: -caption
Gui 5: Show, center w200, Timer
return

; Validates and saves AutoClicker's minimum and maximum click intervals.
AutoClickerTimerSave:
GuiControlGet, NewMin,, MinEdit
GuiControlGet, NewMax,, MaxEdit
NewMin := Trim(NewMin)
NewMax := Trim(NewMax)

Log("TIMER CONFIG", "Save requested - Min=" NewMin "ms, Max=" NewMax "ms")

if (NewMin = "" || NewMax = "")
{
	Log("CONFIG ERROR", "Timer save failed - minimum or maximum timer is blank")
	MsgBox, 48, Timer Error, Minimum and maximum timer values cannot be blank.
	return
}

if !RegExMatch(NewMin, "^\d+$") || !RegExMatch(NewMax, "^\d+$")
{
	Log("CONFIG ERROR", "Timer save failed - minimum or maximum timer is not numeric")
	MsgBox, 48, Timer Error, Minimum and maximum timer values must contain numbers only.
	return
}

if (NewMin > NewMax)
{
	Log("CONFIG ERROR", "Timer save failed - minimum timer is greater than maximum timer")
	MsgBox, 48, Timer Error, Minimum timer cannot be greater than maximum timer.
	return
}

IniWrite, %NewMin%, Config.ini, Timer, min
IniWrite, %NewMax%, Config.ini, Timer, max

Log("TIMER CONFIG", "Timer values written to Config.ini - Min=" NewMin "ms, Max=" NewMax "ms")

Gui 5: Destroy
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center, ----Timer has been updated in the Config.ini file`n----
WinSet, ExStyle, ^0x80
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI
Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, cGreen
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, Timer has been updated in the Config.ini file
WinSet, ExStyle, ^0x80
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

Log("TIMER CONFIG", "Timer configuration update completed")
return

EndMsg:

hours := timeToRunMinutes // 60
minutes := Mod(timeToRunMinutes, 60)
SetTimer, Countdown, Off
SetTimer, RandomClick, Off
ToolTip
LLARS_EndTimerRun()
Logout()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done

Log("COMPLETE", "Script completed normally | Total time: " hours "h " minutes "m")

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

; Automatically searches upward for the LLARS Core folder.
#Include *i %A_ScriptDir%\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk

; Automatically searches upward for the LLARS label library.
#Include *i %A_ScriptDir%\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
