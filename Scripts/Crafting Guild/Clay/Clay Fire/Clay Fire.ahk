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
		LLARS_SetStatus("Banking", "Clay Fire")
		LLARS_RedClick("Bank Prime")

		LLARS_Sleep("Sleep Short")

		LLARS_SetStatus("Loading Preset", "Unfired Clay")
		LLARS_PressHotkey("Bank Preset")
	}
	else
	{
		LLARS_SetStatus("Loading Preset", "Unfired Clay")
		LLARS_PressHotkey("Bank Preset")
	}

	LLARS_Sleep("Sleep Short")

	LLARS_SetStatus("Moving", "Pottery Oven")
	LLARS_RedClick("Pottery Oven")

	LLARS_Sleep("Sleep Walk")

	LLARS_SetStatus("Firing", "Clay")

	LLARS_PressKey("Space")

	fireWait := LLARS_Sleep("Sleep Fire")
	if (fireWait <= 0)
		throw Exception("Sleep Fire was not executed; check the configured timer")

	LLARS_SetStatus("Banking", "Clay Fire")
	LLARS_RedClick("Bank Main")

	LLARS_Sleep("Sleep Walk", true)
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

; Loads the required LLARS Core bootstrap.
#Include %A_ScriptDir%\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
