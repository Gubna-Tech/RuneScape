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
		LLARS_SetStatus("Agility", "Log Balance")
		LLARS_Click("Log balance prime")

		LLARS_Sleep("Sleep Log balance prime")

	}
	else
	{
		LLARS_Sleep("Sleep Brief")

		LLARS_SetStatus("Agility", "Log Balance")
		LLARS_Click("Log balance Main")

		LLARS_Sleep("Sleep Log balance Main")

	}

	LLARS_SetStatus("Agility", "Obstacle Net")
	LLARS_Click("Obstacle net")

	LLARS_Sleep("Sleep Obstacle net")

	LLARS_SetStatus("Agility", "Tree Branch")
	LLARS_Click("Tree branch")

	LLARS_Sleep("Sleep Tree branch")

	LLARS_SetStatus("Agility", "Tree")
	LLARS_Click("Tree")

	LLARS_Sleep("Sleep Tree")

	LLARS_SetStatus("Agility", "Signpost")
	LLARS_Click("Signpost")

	LLARS_Sleep("Sleep Signpost")

	LLARS_SetStatus("Agility", "Pole")
	LLARS_Click("Pole")

	LLARS_Sleep("Sleep Pole")

	LLARS_SetStatus("Agility", "Tile")
	LLARS_Click("Tile")

	LLARS_Sleep("Sleep Tile")

	LLARS_SetStatus("Agility", "Barrier")
	LLARS_Click("Barrier")

	LLARS_Sleep("Sleep Barrier", !LLARS_RandomSleepRoll())

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
