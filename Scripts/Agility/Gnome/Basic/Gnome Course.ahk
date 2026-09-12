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

		IniRead, x1, Config.ini, Log Balance Prime, xmin
		IniRead, x2, Config.ini, Log Balance Prime, xmax
		IniRead, y1, Config.ini, Log Balance Prime, ymin
		IniRead, y2, Config.ini, Log Balance Prime, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LOG BALANCE PRIME", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Log, min
		IniRead, sa2, Config.ini, Sleep Log, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LOG BALANCE PRIME WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 1)
	{
		firstrun := 0
		GuiControl,, ScriptBlue, %scriptname%
		GuiControl,, State3, Running
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("BRIEF WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Log Balance Main, xmin
		IniRead, x2, Config.ini, Log Balance Main, xmax
		IniRead, y1, Config.ini, Log Balance Main, ymin
		IniRead, y2, Config.ini, Log Balance Main, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LOG BALANCE MAIN", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Loop, min
		IniRead, sa2, Config.ini, Sleep Loop, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LOG BALANCE MAIN WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 0)
	{
		++firstrun

		IniRead, x1, Config.ini, Obstacle Net 1, xmin
		IniRead, x2, Config.ini, Obstacle Net 1, xmax
		IniRead, y1, Config.ini, Obstacle Net 1, ymin
		IniRead, y2, Config.ini, Obstacle Net 1, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("OBSTACLE NET 1", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Net 1, min
		IniRead, sa2, Config.ini, Sleep Net 1, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("OBSTACLE NET 1 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Tree Branch 1, xmin
		IniRead, x2, Config.ini, Tree Branch 1, xmax
		IniRead, y1, Config.ini, Tree Branch 1, ymin
		IniRead, y2, Config.ini, Tree Branch 1, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("TREE BRANCH 1", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Normal, min
		IniRead, sa2, Config.ini, Sleep Normal, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("TREE BRANCH 1 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Balance Rope, xmin
		IniRead, x2, Config.ini, Balance Rope, xmax
		IniRead, y1, Config.ini, Balance Rope, ymin
		IniRead, y2, Config.ini, Balance Rope, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BALANCE ROPE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Rope, min
		IniRead, sa2, Config.ini, Sleep Rope, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("BALANCE ROPE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Tree Branch 2, xmin
		IniRead, x2, Config.ini, Tree Branch 2, xmax
		IniRead, y1, Config.ini, Tree Branch 2, ymin
		IniRead, y2, Config.ini, Tree Branch 2, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("TREE BRANCH 2", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Action, min
		IniRead, sa2, Config.ini, Sleep Action, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("TREE BRANCH 2 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Obstacle Net 2, xmin
		IniRead, x2, Config.ini, Obstacle Net 2, xmax
		IniRead, y1, Config.ini, Obstacle Net 2, ymin
		IniRead, y2, Config.ini, Obstacle Net 2, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("OBSTACLE NET 2", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Net 2, min
		IniRead, sa2, Config.ini, Sleep Net 2, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("OBSTACLE NET 2 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Obstacle Pipe, xmin
		IniRead, x2, Config.ini, Obstacle Pipe, xmax
		IniRead, y1, Config.ini, Obstacle Pipe, ymin
		IniRead, y2, Config.ini, Obstacle Pipe, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("OBSTACLE PIPE", "X=" x " Y=" y)

		IniRead, LLARS_RandomSleepOption, %LLARS_CONFIG_FILE%, Random Sleep, option
		StringLower, LLARS_RandomSleepOption, LLARS_RandomSleepOption
		LLARS_RandomSleepThisLoop := false
		if (LLARS_RandomSleepOption = "true")
		{
			IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
			Random, RandomNumber, 1, 100
			LLARS_RandomSleepThisLoop := (RandomNumber <= chance)
		}

		IniRead, sa1, Config.ini, Sleep Pipe, min
		IniRead, sa2, Config.ini, Sleep Pipe, max
		Random, SleepAmount, %sa1%, %sa2%
		if (LLARS_RandomSleepThisLoop)
			LLARS_EstimatedSleep(SleepAmount)
		else
			LLARS_FinalSleep(SleepAmount)
		Log("OBSTACLE PIPE WAIT", "Sleep completed: " SleepAmount " ms")

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
