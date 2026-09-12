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

		IniRead, x1, Config.ini, Fallen Palm Tree prime, xmin
		IniRead, x2, Config.ini, Fallen Palm Tree prime, xmax
		IniRead, y1, Config.ini, Fallen Palm Tree prime, ymin
		IniRead, y2, Config.ini, Fallen Palm Tree prime, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("FALLEN PALM TREE PRIME", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Fallen Palm Tree prime, min
		IniRead, sa2, Config.ini, Fallen Palm Tree prime, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("FALLEN PALM TREE PRIME WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 1)
	{
		firstrun := 0
		GuiControl,, ScriptBlue, %scriptname%
		GuiControl,, State3, Running
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")

		IniRead, x1, Config.ini, Fallen Palm Tree Main, xmin
		IniRead, x2, Config.ini, Fallen Palm Tree Main, xmax
		IniRead, y1, Config.ini, Fallen Palm Tree Main, ymin
		IniRead, y2, Config.ini, Fallen Palm Tree Main, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("FALLEN PALM TREE MAIN", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Fallen Palm Tree Main, min
		IniRead, sa2, Config.ini, Fallen Palm Tree Main, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("FALLEN PALM TREE MAIN WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 0)
	{
		++firstrun

		IniRead, x1, Config.ini, Fallen Palm Tree 1, xmin
		IniRead, x2, Config.ini, Fallen Palm Tree 1, xmax
		IniRead, y1, Config.ini, Fallen Palm Tree 1, ymin
		IniRead, y2, Config.ini, Fallen Palm Tree 1, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("FALLEN PALM TREE 1", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Fallen Palm Tree 1, min
		IniRead, sa2, Config.ini, Fallen Palm Tree 1, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("FALLEN PALM TREE 1 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Rope Ladder, xmin
		IniRead, x2, Config.ini, Rope Ladder, xmax
		IniRead, y1, Config.ini, Rope Ladder, ymin
		IniRead, y2, Config.ini, Rope Ladder, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("ROPE LADDER", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Rope Ladder, min
		IniRead, sa2, Config.ini, Rope Ladder, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("ROPE LADDER WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Gap 1, xmin
		IniRead, x2, Config.ini, Gap 1, xmax
		IniRead, y1, Config.ini, Gap 1, ymin
		IniRead, y2, Config.ini, Gap 1, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("GAP 1", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Gap 1, min
		IniRead, sa2, Config.ini, Gap 1, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("GAP 1 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Stone Pillar, xmin
		IniRead, x2, Config.ini, Stone Pillar, xmax
		IniRead, y1, Config.ini, Stone Pillar, ymin
		IniRead, y2, Config.ini, Stone Pillar, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("STONE PILLAR", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Stone Pillar, min
		IniRead, sa2, Config.ini, Stone Pillar, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("STONE PILLAR WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Rock Wall, xmin
		IniRead, x2, Config.ini, Rock Wall, xmax
		IniRead, y1, Config.ini, Rock Wall, ymin
		IniRead, y2, Config.ini, Rock Wall, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("ROCK WALL", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Rock Wall, min
		IniRead, sa2, Config.ini, Rock Wall, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("ROCK WALL WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Fallen Palm Tree 2, xmin
		IniRead, x2, Config.ini, Fallen Palm Tree 2, xmax
		IniRead, y1, Config.ini, Fallen Palm Tree 2, ymin
		IniRead, y2, Config.ini, Fallen Palm Tree 2, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("FALLEN PALM TREE 2", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Fallen Palm Tree 2, min
		IniRead, sa2, Config.ini, Fallen Palm Tree 2, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("FALLEN PALM TREE 2 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Small Gap, xmin
		IniRead, x2, Config.ini, Small Gap, xmax
		IniRead, y1, Config.ini, Small Gap, ymin
		IniRead, y2, Config.ini, Small Gap, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("SMALL GAP", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Small Gap, min
		IniRead, sa2, Config.ini, Small Gap, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SMALL GAP WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Medium Gap, xmin
		IniRead, x2, Config.ini, Medium Gap, xmax
		IniRead, y1, Config.ini, Medium Gap, ymin
		IniRead, y2, Config.ini, Medium Gap, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("MEDIUM GAP", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Medium Gap, min
		IniRead, sa2, Config.ini, Medium Gap, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("MEDIUM GAP WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Fallen Palm Tree 3, xmin
		IniRead, x2, Config.ini, Fallen Palm Tree 3, xmax
		IniRead, y1, Config.ini, Fallen Palm Tree 3, ymin
		IniRead, y2, Config.ini, Fallen Palm Tree 3, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("FALLEN PALM TREE 3", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Fallen Palm Tree 3, min
		IniRead, sa2, Config.ini, Fallen Palm Tree 3, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("FALLEN PALM TREE 3 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Collapsed Walls, xmin
		IniRead, x2, Config.ini, Collapsed Walls, xmax
		IniRead, y1, Config.ini, Collapsed Walls, ymin
		IniRead, y2, Config.ini, Collapsed Walls, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("COLLAPSED WALLS", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Collapsed Walls, min
		IniRead, sa2, Config.ini, Collapsed Walls, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("COLLAPSED WALLS WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Large Rock 1, xmin
		IniRead, x2, Config.ini, Large Rock 1, xmax
		IniRead, y1, Config.ini, Large Rock 1, ymin
		IniRead, y2, Config.ini, Large Rock 1, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LARGE ROCK 1", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Large Rock 1, min
		IniRead, sa2, Config.ini, Large Rock 1, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LARGE ROCK 1 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Ledge 1, xmin
		IniRead, x2, Config.ini, Ledge 1, xmax
		IniRead, y1, Config.ini, Ledge 1, ymin
		IniRead, y2, Config.ini, Ledge 1, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LEDGE 1", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Ledge 1, min
		IniRead, sa2, Config.ini, Ledge 1, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LEDGE 1 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Gap 2, xmin
		IniRead, x2, Config.ini, Gap 2, xmax
		IniRead, y1, Config.ini, Gap 2, ymin
		IniRead, y2, Config.ini, Gap 2, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("GAP 2", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Gap 2, min
		IniRead, sa2, Config.ini, Gap 2, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("GAP 2 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Ledge 2, xmin
		IniRead, x2, Config.ini, Ledge 2, xmax
		IniRead, y1, Config.ini, Ledge 2, ymin
		IniRead, y2, Config.ini, Ledge 2, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LEDGE 2", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Ledge 2, min
		IniRead, sa2, Config.ini, Ledge 2, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LEDGE 2 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Large Rock 2, xmin
		IniRead, x2, Config.ini, Large Rock 2, xmax
		IniRead, y1, Config.ini, Large Rock 2, ymin
		IniRead, y2, Config.ini, Large Rock 2, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LARGE ROCK 2", "X=" x " Y=" y)

		IniRead, LLARS_RandomSleepOption, %LLARS_CONFIG_FILE%, Random Sleep, option
		StringLower, LLARS_RandomSleepOption, LLARS_RandomSleepOption
		LLARS_RandomSleepThisLoop := false
		if (LLARS_RandomSleepOption = "true")
		{
			IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
			Random, RandomNumber, 1, 100
			LLARS_RandomSleepThisLoop := (RandomNumber <= chance)
		}

		IniRead, sa1, Config.ini, Large Rock 2, min
		IniRead, sa2, Config.ini, Large Rock 2, max
		Random, SleepAmount, %sa1%, %sa2%
		if (LLARS_RandomSleepThisLoop)
			LLARS_EstimatedSleep(SleepAmount)
		else
			LLARS_FinalSleep(SleepAmount)
		Log("LARGE ROCK 2 WAIT", "Sleep completed: " SleepAmount " ms")

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
