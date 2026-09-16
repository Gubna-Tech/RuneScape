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
		LLARS_SetStatus("Agility", "Fallen Palm Tree")
		LLARS_Click("Fallen Palm Tree prime")

		LLARS_Sleep("Sleep Fallen Palm Tree prime")

	}
	else
	{
		LLARS_SetStatus("Agility", "Fallen Palm Tree")
		LLARS_Click("Fallen Palm Tree Main")

		LLARS_Sleep("Sleep Fallen Palm Tree Main")

	}

	LLARS_SetStatus("Agility", "Fallen Palm Tree 1")
	LLARS_Click("Fallen Palm Tree 1")

	LLARS_Sleep("Sleep Fallen Palm Tree 1")

	LLARS_SetStatus("Agility", "Rope Ladder")
	LLARS_Click("Rope Ladder")

	LLARS_Sleep("Sleep Rope Ladder")

	LLARS_SetStatus("Agility", "Gap 1")
	LLARS_Click("Gap 1")

	LLARS_Sleep("Sleep Gap 1")

	LLARS_SetStatus("Agility", "Stone Pillar")
	LLARS_Click("Stone Pillar")

	LLARS_Sleep("Sleep Stone Pillar")

	LLARS_SetStatus("Agility", "Rock Wall")
	LLARS_Click("Rock Wall")

	LLARS_Sleep("Sleep Rock Wall")

	LLARS_SetStatus("Agility", "Fallen Palm Tree 2")
	LLARS_Click("Fallen Palm Tree 2")

	LLARS_Sleep("Sleep Fallen Palm Tree 2")

	LLARS_SetStatus("Agility", "Small Gap")
	LLARS_Click("Small Gap")

	LLARS_Sleep("Sleep Small Gap")

	LLARS_SetStatus("Agility", "Medium Gap")
	LLARS_Click("Medium Gap")

	LLARS_Sleep("Sleep Medium Gap")

	LLARS_SetStatus("Agility", "Fallen Palm Tree 3")
	LLARS_Click("Fallen Palm Tree 3")

	LLARS_Sleep("Sleep Fallen Palm Tree 3")

	LLARS_SetStatus("Agility", "Collapsed Walls")
	LLARS_Click("Collapsed Walls")

	LLARS_Sleep("Sleep Collapsed Walls")

	LLARS_SetStatus("Agility", "Large Rock 1")
	LLARS_Click("Large Rock 1")

	LLARS_Sleep("Sleep Large Rock 1")

	LLARS_SetStatus("Agility", "Ledge 1")
	LLARS_Click("Ledge 1")

	LLARS_Sleep("Sleep Ledge 1")

	LLARS_SetStatus("Agility", "Gap 2")
	LLARS_Click("Gap 2")

	LLARS_Sleep("Sleep Gap 2")

	LLARS_SetStatus("Agility", "Ledge 2")
	LLARS_Click("Ledge 2")

	LLARS_Sleep("Sleep Ledge 2")

	LLARS_SetStatus("Agility", "Large Rock 2")
	LLARS_Click("Large Rock 2")

	LLARS_Sleep("Sleep Large Rock 2", !LLARS_RandomSleepRoll())

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
