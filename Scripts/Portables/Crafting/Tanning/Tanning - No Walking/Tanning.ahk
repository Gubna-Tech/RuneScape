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

if (!LLARS_StartRun())
	return

firstrun := 0
prime := 0

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

Loop, %runcount%
{
	LLARS_BeginLoop()

	Log("RUN", "Run " count " of " runcount3 " started")

	IniRead, option,Config.ini, Renew, option
	if option=true
		if prime=0
		{
			++prime
			IniRead, portables, Config.ini, Renew, portables
			PortableRemainingTime :=( portables * 5 * 60 * 1000)+180000
			SetTimer, UpdateTime, 1000

			IniRead, x1, Config.ini, Bank, xmin
			IniRead, x2, Config.ini, Bank, xmax
			IniRead, y1, Config.ini, Bank, ymin
			IniRead, y2, Config.ini, Bank, ymax
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			NaturalClick(x, y)
			Log("CLICK", "Bank X=" x " Y=" y)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, Renew, bank hotkey
			send {%hk%}
			Log("HOTKEY", "Configured Hotkey hotkey sent: " hk)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, Renew, toolbar hotkey
			send {%hk%}
			Log("HOTKEY", "Configured Hotkey hotkey sent: " hk)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			send {1}
			Log("KEY 1", "Key 1 sent")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, portables, Config.ini, Renew, portables
			sendraw {%portables%}

			IniRead, sa1, Config.ini, Sleep Brief, min
			IniRead, sa2, Config.ini, Sleep Brief, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

			send {enter}
			Log("ENTER", "Enter key sent")
		}

	IniRead, sa1, Config.ini, Sleep Brief, min
	IniRead, sa2, Config.ini, Sleep Brief, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

	IniRead, x1, Config.ini, Bank, xmin
	IniRead, x2, Config.ini, Bank, xmax
	IniRead, y1, Config.ini, Bank, ymin
	IniRead, y2, Config.ini, Bank, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CLICK", "Bank X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	IniRead, hkbank, Config.ini, Bank Preset, hotkey
	send {%hkbank%}
	Log("HOTKEY", "Bank Preset hotkey sent: " hkbank)

	IniRead, option, %LLARS_CONFIG_FILE%, Random Sleep, option
	if option = true
	{
		IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
		Random, RandomNumber, 1, 100

		IniRead, rs2, %LLARS_CONFIG_FILE%, Random Sleep, max
		if  (RandomNumber <= chance and PortableRemainingTime >= rs2)
		{
			++sleepcount
			GuiControl,, ScriptBlue, Random Sleep
			GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RandomSleepAmount)

			IniRead, rs1, %LLARS_CONFIG_FILE%, Random Sleep, min
			IniRead, rs2, %LLARS_CONFIG_FILE%, Random Sleep, max
			Random, RandomSleepAmount, %rs1%, %rs2%
			SetTimer, UpdateCountdown, 1000
			EndTime := A_TickCount + RandomSleepAmount
			totalSleepTime += RandomSleepAmount
			Sleep, RandomSleepAmount
			SetTimer, UpdateCountdown, Off
			GuiControl,,ScriptBlue, %scriptname%
			GuiControl,,State3, Running
		}
	}

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	IniRead, x1, Config.ini, Crafter, xmin
	IniRead, x2, Config.ini, Crafter, xmax
	IniRead, y1, Config.ini, Crafter, ymin
	IniRead, y2, Config.ini, Crafter, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CLICK", "Crafter X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

	send {space}
	Log("SPACE", "Space key sent")

	IniRead, sa1, Config.ini, Sleep Brief, min
	IniRead, sa2, Config.ini, Sleep Brief, max
	Random, SleepAmount, %sa1%, %sa2%
	IniRead, LLARS_RenewOption, Config.ini, Renew, option
	StringLower, LLARS_RenewOption, LLARS_RenewOption
	LLARS_RenewThisLoop := (LLARS_RenewOption = "true" && PortableRemainingTime <= 60000)
	if (LLARS_RenewThisLoop)
		LLARS_EstimatedSleep(SleepAmount)
	else
		LLARS_FinalSleep(SleepAmount)
	Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

	if (LLARS_RenewThisLoop)
	{
			IniRead, x1, Config.ini, Bank, xmin
			IniRead, x2, Config.ini, Bank, xmax
			IniRead, y1, Config.ini, Bank, ymin
			IniRead, y2, Config.ini, Bank, ymax
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			NaturalClick(x, y)
			Log("CLICK", "Bank X=" x " Y=" y)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, Renew, bank hotkey
			send {%hk%}
			Log("HOTKEY", "Bank Preset hotkey sent: " hk)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, Renew, toolbar hotkey
			send {%hk%}
			Log("HOTKEY", "Bank Preset hotkey sent: " hk)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			send {1}
			Log("KEY 1", "Key 1 sent")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")

			IniRead, portables, Config.ini, Renew, portables
			sendraw {%portables%}

			IniRead, sa1, Config.ini, Sleep Brief, min
			IniRead, sa2, Config.ini, Sleep Brief, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP", "Sleep Brief completed: " SleepAmount " ms")

			Send {enter}
			Log("ENTER", "Enter key sent")

			IniRead, portables, Config.ini, Renew, portables
			PortableRemainingTime := portables * 5 * 60 * 1000
			SetTimer, UpdateTime, 1000

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_FinalSleep(SleepAmount)
			Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")
		}

	LLARS_EndLoop()
}

; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

LLARS_RunComplete()

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

; Automatically searches upward for the LLARS Core folder.
#Include *i %A_ScriptDir%\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk

; Automatically searches upward for the LLARS label library.
#Include *i %A_ScriptDir%\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
