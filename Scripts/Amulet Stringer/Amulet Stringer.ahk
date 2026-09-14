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

	IniRead, x1, Config.ini, Bank Coords, xmin
	IniRead, x2, Config.ini, Bank Coords, xmax
	IniRead, y1, Config.ini, Bank Coords, ymin
	IniRead, y2, Config.ini, Bank Coords, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("BANK CLICK", "X=" x " Y=" y)

	; Short randomized delay after banking.
	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)

	IniRead, hkbank, Config.ini, Bank Preset, hotkey
	Send, {%hkbank%}
	Log("BANK PRESET", "Hotkey sent: " hkbank)

	LLARS_RandomSleep()

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)

	IniRead, x1, Config.ini, Amulet, xmin
	IniRead, x2, Config.ini, Amulet, xmax
	IniRead, y1, Config.ini, Amulet, ymin
	IniRead, y2, Config.ini, Amulet, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("AMULET CLICK", "X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)

	IniRead, x1, Config.ini, Ball of Wool, xmin
	IniRead, x2, Config.ini, Ball of Wool, xmax
	IniRead, y1, Config.ini, Ball of Wool, ymin
	IniRead, y2, Config.ini, Ball of Wool, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("BALL OF WOOL CLICK", "X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Send, {Space}
	Log("CRAFT START", "Space key sent")

	; Crafting wait.
	IniRead, sa1, Config.ini, Sleep Craft, min
	IniRead, sa2, Config.ini, Sleep Craft, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_FinalSleep(SleepAmount)
	Log("CRAFT COMPLETE", "Crafting wait completed: " SleepAmount " ms")

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
