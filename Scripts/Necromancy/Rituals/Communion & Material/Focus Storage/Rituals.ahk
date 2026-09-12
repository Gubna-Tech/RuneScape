; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
SetBatchLines, -1

LLARS_SCRIPT_TYPE := "RunCount"

if !LLARS_FrameworkAvailable()
	LLARS_FrameworkError()

LLARS_Initialize()

return

Start:

if (!LLARS_StartRun())
	return

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

Loop, %runcount%
{
	LLARS_BeginLoop()

	if (firstrun = 0)
	{
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=" firstrun)

		IniRead, x1, Config.ini, Pedestal - Pedestal, xmin
		IniRead, x2, Config.ini, Pedestal - Pedestal, xmax
		IniRead, y1, Config.ini, Pedestal - Pedestal, ymin
		IniRead, y2, Config.ini, Pedestal - Pedestal, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("PEDESTAL - PEDESTAL", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Ritual Type, xmin
		IniRead, x2, Config.ini, Ritual Type, xmax
		IniRead, y1, Config.ini, Ritual Type, ymin
		IniRead, y2, Config.ini, Ritual Type, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("RITUAL TYPE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, option, Config.ini, Input, scroll
		StringLower, option, option

		If (option = "true")
		{
			IniRead, x1, Config.ini, Input, xmin
			IniRead, x2, Config.ini, Input, xmax
			IniRead, y1, Config.ini, Input, ymin
			IniRead, y2, Config.ini, Input, ymax
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			Random, Scroll, 5, 10
			MouseMove, %x%, %y%
			Log("INPUT MOVE", "X=" x " Y=" y " | Scroll count=" Scroll)

			IniRead, sa1, Config.ini, Sleep Brief, min
			IniRead, sa2, Config.ini, Sleep Brief, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP BRIEF WAIT", "Sleep completed: " SleepAmount " ms")

			Loop, % Scroll
			{
				Send, {WheelDown}
				Log("SCROLL STEP", "WheelDown | Step=" A_Index " of " Scroll)
			}

			IniRead, sa1, Config.ini, Sleep Brief, min
			IniRead, sa2, Config.ini, Sleep Brief, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP BRIEF WAIT", "Sleep completed: " SleepAmount " ms")
		}
		Else
		{
			Log("INPUT SCROLL", "Scroll option is disabled")
		}

		IniRead, x1, Config.ini, Input, xmin
		IniRead, x2, Config.ini, Input, xmax
		IniRead, y1, Config.ini, Input, ymin
		IniRead, y2, Config.ini, Input, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("INPUT", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

		Send, {Space}
		Log("SPACE", "Sent {Space}")

		IniRead, sa1, Config.ini, Sleep Normal, min
		IniRead, sa2, Config.ini, Sleep Normal, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP NORMAL WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Pedestal - Pedestal, xmin
		IniRead, x2, Config.ini, Pedestal - Pedestal, xmax
		IniRead, y1, Config.ini, Pedestal - Pedestal, ymin
		IniRead, y2, Config.ini, Pedestal - Pedestal, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")
		Log("PEDESTAL - PEDESTAL RIGHT CLICK", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, minx, Config.ini, Offset, minx
		IniRead, maxx, Config.ini, Offset, maxx
		IniRead, miny, Config.ini, Offset, miny
		IniRead, maxy, Config.ini, Offset, maxy
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)
		Log("PEDESTAL TARGET", "Origin X=" RightClickX " Y=" RightClickY " | Offset X=" XOffset " Y=" YOffset " | Target X=" TargetX " Y=" TargetY)

		IniRead, sa1, Config.ini, Sleep Repair, min
		IniRead, sa2, Config.ini, Sleep Repair, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP REPAIR WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Platform, xmin
		IniRead, x2, Config.ini, Platform, xmax
		IniRead, y1, Config.ini, Platform, ymin
		IniRead, y2, Config.ini, Platform, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("PLATFORM", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Walk, min
		IniRead, sa2, Config.ini, Sleep Walk, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP WALK WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, sa1, Config.ini, Sleep Ritual, min
		IniRead, sa2, Config.ini, Sleep Ritual, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP RITUAL WAIT", "Sleep completed: " SleepAmount " ms")
	}

	If (firstrun = 1)
	{
		++count
		++count2
		firstrun := 0

		IfWinNotActive, RuneScape
		{
			WinActivate, RuneScape
			Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
		}

		GuiControl,, Counter, %count%
		GuiControl,, Counter2, %count2% / %runcount3%
		GuiControl,, ScriptBlue, %scriptname%
		GuiControl,, State3, Running
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")

		IniRead, x1, Config.ini, Pedestal - Platform, xmin
		IniRead, x2, Config.ini, Pedestal - Platform, xmax
		IniRead, y1, Config.ini, Pedestal - Platform, ymin
		IniRead, y2, Config.ini, Pedestal - Platform, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")
		Log("PEDESTAL - PLATFORM RIGHT CLICK", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, minx, Config.ini, Offset, minx
		IniRead, maxx, Config.ini, Offset, maxx
		IniRead, miny, Config.ini, Offset, miny
		IniRead, maxy, Config.ini, Offset, maxy
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)
		Log("PEDESTAL PLATFORM TARGET", "Origin X=" RightClickX " Y=" RightClickY " | Offset X=" XOffset " Y=" YOffset " | Target X=" TargetX " Y=" TargetY)

		IniRead, sa1, Config.ini, Sleep Walk, min
		IniRead, sa2, Config.ini, Sleep Walk, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP WALK WAIT", "Sleep completed: " SleepAmount " ms")
	}

	If (firstrun = 0)
	{
		++firstrun
		Log("FIRSTRUN", "firstrun incremented to " firstrun)

		IniRead, option, %LLARS_CONFIG_FILE%, Random Sleep, option
		StringLower, option, option

		If (option = "true")
		{
			IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
			Random, RandomNumber, 1, 100

			If (RandomNumber <= chance)
			{
				++sleepcount

				IniRead, rs1, %LLARS_CONFIG_FILE%, Random Sleep, min
				IniRead, rs2, %LLARS_CONFIG_FILE%, Random Sleep, max
				Random, RandomSleepAmount, %rs1%, %rs2%
				GuiControl,, ScriptBlue, Random Sleep
				EndTime := A_TickCount + RandomSleepAmount
				totalSleepTime += RandomSleepAmount
				SetTimer, UpdateCountdown, 1000
				Log("RANDOM SLEEP", "Sleep=" RandomSleepAmount " ms | Chance=" chance "% | Roll=" RandomNumber)

				Sleep, %RandomSleepAmount%
				SetTimer, UpdateCountdown, Off
				GuiControl,, ScriptBlue, %scriptname%
				GuiControl,, State3, Running
				Log("RANDOM SLEEP COMPLETE", "Random sleep completed: " RandomSleepAmount " ms")
			}
			Else
			{
				Log("RANDOM SLEEP SKIPPED", "Chance=" chance "% | Roll=" RandomNumber)
			}
		}
		Else
		{
			Log("RANDOM SLEEP DISABLED", "Random Sleep option is disabled")
		}

		IniRead, x1, Config.ini, Platform, xmin
		IniRead, x2, Config.ini, Platform, xmax
		IniRead, y1, Config.ini, Platform, ymin
		IniRead, y2, Config.ini, Platform, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("PLATFORM", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Walk, min
		IniRead, sa2, Config.ini, Sleep Walk, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP WALK WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, sa1, Config.ini, Sleep Ritual, min
		IniRead, sa2, Config.ini, Sleep Ritual, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_FinalSleep(SleepAmount)
		Log("SLEEP RITUAL WAIT", "Sleep completed: " SleepAmount " ms")
	}
	LLARS_EndLoop()
}

; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

LLARS_RunComplete()

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
