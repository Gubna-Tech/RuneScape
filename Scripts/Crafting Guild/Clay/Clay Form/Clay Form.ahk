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
		LLARS_SetStatus("Banking", "Clay Form")
		if !LLARS_RedClick("Bank Prime")
			throw Exception("Bank Prime click failed")

		LLARS_Sleep("Sleep Short")
	}
	else
	{
		LLARS_RandomSleep()
	}

	LLARS_SetStatus("Loading Preset", "Soft Clay")
	if !LLARS_PressHotkey("Bank Preset")
		throw Exception("Bank preset hotkey failed")

	LLARS_Sleep("Sleep Short")

	LLARS_SetStatus("Moving", "Pottery Wheel")
	if !LLARS_RedClick("Pottery Wheel")
		throw Exception("Pottery Wheel click failed")

	LLARS_Sleep("Sleep Walk")

	if (ctx.IsFirst)
	{
		LLARS_SetStatus("Selecting", "Pottery Menu")
		if !LLARS_Click("Pottery Menu")
			throw Exception("Pottery Menu click failed")

		LLARS_Sleep("Sleep Short")

		LLARS_SetStatus("Selecting", "Pottery Sub-Menu")
		if !LLARS_Click("Pottery Sub-Menu")
			throw Exception("Pottery Sub-Menu click failed")

		LLARS_Sleep("Sleep Short")

		LLARS_SetStatus("Selecting", "Item")
		if !LLARS_Click("Item")
			throw Exception("Item click failed")

		LLARS_Sleep("Sleep Short")
	}

	LLARS_SetStatus("Forming", "Clay")
	if !LLARS_PressKey("Space")
		throw Exception("Could not start Clay Form")

	formWait := LLARS_Sleep("Sleep Form")
	if (formWait <= 0)
		throw Exception("Sleep Form was not executed; check the configured timer")

	LLARS_SetStatus("Banking", "Clay Form")
	if !LLARS_RedClick("Bank Main")
		throw Exception("Bank Main click failed")

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
