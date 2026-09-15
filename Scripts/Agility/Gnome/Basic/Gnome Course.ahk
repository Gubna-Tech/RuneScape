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
		LLARS_SetStatus("Agility", "Log Balance Prime")
		LLARS_Click("Log Balance Prime")

		LLARS_Sleep("Sleep Log")

	}
	else
	{
		LLARS_Sleep("Sleep Brief")

		LLARS_SetStatus("Agility", "Log Balance Main")
		LLARS_Click("Log Balance Main")

		LLARS_Sleep("Sleep Loop")

	}

	LLARS_SetStatus("Agility", "Obstacle Net 1")
	LLARS_Click("Obstacle Net 1")

	LLARS_Sleep("Sleep Net 1")

	LLARS_SetStatus("Agility", "Tree Branch 1")
	LLARS_Click("Tree Branch 1")

	LLARS_Sleep("Sleep Normal")

	LLARS_SetStatus("Agility", "Balance Rope")
	LLARS_Click("Balance Rope")

	LLARS_Sleep("Sleep Rope")

	LLARS_SetStatus("Agility", "Tree Branch 2")
	LLARS_Click("Tree Branch 2")

	LLARS_Sleep("Sleep Action")

	LLARS_SetStatus("Agility", "Obstacle Net 2")
	LLARS_Click("Obstacle Net 2")

	LLARS_Sleep("Sleep Net 2")

	LLARS_SetStatus("Agility", "Obstacle Pipe")
	LLARS_Click("Obstacle Pipe")

	LLARS_Sleep("Sleep Pipe", !LLARS_RandomSleepRoll())

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
