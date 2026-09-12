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
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=0")

		IniRead, x1, Config.ini, Bank Prime Coords, xmin
		IniRead, x2, Config.ini, Bank Prime Coords, xmax
		IniRead, y1, Config.ini, Bank Prime Coords, ymin
		IniRead, y2, Config.ini, Bank Prime Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BANK PRIME CLICK", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		IniRead, hkbank, Config.ini, Bank Preset, hotkey
		Send, {%hkbank%}
		Log("BANK PRESET", "Hotkey sent: " hkbank)
	}

	If (firstrun = 1)
	{
		firstrun := 0
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")

		IniRead, hkbank, Config.ini, Bank Preset, hotkey
		Send, {%hkbank%}
		Log("BANK PRESET", "Hotkey sent: " hkbank)

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
	}

	If (firstrun = 0)
	{
		++firstrun

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Range Coords, xmin
		IniRead, x2, Config.ini, Range Coords, xmax
		IniRead, y1, Config.ini, Range Coords, ymin
		IniRead, y2, Config.ini, Range Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("RANGE CLICK", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Walk, min
		IniRead, sa2, Config.ini, Sleep Walk, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Walk completed: " SleepAmount " ms")

		Send, {Space}
		Log("SPACE", "Space key sent")

		IniRead, sa1, Config.ini, Sleep Cook, min
		IniRead, sa2, Config.ini, Sleep Cook, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Cook completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Bank Main Coords, xmin
		IniRead, x2, Config.ini, Bank Main Coords, xmax
		IniRead, y1, Config.ini, Bank Main Coords, ymin
		IniRead, y2, Config.ini, Bank Main Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BANK MAIN CLICK", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Walk, min
		IniRead, sa2, Config.ini, Sleep Walk, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_FinalSleep(SleepAmount)
		Log("SLEEP", "Sleep Walk completed: " SleepAmount " ms")
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
