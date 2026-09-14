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

MultiColor_Setup()
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


; ================================================================
; |     MULTI COLOR / MULTI LOCATION LOGIC                      |
; ================================================================
; The watched pixel may match any color section listed below.
; Each completed trigger clicks the next location in sequence.
; Add/remove section names here when expanding the template.

MultiColor_Setup()
{
	global MultiColorColorSections, MultiColorLocationSections
	global MultiColorLocationIndex

	MultiColorColorSections := ["Target Color One", "Target Color Two"]
	MultiColorLocationSections := ["Action Location One", "Action Location Two"]
	MultiColorLocationIndex := 1
}


CheckPixel:
if (!LLARS_RUNNING)
	return

; Pixel coordinates are client-relative. Do not inspect another app if
; the user has switched away from RuneScape.
if !LLARS_IsRuneScapeActive()
	return

MatchedColorSection := MultiColor_FindMatchedColor()
if (MatchedColorSection != "")
{
	; Stop detection while this trigger is handled.
	SetTimer, CheckPixel, Off
	LLARS_SetStatus("Waiting", MatchedColorSection)

	; Standard configured delay before the action.
	LLARS_Sleep("Sleep Timer")

	if (!LLARS_RUNNING)
		return

	; Eternal Tree style location switching: click the current location,
	; then advance so the next trigger uses the next configured location.
	MultiColor_ClickNextLocation()

	; Do not permit another trigger until the watched pixel leaves every
	; configured target color.
	SetTimer, ResetCheck, 100
}

return


ResetCheck:
if (!LLARS_RUNNING)
	return

if !LLARS_IsRuneScapeActive()
	return

if (MultiColor_FindMatchedColor() = "")
{
	SetTimer, ResetCheck, Off
	SetTimer, CheckPixel, 100
	LLARS_SetStatus("Running")
}

return


MultiColor_FindMatchedColor()
{
	global MultiColorColorSections

	for index, colorSection in MultiColorColorSections
	{
		if LLARS_PixelMatches("Pixel Coordinate", colorSection)
			return colorSection
	}

	return ""
}


MultiColor_ClickNextLocation()
{
	global MultiColorLocationSections, MultiColorLocationIndex

	if !IsObject(MultiColorLocationSections)
		return false

	locationCount := MultiColorLocationSections.Length()
	if (locationCount < 1)
		return false

	if (MultiColorLocationIndex < 1 || MultiColorLocationIndex > locationCount)
		MultiColorLocationIndex := 1

	locationSection := MultiColorLocationSections[MultiColorLocationIndex]
	LLARS_SetStatus("Running", locationSection)

	if !LLARS_Click(locationSection)
		return false

	MultiColorLocationIndex++
	if (MultiColorLocationIndex > locationCount)
		MultiColorLocationIndex := 1

	return true
}

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
