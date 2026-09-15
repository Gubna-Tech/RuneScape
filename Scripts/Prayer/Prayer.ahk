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

powdertime := 0
bobtime := 0

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

	option := LLARS_ConfigReadBool("Powder of burials")
	If (option)
	{
		If (ctx.IsFirst)
		{

			LLARS_Click("Bank Coords")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("Powder of burials", "bank preset")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("Powder of burials")

			powdertime := 1800000
			SetTimer, UpdateTime, 1000

			LLARS_Sleep("Sleep Short")
		}
	}
	Else
	{
	}

	option := LLARS_ConfigReadBool("beast of burden")
	If (option)
	{
		If (ctx.IsFirst)
		{

			LLARS_Click("Bank Coords")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("beast of burden", "bank preset")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("beast of burden", "restore pot hotkey")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("beast of burden", "bob hotkey")

			bobtimer := LLARS_ConfigReadInteger("beast of burden", "bob timer")
			bobtime := (bobtimer * 60 * 1000)
			SetTimer, updatebob, 1000

			LLARS_Sleep("Sleep Short")
		}
	}
	Else
	{
	}

	LLARS_Click("Bank Coords")

	LLARS_Sleep("Sleep Short")

	LLARS_PressHotkey("Bank Preset")

	LLARS_Sleep("Sleep Short")

	LLARS_RandomSleep()

	hkdown := LLARS_ConfigReadHotkey("Skillbar Hotkey", "hotkey")
	LLARS_CreatorSendInput("{" . hkdown . " down}", "Key Down")

	LLARS_Sleep("Sleep Prayer")

	hkup := LLARS_ConfigReadHotkey("Skillbar Hotkey", "hotkey")
	LLARS_CreatorSendInput("{" . hkup . " up}", "Key Up")

	option := LLARS_ConfigReadBool("beast of burden")
	If (option)
	{
		LLARS_Sleep("Sleep Short")

		LLARS_PressHotkey("beast of burden", "bob icon hotkey")

		LLARS_Sleep("Sleep Short")

		hkdown := LLARS_ConfigReadHotkey("Skillbar Hotkey", "hotkey")
		LLARS_CreatorSendInput("{" . hkdown . " down}", "Key Down")

		LLARS_Sleep("Sleep Prayer Extra")
		hkup := LLARS_ConfigReadHotkey("Skillbar Hotkey", "hotkey")
		LLARS_CreatorSendInput("{" . hkup . " up}", "Key Up")

		LLARS_Sleep("Sleep Brief")
	}
	Else
	{
	}

	option := LLARS_ConfigReadBool("beast of burden")
	If (option)
	{
		If (bobtime <= 60000)
		{
			LLARS_Click("Bank Coords")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("beast of burden", "bank preset")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("beast of burden", "restore pot hotkey")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("beast of burden", "bob hotkey")

			bobtimer := LLARS_ConfigReadInteger("beast of burden", "bob timer")
			bobtime := (bobtimer * 60 * 1000)
			SetTimer, updatebob, 1000

			LLARS_Sleep("Sleep Short")
		}
		Else
		{
		}
	}

	option := LLARS_ConfigReadBool("Powder of burials")
	If (option)
	{
		If (powdertime <= 60000)
		{
			LLARS_Click("Bank Coords")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("Powder of burials", "bank preset")

			LLARS_Sleep("Sleep Short")

			LLARS_PressHotkey("Powder of burials")

			powdertime := 1800000
			SetTimer, UpdateTime, 1000

			LLARS_Sleep("Sleep Short", true)
		}
		Else
		{
		}
	}
}



; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

return
UpdateTime:
powdertime -= 1000
return

updatebob:
bobtime -= 1000
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
