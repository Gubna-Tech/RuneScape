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
		LLARS_SetStatus("Agility", "Rope swing prime")
		LLARS_Click("Rope swing prime")

		LLARS_Sleep("Sleep Rope swing prime")

	}
	else
	{
		; Make sure RuneScape is active before continuing.

		LLARS_SetStatus("Agility", "Rope swing Main")
		LLARS_Click("Rope swing Main")

		LLARS_Sleep("Sleep Rope swing Main")

	}

	LLARS_SetStatus("Agility", "Log balance")
	LLARS_Click("Log balance")

	LLARS_Sleep("Sleep Log balance")

	LLARS_SetStatus("Agility", "Wall 1")
	LLARS_Click("Wall 1")

	LLARS_Sleep("Sleep Wall 1")

	LLARS_SetStatus("Agility", "Wall 2")
	LLARS_Click("Wall 2")

	LLARS_Sleep("Sleep Wall 2")

	LLARS_SetStatus("Agility", "Spring Device")
	LLARS_Click("Spring Device")

	LLARS_Sleep("Sleep Spring Device")

	LLARS_SetStatus("Agility", "Balance Beam")
	LLARS_Click("Balance Beam")

	LLARS_Sleep("Sleep Balance Beam")

	LLARS_SetStatus("Agility", "Gap")
	LLARS_Click("Gap")

	LLARS_Sleep("Sleep Gap")

	LLARS_SetStatus("Agility", "Roof")
	LLARS_Click("Roof")

	LLARS_Sleep("Sleep Roof", !LLARS_RandomSleepRoll())

	LLARS_RandomSleep()
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
