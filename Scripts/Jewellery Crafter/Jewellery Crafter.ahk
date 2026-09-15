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
		LLARS_Click("Bank Prime Coords")

		LLARS_Sleep("Sleep Short")

		LLARS_PressHotkey("Bank Preset")

		LLARS_Sleep("Sleep Short")

		LLARS_Click("Furnace Coords")

		LLARS_Sleep("Sleep Walk")

		x1 := LLARS_ConfigRead("bar", "xmin", "")
		x2 := LLARS_ConfigRead("bar", "xmax", "")
		y1 := LLARS_ConfigRead("bar", "ymin", "")
		y2 := LLARS_ConfigRead("bar", "ymax", "")
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		if !LLARS_WaitForRuneScape("MouseMove")
			return
		MouseMove, %x%, %y%

		LLARS_Sleep("Sleep Brief")

		scrollMin := LLARS_ConfigRead("Scroll", "min", "")
		scrollMax := LLARS_ConfigRead("Scroll", "max", "")
		Random, ScrollRand, %scrollMin%, %scrollMax%

		Loop, % ScrollRand
		{
			LLARS_PressKey("WheelDown")
			Random, ScrollSleep, 50, 250
			Sleep, %ScrollSleep%
		}

		LLARS_Sleep("Sleep Brief")

		LLARS_Click("bar")

		LLARS_Sleep("Sleep Short")

		LLARS_Click("item")

		LLARS_Sleep("Sleep Brief")

		MouseGetPos, clickX, clickY
		NaturalClick(clickX, clickY)

		LLARS_Sleep("Sleep Short")

	}
	else
	{
		LLARS_Click("Bank Main Coords")

		LLARS_Sleep("Sleep Walk")

		LLARS_PressHotkey("Bank Preset")

		LLARS_RandomSleep()

		LLARS_Sleep("Sleep Short")

		LLARS_Click("Furnace Coords")

		LLARS_Sleep("Sleep Walk")

	}

	LLARS_PressKey("Space")

	LLARS_Sleep("Sleep Craft", true)
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
