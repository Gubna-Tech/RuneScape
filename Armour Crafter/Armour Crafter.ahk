; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
SetBatchLines, -1

; =========================================================================
; |     LOGGING START     -     LOGGING START     -     LOGGING START     |
; =========================================================================

; Starts the logging session before any other script initialization so
; startup events and errors can be recorded from the beginning.
LastLogTick := 0
SetLLARSHOTKEYS("On")
StartLogSession()
Log("STARTUP", "Script started")

; ===============================================================================
; |     DUPLICATE CHECK     -     DUPLICATE CHECK     -     DUPLICATE CHECK     |
; ===============================================================================

; Enables detection of hidden windows and closes any existing LLARS
; instance so only one copy of the script remains active.
DetectHiddenWindows, On
Log("DUPLICATE CHECK", "Checking for other LLARS windows")
CloseOtherLLARS()

; ================================================================
; |     FILE CHECK     -     FILE CHECK     -     FILE CHECK     |
; ================================================================

; Verifies that the script is not being run directly from a compressed
; archive and that both required configuration files are present.
IsArchivePath := RegExMatch(A_ScriptDir, "\.(zip|rar|7z)(\\|$)")

if (IsArchivePath)
{
	Menu, Tray, NoIcon
	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5,ERROR
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, Files Are Zipped
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, cBlack
	Gui Error: Add, Text, Center w220 x5, Please extract all files from the zipped (.zip) folder:
	Gui Error: Font, underline s12
	Gui Error: Add, Text, cGreen center w220 x5, RuneScape-main.zip
	Gui Error: Font, s11 norm Bold c0x152039
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Add, Text, Center w220 x5,Created by Gubna
	Gui Error: Add, Button, gDiscordError w150 x40 center,Discord
	Gui Error: add, button, gCloseError w150 x40 center,Close Error
	WinSet, ExStyle, ^0x80
	Gui Error: -caption
	Gui Error: Show, center w230, File Error
	return
}

; Checks for the main script configuration before continuing.
if !FileExist("Config.ini")
{
	Menu, Tray, NoIcon
	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5,ERROR
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, Config.ini not found
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, cBlack
	Gui Error: Add, Text, Center w220 x5, Please ensure that you have all the original files from:
	Gui Error: Font, underline s12
	Gui Error: Add, Text, cBlue gGitLink center w220 x5, Gubna-Tech Github
	Gui Error: Font, s11 norm Bold c0x152039
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Add, Text, Center w220 x5,Created by Gubna
	Gui Error: Add, Button, gDiscordError w150 x40 center,Discord
	Gui Error: add, button, gCloseError w150 x40 center,Close Error
	WinSet, ExStyle, ^0x80
	Gui Error: -caption
	Gui Error: Show, center w230, Config Error
	return
}
Log("CONFIG LOADED", "Config.ini loaded successfully")

; Checks for the LLARS-specific configuration file.
if !FileExist("LLARS Config.ini")
{
	Menu, Tray, NoIcon
	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5,ERROR
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, LLARS Config.ini not found
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, cBlack
	Gui Error: Add, Text, Center w220 x5, Please ensure that you have all the original files from:
	Gui Error: Font, underline s12
	Gui Error: Add, Text, cBlue gGitLink center w220 x5, Gubna-Tech Github
	Gui Error: Font, s11 norm Bold c0x152039
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Add, Text, Center w220 x5,Created by Gubna
	Gui Error: Add, Button, gDiscordError w150 x40 center,Discord
	Gui Error: add, button, gCloseError w150 x40 center,Close Error
	WinSet, ExStyle, ^0x80
	Gui Error: -caption
	Gui Error: Show, center w230, Config Error
	return
}
Log("LLARS CONFIG LOADED", "LLARS Config.ini loaded successfully")

IniRead, value, LLARS Config.ini, Transparent, value

; ======================================================================
; |     SCRIPT SETUP     -     SCRIPT SETUP     -     SCRIPT SETUP     |
; ======================================================================

; Establishes coordinate modes, counters, the configuration refresh
; timer, the script display name, and the initial LLARS hotkeys.
CoordMode, Pixel, Client
CoordMode, Mouse, Client

coordcount = 0
frcount = 0
LastClickTime := 0
clickspot := 1

SetTimer, CheckLLARSConfig, 250

scriptname := regexreplace(A_scriptname,"\..*","")

; =====================================================================================
; |     MAIN GUI CREATION     -     MAIN GUI CREATION     -     MAIN GUI CREATION     |
; =====================================================================================

; Creates the main LLARS control window, including the start/information
; controls, status indicators, timer display, transparency, saved position,
; and optional LLARS icon.
Gui +LastFound +OwnDialogs +AlwaysOnTop
Gui, Font, s11
Gui, font, bold
Gui, Add, Button, x5 y5 w100 h25 gStart , Start
Gui, Add, Button, x115 y5 w100 h25 gInfo, Information
Gui, Add, Button, x5 y35 w210 h25 gCombo, Color/Coordinate/Hotkey
Gui, Add, Button, x35 y115 w150 h25 gExitb , Exit LLARS
Gui, Font, cBlue
Gui, Add, Text, x135 y65 w70 h25 vState3
Gui, Add, Text, x8 y65 w125 h25 vScriptBlue
Gui, Add, Text, x135 y90 w100 h25 vCounter
Gui, Add, Text, x8 y90 w125 h25, Total Run Count
GuiControl,,TimerLabel, Remaining:
GuiControl,,TimerCount, ** OFF **
Gui, Font, cRed
Gui, Add, Text, x135 y65 w70 h25 vState2
Gui, Add, Text, x8 y65 w125 h25 vScriptRed
GuiControl,,State2, ** OFF **
Gui, Add, Text, x8 y65 w125 h25, %scriptname%
if FileExist("LLARS Logo.ico")
{
	Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
}
WinSet, Transparent, %value%
Gui, Show,w220 h150, LLARS

; Restores the main LLARS GUI to its previously saved screen position.
IniRead, x, LLARS Config.ini, GUI POS, guix
IniRead, y, LLARS Config.ini, GUI POS, guiy
WinMove, LLARS,, %X%, %y%

; Loads the custom LLARS icon into the main GUI when available.
if FileExist("LLARS Logo.ico")
{
	hIcon := DllCall("LoadImage", uint, 0, str, "LLARS Logo.ico"
   	, uint, 1, int, 0, int, 0, uint, 0x10)
	SendMessage, 0x80, 0, hIcon
	SendMessage, 0x80, 1, hIcon
}

; ============================================================================
; |     LOGGING SYSTEM     -     LOGGING SYSTEM     -     LOGGING SYSTEM     |
; ============================================================================

; Checks LLARS Config.ini to determine if logging is enabled.
LoggingCheck()
{
	IniRead, LoggingOption, %A_ScriptDir%\LLARS Config.ini, Logging, option, disabled
	
	if (LoggingOption = "enabled")
		return true
	
	return false
}

; Centralized logging functions used throughout the script to record
; events, timestamps, session state, and important actions.
Log(Event, Details := "")
{
	global LogCount
	
	if !LoggingCheck()
		return
	
	FormatTime, LogTime,, yyyy-MM-dd HH:mm:ss
	
	LogCount++
	
	IniWrite, %LogCount%, %A_ScriptDir%\log.ini, Log, Count
	
	LogEntry := "[Log" LogCount "]`r`n"
	LogEntry .= "Time=" LogTime "`r`n"
	LogEntry .= "Event=" Event "`r`n"
	LogEntry .= "Details=" Details "`r`n`r`n"
	
	FileAppend, %LogEntry%, %A_ScriptDir%\log.ini
}

; Initializes a new logging session, continuing the log count from
; the previous session and marking the current session as running.
StartLogSession()
{
	global LogCount
	
	if !LoggingCheck()
		return
	
	IniRead, LogCount, %A_ScriptDir%\log.ini, Log, Count, 0
	
	FormatTime, StartTime,, yyyy-MM-dd HH:mm:ss
	
	SessionBarrier =
    (
`r`n============================================================
NEW SESSION - %StartTime%
============================================================`r`n
    )
	
	FileAppend, %SessionBarrier%, %A_ScriptDir%\log.ini
	
	IniWrite, RUNNING, %A_ScriptDir%\log.ini, Session, Status
	IniWrite, %StartTime%, %A_ScriptDir%\log.ini, Session, StartTime
}

; Marks the current logging session as stopped and records the
; reason and ending timestamp.
EndLogSession(Reason := "Normal Exit")
{
	if !LoggingCheck()
		return
	
	FormatTime, EndTime,, yyyy-MM-dd HH:mm:ss
	
	IniWrite, STOPPED, %A_ScriptDir%\log.ini, Session, Status
	IniWrite, %EndTime%, %A_ScriptDir%\log.ini, Session, EndTime
	
	Log("STOP", Reason)
}

; ==================================================================================
; |     FUNCTION STORAGE     -     FUNCTION STORAGE     -     FUNCTION STORAGE     |
; ==================================================================================

; Registers Windows message handlers used to keep the custom LLARS
; windows movable and to monitor window position changes.
OnMessage(0x0047, "WM_WINDOWPOSCHANGED")
OnMessage(0x0201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN() {
	If (A_Gui)
		PostMessage, 0xA1, 2
}
return

WM_WINDOWPOSCHANGED(hwnd, uMsg, wParam, lParam) {
	CheckPOS(hwnd)
}
return

; Validates both configuration files and stops on the first blank
; required configuration value that is found.
ConfigError()
{
	if (CheckConfigFile("Config.ini"))
		return
	
	if (CheckConfigFile("LLARS Config.ini"))
		return
}

; Displays the configuration error, opens the affected file, logs
; the missing value, and reloads the script after the user fixes it.
ConfigErrorMessage(file, section, key)
{
	Run, %A_ScriptDir%\%file%
	
	GuiControl,, ScriptRed, CONFIG
	GuiControl,, State2, ERROR
	
	MsgBox, 4112, Config Error, Please enter a value for:`n`n[%section%]`n%key%
	
	Log("CONFIG ERROR", file " | [" section "] " key " is blank")
	
	Reload
}

CheckConfigFile(file)
{
	IniRead, sections, %file%
	
	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		
		if (section = "")
			continue
		
		; Remove brackets if returned by IniRead.
		StringReplace, section, section, [, , All
		StringReplace, section, section, ], , All
		section := Trim(section)
		
		sectionType := GetConfigType(file, section)
		
		; No type=, or unsupported type=.
		; Do not validate this section.
		if (sectionType = "")
			continue
		
		IniRead, option, %file%, %section%, option, true
		option := Trim(option)
		StringLower, option, option
		
		; Disabled sections do not need their values checked.
		if (option = "false" || option = "disabled")
			continue
		
		IniRead, keys, %file%, %section%
		
		Loop, Parse, keys, `n, `r
		{
			line := Trim(A_LoopField)
			
			if (line = "")
				continue
			
			; Ignore comments.
			if (SubStr(line, 1, 1) = ";")
				continue
			
			StringSplit, part, line, =, 2
			
			key := Trim(part1)
			value := Trim(part2)
			
			; Metadata fields are not values that need validation.
			if (key = "option" || key = "type")
				continue
			
			; Blank value = configuration error.
			if (value = "")
			{
				ConfigErrorMessage(file, section, key)
				return true
			}
		}
	}
	
	return false
}

GetConfigType(file, section)
{
	section := Trim(section)
	
	StringReplace, section, section, [, , All
	StringReplace, section, section, ], , All
	section := Trim(section)
	
	IniRead, sectionType, %file%, %section%, type, ERROR
	
	if (sectionType = "ERROR")
		return ""
	
	sectionType := Trim(sectionType)
	StringLower, sectionType, sectionType
	
	if (sectionType = "color")
		return "color"
	
	if (sectionType = "coordinate")
		return "coordinate"
	
	if (sectionType = "hotkey")
		return "hotkey"
	
	return ""
}

; Keeps supported LLARS windows inside the visible screen area when
; their position changes or they are moved partially off-screen.
CheckPOS(hwnd)
{
	WinGetClass, winClass, ahk_id %hwnd%
	
	if (winClass != "AutoHotkeyGUI")
		return
	
	WinGetPos, GUIx, GUIy, GUIw, GUIh, ahk_id %hwnd%
	
	xmin := GUIx
	xmax := GUIw + GUIx
	ymin := GUIy
	ymax := GUIh + GUIy
	xadj := A_ScreenWidth - GUIw
	yadj := A_ScreenHeight - GUIh
	
	X := GUIx
	Y := GUIy
	
	if (xmin < 0)
		X := 0
	if (ymin < 0)
		Y := 0
	if (xmax > A_ScreenWidth)
		X := xadj
	if (ymax > A_ScreenHeight)
		Y := yadj
	
	if (X != GUIx || Y != GUIy)
		WinMove, ahk_id %hwnd%,, X, Y
}

; Finds existing LLARS AutoHotkey windows and closes them
; to prevent multiple active LLARS instances from running simultaneously.
CloseOtherLLARS()
{
	WinGet, hWndList, List, LLARS
	WinGet, hWndList2, List, Script Selector
	
	Loop, %hWndList%
	{
		hWnd := hWndList%A_Index%
		
		WinGet, processName, ProcessName, ahk_id %hWnd%
		
		if (processName = "AutoHotkey.exe" || processName = "AutoHotkeyU64.exe" || processName = "AutoHotkeyU32.exe")
		{
			Log("DUPLICATE CLOSE", "Closing existing LLARS AutoHotkey window")
			WinClose, % "ahk_id " hWnd
		}
	}
	
	Loop, %hWndList2%
	{
		hWnd := hWndList2%A_Index%
		
		WinGet, processName, ProcessName, ahk_id %hWnd%
		
		if (processName = "AutoHotkey.exe" || processName = "AutoHotkeyU64.exe" || processName = "AutoHotkeyU32.exe")
		{
			Log("DUPLICATE CLOSE", "Closing existing Script Selector AutoHotkey window")
			WinClose, % "ahk_id " hWnd
		}
	}
}

; Set this to false when the script is in its normal/idle state.
; Set it to true when the timed script is running.
LLARS_RUNNING := false

SetLLARSHOTKEYS(state := "On", startOnly := false)
{
	global LLARS_lhk1
	global LLARS_lhk2
	global LLARS_lhk3
	global LLARS_lhk4
	global LLARS_RUNNING
	
	IniRead, lhk1, LLARS Config.ini, Start Hotkey, hotkey
	
	; Disable the previously configured Start hotkey if it changed.
	if (LLARS_lhk1 != "" && LLARS_lhk1 != lhk1)
		Hotkey, %LLARS_lhk1%, Start, Off
	
	; Save the current Start hotkey.
	LLARS_lhk1 := lhk1
	
	; Enable/disable the current Start hotkey.
	if (lhk1 != "")
	{
		if (state = "On")
			Hotkey, %lhk1%, Start, On
		else
			Hotkey, %lhk1%, Start, Off
	}
	
	; Only update the Start hotkey when requested.
	if (startOnly)
		return
	
	IniRead, lhk2, LLARS Config.ini, Information Hotkey, hotkey
	IniRead, lhk3, LLARS Config.ini, color/coordinate/hotkey Hotkey, hotkey
	IniRead, lhk4, LLARS Config.ini, exit Hotkey, hotkey
	
	; Disable the previously configured Information/Pause hotkey if it changed.
	if (LLARS_lhk2 != "" && LLARS_lhk2 != lhk2)
	{
		Hotkey, %LLARS_lhk2%, Info, Off
		Hotkey, %LLARS_lhk2%, pauseb, Off
	}
	
	; Save the current Information/Pause hotkey.
	LLARS_lhk2 := lhk2
	
	if (lhk2 != "")
	{
		if (state = "On")
		{
			if (LLARS_RUNNING)
			{
				Hotkey, %lhk2%, Info, Off
				Hotkey, %lhk2%, pauseb, On
			}
			else
			{
				Hotkey, %lhk2%, pauseb, Off
				Hotkey, %lhk2%, Info, On
			}
		}
		else
		{
			Hotkey, %lhk2%, Info, Off
			Hotkey, %lhk2%, pauseb, Off
		}
	}
	
	; Disable the previously configured Combo/Resume hotkey if it changed.
	if (LLARS_lhk3 != "" && LLARS_lhk3 != lhk3)
	{
		Hotkey, %LLARS_lhk3%, Combo, Off
		Hotkey, %LLARS_lhk3%, resumeb, Off
	}
	
	; Save the current Combo/Resume hotkey.
	LLARS_lhk3 := lhk3
	
	if (lhk3 != "")
	{
		if (state = "On")
		{
			if (LLARS_RUNNING)
			{
				Hotkey, %lhk3%, Combo, Off
				Hotkey, %lhk3%, resumeb, On
			}
			else
			{
				Hotkey, %lhk3%, resumeb, Off
				Hotkey, %lhk3%, Combo, On
			}
		}
		else
		{
			Hotkey, %lhk3%, Combo, Off
			Hotkey, %lhk3%, resumeb, Off
		}
	}
	
	; Disable the previously configured Exit hotkey if it changed.
	if (LLARS_lhk4 != "" && LLARS_lhk4 != lhk4)
		Hotkey, %LLARS_lhk4%, exitb, Off
	
	; Save the current Exit hotkey.
	LLARS_lhk4 := lhk4
	
	if (lhk4 != "")
	{
		if (state = "On")
			Hotkey, %lhk4%, exitb, On
		else
			Hotkey, %lhk4%, exitb, Off
	}
}

; Temporarily disables all LLARS control hotkeys.
DisableHotkey()
{
	Control, Disable,, start
	SetLLARSHOTKEYS("Off")
}

; Re-enables all LLARS control hotkeys.
EnableHotkey()
{
	Control, Enable,, start
	SetLLARSHOTKEYS("On")
}

; Disables only the Start control while the timed script is running.
DisableButton()
{
	Control, Disable,, start
	SetLLARSHOTKEYS("Off", true)
}

; Re-enables the Start control after the timed run is finished.
EnableButton()
{
	Control, Enable,, start
	SetLLARSHOTKEYS("On", true)
}

CheckLLARSConfig:
SetLLARSHOTKEYS()
return

; Provides Escape-key shortcuts for closing the various secondary
; LLARS GUIs and returning to the main window.
~Esc::
IfWinActive, Coordinates
{
	EnableHotkey()
	GoSub, close
}
Else IfWinActive, Timer
{
	EnableHotkey()
	Gui 5: Destroy
	Gui 1: Show
}
Else IfWinActive, Information
{
	EnableHotkey()
	GoSub, closeinfo
}
Else IfWinActive, Combo
{
	EnableHotkey()
	GoSub, closecombo
}
Else IfWinActive, Colors
{
	EnableHotkey()
	GoSub, close1
}
Else IfWinActive, Hotkeys
{
	EnableHotkey()
	GoSub, close2
}
Return

NaturalClick(x, y)
{
	MouseGetPos, startX, startY
	
	dx := x - startX
	dy := y - startY
	distance := Sqrt((dx * dx) + (dy * dy))
	
	if (distance <= 2)
	{
		Random, pause, 50, 120
		Sleep, %pause%
		Click
		return
	}
	
	Random, speed, 2500, 3500
	
	duration := (distance / speed) * 1000
	
	if (duration < 180)
		duration := 180
	
	if (duration > 900)
		duration := 900
	
	steps := Round(distance / 6)
	
	if (steps < 15)
		steps := 15
	
	if (steps > 100)
		steps := 100
	
	rawSteps := Round(distance / 3)
	
	if (rawSteps < 60)
		rawSteps := 60
	
	if (rawSteps > 300)
		rawSteps := 300
	
	perpX := -dy / distance
	perpY := dx / distance

	curveLimit := distance * 0.14
	
	if (curveLimit < 5)
		curveLimit := 5
	
	if (curveLimit > 85)
		curveLimit := 85
	
	Random, curveBase, -100, 100
	curveBase := curveBase * curveLimit / 100
	
	Random, curveVariation1, -25, 25
	Random, curveVariation2, -25, 25
	
	curveAmount1 := curveBase + (curveLimit * curveVariation1 / 100)
	curveAmount2 := curveBase + (curveLimit * curveVariation2 / 100)
	
	if (curveAmount1 > curveLimit)
		curveAmount1 := curveLimit
	
	if (curveAmount1 < -curveLimit)
		curveAmount1 := -curveLimit
	
	if (curveAmount2 > curveLimit)
		curveAmount2 := curveLimit
	
	if (curveAmount2 < -curveLimit)
		curveAmount2 := -curveLimit
	
	Random, cp1Percent, 25, 38
	Random, cp2Percent, 62, 75
	
	cp1X := startX + (dx * cp1Percent / 100)
	cp1Y := startY + (dy * cp1Percent / 100)
	
	cp2X := startX + (dx * cp2Percent / 100)
	cp2Y := startY + (dy * cp2Percent / 100)
	
	cp1X += perpX * curveAmount1
	cp1Y += perpY * curveAmount1
	
	cp2X += perpX * curveAmount2
	cp2Y += perpY * curveAmount2
	
	Random, seedX, 1, 100000
	Random, seedY, 1, 100000
	
	noiseAmount := distance * 0.012
	
	if (noiseAmount < 0.75)
		noiseAmount := 0.75
	
	if (noiseAmount > 6)
		noiseAmount := 6

	points := []
	lengths := []
	
	totalLength := 0
	
	previousX := startX
	previousY := startY
	
	points.Push({x:startX, y:startY})
	lengths.Push(0)
	
	previousNoise := 0
	
	Loop, %rawSteps%
	{
		t := A_Index / rawSteps
		
		ease := t
		
		inv := 1 - ease
		
		currentX := (inv * inv * inv * startX)
		currentX += (3 * inv * inv * ease * cp1X)
		currentX += (3 * inv * ease * ease * cp2X)
		currentX += (ease * ease * ease * x)
		
		currentY := (inv * inv * inv * startY)
		currentY += (3 * inv * inv * ease * cp1Y)
		currentY += (3 * inv * ease * ease * cp2Y)
		currentY += (ease * ease * ease * y)
		
		nx := NaturalNoise(seedX, t)
		ny := NaturalNoise(seedY, t + 13.731)
		
		noiseFade := Sin(t * 3.14159265)
		
		if (t > 0.80)
		{
			fade := (1 - t) / 0.20
			
			if (fade < 0)
				fade := 0
			
			noiseFade *= fade
		}
		
		rawNoise := ((nx + ny) * 0.5) * noiseAmount * noiseFade
		
		smoothedNoise := (previousNoise * 0.70) + (rawNoise * 0.30)
		
		previousNoise := smoothedNoise
		
		currentX += perpX * smoothedNoise
		currentY += perpY * smoothedNoise
		
		segmentDX := currentX - previousX
		segmentDY := currentY - previousY
		
		segmentLength := Sqrt((segmentDX * segmentDX) + (segmentDY * segmentDY))
		
		totalLength += segmentLength
		
		points.Push({x:currentX, y:currentY})
		lengths.Push(totalLength)
		
		previousX := currentX
		previousY := currentY
	}
	
	startTime := A_TickCount
	
	searchIndex := 2
	
	previousX := startX
	previousY := startY
	
	Loop, %steps%
	{
		t := A_Index / steps
		
		timingT := t * t * (3 - (2 * t))
		
		targetLength := totalLength * timingT
		
		while (searchIndex < lengths.Length() && lengths[searchIndex] < targetLength)
			searchIndex++
		
		if (searchIndex > lengths.Length())
			searchIndex := lengths.Length()
		
		prevIndex := searchIndex - 1
		
		if (prevIndex < 1)
			prevIndex := 1
		
		prevLength := lengths[prevIndex]
		nextLength := lengths[searchIndex]
		
		lengthRange := nextLength - prevLength
		
		if (lengthRange <= 0)
		{
			blend := 0
		}
		else
		{
			blend := (targetLength - prevLength) / lengthRange
		}
		
		point1 := points[prevIndex]
		point2 := points[searchIndex]
		
		currentX := point1.x + ((point2.x - point1.x) * blend)
		currentY := point1.y + ((point2.y - point1.y) * blend)
		
		currentX := Round(currentX)
		currentY := Round(currentY)
		
		if (currentX != previousX || currentY != previousY)
		{
			MouseMove, %currentX%, %currentY%, 0
			
			previousX := currentX
			previousY := currentY
		}
	
		targetElapsed := Round(duration * t)
		actualElapsed := A_TickCount - startTime
		
		delay := targetElapsed - actualElapsed
		
		if (delay < 1)
			delay := 1
		
		if (delay > 20)
			delay := 20
		
		Sleep, %delay%
	}

	MouseMove, %x%, %y%, 0

	Random, pause, 50, 120
	Sleep, %pause%
	
	Click
}

NaturalNoise(seed, t)
{
	n1 := NaturalNoiseLayer(seed, t, 1.0)
	n2 := NaturalNoiseLayer(seed + 91.73, t, 2.2) * 0.45
	n3 := NaturalNoiseLayer(seed + 217.41, t, 4.5) * 0.20
	
	value := n1 + n2 + n3
	
	if (value > 1)
		value := 1
	
	if (value < -1)
		value := -1
	
	return value
}

NaturalNoiseLayer(seed, t, frequency)
{
	position := (seed * 0.01) + (t * frequency * 5)
	
	segment := Floor(position)
	f := position - segment
	
	smooth := f * f * (3 - (2 * f))
	
	v1 := NaturalHash(segment)
	v2 := NaturalHash(segment + 1)
	
	return v1 + ((v2 - v1) * smooth)
}

NaturalHash(value)
{
	value := Mod(value, 2147483647)
	
	if (value < 0)
		value += 2147483647
	
	value := Mod((value * 48271), 2147483647)
	
	if (value < 0)
		value += 2147483647
	
	return (value / 1073741823.5) - 1
}

; ===================================================================================================================
; |     COLOR/COORDINATE/HOTKEY GUI     -     COLOR/COORDINATE/HOTKEY GUI     -     COLOR/COORDINATE/HOTKEY GUI     |
; ===================================================================================================================

; Displays the secondary menu used to choose between editing colors,
; coordinates, or hotkeys.
Combo:
Gui 1: Hide
DisableHotkey()

Menu, Tray, NoIcon
Gui Combo: +LastFound +OwnDialogs +AlwaysOnTop
Gui Combo: Font, s12 norm bold
Gui Combo: Add, Button, x5 y5 w125 h25 gColor , Colors
Gui Combo: Add, Button, x5 y35 w125 h25 gCoordinates , Coordinates
Gui Combo: Add, Button, x5 y65 w125 h25 gHotkey , Hotkeys
Gui Combo: add, button, x5 y95 w125 h25 gCloseCombo , Close
WinSet, ExStyle, ^0x80
Gui Combo: -caption
Gui Combo: Show, center w135, Combo
return

; Returns from the Combo menu to the main LLARS window.
closecombo:
Gui Combo: Destroy
Gui 1: Show
return

; ===============================================================================
; |     COORDINATES GUI     -     COORDINATES GUI     -     COORDINATES GUI     |
; ===============================================================================

; Builds the coordinate editor dynamically by checking the type assigned
; to each configuration section. Sections marked type=coordinate are
; automatically included without requiring their names in the script.
Coordinates:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy

Gui 1: Hide
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop
Gui 2: Font, s11 Bold
DisableHotkey()

IniRead, allContents, Config.ini
IniRead, llarsContents, LLARS Config.ini

sectionList := " ***** Make a Selection ***** | "
configCoordinatesFound := false

; Add a section header for Config.ini coordinates.
sectionList .= "| ---- Script Coordinates ---- "

; Add sections from Config.ini that are explicitly categorized
; as coordinates.
Loop, Parse, allContents, `n, `r
{
	currentSection := Trim(A_LoopField)
	
	if (currentSection = "")
		continue
	
	StringReplace, currentSection, currentSection, [, , All
	StringReplace, currentSection, currentSection, ], , All
	currentSection := Trim(currentSection)
	
	if (GetConfigType("Config.ini", currentSection) = "coordinate")
	{
		sectionList .= "|" currentSection
		configCoordinatesFound := true
	}
}

; Add a blank space between Config.ini and LLARS Config.ini coordinates.
if (configCoordinatesFound)
	sectionList .= "| "

; Add a section header for LLARS Config.ini coordinates.
sectionList .= "| ---- LLARS Coordinates ---- "

; Add sections from LLARS Config.ini that are explicitly categorized
; as coordinates.
Loop, Parse, llarsContents, `n, `r
{
	currentSection := Trim(A_LoopField)
	
	if (currentSection = "")
		continue
	
	StringReplace, currentSection, currentSection, [, , All
	StringReplace, currentSection, currentSection, ], , All
	currentSection := Trim(currentSection)
	
	if (GetConfigType("LLARS Config.ini", currentSection) = "coordinate")
		sectionList .= "|" currentSection
}

Gui, 2: Add, DropDownList, w230 vSectionList Choose1 gDropDownChanged, % sectionList
Gui, 2: Add, Button, x52 w150 gClose, Close Coordinates

Gui, 2: Show, w250 h45 Center, Coordinates
Gui 2: -Caption
WinSet, ExStyle, ^0x80
WinSet, Transparent, %value%

return

; Closes the coordinate editor and returns to the main LLARS window.
Close:
Gui 2: Destroy
Gui 1: Show
EnableHotkey()
return

; Starts coordinate selection after a valid configuration section
; has been chosen from the dropdown.
DropDownChanged:
GuiControlGet, selectedSection,, SectionList

if (selectedSection != " ***** Make a Selection ***** " && selectedSection != " " && selectedSection != " ---- Script Coordinates ---- " && selectedSection != " ---- LLARS Coordinates ---- ")
	GoSub, ButtonClicked

return

; Handles the two coordinate-selection modes:
; "pixel coordinate" captures one point, while all other sections
; capture a top-left and bottom-right corner to form a rectangle.
ButtonClicked:
if (selectedSection = "pixel coordinate")
{
    Gui, 2: Hide

    WinActivate, RuneScape

    x := ""
    y := ""

    ButtonText := selectedSection

    SetTimer, CheckClicksPixel, 10

    Gui 11u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
    Gui 11u: Color, Red
    Gui 11u: Font, cRed
    Gui 11u: Font, s16 bold
    Gui 11u: Add, Text, valertlabel center,----Right-click the pixel for [ %selectedSection% ]`n----
    WinSet, ExStyle, ^0x80
    Gui 11u: -caption
    Gui 11u: Show, NoActivate xcenter y0, BottomGUI

    Gui 11: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
    Gui 11: Font, s16 bold
    Gui 11: Add, Text, vTone center,Right-click the pixel for [ %selectedSection% ]
    WinSet, ExStyle, ^0x80
    Gui 11: -caption
    Gui 11: Show, NoActivate xcenter y9999, TopGUI

    wingetpos,,,,bottomH, BottomGUI
    wingetpos,,,,topH, TopGUI

    topPOS := (bottomH - topH) / 2

    Gui, TopGUI: +LabelTopGUI
    WinMove, TopGUI,, , %topPOS%
}
else
{
    Gui, 2: Hide

    WinActivate, RuneScape

    ClickCount := 0
    xmin := ""
    ymin := ""
    xmax := ""
    ymax := ""

    ButtonText := selectedSection

    SetTimer, CheckClicks, 10

    Gui 11u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
    Gui 11u: Color, Red
    Gui 11u: Font, cRed
    Gui 11u: Font, s16 bold
    Gui 11u: Add, Text, valertlabel center,----Right-click the top-left corner for [ %selectedSection% ]`n----
    WinSet, ExStyle, ^0x80
    Gui 11u: -caption
    Gui 11u: Show, NoActivate xcenter y0, BottomGUI

    Gui 11: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
    Gui 11: Font, s16 bold
    Gui 11: Add, Text, vTone center,Right-click the top-left corner for [ %selectedSection% ]
    Gui 11: -caption
    Gui 11: Show, NoActivate xcenter y9999, TopGUI

    wingetpos,,,,bottomH, BottomGUI
    wingetpos,,,,topH, TopGUI

    topPOS := (bottomH - topH) / 2

    topPOS := (bottomH - topH) / 2

    Gui, TopGUI: +LabelTopGUI
    WinMove, TopGUI,, , %topPOS%
}

return

; Captures the first and second right-click positions for rectangle
; coordinates, then writes the resulting bounds to the appropriate
; configuration file. Logout is stored in LLARS Config.ini.
CheckClicks:
if GetKeyState("Esc", "P")
{
	Log("RELOAD", "Reload triggered by Escape")
	Reload
}

if GetKeyState("RButton", "P")
{
	MouseGetPos, MouseX, MouseY
	ClickCount++
	
	if (ClickCount = 1)
	{
		Gui 11: Destroy
		Gui 11u: Destroy
		
		Gui 12u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
		Gui 12u: Color, Red
		Gui 12u: Font, cRed
		Gui 12u: Font, s16 bold
		Gui 12u: Add, Text, valertlabel center,----Right-click the bottom-right corner for [ %selectedSection% ]`n----
		WinSet, ExStyle, ^0x80
		Gui 12u: -caption
		Gui 12u: Show, NoActivate xcenter y0, BottomGUI
		
		Gui 12: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
		Gui 12: Font, s16 bold
		Gui 12: Add, Text, vTtwo center,Right-click the bottom-right corner for [ %selectedSection% ]
		Gui 12: -caption
		Gui 12: Show, NoActivate xcenter y9999, TopGUI
		
		Gui, TopGUI: +LabelTopGUI
		WinMove, TopGUI,, , %topPOS%
		
		xmin := MouseX
		ymin := MouseY
	}
	else if (ClickCount = 2)
	{
		Gui 12: Destroy
		Gui 12u: Destroy
		
		xmax := MouseX
		ymax := MouseY
		
		SetTimer, CheckClicks, Off
		
		if (ButtonText = "Logout")
			configFile := "LLARS Config.ini"
		else
			configFile := "Config.ini"
		
		IniWrite, %xmin%, %configFile%, %ButtonText%, xmin
		IniWrite, %xmax%, %configFile%, %ButtonText%, xmax
		IniWrite, %ymin%, %configFile%, %ButtonText%, ymin
		IniWrite, %ymax%, %configFile%, %ButtonText%, ymax
		Log("COORDINATES CHANGED", " %buttontext% | X=" xmin "-" xmax " | Y=" ymin "-" ymax)
		
		if (ButtonText = "Logout")
		{
			Gui 13u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
			Gui 13u: Color, Green
			Gui 13u: Font, cGreen
			Gui 13u: Font, s16 bold
			Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the LLARS Config.ini file`n----
			WinSet, ExStyle, ^0x80
			Gui 13u: -caption
			Gui 13u: Show, NoActivate xcenter y0, BottomGUI
			
			Gui 13: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
			Gui 13: Color, White
			Gui 13: Font, s16 bold
			Gui 13: Add, Text, vTthree center,Coordinates for [ %selectedSection% ] have been updated in the LLARS Config.ini file
			Gui 13: -caption
			Gui 13: Show, NoActivate xcenter y9999, TopGUI
		}
		else
		{
			Gui 13u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
			Gui 13u: Color, Green
			Gui 13u: Font, cGreen
			Gui 13u: Font, s16 bold
			Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the Config.ini file`n----
			WinSet, ExStyle, ^0x80
			Gui 13u: -caption
			Gui 13u: Show, NoActivate xcenter y0, BottomGUI
			
			Gui 13: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
			Gui 13: Color, White
			Gui 13u: Font, s16 bold
			Gui 13u: Add, Text, vTthree center,Coordinates for [ %selectedSection% ] have been updated in the Config.ini file
			Gui 13: -caption
			Gui 13: Show, NoActivate xcenter y9999, TopGUI
		}
		
		Gui, TopGUI: +LabelTopGUI
		WinMove, TopGUI,, , %topPOS%
		
		Sleep, 1500
		
		Gui 13: Destroy
		Gui 13u: Destroy
		Gui, 2: Destroy
		Gui, 1: Show
		
		EnableHotkey()
	}
	Sleep, 250
}

return

; Handles single-point coordinate capture for the special
; "pixel coordinate" configuration section.
CheckClicksPixel:
if GetKeyState("Esc", "P")
{
	Log("RELOAD", "Reload triggered by Escape")
	Reload
}

if GetKeyState("RButton", "P")
{
	MouseGetPos, MouseX, MouseY
	
	Gui 11: Destroy
	Gui 11u: Destroy
	
	Gui 13u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
	Gui 13u: Color, Green
	Gui 13u: Font, cGreen
	Gui 13u: Font, s16 bold
	Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the Config.ini file`n----
	WinSet, ExStyle, ^0x80
	Gui 13u: -caption
	Gui 13u: Show, NoActivate xcenter y0, BottomGUI
	
	Gui 13: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
	Gui 13: Font, s16 bold
	Gui 13: Add, Text, vTthree center,Coordinates for [ %selectedSection% ] have been updated in the Config.ini file
	Gui 13: -caption
	Gui 13: Show, NoActivate xcenter y9999, TopGUI
	
	Gui, TopGUI: +LabelTopGUI
	WinMove, TopGUI,, , %topPOS%
	
	x := MouseX
	y := MouseY
	
	SetTimer, CheckClicksPixel, Off
	
	IniWrite, %x%, Config.ini, %ButtonText%, x
	IniWrite, %y%, Config.ini, %ButtonText%, y
	Log("COORDINATES CHANGED", "Pixel Coordinate | X=" x " | Y=" y)
	
	Sleep, 1500
	
	Gui 13: Destroy
	Gui 13u: Destroy
	Gui, 2: Destroy
	Gui, 1: Show
	
	EnableHotkey()
	
	Sleep, 250
}
return

; ================================================================
; |     COLORS GUI     -     COLORS GUI     -     COLORS GUI     |
; ================================================================

; Builds the color editor dynamically by using the type assigned to
; each configuration section. Sections marked type=color are
; automatically included without requiring their names in the script.
Color:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy

Gui 1: Hide
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop
Gui 2: Font, s11 Bold
DisableHotkey()

IniRead, allContents, Config.ini

sectionList := " ***** Make a Selection ***** "

; Only add sections that are explicitly categorized as colors.
Loop, Parse, allContents, `n, `r
{
	currentSection := Trim(A_LoopField)
	
	if (currentSection = "")
		continue
	
	StringReplace, currentSection, currentSection, [, , All
	StringReplace, currentSection, currentSection, ], , All
	currentSection := Trim(currentSection)
	
	if (GetConfigType("Config.ini", currentSection) = "color")
		sectionList .= "|" currentSection
}

Gui, 2: Add, DropDownList, w230 vSectionList Choose1 gDropDownChanged1, % sectionList
Gui, 2: Add, Button, x52 w150 gClose1, Close Colors

Gui, 2: Show, w250 h45 Center, Colors
Gui 2: -Caption
WinSet, ExStyle, ^0x80
WinSet, Transparent, %value%

return

; Closes the color editor and returns to the main LLARS GUI.
Close1:
Gui 2: Destroy
Gui 1: Show
EnableHotkey()
return

; Starts color selection after a valid section is selected.
DropDownChanged1:
GuiControlGet, selectedSection,, SectionList

if (selectedSection != " ***** Make a Selection ***** ")
	GoSub, ColorSelected

return

; Reads the configured pixel location, captures its current color,
; and writes that color into the selected Config.ini section.
ColorSelected:
Gui, 2: Hide

WinActivate, RuneScape

x := ""
y := ""

ButtonText := selectedSection

Sleep, 500

IniRead, x, Config.ini, Pixel Coordinate, x
IniRead, y, Config.ini, Pixel Coordinate, y

PixelGetColor, color, %x%, %y%, RGB

IniWrite, %color%, Config.ini, %ButtonText%, %ButtonText%

Log("COLOR CHANGED IN CONFIG", ButtonText " = " color)

Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----%buttontext% has been updated in the Config.ini file`n----
WinSet, ExStyle, ^0x80
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI

Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, %buttontext% has been updated in the Config.ini file
Gui 13: -caption
Gui 13: Show, NoActivate xcenter y9999, TopGUI

wingetpos,,,,bottomH, BottomGUI
wingetpos,,,,topH, TopGUI

topPOS := (bottomH - topH) / 2

Gui, TopGUI: +LabelTopGUI
WinMove, TopGUI,, , %topPOS%

Sleep 1500

Gui 13: Destroy
Gui 13u: Destroy
Gui, 2: Destroy
Gui, 1: Show

EnableHotkey()

return

; ================================================================
; |     HOTKEY GUI     -     HOTKEY GUI     -     HOTKEY GUI     |
; ================================================================

; Builds the hotkey editor dynamically by using the type assigned to
; each configuration section. Sections marked type=hotkey are
; automatically included without requiring their names in the script.
;
; The hotkeyConfigFiles object records which INI file each section
; came from. This prevents the script from guessing the source file
; later when a hotkey is selected or changed.
Hotkey:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy

Gui 1: Hide
Gui Combo: Destroy
Gui 3: +LastFound +OwnDialogs +AlwaysOnTop
Gui 3: Font, s11 Bold
DisableHotkey()

IniRead, allContents, Config.ini
IniRead, llarsContents, LLARS Config.ini

sectionList := " ***** Make a Selection ***** | "
hotkeyConfigFiles := {}
configHotkeysFound := false

; Add a section header for Config.ini hotkeys.
sectionList .= "| ---- Script Hotkeys ---- "

; Add sections from Config.ini that are explicitly categorized as hotkeys.
; Store the source file at the same time the section is added.
Loop, Parse, allContents, `n
{
	currentSection := Trim(A_LoopField)
	
	if (currentSection = "")
		continue
	
	StringReplace, currentSection, currentSection, [, , All
	StringReplace, currentSection, currentSection, ], , All
	currentSection := Trim(currentSection)
	
	if (GetConfigType("Config.ini", currentSection) = "hotkey")
	{
		sectionList .= "|" currentSection
		hotkeyConfigFiles[currentSection] := "Config.ini"
		configHotkeysFound := true
	}
}

; Add a blank space between the Script Hotkeys and
; LLARS Hotkeys sections.
sectionList .= "| "

; Add a section header for LLARS Config.ini hotkeys.
sectionList .= "| ---- LLARS Hotkeys ---- "

; Add sections from LLARS Config.ini that are explicitly categorized as hotkeys.
; Store the source file at the same time the section is added.
Loop, Parse, llarsContents, `n
{
	currentSection := Trim(A_LoopField)
	
	if (currentSection = "")
		continue
	
	StringReplace, currentSection, currentSection, [, , All
	StringReplace, currentSection, currentSection, ], , All
	currentSection := Trim(currentSection)
	
	if (GetConfigType("LLARS Config.ini", currentSection) = "hotkey")
	{
		sectionList .= "|" currentSection
		hotkeyConfigFiles[currentSection] := "LLARS Config.ini"
	}
}

Gui, 3: Add, DropDownList, w230 vSectionList Choose1 gDropDownChanged2, % sectionList
Gui, 3: Add, Text, w230 vHotkeysText, Hotkeys will be displayed here
Gui, 3: Add, Hotkey, x97 y60 w60 vChosenHotkey gHotkeyChanged Center, ** NONE **
Gui, 3: Add, Button, x64 y90 w125 gClose2, Close Hotkeys

Gui, 3: Show, w250 h100 Center, Hotkeys
Gui 3: -Caption
WinSet, ExStyle, ^0x80
WinSet, Transparent, %value%
return

; Closes the hotkey editor and returns to the main LLARS window.
Close2:
Gui 3: Destroy
Gui 1: Show
EnableHotkey()
return

; Loads the existing hotkey for the selected section and prepares
; the hotkey control for a replacement value.
DropDownChanged2:
GuiControlGet, selectedSection,, SectionList

if (selectedSection != " ***** Make a Selection ***** " && selectedSection != " " && selectedSection != " ---- Script Hotkeys ---- " && selectedSection != " ---- LLARS Hotkeys ---- ")
{
	; Use the configuration file recorded when the dropdown was built.
	configFile := hotkeyConfigFiles[selectedSection]
	
	IniRead, existingHotkey, %configFile%, %selectedSection%, Hotkey
	GuiControl,, ChosenHotkey, %existingHotkey%
	GoSub, ButtonClicked2
}

return

; Gives focus to the hotkey input control and allows Escape to
; reload the script while the hotkey-selection process is active.
ButtonClicked2:
if GetKeyState("Esc", "P")
{
	Log("RELOAD", "Reload triggered by Escape")
	Reload
}
GuiControl,, HotkeysText, Enter new hotkey
GuiControl, Focus, ChosenHotkey
return

; Saves the newly selected hotkey and displays the same confirmation
; overlay used by the other configuration editors.
HotkeyChanged:
Gui, 3: Submit, NoHide

; Write the new hotkey back to the same configuration file
; from which the selected section was loaded.
configFile := hotkeyConfigFiles[selectedSection]

IniWrite, %ChosenHotkey%, %configFile%, %selectedSection%, Hotkey
Log("HOTKEY CHANGED", "Hotkey = " ChosenHotkey)
Gui, 3: Destroy

Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cgreenhite
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----Hotkey has been updated in the %configFile% file`n----
WinSet, ExStyle, ^0x80
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI

Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, Hotkey has been updated in the %configFile% file
Gui 13: -caption
Gui 13: Show, NoActivate xcenter y9999, TopGUI

wingetpos,,,,bottomH, BottomGUI
wingetpos,,,,topH, TopGUI

topPOS := (bottomH - topH) / 2

Gui, TopGUI: +LabelTopGUI
WinMove, TopGUI,, , %topPOS%

Sleep 1500

Gui 13u: Destroy
Gui 13: Destroy
Gui 1: Show
EnableHotkey()
return

; =============================================================================================================
; |     PAUSE/RESUME BUTTON LOGIC     -     PAUSE/RESUME BUTTON LOGIC     -     PAUSE/RESUME BUTTON LOGIC     |
; =============================================================================================================

; Updates the main GUI state and resumes normal script execution.
ResumeB:
Log("RESUME", "Script resumed")
GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running
Pause, off
Return

; Updates the main GUI state and pauses script execution.
PauseB:
Log("PAUSE", "Script paused")
GuiControl,,State2, Paused
GuiControl,,ScriptRed, %scriptname%
Pause, on
Return

; =========================================================================
; |     RANDOM SLEEP COUNTDOWN     -     RANDOM SLEEP COUNTDOWN          |
; =========================================================================

UpdateCountdown:

RemainingTime := EndTime - A_TickCount

if (RemainingTime > 0)
{
	GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RemainingTime)
}

return

RandomSleepAmountToMinutesSeconds(time)
{
	minutes := Floor(time / 60000)
	seconds := Mod(Floor(time / 1000), 60)

	return minutes . "m " . seconds . "s"
}

; =====================================================================================
; |     EXIT BUTTON LOGIC     -     EXIT BUTTON LOGIC     -     EXIT BUTTON LOGIC     |
; =====================================================================================

; Handles normal LLARS shutdown, saves the GUI position, closes the
; logging session, and exits the application.
ExitB:
guiclose:

Log("EXIT", "LLARS exited normally")

WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy

EndLogSession("Normal Exit")

ExitApp

; ========================================================================================
; |     START BUTTON LOGIC     -     START BUTTON LOGIC     -     START BUTTON LOGIC     |
; ========================================================================================

; Validates the configuration, asks for the desired run duration,
; switches the GUI into running mode, updates running hotkeys,
; activates RuneScape, and starts the automation loop.
Start:

; Make sure the required RuneScape client exists before starting.
IfWinNotExist, RuneScape
{
	Gui 1: Hide
	Gui GNF: +LastFound +OwnDialogs +AlwaysOnTop
	Gui GNF: Font, S13 bold underline cRed
	Gui GNF: Add, Text, Center w220 x5, ERROR
	Gui GNF: Add, Text, center x5 w220,
	Gui GNF: Font, s12 norm bold
	Gui GNF: Add, Text, Center w220 x5, RuneScape Not Found
	Gui GNF: Add, Text, center x5 w220,
	Gui GNF: Font, cBlack
	Gui GNF: Add, Text, Center w220 x5, RuneScape was not found to be running.`n`n`nRuneScape will attempt to be auto-launched upon closing this error message.
	Gui GNF: Add, Text, center x5 w220,
	Gui GNF: Font, norm italic s10 c0x152039
	Gui GNF: Add, Text, Center w220 x5, If RuneScape is already open and you're seeing this message, please use the Discord button below to contact Gubna for assistance.
	Gui GNF: Font, s11 norm Bold c0x152039
	Gui GNF: Add, Text, center x5 w220,
	Gui GNF: Add, Text, Center w220 x5, Created by Gubna
	Gui GNF: Add, Button, gDiscordError w150 x40 center, Discord
	Gui GNF: Add, Button, gCloseGNF w150 x40 center, Close Error
	WinSet, ExStyle, ^0x80
	Gui GNF: -caption
	Gui GNF: Show, center w230, Game Not Found

	return
}

; Validate the entire configuration dynamically.
if (ConfigError())
	return

Log("START", "Start button/hotkey activated")

; inputbox for user to enter runcount
; runcount represents the amount of loops script will execute
InputBox, runcount, Run How Many Times?,,,250,100
if (ErrorLevel)
{
	Reload
	return
}
if (runcount = "" || !RegExMatch(runcount, "^\d+$") || runcount <= 0)
{
	MsgBox, 48, Invalid Input, Please enter a valid whole number greater than 0.
	return
}
if (runcount > 1000)
{
	MsgBox, 48, Invalid Input, Please enter a number between 1 and 1000.
	return
}

; ======================================================================================
; |     RUN INITIALIZATION     -     RUN INITIALIZATION     -     RUN INITIALIZATION   |
; ======================================================================================

If (frcount = 0)
{
	LLARS_RUNNING := true
	SetLLARSHOTKEYS()
	
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	Gui, Font, s11
	Gui, font, bold
	Gui, Add, Button, x5 y5 w100 h25 gStart , Start
	Gui, Add, Button, x115 y5 w100 h25 gInfo, Information
	Gui, Add, Button, x5 y35 w100 h25 gPauseb , Pause
	Gui, Add, Button, x115 y35 w100 h25 gResumeb , Resume
	Gui, Add, Button, x35 y140 w150 h25 gExitb , Exit LLARS
	Gui, Add, Text, x135 y90 w65 h25 center vCounter
	Gui, Add, Text, x8 y90 w125 h25, Total Run Count
	Gui, Add, Text, x8 y65 w125 h25, Run Count
	Gui, Add, Text, x135 y65 w150 h25 vCounter2
	Gui, Font, cGreen
	Gui, Add, Text, x135 y115 w70 h25 vState1
	Gui, Add, Text, x8 y115 w125 h25 vScriptGreen
	Gui, Font, cBlue
	Gui, Add, Text, x135 y115 w70 h25 vState3
	Gui, Add, Text, x8 y115 w125 h25 vScriptBlue
	Gui, Font, cRed
	Gui, Add, Text, x135 y115 w70 h25 vState2
	Gui, Add, Text, x8 y115 w125 h25 vScriptRed
	GuiControl,,State2, ** OFF **
	Gui, Add, Text, x8 y115 w125 h25, %scriptname%
	if FileExist("LLARS Logo.ico")
	{
		Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
	}
	WinSet, Transparent, %value%
	Gui, Show,w220 h170, LLARS
	WinMove, LLARS,, X, Y,
	
	count = 0
	++frcount
}

GuiControl,, ScriptBlue, %scriptname%
GuiControl,, State3, Running

DisableButton()

startcheck := 1

; Reset all values used by the current timed run.
count2 := 0
sleepcount := 0
totalSleepTime := 0
rightclick := 0
clickcount := 0

; IMPORTANT:
; firstrun controls which alternating run sequence is executed.
; Always reset it here so every new Start begins with the first sequence.
firstrun := 0

runcount3 := runcount

StartTime := A_TickCount
StartTimeStamp := A_Hour ":" A_Min ":" A_Sec

Log("RUN START", "Starting " runcount3 " runs")

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ========================================================================
; |     MAIN RUN LOOP     -     MAIN RUN LOOP     -     MAIN RUN LOOP    |
; ========================================================================

loop % runcount
{ 	
	If firstrun = 0
	{
		IfWinNotActive, RuneScape
		{
			WinActivate, RuneScape
			Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
		}
		
		++count
		++count2
		
		GuiControl,,Counter, %count%
		GuiControl,,Counter2, %count2% / %runcount3%
		GuiControl,,ScriptBlue, %scriptname%
		GuiControl,,State3, Running
		DisableButton()
		
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=0")
		
		IniRead, x1, Config.ini, Bank Coords, xmin
		IniRead, x2, Config.ini, Bank Coords, xmax
		IniRead, y1, Config.ini, Bank Coords, ymin
		IniRead, y2, Config.ini, Bank Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		
		Log("BANK CLICK", "X=" x " Y=" y)
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")
		
		IniRead, hkbank, Config.ini, Bank Preset, hotkey
		send {%hkbank%}
		
		Log("BANK PRESET", "Hotkey sent: " hkbank)
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")
		
		IniRead, hk, Config.ini, Skillbar Hotkey, hotkey
		send {%hk%}
		
		Log("SKILLBAR", "Hotkey sent: " hk)
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")
		
		IniRead, x1, Config.ini, item, xmin
		IniRead, x2, Config.ini, item, xmax
		IniRead, y1, Config.ini, item, ymin
		IniRead, y2, Config.ini, item, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		
		Log("ITEM CLICK", "Item=" item " | X=" x " Y=" y)
	}
	If firstrun = 1
	{
		++count
		++count2
		firstrun=0
		
		IfWinNotActive, RuneScape
		{
			WinActivate, RuneScape
			Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
		}
		
		GuiControl,,Counter, %count%
		GuiControl,,Counter2, %count2% / %runcount3%
		GuiControl,,ScriptBlue, %scriptname%
		GuiControl,,State3, Running
		
		Log("RUN", "Run " count " of " runcount3 " started | firstrun=1")
		
		IniRead, x1, Config.ini, Bank Coords, xmin
		IniRead, x2, Config.ini, Bank Coords, xmax
		IniRead, y1, Config.ini, Bank Coords, ymin
		IniRead, y2, Config.ini, Bank Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		NaturalClick(x, y)
		
		Log("BANK CLICK", "X=" x " Y=" y)
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")
		
		IniRead, hkbank, Config.ini, Bank Preset, hotkey
		send {%hkbank%}
		
		Log("BANK PRESET", "Hotkey sent: " hkbank)
		
		IniRead, option, LLARS Config.ini, Random Sleep, option
		if option = true
		{
			IniRead, chance, LLARS Config.ini, Random Sleep, chance
			Random, RandomNumber, 1, 100
			
			if % RandomNumber <= chance
			{
				
				++sleepcount
				GuiControl,, ScriptBlue, Random Sleep
				GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RandomSleepAmount)
				
				IniRead, rs1, LLARS Config.ini, Random Sleep, min
				IniRead, rs2, LLARS Config.ini, Random Sleep, max
				Random, RandomSleepAmount, %rs1%, %rs2%
				
				SetTimer, UpdateCountdown, 1000
				EndTime := A_TickCount + RandomSleepAmount
				totalSleepTime += RandomSleepAmount
				
				Log("RANDOM SLEEP", "Sleep=" RandomSleepAmount " ms | Chance=" chance "% | Roll=" RandomNumber)
				
				Sleep, RandomSleepAmount
				SetTimer, UpdateCountdown, Off
				
				Log("RANDOM SLEEP COMPLETE", "Slept for " RandomSleepAmount " ms")
				
				GuiControl,,ScriptBlue, %scriptname%
				GuiControl,,State3, Running
			}
		}
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")
		
		IniRead, hk, Config.ini, Skillbar Hotkey, hotkey
		send {%hk%}
		
		Log("SKILLBAR", "Hotkey sent: " hk)
	}
	If firstrun = 0
	{
		++firstrun
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		Log("SLEEP", "Sleep Short completed: " SleepAmount " ms")
		
		send {space}
		
		Log("SPACE", "Space key sent")
		
		IniRead, sa1, Config.ini, Sleep Craft, min
		IniRead, sa2, Config.ini, Sleep Craft, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		Log("CRAFT WAIT", "Sleep Craft completed: " SleepAmount " ms")
	}	
}

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

; Calls the logout function after all requested runs finish.
Logout()


; =======================================================================
; |     RUN COMPLETE     -     RUN COMPLETE     -     RUN COMPLETE      |
; =======================================================================

GuiControl,, ScriptGreen, %scriptname%
GuiControl,, State1, Finished

EndTimeStamp := A_Hour ":" A_Min ":" A_Sec

EndTime := A_TickCount

; Convert total elapsed time to whole seconds.
TotalTimeSeconds := Floor((EndTime - StartTime) / 1000)

; Calculate average loop time using whole seconds.
AverageTimeSecondsTotal := Floor(TotalTimeSeconds / runcount3)

; Break total time into hours, minutes, and seconds.
TotalTimeHours := Floor(TotalTimeSeconds / 3600)
TotalTimeMinutes := Floor(Mod(TotalTimeSeconds, 3600) / 60)
TotalTimeSecondsDisplay := Mod(TotalTimeSeconds, 60)

; Break average loop time into minutes and seconds.
AverageTimeMinutes := Floor(AverageTimeSecondsTotal / 60)
AverageTimeSecondsDisplay := Mod(AverageTimeSecondsTotal, 60)

; Calculate actual random sleep percentage.
percentage := Round((sleepcount / runcount3) * 100)

; Convert total random sleep time to whole seconds.
totalSleepTimeSeconds := Floor(totalSleepTime / 1000)

TotalSleepHours := Floor(totalSleepTimeSeconds / 3600)
TotalSleepMinutes := Floor(Mod(totalSleepTimeSeconds, 3600) / 60)
TotalSleepSeconds := Mod(totalSleepTimeSeconds, 60)

Log("COMPLETE", "Completed " runcount3 " runs | Total time=" TotalTimeSeconds " seconds | Random sleeps=" sleepcount)

SoundPlay, C:\Windows\Media\Ring06.wav, 1

IniRead, chance, LLARS Config.ini, Random Sleep, chance

MsgBox, 64, LLARS Run Info, %scriptname% has completed %runcount3% runs`n`nTotal time: %TotalTimeHours%h : %TotalTimeMinutes%m : %TotalTimeSecondsDisplay%s`nAverage loop: %AverageTimeMinutes%m : %AverageTimeSecondsDisplay%s`n`nStart time: %StartTimeStamp%`nEnd time: %EndTimeStamp%`n`nSet sleep chance: %chance%`%`nActual sleep chance: %percentage%`%`nTotal random sleeps: %sleepcount%`nTotal time slept: %TotalSleepHours%h : %TotalSleepMinutes%m : %TotalSleepSeconds%s

EnableButton()
LLARS_RUNNING := false
SetLLARSHOTKEYS()

return

; ===============================================================================
; |     LOGOUT FUNCTION     -     LOGOUT FUNCTION     -     LOGOUT FUNCTION     |
; ===============================================================================

; Performs an optional logout after the timed run completes. The logout
; process uses Escape, a randomized delay, and a random point inside
; the configured logout rectangle from LLARS Config.ini.
Logout(){
	IniRead, option, LLARS Config.ini, Logout, option
	
	Log("LOGOUT CHECK", "Logout option = " option)
	
	if option=true
	{
		Log("LOGOUT", "Logout initiated")
		
		send {esc}	
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		
		Log("LOGOUT WAIT", "Random sleep before logout click: " SleepAmount " ms")
		
		Sleep, %SleepAmount%	

		IniRead, x1, LLARS Config.ini, Logout, xmin
		IniRead, x2, LLARS Config.ini, Logout, xmax
		IniRead, y1, LLARS Config.ini, Logout, ymin
		IniRead, y2, LLARS Config.ini, Logout, ymax
		
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		
		Log("LOGOUT CLICK", "Logout coordinates X=" x " Y=" y)
		
		Click, %x%, %y%
		
		Log("LOGOUT", "Logout click completed")
	}
}

; ===================================================================
; |     INFORMATION     -     INFORMATION     -     INFORMATION     |
; ===================================================================

Info:
DisableHotkey()

IniRead, logout, LLARS Config.ini, Logout, option
IniRead, sleepoption, LLARS Config.ini, Random Sleep, option
IniRead, chance, LLARS Config.ini, Random Sleep, chance

; Build the list of script hotkeys automatically.
scriptHotkeys := ""

if (LLARS_lhk1 != "")
	scriptHotkeys .= "Start: " . LLARS_lhk1 . "`n"

if (LLARS_lhk2 != "")
	scriptHotkeys .= "Information: " . LLARS_lhk2 . "`n"

if (LLARS_lhk3 != "")
	scriptHotkeys .= "Color/Coordinate/Hotkey: " . LLARS_lhk3 . "`n"

if (LLARS_lhk4 != "")
	scriptHotkeys .= "Exit: " . LLARS_lhk4 . "`n"

; Add a blank line between LLARS hotkeys and script hotkeys.
if (scriptHotkeys != "")
	scriptHotkeys .= "`n"

; Read script-specific hotkeys from Config.ini.
IniRead, sections, Config.ini

Loop, Parse, sections, `n, `r
{
	section := A_LoopField
	
	if (section = "")
		continue
	
	IniRead, type, Config.ini, %section%, type
	
	if (type = "hotkey")
	{
		IniRead, hotkey, Config.ini, %section%, hotkey
		
		if (hotkey = "")
			hotkey := "Not Set"
		
		scriptHotkeys .= section . ": " . hotkey . "`n"
	}
}

if (scriptHotkeys = "")
	scriptHotkeys := "No script hotkeys configured"

WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy

Gui 1: hide
Gui 3: hide
Gui 20: +AlwaysOnTop +OwnDialogs +LastFound
Gui 20: Font, S13 bold cMaroon
Gui 20: Add, Text, Center w220 x5,%scriptname%
Gui 20: Font, s11 Bold underline cTeal
Gui 20: Add, Text, Center w220 x5,[ Script Hotkeys ]
Gui 20: Font, Norm
Gui 20: Add, Text, Center w220 x5,%scriptHotkeys%
Gui 20: Font, Bold underline cPurple
Gui 20: Add, Text, Center w220 x5,[ Additional Info ]
Gui 20: Font, Norm
Gui 20: Add, Text, Center w220 x5,Logout: %logout%`nRandom Sleep: %sleepoption%`nSleep Chance: %chance%`%
Gui 20: Add, Text, center x5 w220,
Gui 20: Font, italic s10 c0x152039
Gui 20: Add, Text, Center w220 x5, Additional notes/comments can be found in the Config.ini file or by pressing the Script Config button below
Gui 20: Font, cBlue norm underline bold s11
Gui 20: Add, Text, Center gMIT w220 x5,MIT License
Gui 20: Font, s11 norm Bold c0x152039
Gui 20: Add, Text, Center w220 x5,Created by Gubna
Gui 20: Font, cBlack norm bold
Gui 20: Add, Button, gInfoLLARS w150 x40 center,LLARS Config
Gui 20: Add, Button, gInfoConfig w150 x40 center,Script Config
Gui 20: Add, Button, gDiscord w150 x40 center,Discord
Gui 20: Add, Button, gCloseInfo w150 x40 center,Close Information
WinSet, ExStyle, ^0x80
Gui 20: -caption
Gui 20: Show, center w230, Information
return

; Closes the information window and restores the main LLARS GUI.
CloseInfo:
EnableHotkey()
gui 20: destroy
gui 1: Show		
return

; Opens the Discord link from the information GUI and returns to LLARS.
discord:
EnableHotkey()
Gui 20: destroy
Run, https://discord.gg/Wmmf65myPG
gui 1: Show		
return

; Opens the main script configuration file.
InfoConfig:
EnableHotkey()
Run %A_ScriptDir%\Config.ini
return

; Opens the LLARS configuration file.
InfoLLARS:
EnableHotkey()
Run %A_ScriptDir%\LLARS Config.ini
return

; Opens the project's GitHub repository from the configuration error window.
GitLink:
run, https://github.com/Gubna-Tech/RuneScape
Exitapp

; Opens Discord from the configuration error window and exits the script.
DiscordError:
Run, https://discord.gg/Wmmf65myPG
Exitapp

; Closes the script from the configuration error window.
CloseError:	
ExitApp

; Opens the project's MIT license page.
MIT:
run https://github.com/Gubna-Tech/RuneScape/blob/main/LICENSE
return

; ============================================================================
; |     GAME NOT FOUND     -     GAME NOT FOUND     -     GAME NOT FOUND     |
; ============================================================================

CloseGNF:
Gui GNF: Destroy

; Checks for the Jagex Launcher and RuneScape client.
if FileExist("C:\Program Files (x86)\Jagex Launcher\JagexLauncher.exe")
{
	if FileExist("C:\Program Files\Jagex\RuneScape Launcher\RuneScape.exe")
	{
		Menu, Tray, NoIcon
		Gui Client: +LastFound +OwnDialogs +AlwaysOnTop
		Gui Client: Font, S13 bold underline cRed
		Gui Client: Add, Text, Center w220 x5, ERROR
		Gui Client: Add, Text, center x5 w220,
		Gui Client: Font, s12 norm bold
		Gui Client: Add, Text, Center w220 x5, RuneScape and Jagex Launcher Both Found.
		Gui Client: Add, Text, center x5 w220,
		Gui Client: Font, cBlack
		Gui Client: Add, Text, Center w220 x5, Please select below either RuneScape or Jagex to launch the appropriate client for your account.
		Gui Client: Add, Text, center x5 w220,
		Gui Client: Add, Button, gJagex w150 x40 center, Jagex
		Gui Client: Add, Button, gRuneScape w150 x40 center, RuneScape
		WinSet, ExStyle, ^0x80
		Gui Client: -caption
		Gui Client: Show, center w230, Multiple Client
		return
	}
	else
	{
		Gui 1: Show
		Run, C:\Program Files (x86)\Jagex Launcher\JagexLauncher.exe
		return
	}
}
else if FileExist("C:\Program Files\Jagex\RuneScape Launcher\RuneScape.exe")
{
	Gui 1: Show
	Run, rs-launch://www.runescape.com/k=5/l=$(Language:0)/jav_config.ws
	return
}
else
{
	Menu, Tray, NoIcon
	Gui Client: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Client: Font, S13 bold underline cRed
	Gui Client: Add, Text, Center w220 x5, ERROR
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Font, s12 norm bold
	Gui Client: Add, Text, Center w220 x5, Neither RuneScape Nor Jagex Launcher Were Found.
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Font, cBlack
	Gui Client: Add, Text, Center w220 x5, No game client was detected in its expected location, please manually launch RuneScape.
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Add, Text, Center w220 x5, Please ensure that RuneScape is open before attempting to start the script again.
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Add, Button, gCloseClient w150 x40 center, Close Error
	WinSet, ExStyle, ^0x80
	Gui Client: -caption
	Gui Client: Show, center w230, No Client Detected

	return
}
return

CloseClient:
Gui Client: Destroy
Gui 1: Show
return

Jagex:
Gui Client: Destroy
Gui 1: Show
Run, C:\Program Files (x86)\Jagex Launcher\JagexLauncher.exe
return

RuneScape:
Gui Client: Destroy
Gui 1: Show
Run, rs-launch://www.runescape.com/k=5/l=$(Language:0)/jav_config.ws
return