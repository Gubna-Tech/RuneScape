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
		LLARS_SetStatus("Agility", "Log Beam Prime")
		LLARS_Click("Log Beam Prime")

		LLARS_Sleep("Sleep Log Beam Prime")

	}
	else
	{
		LLARS_SetStatus("Agility", "Log Beam Main")
		LLARS_Click("Log Beam Main")

		LLARS_Sleep("Sleep Log Beam Main")

	}

	LLARS_SetStatus("Agility", "Wall")
	LLARS_Click("Wall")

	LLARS_Sleep("Sleep Wall")

	LLARS_SetStatus("Agility", "Balancing Ledge")
	LLARS_Click("Balancing Ledge")

	LLARS_Sleep("Sleep Balancing Ledge")

	LLARS_SetStatus("Agility", "Obstacle low wall")
	LLARS_Click("Obstacle low wall")

	LLARS_Sleep("Sleep Obstacle low wall")

	LLARS_SetStatus("Agility", "Rope swing")
	LLARS_Click("Rope swing")

	LLARS_Sleep("Sleep Rope swing")

	LLARS_SetStatus("Agility", "Monkey bars")
	LLARS_Click("Monkey bars")

	LLARS_Sleep("Sleep Monkey bars")

	LLARS_SetStatus("Agility", "Ledge")
	LLARS_Click("Ledge")

	LLARS_Sleep("Sleep Ledge", !LLARS_RandomSleepRoll())

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
