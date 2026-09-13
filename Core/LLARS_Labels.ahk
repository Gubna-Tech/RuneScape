; ================================================================
; |     LLARS LABEL LIBRARY     -     LLARS LABEL LIBRARY        |
; ================================================================

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

Else IfWinActive, Reset Configuration
{
	EnableHotkey()
	GoSub, CloseResetConfig
}

Return

; Refreshes shared LLARS hotkeys and the main GUI configuration status.
CheckLLARSConfig:
LLARS_CheckHotkeyConfig()
LLARS_UpdateConfigStatus()
return

; Updates the temporary Random Sleep countdown shown in the status area.
UpdateCountdown:
RemainingTime := EndTime - A_TickCount
if (RemainingTime > 0)
{
	GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RemainingTime)
}

return

; Formats a millisecond countdown as minutes and seconds for the GUI.
RandomSleepAmountToMinutesSeconds(time)
{
	minutes := Floor(time / 60000)
	seconds := Mod(Floor(time / 1000), 60)
	return minutes . "m " . seconds . "s"
}

; =========================================================================
; |     ESTIMATED TIME COUNTDOWN     -     ESTIMATED TIME COUNTDOWN       |
; =========================================================================

; Updates the current-loop and full-run estimates shown by RunCount scripts.
UpdateEstimatedTime:
if (!LLARS_RUNNING)
	return

if (EstCompletedLoops = 0 && EstConfiguredFirstLoopAverage > 0)
{
	EstimatedLoopTime := EstConfiguredFirstLoopAverage
}

else if (EstFollowingCompletedLoops > 0 && EstFollowingAverageLoopTime > 0)
{
	EstimatedLoopTime := EstFollowingAverageLoopTime
}

else if (EstConfiguredFollowingLoopAverage > 0)
{
	EstimatedLoopTime := EstConfiguredFollowingLoopAverage
}

else if (EstConfiguredLoopAverage > 0)
{
	EstimatedLoopTime := EstConfiguredLoopAverage
}

else
{
	GuiControl,, EstLoopRemaining, Calculating
	GuiControl,, EstRunRemaining, Calculating
	return
}

if (EstLoopStartTick > 0)
{
	ElapsedLoopTime := A_TickCount - EstLoopStartTick
	PredictiveLoopRemainingTime := EstimatedLoopTime - ElapsedLoopTime
}

else
{
	PredictiveLoopRemainingTime := EstimatedLoopTime
}

if (PredictiveLoopRemainingTime < 0)
	PredictiveLoopRemainingTime := 0
if (EstFinalSleepActive && EstFinalSleepEndTick > 0)
	EstLoopRemainingTime := EstFinalSleepEndTick - A_TickCount
else
	EstLoopRemainingTime := PredictiveLoopRemainingTime
if (EstLoopRemainingTime < 0)
	EstLoopRemainingTime := 0
EstLoopTotalSeconds := Floor(EstLoopRemainingTime / 1000)
EstLoopHours := Floor(EstLoopTotalSeconds / 3600)
EstLoopMinutes := Floor(Mod(EstLoopTotalSeconds, 3600) / 60)
EstLoopSeconds := Mod(EstLoopTotalSeconds, 60)
EstLoopDisplay := EstLoopHours "h " EstLoopMinutes "m " EstLoopSeconds "s"
GuiControl,, EstLoopRemaining, %EstLoopDisplay%
if (EstFollowingCompletedLoops > 0 && EstFollowingAverageLoopTime > 0)
	FutureLoopTime := EstFollowingAverageLoopTime
else if (EstConfiguredFollowingLoopAverage > 0)
	FutureLoopTime := EstConfiguredFollowingLoopAverage
else
	FutureLoopTime := EstimatedLoopTime

if (EstLoopStartTick > 0)
	LoopsRemaining := runcount3 - count
else
	LoopsRemaining := runcount3
if (LoopsRemaining < 0)
	LoopsRemaining := 0
if (EstLoopStartTick > 0)
	EstRunRemainingTime := EstLoopRemainingTime + (LoopsRemaining * FutureLoopTime)
else if (LoopsRemaining > 0)
	EstRunRemainingTime := EstimatedLoopTime + ((LoopsRemaining - 1) * FutureLoopTime)
else
	EstRunRemainingTime := 0
if (EstRunRemainingTime < 0)
	EstRunRemainingTime := 0
EstRunTotalSeconds := Floor(EstRunRemainingTime / 1000)
EstRunHours := Floor(EstRunTotalSeconds / 3600)
EstRunMinutes := Floor(Mod(EstRunTotalSeconds, 3600) / 60)
EstRunSeconds := Mod(EstRunTotalSeconds, 60)
EstRunDisplay := EstRunHours "h " EstRunMinutes "m " EstRunSeconds "s"
GuiControl,, EstRunRemaining, %EstRunDisplay%
return

; =====================================================================
; |     COMBO BUTTON     -     COMBO BUTTON     -     COMBO BUTTON    |
; =====================================================================

; Handles normal LLARS shutdown, saves the GUI position, closes the
Combo:
Gui 1: Hide
DisableHotkey()
Menu, Tray, NoIcon
Gui Combo: +LastFound +OwnDialogs +AlwaysOnTop
Gui Combo: Font, s12 Bold cBlack
Gui Combo: Add, Text, x5 y5 w210 h25 Center, LLARS
Gui Combo: Font, s10 Bold cGray
Gui Combo: Add, Text, x5 y29 w210 h18 Center, Configuration
Gui Combo: Add, Text, x5 y49 w210 h2 0x10
Gui Combo: Font, s10 Bold cBlack
Gui Combo: Add, Button, x25 y57 w170 h25 gColor, Colors
Gui Combo: Add, Button, x25 y86 w170 h25 gCoordinates, Coordinates
Gui Combo: Add, Button, x25 y115 w170 h25 gHotkey, Hotkeys

; Scripts may optionally add one script-specific configuration button.
if (LLARS_COMBO_TIMER_LABEL != "")
{
	Gui Combo: Add, Button, x25 y144 w170 h25 gLLARS_CustomComboTimer, Timer
	Gui Combo: Add, Text, x5 y176 w210 h2 0x10
	Gui Combo: Add, Button, x25 y184 w170 h29 gCloseCombo, Close
	comboHeight := 220
}

else
{
	Gui Combo: Add, Text, x5 y147 w210 h2 0x10
	Gui Combo: Add, Button, x25 y155 w170 h29 gCloseCombo, Close
	comboHeight := 191
}

WinSet, ExStyle, ^0x80
Gui Combo: -caption
Gui Combo: Show, center w220 h%comboHeight%, Combo
return

; Opens the optional script-owned Timer/configuration editor.
LLARS_CustomComboTimer:
if (LLARS_COMBO_TIMER_LABEL != "")
	GoSub, %LLARS_COMBO_TIMER_LABEL%
return

; Returns from the Combo menu to the main LLARS window.
closecombo:
Gui Combo: Destroy
Gui 1: Show
EnableHotkey()
return

; =====================================================================
; |     RESET CONFIG GUI     -     RESET CONFIG GUI                    |
; =====================================================================

; Builds a reset list from the script's Config.ini only. An entry is
; included only when its section is explicitly type=hotkey, coordinate,
; or color and currently contains a saved value. Other configuration
; values such as offsets, timers, ranges, options, and chances can never
; be selected or modified by this GUI.
ResetConfig:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, %LLARS_CONFIG_FILE%, GUI POS, guix
IniWrite, %GUIyc%, %LLARS_CONFIG_FILE%, GUI POS, guiy
Gui 1: Hide
Gui Combo: Destroy
DisableHotkey()
Gui Reset: Destroy
Gui Reset: +LastFound +OwnDialogs +AlwaysOnTop
Gui Reset: Font, s10 Bold
resetConfigItems := {}
resetSectionList := " ***** Make a Selection ***** "
IniRead, resetSections, Config.ini

if (resetSections != "ERROR")
{
	Loop, Parse, resetSections, `n, `r
	{
		resetSection := Trim(A_LoopField)
		if (resetSection = "")
			continue

		resetType := GetConfigType("Config.ini", resetSection)
		if (resetType != "hotkey" && resetType != "coordinate" && resetType != "color")
			continue

		if !LLARS_ConfigItemHasResettableValue("Config.ini", resetSection, resetType)
			continue

		if (resetType = "hotkey")
			resetTypeDisplay := "Hotkey"
		else if (resetType = "coordinate")
			resetTypeDisplay := "Coordinate"
		else
			resetTypeDisplay := "Color"

		resetDisplay := resetTypeDisplay " - " resetSection
		resetSectionList .= "|" resetDisplay
		resetConfigItems[resetDisplay] := {section: resetSection, type: resetType, typeDisplay: resetTypeDisplay}
	}
}

Gui Reset: Add, Text, x10 y10 w300 h20 Center, Reset Saved Configuration
Gui Reset: Font, s10 Norm
Gui Reset: Add, Text, x10 y34 w300 h32 Center, Only saved Hotkeys, Coordinates, and Colors can be reset.
Gui Reset: Font, s10 Bold
Gui Reset: Add, DropDownList, x10 y70 w300 vResetSectionList Choose1 gResetConfigSelection, %resetSectionList%
Gui Reset: Add, Button, x10 y104 w145 h27 vResetConfigButton gResetSelectedConfig Disabled, Reset Selected
Gui Reset: Add, Button, x165 y104 w145 h27 gResetAllConfig, Clear All
Gui Reset: Add, Button, x10 y137 w300 h27 gCloseResetConfig, Cancel
Gui Reset: -Caption
Gui Reset: Show, w320 h174 Center, Reset Configuration
WinSet, ExStyle, ^0x80
WinSet, Transparent, %value%
return

; Enables the reset button only after a real, framework-recognized item
; from the generated list has been selected.
ResetConfigSelection:
GuiControlGet, resetSelection, Reset:, ResetSectionList
if (resetConfigItems.HasKey(resetSelection))
	GuiControl, Reset: Enable, ResetConfigButton
else
	GuiControl, Reset: Disable, ResetConfigButton
return

; Clears only the recognized key(s) belonging to the selected typed editor
; section. The section itself and every unrelated key remain untouched.
ResetSelectedConfig:
GuiControlGet, resetSelection, Reset:, ResetSectionList
if !resetConfigItems.HasKey(resetSelection)
	return

resetItem := resetConfigItems[resetSelection]
resetSection := resetItem.section
resetType := resetItem.type
resetTypeDisplay := resetItem.typeDisplay
Gui Reset: Destroy

if !LLARS_ResetConfigItem("Config.ini", resetSection, resetType)
{
	MsgBox, 48, Reset Configuration, The selected configuration value could not be reset.
	Gui 1: Show
	EnableHotkey()
	return
}

Log("CONFIG RESET", resetTypeDisplay " | " resetSection)
LLARS_UpdateConfigStatus()
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----%resetTypeDisplay% [ %resetSection% ] has been reset in the Config.ini file`n----
WinSet, ExStyle, ^0x80
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI
Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, %resetTypeDisplay% [ %resetSection% ] has been reset in the Config.ini file
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


; Clears every saved framework-recognized Hotkey, Coordinate, and Color
; currently shown by the Reset Config GUI. No other Config.ini keys can be
; touched because every item still passes through LLARS_ResetConfigItem().
ResetAllConfig:
resetCount := 0
for resetDisplay, resetItem in resetConfigItems
	resetCount++

if (resetCount = 0)
	return

Gui Reset: Destroy
MsgBox, 36, Reset Configuration, Clear all saved Hotkeys, Coordinates, and Colors?`n`nOffsets, timers, options, ranges, and all other settings will remain unchanged.
IfMsgBox, No
{
	Gui 1: Show
	EnableHotkey()
	return
}

resetChanged := false
for resetDisplay, resetItem in resetConfigItems
{
	if LLARS_ResetConfigItem("Config.ini", resetItem.section, resetItem.type)
	{
		resetChanged := true
		Log("CONFIG RESET", resetItem.typeDisplay " | " resetItem.section)
	}
}

if !resetChanged
{
	MsgBox, 48, Reset Configuration, No saved Hotkeys, Coordinates, or Colors could be reset.
	Gui 1: Show
	EnableHotkey()
	return
}

LLARS_UpdateConfigStatus()
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----All saved Hotkeys, Coordinates, and Colors have been reset in the Config.ini file`n----
WinSet, ExStyle, ^0x80
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI
Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, All saved Hotkeys, Coordinates, and Colors have been reset in the Config.ini file
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

; Cancels the reset workflow without changing Config.ini.
CloseResetConfig:
Gui Reset: Destroy
Gui 1: Show
EnableHotkey()
return

; ===============================================================================
; |     COORDINATES GUI     -     COORDINATES GUI     -     COORDINATES GUI     |
; ===============================================================================

; Builds the coordinate editor dynamically by checking the type assigned
; to each configuration section. Sections marked type=coordinate are
; automatically included without requiring their names in the script.
Coordinates:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, %LLARS_CONFIG_FILE%, GUI POS, guix
IniWrite, %GUIyc%, %LLARS_CONFIG_FILE%, GUI POS, guiy
Gui 1: Hide
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop
Gui 2: Font, s12 Bold cBlack
Gui 2: Add, Text, x5 y5 w280 h25 Center, LLARS
Gui 2: Font, s10 Bold cGray
Gui 2: Add, Text, x5 y29 w280 h18 Center, %scriptname%
Gui 2: Add, Text, x10 y49 w270 h2 0x10
Gui 2: Font, s10 Bold cBlack
DisableHotkey()
IniRead, allContents, Config.ini
IniRead, llarsContents, %LLARS_CONFIG_FILE%
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
	if (GetConfigType(LLARS_CONFIG_FILE, currentSection) = "coordinate")
		sectionList .= "|" currentSection
}

Gui, 2: Add, DropDownList, x30 y58 w230 vSectionList Choose1 gDropDownChanged, % sectionList
Gui, 2: Add, Button, x60 y91 w170 h25 gClose, Close Coordinates
Gui 2: -Caption
Gui, 2: Show, w290 h126 Center, Coordinates
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
if (selectedSection = "" || selectedSection = " " || selectedSection = " ***** Make a Selection ***** " || selectedSection = " ---- Script Coordinates ---- " || selectedSection = " ---- LLARS Coordinates ---- ")
	return

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

		; Show the selected area while the saved confirmation is visible.
		LLARS_ShowCoordinatePreview(xmin, ymin, xmax, ymax)
		SetTimer, CheckClicks, Off
		if (ButtonText = "Logout")
			configFile := LLARS_CONFIG_FILE
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
			Gui 13: Font, s16 bold
			Gui 13: Add, Text, vTthree center,Coordinates for [ %selectedSection% ] have been updated in the Config.ini file
			Gui 13: -caption
			Gui 13: Show, NoActivate xcenter y9999, TopGUI
		}

		wingetpos,,,,bottomH, BottomGUI
		wingetpos,,,,topH, TopGUI
		topPOS := (bottomH - topH) / 2
		Gui, TopGUI: +LabelTopGUI
		WinMove, TopGUI,, , %topPOS%
		Sleep, 1500
		LLARS_HideCoordinatePreview()
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

; Draws a temporary border around a two-click coordinate range so the user
; can visually confirm the saved rectangle before continuing.
LLARS_ShowCoordinatePreview(x1, y1, x2, y2)
{
	LLARS_HideCoordinatePreview()

	; Mouse coordinates are captured relative to the RuneScape client area.
	; Convert them to screen coordinates before positioning the preview GUIs.
	LLARS_ClientToScreen(x1, y1)
	LLARS_ClientToScreen(x2, y2)
	border := 3
	left := (x1 < x2) ? x1 : x2
	top := (y1 < y2) ? y1 : y2
	right := (x1 > x2) ? x1 : x2
	bottom := (y1 > y2) ? y1 : y2
	width := right - left + 1
	height := bottom - top + 1

	; Keep very small selections visible without changing the saved coordinates.
	if (width < border * 2)
		width := border * 2
	if (height < border * 2)
		height := border * 2

	; Four click-through GUI strips form an outline without covering the selection.
	Gui, 14: +AlwaysOnTop -Caption -Border +ToolWindow +E0x20
	Gui, 14: Color, Red
	Gui, 14: Show, NoActivate x%left% y%top% w%width% h%border%, LLARSCoordinatePreviewTop
	bottomY := top + height - border
	Gui, 15: +AlwaysOnTop -Caption -Border +ToolWindow +E0x20
	Gui, 15: Color, Red
	Gui, 15: Show, NoActivate x%left% y%bottomY% w%width% h%border%, LLARSCoordinatePreviewBottom
	Gui, 16: +AlwaysOnTop -Caption -Border +ToolWindow +E0x20
	Gui, 16: Color, Red
	Gui, 16: Show, NoActivate x%left% y%top% w%border% h%height%, LLARSCoordinatePreviewLeft
	rightX := left + width - border
	Gui, 17: +AlwaysOnTop -Caption -Border +ToolWindow +E0x20
	Gui, 17: Color, Red
	Gui, 17: Show, NoActivate x%rightX% y%top% w%border% h%height%, LLARSCoordinatePreviewRight
}

; Converts RuneScape client coordinates to absolute screen coordinates for
; temporary overlays. This does not change the coordinates saved to Config.ini.
LLARS_ClientToScreen(ByRef x, ByRef y)
{
	hWnd := WinExist("RuneScape")
	if (!hWnd)
		return

	VarSetCapacity(point, 8, 0)
	NumPut(x, point, 0, "Int")
	NumPut(y, point, 4, "Int")
	DllCall("ClientToScreen", "Ptr", hWnd, "Ptr", &point)
	x := NumGet(point, 0, "Int")
	y := NumGet(point, 4, "Int")
}

; Removes the temporary coordinate selection outline.
LLARS_HideCoordinatePreview()
{
	Gui, 14: Destroy
	Gui, 15: Destroy
	Gui, 16: Destroy
	Gui, 17: Destroy
}

; ================================================================
; |     COLORS GUI     -     COLORS GUI     -     COLORS GUI     |
; ================================================================

; Builds the color editor dynamically by using the type assigned to
; each configuration section. Sections marked type=color are
; automatically included without requiring their names in the script.
Color:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, %LLARS_CONFIG_FILE%, GUI POS, guix
IniWrite, %GUIyc%, %LLARS_CONFIG_FILE%, GUI POS, guiy
Gui 1: Hide
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop
Gui 2: Font, s12 Bold cBlack
Gui 2: Add, Text, x5 y5 w280 h25 Center, LLARS
Gui 2: Font, s10 Bold cGray
Gui 2: Add, Text, x5 y29 w280 h18 Center, %scriptname%
Gui 2: Add, Text, x10 y49 w270 h2 0x10
Gui 2: Font, s10 Bold cBlack
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

Gui, 2: Add, DropDownList, x30 y58 w230 vSectionList Choose1 gDropDownChanged1, % sectionList
Gui, 2: Add, Button, x60 y91 w170 h25 gClose1, Close Colors
Gui 2: -Caption
Gui, 2: Show, w290 h126 Center, Colors
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
colorKey := LLARS_GetColorKey("Config.ini", ButtonText)
IniWrite, %color%, Config.ini, %ButtonText%, %colorKey%
Log("COLOR CHANGED IN CONFIG", ButtonText " | " colorKey " = " color)
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
IniWrite, %GUIxc%, %LLARS_CONFIG_FILE%, GUI POS, guix
IniWrite, %GUIyc%, %LLARS_CONFIG_FILE%, GUI POS, guiy
Gui 1: Hide
Gui Combo: Destroy
Gui 3: +LastFound +OwnDialogs +AlwaysOnTop
Gui 3: Font, s12 Bold cBlack
Gui 3: Add, Text, x5 y5 w280 h25 Center, LLARS
Gui 3: Font, s10 Bold cGray
Gui 3: Add, Text, x5 y29 w280 h18 Center, %scriptname%
Gui 3: Add, Text, x10 y49 w270 h2 0x10
Gui 3: Font, s10 Bold cBlack
DisableHotkey()
IniRead, allContents, Config.ini
IniRead, llarsContents, %LLARS_CONFIG_FILE%
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
	if (GetConfigType(LLARS_CONFIG_FILE, currentSection) = "hotkey")
	{
		sectionList .= "|" currentSection
		hotkeyConfigFiles[currentSection] := LLARS_CONFIG_FILE
	}
}

; Keeps the currently selected valid section locked separately
; from the dropdown selection.
selectedHotkeySection := ""
selectedHotkeyConfigFile := ""
Gui, 3: Add, DropDownList, x30 y58 w230 vSectionList Choose1 gDropDownChanged2, % sectionList
Gui, 3: Add, Text, x30 y88 w230 h18 Center vHotkeysText, Hotkeys will be displayed here
Gui, 3: Add, Hotkey, x115 y109 w60 h23 vChosenHotkey gHotkeyChanged Center Disabled, ** NONE **
Gui, 3: Add, Button, x60 y141 w170 h25 gClose2, Close Hotkeys
Gui 3: -Caption
Gui, 3: Show, w290 h176 Center, Hotkeys
WinSet, ExStyle, ^0x80
WinSet, Transparent, %value%
return

; Closes the hotkey editor and returns to the main LLARS GUI.
Close2:
Gui 3: Destroy
Gui 1: Show
EnableHotkey()
return

; Loads the existing hotkey for the selected section and prepares
; the hotkey control for a replacement value.
DropDownChanged2:
GuiControlGet, selectedSection,, SectionList

; Always invalidate the previously selected hotkey first.
selectedHotkeySection := ""
selectedHotkeyConfigFile := ""

; Disable and clear the hotkey control until a valid section is selected.
GuiControl, Disable, ChosenHotkey
GuiControl,, ChosenHotkey, ** NONE **
if (selectedSection = "" || selectedSection = " " || selectedSection = " ***** Make a Selection ***** " || selectedSection = " ---- Script Hotkeys ---- " || selectedSection = " ---- LLARS Hotkeys ---- ")
{

	; Move focus away from the dropdown so keyboard letters cannot
	; jump to another section while no hotkey section is selected.
	GuiControl, Focus, HotkeysText
	return
}

; Use the configuration file recorded when the dropdown was built.
configFile := hotkeyConfigFiles[selectedSection]

; If the selected entry is not a real configuration section, do nothing.
if (configFile = "")
{
	GuiControl, Focus, HotkeysText
	return
}

; Lock the valid section and configuration file independently
; from the dropdown selection.
selectedHotkeySection := selectedSection
selectedHotkeyConfigFile := configFile
IniRead, existingHotkey, %configFile%, %selectedSection%, Hotkey
GuiControl,, ChosenHotkey, %existingHotkey%
GuiControl, Enable, ChosenHotkey
GoSub, ButtonClicked2
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

; Do nothing unless a valid hotkey section was explicitly selected.
if (selectedHotkeySection = "" || selectedHotkeyConfigFile = "")
	return

Gui, 3: Submit, NoHide

; Use the locked section and configuration file instead of whatever
; the dropdown may currently be highlighting.
IniWrite, %ChosenHotkey%, %selectedHotkeyConfigFile%, %selectedHotkeySection%, Hotkey
if (selectedHotkeyConfigFile = LLARS_CONFIG_FILE)
{
	LLARS_CheckHotkeyConfig()
	hotkeyConfigDisplay := "LLARS Config.ini"
}
else
	hotkeyConfigDisplay := "Config.ini"
Log("HOTKEY CHANGED", "Hotkey = " ChosenHotkey)
Gui, 3: Destroy
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cgreenhite
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----Hotkey has been updated in the %hotkeyConfigDisplay% file`n----
WinSet, ExStyle, ^0x80
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI
Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13: Color, White
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, Hotkey has been updated in the %hotkeyConfigDisplay% file
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
; |     EXIT BUTTON     -     EXIT BUTTON     -     EXIT BUTTON           |
; =========================================================================

; Handles both the Exit button and normal GUI close event.
ExitB:
	Suspend, Permit
guiclose:
Log("EXIT", "LLARS exited normally")
WinGetPos, GUIxc, GUIyc,,,LLARS ahk_class AutoHotkeyGUI
IniWrite, %GUIxc%, %LLARS_CONFIG_FILE%, GUI POS, guix
IniWrite, %GUIyc%, %LLARS_CONFIG_FILE%, GUI POS, guiy
EndLogSession("Normal Exit")
ExitApp

; ===================================================================
; |     INFORMATION     -     INFORMATION     -     INFORMATION     |
; ===================================================================

; Builds the Information window with current LLARS/script hotkeys,
; shared options, configuration shortcuts, and project links.
Info:
DisableHotkey()
IniRead, logout, %LLARS_CONFIG_FILE%, Logout, option
IniRead, sleepoption, %LLARS_CONFIG_FILE%, Random Sleep, option
IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance

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

; Read script-specific hotkeys from Config.ini.
configHotkeys := ""
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
		configHotkeys .= section . ": " . hotkey . "`n"
	}
}

; Add a blank line only when script-specific hotkeys actually exist.
if (configHotkeys != "")
{
	if (scriptHotkeys != "")
		scriptHotkeys .= "`n"
	scriptHotkeys .= configHotkeys
}

if (scriptHotkeys = "")
	scriptHotkeys := "No script hotkeys configured"
else
	scriptHotkeys := RTrim(scriptHotkeys, "`n`r")
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, %LLARS_CONFIG_FILE%, GUI POS, guix
IniWrite, %GUIyc%, %LLARS_CONFIG_FILE%, GUI POS, guiy
Gui 3: hide
; Size the Information GUI from its actual hotkey content so each section
; keeps its own space without relying on relative Y positions.
hotkeyLineCount := 0
Loop, Parse, scriptHotkeys, `n, `r
	hotkeyLineCount++
if (hotkeyLineCount < 1)
	hotkeyLineCount := 1

hotkeyHeight := hotkeyLineCount * 18
hotkeyBoxY := 57
hotkeyTextY := hotkeyBoxY + 21
hotkeyBoxHeight := hotkeyHeight + 29

; When there are no script-specific Config.ini hotkeys, keep the full text
; height so every LLARS hotkey remains visible while trimming only the unused
; bottom padding from the group box.
if (configHotkeys = "")
	hotkeyBoxHeight := hotkeyHeight + 25
additionalTitleY := hotkeyBoxY + hotkeyBoxHeight + 4
optionsBoxY := additionalTitleY + 23
notesBoxY := optionsBoxY + 91
notesBoxHeight := 94
projectDividerY := notesBoxY + notesBoxHeight + 7
mitY := projectDividerY + 8
createdY := mitY + 22
resourceDividerY := createdY + 27
resourceTitleY := resourceDividerY + 8
llarsConfigY := resourceTitleY + 23
scriptConfigY := llarsConfigY + 29
discordY := scriptConfigY + 29
closeDividerY := discordY + 32
closeInfoY := closeDividerY + 8
informationHeight := closeInfoY + 39

Gui 20: +AlwaysOnTop +OwnDialogs +LastFound
Gui 20: Font, s12 Bold cBlack
Gui 20: Add, Text, x5 y5 w280 h25 Center, LLARS
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, Text, x5 y29 w280 h18 Center, Information
Gui 20: Add, Text, x10 y49 w270 h2 0x10
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, GroupBox, x20 y%hotkeyBoxY% w250 h%hotkeyBoxHeight%, Script Hotkeys
Gui 20: Font, s10 Norm cBlack
Gui 20: Add, Text, x32 y%hotkeyTextY% w226 h%hotkeyHeight% Center, %scriptHotkeys%
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, Text, x10 y%additionalTitleY% w270 h20 Center, Script Information
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, GroupBox, x20 y%optionsBoxY% w250 h84, Script Options
Gui 20: Font, s10 Norm cBlack
optionsRow1Y := optionsBoxY + 23
optionsRow2Y := optionsBoxY + 43
optionsRow3Y := optionsBoxY + 63
Gui 20: Add, Text, x35 y%optionsRow1Y% w105 h18, Logout
Gui 20: Add, Text, x35 y%optionsRow2Y% w105 h18, Random Sleep
Gui 20: Add, Text, x35 y%optionsRow3Y% w105 h18, Sleep Chance
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, Text, x145 y%optionsRow1Y% w105 h18 Right, %logout%
Gui 20: Add, Text, x145 y%optionsRow2Y% w105 h18 Right, %sleepoption%
Gui 20: Add, Text, x145 y%optionsRow3Y% w105 h18 Right, %chance%`%
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, GroupBox, x20 y%notesBoxY% w250 h%notesBoxHeight%, Script Notes
notesTextY := notesBoxY + 23
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, Text, x32 y%notesTextY% w226 h62 Center, Additional notes/comments can be found in the Config.ini file or by pressing the Script Config button below.
Gui 20: Add, Text, x10 y%projectDividerY% w270 h2 0x10
Gui 20: Font, s10 Bold cBlue underline
Gui 20: Add, Text, x10 y%mitY% w270 h20 Center gMIT, MIT License
Gui 20: Font, s10 Norm cBlack
Gui 20: Add, Text, x91 y%createdY% w70 h20 Right, Created by
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, Text, x163 y%createdY% w45 h20, Gubna
Gui 20: Add, Text, x10 y%resourceDividerY% w270 h2 0x10
Gui 20: Font, s10 Bold cBlack
Gui 20: Add, Text, x10 y%resourceTitleY% w270 h20 Center, Resources
Gui 20: Add, Button, x60 y%llarsConfigY% w170 h25 gInfoLLARS, LLARS Config
Gui 20: Add, Button, x60 y%scriptConfigY% w170 h25 gInfoConfig, Script Config
Gui 20: Add, Button, x60 y%discordY% w170 h25 gDiscord, Discord
Gui 20: Add, Text, x10 y%closeDividerY% w270 h2 0x10
Gui 20: Add, Button, x60 y%closeInfoY% w170 h29 gCloseInfo, Close Information
WinSet, ExStyle, ^0x80
Gui 20: -caption
Gui 20: Show, center w290 h%informationHeight%, Information
return

; Closes the information window and restores the main LLARS GUI.
CloseInfo:
Gui 1: Default
EnableHotkey()
Gui 20: Destroy
Gui 1: Show
return

; Opens the Discord link from the information GUI and returns to LLARS.
discord:
Gui 1: Default
EnableHotkey()
Gui 20: Destroy
Run, https://discord.gg/Wmmf65myPG
Gui 1: Show
return

; Opens the main script configuration file.
InfoConfig:
EnableHotkey()
Run %LLARS_SCRIPT_DIR%\Config.ini
return

; Opens the LLARS configuration file.
InfoLLARS:
EnableHotkey()
Run %LLARS_CONFIG_FILE%
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

; Handles the Game Not Found prompt and offers an installed client when possible.
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

; Closes the client-detection message and returns to the main LLARS GUI.
CloseClient:
Gui Client: Destroy
Gui 1: Show
return

; Launches the Jagex Launcher from the client-selection window.
Jagex:
Gui Client: Destroy
Gui 1: Show
Run, C:\Program Files (x86)\Jagex Launcher\JagexLauncher.exe
return

; Launches the RuneScape client from the client-selection window.
RuneScape:
Gui Client: Destroy
Gui 1: Show
Run, rs-launch://www.runescape.com/k=5/l=$(Language:0)/jav_config.ws
