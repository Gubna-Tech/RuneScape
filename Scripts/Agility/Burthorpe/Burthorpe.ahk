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
		GuiControl,, ScriptBlue, %scriptname%
		GuiControl,, State3, Running
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=0")

		IniRead, x1, Config.ini, Log Beam Prime, xmin
		IniRead, x2, Config.ini, Log Beam Prime, xmax
		IniRead, y1, Config.ini, Log Beam Prime, ymin
		IniRead, y2, Config.ini, Log Beam Prime, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LOG BEAM PRIME", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Log Beam Prime, min
		IniRead, sa2, Config.ini, Log Beam Prime, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LOG BEAM PRIME WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 1)
	{
		firstrun := 0
		GuiControl,, ScriptBlue, %scriptname%
		GuiControl,, State3, Running
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")

		IniRead, x1, Config.ini, Log Beam Main, xmin
		IniRead, x2, Config.ini, Log Beam Main, xmax
		IniRead, y1, Config.ini, Log Beam Main, ymin
		IniRead, y2, Config.ini, Log Beam Main, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LOG BEAM MAIN", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Log Beam Main, min
		IniRead, sa2, Config.ini, Log Beam Main, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LOG BEAM MAIN WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 0)
	{
		++firstrun

		IniRead, x1, Config.ini, Wall, xmin
		IniRead, x2, Config.ini, Wall, xmax
		IniRead, y1, Config.ini, Wall, ymin
		IniRead, y2, Config.ini, Wall, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("WALL", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Wall, min
		IniRead, sa2, Config.ini, Wall, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("WALL WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Balancing Ledge, xmin
		IniRead, x2, Config.ini, Balancing Ledge, xmax
		IniRead, y1, Config.ini, Balancing Ledge, ymin
		IniRead, y2, Config.ini, Balancing Ledge, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BALANCING LEDGE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Balancing Ledge, min
		IniRead, sa2, Config.ini, Balancing Ledge, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("BALANCING LEDGE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Obstacle low wall, xmin
		IniRead, x2, Config.ini, Obstacle low wall, xmax
		IniRead, y1, Config.ini, Obstacle low wall, ymin
		IniRead, y2, Config.ini, Obstacle low wall, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("OBSTACLE LOW WALL", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Obstacle low wall, min
		IniRead, sa2, Config.ini, Obstacle low wall, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("OBSTACLE LOW WALL WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Rope swing, xmin
		IniRead, x2, Config.ini, Rope swing, xmax
		IniRead, y1, Config.ini, Rope swing, ymin
		IniRead, y2, Config.ini, Rope swing, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("ROPE SWING", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Rope swing, min
		IniRead, sa2, Config.ini, Rope swing, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("ROPE SWING WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Monkey bars, xmin
		IniRead, x2, Config.ini, Monkey bars, xmax
		IniRead, y1, Config.ini, Monkey bars, ymin
		IniRead, y2, Config.ini, Monkey bars, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("MONKEY BARS", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Monkey bars, min
		IniRead, sa2, Config.ini, Monkey bars, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("MONKEY BARS WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Ledge, xmin
		IniRead, x2, Config.ini, Ledge, xmax
		IniRead, y1, Config.ini, Ledge, ymin
		IniRead, y2, Config.ini, Ledge, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LEDGE", "X=" x " Y=" y)

		IniRead, LLARS_RandomSleepOption, %LLARS_CONFIG_FILE%, Random Sleep, option
		StringLower, LLARS_RandomSleepOption, LLARS_RandomSleepOption
		LLARS_RandomSleepThisLoop := false
		if (LLARS_RandomSleepOption = "true")
		{
			IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
			Random, RandomNumber, 1, 100
			LLARS_RandomSleepThisLoop := (RandomNumber <= chance)
		}

		IniRead, sa1, Config.ini, Ledge, min
		IniRead, sa2, Config.ini, Ledge, max
		Random, SleepAmount, %sa1%, %sa2%
		if (LLARS_RandomSleepThisLoop)
			LLARS_EstimatedSleep(SleepAmount)
		else
			LLARS_FinalSleep(SleepAmount)
		Log("LEDGE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, option, %LLARS_CONFIG_FILE%, Random Sleep, option
		StringLower, option, option

		if (LLARS_RandomSleepThisLoop)
		{
			IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance

			if (RandomNumber <= chance)
			{
				++sleepcount

				IniRead, rs1, %LLARS_CONFIG_FILE%, Random Sleep, min
				IniRead, rs2, %LLARS_CONFIG_FILE%, Random Sleep, max

				; Generate the actual random sleep duration BEFORE
				; starting the countdown.
				Random, RandomSleepAmount, %rs1%, %rs2%
				GuiControl,, ScriptBlue, Random Sleep
				EndTime := A_TickCount + RandomSleepAmount
				totalSleepTime += RandomSleepAmount
				SetTimer, UpdateCountdown, 1000
				Log("RANDOM SLEEP", "Sleep=" RandomSleepAmount " ms | Chance=" chance "% | Roll=" RandomNumber)

				LLARS_FinalSleep(RandomSleepAmount)
				SetTimer, UpdateCountdown, Off
				GuiControl,, ScriptBlue, %scriptname%
				GuiControl,, State3, Running
				Log("RANDOM SLEEP COMPLETE", "Random sleep completed: " RandomSleepAmount " ms")
			}
			else
			{
				Log("RANDOM SLEEP SKIPPED", "Chance=" chance "% | Roll=" RandomNumber)
			}
		}
		else
		{
			Log("RANDOM SLEEP DISABLED", "Random Sleep option is disabled")
		}
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
