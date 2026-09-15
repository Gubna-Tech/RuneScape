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

if (!MultiColor_Setup())
{
	MsgBox, 48, LLARS Multi Color, No valid color mappings were found in Config.ini.`n`nEach type=color section needs both a coordinate= section name and an action= section name.
	return
}

if (!LLARS_StartTimerRun())
	return

SetTimer, Countdown, 1000

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
; |     MULTI PIXEL / MULTI COLOR LOGIC                           |
; ================================================================
; Every type=color section in Config.ini can declare:
;     coordinate=Pixel Coordinate Section Name
;     action=Action Location Section Name
;
; This lets one pixel watch several colors, several pixels watch their own
; colors, and each detected color trigger the action that belongs to it.
; Add more coordinate/color/action sections in Config.ini as needed; this
; template discovers the mappings automatically.

MultiColor_Setup()
{
	global MultiColorGroups

	MultiColorGroups := []
	groupIndexByCoordinate := {}

	IniRead, sectionList, Config.ini
	if (sectionList = "ERROR")
		return false

	Loop, Parse, sectionList, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		IniRead, sectionType, Config.ini, %section%, type, ERROR
		sectionType := Trim(sectionType)
		StringLower, sectionType, sectionType
		if (sectionType != "color")
			continue

		IniRead, coordinateSection, Config.ini, %section%, coordinate, ERROR
		IniRead, actionSection, Config.ini, %section%, action, ERROR
		coordinateSection := Trim(coordinateSection)
		actionSection := Trim(actionSection)

		if (coordinateSection = "" || coordinateSection = "ERROR")
			continue
		if (actionSection = "" || actionSection = "ERROR")
			continue

		if !groupIndexByCoordinate.HasKey(coordinateSection)
		{
			MultiColorGroups.Push({Coordinate: coordinateSection
				, Colors: []
				, Actions: {}
				, LastMatch: ""})
			groupIndexByCoordinate[coordinateSection] := MultiColorGroups.Length()
		}

		groupIndex := groupIndexByCoordinate[coordinateSection]
		groupInfo := MultiColorGroups[groupIndex]
		groupInfo.Colors.Push(section)
		groupInfo.Actions[section] := actionSection
	}

	return (MultiColorGroups.Length() > 0)
}


CheckPixel:
if !LLARS_RunActive()
	return

LLARS_SetStatus("Monitoring", "Color Targets")

MatchedTarget := MultiColor_FindTrigger()
if IsObject(MatchedTarget)
{
	; Handle one new target state at a time so script actions never overlap.
	SetTimer, CheckPixel, Off
	LLARS_SetStatus("Detected", MatchedTarget.Color)

	; Standard configured delay before the mapped action.
	LLARS_Sleep("Sleep Timer")

	if !LLARS_RunActive()
		return

	LLARS_SetStatus("Working", MatchedTarget.Action)
	LLARS_Click(MatchedTarget.Action)

	if LLARS_RunActive()
		SetTimer, CheckPixel, 100
}

return


MultiColor_FindTrigger()
{
	global MultiColorGroups

	if !IsObject(MultiColorGroups)
		return ""

	for groupIndex, groupInfo in MultiColorGroups
	{
		matchedColor := LLARS_PixelMatchesAny(groupInfo.Coordinate, groupInfo.Colors)

		; Leaving all configured target colors rearms this coordinate.
		if (matchedColor = "")
		{
			groupInfo.LastMatch := ""
			continue
		}

		; Do not repeatedly fire while the same target color stays visible.
		if (groupInfo.LastMatch = matchedColor)
			continue

		; A direct change from one configured color to another is a new state
		; and may intentionally trigger a different mapped action.
		groupInfo.LastMatch := matchedColor
		actionSection := groupInfo.Actions[matchedColor]
		if (actionSection = "")
			continue

		return {Coordinate: groupInfo.Coordinate
			, Color: matchedColor
			, Action: actionSection}
	}

	return ""
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
LLARS_TimerStopAll()
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
