; ================================================================
; |     LLARS LABEL LIBRARY     -     LLARS LABEL LIBRARY        |
; ================================================================

; Provides Escape-key shortcuts for closing the various secondary LLARS GUIs through the same close paths used by their Close buttons.
~Esc::
WinGet, LLARS_EscapeActivePID, PID, A
if (LLARS_EscapeActivePID != DllCall("GetCurrentProcessId"))
	Return

IfWinActive, Coordinates ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	GoSub, close
}

Else IfWinActive, Timer ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	LLARS_DeveloperUIAction("Timer Configuration", "Closed")
	Gui 5: Destroy
	Gui 1: Show
}

Else IfWinActive, Information ahk_class AutoHotkeyGUI
{
	GoSub, CloseInfo
}

Else IfWinActive, Timing Audit ahk_class AutoHotkeyGUI
{
	GoSub, CloseDeveloperTimingAudit
}

Else IfWinActive, Developer Mode ahk_class AutoHotkeyGUI
{
	GoSub, CloseDeveloperMode
}

Else IfWinActive, Combo ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	GoSub, closecombo
}

Else IfWinActive, Colors ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	GoSub, close1
}

Else IfWinActive, Hotkeys ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	GoSub, close2
}

Else IfWinActive, Reset Configuration ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	GoSub, CloseResetConfig
}

Else IfWinActive, Multiple Client ahk_class AutoHotkeyGUI
{
	GoSub, CloseClient
}

Else IfWinActive, No Client Detected ahk_class AutoHotkeyGUI
{
	GoSub, CloseClient
}

Else IfWinActive, Config Error ahk_class AutoHotkeyGUI
{
	GoSub, CloseError
}

Else IfWinActive, Game Not Found ahk_class AutoHotkeyGUI
{
	GoSub, CloseGNF
}

Return

; Refreshes shared LLARS hotkeys and the main GUI configuration status.
CheckLLARSConfig:
LLARS_CheckHotkeyConfig()
LLARS_UpdateConfigStatus()
return

; Developer Mode remains available independently of normal control locking.
LLARS_AlwaysOnHotkeyWatchdog:
LLARS_EnableDeveloperHotkey(LLARS_lhk5)
return

; Updates the temporary Random Sleep countdown shown in the status area.
UpdateCountdown:
RemainingTime := EndTime - A_TickCount
if (RemainingTime > 0)
	GuiControl, 1:, State3, % RandomSleepAmountToMinutesSeconds(RemainingTime)
else
	SetTimer, UpdateCountdown, Off

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
LLARS_UpdateEstimatedTimeNow()
return

LLARS_UpdateEstimatedTimeNow()
{
	global LLARS_RUNNING, EstCompletedLoops, EstConfiguredFirstLoopAverage
	global EstFollowingCompletedLoops, EstFollowingAverageLoopTime
	global EstConfiguredFollowingLoopAverage, EstConfiguredLoopAverage
	global EstLoopStartTick, EstRandomSleepAdjustment, EstFinalSleepActive, EstFinalSleepEndTick
	global runcount3, count
	if (!LLARS_RUNNING)
		return

	if (EstCompletedLoops = 0 && EstConfiguredFirstLoopAverage > 0)
	{
		EstimatedLoopTime := EstConfiguredFirstLoopAverage
	}

	else if (EstFollowingCompletedLoops > 0 && EstFollowingAverageLoopTime > 0)
	{
		; Once real following loops exist, their measured average continuously improves the prediction for all remaining ordinary loops.
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
		GuiControl, 1:, EstLoopRemaining, Calculating
		GuiControl, 1:, EstRunRemaining, Calculating
		return
	}

	if (EstLoopStartTick > 0)
	{
		ElapsedLoopTime := A_TickCount - EstLoopStartTick
		PredictiveLoopRemainingTime := EstimatedLoopTime + EstRandomSleepAdjustment - ElapsedLoopTime
	}

	else
	{
		PredictiveLoopRemainingTime := EstimatedLoopTime + EstRandomSleepAdjustment
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
	GuiControl, 1:, EstLoopRemaining, %EstLoopDisplay%
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
	GuiControl, 1:, EstRunRemaining, %EstRunDisplay%
}

; =====================================================================
; |     COMBO BUTTON     -     COMBO BUTTON     -     COMBO BUTTON    |
; =====================================================================

; Handles normal LLARS shutdown, saves the GUI position, closes the
Combo:
LLARS_DeveloperHotkey("Configuration")
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

Gui Combo: +ToolWindow
Gui Combo: -caption
Gui Combo: Show, center w220 h%comboHeight%, Combo
LLARS_DeveloperUIAction("Configuration")
return

; Opens the optional script-owned Timer/configuration editor.
LLARS_CustomComboTimer:
if (LLARS_COMBO_TIMER_LABEL != "")
{
	LLARS_DeveloperUIAction("Configuration", "Closed")
	LLARS_DeveloperUIAction("Timer Configuration")
	GoSub, %LLARS_COMBO_TIMER_LABEL%
}
return

; Returns from the Combo menu to the main LLARS window.
closecombo:
LLARS_DeveloperUIAction("Configuration", "Closed")
Gui Combo: Destroy
Gui 1: Show
EnableHotkey()
return

; =====================================================================
; |     RESET CONFIG GUI     -     RESET CONFIG GUI                    |
; =====================================================================

; Builds a reset list from the script's Config.ini only. An entry is
; included only when its section is explicitly type=hotkey, coordinate,
; or color and currently contains a saved value.
ResetConfig:
LLARS_MainSavePosition()
Gui 1: Hide
Gui Combo: Destroy
DisableHotkey()
Gui Reset: Destroy
Gui Reset: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSResetGuiHwnd
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
LLARS_DeveloperUIAction("Reset Configuration")
Gui Reset: +ToolWindow
WinSet, Transparent, %value%, ahk_id %LLARSResetGuiHwnd%
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

; Clears only the recognized key(s) belonging to the selected typed editor section.
ResetSelectedConfig:
GuiControlGet, resetSelection, Reset:, ResetSectionList
if !resetConfigItems.HasKey(resetSelection)
	return

resetItem := resetConfigItems[resetSelection]
resetSection := resetItem.section
resetType := resetItem.type
resetTypeDisplay := resetItem.typeDisplay
LLARS_DeveloperUIAction("Reset Configuration", "Closed")
Gui Reset: Destroy

if !LLARS_ResetConfigItem("Config.ini", resetSection, resetType)
{
	MsgBox, 48, Reset Configuration, The selected configuration value could not be reset.
	Gui 1: Show
	EnableHotkey()
	return
}

LLARS_DeveloperAction("Config Reset || " . resetTypeDisplay . " || " . resetSection)
LLARS_UpdateConfigStatus()
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----%resetTypeDisplay% [ %resetSection% ] has been reset in the Config.ini file`n----
Gui 13u: +ToolWindow
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


; Clears every saved framework-recognized Hotkey, Coordinate, and Color currently shown by the Reset Config GUI.
; touched because every item still passes through LLARS_ResetConfigItem().
ResetAllConfig:
resetCount := 0
for resetDisplay, resetItem in resetConfigItems
	resetCount++

if (resetCount = 0)
	return

LLARS_DeveloperUIAction("Reset Configuration", "Closed")
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
	}
}

if !resetChanged
{
	MsgBox, 48, Reset Configuration, No saved Hotkeys, Coordinates, or Colors could be reset.
	Gui 1: Show
	EnableHotkey()
	return
}

LLARS_DeveloperAction("Config Reset || Clear All")
LLARS_UpdateConfigStatus()
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----All saved Hotkeys, Coordinates, and Colors have been reset in the Config.ini file`n----
Gui 13u: +ToolWindow
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
LLARS_DeveloperUIAction("Reset Configuration", "Closed")
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
LLARS_MainSavePosition()
Gui 1: Hide
LLARS_DeveloperUIAction("Configuration", "Closed")
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSConfigGuiHwnd
Gui 2: Font, s12 Bold cBlack
Gui 2: Add, Text, x5 y5 w280 h25 Center, LLARS
Gui 2: Font, s10 Bold cGray
Gui 2: Add, Text, x5 y29 w280 h18 Center, Coordinates
Gui 2: Add, Text, x10 y49 w270 h2 0x10
Gui 2: Font, s10 Bold cBlack
DisableHotkey()
scriptHotkeyConfigFile := LLARS_SCRIPT_DIR . "\Config.ini"
IniRead, allContents, %scriptHotkeyConfigFile%
IniRead, llarsContents, %LLARS_CONFIG_FILE%
sectionList := " ***** Make a Selection ***** | "
configCoordinatesFound := false
coordinateConfigFiles := {}

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
	if (GetConfigType(scriptHotkeyConfigFile, currentSection) = "coordinate")
	{
		sectionList .= "|" currentSection
		coordinateConfigFiles[currentSection] := scriptHotkeyConfigFile
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
	{
		sectionList .= "|" currentSection
		coordinateConfigFiles[currentSection] := LLARS_CONFIG_FILE
	}
}

Gui, 2: Add, DropDownList, x30 y58 w230 vSectionList Choose1 gDropDownChanged, % sectionList
Gui, 2: Add, Button, x60 y91 w170 h25 gClose, Close Coordinates
Gui 2: -Caption
Gui, 2: Show, w290 h126 Center, Coordinates
LLARS_DeveloperUIAction("Coordinates")
Gui 2: +ToolWindow
WinSet, Transparent, %value%, ahk_id %LLARSConfigGuiHwnd%
return

; Closes the coordinate editor and returns to the main LLARS window.
Close:
LLARS_DeveloperUIAction("Coordinates", "Closed")
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

; Handles coordinate selection from the section's actual schema.
ButtonClicked:
coordinateConfigFile := coordinateConfigFiles.HasKey(selectedSection) ? coordinateConfigFiles[selectedSection] : "Config.ini"
missingCoordinateKey := "__LLARS_COORDINATE_KEY_MISSING__"
IniRead, pointXKey, %coordinateConfigFile%, %selectedSection%, x, %missingCoordinateKey%
IniRead, pointYKey, %coordinateConfigFile%, %selectedSection%, y, %missingCoordinateKey%
IniRead, rectangleXMinKey, %coordinateConfigFile%, %selectedSection%, xmin, %missingCoordinateKey%
IniRead, rectangleXMaxKey, %coordinateConfigFile%, %selectedSection%, xmax, %missingCoordinateKey%
IniRead, rectangleYMinKey, %coordinateConfigFile%, %selectedSection%, ymin, %missingCoordinateKey%
IniRead, rectangleYMaxKey, %coordinateConfigFile%, %selectedSection%, ymax, %missingCoordinateKey%
hasAnyPointCoordinateKeys := (pointXKey != missingCoordinateKey || pointYKey != missingCoordinateKey)
hasPointCoordinateKeys := (pointXKey != missingCoordinateKey && pointYKey != missingCoordinateKey)
hasAnyRectangleCoordinateKeys := (rectangleXMinKey != missingCoordinateKey || rectangleXMaxKey != missingCoordinateKey || rectangleYMinKey != missingCoordinateKey || rectangleYMaxKey != missingCoordinateKey)
hasRectangleCoordinateKeys := (rectangleXMinKey != missingCoordinateKey && rectangleXMaxKey != missingCoordinateKey && rectangleYMinKey != missingCoordinateKey && rectangleYMaxKey != missingCoordinateKey)

if ((!hasPointCoordinateKeys && hasAnyPointCoordinateKeys) || (!hasRectangleCoordinateKeys && hasAnyRectangleCoordinateKeys) || (hasAnyPointCoordinateKeys && hasAnyRectangleCoordinateKeys) || (!hasAnyPointCoordinateKeys && !hasAnyRectangleCoordinateKeys))
{
	LLARS_CreatorConfigError("Coordinate section [" . selectedSection . "] must define either x/y for one pixel or xmin/xmax/ymin/ymax for a rectangle.")
	return
}

pointCoordinateSection := hasPointCoordinateKeys

if (pointCoordinateSection)
{
    Gui, 2: Hide
    LLARS_ActivateValidatedRuneScape()
    x := ""
    y := ""
    ButtonText := selectedSection
    CoordinateRButtonWasDown := false
    SetTimer, CheckClicksPixel, 10
    Gui 11u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
    Gui 11u: Color, Red
    Gui 11u: Font, cRed
    Gui 11u: Font, s16 bold
    Gui 11u: Add, Text, valertlabel center,----Right-click the pixel for [ %selectedSection% ]`n----
    Gui 11u: +ToolWindow
    Gui 11u: -caption
    Gui 11u: Show, NoActivate xcenter y0, BottomGUI
    Gui 11: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
    Gui 11: Font, s16 bold
    Gui 11: Add, Text, vTone center,Right-click the pixel for [ %selectedSection% ]
    Gui 11: +ToolWindow
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
    LLARS_ActivateValidatedRuneScape()
    ClickCount := 0
    xmin := ""
    ymin := ""
    xmax := ""
    ymax := ""
    ButtonText := selectedSection
    CoordinateRButtonWasDown := false
    SetTimer, CheckClicks, 10
    Gui 11u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
    Gui 11u: Color, Red
    Gui 11u: Font, cRed
    Gui 11u: Font, s16 bold
    Gui 11u: Add, Text, valertlabel center,----Right-click the top-left corner for [ %selectedSection% ]`n----
    Gui 11u: +ToolWindow
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

; Captures the first and second right-click positions for rectangle coordinates, then writes the resulting bounds to the appropriate configuration file.
CheckClicks:
if GetKeyState("Esc", "P")
{
	Reload
}

CoordinateRButtonDown := GetKeyState("RButton")
if (CoordinateRButtonDown && !CoordinateRButtonWasDown)
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
		Gui 12u: +ToolWindow
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
		configFile := (coordinateConfigFile != "") ? coordinateConfigFile : ((ButtonText = "Logout") ? LLARS_CONFIG_FILE : "Config.ini")
		IniWrite, %xmin%, %configFile%, %ButtonText%, xmin
		IniWrite, %xmax%, %configFile%, %ButtonText%, xmax
		IniWrite, %ymin%, %configFile%, %ButtonText%, ymin
		IniWrite, %ymax%, %configFile%, %ButtonText%, ymax
		LLARS_DeveloperAction("Coordinates || " . selectedSection . " || X=" . xmin . "-" . xmax . " || Y=" . ymin . "-" . ymax, false)
		if (ButtonText = "Logout")
		{
			Gui 13u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
			Gui 13u: Color, Green
			Gui 13u: Font, cGreen
			Gui 13u: Font, s16 bold
			Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the LLARS Config.ini file`n----
			Gui 13u: +ToolWindow
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
			Gui 13u: +ToolWindow
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
		LLARS_DeveloperUIAction("Coordinates", "Closed")
		Gui, 2: Destroy
		Gui, 1: Show
		EnableHotkey()
	}

	Sleep, 250
}
CoordinateRButtonWasDown := CoordinateRButtonDown

return

; Handles single-point coordinate capture for point-only configuration sections.
CheckClicksPixel:
if GetKeyState("Esc", "P")
{
	Reload
}

CoordinateRButtonDown := GetKeyState("RButton")
if (CoordinateRButtonDown && !CoordinateRButtonWasDown)
{
	MouseGetPos, MouseX, MouseY
	Gui 11: Destroy
	Gui 11u: Destroy
	Gui 13u: +LastFound +OwnDialogs +AlwaysOnTop +Disabled
	Gui 13u: Color, Green
	Gui 13u: Font, cGreen
	Gui 13u: Font, s16 bold
	Gui 13u: Add, Text, valertlabel center,----Coordinates for [ %selectedSection% ] have been updated in the Config.ini file`n----
	Gui 13u: +ToolWindow
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
	configFile := (coordinateConfigFile != "") ? coordinateConfigFile : "Config.ini"
	; Point sections are authoritative single X/Y coordinates.
	IniDelete, %configFile%, %ButtonText%, xmin
	IniDelete, %configFile%, %ButtonText%, xmax
	IniDelete, %configFile%, %ButtonText%, ymin
	IniDelete, %configFile%, %ButtonText%, ymax
	IniWrite, %x%, %configFile%, %ButtonText%, x
	IniWrite, %y%, %configFile%, %ButtonText%, y
	LLARS_DeveloperAction("Coordinates || " . selectedSection . " || X=" . x . " || Y=" . y, false)
	Sleep, 1500
	Gui 13: Destroy
	Gui 13u: Destroy
	LLARS_DeveloperUIAction("Coordinates", "Closed")
	Gui, 2: Destroy
	Gui, 1: Show
	EnableHotkey()
	Sleep, 250
}
CoordinateRButtonWasDown := CoordinateRButtonDown

return

; Draws a temporary border around a two-click coordinate range so the user
; can visually confirm the saved rectangle before continuing.
LLARS_ShowCoordinatePreview(x1, y1, x2, y2)
{
	LLARS_HideCoordinatePreview()

	; Mouse coordinates are captured relative to the RuneScape client area.
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

	; These are top-level layered + transparent windows.

	Gui, 14: +AlwaysOnTop -Caption -Border +ToolWindow +E0x08080020 +HwndoverlayTopHwnd
	Gui, 14: Color, Red
	Gui, 14: Show, NoActivate x%left% y%top% w%width% h%border%, LLARSCoordinatePreviewTop
	LLARS_MakeCoordinateOverlayLayered(overlayTopHwnd)

	bottomY := top + height - border
	Gui, 15: +AlwaysOnTop -Caption -Border +ToolWindow +E0x08080020 +HwndoverlayBottomHwnd
	Gui, 15: Color, Red
	Gui, 15: Show, NoActivate x%left% y%bottomY% w%width% h%border%, LLARSCoordinatePreviewBottom
	LLARS_MakeCoordinateOverlayLayered(overlayBottomHwnd)

	Gui, 16: +AlwaysOnTop -Caption -Border +ToolWindow +E0x08080020 +HwndoverlayLeftHwnd
	Gui, 16: Color, Red
	Gui, 16: Show, NoActivate x%left% y%top% w%border% h%height%, LLARSCoordinatePreviewLeft
	LLARS_MakeCoordinateOverlayLayered(overlayLeftHwnd)

	rightX := left + width - border
	Gui, 17: +AlwaysOnTop -Caption -Border +ToolWindow +E0x08080020 +HwndoverlayRightHwnd
	Gui, 17: Color, Red
	Gui, 17: Show, NoActivate x%rightX% y%top% w%border% h%height%, LLARSCoordinatePreviewRight
	LLARS_MakeCoordinateOverlayLayered(overlayRightHwnd)
}

; Makes the already-created border strip fully opaque while retaining its layered/click-through window style.
LLARS_MakeCoordinateOverlayLayered(hWnd)
{
	if (!hWnd)
		return false

	return DllCall("user32\SetLayeredWindowAttributes"
		, "Ptr", hWnd
		, "UInt", 0
		, "UChar", 255
		, "UInt", 0x2)
}

; While Developer Mode is open, shows the Config.ini coordinate region that contains the current NaturalClick target.
LLARS_DeveloperCoordinateOverlay(x, y, section := "", scope := "script")
{
	global LLARS_SCRIPT_DIR, LLARS_CONFIG_FILE

	if !WinExist("Developer Mode ahk_class AutoHotkeyGUI")
		return false

	scope := Trim(scope)
	StringLower, scope, scope
	if scope in llars,framework,global
		configPath := LLARS_CONFIG_FILE
	else
		configPath := LLARS_SCRIPT_DIR . "\Config.ini"

	; LLARS_Click() passes the exact configured coordinate section so the
	; debugger does not have to guess which rectangle produced a randomized target.
	if (section = "")
	{
		if !IsFunc("LLARS_DeveloperClickTarget")
			return false
		section := LLARS_DeveloperClickTarget(x, y)
	}

	if (section = "" || !FileExist(configPath))
		return false

	IniRead, xmin, %configPath%, %section%, xmin, ERROR
	IniRead, xmax, %configPath%, %section%, xmax, ERROR
	IniRead, ymin, %configPath%, %section%, ymin, ERROR
	IniRead, ymax, %configPath%, %section%, ymax, ERROR

	if (xmin != "ERROR" && xmax != "ERROR" && ymin != "ERROR" && ymax != "ERROR")
	{
		xmin := Trim(xmin)
		xmax := Trim(xmax)
		ymin := Trim(ymin)
		ymax := Trim(ymax)
		if (xmin != "" && xmax != "" && ymin != "" && ymax != "")
		{
			LLARS_ShowCoordinatePreview(xmin, ymin, xmax, ymax)
			; Keep the target visible for the full NaturalClick.
			SetTimer, LLARS_HideDeveloperCoordinateOverlay, Off
			return true
		}
	}

	IniRead, fixedX, %configPath%, %section%, x, ERROR
	IniRead, fixedY, %configPath%, %section%, y, ERROR
	if (fixedX = "ERROR" || fixedY = "ERROR")
		return false

	fixedX := Trim(fixedX)
	fixedY := Trim(fixedY)
	if (fixedX = "" || fixedY = "")
		return false

	LLARS_ShowCoordinatePreview(fixedX - 5, fixedY - 5, fixedX + 5, fixedY + 5)
	; Keep the target visible for the full NaturalClick.
	SetTimer, LLARS_HideDeveloperCoordinateOverlay, Off
	return true
}

; Ends the Developer Mode coordinate overlay.
LLARS_DeveloperCoordinateOverlayHide(delay := 0)
{
	SetTimer, LLARS_HideDeveloperCoordinateOverlay, Off
	if (delay > 0)
	{
		delay := -Abs(Round(delay))
		SetTimer, LLARS_HideDeveloperCoordinateOverlay, %delay%
		return
	}

	LLARS_HideCoordinatePreview()
}

LLARS_HideDeveloperCoordinateOverlay:
LLARS_HideCoordinatePreview()
return

; Converts RuneScape client coordinates to absolute screen coordinates for temporary overlays.
LLARS_ClientToScreen(ByRef x, ByRef y)
{
	global LLARS_RunRuneScapeHwnd

	hWnd := 0
	if (LLARS_RunRuneScapeHwnd && DllCall("IsWindow", "Ptr", LLARS_RunRuneScapeHwnd) && LLARS_IsRuneScapeWindow(LLARS_RunRuneScapeHwnd))
		hWnd := LLARS_RunRuneScapeHwnd

	if (!hWnd)
	{
		activeHwnd := WinExist("A")
		if (activeHwnd && IsFunc("LLARS_IsRuneScapeWindow") && LLARS_IsRuneScapeWindow(activeHwnd))
			hWnd := activeHwnd
	}

	if (!hWnd)
		hWnd := LLARS_FindRuneScapeWindow()
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
LLARS_MainSavePosition()
Gui 1: Hide
LLARS_DeveloperUIAction("Configuration", "Closed")
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSConfigGuiHwnd
Gui 2: Font, s12 Bold cBlack
Gui 2: Add, Text, x5 y5 w280 h25 Center, LLARS
Gui 2: Font, s10 Bold cGray
Gui 2: Add, Text, x5 y29 w280 h18 Center, Colors
Gui 2: Add, Text, x10 y49 w270 h2 0x10
Gui 2: Font, s10 Bold cBlack
DisableHotkey()
colorConfigFile := LLARS_SCRIPT_DIR . "\Config.ini"
IniRead, allContents, %colorConfigFile%
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
	if (GetConfigType(colorConfigFile, currentSection) = "color")
		sectionList .= "|" currentSection
}

Gui, 2: Add, DropDownList, x30 y58 w230 vSectionList Choose1 gDropDownChanged1, % sectionList
Gui, 2: Add, Button, x60 y91 w170 h25 gClose1, Close Colors
Gui 2: -Caption
Gui, 2: Show, w290 h126 Center, Colors
LLARS_DeveloperUIAction("Colors")
Gui 2: +ToolWindow
WinSet, Transparent, %value%, ahk_id %LLARSConfigGuiHwnd%
return

; Closes the color editor and returns to the main LLARS GUI.
Close1:
LLARS_DeveloperUIAction("Colors", "Closed")
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

; Colors with coordinate= metadata use that exact point. When metadata is absent,
; LLARS also uses a uniquely matching x/y coordinate section by name. Standalone
; colors still ask for one physical right-click and sample that exact RGB value.
ColorSelected:
Gui, 2: Hide
LLARS_ActivateValidatedRuneScape()
x := ""
y := ""
ButtonText := selectedSection
colorConfigFile := LLARS_SCRIPT_DIR . "\Config.ini"
Sleep, 350
IniRead, colorCoordinateSection, %colorConfigFile%, %ButtonText%, coordinate, ERROR
colorCoordinateSection := Trim(colorCoordinateSection)
if (colorCoordinateSection = "" || colorCoordinateSection = "ERROR")
	colorCoordinateSection := LLARS_ColorMatchingPointSection(colorConfigFile, ButtonText)
if (colorCoordinateSection = "" || colorCoordinateSection = "ERROR")
{
	; Preserve legacy LLARS scripts that intentionally use [Pixel Coordinate]
	; as their shared color sample point.
	IniRead, legacyColorX, %colorConfigFile%, Pixel Coordinate, x, ERROR
	IniRead, legacyColorY, %colorConfigFile%, Pixel Coordinate, y, ERROR
	if legacyColorX is number
	{
		if legacyColorY is number
			colorCoordinateSection := "Pixel Coordinate"
	}
}
if (colorCoordinateSection = "" || colorCoordinateSection = "ERROR")
{
	SetTimer, CheckColorClick, 25
	colorHoverText := "Right-click the exact color for [ " . selectedSection . " ] | RGB: ------"
	colorPickerBorder := 12
	colorPickerInnerHeight := 38
	colorPickerInnerWidth := Min(1080, A_ScreenWidth - (colorPickerBorder * 2) - 16)
	if (colorPickerInnerWidth < 620)
		colorPickerInnerWidth := 620
	colorPickerOuterWidth := colorPickerInnerWidth + (colorPickerBorder * 2)
	colorPickerOuterHeight := colorPickerInnerHeight + (colorPickerBorder * 2)
	colorPickerRightX := colorPickerOuterWidth - colorPickerBorder
	colorPickerBottomY := colorPickerOuterHeight - colorPickerBorder
	Gui 11u: Destroy
	Gui 11: Destroy
	Gui 11: +LastFound +OwnDialogs +AlwaysOnTop +Disabled +ToolWindow -Caption
	Gui 11: Margin, 0, 0
	Gui 11: Color, White
	Gui 11: Add, Progress, x0 y0 w%colorPickerOuterWidth% h%colorPickerBorder% cRed BackgroundRed Disabled, 100
	Gui 11: Add, Progress, x0 y%colorPickerBottomY% w%colorPickerOuterWidth% h%colorPickerBorder% cRed BackgroundRed Disabled, 100
	Gui 11: Add, Progress, x0 y%colorPickerBorder% w%colorPickerBorder% h%colorPickerInnerHeight% cRed BackgroundRed Disabled, 100
	Gui 11: Add, Progress, x%colorPickerRightX% y%colorPickerBorder% w%colorPickerBorder% h%colorPickerInnerHeight% cRed BackgroundRed Disabled, 100
	Gui 11: Font, s16 bold cBlack
	Gui 11: Add, Text, x%colorPickerBorder% y%colorPickerBorder% w%colorPickerInnerWidth% h%colorPickerInnerHeight% Center +0x200 vTone, %colorHoverText%
	Gui 11: Show, NoActivate xcenter y0 w%colorPickerOuterWidth% h%colorPickerOuterHeight%, ColorPicker
	return
}

IniRead, x, %colorConfigFile%, %colorCoordinateSection%, x, ERROR
IniRead, y, %colorConfigFile%, %colorCoordinateSection%, y, ERROR
if x is not number
{
	LLARS_CreatorConfigError(ButtonText . " references an invalid color coordinate section: " . colorCoordinateSection)
	Gui, 2: Destroy
	Gui, 1: Show
	EnableHotkey()
	return
}
if y is not number
{
	LLARS_CreatorConfigError(ButtonText . " references an invalid color coordinate section: " . colorCoordinateSection)
	Gui, 2: Destroy
	Gui, 1: Show
	EnableHotkey()
	return
}
PixelGetColor, color, %x%, %y%, RGB
GoSub, SaveColorSelection
return

LLARS_ColorMatchingPointSection(configFile, colorSection)
{
	colorToken := LLARS_DeveloperPixelSectionToken(colorSection)
	if (colorToken = "")
		return ""

	IniRead, sections, %configFile%
	matchedSection := ""
	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "" || GetConfigType(configFile, section) != "coordinate")
			continue

		IniRead, pointX, %configFile%, %section%, x, ERROR
		IniRead, pointY, %configFile%, %section%, y, ERROR
		if pointX is not number
			continue
		if pointY is not number
			continue

		if (LLARS_DeveloperPixelSectionToken(section) != colorToken)
			continue

		if (matchedSection != "")
			return ""
		matchedSection := section
	}

	return matchedSection
}

; Captures one standalone RGB value directly from the RuneScape client.
CheckColorClick:
if GetKeyState("Esc", "P")
{
	Reload
}

hoverColor := "------"
if LLARS_IsRuneScapeActive()
{
	MouseGetPos, hoverX, hoverY
	PixelGetColor, hoverColor, %hoverX%, %hoverY%, RGB
	if (hoverColor = "")
		hoverColor := "------"
	else
		StringUpper, hoverColor, hoverColor
}
colorHoverText := "Right-click the exact color for [ " . selectedSection . " ] | RGB: " . hoverColor
GuiControl, 11:, Tone, %colorHoverText%

if GetKeyState("RButton", "P")
{
	MouseGetPos, x, y
	PixelGetColor, color, %x%, %y%, RGB
	SetTimer, CheckColorClick, Off
	Gui 11: Destroy
	Gui 11u: Destroy
	GoSub, SaveColorSelection
	Sleep, 250
}
return

; Saves and displays the sampled RGB.
SaveColorSelection:
StringUpper, color, color
colorKey := LLARS_GetColorKey(colorConfigFile, ButtonText)
IniWrite, %color%, %colorConfigFile%, %ButtonText%, %colorKey%
duplicateColors := LLARS_ColorDuplicateSections(colorConfigFile, ButtonText, color)
if (duplicateColors = "")
	colorResultText := ButtonText . " = " . color . " | Unique"
else
	colorResultText := ButtonText . " = " . color . " | Matches: " . duplicateColors
LLARS_DeveloperAction("Color || " . ButtonText . " || RGB=" . color . ((duplicateColors != "") ? " || Matches=" . duplicateColors : ""), false)
LLARS_DeveloperColorConfigAction(ButtonText " | " colorKey " = " color . ((duplicateColors != "") ? " | Matches: " . duplicateColors : ""))
; Build one balanced confirmation window: white center with an equal 12 px green frame on every side.
colorResultHeight := 38
colorResultBorder := 12
Gui 19: Destroy
Gui 19: +ToolWindow -Caption
Gui 19: Font, s16 bold
Gui 19: Add, Text, vLLARSColorMeasure -Wrap, %colorResultText%
Gui 19: Show, Hide AutoSize, ColorConfirmationMeasure
GuiControlGet, colorResultTextPos, 19:Pos, LLARSColorMeasure
colorResultWidth := colorResultTextPosW + 50
Gui 19: Destroy
if (colorResultWidth < 520)
	colorResultWidth := 520
colorResultMaxWidth := A_ScreenWidth - (colorResultBorder * 2) - 16
if (colorResultWidth > colorResultMaxWidth)
	colorResultWidth := colorResultMaxWidth
colorResultOuterWidth := colorResultWidth + (colorResultBorder * 2)
colorResultOuterHeight := colorResultHeight + (colorResultBorder * 2)
colorResultRightX := colorResultOuterWidth - colorResultBorder
colorResultBottomY := colorResultOuterHeight - colorResultBorder
Gui 13u: Destroy
Gui 13: Destroy
Gui 13: +LastFound +AlwaysOnTop +OwnDialogs +Disabled +ToolWindow -Caption
Gui 13: Margin, 0, 0
Gui 13: Color, White
Gui 13: Add, Progress, x0 y0 w%colorResultOuterWidth% h%colorResultBorder% cGreen BackgroundGreen Disabled, 100
Gui 13: Add, Progress, x0 y%colorResultBottomY% w%colorResultOuterWidth% h%colorResultBorder% cGreen BackgroundGreen Disabled, 100
Gui 13: Add, Progress, x0 y%colorResultBorder% w%colorResultBorder% h%colorResultHeight% cGreen BackgroundGreen Disabled, 100
Gui 13: Add, Progress, x%colorResultRightX% y%colorResultBorder% w%colorResultBorder% h%colorResultHeight% cGreen BackgroundGreen Disabled, 100
Gui 13: Font, s16 bold cBlack
Gui 13: Add, Text, x%colorResultBorder% y%colorResultBorder% w%colorResultWidth% h%colorResultHeight% Center +0x200 vTthree, %colorResultText%
Gui 13: Show, NoActivate xcenter y0 w%colorResultOuterWidth% h%colorResultOuterHeight%, ColorConfirmation
Sleep 1800
Gui 13: Destroy
Gui 13u: Destroy
LLARS_DeveloperUIAction("Colors", "Closed")
Gui, 2: Destroy
Gui, 1: Show
EnableHotkey()
return

LLARS_ColorDuplicateSections(configFile, selectedSection, selectedColor)
{
	selectedColor := Trim(selectedColor)
	StringUpper, selectedColor, selectedColor
	duplicates := ""
	IniRead, colorSections, %configFile%
	Loop, Parse, colorSections, `n, `r
	{
		section := Trim(A_LoopField)
		StringReplace, section, section, [, , All
		StringReplace, section, section, ], , All
		section := Trim(section)
		if (section = "" || section = selectedSection)
			continue
		if (GetConfigType(configFile, section) != "color")
			continue
		otherKey := LLARS_GetColorKey(configFile, section)
		IniRead, otherColor, %configFile%, %section%, %otherKey%, ERROR
		otherColor := Trim(otherColor)
		StringUpper, otherColor, otherColor
		if (otherColor = selectedColor)
		{
			if (duplicates != "")
				duplicates .= ", "
			duplicates .= section
		}
	}
	return duplicates
}

; ================================================================
; |     HOTKEY GUI     -     HOTKEY GUI     -     HOTKEY GUI     |
; ================================================================

; Builds the hotkey editor dynamically by using the type assigned to
; each configuration section. Sections marked type=hotkey are
; automatically included without requiring their names in the script.
;
; The hotkeyConfigFiles object records which INI file each section came from.
Hotkey:
LLARS_MainSavePosition()
Gui 1: Hide
LLARS_DeveloperUIAction("Configuration", "Closed")
Gui Combo: Destroy
Gui 3: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSHotkeyGuiHwnd
Gui 3: Font, s12 Bold cBlack
Gui 3: Add, Text, x5 y5 w280 h25 Center, LLARS
Gui 3: Font, s10 Bold cGray
Gui 3: Add, Text, x5 y29 w280 h18 Center, Hotkeys
Gui 3: Add, Text, x10 y49 w270 h2 0x10
Gui 3: Font, s10 Bold cBlack
DisableHotkey()
scriptHotkeyConfigFile := LLARS_SCRIPT_DIR . "\Config.ini"
IniRead, allContents, %scriptHotkeyConfigFile%
IniRead, llarsContents, %LLARS_CONFIG_FILE%
sectionList := " ***** Make a Selection ***** | "
hotkeyConfigFiles := {}
configHotkeysFound := false

; Add a section header for Config.ini hotkeys.
sectionList .= "| ---- Script Hotkeys ---- "

; Add sections from Config.ini that are explicitly categorized as hotkeys.
Loop, Parse, allContents, `n
{
	currentSection := Trim(A_LoopField)
	if (currentSection = "")
		continue
	StringReplace, currentSection, currentSection, [, , All
	StringReplace, currentSection, currentSection, ], , All
	currentSection := Trim(currentSection)
	if (GetConfigType(scriptHotkeyConfigFile, currentSection) = "hotkey")
	{
		sectionList .= "|" currentSection
		hotkeyConfigFiles[currentSection] := scriptHotkeyConfigFile
		configHotkeysFound := true
	}
}

; Add a blank space between the Script Hotkeys and
; LLARS Hotkeys sections.
sectionList .= "| "

; Add a section header for LLARS Config.ini hotkeys.
sectionList .= "| ---- LLARS Hotkeys ---- "

; Add sections from LLARS Config.ini that are explicitly categorized as hotkeys.
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
Gui, 3: Add, Hotkey, x70 y109 w150 h23 vChosenHotkey gHotkeyChanged Center Disabled, ** NONE **
Gui, 3: Add, Button, x60 y141 w170 h25 gClose2, Close Hotkeys
Gui 3: -Caption
Gui, 3: Show, w290 h176 Center, Hotkeys
LLARS_DeveloperUIAction("Hotkeys")
Gui 3: +ToolWindow
WinSet, Transparent, %value%, ahk_id %LLARSHotkeyGuiHwnd%
return

; Closes the hotkey editor and returns to the main LLARS GUI.
Close2:
LLARS_DeveloperUIAction("Hotkeys", "Closed")
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

	; Move focus away from the dropdown so keyboard letters cannot jump to another section while no hotkey section is selected.
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

; The Hotkey control fires while modifiers are still being pressed.
if !LLARS_IsValidConfigHotkey(ChosenHotkey)
	return

; Use the locked section and configuration file instead of whatever
; the dropdown may currently be highlighting.
IniWrite, %ChosenHotkey%, %selectedHotkeyConfigFile%, %selectedHotkeySection%, Hotkey
LLARS_DeveloperAction("Hotkey Config || " . selectedHotkeySection . " || " . ChosenHotkey, false)
if WinExist("Developer Mode ahk_class AutoHotkeyGUI")
	Gosub, LLARS_DeveloperAutoRefresh
if (selectedHotkeyConfigFile = LLARS_CONFIG_FILE)
{
	LLARS_CheckHotkeyConfig()
	hotkeyConfigDisplay := "LLARS Config.ini"
}
else
	hotkeyConfigDisplay := "Config.ini"
LLARS_DeveloperUIAction("Hotkeys", "Closed")
Gui, 3: Destroy
Gui 13u: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cgreenhite
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----Hotkey has been updated in the %hotkeyConfigDisplay% file`n----
Gui 13u: +ToolWindow
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
LLARS_PAUSED := false
LLARS_DeveloperAction("Script || Resumed")
GuiControl,,ScriptBlue, % LLARS_DisplayScriptName()
GuiControl,,State3, Running
GuiControl, Dev:, DeveloperRunningText, Running
Return

; Pauses the interrupted automation thread while keeping this hotkey thread
; alive so Developer Mode can continue refreshing elapsed time and live data.
PauseB:
LLARS_PAUSED := true
LLARS_DeveloperAction("Script || Paused")
GuiControl,,State2, Paused
GuiControl,,ScriptRed, % LLARS_DisplayScriptName()
GuiControl, Dev:, DeveloperRunningText, Paused

Pause, On, 1

while (LLARS_PAUSED)
{
	if WinExist("Developer Mode ahk_class AutoHotkeyGUI")
		Gosub, LLARS_DeveloperAutoRefresh

	Sleep, 250
}

Pause, Off, 1
Return

; =========================================================================
; |     EXIT BUTTON     -     EXIT BUTTON     -     EXIT BUTTON           |
; =========================================================================

; Handles the Exit hotkey/button and normal GUI close event.
ExitB:
LLARS_DeveloperHotkey("Exit")
guiclose:
LLARS_MainSavePosition()

if (DeveloperGuiHwnd && WinExist("ahk_id " . DeveloperGuiHwnd))
	LLARS_DeveloperSavePosition(DeveloperGuiHwnd)

if IsFunc("LLARS_TimerStopAll")
	LLARS_TimerStopAll()
ExitApp

; ===================================================================
; |     INFORMATION     -     INFORMATION     -     INFORMATION     |
; ===================================================================

; Builds the Information window with current LLARS/script hotkeys,
; shared options, configuration shortcuts, and project links.
Info:
LLARS_DeveloperHotkey("Information")
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
if (LLARS_lhk5 != "")
	scriptHotkeys .= "Developer Mode: " . LLARS_lhk5 . "`n"

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
LLARS_MainSavePosition()
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

; When there are no script-specific Config.ini hotkeys, keep the full text height so every LLARS hotkey remains visible while trimming only the unused bottom padding from the group box.
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
developerModeY := scriptConfigY + 29
discordY := developerModeY + 29
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
Gui 20: Add, Button, x60 y%developerModeY% w170 h25 gDeveloperMode, Developer Mode
Gui 20: Add, Button, x60 y%discordY% w170 h25 gDiscord, Discord
Gui 20: Add, Text, x10 y%closeDividerY% w270 h2 0x10
Gui 20: Add, Button, x60 y%closeInfoY% w170 h29 gCloseInfo, Close Information
Gui 20: +ToolWindow
Gui 20: -caption
Gui 20: Show, center w290 h%informationHeight%, Information
LLARS_DeveloperUIAction("Information")
return

; Closes the information window and restores the main LLARS GUI.
CloseInfo:
Gui 1: Default
LLARS_DeveloperUIAction("Information", "Closed")
Gui 20: Destroy
Gui 1: Show
return

; Opens the Discord link from the information GUI and returns to LLARS.
discord:
Gui 1: Default
LLARS_DeveloperUIAction("Information", "Closed")
Gui 20: Destroy
Run, https://discord.gg/Wmmf65myPG
Gui 1: Show
return

; Opens the main script configuration file.
InfoConfig:
EnableHotkey()
Run %LLARS_SCRIPT_DIR%\Config.ini
return

LLARS_DeveloperControlHotkeyReleaseTimer:
if IsFunc("LLARS_DeveloperCheckControlHotkeyReleases")
	LLARS_DeveloperCheckControlHotkeyReleases()
else
	SetTimer, LLARS_DeveloperControlHotkeyReleaseTimer, Off
return

DeveloperModeHotkey:
	Suspend, Permit
LLARS_WaitForHotkeyRelease(LLARS_lhk5)
LLARS_DeveloperHotkey("Developer Mode")
if (DeveloperGuiHwnd && WinExist("ahk_id " . DeveloperGuiHwnd))
{
	Gosub, CloseDeveloperMode
	return
}
DeveloperGuiHwnd := 0
LLARS_DeveloperUIAction("Developer Mode")
Gosub, DeveloperModeDashboard
return

; Opens the LLARS configuration file.
InfoLLARS:
EnableHotkey()
Run %LLARS_CONFIG_FILE%
return

; ============================================================================
; |     DEVELOPER MODE     -     DEVELOPER MODE     -     DEVELOPER MODE     |
; ============================================================================

; Opens the live Developer Mode dashboard directly from Information or the dedicated hotkey.
DeveloperMode:
EnableHotkey()
LLARS_DeveloperUIAction("Information", "Closed")
Gui 20: Destroy
LLARS_DeveloperUIAction("Developer Mode")
Gosub, DeveloperModeDashboard
return

DeveloperModeDashboard:
if (LLARS_DeveloperLightweight)
{
	Gosub, DeveloperModeLightweightDashboard
	return
}

LLARS_DeveloperDestroyInspectorPanel()
LLARS_DeveloperDestroyHotkeysPanel()
Gui Dev: Destroy
Gui Dev: +AlwaysOnTop +OwnDialogs +LastFound +HwndDeveloperGuiHwnd

Gui Dev: Font, s12 Bold cBlack
Gui Dev: Add, Text, x5 y4 w550 h22 Center, LLARS
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x5 y25 w550 h17 Center, Developer Mode
Gui Dev: Font, s11 Norm cGray
Gui Dev: Add, Text, x5 y43 w550 h18 Center, %scriptname%
Gui Dev: Add, Text, x130 y63 w300 h2 0x10

if (LLARS_RUNNING)
{
	if (LLARS_PAUSED)
		developerRunning := "Paused"
	else
		developerRunning := "Running"
}
else
	developerRunning := "Idle"

developerFinalSleep := EstFinalSleepActive ? "Active" : "Inactive"
developerRunType := (LLARS_RUN_TYPE != "") ? LLARS_RUN_TYPE : "Not Started"

if (LLARS_RUNNING && LLARS_RunStartTick > 0)
{
	developerElapsedMS := A_TickCount - LLARS_RunStartTick
	developerElapsedHours := Floor(developerElapsedMS / 3600000)
	developerElapsedMinutes := Floor(Mod(developerElapsedMS, 3600000) / 60000)
	developerElapsedSeconds := Floor(Mod(developerElapsedMS, 60000) / 1000)
	developerElapsed := developerElapsedHours . "h " . developerElapsedMinutes . "m " . developerElapsedSeconds . "s"
}
else
	developerElapsed := "--"

if (developerRunType = "RunCount" && runcount3 != "")
	developerProgress := count2 . " / " . runcount3
else if (developerRunType = "Timer" && LLARS_RUNNING)
	developerProgress := LLARS_TimerRemainingText(endTime - A_TickCount)
else
	developerProgress := "--"

LLARS_DeveloperMousePixel(developerMouseX, developerMouseY, developerPixelColor, developerInspectorStatus)
LLARS_DeveloperCheckPixelReset()
developerPixelTargets := LLARS_DeveloperPixelTargets()

developerStartState := (!LLARS_RUNNING && !LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerInfoState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerConfigState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"

developerInfoName := LLARS_RUNNING ? "Pause" : "Information"
developerConfigName := LLARS_RUNNING ? "Resume" : "Configuration"

developerHotkeys := ""
developerHotkeys .= "Start: " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk1) . " (" . developerStartState . ")`n"
developerHotkeys .= developerInfoName . ": " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk2) . " (" . developerInfoState . ")`n"
developerHotkeys .= developerConfigName . ": " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk3) . " (" . developerConfigState . ")`n"
developerHotkeys .= "Exit: " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk4) . " (Enabled)"
if (LLARS_lhk5 != "")
	developerHotkeys .= "`nDeveloper Mode: " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk5)

developerScriptHotkeys := LLARS_DeveloperScriptHotkeys()
if (developerScriptHotkeys != "")
	developerHotkeys .= "`n`n" . developerScriptHotkeys

developerActions := LLARS_DeveloperActions
actionLineCount := 0
Loop, Parse, developerActions, `n, `r
	actionLineCount++
if (developerActions = "")
	developerActions := "No framework actions recorded yet."

developerDiagnostics := LLARS_DeveloperConfigDiagnostics()

; Compact two-row run summary.
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Text, x20 y71 w70 h18 Right, State:
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x94 y71 w96 h18 vDeveloperRunningText, %developerRunning%
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Text, x195 y71 w78 h18 Right, Run Type:
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x277 y71 w88 h18 vDeveloperRunTypeText, %developerRunType%
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Text, x370 y71 w74 h18 Right, Progress:
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x448 y71 w92 h18 vDeveloperProgressText, %developerProgress%
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Text, x65 y92 w78 h18 Right, Elapsed:
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x147 y92 w123 h18 vDeveloperElapsedText, %developerElapsed%
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Text, x290 y92 w88 h18 Right, Final Sleep:
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x382 y92 w113 h18 vDeveloperFinalSleepText, %developerFinalSleep%
Gui Dev: Add, Text, x20 y116 w520 h2 0x10

; Top row: the entire Live Inspector scrolls as one pane, matching the
; Active Hotkeys pane while keeping normal LLARS label/value formatting.
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x20 y126 w250 h18 Center, Live Inspector
Gui Dev: Add, GroupBox, x20 y147 w250 h198

Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x290 y126 w250 h18 Center, Active Hotkeys
Gui Dev: Add, GroupBox, x290 y147 w250 h198

; Full-width diagnostics are easier to read than the previous narrow fourth box.
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x20 y355 w520 h18 Center, Configuration Diagnostics
Gui Dev: Add, GroupBox, x20 y376 w520 h83
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Edit, x30 y394 w500 h53 ReadOnly -TabStop +VScroll vDeveloperDiagnosticsText, %developerDiagnostics%

Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x20 y464 w520 h18 Center, Recent Framework Actions
Gui Dev: Add, GroupBox, x20 y484 w520 h156
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Edit, x30 y501 w500 h132 ReadOnly -TabStop +VScroll hwndDeveloperActionsHwnd vDeveloperActionsText, %developerActions%

Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Button, x35 y648 w155 h27 gToggleDeveloperLightweight, Lightweight Mode
Gui Dev: Add, Button, x202 y648 w155 h27 gDeveloperTimingAudit, Timing Audit
Gui Dev: Add, Button, x369 y648 w155 h27 gCloseDeveloperMode, Close
Gui Dev: +ToolWindow
Gui Dev: -Caption
; Build the full dashboard while the parent is hidden so the hotkey toggle
; never exposes the unfinished Developer Mode shell before its child panes exist.
Gui Dev: Show, Hide w560 h688, Developer Mode
LLARS_DeveloperCreateInspectorPanel(developerInspectorStatus, developerMouseX, developerMouseY, developerPixelColor, developerPixelTargets, DeveloperGuiHwnd)
LLARS_DeveloperCreateHotkeysPanel(developerHotkeys, DeveloperGuiHwnd)
if LLARS_DeveloperLoadPosition(DeveloperGUIx, DeveloperGUIy)
	Gui Dev: Show, x%DeveloperGUIx% y%DeveloperGUIy% w560 h688, Developer Mode
else
	Gui Dev: Show, Center w560 h688, Developer Mode

LLARS_EnableDeveloperHotkey()
LLARS_DeveloperLastHotkeys := developerHotkeys
LLARS_DeveloperLastInspectorSignature := LLARS_DeveloperInspectorSignature(developerPixelTargets)
LLARS_DeveloperLastDiagnostics := developerDiagnostics
LLARS_DeveloperLastActions := developerActions
PostMessage, 0x115, 7, 0,, ahk_id %DeveloperActionsHwnd%
SetTimer, LLARS_DeveloperAutoRefresh, 750
return

DeveloperModeLightweightDashboard:
LLARS_DeveloperDestroyInspectorPanel()
LLARS_DeveloperDestroyHotkeysPanel()
Gui Dev: Destroy
DeveloperGuiHwnd := 0
Gui Dev: +AlwaysOnTop +OwnDialogs +LastFound +HwndDeveloperGuiHwnd

developerActions := LLARS_DeveloperActions
if (developerActions = "")
	developerActions := "No framework actions recorded yet."

Gui Dev: Font, s12 Bold cBlack
Gui Dev: Add, Text, x5 y5 w550 h25 Center, LLARS
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Text, x5 y29 w550 h18 Center, Developer Mode - Lightweight
Gui Dev: Font, s11 Norm cGray
Gui Dev: Add, Text, x5 y48 w550 h20 Center, %scriptname%
Gui Dev: Add, Text, x130 y69 w300 h2 0x10
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, GroupBox, x20 y82 w520 h218, Recent Framework Actions
Gui Dev: Font, s10 Norm cBlack
Gui Dev: Add, Edit, x30 y104 w500 h184 ReadOnly -TabStop +VScroll hwndDeveloperActionsHwnd vDeveloperActionsText, %developerActions%
Gui Dev: Font, s10 Bold cBlack
Gui Dev: Add, Button, x35 y312 w155 h27 gToggleDeveloperLightweight, Full Mode
Gui Dev: Add, Button, x202 y312 w155 h27 gDeveloperTimingAudit, Timing Audit
Gui Dev: Add, Button, x369 y312 w155 h27 gCloseDeveloperMode, Close
Gui Dev: +ToolWindow
Gui Dev: -Caption
if LLARS_DeveloperLoadPosition(DeveloperGUIx, DeveloperGUIy)
	Gui Dev: Show, x%DeveloperGUIx% y%DeveloperGUIy% w560 h350, Developer Mode
else
	Gui Dev: Show, Center w560 h350, Developer Mode

LLARS_EnableDeveloperHotkey()
LLARS_DeveloperLastActions := developerActions
PostMessage, 0x115, 7, 0,, ahk_id %DeveloperActionsHwnd%
SetTimer, LLARS_DeveloperAutoRefresh, 750
return

DeveloperTimingAudit:
SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, Off
if (DeveloperTimingAuditHwnd && WinExist("ahk_id " . DeveloperTimingAuditHwnd))
{
	Gui Audit: Show
	WinActivate, ahk_id %DeveloperTimingAuditHwnd%
	SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, 750
	Gui Dev: Default
	return
}
Gui Audit: Destroy
DeveloperTimingAuditHwnd := 0
LLARS_DeveloperTimingAuditPaused := false
DeveloperTimingAuditLastText := ""
DeveloperTimingAuditFilter := ""
DeveloperTimingAuditSortColumn := 0
DeveloperTimingAuditSortDirection := "Asc"
Gui Audit: +AlwaysOnTop +OwnDialogs +ToolWindow +HwndDeveloperTimingAuditHwnd
Gui Audit: Font, s13 Bold cBlack
Gui Audit: Add, Text, x5 y5 w530 h26 Center, LLARS
Gui Audit: Font, s11 Bold cBlack
Gui Audit: Add, Text, x5 y30 w530 h19 Center, Timing Audit
Gui Audit: Font, s10 Norm cGray
Gui Audit: Add, Text, x5 y51 w530 h19 Center, Last 500 audit actions. Newest first.
Gui Audit: Add, Text, x50 y73 w440 h2 0x10
Gui Audit: Font, s10 Norm cBlack, Segoe UI
Gui Audit: Add, Text, x20 y87 w42 h22 +0x200, Filter:
Gui Audit: Add, Edit, x64 y86 w326 h23 gDeveloperTimingAuditFilterChanged vDeveloperTimingAuditFilter
Gui Audit: Font, s9 Bold cBlack, Segoe UI
Gui Audit: Add, Button, x400 y85 w120 h25 gResetDeveloperTimingAuditView, Reset View
Gui Audit: Font, s10 Norm cBlack, Segoe UI
Gui Audit: Add, ListView, x20 y119 w500 h253 Grid -Multi AltSubmit gDeveloperTimingAuditListEvent +HwndDeveloperTimingAuditListHwnd vDeveloperTimingAuditList, Action|Detail|Value
Gui Audit: Default
Gui Audit: ListView, DeveloperTimingAuditList
LV_ModifyCol(1, 105)
LV_ModifyCol(2, 230)
LV_ModifyCol(3, 145)
LLARS_DeveloperPopulateTimingAudit()
Gui Audit: Font, s11 Bold cBlack, Segoe UI
Gui Audit: Add, Button, x115 y385 w145 h28 gToggleDeveloperTimingAuditPause vDeveloperTimingAuditPauseButton, Pause
Gui Audit: Add, Button, x280 y385 w145 h28 gCloseDeveloperTimingAudit, Close
Gui Audit: -Caption
Gui Audit: Show, Center w540 h425, Timing Audit
SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, 750
Gui Dev: Default
return

ToggleDeveloperTimingAuditPause:
LLARS_DeveloperTimingAuditPaused := !LLARS_DeveloperTimingAuditPaused
if (LLARS_DeveloperTimingAuditPaused)
{
	SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, Off
	GuiControl, Audit:, DeveloperTimingAuditPauseButton, Resume
}
else
{
	GuiControl, Audit:, DeveloperTimingAuditPauseButton, Pause
	DeveloperTimingAuditLastText := ""
	LLARS_DeveloperPopulateTimingAudit()
	SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, 750
}
return

LLARS_DeveloperTimingAuditAutoRefresh:
if (LLARS_DeveloperTimingAuditPaused)
	return
if (!DeveloperTimingAuditHwnd || !WinExist("ahk_id " . DeveloperTimingAuditHwnd))
{
	SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, Off
	return
}
LLARS_DeveloperPopulateTimingAudit()
return

DeveloperTimingAuditFilterChanged:
GuiControlGet, DeveloperTimingAuditFilter, Audit:, DeveloperTimingAuditFilter
DeveloperTimingAuditLastText := ""
LLARS_DeveloperPopulateTimingAudit()
return

DeveloperTimingAuditListEvent:
if (A_GuiEvent = "ColClick")
{
	if (DeveloperTimingAuditSortColumn = A_EventInfo)
		DeveloperTimingAuditSortDirection := (DeveloperTimingAuditSortDirection = "Asc") ? "Desc" : "Asc"
	else
	{
		DeveloperTimingAuditSortColumn := A_EventInfo
		DeveloperTimingAuditSortDirection := "Asc"
	}
	DeveloperTimingAuditLastText := ""
	LLARS_DeveloperPopulateTimingAudit()
}
return

ResetDeveloperTimingAuditView:
DeveloperTimingAuditFilter := ""
DeveloperTimingAuditSortColumn := 0
DeveloperTimingAuditSortDirection := "Asc"
GuiControl, Audit:, DeveloperTimingAuditFilter,
DeveloperTimingAuditLastText := ""
LLARS_DeveloperPopulateTimingAudit()
return

CloseDeveloperTimingAudit:
SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, Off
Gui Audit: Destroy
DeveloperTimingAuditHwnd := 0
LLARS_DeveloperTimingAuditPaused := false
DeveloperTimingAuditLastText := ""
DeveloperTimingAuditListHwnd := 0
Gui Dev: Default
return

AuditGuiClose:
AuditGuiEscape:
Gosub, CloseDeveloperTimingAudit
return

; Displays the concise audit history in fixed columns.
LLARS_DeveloperPopulateTimingAudit()
{
	global LLARS_DeveloperAuditActions, DeveloperTimingAuditLastText, DeveloperTimingAuditListHwnd
	global DeveloperTimingAuditFilter, DeveloperTimingAuditSortColumn, DeveloperTimingAuditSortDirection

	signature := "TimingAudit|" . DeveloperTimingAuditFilter . "|" . DeveloperTimingAuditSortColumn . "|" . DeveloperTimingAuditSortDirection . "|"
	if IsObject(LLARS_DeveloperAuditActions)
	{
		for _, auditAction in LLARS_DeveloperAuditActions
			signature .= auditAction . "|"
	}

	if (signature = DeveloperTimingAuditLastText)
		return
	DeveloperTimingAuditLastText := signature

	Gui Audit: Default
	Gui Audit: ListView, DeveloperTimingAuditList
	if (DeveloperTimingAuditListHwnd)
		SendMessage, 0xB, 0, 0,, ahk_id %DeveloperTimingAuditListHwnd%
	LV_Delete()
	LV_ModifyCol(1, "", "Action")
	LV_ModifyCol(2, "", "Detail")
	LV_ModifyCol(3, "", "Value")

	matchingActions := 0
	if (!IsObject(LLARS_DeveloperAuditActions) || LLARS_DeveloperAuditActions.Length() = 0)
	{
		LV_Add("", "No audit actions recorded yet.", "", "")
	}
	else
	{
		auditCount := LLARS_DeveloperAuditActions.Length()
		Loop, %auditCount%
		{
			auditIndex := auditCount - A_Index + 1
			auditAction := LLARS_DeveloperAuditActions[auditIndex]
			LLARS_DeveloperTimingAuditColumns(auditAction, auditType, auditDetail, auditValue)
			if (DeveloperTimingAuditFilter != "")
			{
				auditSearchText := auditType . " " . auditDetail . " " . auditValue
				if !InStr(auditSearchText, DeveloperTimingAuditFilter, false)
					continue
			}
			LV_Add("", auditType, auditDetail, auditValue)
			matchingActions++
		}

		if (matchingActions = 0)
			LV_Add("", "No matching audit actions.", "", "")
	}

	if (DeveloperTimingAuditSortColumn >= 1 && DeveloperTimingAuditSortColumn <= 3 && matchingActions > 0)
	{
		sortOption := (DeveloperTimingAuditSortDirection = "Desc") ? "SortDesc" : "Sort"
		LV_ModifyCol(DeveloperTimingAuditSortColumn, sortOption)
		sortArrow := (DeveloperTimingAuditSortDirection = "Desc") ? " ↓" : " ↑"
		if (DeveloperTimingAuditSortColumn = 1)
			LV_ModifyCol(1, "", "Action" . sortArrow)
		else if (DeveloperTimingAuditSortColumn = 2)
			LV_ModifyCol(2, "", "Detail" . sortArrow)
		else if (DeveloperTimingAuditSortColumn = 3)
			LV_ModifyCol(3, "", "Value" . sortArrow)
	}

	if (DeveloperTimingAuditListHwnd)
	{
		SendMessage, 0xB, 1, 0,, ahk_id %DeveloperTimingAuditListHwnd%
		WinSet, Redraw,, ahk_id %DeveloperTimingAuditListHwnd%
	}
	if (LV_GetCount() > 0)
		LV_Modify(1, "Vis")
	Gui Dev: Default
}

; Converts the concise framework action strings into the three audit columns.
LLARS_DeveloperTimingAuditColumns(action, ByRef auditType, ByRef auditDetail, ByRef auditValue)
{
	auditType := ""
	auditDetail := ""
	auditValue := ""
	parts := StrSplit(action, " || ")
	if (!IsObject(parts) || parts.Length() = 0)
		return

	auditType := Trim(parts[1])
	partCount := parts.Length()

	if (auditType = "Color Search")
	{
		if (partCount >= 2)
			auditType := Trim(parts[2])
		if (partCount >= 3)
			auditDetail := Trim(parts[3])
		if (partCount >= 4)
		{
			auditValue := Trim(parts[4])
			if RegExMatch(auditValue, "^-?\d+(?:\.\d+)?$")
				auditValue := "Clicks = " . auditValue
		}
		return
	}

	if (auditType = "Color Click")
	{
		auditType := "Target"
		if (partCount >= 2)
			auditDetail := Trim(parts[2])
		if (partCount >= 4)
			auditValue := Trim(parts[4])
		return
	}

	if (auditType = "MouseMove")
	{
		auditType := "Move"
		if (partCount >= 2)
		{
			auditValue := Trim(parts[2])
			auditValue := StrReplace(auditValue, "(", "")
			auditValue := StrReplace(auditValue, ")", "")
			auditValue := StrReplace(auditValue, " > ", " -> ")
		}
		return
	}

	if (auditType = "NaturalClick")
	{
		auditType := "Click"
		if (partCount >= 2)
			auditDetail := Trim(parts[2])
		if (partCount >= 3)
			auditValue := Trim(parts[3])
		return
	}

	if (auditType = "NaturalClick Timing")
	{
		auditType := "Click Time"
		if (partCount >= 2)
			auditValue := Trim(parts[2])
		return
	}

	if (auditType = "Mouse Timing")
	{
		auditType := "Mouse Hold"
		if (partCount >= 2)
			auditValue := Trim(parts[2])
		return
	}

	if (partCount >= 3)
	{
		auditDetail := Trim(parts[2])
		auditValue := Trim(parts[3])
		return
	}

	if (partCount = 2)
	{
		secondField := Trim(parts[2])
		if RegExMatch(secondField, "i)(?:^Hold=|\bms$|^\([^)]*\)(?:\s*>\s*\([^)]*\))?$)")
			auditValue := secondField
		else
			auditDetail := secondField
	}
}

ToggleDeveloperLightweight:
SetTimer, LLARS_DeveloperAutoRefresh, Off
LLARS_DeveloperSavePosition(DeveloperGuiHwnd)
LLARS_DeveloperLightweight := !LLARS_DeveloperLightweight
Gosub, DeveloperModeDashboard
return

; Toggles Developer Mode without changing any normal LLARS runtime behavior.
LLARS_DeveloperAutoRefresh:
if !WinExist("Developer Mode ahk_class AutoHotkeyGUI")
{
	SetTimer, LLARS_DeveloperAutoRefresh, Off
	return
}

if (LLARS_DeveloperLightweight)
{
	developerActions := LLARS_DeveloperActions
	if (developerActions = "")
		developerActions := "No framework actions recorded yet."
	if (developerActions != LLARS_DeveloperLastActions)
	{
		GuiControl, Dev:, DeveloperActionsText, %developerActions%
		LLARS_DeveloperLastActions := developerActions
		PostMessage, 0x115, 7, 0,, ahk_id %DeveloperActionsHwnd%
	}
	return
}

if (LLARS_RUNNING)
{
	if (LLARS_PAUSED)
		developerRunning := "Paused"
	else
		developerRunning := "Running"
}
else
	developerRunning := "Idle"

developerFinalSleep := EstFinalSleepActive ? "Active" : "Inactive"
developerRunType := (LLARS_RUN_TYPE != "") ? LLARS_RUN_TYPE : "Not Started"

if (LLARS_RUNNING && LLARS_RunStartTick > 0)
{
	developerElapsedMS := A_TickCount - LLARS_RunStartTick
	developerElapsedHours := Floor(developerElapsedMS / 3600000)
	developerElapsedMinutes := Floor(Mod(developerElapsedMS, 3600000) / 60000)
	developerElapsedSeconds := Floor(Mod(developerElapsedMS, 60000) / 1000)
	developerElapsed := developerElapsedHours . "h " . developerElapsedMinutes . "m " . developerElapsedSeconds . "s"
}
else
	developerElapsed := "--"

if (developerRunType = "RunCount" && runcount3 != "")
	developerProgress := count2 . " / " . runcount3
else if (developerRunType = "Timer" && LLARS_RUNNING)
	developerProgress := LLARS_TimerRemainingText(endTime - A_TickCount)
else
	developerProgress := "--"

LLARS_DeveloperMousePixel(developerMouseX, developerMouseY, developerPixelColor, developerInspectorStatus)
developerPixelTargets := LLARS_DeveloperPixelTargets()

developerStartState := (!LLARS_RUNNING && !LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerInfoState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerConfigState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"

developerInfoName := LLARS_RUNNING ? "Pause" : "Information"
developerConfigName := LLARS_RUNNING ? "Resume" : "Configuration"

developerHotkeys := ""
developerHotkeys .= "Start: " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk1) . " (" . developerStartState . ")`n"
developerHotkeys .= developerInfoName . ": " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk2) . " (" . developerInfoState . ")`n"
developerHotkeys .= developerConfigName . ": " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk3) . " (" . developerConfigState . ")`n"
developerHotkeys .= "Exit: " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk4) . " (Enabled)"
if (LLARS_lhk5 != "")
	developerHotkeys .= "`nDeveloper Mode: " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk5)

developerScriptHotkeys := LLARS_DeveloperScriptHotkeys()
if (developerScriptHotkeys != "")
	developerHotkeys .= "`n`n" . developerScriptHotkeys

developerActions := LLARS_DeveloperActions
if (developerActions = "")
	developerActions := "No framework actions recorded yet."

developerDiagnostics := LLARS_DeveloperConfigDiagnostics()

GuiControl, Dev:, DeveloperRunningText, %developerRunning%
GuiControl, Dev:, DeveloperRunTypeText, %developerRunType%
GuiControl, Dev:, DeveloperProgressText, %developerProgress%
GuiControl, Dev:, DeveloperElapsedText, %developerElapsed%
GuiControl, Dev:, DeveloperFinalSleepText, %developerFinalSleep%

developerInspectorSignature := LLARS_DeveloperInspectorSignature(developerPixelTargets)
if (developerInspectorSignature != LLARS_DeveloperLastInspectorSignature)
{
	LLARS_DeveloperCreateInspectorPanel(developerInspectorStatus, developerMouseX, developerMouseY, developerPixelColor, developerPixelTargets, DeveloperGuiHwnd, true)
	LLARS_DeveloperLastInspectorSignature := developerInspectorSignature
}
else
	LLARS_DeveloperRefreshInspectorPanel(developerInspectorStatus, developerMouseX, developerMouseY, developerPixelColor, developerPixelTargets)

; Active Hotkeys uses the same scrollable child-pane method as Live Inspector.
if (developerHotkeys != LLARS_DeveloperLastHotkeys)
{
	LLARS_DeveloperCreateHotkeysPanel(developerHotkeys, DeveloperGuiHwnd, true)
	LLARS_DeveloperLastHotkeys := developerHotkeys
}

if (developerActions != LLARS_DeveloperLastActions)
{
	GuiControl, Dev:, DeveloperActionsText, %developerActions%
	LLARS_DeveloperLastActions := developerActions
	PostMessage, 0x115, 7, 0,, ahk_id %DeveloperActionsHwnd%
}

if (developerDiagnostics != LLARS_DeveloperLastDiagnostics)
{
	GuiControl, Dev:, DeveloperDiagnosticsText, %developerDiagnostics%
	LLARS_DeveloperLastDiagnostics := developerDiagnostics
}
return

; Closes only the developer diagnostics window.
CloseDeveloperMode:
SetTimer, LLARS_DeveloperAutoRefresh, Off
SetTimer, LLARS_DeveloperTimingAuditAutoRefresh, Off
Gui Audit: Destroy
DeveloperTimingAuditHwnd := 0
DeveloperTimingAuditListHwnd := 0
LLARS_DeveloperTimingAuditPaused := false
DeveloperTimingAuditLastText := ""
LLARS_DeveloperSavePosition(DeveloperGuiHwnd)
LLARS_DeveloperUIAction("Developer Mode", "Closed")
LLARS_DeveloperDestroyInspectorPanel()
LLARS_DeveloperDestroyHotkeysPanel()
Gui Dev: Destroy
DeveloperGuiHwnd := 0
Gui 1: Default
Gui 1: Show
return

; Builds Developer Mode pixel-target data from active typed Config.ini color sections.
LLARS_DeveloperPixelTargets()
{
	global LLARS_SCRIPT_DIR

	targets := []
	ConfigPath := LLARS_SCRIPT_DIR . "\Config.ini"
	if !FileExist(ConfigPath)
	{
		targets.Push({Message: "Config.ini not found"})
		return targets
	}

	IniRead, sections, %ConfigPath%
	if (sections = "ERROR")
	{
		targets.Push({Message: "Unable to read Config.ini"})
		return targets
	}

	pointSections := []
	colorSections := []

	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		if !LLARS_DeveloperConfigSectionActive(ConfigPath, section)
			continue

		configType := GetConfigType(ConfigPath, section)
		if (configType = "coordinate")
		{
			IniRead, x, %ConfigPath%, %section%, x, ERROR
			IniRead, y, %ConfigPath%, %section%, y, ERROR
			if (x != "ERROR" || y != "ERROR")
				pointSections.Push({Name: section, X: Trim(x), Y: Trim(y)})
			continue
		}

		if (configType = "color")
			colorSections.Push(section)
	}

	if (colorSections.Length() = 0)
	{
		targets.Push({Message: "No configured color targets."})
		return targets
	}

	; Only the legacy [Pixel Coordinate] section is treated as an implicit shared
	; fixed pixel.
	sharedPoint := ""
	for _, pointInfo in pointSections
	{
		if (pointInfo.Name = "Pixel Coordinate")
		{
			sharedPoint := pointInfo
			break
		}
	}

	pixelCache := {}
	for colorIndex, colorSection in colorSections
	{
		pointInfo := LLARS_DeveloperPixelPointForColor(ConfigPath, colorSection, pointSections, sharedPoint, colorIndex)
		coordinateText := "Not Set"
		actualColor := "--"

		if IsObject(pointInfo)
		{
			x := pointInfo.X
			y := pointInfo.Y
			if (LLARS_IsNumericConfigValue(x) && LLARS_IsNumericConfigValue(y))
			{
				x := Round(x + 0)
				y := Round(y + 0)
				coordinateText := "x" . x . " || y" . y
				cacheKey := x . "|" . y
				if (pixelCache.HasKey(cacheKey))
					actualColor := pixelCache[cacheKey]
				else
				{
					actualColor := LLARS_DeveloperPixelColorAt(x, y)
					pixelCache[cacheKey] := actualColor
				}
			}
		}

		colorKey := LLARS_GetColorKey(ConfigPath, colorSection)
		IniRead, targetColor, %ConfigPath%, %colorSection%, %colorKey%, ERROR
		targetColor := Trim(targetColor)
		if (targetColor = "ERROR" || !RegExMatch(targetColor, "i)^0x[0-9A-F]{6}$"))
			targetColor := "Not Set"
		else
			StringUpper, targetColor, targetColor

		targets.Push({Name: colorSection
			, Coordinates: IsObject(pointInfo) ? coordinateText : "Search"
			, ActualColor: actualColor
			, TargetColor: targetColor
			, HasFixedPoint: IsObject(pointInfo)})
	}

	return targets
}

; Creates one scrollable Live Inspector pane.
LLARS_DeveloperCreateInspectorPanel(inspectorStatus, mouseX, mouseY, mouseColor, targets, parentHwnd, preserveScroll := false)
{
	static inspectorMessagesRegistered := false
	global DeveloperInspectorHwnd, DeveloperInspectorContentHeight, DeveloperInspectorViewHeight
	global DeveloperInspectorScrollPos, DeveloperInspectorStatusHwnd, DeveloperInspectorMouseXHwnd
	global DeveloperInspectorMouseYHwnd, DeveloperInspectorMouseColorHwnd
	global DeveloperInspectorActualHwnds, DeveloperInspectorTargetHwnds

	preservedScroll := preserveScroll ? LLARS_DeveloperGetInspectorScrollPos() : 0
	LLARS_DeveloperDestroyInspectorPanel(false)

	DeveloperInspectorViewHeight := 166
	DeveloperInspectorScrollPos := 0
	DeveloperInspectorActualHwnds := []
	DeveloperInspectorTargetHwnds := []

	Gui DevInspector: +Parent%parentHwnd% -Caption -Border +ToolWindow +HwndDeveloperInspectorHwnd +0x200000
	Gui DevInspector: Margin, 0, 0

	rowY := 3
	LLARS_DeveloperAddInspectorRow("Game Status", inspectorStatus, rowY, DeveloperInspectorStatusHwnd)
	rowY += 21
	LLARS_DeveloperAddInspectorRow("Mouse POS X", mouseX, rowY, DeveloperInspectorMouseXHwnd)
	rowY += 21
	LLARS_DeveloperAddInspectorRow("Mouse POS Y", mouseY, rowY, DeveloperInspectorMouseYHwnd)
	rowY += 21
	LLARS_DeveloperAddInspectorRow("Mouse RGB", mouseColor, rowY, DeveloperInspectorMouseColorHwnd)
	rowY += 29

	if (!IsObject(targets) || targets.Length() = 0)
		targets := [{Message: "No configured color targets."}]

	if (targets[1].HasKey("Message"))
	{
		messageText := targets[1].Message
		Gui DevInspector: Font, s10 Norm cBlack
		Gui DevInspector: Add, Text, x5 y%rowY% w195 h36, %messageText%
		rowY += 40
	}
	else
	{
		for targetIndex, targetInfo in targets
		{
			sectionName := targetInfo.Name
			coordinates := targetInfo.Coordinates
			actualColor := targetInfo.ActualColor
			targetColor := targetInfo.TargetColor

			sectionDisplay := sectionName
			sectionHeight := 18
			if RegExMatch(sectionName, "i)^(Resource|Deposit) Color ([0-9]+)$", sectionParts)
			{
				sectionDisplay := sectionParts1 . "`nColor " . sectionParts2
				sectionHeight := 36
			}
			valueY := rowY + Floor((sectionHeight - 18) / 2)

			Gui DevInspector: Font, s10 Norm cBlack
			Gui DevInspector: Add, Text, x5 y%rowY% w108 h%sectionHeight%, %sectionDisplay%
			; Keep the right-side mode/value deliberately short so long target names stay readable inside the fixed-width Live Inspector pane.
			Gui DevInspector: Font, s10 Bold cBlack
			Gui DevInspector: Add, Text, x116 y%valueY% w84 h20 Right -Wrap, %coordinates%
			rowY += sectionHeight + 5

			actualHwnd := ""
			targetHwnd := ""
			if (targetInfo.HasFixedPoint)
			{
				LLARS_DeveloperAddInspectorRow("Actual RGB", actualColor, rowY, actualHwnd)
				rowY += 21
				LLARS_DeveloperAddInspectorRow("Target RGB", targetColor, rowY, targetHwnd)
				rowY += 29
			}
			else
			{
				LLARS_DeveloperAddInspectorRow("Target RGB", targetColor, rowY, targetHwnd)
				rowY += 29
			}
			DeveloperInspectorActualHwnds.Push(actualHwnd)
			DeveloperInspectorTargetHwnds.Push(targetHwnd)
		}
	}

	DeveloperInspectorContentHeight := Max(rowY, DeveloperInspectorViewHeight)

	; Show the child GUI hidden first, then position it with SetWindowPos.
	Gui DevInspector: Show, Hide w230 h%DeveloperInspectorViewHeight%
	DllCall("SetWindowPos", "Ptr", DeveloperInspectorHwnd, "Ptr", 0
		, "Int", 30, "Int", 166, "Int", 230, "Int", DeveloperInspectorViewHeight
		, "UInt", 0x0040)
	DllCall("RedrawWindow", "Ptr", DeveloperInspectorHwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
	LLARS_DeveloperConfigureInspectorScroll()
	if (preservedScroll > 0)
		LLARS_DeveloperSetInspectorScroll(preservedScroll)

	if (!inspectorMessagesRegistered)
	{
		OnMessage(0x115, "LLARS_DeveloperPaneVScroll")
		OnMessage(0x20A, "LLARS_DeveloperPaneMouseWheel")
		inspectorMessagesRegistered := true
	}
}

LLARS_DeveloperAddInspectorRow(labelText, valueText, rowY, ByRef valueHwnd)
{
	Gui DevInspector: Font, s10 Norm cBlack
	Gui DevInspector: Add, Text, x5 y%rowY% w105 h18 -Wrap, %labelText%
	Gui DevInspector: Font, s10 Bold cBlack
	Gui DevInspector: Add, Text, x113 y%rowY% w88 h18 Right -Wrap hwndDeveloperInspectorValueHwnd, %valueText%
	valueHwnd := DeveloperInspectorValueHwnd
}

LLARS_DeveloperRefreshInspectorPanel(inspectorStatus, mouseX, mouseY, mouseColor, targets)
{
	global DeveloperInspectorHwnd, DeveloperInspectorStatusHwnd, DeveloperInspectorMouseXHwnd
	global DeveloperInspectorMouseYHwnd, DeveloperInspectorMouseColorHwnd
	global DeveloperInspectorActualHwnds, DeveloperInspectorTargetHwnds

	if (!DeveloperInspectorHwnd)
		return

	LLARS_DeveloperSetInspectorText(DeveloperInspectorStatusHwnd, inspectorStatus)
	LLARS_DeveloperSetInspectorText(DeveloperInspectorMouseXHwnd, mouseX)
	LLARS_DeveloperSetInspectorText(DeveloperInspectorMouseYHwnd, mouseY)
	LLARS_DeveloperSetInspectorText(DeveloperInspectorMouseColorHwnd, mouseColor)

	if (!IsObject(targets) || targets.Length() = 0 || targets[1].HasKey("Message"))
		return

	for targetIndex, targetInfo in targets
	{
		actualHwnd := DeveloperInspectorActualHwnds[targetIndex]
		targetHwnd := DeveloperInspectorTargetHwnds[targetIndex]
		LLARS_DeveloperSetInspectorText(actualHwnd, targetInfo.ActualColor)
		LLARS_DeveloperSetInspectorText(targetHwnd, targetInfo.TargetColor)
	}
}

LLARS_DeveloperSetInspectorText(controlHwnd, valueText)
{
	if (controlHwnd)
		ControlSetText,, %valueText%, ahk_id %controlHwnd%
}

LLARS_DeveloperCreateHotkeysPanel(hotkeysText, parentHwnd, preserveScroll := false)
{
	global DeveloperHotkeysHwnd, DeveloperHotkeysContentHeight, DeveloperHotkeysViewHeight
	global DeveloperHotkeysScrollPos

	preservedScroll := preserveScroll ? LLARS_DeveloperGetHotkeysScrollPos() : 0
	LLARS_DeveloperDestroyHotkeysPanel(false)

	DeveloperHotkeysViewHeight := 166
	DeveloperHotkeysScrollPos := 0

	Gui DevHotkeys: +Parent%parentHwnd% -Caption -Border +ToolWindow +HwndDeveloperHotkeysHwnd +0x200000
	Gui DevHotkeys: Margin, 0, 0

	rowY := 3
	if (Trim(hotkeysText, " `t`r`n") = "")
		hotkeysText := "No active hotkeys"

	Loop, Parse, hotkeysText, `n, `r
	{
		lineText := A_LoopField
		if (Trim(lineText) = "")
		{
			rowY += 9
			continue
		}

		separatorPos := InStr(lineText, ":")
		if (separatorPos > 0)
		{
			labelText := Trim(SubStr(lineText, 1, separatorPos - 1))
			valueText := Trim(SubStr(lineText, separatorPos + 1))
			LLARS_DeveloperAddHotkeyRow(labelText, valueText, rowY)
		}
		else
		{
			Gui DevHotkeys: Font, s10 Norm cBlack
			Gui DevHotkeys: Add, Text, x5 y%rowY% w196 h18 -Wrap, %lineText%
		}
		rowY += 21
	}

	DeveloperHotkeysContentHeight := Max(rowY, DeveloperHotkeysViewHeight)
	Gui DevHotkeys: Show, Hide w230 h%DeveloperHotkeysViewHeight%
	DllCall("SetWindowPos", "Ptr", DeveloperHotkeysHwnd, "Ptr", 0
		, "Int", 300, "Int", 166, "Int", 230, "Int", DeveloperHotkeysViewHeight
		, "UInt", 0x0040)
	DllCall("RedrawWindow", "Ptr", DeveloperHotkeysHwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
	LLARS_DeveloperConfigureHotkeysScroll()
	if (preservedScroll > 0)
		LLARS_DeveloperSetHotkeysScroll(preservedScroll)
}

LLARS_DeveloperAddHotkeyRow(labelText, valueText, rowY)
{
	Gui DevHotkeys: Font, s10 Norm cBlack
	Gui DevHotkeys: Add, Text, x5 y%rowY% w118 h18 -Wrap, %labelText%
	Gui DevHotkeys: Font, s10 Bold cBlack
	Gui DevHotkeys: Add, Text, x126 y%rowY% w87 h18 Right -Wrap, %valueText%
}

LLARS_DeveloperConfigureHotkeysScroll()
{
	global DeveloperHotkeysHwnd, DeveloperHotkeysContentHeight
	global DeveloperHotkeysViewHeight, DeveloperHotkeysScrollPos

	if (!DeveloperHotkeysHwnd)
		return

	maxPos := Max(0, DeveloperHotkeysContentHeight - DeveloperHotkeysViewHeight)
	DeveloperHotkeysScrollPos := Max(0, Min(maxPos, DeveloperHotkeysScrollPos + 0))

	VarSetCapacity(scrollInfo, 28, 0)
	NumPut(28, scrollInfo, 0, "UInt")
	NumPut(0x17, scrollInfo, 4, "UInt")
	NumPut(0, scrollInfo, 8, "Int")
	NumPut(Max(0, DeveloperHotkeysContentHeight - 1), scrollInfo, 12, "Int")
	NumPut(DeveloperHotkeysViewHeight, scrollInfo, 16, "UInt")
	NumPut(DeveloperHotkeysScrollPos, scrollInfo, 20, "Int")
	DllCall("SetScrollInfo", "Ptr", DeveloperHotkeysHwnd, "Int", 1, "Ptr", &scrollInfo, "Int", true)
	DllCall("ShowScrollBar", "Ptr", DeveloperHotkeysHwnd, "Int", 1, "Int", maxPos > 0)
}

LLARS_DeveloperGetHotkeysScrollPos()
{
	global DeveloperHotkeysHwnd, DeveloperHotkeysScrollPos

	if (!DeveloperHotkeysHwnd)
		return DeveloperHotkeysScrollPos + 0

	VarSetCapacity(scrollInfo, 28, 0)
	NumPut(28, scrollInfo, 0, "UInt")
	NumPut(0x4, scrollInfo, 4, "UInt")
	if DllCall("GetScrollInfo", "Ptr", DeveloperHotkeysHwnd, "Int", 1, "Ptr", &scrollInfo)
		return NumGet(scrollInfo, 20, "Int")
	return DeveloperHotkeysScrollPos + 0
}

LLARS_DeveloperSetHotkeysScroll(newPos)
{
	global DeveloperHotkeysHwnd, DeveloperHotkeysContentHeight
	global DeveloperHotkeysViewHeight, DeveloperHotkeysScrollPos

	if (!DeveloperHotkeysHwnd)
		return

	maxPos := Max(0, DeveloperHotkeysContentHeight - DeveloperHotkeysViewHeight)
	newPos := Max(0, Min(maxPos, Round(newPos)))
	oldPos := DeveloperHotkeysScrollPos + 0
	if (newPos = oldPos)
		return

	DeveloperHotkeysScrollPos := newPos
	DllCall("ScrollWindowEx", "Ptr", DeveloperHotkeysHwnd, "Int", 0, "Int", oldPos - newPos
		, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0x0007)

	VarSetCapacity(scrollInfo, 28, 0)
	NumPut(28, scrollInfo, 0, "UInt")
	NumPut(0x4, scrollInfo, 4, "UInt")
	NumPut(newPos, scrollInfo, 20, "Int")
	DllCall("SetScrollInfo", "Ptr", DeveloperHotkeysHwnd, "Int", 1, "Ptr", &scrollInfo, "Int", true)
	DllCall("UpdateWindow", "Ptr", DeveloperHotkeysHwnd)
}

LLARS_DeveloperDestroyHotkeysPanel(resetScroll := true)
{
	global DeveloperHotkeysHwnd, DeveloperHotkeysContentHeight
	global DeveloperHotkeysViewHeight, DeveloperHotkeysScrollPos

	Gui DevHotkeys: Destroy
	DeveloperHotkeysHwnd := ""
	DeveloperHotkeysContentHeight := 0
	DeveloperHotkeysViewHeight := 0
	if (resetScroll)
		DeveloperHotkeysScrollPos := 0
}

LLARS_DeveloperInspectorSignature(targets)
{
	if (!IsObject(targets) || targets.Length() = 0)
		return ""

	if (targets[1].HasKey("Message"))
		return "MESSAGE|" . targets[1].Message

	signature := ""
	for targetIndex, targetInfo in targets
		signature .= targetInfo.Name . "|" . targetInfo.Coordinates . "`n"
	return signature
}

LLARS_DeveloperConfigureInspectorScroll()
{
	global DeveloperInspectorHwnd, DeveloperInspectorContentHeight
	global DeveloperInspectorViewHeight, DeveloperInspectorScrollPos

	if (!DeveloperInspectorHwnd)
		return

	maxPos := Max(0, DeveloperInspectorContentHeight - DeveloperInspectorViewHeight)
	DeveloperInspectorScrollPos := Max(0, Min(maxPos, DeveloperInspectorScrollPos + 0))

	VarSetCapacity(scrollInfo, 28, 0)
	NumPut(28, scrollInfo, 0, "UInt")
	NumPut(0x17, scrollInfo, 4, "UInt")
	NumPut(0, scrollInfo, 8, "Int")
	NumPut(Max(0, DeveloperInspectorContentHeight - 1), scrollInfo, 12, "Int")
	NumPut(DeveloperInspectorViewHeight, scrollInfo, 16, "UInt")
	NumPut(DeveloperInspectorScrollPos, scrollInfo, 20, "Int")
	DllCall("SetScrollInfo", "Ptr", DeveloperInspectorHwnd, "Int", 1, "Ptr", &scrollInfo, "Int", true)
	DllCall("ShowScrollBar", "Ptr", DeveloperInspectorHwnd, "Int", 1, "Int", maxPos > 0)
}

LLARS_DeveloperGetInspectorScrollPos()
{
	global DeveloperInspectorHwnd, DeveloperInspectorScrollPos

	if (!DeveloperInspectorHwnd)
		return DeveloperInspectorScrollPos + 0

	VarSetCapacity(scrollInfo, 28, 0)
	NumPut(28, scrollInfo, 0, "UInt")
	NumPut(0x4, scrollInfo, 4, "UInt")
	if DllCall("GetScrollInfo", "Ptr", DeveloperInspectorHwnd, "Int", 1, "Ptr", &scrollInfo)
		return NumGet(scrollInfo, 20, "Int")
	return DeveloperInspectorScrollPos + 0
}

LLARS_DeveloperSetInspectorScroll(newPos)
{
	global DeveloperInspectorHwnd, DeveloperInspectorContentHeight
	global DeveloperInspectorViewHeight, DeveloperInspectorScrollPos

	if (!DeveloperInspectorHwnd)
		return

	maxPos := Max(0, DeveloperInspectorContentHeight - DeveloperInspectorViewHeight)
	newPos := Max(0, Min(maxPos, Round(newPos)))
	oldPos := DeveloperInspectorScrollPos + 0
	if (newPos = oldPos)
		return

	DeveloperInspectorScrollPos := newPos
	DllCall("ScrollWindowEx", "Ptr", DeveloperInspectorHwnd, "Int", 0, "Int", oldPos - newPos
		, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0x0007)

	VarSetCapacity(scrollInfo, 28, 0)
	NumPut(28, scrollInfo, 0, "UInt")
	NumPut(0x4, scrollInfo, 4, "UInt")
	NumPut(newPos, scrollInfo, 20, "Int")
	DllCall("SetScrollInfo", "Ptr", DeveloperInspectorHwnd, "Int", 1, "Ptr", &scrollInfo, "Int", true)
	DllCall("UpdateWindow", "Ptr", DeveloperInspectorHwnd)
}

LLARS_DeveloperPaneVScroll(wParam, lParam, msg, hWnd)
{
	global DeveloperInspectorHwnd, DeveloperHotkeysHwnd

	if (hWnd = DeveloperInspectorHwnd)
		return LLARS_DeveloperInspectorVScroll(wParam, lParam, msg, hWnd)
	if (hWnd = DeveloperHotkeysHwnd)
		return LLARS_DeveloperHotkeysVScroll(wParam, lParam, msg, hWnd)
}

LLARS_DeveloperHotkeysVScroll(wParam, lParam, msg, hWnd)
{
	global DeveloperHotkeysHwnd, DeveloperHotkeysScrollPos
	global DeveloperHotkeysContentHeight, DeveloperHotkeysViewHeight

	if (!DeveloperHotkeysHwnd || hWnd != DeveloperHotkeysHwnd)
		return

	scrollCode := wParam & 0xFFFF
	newPos := DeveloperHotkeysScrollPos + 0
	pageAmount := Max(42, DeveloperHotkeysViewHeight - 21)
	maxPos := Max(0, DeveloperHotkeysContentHeight - DeveloperHotkeysViewHeight)

	if (scrollCode = 0)
		newPos -= 21
	else if (scrollCode = 1)
		newPos += 21
	else if (scrollCode = 2)
		newPos -= pageAmount
	else if (scrollCode = 3)
		newPos += pageAmount
	else if (scrollCode = 4 || scrollCode = 5)
	{
		VarSetCapacity(scrollInfo, 28, 0)
		NumPut(28, scrollInfo, 0, "UInt")
		NumPut(0x10, scrollInfo, 4, "UInt")
		if DllCall("GetScrollInfo", "Ptr", DeveloperHotkeysHwnd, "Int", 1, "Ptr", &scrollInfo)
			newPos := NumGet(scrollInfo, 24, "Int")
	}
	else if (scrollCode = 6)
		newPos := 0
	else if (scrollCode = 7)
		newPos := maxPos
	else
		return 0

	LLARS_DeveloperSetHotkeysScroll(newPos)
	return 0
}

LLARS_DeveloperPaneMouseWheel(wParam, lParam, msg, hWnd)
{
	global DeveloperInspectorHwnd, DeveloperHotkeysHwnd
	global DeveloperInspectorScrollPos, DeveloperHotkeysScrollPos

	MouseGetPos,,, hoveredWindow, hoveredControl, 2

	isOverInspector := (hoveredWindow = DeveloperInspectorHwnd || hoveredControl = DeveloperInspectorHwnd)
	if (!isOverInspector && hoveredControl != "" && DeveloperInspectorHwnd)
		isOverInspector := DllCall("IsChild", "Ptr", DeveloperInspectorHwnd, "Ptr", hoveredControl)

	isOverHotkeys := (hoveredWindow = DeveloperHotkeysHwnd || hoveredControl = DeveloperHotkeysHwnd)
	if (!isOverHotkeys && hoveredControl != "" && DeveloperHotkeysHwnd)
		isOverHotkeys := DllCall("IsChild", "Ptr", DeveloperHotkeysHwnd, "Ptr", hoveredControl)

	if (!isOverInspector && !isOverHotkeys)
		return

	wheelDelta := (wParam >> 16) & 0xFFFF
	if (wheelDelta > 32767)
		wheelDelta -= 65536
	if (wheelDelta = 0)
		return 0

	if (isOverInspector)
		LLARS_DeveloperSetInspectorScroll(DeveloperInspectorScrollPos - ((wheelDelta / 120) * 42))
	else
		LLARS_DeveloperSetHotkeysScroll(DeveloperHotkeysScrollPos - ((wheelDelta / 120) * 42))
	return 0
}

LLARS_DeveloperInspectorVScroll(wParam, lParam, msg, hWnd)
{
	global DeveloperInspectorHwnd, DeveloperInspectorScrollPos
	global DeveloperInspectorContentHeight, DeveloperInspectorViewHeight

	if (!DeveloperInspectorHwnd || hWnd != DeveloperInspectorHwnd)
		return

	scrollCode := wParam & 0xFFFF
	newPos := DeveloperInspectorScrollPos + 0
	pageAmount := Max(42, DeveloperInspectorViewHeight - 21)
	maxPos := Max(0, DeveloperInspectorContentHeight - DeveloperInspectorViewHeight)

	if (scrollCode = 0)
		newPos -= 21
	else if (scrollCode = 1)
		newPos += 21
	else if (scrollCode = 2)
		newPos -= pageAmount
	else if (scrollCode = 3)
		newPos += pageAmount
	else if (scrollCode = 4 || scrollCode = 5)
	{
		VarSetCapacity(scrollInfo, 28, 0)
		NumPut(28, scrollInfo, 0, "UInt")
		NumPut(0x10, scrollInfo, 4, "UInt")
		if DllCall("GetScrollInfo", "Ptr", DeveloperInspectorHwnd, "Int", 1, "Ptr", &scrollInfo)
			newPos := NumGet(scrollInfo, 24, "Int")
	}
	else if (scrollCode = 6)
		newPos := 0
	else if (scrollCode = 7)
		newPos := maxPos
	else
		return 0

	LLARS_DeveloperSetInspectorScroll(newPos)
	return 0
}

LLARS_DeveloperInspectorMouseWheel(wParam, lParam, msg, hWnd)
{
	global DeveloperInspectorHwnd, DeveloperInspectorScrollPos

	if (!DeveloperInspectorHwnd)
		return

	MouseGetPos,,, hoveredWindow, hoveredControl, 2
	isOverInspector := (hoveredWindow = DeveloperInspectorHwnd || hoveredControl = DeveloperInspectorHwnd)
	if (!isOverInspector && hoveredControl != "")
		isOverInspector := DllCall("IsChild", "Ptr", DeveloperInspectorHwnd, "Ptr", hoveredControl)
	if (!isOverInspector)
		return

	wheelDelta := (wParam >> 16) & 0xFFFF
	if (wheelDelta > 32767)
		wheelDelta -= 65536
	if (wheelDelta = 0)
		return 0

	LLARS_DeveloperSetInspectorScroll(DeveloperInspectorScrollPos - ((wheelDelta / 120) * 42))
	return 0
}

LLARS_DeveloperDestroyInspectorPanel(resetScroll := true)
{
	global DeveloperInspectorHwnd, DeveloperInspectorContentHeight, DeveloperInspectorViewHeight
	global DeveloperInspectorScrollPos, DeveloperInspectorStatusHwnd, DeveloperInspectorMouseXHwnd
	global DeveloperInspectorMouseYHwnd, DeveloperInspectorMouseColorHwnd
	global DeveloperInspectorActualHwnds, DeveloperInspectorTargetHwnds

	Gui DevInspector: Destroy
	DeveloperInspectorHwnd := ""
	DeveloperInspectorContentHeight := 0
	DeveloperInspectorViewHeight := 0
	DeveloperInspectorStatusHwnd := ""
	DeveloperInspectorMouseXHwnd := ""
	DeveloperInspectorMouseYHwnd := ""
	DeveloperInspectorMouseColorHwnd := ""
	DeveloperInspectorActualHwnds := []
	DeveloperInspectorTargetHwnds := []
	if (resetScroll)
		DeveloperInspectorScrollPos := 0
}

LLARS_DeveloperConfigSectionActive(ConfigPath, section)
{
	IniRead, option, %ConfigPath%, %section%, option, true
	option := Trim(option)
	StringLower, optionLower, option
	if (optionLower = "false")
		return false

	IniRead, depends, %ConfigPath%, %section%, depends, ERROR
	if (depends != "ERROR" && Trim(depends) != "")
	{
		depends := Trim(depends)
		IniRead, dependsOption, %ConfigPath%, %depends%, option, true
		dependsOption := Trim(dependsOption)
		StringLower, dependsOptionLower, dependsOption
		if (dependsOptionLower = "false")
			return false
	}

	return true
}

LLARS_DeveloperPixelPointForColor(ConfigPath, colorSection, pointSections, sharedPoint, colorIndex)
{
	; MultiColor templates can explicitly map each color section to the exact coordinate section it belongs to.
	IniRead, mappedCoordinate, %ConfigPath%, %colorSection%, coordinate, ERROR
	mappedCoordinate := Trim(mappedCoordinate)
	if (mappedCoordinate != "" && mappedCoordinate != "ERROR")
	{
		for _, pointInfo in pointSections
		{
			if (pointInfo.Name = mappedCoordinate)
				return pointInfo
		}
	}

	if IsObject(sharedPoint)
		return sharedPoint

	colorToken := LLARS_DeveloperPixelSectionToken(colorSection)
	if (colorToken != "")
	{
		for _, pointInfo in pointSections
		{
			if (LLARS_DeveloperPixelSectionToken(pointInfo.Name) = colorToken)
				return pointInfo
		}
	}

	; Do not pair a standalone color with a coordinate by list position.
	return ""
}

LLARS_DeveloperPixelSectionToken(section)
{
	token := Trim(section)
	StringLower, token, token
	token := RegExReplace(token, "i)\b(target|pixel|color|coordinate|coordinates|empty|default)\b", "")
	token := RegExReplace(token, "[^a-z0-9]+", "")
	return token
}

LLARS_DeveloperPixelColorAt(x, y)
{
	if !LLARS_IsRuneScapeActive()
		return "--"

	x := Round(x + 0)
	y := Round(y + 0)
	PixelGetColor, developerColor, %x%, %y%, RGB
	if (developerColor = "")
		return "--"

	StringUpper, developerColor, developerColor
	return developerColor
}

LLARS_DeveloperHotkeyDisplay(hotkey)
{
	hotkey := Trim(hotkey)
	if (hotkey = "")
		return "Not Set"

	hasCtrl := InStr(hotkey, "^")
	hasAlt := InStr(hotkey, "!")
	hasShift := InStr(hotkey, "+")
	hasWin := InStr(hotkey, "#")

	keyName := hotkey
	StringReplace, keyName, keyName, ~, , All
	StringReplace, keyName, keyName, $, , All
	StringReplace, keyName, keyName, *, , All
	StringReplace, keyName, keyName, <, , All
	StringReplace, keyName, keyName, >, , All
	StringReplace, keyName, keyName, ^, , All
	StringReplace, keyName, keyName, !, , All
	StringReplace, keyName, keyName, +, , All
	StringReplace, keyName, keyName, #, , All
	keyName := Trim(keyName)
	keyName := RegExReplace(keyName, "i)\s+Up$")

	if (StrLen(keyName) = 1)
		StringUpper, keyName, keyName
	else
	{
		displayKey := GetKeyName(keyName)
		if (displayKey != "")
			keyName := displayKey
	}

	displayHotkey := ""
	if (hasCtrl)
		displayHotkey .= "Ctrl+"
	if (hasAlt)
		displayHotkey .= "Alt+"
	if (hasShift)
		displayHotkey .= "Shift+"
	if (hasWin)
		displayHotkey .= "Win+"

	return displayHotkey . keyName
}

LLARS_DeveloperScriptHotkeys()
{
	global LLARS_SCRIPT_DIR

	ConfigPath := LLARS_SCRIPT_DIR . "\Config.ini"
	if !FileExist(ConfigPath)
		return ""

	hotkeys := ""
	IniRead, sections, %ConfigPath%
	if (sections = "ERROR")
		return ""

	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		if (GetConfigType(ConfigPath, section) != "hotkey")
			continue

		IniRead, option, %ConfigPath%, %section%, option, true
		option := Trim(option)
		StringLower, optionLower, option
		if (optionLower = "false")
			continue

		IniRead, depends, %ConfigPath%, %section%, depends, ERROR
		if (depends != "ERROR" && Trim(depends) != "")
		{
			depends := Trim(depends)
			IniRead, dependsOption, %ConfigPath%, %depends%, option, true
			dependsOption := Trim(dependsOption)
			StringLower, dependsOptionLower, dependsOption
			if (dependsOptionLower = "false")
				continue
		}

		IniRead, hotkeyValue, %ConfigPath%, %section%, hotkey, ERROR
		if (hotkeyValue = "ERROR" || Trim(hotkeyValue) = "")
			hotkeys .= section . ": Not Set`n"
		else
			hotkeys .= section . ": " . LLARS_DeveloperHotkeyDisplay(Trim(hotkeyValue)) . "`n"
	}

	return RTrim(hotkeys, "`n`r")
}

LLARS_DeveloperConfigDiagnostics()
{
	global LLARS_SCRIPT_DIR

	ConfigPath := LLARS_SCRIPT_DIR "\Config.ini"
	if !FileExist(ConfigPath)
		return "Config.ini not found"

	diagnostics := ""
	IniRead, sections, %ConfigPath%
	if (sections = "ERROR")
		return "Unable to read Config.ini"

	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		IniRead, option, %ConfigPath%, %section%, option, true
		option := Trim(option)
		StringLower, optionLower, option
		if (optionLower = "false")
			continue

		IniRead, depends, %ConfigPath%, %section%, depends, ERROR
		if (depends != "ERROR" && Trim(depends) != "")
		{
			depends := Trim(depends)
			IniRead, dependsOption, %ConfigPath%, %depends%, option, true
			dependsOption := Trim(dependsOption)
			StringLower, dependsOptionLower, dependsOption
			if (dependsOptionLower = "false")
				continue
		}

		configType := GetConfigType(ConfigPath, section)
		if (configType = "hotkey")
		{
			IniRead, hotkeyValue, %ConfigPath%, %section%, hotkey, ERROR
			if (hotkeyValue = "ERROR" || Trim(hotkeyValue) = "")
				diagnostics .= section . ": Hotkey missing`n`n"
			else if (!LLARS_IsValidConfigHotkey(hotkeyValue))
				diagnostics .= section . ": Hotkey invalid`n`n"
			continue
		}

		if (configType = "coordinate")
		{
			IniRead, x, %ConfigPath%, %section%, x, ERROR
			IniRead, y, %ConfigPath%, %section%, y, ERROR
			IniRead, xmin, %ConfigPath%, %section%, xmin, ERROR
			IniRead, xmax, %ConfigPath%, %section%, xmax, ERROR
			IniRead, ymin, %ConfigPath%, %section%, ymin, ERROR
			IniRead, ymax, %ConfigPath%, %section%, ymax, ERROR

			hasPointCoordinates := (x != "ERROR" || y != "ERROR")
			hasRectangleCoordinates := (xmin != "ERROR" || xmax != "ERROR" || ymin != "ERROR" || ymax != "ERROR")
			coordinateInvalid := false

			if (hasPointCoordinates)
			{
				if (x = "ERROR" || y = "ERROR" || Trim(x) = "" || Trim(y) = "")
					coordinateInvalid := true
				else if (!LLARS_IsNumericConfigValue(x) || !LLARS_IsNumericConfigValue(y))
					coordinateInvalid := true
			}
			else if (hasRectangleCoordinates)
			{
				if (xmin = "ERROR" || xmax = "ERROR" || ymin = "ERROR" || ymax = "ERROR")
					coordinateInvalid := true
				else if (Trim(xmin) = "" || Trim(xmax) = "" || Trim(ymin) = "" || Trim(ymax) = "")
					coordinateInvalid := true
				else if (!LLARS_IsNumericConfigValue(xmin) || !LLARS_IsNumericConfigValue(xmax) || !LLARS_IsNumericConfigValue(ymin) || !LLARS_IsNumericConfigValue(ymax))
					coordinateInvalid := true
				else if ((xmin + 0) > (xmax + 0) || (ymin + 0) > (ymax + 0))
					coordinateInvalid := true
			}
			else
				coordinateInvalid := true

			if (coordinateInvalid)
				diagnostics .= section . ": Coordinates missing/invalid`n`n"
			continue
		}

		if (configType = "color")
		{
			colorKey := LLARS_GetColorKey(ConfigPath, section)
			IniRead, colorValue, %ConfigPath%, %section%, %colorKey%, ERROR
			if (colorValue = "ERROR" || !RegExMatch(Trim(colorValue), "i)^0x[0-9A-F]{6}$"))
				diagnostics .= section . ": Color missing/invalid`n`n"
		}
	}

	if (diagnostics = "")
		return "No typed configuration problems found."

	return RTrim(diagnostics, "`n`r")
}

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
		Gui Client: +ToolWindow
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
	Gui Client: +ToolWindow
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
