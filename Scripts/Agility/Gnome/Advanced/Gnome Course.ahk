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

		IniRead, x1, Config.ini, Log balance prime, xmin
		IniRead, x2, Config.ini, Log balance prime, xmax
		IniRead, y1, Config.ini, Log balance prime, ymin
		IniRead, y2, Config.ini, Log balance prime, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LOG BALANCE PRIME", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Log balance prime, min
		IniRead, sa2, Config.ini, Log balance prime, max
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

		IniRead, x1, Config.ini, Log balance Main, xmin
		IniRead, x2, Config.ini, Log balance Main, xmax
		IniRead, y1, Config.ini, Log balance Main, ymin
		IniRead, y2, Config.ini, Log balance Main, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LOG BALANCE MAIN", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Log balance Main, min
		IniRead, sa2, Config.ini, Log balance Main, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LOG BALANCE MAIN WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 0)
	{
		++firstrun

		IniRead, x1, Config.ini, Obstacle net, xmin
		IniRead, x2, Config.ini, Obstacle net, xmax
		IniRead, y1, Config.ini, Obstacle net, ymin
		IniRead, y2, Config.ini, Obstacle net, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("OBSTACLE NET", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Obstacle net, min
		IniRead, sa2, Config.ini, Obstacle net, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("OBSTACLE NET WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Tree branch, xmin
		IniRead, x2, Config.ini, Tree branch, xmax
		IniRead, y1, Config.ini, Tree branch, ymin
		IniRead, y2, Config.ini, Tree branch, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("TREE BRANCH", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Tree branch, min
		IniRead, sa2, Config.ini, Tree branch, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("TREE BRANCH WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Tree, xmin
		IniRead, x2, Config.ini, Tree, xmax
		IniRead, y1, Config.ini, Tree, ymin
		IniRead, y2, Config.ini, Tree, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("TREE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Tree, min
		IniRead, sa2, Config.ini, Tree, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("TREE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Signpost, xmin
		IniRead, x2, Config.ini, Signpost, xmax
		IniRead, y1, Config.ini, Signpost, ymin
		IniRead, y2, Config.ini, Signpost, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("SIGNPOST", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Signpost, min
		IniRead, sa2, Config.ini, Signpost, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SIGNPOST WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Pole, xmin
		IniRead, x2, Config.ini, Pole, xmax
		IniRead, y1, Config.ini, Pole, ymin
		IniRead, y2, Config.ini, Pole, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("POLE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Pole, min
		IniRead, sa2, Config.ini, Pole, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("POLE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Tile, xmin
		IniRead, x2, Config.ini, Tile, xmax
		IniRead, y1, Config.ini, Tile, ymin
		IniRead, y2, Config.ini, Tile, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("TILE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Tile, min
		IniRead, sa2, Config.ini, Tile, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("TILE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Barrier, xmin
		IniRead, x2, Config.ini, Barrier, xmax
		IniRead, y1, Config.ini, Barrier, ymin
		IniRead, y2, Config.ini, Barrier, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BARRIER", "X=" x " Y=" y)

		IniRead, LLARS_RandomSleepOption, %LLARS_CONFIG_FILE%, Random Sleep, option
		StringLower, LLARS_RandomSleepOption, LLARS_RandomSleepOption
		LLARS_RandomSleepThisLoop := false
		if (LLARS_RandomSleepOption = "true")
		{
			IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
			Random, RandomNumber, 1, 100
			LLARS_RandomSleepThisLoop := (RandomNumber <= chance)
		}

		IniRead, sa1, Config.ini, Barrier, min
		IniRead, sa2, Config.ini, Barrier, max
		Random, SleepAmount, %sa1%, %sa2%
		if (LLARS_RandomSleepThisLoop)
			LLARS_EstimatedSleep(SleepAmount)
		else
			LLARS_FinalSleep(SleepAmount)
		Log("BARRIER WAIT", "Sleep completed: " SleepAmount " ms")

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
