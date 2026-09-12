; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
SetBatchLines, -1

LLARS_SCRIPT_TYPE := "Timer"

if !LLARS_FrameworkAvailable()
	LLARS_FrameworkError()

LLARS_Initialize()

return

Start:

if (!LLARS_StartTimerRun())
	return

SetTimer, Countdown, 1000

IfWinNotActive, RuneScape
{
	WinActivate, RuneScape
}

SetTimer, CheckPixel, 100

return

; =====================================================================
; |     TIMER COUNTDOWN     -     TIMER COUNTDOWN                     |
; =====================================================================

Countdown:
RemainingTime := endTime - A_TickCount

if (RemainingTime > 0)
{
	GuiControl,, TimerCount, % LLARS_TimerRemainingText(RemainingTime)
	return
}

GuiControl,, TimerCount, Done
GuiControl,, State3, Done

SetTimer, Countdown, Off

Log("TIMER COMPLETE", "Timed run reached zero")
Goto, EndMsg

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

; ============================================================
; |     COLOR / PIXEL DETECTION CODE STARTS HERE             |
; ============================================================

CheckPixel:
if (!LLARS_RUNNING)
	return

IniRead, targetColor, Config.ini, Target Color, color
IniRead, x, Config.ini, Pixel Coordinate, x
IniRead, y, Config.ini, Pixel Coordinate, y

PixelGetColor, currentColor, %x%, %y%, RGB

if (currentColor = targetColor)
{
	; Stop detection while the action is being handled.
	SetTimer, CheckPixel, Off

	; ========================================================
	; |     WRITE THE ACTION FOR A COLOR MATCH HERE          |
	; ========================================================

	; Example randomized delay:
	IniRead, sa1, Config.ini, Sleep Timer, min
	IniRead, sa2, Config.ini, Sleep Timer, max
	Random, SleepAmount, %sa1%, %sa2%
	Sleep, %SleepAmount%

	; Example randomized click location:
	IniRead, x1, Config.ini, Action Location, xmin
	IniRead, x2, Config.ini, Action Location, xmax
	IniRead, y1, Config.ini, Action Location, ymin
	IniRead, y2, Config.ini, Action Location, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)

	; Wait until the watched pixel changes away from the target
	; before allowing another detection.
	SetTimer, ResetCheck, 100
}

return


ResetCheck:
if (!LLARS_RUNNING)
	return

IniRead, targetColor, Config.ini, Target Color, color
IniRead, x, Config.ini, Pixel Coordinate, x
IniRead, y, Config.ini, Pixel Coordinate, y

PixelGetColor, currentColor, %x%, %y%, RGB

if (currentColor != targetColor)
{
	SetTimer, ResetCheck, Off
	SetTimer, CheckPixel, 100
}

return

; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

EndMsg:

hours := Floor(timeToRunMinutes / 60)
minutes := Mod(timeToRunMinutes, 60)

SetTimer, Countdown, Off
SetTimer, CheckPixel, Off
SetTimer, ResetCheck, Off
LLARS_EndTimerRun()
Logout()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done

Log("COMPLETE", "Script completed normally | Total time: " hours "h " minutes "m")

SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nTotal time: %hours%h %minutes%m

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
