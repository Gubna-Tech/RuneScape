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

		IniRead, x1, Config.ini, Bank Coords, xmin
		IniRead, x2, Config.ini, Bank Coords, xmax
		IniRead, y1, Config.ini, Bank Coords, ymin
		IniRead, y2, Config.ini, Bank Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BANK CLICK", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		IniRead, hkbank, Config.ini, Bank Preset, hotkey
		Send, {%hkbank%}
		Log("BANK PRESET", "Hotkey sent: " hkbank)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		IniRead, hk, Config.ini, Skillbar Hotkey, hotkey
		Send, {%hk%}
		Log("SKILLBAR", "Hotkey sent: " hk)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		Send, {2}
		Log("BOW ACTION", "Key 2 sent")

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		IniRead, x1, Config.ini, Bow Type, xmin
		IniRead, x2, Config.ini, Bow Type, xmax
		IniRead, y1, Config.ini, Bow Type, ymin
		IniRead, y2, Config.ini, Bow Type, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BOW TYPE CLICK", "X=" x " Y=" y)
	}

	If (firstrun = 1)
	{
		firstrun := 0
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")

		IniRead, x1, Config.ini, Bank Coords, xmin
		IniRead, x2, Config.ini, Bank Coords, xmax
		IniRead, y1, Config.ini, Bank Coords, ymin
		IniRead, y2, Config.ini, Bank Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("BANK CLICK", "X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		IniRead, hkbank, Config.ini, Bank Preset, hotkey
		Send, {%hkbank%}
		Log("BANK PRESET", "Hotkey sent: " hkbank)

		LLARS_RandomSleep()

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		if (firstrun = 0)
			LLARS_EstimatedSleep(SleepAmount)
		else
			LLARS_FinalSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		IniRead, hk, Config.ini, Skillbar Hotkey, hotkey
		Send, {%hk%}
		Log("SKILLBAR", "Hotkey sent: " hk)
	}

	If (firstrun = 0)
	{
		++firstrun

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		Send, {Space}
		Log("SPACE", "Space key sent")

		IniRead, sa1, Config.ini, Sleep Fletch, min
		IniRead, sa2, Config.ini, Sleep Fletch, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_FinalSleep(SleepAmount)
		Log("SLEEP", "Sleep Fletch completed: " SleepAmount " ms")
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
