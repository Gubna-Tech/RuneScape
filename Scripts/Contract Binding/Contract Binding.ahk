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

LLARS_RunCount(Func("Run"))

return

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

Run(ctx)
{
	global

	LLARS_Click("Magestix")

	LLARS_Sleep("Sleep Short")

	LLARS_Click("Sell Tab")

	LLARS_Sleep("Sleep Short")

	loop 3
	{
		x1 := LLARS_ConfigRead("Hellfire Metal - Sell", "xmin", "")
		x2 := LLARS_ConfigRead("Hellfire Metal - Sell", "xmax", "")
		y1 := LLARS_ConfigRead("Hellfire Metal - Sell", "ymin", "")
		y2 := LLARS_ConfigRead("Hellfire Metal - Sell", "ymax", "")
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")

		LLARS_Sleep("Sleep Brief")

		minx := LLARS_ConfigReadNumber("Offset - Sell", "minx")
		maxx := LLARS_ConfigReadNumber("Offset - Sell", "maxx")
		miny := LLARS_ConfigReadNumber("Offset - Sell", "miny")
		maxy := LLARS_ConfigReadNumber("Offset - Sell", "maxy")
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)

		LLARS_Sleep("Sleep Brief")
	}

	loop 3
	{
		x1 := LLARS_ConfigRead("Blood of Orcus - Sell", "xmin", "")
		x2 := LLARS_ConfigRead("Blood of Orcus - Sell", "xmax", "")
		y1 := LLARS_ConfigRead("Blood of Orcus - Sell", "ymin", "")
		y2 := LLARS_ConfigRead("Blood of Orcus - Sell", "ymax", "")
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")

		LLARS_Sleep("Sleep Brief")

		minx := LLARS_ConfigReadNumber("Offset - Sell", "minx")
		maxx := LLARS_ConfigReadNumber("Offset - Sell", "maxx")
		miny := LLARS_ConfigReadNumber("Offset - Sell", "miny")
		maxy := LLARS_ConfigReadNumber("Offset - Sell", "maxy")
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)

		LLARS_Sleep("Sleep Brief")
	}

	LLARS_Click("Buy Tab")

	LLARS_Sleep("Sleep Short")

	LLARS_Click("Blood of Orcus - Buy", "right")

	LLARS_Sleep("Sleep Brief")

	minx := LLARS_ConfigReadNumber("Offset - Buy", "minx")
	maxx := LLARS_ConfigReadNumber("Offset - Buy", "maxx")
	miny := LLARS_ConfigReadNumber("Offset - Buy", "miny")
	maxy := LLARS_ConfigReadNumber("Offset - Buy", "maxy")
	MouseGetPos, RightClickX, RightClickY
	Random, XOffset, %minx%, %maxx%
	Random, YOffset, %miny%, %maxy%
	TargetX := RightClickX + XOffset
	TargetY := RightClickY + YOffset
	NaturalClick(TargetX, TargetY)

	LLARS_Sleep("Sleep Short")

	LLARS_Click("Hellfire Metal - Buy", "right")

	LLARS_Sleep("Sleep Brief")

	minx := LLARS_ConfigReadNumber("Offset - Buy", "minx")
	maxx := LLARS_ConfigReadNumber("Offset - Buy", "maxx")
	miny := LLARS_ConfigReadNumber("Offset - Buy", "miny")
	maxy := LLARS_ConfigReadNumber("Offset - Buy", "maxy")
	MouseGetPos, RightClickX, RightClickY
	Random, XOffset, %minx%, %maxx%
	Random, YOffset, %miny%, %maxy%
	TargetX := RightClickX + XOffset
	TargetY := RightClickY + YOffset
	NaturalClick(TargetX, TargetY)

	LLARS_Sleep("Sleep Short")

	LLARS_Click("Obelisk")

	LLARS_Sleep("Sleep Short")

	LLARS_PressKey("space")

	LLARS_Sleep("Sleep Infuse")

	loop 14
	{
		x1 := LLARS_ConfigRead("Magestix", "xmin", "")
		x2 := LLARS_ConfigRead("Magestix", "xmax", "")
		y1 := LLARS_ConfigRead("Magestix", "ymin", "")
		y2 := LLARS_ConfigRead("Magestix", "ymax", "")
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)

		LLARS_Sleep("Sleep Short")

		x1 := LLARS_ConfigRead("Blood of Orcus - Buy", "xmin", "")
		x2 := LLARS_ConfigRead("Blood of Orcus - Buy", "xmax", "")
		y1 := LLARS_ConfigRead("Blood of Orcus - Buy", "ymin", "")
		y2 := LLARS_ConfigRead("Blood of Orcus - Buy", "ymax", "")
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")

		LLARS_Sleep("Sleep Brief")

		minx := LLARS_ConfigReadNumber("Offset - Buy", "minx")
		maxx := LLARS_ConfigReadNumber("Offset - Buy", "maxx")
		miny := LLARS_ConfigReadNumber("Offset - Buy", "miny")
		maxy := LLARS_ConfigReadNumber("Offset - Buy", "maxy")
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)

		LLARS_Sleep("Sleep Short")

		x1 := LLARS_ConfigRead("Hellfire Metal - Buy", "xmin", "")
		x2 := LLARS_ConfigRead("Hellfire Metal - Buy", "xmax", "")
		y1 := LLARS_ConfigRead("Hellfire Metal - Buy", "ymin", "")
		y2 := LLARS_ConfigRead("Hellfire Metal - Buy", "ymax", "")
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y, "right")

		LLARS_Sleep("Sleep Brief")

		minx := LLARS_ConfigReadNumber("Offset - Buy", "minx")
		maxx := LLARS_ConfigReadNumber("Offset - Buy", "maxx")
		miny := LLARS_ConfigReadNumber("Offset - Buy", "miny")
		maxy := LLARS_ConfigReadNumber("Offset - Buy", "maxy")
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)

		LLARS_Sleep("Sleep Short")

		x1 := LLARS_ConfigRead("Obelisk", "xmin", "")
		x2 := LLARS_ConfigRead("Obelisk", "xmax", "")
		y1 := LLARS_ConfigRead("Obelisk", "ymin", "")
		y2 := LLARS_ConfigRead("Obelisk", "ymax", "")
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)

		LLARS_Sleep("Sleep Short")

		LLARS_PressKey("space")

		LLARS_Sleep("Sleep Infuse", true)
	}
}



; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

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
