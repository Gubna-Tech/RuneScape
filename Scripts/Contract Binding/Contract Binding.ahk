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

	Log("RUN", "Run " count " of " runcount3 " started")

	IniRead, x1, Config.ini, Magestix, xmin
	IniRead, x2, Config.ini, Magestix, xmax
	IniRead, y1, Config.ini, Magestix, ymin
	IniRead, y2, Config.ini, Magestix, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CLICK", "Magestix X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	IniRead, x1, Config.ini, Sell Tab, xmin
	IniRead, x2, Config.ini, Sell Tab, xmax
	IniRead, y1, Config.ini, Sell Tab, ymin
	IniRead, y2, Config.ini, Sell Tab, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CLICK", "Sell Tab X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	loop 3
	{
			IniRead, x1, Config.ini, Hellfire Metal - Sell, xmin
		IniRead, x2, Config.ini, Hellfire Metal - Sell, xmax
		IniRead, y1, Config.ini, Hellfire Metal - Sell, ymin
		IniRead, y2, Config.ini, Hellfire Metal - Sell, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")
		Log("RIGHT CLICK", "Hellfire Metal - Sell X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

		IniRead, minx, Config.ini, Offset - Sell, minx
		IniRead, maxx, Config.ini, Offset - Sell, maxx
		IniRead, miny, Config.ini, Offset - Sell, miny
		IniRead, maxy, Config.ini, Offset - Sell, maxy
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)
		Log("MENU CLICK", "Offset - Sell X=" TargetX " Y=" TargetY " | XOffset=" XOffset " YOffset=" YOffset)

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")
	}

	loop 3
	{
			IniRead, x1, Config.ini, Blood of Orcus - Sell, xmin
		IniRead, x2, Config.ini, Blood of Orcus - Sell, xmax
		IniRead, y1, Config.ini, Blood of Orcus - Sell, ymin
		IniRead, y2, Config.ini, Blood of Orcus - Sell, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")
		Log("RIGHT CLICK", "Blood of Orcus - Sell X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

		IniRead, minx, Config.ini, Offset - Sell, minx
		IniRead, maxx, Config.ini, Offset - Sell, maxx
		IniRead, miny, Config.ini, Offset - Sell, miny
		IniRead, maxy, Config.ini, Offset - Sell, maxy
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)
		Log("MENU CLICK", "Offset - Sell X=" TargetX " Y=" TargetY " | XOffset=" XOffset " YOffset=" YOffset)

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")
	}

	IniRead, x1, Config.ini, Buy Tab, xmin
	IniRead, x2, Config.ini, Buy Tab, xmax
	IniRead, y1, Config.ini, Buy Tab, ymin
	IniRead, y2, Config.ini, Buy Tab, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CLICK", "Buy Tab X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	IniRead, x1, Config.ini, Blood of Orcus - Buy, xmin
	IniRead, x2, Config.ini, Blood of Orcus - Buy, xmax
	IniRead, y1, Config.ini, Blood of Orcus - Buy, ymin
	IniRead, y2, Config.ini, Blood of Orcus - Buy, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y, "right")
	Log("RIGHT CLICK", "Blood of Orcus - Buy X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Brief, min
	IniRead, sa2, Config.ini, Sleep Brief, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

	IniRead, minx, Config.ini, Offset - Buy, minx
	IniRead, maxx, Config.ini, Offset - Buy, maxx
	IniRead, miny, Config.ini, Offset - Buy, miny
	IniRead, maxy, Config.ini, Offset - Buy, maxy
	MouseGetPos, RightClickX, RightClickY
	Random, XOffset, %minx%, %maxx%
	Random, YOffset, %miny%, %maxy%
	TargetX := RightClickX + XOffset
	TargetY := RightClickY + YOffset
	NaturalClick(TargetX, TargetY)
	Log("MENU CLICK", "Offset - Buy X=" TargetX " Y=" TargetY " | XOffset=" XOffset " YOffset=" YOffset)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	IniRead, x1, Config.ini, Hellfire Metal - Buy, xmin
	IniRead, x2, Config.ini, Hellfire Metal - Buy, xmax
	IniRead, y1, Config.ini, Hellfire Metal - Buy, ymin
	IniRead, y2, Config.ini, Hellfire Metal - Buy, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y, "right")
	Log("RIGHT CLICK", "Hellfire Metal - Buy X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Brief, min
	IniRead, sa2, Config.ini, Sleep Brief, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

	IniRead, minx, Config.ini, Offset - Buy, minx
	IniRead, maxx, Config.ini, Offset - Buy, maxx
	IniRead, miny, Config.ini, Offset - Buy, miny
	IniRead, maxy, Config.ini, Offset - Buy, maxy
	MouseGetPos, RightClickX, RightClickY
	Random, XOffset, %minx%, %maxx%
	Random, YOffset, %miny%, %maxy%
	TargetX := RightClickX + XOffset
	TargetY := RightClickY + YOffset
	NaturalClick(TargetX, TargetY)
	Log("MENU CLICK", "Offset - Buy X=" TargetX " Y=" TargetY " | XOffset=" XOffset " YOffset=" YOffset)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	IniRead, x1, Config.ini, Obelisk, xmin
	IniRead, x2, Config.ini, Obelisk, xmax
	IniRead, y1, Config.ini, Obelisk, ymin
	IniRead, y2, Config.ini, Obelisk, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CLICK", "Obelisk X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	send {space}
	Log("SPACE", "Space key sent to begin infusion")

	IniRead, sa1, Config.ini, Sleep Infuse, min
	IniRead, sa2, Config.ini, Sleep Infuse, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Infuse completed: " SleepAmount " ms")

	loop 14
	{
			IniRead, x1, Config.ini, Magestix, xmin
		IniRead, x2, Config.ini, Magestix, xmax
		IniRead, y1, Config.ini, Magestix, ymin
		IniRead, y2, Config.ini, Magestix, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("CLICK", "Magestix X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, x1, Config.ini, Blood of Orcus - Buy, xmin
		IniRead, x2, Config.ini, Blood of Orcus - Buy, xmax
		IniRead, y1, Config.ini, Blood of Orcus - Buy, ymin
		IniRead, y2, Config.ini, Blood of Orcus - Buy, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")
		Log("RIGHT CLICK", "Blood of Orcus - Buy X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

		IniRead, minx, Config.ini, Offset - Buy, minx
		IniRead, maxx, Config.ini, Offset - Buy, maxx
		IniRead, miny, Config.ini, Offset - Buy, miny
		IniRead, maxy, Config.ini, Offset - Buy, maxy
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)
		Log("MENU CLICK", "Offset - Buy X=" TargetX " Y=" TargetY " | XOffset=" XOffset " YOffset=" YOffset)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, x1, Config.ini, Hellfire Metal - Buy, xmin
		IniRead, x2, Config.ini, Hellfire Metal - Buy, xmax
		IniRead, y1, Config.ini, Hellfire Metal - Buy, ymin
		IniRead, y2, Config.ini, Hellfire Metal - Buy, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")
		Log("RIGHT CLICK", "Hellfire Metal - Buy X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

		IniRead, minx, Config.ini, Offset - Buy, minx
		IniRead, maxx, Config.ini, Offset - Buy, maxx
		IniRead, miny, Config.ini, Offset - Buy, miny
		IniRead, maxy, Config.ini, Offset - Buy, maxy
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)
		Log("MENU CLICK", "Offset - Buy X=" TargetX " Y=" TargetY " | XOffset=" XOffset " YOffset=" YOffset)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, x1, Config.ini, Obelisk, xmin
		IniRead, x2, Config.ini, Obelisk, xmax
		IniRead, y1, Config.ini, Obelisk, ymin
		IniRead, y2, Config.ini, Obelisk, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		Log("CLICK", "Obelisk X=" x " Y=" y)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

		send {space}
		Log("SPACE", "Space key sent to begin infusion")

		IniRead, sa1, Config.ini, Sleep Infuse, min
		IniRead, sa2, Config.ini, Sleep Infuse, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_FinalSleep(SleepAmount)
		Log("SLEEP", "Sleep Infuse completed: " SleepAmount " ms")
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
