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

prime := 0

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

	option := LLARS_ConfigReadBool("Renew")
	if (option)
		if prime=0
	{
		++prime
		portables := LLARS_ConfigReadInteger("Renew", "portables")
		PortableRemainingTime :=( portables * 5 * 60 * 1000)+180000
		SetTimer, UpdateTime, 1000

		LLARS_SetStatus("Banking", "Gems")
		LLARS_Click("Bank")

		LLARS_Sleep("Sleep Short")

		LLARS_SetStatus("Renewing", "Portable Station")
		LLARS_PressHotkey("Renew", "bank hotkey")

		LLARS_Sleep("Sleep Short")

		LLARS_PressHotkey("Renew", "toolbar hotkey")

		LLARS_Sleep("Sleep Short")

		LLARS_PressKey("1")

		LLARS_Sleep("Sleep Short")

		portables := LLARS_ConfigReadInteger("Renew", "portables")
		LLARS_CreatorSendInput("{Raw}{" . portables . "}", "Text Input")

		LLARS_Sleep("Sleep Brief")

		LLARS_PressKey("enter")
	}

	LLARS_Sleep("Sleep Short")

	LLARS_SetStatus("Banking", "Gems")
	LLARS_Click("Bank")

	LLARS_Sleep("Sleep Short")

	LLARS_SetStatus("Loading Preset", "Gems")
	LLARS_PressHotkey("Bank Preset")

	LLARS_Sleep("Sleep Short")

	LLARS_SetStatus("Opening", "Portable Crafter")
	LLARS_Click("Crafter")

	LLARS_Sleep("Sleep Short")

	LLARS_RandomSleep()

	LLARS_PressKey("space")

	LLARS_SetStatus("Cutting", "Gems")
	IniRead, sa1, Config.ini, Sleep Craft, min
	IniRead, sa2, Config.ini, Sleep Craft, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_RenewOption := LLARS_ConfigReadBool("Renew")
	LLARS_RenewThisLoop := (LLARS_RenewOption && PortableRemainingTime <= 60000)
	if (LLARS_RenewThisLoop)
		LLARS_EstimatedSleep(SleepAmount)
	else
		LLARS_FinalSleep(SleepAmount)

	if (LLARS_RenewThisLoop)
	{
		LLARS_SetStatus("Banking", "Gems")
		LLARS_Click("Bank")

		LLARS_Sleep("Sleep Short")

		LLARS_SetStatus("Renewing", "Portable Station")
		LLARS_PressHotkey("Renew", "bank hotkey")

		LLARS_Sleep("Sleep Short")

		LLARS_PressHotkey("Renew", "toolbar hotkey")

		LLARS_Sleep("Sleep Short")

		LLARS_PressKey("1")

		LLARS_Sleep("Sleep Short")

		portables := LLARS_ConfigReadInteger("Renew", "portables")
		LLARS_CreatorSendInput("{Raw}{" . portables . "}", "Text Input")

		LLARS_Sleep("Sleep Brief")

		LLARS_PressKey("enter")

		portables := LLARS_ConfigReadInteger("Renew", "portables")
		PortableRemainingTime := portables * 5 * 60 * 1000
		SetTimer, UpdateTime, 1000

		LLARS_Sleep("Sleep Short", true)
	}
}



; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

return
; ================================================================
; |     PORTABLE RENEW TIMER     -     PORTABLE RENEW TIMER       |
; ================================================================

UpdateTime:
PortableRemainingTime -= 1000
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
