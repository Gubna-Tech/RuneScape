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

	if (ctx.IsFirst)
	{
		LLARS_Click("Pedestal - Pedestal")

		LLARS_Sleep("Sleep Short")

		LLARS_Click("Ritual Type")

		LLARS_Sleep("Sleep Short")

		option := LLARS_ConfigReadInteger("Input", "scroll")
		If (option)
		{
			x1 := LLARS_ConfigRead("Input", "xmin", "")
			x2 := LLARS_ConfigRead("Input", "xmax", "")
			y1 := LLARS_ConfigRead("Input", "ymin", "")
			y2 := LLARS_ConfigRead("Input", "ymax", "")
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			Random, Scroll, 5, 10
			if !LLARS_WaitForRuneScape("MouseMove")
				return
			MouseMove, %x%, %y%

			LLARS_Sleep("Sleep Brief")

			Loop, % Scroll
			{
				LLARS_PressKey("WheelDown")
			}

			LLARS_Sleep("Sleep Brief")
		}
		Else
		{
		}

		LLARS_Click("Input")

		LLARS_Sleep("Sleep Short")

		LLARS_PressKey("Space")

		LLARS_Sleep("Sleep Normal")

		LLARS_Click("Pedestal - Pedestal", "right")

		LLARS_Sleep("Sleep Short")

		minx := LLARS_ConfigReadNumber("Offset", "minx")
		maxx := LLARS_ConfigReadNumber("Offset", "maxx")
		miny := LLARS_ConfigReadNumber("Offset", "miny")
		maxy := LLARS_ConfigReadNumber("Offset", "maxy")
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)

		LLARS_Sleep("Sleep Repair")

		LLARS_Click("Platform")

		LLARS_Sleep("Sleep Walk")

		LLARS_Sleep("Sleep Ritual")

	}
	else
	{
		LLARS_Click("Pedestal - Platform", "right")

		LLARS_Sleep("Sleep Short")

		minx := LLARS_ConfigReadNumber("Offset", "minx")
		maxx := LLARS_ConfigReadNumber("Offset", "maxx")
		miny := LLARS_ConfigReadNumber("Offset", "miny")
		maxy := LLARS_ConfigReadNumber("Offset", "maxy")
		MouseGetPos, RightClickX, RightClickY
		Random, XOffset, %minx%, %maxx%
		Random, YOffset, %miny%, %maxy%
		TargetX := RightClickX + XOffset
		TargetY := RightClickY + YOffset
		NaturalClick(TargetX, TargetY)

		LLARS_Sleep("Sleep Walk")

	}

	LLARS_RandomSleep()

	LLARS_Click("Platform")

	LLARS_Sleep("Sleep Walk")

	LLARS_Sleep("Sleep Ritual", true)
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
