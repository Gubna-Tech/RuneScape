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

prime := 0
bobprime := 0
powdertime := 0
bobtime := 0

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

	IniRead, option, Config.ini, Powder of burials, option
	StringLower, option, option

	If (option = "true")
	{
		If (prime = 0)
		{
			++prime

			IniRead, x1, Config.ini, Bank Coords, xmin
			IniRead, x2, Config.ini, Bank Coords, xmax
			IniRead, y1, Config.ini, Bank Coords, ymin
			IniRead, y2, Config.ini, Bank Coords, ymax
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			NaturalClick(x, y)
			Log("POWDER PRIME BANK", "X=" x " Y=" y)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hkbank, Config.ini, Powder of burials, bank preset
			Send, {%hkbank%}
			Log("POWDER BANK PRESET", "Hotkey=" hkbank)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, Powder of burials, hotkey
			Send, {%hk%}
			Log("POWDER HOTKEY", "Hotkey=" hk)

			powdertime := 1800000
			SetTimer, UpdateTime, 1000
			Log("POWDER TIMER", "Powder timer started: " powdertime " ms")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")
		}
	}
	Else
	{
		Log("POWDER OF BURIALS", "Option disabled")
	}

	IniRead, option, Config.ini, beast of burden, option
	StringLower, option, option

	If (option = "true")
	{
		If (bobprime = 0)
		{
			++bobprime

			IniRead, x1, Config.ini, Bank Coords, xmin
			IniRead, x2, Config.ini, Bank Coords, xmax
			IniRead, y1, Config.ini, Bank Coords, ymin
			IniRead, y2, Config.ini, Bank Coords, ymax
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			NaturalClick(x, y)
			Log("BOB PRIME BANK", "X=" x " Y=" y)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hkbank, Config.ini, beast of burden, bank preset
			Send, {%hkbank%}
			Log("BOB BANK PRESET", "Hotkey=" hkbank)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, beast of burden, restore pot hotkey
			Send, {%hk%}
			Log("BOB RESTORE POT", "Hotkey=" hk)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, beast of burden, bob hotkey
			Send, {%hk%}
			Log("BOB HOTKEY", "Hotkey=" hk)

			IniRead, bobtimer, Config.ini, beast of burden, bob timer
			bobtime := (bobtimer * 60 * 1000)
			SetTimer, updatebob, 1000
			Log("BOB TIMER", "Bob timer started: " bobtime " ms")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")
		}
	}
	Else
	{
		Log("BEAST OF BURDEN", "Option disabled")
	}

	IniRead, x1, Config.ini, Bank Coords, xmin
	IniRead, x2, Config.ini, Bank Coords, xmax
	IniRead, y1, Config.ini, Bank Coords, ymin
	IniRead, y2, Config.ini, Bank Coords, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("BANK", "X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

	IniRead, hkbank, Config.ini, Bank Preset, hotkey
	Send, {%hkbank%}
	Log("BANK PRESET", "Hotkey=" hkbank)

	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

	IniRead, option, %LLARS_CONFIG_FILE%, Random Sleep, option
	StringLower, option, option

	If (option = "true")
	{
		IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
		Random, RandomNumber, 1, 100

		If (RandomNumber <= chance)
		{
			++sleepcount

			IniRead, rs1, %LLARS_CONFIG_FILE%, Random Sleep, min
			IniRead, rs2, %LLARS_CONFIG_FILE%, Random Sleep, max
			Random, RandomSleepAmount, %rs1%, %rs2%
			GuiControl,, ScriptBlue, Random Sleep
			EndTime := A_TickCount + RandomSleepAmount
			totalSleepTime += RandomSleepAmount
			SetTimer, UpdateCountdown, 1000
			Log("RANDOM SLEEP", "Sleep=" RandomSleepAmount " ms | Chance=" chance "% | Roll=" RandomNumber)

			Sleep, %RandomSleepAmount%
			SetTimer, UpdateCountdown, Off
			GuiControl,, ScriptBlue, %scriptname%
			GuiControl,, State3, Running
			Log("RANDOM SLEEP COMPLETE", "Random sleep completed: " RandomSleepAmount " ms")
		}
		Else
		{
			Log("RANDOM SLEEP SKIPPED", "Chance=" chance "% | Roll=" RandomNumber)
		}
	}
	Else
	{
		Log("RANDOM SLEEP DISABLED", "Random Sleep option is disabled")
	}

	IniRead, hkdown, Config.ini, Skillbar Hotkey, hotkey
	Send, {%hkdown% down}
	Log("SKILLBAR DOWN", "Hotkey=" hkdown)

	IniRead, sap1, Config.ini, Sleep Prayer, min
	IniRead, sap2, Config.ini, Sleep Prayer, max
	Random, SleepAmount, %sap1%, %sap2%
	LLARS_EstimatedSleep(SleepAmount)
	Log("SLEEP PRAYER WAIT", "Sleep completed: " SleepAmount " ms")

	IniRead, hkup, Config.ini, Skillbar Hotkey, hotkey
	Send, {%hkup% up}
	Log("SKILLBAR UP", "Hotkey=" hkup)

	IniRead, option, Config.ini, beast of burden, option
	StringLower, option, option

	If (option = "true")
	{
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, hk, Config.ini, beast of burden, bob icon hotkey
		Send, {%hk%}
		Log("BOB ICON", "Hotkey=" hk)

		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

		IniRead, hkdown, Config.ini, Skillbar Hotkey, hotkey
		Send, {%hkdown% down}
		Log("SKILLBAR DOWN EXTRA", "Hotkey=" hkdown)

		IniRead, sap1, Config.ini, Sleep Prayer Extra, min
		IniRead, sap2, Config.ini, Sleep Prayer Extra, max
		Random, SleepAmountPrayer, %sap1%, %sap2%
		LLARS_EstimatedSleep(SleepAmountPrayer)
		Log("SLEEP PRAYER EXTRA WAIT", "Sleep completed: " SleepAmountPrayer " ms")

		IniRead, hkup, Config.ini, Skillbar Hotkey, hotkey
		Send, {%hkup% up}
		Log("SKILLBAR UP EXTRA", "Hotkey=" hkup)

		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		LLARS_EstimatedSleep(SleepAmount)
		Log("SLEEP BRIEF WAIT", "Sleep completed: " SleepAmount " ms")
	}
	Else
	{
		Log("BOB EXTRA", "Option disabled")
	}

	IniRead, option, Config.ini, beast of burden, option
	StringLower, option, option

	If (option = "true")
	{
		If (bobtime <= 60000)
		{
			IniRead, x1, Config.ini, Bank Coords, xmin
			IniRead, x2, Config.ini, Bank Coords, xmax
			IniRead, y1, Config.ini, Bank Coords, ymin
			IniRead, y2, Config.ini, Bank Coords, ymax
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			NaturalClick(x, y)
			Log("BOB TIMER BANK", "X=" x " Y=" y " | BobTime=" bobtime " ms")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hkbank, Config.ini, beast of burden, bank preset
			Send, {%hkbank%}
			Log("BOB BANK PRESET", "Hotkey=" hkbank)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, beast of burden, restore pot hotkey
			Send, {%hk%}
			Log("BOB RESTORE POT", "Hotkey=" hk)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, beast of burden, bob hotkey
			Send, {%hk%}
			Log("BOB HOTKEY", "Hotkey=" hk)

			IniRead, bobtimer, Config.ini, beast of burden, bob timer
			bobtime := (bobtimer * 60 * 1000)
			SetTimer, updatebob, 1000
			Log("BOB TIMER", "Bob timer restarted: " bobtime " ms")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")
		}
		Else
		{
			Log("BOB TIMER CHECK", "No refill needed | BobTime=" bobtime " ms")
		}
	}

	IniRead, option, Config.ini, Powder of burials, option
	StringLower, option, option

	If (option = "true")
	{
		If (powdertime <= 60000)
		{
			IniRead, x1, Config.ini, Bank Coords, xmin
			IniRead, x2, Config.ini, Bank Coords, xmax
			IniRead, y1, Config.ini, Bank Coords, ymin
			IniRead, y2, Config.ini, Bank Coords, ymax
			Random, x, %x1%, %x2%
			Random, y, %y1%, %y2%
			NaturalClick(x, y)
			Log("POWDER TIMER BANK", "X=" x " Y=" y " | PowderTime=" powdertime " ms")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hkbank, Config.ini, Powder of burials, bank preset
			Send, {%hkbank%}
			Log("POWDER BANK PRESET", "Hotkey=" hkbank)

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_EstimatedSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")

			IniRead, hk, Config.ini, Powder of burials, hotkey
			Send, {%hk%}
			Log("POWDER HOTKEY", "Hotkey=" hk)

			powdertime := 1800000
			SetTimer, UpdateTime, 1000
			Log("POWDER TIMER", "Powder timer restarted: " powdertime " ms")

			IniRead, sa1, Config.ini, Sleep Short, min
			IniRead, sa2, Config.ini, Sleep Short, max
			Random, SleepAmount, %sa1%, %sa2%
			LLARS_FinalSleep(SleepAmount)
			Log("SLEEP SHORT WAIT", "Sleep completed: " SleepAmount " ms")
		}
		Else
		{
			Log("POWDER TIMER CHECK", "No refill needed | PowderTime=" powdertime " ms")
		}
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
