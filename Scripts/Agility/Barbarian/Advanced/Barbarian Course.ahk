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

		IniRead, x1, Config.ini, Rope swing prime, xmin
		IniRead, x2, Config.ini, Rope swing prime, xmax
		IniRead, y1, Config.ini, Rope swing prime, ymin
		IniRead, y2, Config.ini, Rope swing prime, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("ROPE SWING PRIME", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Rope swing prime, min
		IniRead, sa2, Config.ini, Rope swing prime, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("ROPE SWING PRIME WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 1)
	{
		firstrun := 0

	; Make sure RuneScape is active before continuing.

		GuiControl,, ScriptBlue, %scriptname%
		GuiControl,, State3, Running
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")

		IniRead, x1, Config.ini, Rope swing Main, xmin
		IniRead, x2, Config.ini, Rope swing Main, xmax
		IniRead, y1, Config.ini, Rope swing Main, ymin
		IniRead, y2, Config.ini, Rope swing Main, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("ROPE SWING MAIN", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Rope swing Main, min
		IniRead, sa2, Config.ini, Rope swing Main, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("ROPE SWING MAIN WAIT", "Sleep completed: " SleepAmount " ms")
	}

	if (firstrun = 0)
	{
		++firstrun

		IniRead, x1, Config.ini, Log balance, xmin
		IniRead, x2, Config.ini, Log balance, xmax
		IniRead, y1, Config.ini, Log balance, ymin
		IniRead, y2, Config.ini, Log balance, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("LOG BALANCE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Log balance, min
		IniRead, sa2, Config.ini, Log balance, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("LOG BALANCE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Wall 1, xmin
		IniRead, x2, Config.ini, Wall 1, xmax
		IniRead, y1, Config.ini, Wall 1, ymin
		IniRead, y2, Config.ini, Wall 1, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("WALL 1", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Wall 1, min
		IniRead, sa2, Config.ini, Wall 1, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("WALL 1 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Wall 2, xmin
		IniRead, x2, Config.ini, Wall 2, xmax
		IniRead, y1, Config.ini, Wall 2, ymin
		IniRead, y2, Config.ini, Wall 2, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("WALL 2", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Wall 2, min
		IniRead, sa2, Config.ini, Wall 2, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("WALL 2 WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Spring Device, xmin
		IniRead, x2, Config.ini, Spring Device, xmax
		IniRead, y1, Config.ini, Spring Device, ymin
		IniRead, y2, Config.ini, Spring Device, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("SPRING DEVICE", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Spring Device, min
		IniRead, sa2, Config.ini, Spring Device, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SPRING DEVICE WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Balance Beam, xmin
		IniRead, x2, Config.ini, Balance Beam, xmax
		IniRead, y1, Config.ini, Balance Beam, ymin
		IniRead, y2, Config.ini, Balance Beam, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BALANCE BEAM", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Balance Beam, min
		IniRead, sa2, Config.ini, Balance Beam, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("BALANCE BEAM WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Gap, xmin
		IniRead, x2, Config.ini, Gap, xmax
		IniRead, y1, Config.ini, Gap, ymin
		IniRead, y2, Config.ini, Gap, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("GAP", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Gap, min
		IniRead, sa2, Config.ini, Gap, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("GAP WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Roof, xmin
		IniRead, x2, Config.ini, Roof, xmax
		IniRead, y1, Config.ini, Roof, ymin
		IniRead, y2, Config.ini, Roof, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("ROOF", "X=" x " Y=" y)

		IniRead, LLARS_RandomSleepOption, %LLARS_CONFIG_FILE%, Random Sleep, option
		StringLower, LLARS_RandomSleepOption, LLARS_RandomSleepOption
		LLARS_RandomSleepThisLoop := false
		if (LLARS_RandomSleepOption = "true")
		{
			IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
			Random, RandomNumber, 1, 100
			LLARS_RandomSleepThisLoop := (RandomNumber <= chance)
		}

		IniRead, sa1, Config.ini, Roof, min
		IniRead, sa2, Config.ini, Roof, max
		Random, SleepAmount, %sa1%, %sa2%
		if (LLARS_RandomSleepThisLoop)
			LLARS_EstimatedSleep(SleepAmount)
		else
			LLARS_FinalSleep(SleepAmount)
		Log("ROOF WAIT", "Sleep completed: " SleepAmount " ms")

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

			; Start the countdown using the actual randomized duration.
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
