; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
SetBatchLines, -1

; =========================================================================
; |     LOGGING START     -     LOGGING START     -     LOGGING START     |
; =========================================================================

; Starts the logging session before any other script initialization so
; startup events and errors can be recorded from the beginning.
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
	Gui Error: Add, Text, center x220 x5,
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

; ===================================================================
; |     HOTKEY READ     -     HOTKEY READ     -     HOTKEY READ     |
; ===================================================================

; Loads the LLARS control hotkeys and GUI transparency setting from
; the external configuration instead of hard-coding them in the script.
IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, information
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, color/coordinate/hotkey
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
IniRead, value, LLARS Config.ini, Transparent, value

; ======================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<  |
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<  |
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<  |
; ======================================================================

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

settimer, configcheck, 250

scriptname := regexreplace(A_scriptname,"\..*","")

Hotkey, %lhk1%, Start
Hotkey, %lhk2%, Info
Hotkey, %lhk3%, Combo
Hotkey, %lhk4%, exitb

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

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
Gui, Add, Button, x5 y35 w210 h25 gCombo, Coordinate/Hotkey/Timer
Gui, Add, Button, x35 y115 w150 h25 gExitb , Exit LLARS
Gui, Font, cBlue
Gui, Add, Text, x135 y65 w70 h25 vState3
Gui, Add, Text, x8 y65 w125 h25 vScriptBlue
Gui, Add, Text, x8 y90 w100 h25 vTimerLabel
Gui, Add, Text, x135 y90 w70 h25 vTimerCount
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
WinMove A, ,%X%, %y%

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

; Centralized logging functions used throughout the script to record
; events, timestamps, session state, and important actions.
Log(Event, Details := "")
{
	global LogCount
	
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

WM_WINDOWPOSCHANGED() {
	If (A_Gui) {
		checkpos()
	}
}
return

; Validates both configuration files and stops on the first configuration
; problem that is found.
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
	
	Log("CONFIG ERROR", file " | [" section "] " key " is blank or missing")
	
	Reload
}

; Dynamically scans every section/key in a configuration file.
;
; The type value determines how a section is validated:
;
;   type=color
;       Requires the section-name key to exist and contain a value.
;
;   type=coordinate
;       Detects whether the section uses x/y or xmin/xmax/ymin/ymax.
;       Missing or deleted coordinate keys are detected.
;
;   type=hotkey
;       Requires the Hotkey key to exist and contain a value.
;
; Sections with option=false are skipped.
;
; Sections without a recognized type are checked generically so
; normal configuration sections such as Sleep Timer continue to
; have all of their values validated.
CheckConfigFile(file)
{
	IniRead, sections, %file%
	
	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		
		if (section = "")
			continue
		
		; Check whether this section has been disabled.
		IniRead, option, %file%, %section%, option, true
		
		option := Trim(option)
		StringLower, option, option
		
		if (option = "false")
			continue
		
		; Determine how this section should be validated.
		configType := GetConfigType(file, section)
		
		if (configType = "coordinate")
		{
			; Read both possible coordinate formats.
			;
			; ERROR means the key does not exist.
			IniRead, x, %file%, %section%, x, ERROR
			IniRead, y, %file%, %section%, y, ERROR
			
			IniRead, xmin, %file%, %section%, xmin, ERROR
			IniRead, xmax, %file%, %section%, xmax, ERROR
			IniRead, ymin, %file%, %section%, ymin, ERROR
			IniRead, ymax, %file%, %section%, ymax, ERROR
			
			; Determine which coordinate format exists.
			;
			; If either x or y exists, this is treated as a
			; single-point coordinate and both x and y are required.
			hasPointCoordinates := (x != "ERROR" || y != "ERROR")
			
			; If any rectangle coordinate exists, this is treated
			; as a rectangle and all four values are required.
			hasRectangleCoordinates := (xmin != "ERROR" || xmax != "ERROR" || ymin != "ERROR" || ymax != "ERROR")
			
			; ------------------------------------------------------
			; Single pixel coordinate: x / y
			; ------------------------------------------------------
			if (hasPointCoordinates)
			{
				if (x = "ERROR" || Trim(x) = "")
				{
					ConfigErrorMessage(file, section, "x")
					return true
				}
				
				if (y = "ERROR" || Trim(y) = "")
				{
					ConfigErrorMessage(file, section, "y")
					return true
				}
			}
			
			; ------------------------------------------------------
			; Rectangle coordinate: xmin / xmax / ymin / ymax
			; ------------------------------------------------------
			else if (hasRectangleCoordinates)
			{
				if (xmin = "ERROR" || Trim(xmin) = "")
				{
					ConfigErrorMessage(file, section, "xmin")
					return true
				}
				
				if (xmax = "ERROR" || Trim(xmax) = "")
				{
					ConfigErrorMessage(file, section, "xmax")
					return true
				}
				
				if (ymin = "ERROR" || Trim(ymin) = "")
				{
					ConfigErrorMessage(file, section, "ymin")
					return true
				}
				
				if (ymax = "ERROR" || Trim(ymax) = "")
				{
					ConfigErrorMessage(file, section, "ymax")
					return true
				}
			}
			
			; No coordinate keys exist at all.
			; This catches the case where every coordinate entry
			; was deleted but type=coordinate was left behind.
			else
			{
				ConfigErrorMessage(file, section, "coordinates")
				return true
			}
			
			continue
		}
		
		if (configType = "color")
		{
			; Color sections use the section name as their key.
			;
			; ERROR means the key itself was deleted.
			IniRead, colorValue, %file%, %section%, %section%, ERROR
			
			if (colorValue = "ERROR" || Trim(colorValue) = "")
			{
				ConfigErrorMessage(file, section, section)
				return true
			}
			
			continue
		}

		if (configType = "hotkey")
		{
			; Hotkey sections require the Hotkey key.
			;
			; ERROR means the key itself was deleted.
			IniRead, hotkeyValue, %file%, %section%, Hotkey, ERROR
			
			if (hotkeyValue = "ERROR" || Trim(hotkeyValue) = "")
			{
				ConfigErrorMessage(file, section, "Hotkey")
				return true
			}
			
			continue
		}
		
		; Sections without a recognized type are checked normally.
		; This handles sections such as Sleep Timer and Sleep Short.
		;
		; option and type are metadata and are not themselves required
		; configuration values.
		IniRead, keys, %file%, %section%
		
		Loop, Parse, keys, `n, `r
		{
			line := Trim(A_LoopField)
			
			if (line = "")
				continue
			
			StringSplit, part, line, =, 2
			
			key := Trim(part1)
			value := Trim(part2)
			
			if (key = "option" || key = "type")
				continue
			
			if (value = "")
			{
				ConfigErrorMessage(file, section, key)
				return true
			}
		}
	}
	
	return false
}

; Keeps supported LLARS windows inside the visible screen area when
; their position changes or they are moved partially off-screen.
CheckPOS() {
	allowedWindows := "|LLARS|hotkeys|coordinates|file error|config error|game not found|information|multiple client|no client detected|combo|timer|"
	
	WinGetTitle, activeWindowTitle, A
	
	if (InStr(allowedWindows, "|" activeWindowTitle "|") <= 0) {
		return
	}
	
	WinGetPos, GUIx, GUIy, GUIw, GUIh, A
	xmin := GUIx
	xmax := GUIw + GUIx
	ymin := GUIy
	ymax := GUIh + GUIy
	xadj := A_ScreenWidth - GUIw
	yadj := A_ScreenHeight - GUIh
	WinGetPos, X, Y,,, A    
	
	if (xmin < 0) {
		WinMove, A,, 0
	}
	if (ymin < 0) {
		WinMove, A,,, 0
	}
	if (xmax > A_ScreenWidth) {
		WinMove, A,, xadj    
	}
	if (ymax > A_ScreenHeight) {
		WinMove, A,,, yadj
	}
}

; Finds existing LLARS windows and closes them to prevent multiple
; active LLARS instances from running simultaneously.
CloseOtherLLARS()
{
	WinGet, hWndList, List, LLARS
	
	Loop, %hWndList%
	{
		hWnd := hWndList%A_Index%
		Log("DUPLICATE CLOSE", "Closing existing LLARS window")
		WinClose, % "ahk_id " hWnd
	}
}

; Temporarily disables all LLARS control hotkeys while a configuration
; or information GUI is active.
DisableHotkey(disable := true) {
	Control, Disable,, start
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, information
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, color/coordinate/hotkey
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	Hotkey, %lhk1%, off	
	Hotkey, %lhk2%, off
	Hotkey, %lhk3%, off
	Hotkey, %lhk4%, off
}

; Re-enables the configured LLARS control hotkeys after leaving
; a secondary GUI.
EnableHotkey(enable := true) {
	Control, Enable,, start
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, information
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, color/coordinate/hotkey
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	Hotkey, %lhk1%, on	
	Hotkey, %lhk2%, on
	Hotkey, %lhk3%, on
	Hotkey, %lhk4%, on
}

; Disables only the Start control while the timed script is running.
DisableButton(disable := true) {
	Control, Disable,, start
	
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	Hotkey, %lhk1%, off
}

; Re-enables the Start control after the timed run is finished.
EnableButton(enable := true) {
	Control, Enable,, start
	
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	Hotkey, %lhk1%, On
}

; Provides Escape-key shortcuts for closing the various secondary
; LLARS GUIs and returning to the main window.
~Esc::
IfWinActive, Coordinates
{EnableHotkey()
GoSub, close
}
IfWinActive, Timer
{EnableHotkey()
Gui 5: destroy
Gui 1: show
}
IfWinActive, Information
{EnableHotkey()	
GoSub, closeinfo
}
IfWinActive, Combo
{EnableHotkey()	
GoSub, closecombo
}
IfWinActive, Colors
{EnableHotkey()	
GoSub, close1
}
IfWinActive, Hotkeys
{EnableHotkey()	
GoSub, close2
}
Return

; Checks whether a configuration section contains every key supplied
; in the requiredKeys list. This allows the configuration files to
; determine which sections belong to each editor automatically.
HasConfigKeys(file, section, requiredKeys)
{
	IniRead, keys, %file%, %section%
	
	Loop, Parse, requiredKeys, |
	{
		requiredKey := A_LoopField
		found := false
		
		Loop, Parse, keys, `n, `r
		{
			line := Trim(A_LoopField)
			
			if (line = "")
				continue
			
			StringSplit, part, line, =, 2
			key := Trim(part1)
			
			if (key = requiredKey)
			{
				found := true
				break
			}
		}
		
		if !found
			return false
	}
	
	return true
}

; Checks whether a section contains a single specific key.
HasConfigKey(file, section, requiredKey)
{
	return HasConfigKeys(file, section, requiredKey)
}

; Reads and validates the type assigned to a configuration section.
;
; Supported types:
;
;   type=color
;   type=coordinate
;   type=hotkey
;
; A section without a type key, or with an unsupported type,
; is ignored by the Color, Coordinate, and Hotkey editor GUIs.
GetConfigType(file, section)
{
	section := Trim(section)
	
	; Remove brackets if brackets are present in the section name.
	StringReplace, section, section, [, , All
	StringReplace, section, section, ], , All
	section := Trim(section)
	
	; Read the type value. ERROR is used so a missing type key
	; can be distinguished from an actual value.
	IniRead, sectionType, %file%, %section%, type, ERROR
	
	if (sectionType = "ERROR")
		return ""
	
	sectionType := Trim(sectionType)
	StringLower, sectionType, sectionType
	
	; Only recognized configuration types are returned.
	if (sectionType = "color")
		return "color"
	
	if (sectionType = "coordinate")
		return "coordinate"
	
	if (sectionType = "hotkey")
		return "hotkey"
	
	return ""
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
Gui Combo: Add, Button, x5 y95 w125 h25 gTimer , Timer
Gui Combo: add, button, x5 y125 w125 h25 gCloseCombo , Close
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

sectionList := " ***** Make a Selection ***** "

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
		sectionList .= "|" currentSection
}

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

; Closes the coordinate editor and returns to the main LLARS GUI.
Close:
Gui 2: Destroy
Gui 1: Show
EnableHotkey()
return

; Starts coordinate selection after a valid configuration section
; has been chosen from the dropdown.
DropDownChanged:
GuiControlGet, selectedSection,, SectionList

if (selectedSection != " ***** Make a Selection ***** ")
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

    Gui 11u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
    Gui 11u: Color, Red
    Gui 11u: Font, cRed
    Gui 11u: Font, s16 bold
    Gui 11u: Add, Text, valertlabel center,----Right-click the pixel for [ %selectedSection% ]`n----
    WinSet, ExStyle, ^0x80
    Gui 11u: -caption
    Gui 11u: Show, NoActivate xcenter y0, BottomGUI

    Gui 11: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
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

    Gui 11u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
    Gui 11u: Color, Red
    Gui 11u: Font, cRed
    Gui 11u: Font, s16 bold
    Gui 11u: Add, Text, valertlabel center,----Right-click the top-left corner for [ %selectedSection% ]`n----
    WinSet, ExStyle, ^0x80
    Gui 11u: -caption
    Gui 11u: Show, NoActivate xcenter y0, BottomGUI

    Gui 11: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
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
		
		Gui 12u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui 12u: Color, Red
		Gui 12u: Font, cRed
		Gui 12u: Font, s16 bold
		Gui 12u: Add, Text, valertlabel center,----Right-click the bottom-right corner for [ %selectedSection% ]`n----
		WinSet, ExStyle, ^0x80
		Gui 12u: -caption
		Gui 12u: Show, NoActivate xcenter y0, BottomGUI
		
		Gui 12: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
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
			Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
			Gui 13u: Color, Green
			Gui 13u: Font, cGreen
			Gui 13u: Font, s16 bold
			Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the LLARS Config.ini file`n----
			WinSet, ExStyle, ^0x80
			Gui 13u: -caption
			Gui 13u: Show, NoActivate xcenter y0, BottomGUI
			
			Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
			Gui 13: Color, White
			Gui 13: Font, s16 bold
			Gui 13: Add, Text, vTthree center,Coordinates for [ %selectedSection% ] have been updated in the LLARS Config.ini file
			WinSet, ExStyle, ^0x80
			Gui 13: -caption
			Gui 13: Show, NoActivate xcenter y9999, TopGUI
		}
		else
		{
			Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
			Gui 13u: Color, Green
			Gui 13u: Font, cGreen
			Gui 13u: Font, s16 bold
			Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the Config.ini file`n----
			WinSet, ExStyle, ^0x80
			Gui 13u: -caption
			Gui 13u: Show, NoActivate xcenter y0, BottomGUI
			
			Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
			Gui 13: Color, White
			Gui 13: Font, s16 bold
			Gui 13: Add, Text, vTthree center,Coordinates for [ %selectedSection% ] have been updated in the Config.ini file
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
	
	Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui 13u: Color, Green
	Gui 13u: Font, cGreen
	Gui 13u: Font, s16 bold
	Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the Config.ini file`n----
	WinSet, ExStyle, ^0x80
	Gui 13u: -caption
	Gui 13u: Show, NoActivate xcenter y0, BottomGUI
	
	Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui 13: Color, White
	Gui 13: Font, s16 bold
	Gui 13: Add, Text, vTthree center,Coordinates for [ %selectedSection% ] have been updated in the Config.ini file
	WinSet, ExStyle, ^0x80
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

sectionList := " ***** Make a Selection ***** "
hotkeyConfigFiles := {}

; Add sections from Config.ini that are explicitly categorized as hotkeys.
; Store the source file at the same time the section is added.
Loop, Parse, allContents, `n, `r
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
	}
}

; Add sections from LLARS Config.ini that are explicitly categorized as hotkeys.
; Store the source file at the same time the section is added.
Loop, Parse, llarsContents, `n, `r
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

Gui, 3: Add, DropDownList, w230 sort vSectionList Choose1 gDropDownChanged2, % sectionList
Gui, 3: Add, Text, w230 vHotkeysText, Hotkeys will be displayed here
Gui, 3: Add, Hotkey, x97 y60 w60 vChosenHotkey gHotkeyChanged Center, ** NONE **
Gui, 3: Add, Button, x64 y90 w125 gClose2, Close Hotkeys

Gui, 3: Show, w250 h100 Center, Hotkeys
Gui 3: -Caption
WinSet, ExStyle, ^0x80
WinSet, Transparent, %value%
return

; Closes the hotkey editor and returns to the main LLARS GUI.
Close2:
Gui 3: Destroy
Gui 1: Show
EnableHotkey()
return

; Loads the existing hotkey for the selected section.
; The source INI file is taken directly from the mapping created
; when the dropdown list was built.
DropDownChanged2:
GuiControlGet, selectedSection,, SectionList

if (selectedSection != " ***** Make a Selection ***** ")
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

; Saves the newly selected hotkey to the same configuration file
; from which the selected section was loaded.
HotkeyChanged:
Gui, 3: Submit, NoHide

configFile := hotkeyConfigFiles[selectedSection]

IniWrite, %ChosenHotkey%, %configFile%, %selectedSection%, Hotkey
Log("HOTKEY CHANGED", "Hotkey = " ChosenHotkey)

Gui, 3: Destroy

Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
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

; ======================================================================
; |     TIMER BUTTON     -     TIMER BUTTON     -     TIMER BUTTON     |
; ======================================================================

; Open the Timer configuration editor.
; Reads the current minimum and maximum click intervals from Config.ini.
Timer:
Log("TIMER CONFIG", "Opening Timer configuration editor")

Gui 1: Hide
Gui Combo: Destroy
DisableHotkey()

; Read current Timer settings from Config.ini
IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max

Log("TIMER CONFIG", "Current values loaded - Min=" sa1 "ms, Max=" sa2 "ms")

; Timer configuration GUI
Gui 5: +LastFound +AlwaysOnTop +OwnDialogs
Gui 5: Font, bold s12
Gui 5: Add, Text, x5 w190 center, Click Timer Interval
Gui 5: Font, s10
Gui 5: Add, Text, x5 w190 center, timers are in ms`n1000ms = 1sec
Gui 5: Add, Text,,
Gui 5: Font, s11
Gui 5: Add, Text, center x5 w190, Minimum click timer
Gui 5: Add, Edit, vMinEdit center x50 w100, % sa1
Gui 5: Add, Text,,
Gui 5: Add, Text, center x5 w190, Maximum click timer
Gui 5: Add, Edit, vMaxEdit center x50 w100, % sa2
Gui 5: Add, Text,,
Gui 5: Add, Button, Default gButtonSave x50 w100, Save Timer

WinSet, ExStyle, ^0x80
Gui 5: -caption
Gui 5: Show, center w200, Timer
Return

; ======================================================================
; |     TIMER SAVE       -     TIMER SAVE       -     TIMER SAVE       |
; ======================================================================

; Save the updated Timer values to Config.ini.
ButtonSave:
GuiControlGet, NewMin,, MinEdit
GuiControlGet, NewMax,, MaxEdit

; Remove accidental spaces
NewMin := Trim(NewMin)
NewMax := Trim(NewMax)

Log("TIMER CONFIG", "Save requested - Min=" NewMin "ms, Max=" NewMax "ms")

; Validate timer values before writing them to Config.ini.
if (NewMin = "" || NewMax = "")
{
	Log("CONFIG ERROR", "Timer save failed - minimum or maximum timer is blank")
	MsgBox, 48, Timer Error, Minimum and maximum timer values cannot be blank.
	Return
}

if !RegExMatch(NewMin, "^\d+$") || !RegExMatch(NewMax, "^\d+$")
{
	Log("CONFIG ERROR", "Timer save failed - minimum or maximum timer is not numeric")
	MsgBox, 48, Timer Error, Minimum and maximum timer values must contain numbers only.
	Return
}

if (NewMin > NewMax)
{
	Log("CONFIG ERROR", "Timer save failed - minimum timer is greater than maximum timer")
	MsgBox, 48, Timer Error, Minimum timer cannot be greater than maximum timer.
	Return
}

; Write validated Timer settings to Config.ini.
IniWrite, %NewMin%, Config.ini, Timer, min
IniWrite, %NewMax%, Config.ini, Timer, max

Log("TIMER CONFIG", "Timer values written to Config.ini - Min=" NewMin "ms, Max=" NewMax "ms")

Gui 5: Destroy

; Display confirmation message.
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center, ----Timer has been updated in the Config.ini file`n----
WinSet, ExStyle, ^0x80
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI

Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, cGreen
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, Timer has been updated in the Config.ini file
WinSet, ExStyle, ^0x80
Gui 13: -caption
Gui 13: Show, NoActivate xcenter y9999, TopGUI

; Position the confirmation GUIs.
WinGetPos,,,,bottomH, BottomGUI
WinGetPos,,,,topH, TopGUI

topPOS := (bottomH - topH) / 2

Gui, TopGUI: +LabelTopGUI
WinMove, TopGUI,, , %topPOS%

Sleep, 1500


; Clean up and return to the main LLARS GUI.
Gui 13u: Destroy
Gui 13: Destroy
Gui 1: Show
EnableHotkey()

Log("TIMER CONFIG", "Timer configuration update completed")
Return

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

; ======================================================================
; |     HOTKEY CHECK     -     HOTKEY CHECK     -     HOTKEY CHECK     |
; ======================================================================

; Periodically reloads the configured LLARS menu hotkeys while the
; script is idle, allowing hotkey changes in LLARS Config.ini to take
; effect without restarting the script.
Configcheck:
IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, information
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, color/coordinate/hotkey
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit

Hotkey %lhk1%, Start
Hotkey %lhk2%, Info
Hotkey %lhk3%, Combo
Hotkey %lhk4%, exitb
return

; Periodically reloads the LLARS hotkeys used while the timed script
; is running, where the information/menu hotkeys become Pause/Resume.
Config2check:
IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, information
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, color/coordinate/hotkey
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit

Hotkey, %lhk1%, Start
Hotkey, %lhk2%, pauseb
Hotkey, %lhk3%, resumeb
Hotkey, %lhk4%, exitb
return

; ===================================================================
; |     TIMER LOGIC     -     TIMER LOGIC     -     TIMER LOGIC     |
; ===================================================================

; Updates the remaining run time every second and handles the normal
; completion sequence once the configured timer reaches zero.
Countdown:
remainingTimeMS := endTime - A_TickCount
remainingTimeMinutes := Floor(remainingTimeMS / 60000)
remainingTimeSeconds := Mod(Floor(remainingTimeMS / 1000), 60)

GuiControl,, TimerCount, %remainingTimeMinutes%m %remainingTimeSeconds%s
DisableButton()

if (remainingTimeMS <= 0 and startcheck=1)
{
	SetTimer, Countdown, off
	SetTimer, RandomClick, Off
	GuiControl,, TimerCount, Done
	GuiControl,,State3, Done
	EnableButton()
	Logout()
	Goto EndMsg
}
return

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

; Starts a timed automation run. The selected duration is converted to
; milliseconds, the running-state GUI is created, the hotkey assignments
; switch to Pause/Resume behavior, and the pixel detection timer begins.
Start:
ConfigError()

Log("START", "Start button/hotkey activated")

InputBox, timeToRunMinutes, Set Timer, Enter the time duration in minutes`n(example: 1 for 1 minute):,,250,150

if (timeToRunMinutes = "" or timeToRunMinutes = 0)
{
	MsgBox, 48, Invalid Input, Please enter a valid number greater than 0.
	return
}

timeToRunMS := timeToRunMinutes * 60 * 1000
endTime := A_TickCount + timeToRunMS

Log("TIMER", "Timer set to " timeToRunMinutes " minutes")

; On the first run, stop the idle hotkey watcher and switch the LLARS
; hotkeys to their running-state Pause/Resume assignments.
If (frcount = 0)
{
	SetTimer, ConfigCheck, off
	SetTimer, Config2Check, 250
	
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, information
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, color/coordinate/hotkey
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	IniRead, value, LLARS Config.ini, Transparent, value
	
	Hotkey %lhk1%, Start
	Hotkey %lhk2%, pauseb
	Hotkey %lhk3%, resumeb
	Hotkey %lhk4%, exitb
	
	; Rebuild the main GUI into its running-state layout.
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	Gui, Font, s11
	Gui, font, bold
	Gui, Add, Button, x5 y5 w100 h25 gStart , Start
	Gui, Add, Button, x115 y5 w100 h25 gInfo, Information
	Gui, Add, Button, x5 y35 w100 h25 gPauseb , Pause
	Gui, Add, Button, x115 y35 w100 h25 gResumeb , Resume
	Gui, Add, Button, x35 y115 w150 h25 gExitb , Exit LLARS
	Gui, Font, cBlue
	Gui, Add, Text, x135 y65 w70 h25 vState3
	Gui, Add, Text, x8 y65 w125 h25 vScriptBlue
	Gui, Add, Text, x8 y90 w100 h25 vTimerLabel
	Gui, Add, Text, x135 y90 w70 h25 vTimerCount
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
	WinMove, LLARS,, X, Y,
}

else
	
sleep 250

; ======================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<  |
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<  |
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<  |
; ======================================================================

; Set the running-state display and begin the countdown/pixel timers.
GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running
DisableButton()
startcheck=1

SetTimer, Countdown, 1000

IfWinNotActive, RuneScape
{
			WinActivate, RuneScape
}

; ========================================================================================
; |     RANDOM CLICK LOGIC     -     RANDOM CLICK LOGIC     -     RANDOM CLICK LOGIC     |
; ========================================================================================

; Start the initial random click routine.
; The original click and timer sequence is preserved.
Log("AUTOCLICKER", "Random click routine started")

; Loads the configured rectangular Click location.
IniRead, x1, Config.ini, Click, xmin
IniRead, x2, Config.ini, Click, xmax
IniRead, y1, Config.ini, Click, ymin
IniRead, y2, Config.ini, Click, ymax

; Selects a random coordinate inside the configured Click rectangle.
Random, x, %x1%, %x2%
Random, y, %y1%, %y2%

; Performs the initial random click.
Click, %x%, %y%

; Records the time the initial click occurred for logging.
LastClickTime := A_TickCount

; Logs the initial click after the original click operation.
Log("CLICK", "Click Location X=" x " Y=" y " | N/A - first click")

; Loads the configured minimum and maximum timer values.
IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max

; Selects the randomized delay before the next click.
Random, SleepClick, %sa1%, %sa2%

; Starts the randomized click timer.
SetTimer, RandomClick, %SleepClick%

; Logs the randomized wait after the timer has been started.
Log("WAIT", "Random sleep before click: " SleepClick " ms")

; Displays a temporary tooltip indicating that the AutoClicker has been activated.
Loop 100
{
	MouseGetPos, xm, ym
	ToolTip, Activated AutoClicker, (xm+15), (ym+15), 1
	Sleep 25
}
ToolTip

Return

; ========================================================================================
; |     RANDOM CLICK TIMER     -     RANDOM CLICK TIMER     -     RANDOM CLICK TIMER     |
; ========================================================================================

; Performs each subsequent random click.
; The original click and timer sequence is preserved.
; Config.ini is re-read each time the timer fires.
RandomClick:
{
	; Makes sure RuneScape is the active window before clicking.
	IfWinNotActive, RuneScape
	{
		WinActivate, RuneScape
	}

	DisableButton()

	; Loads the configured rectangular Click location.
	IniRead, x1, Config.ini, Click, xmin
	IniRead, x2, Config.ini, Click, xmax
	IniRead, y1, Config.ini, Click, ymin
	IniRead, y2, Config.ini, Click, ymax

	; Selects a random coordinate inside the configured Click rectangle.
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%

	; Performs the random click.
	Click, %x%, %y%

	; Calculates and records the time since the previous click.
	if (LastClickTime = 0)
	{
		TimeSinceClick := "N/A - first click"
	}
	else
	{
		TimeSinceClick := A_TickCount - LastClickTime " ms since previous click"
	}

	LastClickTime := A_TickCount

	; Logs the click after the original click operation.
	Log("CLICK", "Click Location X=" x " Y=" y " | " TimeSinceClick)

	; Loads the configured minimum and maximum timer values.
	IniRead, sa1, Config.ini, Timer, min
	IniRead, sa2, Config.ini, Timer, max

	; Selects the next randomized click delay.
	Random, SleepClick, %sa1%, %sa2%

	; Sets the next timer exactly as the original routine did.
	SetTimer, RandomClick, %SleepClick%

	; Logs the randomized wait after the timer has been started.
	Log("WAIT", "Random sleep before click: " SleepClick " ms")

	; Displays the AutoClicker tooltip.
	Loop 100
	{
		MouseGetPos, xm, ym
		ToolTip, Activated AutoClicker, (xm+15), (ym+15), 1
		Sleep 25
	}
	ToolTip
}
Return

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

; ===============================================================================
; |     LOGOUT FUNCTION     -     LOGOUT FUNCTION     -     LOGOUT FUNCTION     |
; ===============================================================================

; Handles the optional logout sequence after the timed run completes.
; When enabled, the script presses Escape, waits for a random delay,
; selects a random point within the configured logout region, and clicks it.
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
		
		; Logout coordinates are stored in screen coordinates rather than
		; the normal client-relative coordinate mode.
		IniRead, x1, LLARS Config.ini, Logout, xmin
		IniRead, x2, LLARS Config.ini, Logout, xmax
		IniRead, y1, LLARS Config.ini, Logout, ymin
		IniRead, y2, LLARS Config.ini, ymax
		
		; Choose a random point within the configured logout rectangle.
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		
		Log("LOGOUT CLICK", "Logout coordinates X=" x " Y=" y)
		
		Click, %x%, %y%
		
		Log("LOGOUT", "Logout click completed")
	}
}

; =================================================================================================
; |     SCRIPT FINISH MESSAGE     -     SCRIPT FINISH MESSAGE     -     SCRIPT FINISH MESSAGE     |
; =================================================================================================

; Calculate the completed run duration in hours and minutes and display
; the final completion notification.
EndMsg:
hours := timeToRunMinutes // 60
minutes := Mod(timeToRunMinutes, 60)

Log("COMPLETE", "Script completed normally | Total time: " hours "h " minutes "m")

SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nTotal time: %hours%h %minutes%m
return

; ==========================================================================================================
; |     INFORMATION BUTTON LOGIC     -     INFORMATION BUTTON LOGIC     -     INFORMATION BUTTON LOGIC     |
; ==========================================================================================================

; Display the current LLARS hotkeys and additional configuration values.
; This GUI is informational only and does not modify the configuration.
info:
DisableHotkey()
IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
IniRead, lhk3, LLARS Config.ini, config/resume
IniRead, lhk4, LLARS Config.ini, exit
IniRead, logout, LLARS Config.ini, Logout, option
IniRead, sleepoption, LLARS Config.ini, Random Sleep, option
IniRead, chance, LLARS Config.ini, Random Sleep, chance

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
Gui 20: Add, Text, Center w220 x5,Start: %lhk1%`nCoordinates/Pause: %lhk2%`nHotkey/Resume: %lhk3%`nExit: %lhk4%
Gui 20: Add, Text, center x5 w220,
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
Gui 20: add, button, gCloseInfo w150 x40 center,Close Information
WinSet, ExStyle, ^0x80
Gui 20: -caption
Gui 20: Show, center w230, Information
return

; Close the Information GUI and restore the main LLARS window.
CloseInfo:
EnableHotkey()
gui 20: destroy
gui 1: Show		
return

; Open the Discord community link after closing the Information GUI.
discord:
EnableHotkey()
Gui 20: destroy
Run, https://discord.gg/Wmmf65myPG
gui 1: Show		
return

; Open the main script configuration file.
InfoConfig:
EnableHotkey()
Run %A_ScriptDir%\Config.ini
return

; Open the LLARS configuration file.
InfoLLARS:
EnableHotkey()
Run %A_ScriptDir%\LLARS Config.ini
return

; Open the project GitHub page from the configuration error GUI.
GitLink:
run, https://github.com/Gubna-Tech/RuneScape
Exitapp

; Open Discord from a startup/configuration error and then terminate.
DiscordError:
Run, https://discord.gg/Wmmf65myPG
Exitapp

; Close the script from the configuration error GUI.
CloseError:	
ExitApp

; Open the project's MIT license page.
MIT:
run https://github.com/Gubna-Tech/RuneScape
return