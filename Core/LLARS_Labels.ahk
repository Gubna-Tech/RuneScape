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

Else IfWinActive, Input Settings ahk_class AutoHotkeyGUI
{
	GoSub, CloseInputSettings
}

Else IfWinActive, Timing Audit ahk_class AutoHotkeyGUI
{
	GoSub, CloseDeveloperTimingAudit
}

Else IfWinActive, Developer Mode ahk_class AutoHotkeyGUI
{
	GoSub, CloseDeveloperMode
}

Else IfWinActive, Check Setup ahk_class AutoHotkeyGUI
{
	GoSub, CloseSetupCheck
}

Else IfWinActive, Setup ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	GoSub, closecombo
}

Else IfWinActive, Config Settings ahk_class AutoHotkeyGUI
{
	EnableHotkey()
	GoSub, CloseConfigSettings
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
RemainingTime := EndTime - LLARS_NowMS()
if (RemainingTime > 0)
	GuiControl, 1:, State3, % RandomSleepAmountToMinutesSeconds(RemainingTime)
else
	SetTimer, UpdateCountdown, Off

return

; Formats a millisecond countdown as minutes and seconds for the GUI.
RandomSleepAmountToMinutesSeconds(time)
{
	return LLARS_TimerRemainingText(time)
}

; =========================================================================
; |     ESTIMATED TIME COUNTDOWN     -     ESTIMATED TIME COUNTDOWN       |
; =========================================================================

; The estimate timer runs every 250 ms, but its values are displayed in
; whole seconds. Avoid invalidating transparent status text four times per second.
LLARS_GUISetRemainingText(controlId, displayText)
{
    global LLARS_GUIRemainingPaintCache
    if (!IsObject(LLARS_GUIRemainingPaintCache))
        LLARS_GUIRemainingPaintCache := {}
    if (LLARS_GUIRemainingPaintCache.HasKey(controlId) && LLARS_GUIRemainingPaintCache[controlId] == displayText)
        return false
    LLARS_GUIRemainingPaintCache[controlId] := displayText
    GuiControl, 1:, %controlId%, %displayText%
    return true
}

; Updates the current-loop and full-run estimates shown by RunCount scripts.
UpdateEstimatedTime:
LLARS_UpdateEstimatedTimeNow()
return

LLARS_UpdateEstimatedTimeNow()
{
	global LLARS_RUNNING, EstCompletedLoops, EstConfiguredFirstLoopAverage
	global EstFollowingCompletedLoops, EstFollowingAverageLoopTime
	global EstConfiguredFollowingLoopAverage, EstConfiguredLoopAverage
	global EstLoopStartTick, EstRandomSleepAdjustment, EstConfiguredSleepAdjustment, EstFinalSleepActive, EstFinalSleepEndTick
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
		LLARS_GUISetRemainingText("EstLoopRemaining", "Calculating")
		LLARS_GUISetRemainingText("EstRunRemaining", "Calculating")
		return
	}

	if (EstLoopStartTick > 0)
	{
		ElapsedLoopTime := LLARS_NowMS() - EstLoopStartTick
		PredictiveLoopRemainingTime := EstimatedLoopTime + EstRandomSleepAdjustment + EstConfiguredSleepAdjustment - ElapsedLoopTime
	}

	else
	{
		PredictiveLoopRemainingTime := EstimatedLoopTime + EstRandomSleepAdjustment + EstConfiguredSleepAdjustment
	}

	if (PredictiveLoopRemainingTime < 0)
		PredictiveLoopRemainingTime := 0
	if (EstFinalSleepActive && EstFinalSleepEndTick > 0)
		EstLoopRemainingTime := EstFinalSleepEndTick - LLARS_NowMS()
	else
		EstLoopRemainingTime := PredictiveLoopRemainingTime
	if (EstLoopRemainingTime < 0)
		EstLoopRemainingTime := 0
	EstLoopTotalSeconds := Floor(EstLoopRemainingTime / 1000)
	EstLoopHours := Floor(EstLoopTotalSeconds / 3600)
	EstLoopMinutes := Floor(Mod(EstLoopTotalSeconds, 3600) / 60)
	EstLoopSeconds := Mod(EstLoopTotalSeconds, 60)
	EstLoopDisplay := EstLoopHours "h " EstLoopMinutes "m " EstLoopSeconds "s"
	LLARS_GUISetRemainingText("EstLoopRemaining", EstLoopDisplay)
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
	LLARS_GUISetRemainingText("EstRunRemaining", EstRunDisplay)
}

; =====================================================================
; |     SETUP GUI     -     SETUP GUI     -     SETUP GUI             |
; =====================================================================

; Opens the shared Setup window for script/input setup controls. Mechanical
; script capabilities come from the same Config.ini-derived object used by the
; Selector and preflight. Global LLARS Hotkeys remain available for every script.
Combo:
LLARS_DeveloperHotkey("Setup")
Gui 1: Hide
DisableHotkey()
Menu, Tray, NoIcon
Gui Combo: Destroy
Gui Combo: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSSetupGuiHwnd
LLARS_VisualPrepare("Combo")
setupCaps := LLARS_GetScriptCapabilities()
setupHasTimer := (setupCaps.Timer && LLARS_COMBO_TIMER_LABEL != "")
setupButtonCount := 6 + (setupHasTimer ? 1 : 0)
setupLayout := LLARS_VisualStackLayout(setupButtonCount)
LLARS_VisualModalHeader("Combo", setupLayout.width, "Setup")
LLARS_VisualModalCards("Combo", setupLayout)
setupY := setupLayout.buttonY
Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gColor vSetupColorsButton", Colors
if (!setupCaps.Colors)
    GuiControl, Combo:Disable, SetupColorsButton
setupY += setupLayout.step
Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gCoordinates vSetupCoordinatesButton", Coordinates
if (!setupCaps.Coordinates)
    GuiControl, Combo:Disable, SetupCoordinatesButton
setupY += setupLayout.step
; LLARS-wide hotkeys must remain reachable even without script hotkeys.
Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gHotkey vSetupHotkeysButton", Hotkeys
setupY += setupLayout.step
if (setupHasTimer)
{
    Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gLLARS_CustomComboTimer vSetupTimerButton", Timer
    setupY += setupLayout.step
}
Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gSetupOpenScriptConfig vSetupScriptConfigButton", Script Config
if (!setupCaps.ScriptConfig)
    GuiControl, Combo:Disable, SetupScriptConfigButton
setupY += setupLayout.step
Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gInputSettings", Input Settings
setupY += setupLayout.step
Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gCheckSetup", Check Setup
Gui Combo: Add, Button, % "x" . setupLayout.buttonX . " y" . setupLayout.footerButtonY . " w" . setupLayout.buttonW . " h" . setupLayout.buttonH . " gCloseCombo", Close Setup
Gui Combo: +ToolWindow
Gui Combo: -caption
Gui Combo: Show, % "Center w" . setupLayout.width . " h" . setupLayout.height, Setup
LLARS_VisualFinish("Combo")
LLARS_DeveloperUIAction("Setup")
return

; Opens the local script Config.ini without changing the active Setup window.
SetupOpenScriptConfig:
if FileExist(LLARS_SCRIPT_DIR . "\Config.ini")
	Run, %LLARS_SCRIPT_DIR%\Config.ini
return

; Runs the shared setup preflight and shows the actionable result window.
CheckSetup:
Gui Combo: Hide
LLARS_ShowSetupPreflight()
return

; Opens the optional script-owned Timer/setup editor.
LLARS_CustomComboTimer:
if (LLARS_COMBO_TIMER_LABEL != "")
{
	LLARS_DeveloperUIAction("Setup", "Closed")
	LLARS_DeveloperUIAction("Timer Configuration")
	GoSub, %LLARS_COMBO_TIMER_LABEL%
}
return

; Returns from Setup to the main LLARS window.
closecombo:
LLARS_DeveloperUIAction("Setup", "Closed")
Gui Combo: Destroy
Gui SetupCheck: Destroy
Gui 1: Show
EnableHotkey()
return

; Returns from Check Setup to the shared Setup window.
CloseSetupCheck:
Gui SetupCheck: Destroy
Gui Combo: Show
return

; Action buttons from the preflight result reuse the existing editors.
SetupCheckHotkeys:
Gui SetupCheck: Destroy
GoSub, Hotkey
return

SetupCheckCoordinates:
Gui SetupCheck: Destroy
GoSub, Coordinates
return

SetupCheckColors:
Gui SetupCheck: Destroy
GoSub, Color
return

SetupCheckTimer:
Gui SetupCheck: Destroy
GoSub, LLARS_CustomComboTimer
return

SetupCheckInput:
Gui SetupCheck: Destroy
GoSub, InputSettings
return

; Main Setup Status rows are quick-open links whenever that capability belongs
; to the active script. Ready rows stay clickable for fast edits; Not Required
; rows are inert so users cannot enter script-inactive setup surfaces by mistake.
SetupStatusHotkeys:
LLARS_UpdateConfigStatus()
if LLARS_SetupItemIsAvailable("Hotkeys")
	GoSub, Hotkey
return

SetupStatusCoordinates:
LLARS_UpdateConfigStatus()
if LLARS_SetupItemIsAvailable("Coordinates")
	GoSub, Coordinates
return

SetupStatusColors:
LLARS_UpdateConfigStatus()
if LLARS_SetupItemIsAvailable("Colors")
	GoSub, Color
return

SetupStatusTimer:
LLARS_UpdateConfigStatus()
if (LLARS_SetupItemIsAvailable("Timer") && LLARS_COMBO_TIMER_LABEL != "")
	GoSub, LLARS_CustomComboTimer
return

SetupStatusScriptConfig:
LLARS_UpdateConfigStatus()
if LLARS_SetupItemIsAvailable("Script Config")
{
	if FileExist(LLARS_SCRIPT_DIR . "\Config.ini")
		GoSub, SetupOpenScriptConfig
	else
		MsgBox, 48, LLARS Setup, The required script Config.ini is missing.`n`nRe-extract or redownload the complete LLARS package.
}
return

; =====================================================================
; |     CONFIG SETTINGS GUI     -     CONFIG SETTINGS GUI              |
; =====================================================================

; Keeps file/backup/reset operations separate from gameplay setup.
ConfigSettings:
LLARS_DeveloperHotkey("Config Settings")
LLARS_MainSavePosition()
Gui 1: Hide
DisableHotkey()
Gui ConfigSettings: Destroy
Gui ConfigSettings: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSSettingsGuiHwnd
LLARS_VisualPrepare("ConfigSettings")
settingsLayout := LLARS_VisualStackLayout(5)
LLARS_VisualModalHeader("ConfigSettings", settingsLayout.width, "Config Settings")
LLARS_VisualModalCards("ConfigSettings", settingsLayout)
Gui ConfigSettings: Add, Button, % "x" . settingsLayout.buttonX . " y" . settingsLayout.buttonY . " w" . settingsLayout.buttonW . " h" . settingsLayout.buttonH . " gInfoLLARS", LLARS Config
Gui ConfigSettings: Add, Button, % "x" . settingsLayout.buttonX . " y" . (settingsLayout.buttonY+settingsLayout.step) . " w" . settingsLayout.buttonW . " h" . settingsLayout.buttonH . " gInfoConfig vConfigSettingsScriptButton", Script Config
if !FileExist(LLARS_SCRIPT_DIR . "\Config.ini")
    GuiControl, ConfigSettings:Disable, ConfigSettingsScriptButton
Gui ConfigSettings: Add, Button, % "x" . settingsLayout.buttonX . " y" . (settingsLayout.buttonY+2*settingsLayout.step) . " w" . settingsLayout.buttonW . " h" . settingsLayout.buttonH . " gInfoBackupConfig", Backup Config
Gui ConfigSettings: Add, Button, % "x" . settingsLayout.buttonX . " y" . (settingsLayout.buttonY+3*settingsLayout.step) . " w" . settingsLayout.buttonW . " h" . settingsLayout.buttonH . " gInfoRestoreConfig", Restore Config
Gui ConfigSettings: Add, Button, % "x" . settingsLayout.buttonX . " y" . (settingsLayout.buttonY+4*settingsLayout.step) . " w" . settingsLayout.buttonW . " h" . settingsLayout.buttonH . " gResetConfig", Reset Config
Gui ConfigSettings: Add, Button, % "x" . settingsLayout.buttonX . " y" . settingsLayout.footerButtonY . " w" . settingsLayout.buttonW . " h" . settingsLayout.buttonH . " gCloseConfigSettings", Close Config Settings
Gui ConfigSettings: +ToolWindow
Gui ConfigSettings: -caption
Gui ConfigSettings: Show, % "Center w" . settingsLayout.width . " h" . settingsLayout.height, Config Settings
LLARS_VisualFinish("ConfigSettings")
LLARS_DeveloperUIAction("Config Settings")
return

CloseConfigSettings:
LLARS_DeveloperUIAction("Config Settings", "Closed")
Gui ConfigSettings: Destroy
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
Gui ConfigSettings: Destroy
DisableHotkey()
Gui Reset: Destroy
Gui Reset: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSResetGuiHwnd
LLARS_VisualPrepare("Reset")
LLARS_VisualModalHeader("Reset", 320, "Reset Configuration")
LLARS_VisualCard("Reset", 12, 82, 296, 178)
Gui Reset: Font, s10 Bold c24324A, Segoe UI
resetConfigItems := {}
resetSectionList := " ***** Make a Selection ***** "
resetSections := LLARS_ConfigSectionList("Config.ini")

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

Gui Reset: Font, s10 Norm
Gui Reset: Add, Text, x20 y94 w280 h35 Center, Only saved Hotkeys, Coordinates, and Colors can be reset.
Gui Reset: Font, s10 Bold
Gui Reset: Add, DropDownList, x20 y139 w280 vResetSectionList Choose1 gResetConfigSelection, %resetSectionList%
Gui Reset: Add, Button, x20 y174 w132 h34 vResetConfigButton gResetSelectedConfig Disabled, Reset Selected
Gui Reset: Add, Button, x168 y174 w132 h34 gResetAllConfig, Clear All
Gui Reset: Add, Button, x20 y213 w280 h33 gCloseResetConfig, Cancel
Gui Reset: -Caption
Gui Reset: Show, w320 h274 Center, Reset Configuration
LLARS_VisualFinish("Reset")
LLARS_DeveloperUIAction("Reset Configuration")
Gui Reset: +ToolWindow
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
	GoSub, ConfigSettings
	return
}

LLARS_DeveloperAction("Config Reset || " . resetTypeDisplay . " || " . resetSection)
LLARS_UpdateConfigStatus()
LLARS_VisualConfigNotice("CONFIGURATION RESET", resetTypeDisplay . " [ " . resetSection . " ]", "Cleared from Config.ini", 1500)
GoSub, ConfigSettings
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
	GoSub, ConfigSettings
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
	GoSub, ConfigSettings
	return
}

LLARS_DeveloperAction("Config Reset || Clear All")
LLARS_UpdateConfigStatus()
LLARS_VisualConfigNotice("CONFIGURATION RESET", "All saved Hotkeys, Coordinates, and Colors cleared", "Saved to Config.ini", 1500)
GoSub, ConfigSettings
return

; Cancels the reset workflow without changing Config.ini.
CloseResetConfig:
LLARS_DeveloperUIAction("Reset Configuration", "Closed")
Gui Reset: Destroy
GoSub, ConfigSettings
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
LLARS_DeveloperUIAction("Setup", "Closed")
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSConfigGuiHwnd
LLARS_VisualPrepare("2")
LLARS_VisualModalHeader("2", 320, "Coordinates")
LLARS_VisualCard("2", 12, 82, 296, 106)
Gui 2: Font, s10 Bold c24324A, Segoe UI
DisableHotkey()
scriptHotkeyConfigFile := LLARS_SCRIPT_DIR . "\Config.ini"
allContents := LLARS_ConfigSectionList(scriptHotkeyConfigFile)
llarsContents := LLARS_ConfigSectionList(LLARS_CONFIG_FILE)
sectionList := " ***** Make a Selection ***** | "
configCoordinatesFound := false
coordinateConfigFiles := {}

; Add a section header for Config.ini coordinates.
sectionList .= "| ---- Script Coordinates ---- "

; Add sections from Config.ini that are explicitly categorized
; as coordinates.
Loop, Parse, allContents, `n, `r
{
	currentSection := LLARS_NormalizeConfigSectionName(A_LoopField)
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
	currentSection := LLARS_NormalizeConfigSectionName(A_LoopField)
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

Gui, 2: Add, DropDownList, x30 y98 w260 vSectionList Choose1 gDropDownChanged, % sectionList
Gui, 2: Add, Button, x42 y144 w236 h34 gClose, Close Coordinates
Gui 2: -Caption
Gui, 2: Show, w320 h198 Center, Coordinates
LLARS_VisualFinish("2")
LLARS_DeveloperUIAction("Coordinates")
Gui 2: +ToolWindow
return

; Closes the coordinate editor and returns to the main LLARS window.
Close:
LLARS_DeveloperUIAction("Coordinates", "Closed")
Gui 2: Destroy
LLARS_VisualRestoreMain()
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
pointXKey := LLARS_ConfigReadFile(coordinateConfigFile, selectedSection, "x", missingCoordinateKey)
pointYKey := LLARS_ConfigReadFile(coordinateConfigFile, selectedSection, "y", missingCoordinateKey)
rectangleXMinKey := LLARS_ConfigReadFile(coordinateConfigFile, selectedSection, "xmin", missingCoordinateKey)
rectangleXMaxKey := LLARS_ConfigReadFile(coordinateConfigFile, selectedSection, "xmax", missingCoordinateKey)
rectangleYMinKey := LLARS_ConfigReadFile(coordinateConfigFile, selectedSection, "ymin", missingCoordinateKey)
rectangleYMaxKey := LLARS_ConfigReadFile(coordinateConfigFile, selectedSection, "ymax", missingCoordinateKey)
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
    LLARS_VisualCapturePrompt("11", "Update Coordinates", "Right-click the pixel for [ " . selectedSection . " ]")
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
    LLARS_VisualCapturePrompt("11", "Update Coordinates", "Right-click the top-left corner for [ " . selectedSection . " ]")
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
	if !LLARS_CaptureRuneScapeClientPoint(MouseX, MouseY)
		return
	ClickCount++
	if (ClickCount = 1)
	{
		Gui 11: Destroy
		Gui 11u: Destroy
		LLARS_VisualCapturePrompt("12", "Update Coordinates", "Right-click the bottom-right corner for [ " . selectedSection . " ]")
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
		LLARS_ConfigWriteFile(configFile, ButtonText, "xmin", xmin)
		LLARS_ConfigWriteFile(configFile, ButtonText, "xmax", xmax)
		LLARS_ConfigWriteFile(configFile, ButtonText, "ymin", ymin)
		LLARS_ConfigWriteFile(configFile, ButtonText, "ymax", ymax)
		LLARS_DeveloperAction("Coordinates || " . selectedSection . " || X=" . xmin . "-" . xmax . " || Y=" . ymin . "-" . ymax, false)
		coordinateConfigDisplay := (configFile = LLARS_CONFIG_FILE) ? "LLARS Config.ini" : "Config.ini"
		LLARS_VisualConfigNotice("COORDINATES UPDATED", selectedSection, "Saved to " . coordinateConfigDisplay, 1500)
		LLARS_HideCoordinatePreview()
		LLARS_DeveloperUIAction("Coordinates", "Closed")
		Gui, 2: Destroy
		LLARS_VisualRestoreMain()
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
	if !LLARS_CaptureRuneScapeClientPoint(MouseX, MouseY)
		return
	Gui 11: Destroy
	Gui 11u: Destroy
	x := MouseX
	y := MouseY
	SetTimer, CheckClicksPixel, Off
	configFile := (coordinateConfigFile != "") ? coordinateConfigFile : "Config.ini"
	; Point sections are authoritative single X/Y coordinates.
	LLARS_ConfigDeleteFile(configFile, ButtonText, "xmin")
	LLARS_ConfigDeleteFile(configFile, ButtonText, "xmax")
	LLARS_ConfigDeleteFile(configFile, ButtonText, "ymin")
	LLARS_ConfigDeleteFile(configFile, ButtonText, "ymax")
	LLARS_ConfigWriteFile(configFile, ButtonText, "x", x)
	LLARS_ConfigWriteFile(configFile, ButtonText, "y", y)
	LLARS_DeveloperAction("Coordinates || " . selectedSection . " || X=" . x . " || Y=" . y, false)
	coordinateConfigDisplay := (configFile = LLARS_CONFIG_FILE) ? "LLARS Config.ini" : "Config.ini"
	LLARS_VisualConfigNotice("COORDINATES UPDATED", selectedSection, "Saved to " . coordinateConfigDisplay, 1500)
	LLARS_DeveloperUIAction("Coordinates", "Closed")
	Gui, 2: Destroy
	LLARS_VisualRestoreMain()
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
	if (!LLARS_ClientToScreen(x1, y1) || !LLARS_ClientToScreen(x2, y2))
		return false
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

	xmin := LLARS_ConfigReadFile(configPath, section, "xmin", "ERROR")
	xmax := LLARS_ConfigReadFile(configPath, section, "xmax", "ERROR")
	ymin := LLARS_ConfigReadFile(configPath, section, "ymin", "ERROR")
	ymax := LLARS_ConfigReadFile(configPath, section, "ymax", "ERROR")

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

	fixedX := LLARS_ConfigReadFile(configPath, section, "x", "ERROR")
	fixedY := LLARS_ConfigReadFile(configPath, section, "y", "ERROR")
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

; Captures an actual physical cursor point through the RuneScape client.
; If focus is missing we DO NOT write incorrect coordinates to Config.ini.
LLARS_CaptureRuneScapeClientPoint(ByRef clientX, ByRef clientY)
{
    global LLARS_RunRuneScapeHwnd
    hwnd := 0
    if (LLARS_RunRuneScapeHwnd && DllCall("user32\IsWindow", "Ptr", LLARS_RunRuneScapeHwnd)
        && LLARS_IsRuneScapeWindow(LLARS_RunRuneScapeHwnd))
        hwnd := LLARS_RunRuneScapeHwnd
    if (!hwnd)
    {
        hwnd := DllCall("user32\GetForegroundWindow", "Ptr")
        if (!hwnd || !LLARS_IsRuneScapeWindow(hwnd))
            hwnd := LLARS_FindRuneScapeWindow()
    }
    if (!hwnd)
        return false
    if !LLARS_AHI_CursorClientPoint(hwnd, clientX, clientY)
        return false
    VarSetCapacity(clientRect, 16, 0)
    if !DllCall("user32\GetClientRect", "Ptr", hwnd, "Ptr", &clientRect)
        return false
    return (clientX >= 0 && clientY >= 0 && clientX < NumGet(clientRect, 8, "Int")
        && clientY < NumGet(clientRect, 12, "Int"))
}

; The red target preview and click conversion share the SAME RuneScape HWND.
LLARS_ClientToScreen(ByRef x, ByRef y)
{
    global LLARS_RunRuneScapeHwnd
    hwnd := (LLARS_RunRuneScapeHwnd && DllCall("user32\IsWindow", "Ptr", LLARS_RunRuneScapeHwnd)
        && LLARS_IsRuneScapeWindow(LLARS_RunRuneScapeHwnd)) ? LLARS_RunRuneScapeHwnd : 0
    if (!hwnd)
    {
        hwnd := DllCall("user32\GetForegroundWindow", "Ptr")
        if (!hwnd || !LLARS_IsRuneScapeWindow(hwnd))
            hwnd := LLARS_FindRuneScapeWindow()
    }
    if (!hwnd || !LLARS_AHI_ClientPointToScreen(x, y, hwnd, screenX, screenY))
        return false
    x := screenX, y := screenY
    return true
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
LLARS_DeveloperUIAction("Setup", "Closed")
Gui Combo: Destroy
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSConfigGuiHwnd
LLARS_VisualPrepare("2")
LLARS_VisualModalHeader("2", 320, "Colors")
LLARS_VisualCard("2", 12, 82, 296, 106)
Gui 2: Font, s10 Bold c24324A, Segoe UI
DisableHotkey()
colorConfigFile := LLARS_SCRIPT_DIR . "\Config.ini"
allContents := LLARS_ConfigSectionList(colorConfigFile)
sectionList := " ***** Make a Selection ***** "

; Only add sections that are explicitly categorized as colors.
Loop, Parse, allContents, `n, `r
{
	currentSection := LLARS_NormalizeConfigSectionName(A_LoopField)
	if (currentSection = "")
		continue
	StringReplace, currentSection, currentSection, [, , All
	StringReplace, currentSection, currentSection, ], , All
	currentSection := Trim(currentSection)
	if (GetConfigType(colorConfigFile, currentSection) = "color")
		sectionList .= "|" currentSection
}

Gui, 2: Add, DropDownList, x30 y98 w260 vSectionList Choose1 gDropDownChanged1, % sectionList
Gui, 2: Add, Button, x42 y144 w236 h34 gClose1, Close Colors
Gui 2: -Caption
Gui, 2: Show, w320 h198 Center, Colors
LLARS_VisualFinish("2")
LLARS_DeveloperUIAction("Colors")
Gui 2: +ToolWindow
return

; Closes the color editor and returns to the main LLARS GUI.
Close1:
LLARS_DeveloperUIAction("Colors", "Closed")
Gui 2: Destroy
LLARS_VisualRestoreMain()
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
colorCoordinateSection := LLARS_ConfigReadFile(colorConfigFile, ButtonText, "coordinate", "ERROR")
colorCoordinateSection := Trim(colorCoordinateSection)
if (colorCoordinateSection = "" || colorCoordinateSection = "ERROR")
	colorCoordinateSection := LLARS_ColorMatchingPointSection(colorConfigFile, ButtonText)
if (colorCoordinateSection = "" || colorCoordinateSection = "ERROR")
{
	; Preserve legacy LLARS scripts that intentionally use [Pixel Coordinate]
	; as their shared color sample point.
	legacyColorX := LLARS_ConfigReadFile(colorConfigFile, "Pixel Coordinate", "x", "ERROR")
	legacyColorY := LLARS_ConfigReadFile(colorConfigFile, "Pixel Coordinate", "y", "ERROR")
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
	LLARS_VisualCapturePrompt("11", "Update Colors", colorHoverText, 880)
	return
}

x := LLARS_ConfigReadFile(colorConfigFile, colorCoordinateSection, "x", "ERROR")
y := LLARS_ConfigReadFile(colorConfigFile, colorCoordinateSection, "y", "ERROR")
if x is not number
{
	LLARS_CreatorConfigError(ButtonText . " references an invalid color coordinate section: " . colorCoordinateSection)
	Gui, 2: Destroy
	LLARS_VisualRestoreMain()
	EnableHotkey()
	return
}
if y is not number
{
	LLARS_CreatorConfigError(ButtonText . " references an invalid color coordinate section: " . colorCoordinateSection)
	Gui, 2: Destroy
	LLARS_VisualRestoreMain()
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

	sections := LLARS_ConfigSectionList(configFile)
	matchedSection := ""
	Loop, Parse, sections, `n, `r
	{
		section := LLARS_NormalizeConfigSectionName(A_LoopField)
		if (section = "" || GetConfigType(configFile, section) != "coordinate")
			continue

		pointX := LLARS_ConfigReadFile(configFile, section, "x", "ERROR")
		pointY := LLARS_ConfigReadFile(configFile, section, "y", "ERROR")
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
LLARS_VisualCapturePromptUpdate("11", colorHoverText)

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
LLARS_ConfigWriteFile(colorConfigFile, ButtonText, colorKey, color)
duplicateColors := LLARS_ColorDuplicateSections(colorConfigFile, ButtonText, color)
if (duplicateColors = "")
	colorResultText := ButtonText . " = " . color . " | Unique"
else
	colorResultText := ButtonText . " = " . color . " | Matches: " . duplicateColors
LLARS_DeveloperAction("Color || " . ButtonText . " || RGB=" . color . ((duplicateColors != "") ? " || Matches=" . duplicateColors : ""), false)
LLARS_DeveloperColorConfigAction(ButtonText " | " colorKey " = " color . ((duplicateColors != "") ? " | Matches: " . duplicateColors : ""))
colorConfigDisplay := (colorConfigFile = LLARS_CONFIG_FILE) ? "LLARS Config.ini" : "Config.ini"
LLARS_VisualConfigNotice("COLOR UPDATED", colorResultText, "Saved to " . colorConfigDisplay, 1800)
LLARS_DeveloperUIAction("Colors", "Closed")
Gui, 2: Destroy
LLARS_VisualRestoreMain()
EnableHotkey()
return

LLARS_ColorDuplicateSections(configFile, selectedSection, selectedColor)
{
	selectedColor := Trim(selectedColor)
	StringUpper, selectedColor, selectedColor
	duplicates := ""
	colorSections := LLARS_ConfigSectionList(configFile)
	Loop, Parse, colorSections, `n, `r
	{
		section := LLARS_NormalizeConfigSectionName(A_LoopField)
		StringReplace, section, section, [, , All
		StringReplace, section, section, ], , All
		section := Trim(section)
		if (section = "" || section = selectedSection)
			continue
		if (GetConfigType(configFile, section) != "color")
			continue
		otherKey := LLARS_GetColorKey(configFile, section)
		otherColor := LLARS_ConfigReadFile(configFile, section, otherKey, "ERROR")
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
LLARS_DeveloperUIAction("Setup", "Closed")
Gui Combo: Destroy
Gui 3: +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSHotkeyGuiHwnd
LLARS_VisualPrepare("3")
LLARS_VisualModalHeader("3", 320, "Hotkeys")
LLARS_VisualCard("3", 12, 82, 296, 176)
Gui 3: Font, s10 Bold c24324A, Segoe UI
DisableHotkey()
scriptHotkeyConfigFile := LLARS_SCRIPT_DIR . "\Config.ini"
allContents := LLARS_ConfigSectionList(scriptHotkeyConfigFile)
llarsContents := LLARS_ConfigSectionList(LLARS_CONFIG_FILE)
sectionList := " ***** Make a Selection ***** | "
hotkeyConfigFiles := {}
configHotkeysFound := false

; Add a section header for Config.ini hotkeys.
sectionList .= "| ---- Script Hotkeys ---- "

; Add sections from Config.ini that are explicitly categorized as hotkeys.
Loop, Parse, allContents, `n
{
	currentSection := LLARS_NormalizeConfigSectionName(A_LoopField)
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
	currentSection := LLARS_NormalizeConfigSectionName(A_LoopField)
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
Gui, 3: Add, DropDownList, x30 y98 w260 vSectionList Choose1 gDropDownChanged2, % sectionList
Gui, 3: Add, Text, x30 y131 w260 h20 Center vHotkeysText, Hotkeys will be displayed here
Gui, 3: Add, Hotkey, x60 y157 w200 h28 vChosenHotkey gHotkeyChanged Center Disabled, ** NONE **
Gui, 3: Add, Button, x42 y200 w236 h34 gClose2, Close Hotkeys
Gui 3: -Caption
Gui, 3: Show, w320 h270 Center, Hotkeys
LLARS_VisualFinish("3")
LLARS_DeveloperUIAction("Hotkeys")
Gui 3: +ToolWindow
return

; Closes the hotkey editor and returns to the main LLARS GUI.
Close2:
LLARS_DeveloperUIAction("Hotkeys", "Closed")
Gui 3: Destroy
LLARS_VisualRestoreMain()
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
existingHotkey := LLARS_ConfigReadFile(configFile, selectedSection, "Hotkey", "ERROR")
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
LLARS_ConfigWriteFile(selectedHotkeyConfigFile, selectedHotkeySection, "Hotkey", ChosenHotkey)
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
LLARS_VisualConfigNotice("HOTKEY UPDATED", selectedHotkeySection . "  =  " . ChosenHotkey, "Saved to " . hotkeyConfigDisplay, 1500)
LLARS_VisualRestoreMain()
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
LLARS_VisualShowStatus("blue")
GuiControl, Dev:, DeveloperRunningText, Running
Return

; Pauses the interrupted automation thread while keeping this hotkey thread
; alive so Developer Mode can continue refreshing elapsed time and live data.
PauseB:
if IsFunc("LLARS_AHI_ReleaseAllInput")
	LLARS_AHI_ReleaseAllInput()
LLARS_PAUSED := true
LLARS_DeveloperAction("Script || Paused")
GuiControl,,State2, Paused
GuiControl,,ScriptRed, % LLARS_DisplayScriptName()
LLARS_VisualShowStatus("red")
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
if IsFunc("LLARS_AHI_ReleaseAllInput")
	LLARS_AHI_ReleaseAllInput()
ExitApp

; ===================================================================
; |     INFORMATION     -     INFORMATION     -     INFORMATION     |
; ===================================================================

; Builds the Information window with current LLARS/script hotkeys,
; shared options, developer/community resources, and project details.
Info:
LLARS_DeveloperHotkey("Information")
logout := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Logout", "option", "ERROR")
sleepoption := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "option", "ERROR")
chance := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "chance", "ERROR")

; Build the list of script hotkeys automatically.
scriptHotkeys := ""
if (LLARS_lhk1 != "")
	scriptHotkeys .= "Start: " . LLARS_lhk1 . "`n"
if (LLARS_lhk2 != "")
	scriptHotkeys .= "Information: " . LLARS_lhk2 . "`n"
if (LLARS_lhk3 != "")
	scriptHotkeys .= "Setup: " . LLARS_lhk3 . "`n"
if (LLARS_lhk4 != "")
	scriptHotkeys .= "Exit: " . LLARS_lhk4 . "`n"
if (LLARS_lhk5 != "")
	scriptHotkeys .= "Developer Mode: " . LLARS_DeveloperHotkeyDisplay(LLARS_lhk5) . "`n"

; Read script-specific hotkeys from Config.ini.
configHotkeys := ""
sections := LLARS_ConfigSectionList("Config.ini")
Loop, Parse, sections, `n, `r
{
	section := A_LoopField
	if (section = "")
		continue
	type := LLARS_ConfigReadFile("Config.ini", section, "type", "ERROR")
	if (type = "hotkey")
	{
		hotkey := LLARS_ConfigReadFile("Config.ini", section, "hotkey", "ERROR")
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
; Content-driven layout with evenly centered section titles, distinct
; separators, and breathable grouping. Action callbacks remain unchanged.
hotkeyLineCount := 0
Loop, Parse, scriptHotkeys, `n, `r
    hotkeyLineCount++
if (hotkeyLineCount < 1)
    hotkeyLineCount := 1
hotkeyRowHeight := 23
hotkeyHeight := hotkeyLineCount * hotkeyRowHeight + 8
hotkeyHeadingY := 86
hotkeyTextY := hotkeyHeadingY + 34
informationHeadingY := hotkeyTextY + hotkeyHeight + 16
optionsHeadingY := informationHeadingY + 33
optionsRow1Y := optionsHeadingY + 25
optionsRow2Y := optionsRow1Y + 23
optionsRow3Y := optionsRow2Y + 23
notesHeadingY := optionsRow3Y + 36
notesTextY := notesHeadingY + 34
notesTextHeight := 63
mitY := notesTextY + notesTextHeight + 8
createdY := mitY + 23
resourcesHeadingY := createdY + 38
resourceButtonY := resourcesHeadingY + 34
resourceButtonY2 := resourceButtonY + 40
closeInfoY := resourceButtonY2 + 45
informationHeight := closeInfoY + 45

Gui 20: +AlwaysOnTop +OwnDialogs +LastFound +HwndLLARSInfoGuiHwnd +ToolWindow -Caption
LLARS_VisualPrepare("20")
Gui 20: Color, FFFFFF, FFFFFF
LLARS_VisualBanner("20", 360, 73)
Gui 20: Font, s16 Bold cFFFFFF, Segoe UI
Gui 20: Add, Text, x14 y10 w332 h29 Center BackgroundTrans, LLARS
Gui 20: Font, s11 Bold cDCE7F4, Segoe UI
Gui 20: Add, Text, x14 y40 w332 h21 Center BackgroundTrans, Information
; Hotkey section: heading is a colored band, not body text.
Gui 20: Add, Text, % "x21 y" . hotkeyHeadingY . " w318 h28 Disabled BackgroundEAF1FB"
Gui 20: Add, Text, % "x21 y" . hotkeyHeadingY . " w4 h28 Disabled Background3676E8"
Gui 20: Font, s11 Bold c1D4F8D, Segoe UI
Gui 20: Add, Text, % "x25 y" . (hotkeyHeadingY+4) . " w310 h22 Center BackgroundTrans", Script Hotkeys
Gui 20: Add, Text, % "x21 y" . (hotkeyHeadingY+28) . " w318 h1 Disabled BackgroundD0DAE7"
; Separate key labels from actual key combinations. Values are bold and
; retain the familiar 11pt reading size; no opaque Edit field is needed.
hotkeyRowY := hotkeyTextY + 4
Loop, Parse, scriptHotkeys, `n, `r
{
    hotkeyLine := A_LoopField
    colonPos := InStr(hotkeyLine, ":")
    if (colonPos > 0)
    {
        hotkeyCaption := SubStr(hotkeyLine, 1, colonPos)
        hotkeyValue := Trim(SubStr(hotkeyLine, colonPos + 1))
        Gui 20: Font, s11 Norm c24324A, Segoe UI
        Gui 20: Add, Text, % "x26 y" . hotkeyRowY . " w160 h23 Right BackgroundTrans", %hotkeyCaption%
        Gui 20: Font, s11 Bold c24324A, Segoe UI
        Gui 20: Add, Text, % "x192 y" . hotkeyRowY . " w142 h23 BackgroundTrans", %hotkeyValue%
    }
    else
    {
        Gui 20: Font, s11 Bold c24324A, Segoe UI
        Gui 20: Add, Text, % "x27 y" . hotkeyRowY . " w305 h23 Center BackgroundTrans", %hotkeyLine%
    }
    hotkeyRowY += hotkeyRowHeight
}
; Script Information is a real major section, with nested Options.
Gui 20: Add, Text, % "x21 y" . informationHeadingY . " w318 h28 Disabled BackgroundEAF1FB"
Gui 20: Add, Text, % "x21 y" . informationHeadingY . " w4 h28 Disabled Background3676E8"
Gui 20: Font, s11 Bold c1D4F8D, Segoe UI
Gui 20: Add, Text, % "x25 y" . (informationHeadingY+4) . " w310 h22 Center BackgroundTrans", Script Information
Gui 20: Add, Text, % "x21 y" . (informationHeadingY+28) . " w318 h1 Disabled BackgroundD0DAE7"
Gui 20: Font, s11 Bold c45689A, Segoe UI
Gui 20: Add, Text, x25 y%optionsHeadingY% w310 h21 Center BackgroundTrans, Script Options
Gui 20: Font, s11 Bold c253650, Segoe UI
Gui 20: Add, Text, x35 y%optionsRow1Y% w155 h20 BackgroundTrans, Logout
Gui 20: Add, Text, x35 y%optionsRow2Y% w155 h20 BackgroundTrans, Random Sleep
Gui 20: Add, Text, x35 y%optionsRow3Y% w155 h20 BackgroundTrans, Sleep Chance
Gui 20: Font, s11 Bold c24324A, Segoe UI
Gui 20: Add, Text, x193 y%optionsRow1Y% w132 h20 Right BackgroundTrans, %logout%
Gui 20: Add, Text, x193 y%optionsRow2Y% w132 h20 Right BackgroundTrans, %sleepoption%
Gui 20: Add, Text, x193 y%optionsRow3Y% w132 h20 Right BackgroundTrans, %chance%`%
; Script Notes uses a second genuine header band, not just bold body text.
Gui 20: Add, Text, % "x21 y" . notesHeadingY . " w318 h28 Disabled BackgroundEAF1FB"
Gui 20: Add, Text, % "x21 y" . notesHeadingY . " w4 h28 Disabled Background3676E8"
Gui 20: Font, s11 Bold c1D4F8D, Segoe UI
Gui 20: Add, Text, % "x25 y" . (notesHeadingY+4) . " w310 h22 Center BackgroundTrans", Script Notes
Gui 20: Add, Text, % "x21 y" . (notesHeadingY+28) . " w318 h1 Disabled BackgroundD0DAE7"
Gui 20: Font, s11 Norm c24324A, Segoe UI
Gui 20: Add, Text, x30 y%notesTextY% w301 h%notesTextHeight% Center BackgroundTrans, Additional notes/comments can be found in the script Config.ini file, available from Config Settings.
Gui 20: Add, Text, % "x21 y" . (mitY-7) . " w318 h1 Disabled BackgroundD0DAE7"
Gui 20: Font, s11 Bold c2868D9 underline, Segoe UI
Gui 20: Add, Text, x24 y%mitY% w312 h20 Center BackgroundTrans gMIT, MIT License
Gui 20: Font, s11 Norm c24324A, Segoe UI
Gui 20: Add, Text, x104 y%createdY% w88 h20 Right BackgroundTrans, Created by
Gui 20: Font, s11 Bold c24324A, Segoe UI
Gui 20: Add, Text, x197 y%createdY% w82 h20 BackgroundTrans, Gubna
; Resources is an actionable area and gets its own prominent heading.
Gui 20: Add, Text, % "x21 y" . resourcesHeadingY . " w318 h28 Disabled BackgroundEAF1FB"
Gui 20: Add, Text, % "x21 y" . resourcesHeadingY . " w4 h28 Disabled Background3676E8"
Gui 20: Font, s11 Bold c1D4F8D, Segoe UI
Gui 20: Add, Text, % "x25 y" . (resourcesHeadingY+4) . " w310 h22 Center BackgroundTrans", Resources
Gui 20: Add, Text, % "x21 y" . (resourcesHeadingY+28) . " w318 h1 Disabled BackgroundD0DAE7"
Gui 20: Font, s10 Bold c24324A, Segoe UI
Gui 20: Add, Button, x24 y%resourceButtonY% w150 h33 gDeveloperMode, Developer Mode
Gui 20: Add, Button, x186 y%resourceButtonY% w150 h33 gInfoVerifyLLARSFiles, Verify LLARS Files
Gui 20: Add, Button, x24 y%resourceButtonY2% w150 h33 gInfoCreateSupportBundle, Create Support Bundle
Gui 20: Add, Button, x186 y%resourceButtonY2% w150 h33 gDiscord, Discord
Gui 20: Add, Text, % "x21 y" . (closeInfoY-8) . " w318 h1 Disabled BackgroundD0DAE7"
Gui 20: Add, Button, x92 y%closeInfoY% w176 h34 gCloseInfo, Close Information
Gui 20: Show, center w360 h%informationHeight%, Information
LLARS_VisualFinish("20")
LLARS_DeveloperUIAction("Information")
return

; Closes the information window and restores the main LLARS GUI.
CloseInfo:
Gui 1: Default
LLARS_DeveloperUIAction("Information", "Closed")
Gui 20: Destroy
Gui 1: Show
return

; Runs the non-restrictive installation integrity check.
InfoVerifyLLARSFiles:
integrityResult := LLARS_VerifyInstallation(LLARS_ROOT, true)
integrityText := LLARS_IntegrityResultText(integrityResult)
LLARS_SupportEvent("Installation integrity", integrityResult.Status . " | Issues=" . integrityResult.IssueCount)
if (integrityResult.Status = "PASS")
	MsgBox, 0x40040, LLARS File Verification, %integrityText%
else
	MsgBox, 0x40030, LLARS File Verification, %integrityText%
return

; Creates the privacy-safe four-file support ZIP after showing its contents.
InfoCreateSupportBundle:
LLARS_CreateSupportBundle(LLARS_ROOT, true)
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

; Uses the existing Backup\Config Backup.bat in automatic mode and keeps all backup
; behavior centralized in the same public tool used by update-time protection.
InfoBackupConfig:
backupError := ""
if LLARS_RunConfigBackup(LLARS_ROOT, true, backupError)
	MsgBox, 0x40040, LLARS Configuration, Configuration backup complete.`n`nLatest snapshot: Backup\Config Backup`nPrevious successful snapshots: Config Backup 1 and Config Backup 2.
else
	MsgBox, 0x40010, LLARS Configuration, Configuration backup failed.`n`n%backupError%
return

; Restore is intentionally explicit because it overwrites current configuration.
InfoRestoreConfig:
MsgBox, 0x40034, LLARS Configuration, Restore the latest LLARS configuration backup now?`n`nSource: Backup\Config Backup`n`nThis overwrites the current shared LLARS Config.ini and any script-local Config.ini files present in that snapshot. Two previous successful snapshots are retained as Config Backup 1 and Config Backup 2.
IfMsgBox, No
	return
restoreError := ""
if !LLARS_RunConfigRestore(LLARS_ROOT, true, restoreError)
{
	MsgBox, 0x40010, LLARS Configuration, Configuration restore failed.`n`n%restoreError%
	return
}
MsgBox, 0x40040, LLARS Configuration, Configuration restored successfully.`n`nLLARS will reload now so the restored settings take effect.
Reload
return

; Opens LLARS input-backend controls. AutoHotInterception is the recommended
; backend; Standard AutoHotkey remains available as a fallback.
InputSettings:
EnableHotkey()
Gui Combo: Hide
Gui 21: Destroy
Gui 21: +AlwaysOnTop +OwnDialogs +LastFound +ToolWindow -caption +HwndLLARSInputSettingsGuiHwnd
LLARS_VisualPrepare("21")
Gui 21: Color, FFFFFF, FFFFFF
LLARS_VisualModalHeader("21", 500, "Input Settings")
Gui 21: Font, s10 Norm c24324A, Segoe UI
Gui 21: Add, Text, BackgroundTrans x20 y96 w460 h42 Center, AutoHotInterception (AHI) is the recommended LLARS input backend.`nStandard AutoHotkey remains available as a fallback.
Gui 21: Font, s10 Bold c24324A, Segoe UI
Gui 21: Add, Text, BackgroundTrans x20 y144 w460 h20 Center, Current Input Status
Gui 21: Add, Text, BackgroundTrans x15 y169 w470 h20 Center vInputBackendStatus
Gui 21: Add, Text, BackgroundTrans x15 y193 w470 h20 Center vInputActiveStatus
Gui 21: Add, Text, BackgroundTrans x15 y217 w470 h20 Center vInputDriverStatus
Gui 21: Add, Text, x12 y243 w476 h2 0x10
Gui 21: Font, s10 Norm c24324A, Segoe UI
Gui 21: Add, Text, BackgroundTrans x20 y254 w460 h20 vInputMouseRoute
Gui 21: Add, Text, BackgroundTrans x20 y278 w460 h20 vInputKeyboardRoute
Gui 21: Add, Text, BackgroundTrans x20 y302 w460 h20 vInputLastMouse
Gui 21: Add, Text, BackgroundTrans x20 y326 w460 h20 vInputLastKeyboard
Gui 21: Add, Text, BackgroundTrans x20 y350 w460 h20 vInputStartupTiming
Gui 21: Add, Text, BackgroundTrans x20 y374 w460 h20 vInputFallbackStatus
Gui 21: Add, Text, x12 y402 w476 h2 0x10
Gui 21: Font, s10 Bold c24324A, Segoe UI
Gui 21: Add, Button, x20 y414 w220 h31 gInputTestAHI, Test AHI
Gui 21: Add, Button, x260 y414 w220 h31 gInputEnableAHI, Enable / Repair AHI
Gui 21: Add, Button, x20 y450 w220 h31 gInputUseStandard, Use Standard AutoHotkey
Gui 21: Add, Button, x260 y450 w220 h31 gInputUninstallAHI vInputUninstallButton, Uninstall AHI / Interception
Gui 21: Add, Text, x12 y491 w476 h2 0x10
Gui 21: Add, Button, x135 y504 w230 h31 gCloseInputSettings, Close Input Settings
Gosub, RefreshInputSettings
Gui 21: Show, Center w500 h552, Input Settings
LLARS_VisualFinish("21")
return

RefreshInputSettings:
if IsFunc("LLARS_AHI_StatusSnapshot")
	inputSnapshot := LLARS_AHI_StatusSnapshot(LLARS_ROOT)
else
	inputSnapshot := {Configured:"Unknown", Active:"Unknown", Driver:"Unknown", MouseRoute:"Unknown", KeyboardRoute:"Unknown", MouseLast:"<none>", KeyboardLast:"<none>", Startup:"n/a", Fallback:"Unknown"}

GuiControl, 21:, InputBackendStatus, % "Backend: " . inputSnapshot.Configured
GuiControl, 21:, InputActiveStatus, % "Active input: " . inputSnapshot.Active
GuiControl, 21:, InputDriverStatus, % "AHI driver: " . inputSnapshot.Driver
GuiControl, 21:, InputMouseRoute, % "Mouse route: " . inputSnapshot.MouseRoute
GuiControl, 21:, InputKeyboardRoute, % "Keyboard route: " . inputSnapshot.KeyboardRoute
GuiControl, 21:, InputLastMouse, % "Last mouse transport: " . inputSnapshot.MouseLast
GuiControl, 21:, InputLastKeyboard, % "Last keyboard transport: " . inputSnapshot.KeyboardLast
GuiControl, 21:, InputStartupTiming, % "AHI startup: " . inputSnapshot.Startup
GuiControl, 21:, InputFallbackStatus, % "Fallback state: " . inputSnapshot.Fallback

inputDriverInstalled := IsFunc("LLARS_AHI_DriverPresent") ? LLARS_AHI_DriverPresent() : false
if (inputDriverInstalled)
	GuiControl, 21:Enable, InputUninstallButton
else
	GuiControl, 21:Disable, InputUninstallButton
return

InputTestAHI:
inputTestSummary := ""
inputTestPassed := IsFunc("LLARS_AHI_SelfTest") ? LLARS_AHI_SelfTest(LLARS_ROOT, inputTestSummary) : false
if (inputTestSummary = "")
	inputTestSummary := "AHI health test is unavailable."
if (inputTestPassed)
	MsgBox, 0x40040, LLARS AHI Test, %inputTestSummary%
else
	MsgBox, 0x40030, LLARS AHI Test, %inputTestSummary%
Gosub, RefreshInputSettings
return

InputUseStandard:
if IsFunc("LLARS_AHI_SetMode")
	LLARS_AHI_SetMode(LLARS_ROOT, "standard")
if IsFunc("LLARS_AHI_DisableForProcess")
	LLARS_AHI_DisableForProcess("Standard AutoHotkey fallback selected")
MsgBox, 0x40040, LLARS Input Settings, Standard AutoHotkey fallback is selected.`n`nYou can switch back to the recommended AHI backend at any time from Input Settings.
Gosub, RefreshInputSettings
return

InputEnableAHI:
inputAHIReady := false
if IsFunc("LLARS_AHI_Enable")
	inputAHIReady := LLARS_AHI_Enable(LLARS_ROOT, true)
if (inputAHIReady)
	MsgBox, 0x40040, LLARS Input Settings, AutoHotInterception (AHI) is enabled and ready.
Gosub, RefreshInputSettings
return

InputUninstallAHI:
if IsFunc("LLARS_AHI_DriverPresent") && !LLARS_AHI_DriverPresent()
{
	MsgBox, 0x40040, LLARS Input Settings, The AHI / Interception driver is not currently installed.
	Gosub, RefreshInputSettings
	return
}
confirmUninstall := "Uninstall the AHI / Interception keyboard and mouse driver from Windows?"
	. "`n`nLLARS will use Standard AutoHotkey fallback until AHI is installed again."
	. "`nA Windows restart is required after uninstall to finish unloading the driver."
	. "`n`nThis is normally only needed for troubleshooting or a clean AHI reinstall."
MsgBox, 0x40034, LLARS Input Driver, %confirmUninstall%
IfMsgBox, Yes
{
	if IsFunc("LLARS_AHI_RequestUninstall")
		LLARS_AHI_RequestUninstall(LLARS_ROOT, true, false)
}
Gosub, RefreshInputSettings
return

CloseInputSettings:
Gui 21: Destroy
if WinExist("Setup ahk_class AutoHotkeyGUI")
	Gui Combo: Show
else
	Gui 1: Show
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

Gui Dev: Destroy
Gui Dev: +AlwaysOnTop +OwnDialogs +LastFound +HwndDeveloperGuiHwnd
LLARS_VisualPrepare("Dev")
LLARS_VisualBanner("Dev", 560, 66)

Gui Dev: Color, FFFFFF, FFFFFF
; Native read-only panes avoid independently shown child windows obscuring labels.
Gui Dev: Font, s14 Bold cFFFFFF, Segoe UI
Gui Dev: Add, Text, x5 y4 w550 h24 Center BackgroundTrans, LLARS
Gui Dev: Font, s10 Bold cDCE7F4, Segoe UI
Gui Dev: Add, Text, x5 y28 w550 h18 Center BackgroundTrans, Developer Mode
Gui Dev: Font, s10 Bold cDCE7F4, Segoe UI
Gui Dev: Add, Text, x5 y45 w550 h18 Center BackgroundTrans, %scriptname%

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
	developerElapsedMS := LLARS_NowMS() - LLARS_RunStartTick
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
	developerProgress := LLARS_TimerRemainingText(endTime - LLARS_NowMS())
else
	developerProgress := "--"

LLARS_DeveloperMousePixel(developerMouseX, developerMouseY, developerPixelColor, developerInspectorStatus)
developerPixelTargets := LLARS_DeveloperPixelTargets()

developerStartState := (!LLARS_RUNNING && !LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerInfoState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerConfigState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"

developerInfoName := LLARS_RUNNING ? "Pause" : "Information"
developerConfigName := LLARS_RUNNING ? "Resume" : "Setup"

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

developerActionSnapshot := LLARS_DeveloperActionSnapshot()
developerActions := developerActionSnapshot.Text
developerActionSerial := developerActionSnapshot.Serial
if (developerActions = "")
	developerActions := "No framework actions recorded yet."

developerInputEngine := IsFunc("LLARS_AHI_DeveloperDisplay") ? LLARS_AHI_DeveloperDisplay(LLARS_ROOT) : "Input diagnostics unavailable"
developerDiagnostics := LLARS_DeveloperConfigDiagnostics()

; Compact two-row run summary.
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x20 y71 w70 h18 Right, State:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x94 y71 w96 h18 vDeveloperRunningText, %developerRunning%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x195 y71 w78 h18 Right, Run Type:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x277 y71 w88 h18 vDeveloperRunTypeText, %developerRunType%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x370 y71 w74 h18 Right, Progress:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x448 y71 w92 h18 vDeveloperProgressText, %developerProgress%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x65 y92 w78 h18 Right, Elapsed:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x147 y92 w123 h18 vDeveloperElapsedText, %developerElapsed%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x290 y92 w88 h18 Right, Final Sleep:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x382 y92 w113 h18 vDeveloperFinalSleepText, %developerFinalSleep%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x5 y113 w82 h18 Right, Input Engine:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x91 y113 w464 h18 -Wrap vDeveloperInputEngineText, %developerInputEngine%
Gui Dev: Add, Text, x20 y139 w520 h2 0x10

Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x30 y151 w230 h22 Center BackgroundTrans, Live Inspector
Gui Dev: Add, Text, x300 y151 w230 h22 Center BackgroundTrans, Active Hotkeys
Gui Dev: Font, s10 Norm c24324A, Segoe UI
initialInspectorText := LLARS_DeveloperInspectorSummary(developerInspectorStatus, developerMouseX, developerMouseY, developerPixelColor, developerPixelTargets)
Gui Dev: Add, Edit, x30 y179 w230 h186 ReadOnly -TabStop +VScroll vDeveloperInspectorSummaryText, %initialInspectorText%
Gui Dev: Add, Edit, x300 y179 w230 h186 ReadOnly -TabStop +VScroll vDeveloperHotkeysSummaryText, %developerHotkeys%
LLARS_DeveloperLastInspectorText := initialInspectorText

; Full-width diagnostics keep this section easy to scan.
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x20 y378 w520 h18 Center, Configuration Diagnostics

Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Edit, x30 y402 w500 h73 ReadOnly -TabStop +VScroll +0x4 +0x40 -0x80 vDeveloperDiagnosticsText, %developerDiagnostics%

Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x20 y482 w520 h18 Center, Recent Framework Actions

Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Edit, x30 y505 w500 h151 ReadOnly +VScroll -TabStop hwndDeveloperActionsHwnd vDeveloperActionsText
LLARS_DeveloperConfigureActionControl(DeveloperActionsHwnd)

Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Button, x20 y671 w125 h27 gToggleDeveloperLightweight, Lightweight
Gui Dev: Add, Button, x152 y671 w125 h27 gDeveloperTimingAudit, Timing Audit
Gui Dev: Add, Button, x284 y671 w125 h27 gCopyAHISupportReport, Copy Support
Gui Dev: Add, Button, x416 y671 w124 h27 gCloseDeveloperMode, Close
Gui Dev: +ToolWindow
Gui Dev: -Caption
; Build the full dashboard while the parent is hidden so the hotkey toggle
; never exposes the unfinished Developer Mode shell before its child panes exist.
Gui Dev: Show, Hide w560 h711, Developer Mode
; The inspector and hotkey information is already held in native parent controls.
if LLARS_DeveloperLoadPosition(DeveloperGUIx, DeveloperGUIy)
{
	if (LLARS_RUNNING)
		Gui Dev: Show, NoActivate x%DeveloperGUIx% y%DeveloperGUIy% w560 h711, Developer Mode
	else
		Gui Dev: Show, x%DeveloperGUIx% y%DeveloperGUIy% w560 h711, Developer Mode
}
else
{
	if (LLARS_RUNNING)
		Gui Dev: Show, NoActivate Center w560 h711, Developer Mode
	else
		Gui Dev: Show, Center w560 h711, Developer Mode
}
LLARS_VisualFinish("Dev")

; Populate the console only after the final Show and mark a snapshot current
; only after the read-only Edit control verifies the complete ordered text.
LLARS_DeveloperLastActions := ""
LLARS_DeveloperLastActionSerial := -1
if LLARS_DeveloperRenderActions(DeveloperActionsHwnd, developerActions)
{
	LLARS_DeveloperLastActions := developerActions
	LLARS_DeveloperLastActionSerial := developerActionSerial
}

LLARS_EnableDeveloperHotkey()
LLARS_DeveloperLastHotkeys := developerHotkeys
LLARS_DeveloperLastInputEngine := developerInputEngine
LLARS_DeveloperLastDiagnostics := developerDiagnostics
SetTimer, LLARS_DeveloperAutoRefresh, 250
return

DeveloperModeLightweightDashboard:
Gui Dev: Destroy
DeveloperGuiHwnd := 0
Gui Dev: +AlwaysOnTop +OwnDialogs +LastFound +HwndDeveloperGuiHwnd
LLARS_VisualPrepare("Dev")
LLARS_VisualBanner("Dev", 560, 66)

developerActionSnapshot := LLARS_DeveloperActionSnapshot()
developerActions := developerActionSnapshot.Text
developerActionSerial := developerActionSnapshot.Serial
if (developerActions = "")
	developerActions := "No framework actions recorded yet."
developerLightweightDebug := LLARS_DeveloperLightweightDebugData()
developerLWState := developerLightweightDebug.State
developerLWRunType := developerLightweightDebug.RunType
developerLWProgress := developerLightweightDebug.Progress
developerLWElapsed := developerLightweightDebug.Elapsed
developerLWFinalSleep := developerLightweightDebug.FinalSleep
developerLWEngine := developerLightweightDebug.Engine
developerLWMouseRoute := developerLightweightDebug.MouseRoute
developerLWKeyboardRoute := developerLightweightDebug.KeyboardRoute

Gui Dev: Color, FFFFFF, FFFFFF
Gui Dev: Font, s14 Bold cFFFFFF, Segoe UI
Gui Dev: Add, Text, x5 y4 w550 h25 Center BackgroundTrans, LLARS
Gui Dev: Font, s10 Bold cDCE7F4, Segoe UI
Gui Dev: Add, Text, x5 y29 w550 h18 Center BackgroundTrans, Developer Mode - Lightweight
Gui Dev: Font, s10 Bold cDCE7F4, Segoe UI
Gui Dev: Add, Text, x5 y47 w550 h18 Center BackgroundTrans, %scriptname%

Gui Dev: Font, s10 Bold c24324A, Segoe UI


; Keep Lightweight focused on the status a user needs at a glance.
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x32 y102 w42 h18 Right, State:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x80 y102 w78 h18 -Wrap vDeveloperLWStateText, %developerLWState%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x170 y102 w68 h18 Right, Run Type:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x244 y102 w120 h18 -Wrap vDeveloperLWRunTypeText, %developerLWRunType%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x370 y102 w65 h18 Right, Progress:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x441 y102 w85 h18 -Wrap vDeveloperLWProgressText, %developerLWProgress%

Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x32 y123 w58 h18 Right, Elapsed:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x96 y123 w132 h18 -Wrap vDeveloperLWElapsedText, %developerLWElapsed%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x246 y123 w82 h18 Right, Final Sleep:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x334 y123 w150 h18 -Wrap vDeveloperLWFinalSleepText, %developerLWFinalSleep%

Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x32 y144 w92 h18 Right, Input Engine:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x130 y144 w396 h18 -Wrap vDeveloperLWEngineText, %developerLWEngine%

Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x32 y165 w82 h18 Right, Mouse Route:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x120 y165 w145 h18 -Wrap vDeveloperLWMouseRouteText, %developerLWMouseRoute%
Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Text, x274 y165 w104 h18 Right, Keyboard Route:
Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Text, x384 y165 w142 h18 -Wrap vDeveloperLWKeyboardRouteText, %developerLWKeyboardRoute%

Gui Dev: Font, s10 Bold c24324A, Segoe UI

Gui Dev: Font, s10 Norm c24324A, Segoe UI
Gui Dev: Add, Edit, x30 y220 w500 h216 ReadOnly +VScroll -TabStop hwndDeveloperActionsHwnd vDeveloperActionsText
LLARS_DeveloperConfigureActionControl(DeveloperActionsHwnd)

Gui Dev: Font, s10 Bold c24324A, Segoe UI
Gui Dev: Add, Button, x20 y460 w125 h27 gToggleDeveloperLightweight, Full Mode
Gui Dev: Add, Button, x152 y460 w125 h27 gDeveloperTimingAudit, Timing Audit
Gui Dev: Add, Button, x284 y460 w125 h27 gCopyAHISupportReport, Copy Support
Gui Dev: Add, Button, x416 y460 w124 h27 gCloseDeveloperMode, Close
Gui Dev: +ToolWindow
Gui Dev: -Caption
if LLARS_DeveloperLoadPosition(DeveloperGUIx, DeveloperGUIy)
{
	if (LLARS_RUNNING)
		Gui Dev: Show, NoActivate x%DeveloperGUIx% y%DeveloperGUIy% w560 h498, Developer Mode
	else
		Gui Dev: Show, x%DeveloperGUIx% y%DeveloperGUIy% w560 h498, Developer Mode
}
else
{
	if (LLARS_RUNNING)
		Gui Dev: Show, NoActivate Center w560 h498, Developer Mode
	else
		Gui Dev: Show, Center w560 h498, Developer Mode
}
LLARS_VisualFinish("Dev")

LLARS_DeveloperLastActions := ""
LLARS_DeveloperLastActionSerial := -1
if LLARS_DeveloperRenderActions(DeveloperActionsHwnd, developerActions)
{
	LLARS_DeveloperLastActions := developerActions
	LLARS_DeveloperLastActionSerial := developerActionSerial
}

LLARS_EnableDeveloperHotkey()
LLARS_DeveloperLastLightweightDebug := developerLightweightDebug.Signature
SetTimer, LLARS_DeveloperAutoRefresh, 250
return


CopyAHISupportReport:
if IsFunc("LLARS_AHI_CopySupportReport")
{
	reportPath := LLARS_AHI_CopySupportReport(LLARS_ROOT, "Manual Developer Mode copy")
	if (reportPath != "")
	{
		LLARS_DeveloperAction("Support || Report copied to clipboard")
		MsgBox, 0x40040, LLARS Support Report, A sanitized LLARS support report was copied to your clipboard.`n`nIt includes current run/config/input health plus recent framework actions and AHI diagnostics.`n`nSaved at:`nLogs\LLARS-Support.txt
	}
	else
		MsgBox, 0x40030, LLARS Support Report, LLARS could not create the support report.
}
else
	MsgBox, 0x40030, LLARS Support Report, Support diagnostics are not available in this LLARS build.
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
LLARS_VisualPrepare("Audit")
LLARS_VisualBanner("Audit", 540, 77)
LLARS_VisualCard("Audit", 12, 80, 516, 295)
LLARS_VisualCard("Audit", 12, 378, 516, 43)
Gui Audit: Font, s14 Bold cFFFFFF, Segoe UI
Gui Audit: Add, Text, x5 y5 w530 h26 Center BackgroundTrans, LLARS
Gui Audit: Font, s11 Bold cDCE7F4, Segoe UI
Gui Audit: Add, Text, x5 y30 w530 h19 Center BackgroundTrans, Timing Audit
Gui Audit: Font, s10 Norm cDCE7F4, Segoe UI
Gui Audit: Add, Text, x5 y51 w530 h19 Center BackgroundTrans, Last 500 audit actions. Newest first.
Gui Audit: Font, s10 Norm c24324A, Segoe UI
Gui Audit: Add, Text, x20 y87 w42 h22 +0x200, Filter:
Gui Audit: Add, Edit, x64 y86 w326 h23 gDeveloperTimingAuditFilterChanged vDeveloperTimingAuditFilter
Gui Audit: Font, s9 Bold c24324A, Segoe UI
Gui Audit: Add, Button, x400 y85 w120 h25 gResetDeveloperTimingAuditView, Reset View
Gui Audit: Font, s10 Norm c24324A, Segoe UI
Gui Audit: Add, ListView, x20 y119 w500 h253 Grid -Multi AltSubmit gDeveloperTimingAuditListEvent +HwndDeveloperTimingAuditListHwnd vDeveloperTimingAuditList, Action|Detail|Value
Gui Audit: Default
Gui Audit: ListView, DeveloperTimingAuditList
LV_ModifyCol(1, 105)
LV_ModifyCol(2, 230)
LV_ModifyCol(3, 145)
LLARS_DeveloperPopulateTimingAudit()
Gui Audit: Font, s11 Bold c24324A, Segoe UI
Gui Audit: Add, Button, x115 y385 w145 h28 gToggleDeveloperTimingAuditPause vDeveloperTimingAuditPauseButton, Pause
Gui Audit: Add, Button, x280 y385 w145 h28 gCloseDeveloperTimingAudit, Close
Gui Audit: -Caption
Gui Audit: Show, Center w540 h425, Timing Audit
LLARS_VisualFinish("Audit")
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

	if (auditType = "Move")
	{
		if (partCount >= 2)
			auditValue := Trim(parts[2])
		if (partCount >= 3)
			auditDetail := Trim(parts[3])
		return
	}

	if RegExMatch(auditType, "i)^(Left|Right|Middle|XButton1|XButton2) Click$")
	{
		if (partCount >= 2)
			auditValue := Trim(parts[2])
		if (partCount >= 3)
			auditDetail := Trim(parts[3])
		return
	}

	if (auditType = "Key Press" || auditType = "Key Hold")
	{
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
			auditDetail := Trim(parts[2])
		if (partCount >= 3)
			auditValue := Trim(parts[3])
		return
	}

	if (auditType = "Keyboard Timing")
	{
		auditType := "Key Hold"
		if (partCount >= 2)
			auditDetail := Trim(parts[2])
		if (partCount >= 3)
			auditValue := Trim(parts[3])
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
	developerActionSnapshot := LLARS_DeveloperActionSnapshot()
	developerActions := developerActionSnapshot.Text
	developerActionSerial := developerActionSnapshot.Serial
	if (developerActions = "")
		developerActions := "No framework actions recorded yet."

	developerLightweightDebug := LLARS_DeveloperLightweightDebugData()
	if (developerLightweightDebug.Signature != LLARS_DeveloperLastLightweightDebug)
	{
		developerLWState := developerLightweightDebug.State
		developerLWRunType := developerLightweightDebug.RunType
		developerLWProgress := developerLightweightDebug.Progress
		developerLWElapsed := developerLightweightDebug.Elapsed
		developerLWFinalSleep := developerLightweightDebug.FinalSleep
		developerLWEngine := developerLightweightDebug.Engine
		developerLWMouseRoute := developerLightweightDebug.MouseRoute
		developerLWKeyboardRoute := developerLightweightDebug.KeyboardRoute

		GuiControl, Dev:, DeveloperLWStateText, %developerLWState%
		GuiControl, Dev:, DeveloperLWRunTypeText, %developerLWRunType%
		GuiControl, Dev:, DeveloperLWProgressText, %developerLWProgress%
		GuiControl, Dev:, DeveloperLWElapsedText, %developerLWElapsed%
		GuiControl, Dev:, DeveloperLWFinalSleepText, %developerLWFinalSleep%
		GuiControl, Dev:, DeveloperLWEngineText, %developerLWEngine%
		GuiControl, Dev:, DeveloperLWMouseRouteText, %developerLWMouseRoute%
		GuiControl, Dev:, DeveloperLWKeyboardRouteText, %developerLWKeyboardRoute%
		LLARS_DeveloperLastLightweightDebug := developerLightweightDebug.Signature
	}

	if (developerActionSerial != LLARS_DeveloperLastActionSerial)
	{
		if LLARS_DeveloperRenderActions(DeveloperActionsHwnd, developerActions)
		{
			LLARS_DeveloperLastActions := developerActions
			LLARS_DeveloperLastActionSerial := developerActionSerial
		}
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
	developerElapsedMS := LLARS_NowMS() - LLARS_RunStartTick
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
	developerProgress := LLARS_TimerRemainingText(endTime - LLARS_NowMS())
else
	developerProgress := "--"

LLARS_DeveloperMousePixel(developerMouseX, developerMouseY, developerPixelColor, developerInspectorStatus)
developerPixelTargets := LLARS_DeveloperPixelTargets()

developerStartState := (!LLARS_RUNNING && !LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerInfoState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"
developerConfigState := (!LLARS_CONTROLS_LOCKED) ? "Enabled" : "Disabled"

developerInfoName := LLARS_RUNNING ? "Pause" : "Information"
developerConfigName := LLARS_RUNNING ? "Resume" : "Setup"

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

developerActionSnapshot := LLARS_DeveloperActionSnapshot()
developerActions := developerActionSnapshot.Text
developerActionSerial := developerActionSnapshot.Serial
if (developerActions = "")
	developerActions := "No framework actions recorded yet."

developerInputEngine := IsFunc("LLARS_AHI_DeveloperDisplay") ? LLARS_AHI_DeveloperDisplay(LLARS_ROOT) : "Input diagnostics unavailable"
developerDiagnostics := LLARS_DeveloperConfigDiagnostics()

GuiControl, Dev:, DeveloperRunningText, %developerRunning%
GuiControl, Dev:, DeveloperRunTypeText, %developerRunType%
GuiControl, Dev:, DeveloperProgressText, %developerProgress%
GuiControl, Dev:, DeveloperElapsedText, %developerElapsed%
GuiControl, Dev:, DeveloperFinalSleepText, %developerFinalSleep%

developerInspectorText := LLARS_DeveloperInspectorSummary(developerInspectorStatus, developerMouseX, developerMouseY, developerPixelColor, developerPixelTargets)
if (developerInspectorText != LLARS_DeveloperLastInspectorText)
{
    GuiControl, Dev:, DeveloperInspectorSummaryText, %developerInspectorText%
    LLARS_DeveloperLastInspectorText := developerInspectorText
}
if (developerHotkeys != LLARS_DeveloperLastHotkeys)
{
    GuiControl, Dev:, DeveloperHotkeysSummaryText, %developerHotkeys%
    LLARS_DeveloperLastHotkeys := developerHotkeys
}

if (developerActionSerial != LLARS_DeveloperLastActionSerial)
{
	if LLARS_DeveloperRenderActions(DeveloperActionsHwnd, developerActions)
	{
		LLARS_DeveloperLastActions := developerActions
		LLARS_DeveloperLastActionSerial := developerActionSerial
	}
}

if (developerInputEngine != LLARS_DeveloperLastInputEngine)
{
	GuiControl, Dev:, DeveloperInputEngineText, %developerInputEngine%
	LLARS_DeveloperLastInputEngine := developerInputEngine
}


if (developerDiagnostics != LLARS_DeveloperLastDiagnostics)
{
	GuiControl, Dev:, DeveloperDiagnosticsText, %developerDiagnostics%
	LLARS_DeveloperLastDiagnostics := developerDiagnostics
}
return

; Builds the compact live snapshot used by Lightweight Developer Mode.
; Keep every line intentionally short so the lightweight window remains stable
; across Windows DPI/font metrics.
LLARS_DeveloperLightweightDebugData()
{
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_RUN_TYPE, LLARS_RunStartTick
	global EstFinalSleepActive, count2, runcount3, endTime, LLARS_ROOT

	if (LLARS_RUNNING)
		stateText := LLARS_PAUSED ? "Paused" : "Running"
	else
		stateText := "Idle"

	runTypeText := (LLARS_RUN_TYPE != "") ? LLARS_RUN_TYPE : "Not Started"

	if (LLARS_RUNNING && LLARS_RunStartTick > 0)
	{
		elapsedMS := LLARS_NowMS() - LLARS_RunStartTick
		elapsedHours := Floor(elapsedMS / 3600000)
		elapsedMinutes := Floor(Mod(elapsedMS, 3600000) / 60000)
		elapsedSeconds := Floor(Mod(elapsedMS, 60000) / 1000)
		elapsedText := elapsedHours . "h " . elapsedMinutes . "m " . elapsedSeconds . "s"
	}
	else
		elapsedText := "--"

	if (runTypeText = "RunCount" && runcount3 != "")
		progressText := count2 . " / " . runcount3
	else if (runTypeText = "Timer" && LLARS_RUNNING)
		progressText := LLARS_TimerRemainingText(endTime - LLARS_NowMS())
	else
		progressText := "--"

	finalSleepText := EstFinalSleepActive ? "Active" : "Inactive"

	if IsFunc("LLARS_AHI_DeveloperSnapshot")
	{
		inputStatus := LLARS_AHI_DeveloperSnapshot(LLARS_ROOT)
		engineText := inputStatus.Engine . " || " . inputStatus.Driver
		mouseRoute := inputStatus.MouseRoute
		keyboardRoute := inputStatus.KeyboardRoute
	}
	else
	{
		engineText := "Input diagnostics unavailable"
		mouseRoute := "Unavailable"
		keyboardRoute := "Unavailable"
	}

	signature := stateText
		. "`n" . runTypeText
		. "`n" . progressText
		. "`n" . elapsedText
		. "`n" . finalSleepText
		. "`n" . engineText
		. "`n" . mouseRoute
		. "`n" . keyboardRoute

	return {State:stateText
		, RunType:runTypeText
		, Progress:progressText
		, Elapsed:elapsedText
		, FinalSleep:finalSleepText
		, Engine:engineText
		, MouseRoute:mouseRoute
		, KeyboardRoute:keyboardRoute
		, Signature:signature}
}

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
Gui Dev: Destroy
DeveloperGuiHwnd := 0
Gui 1: Default
Gui 1: Show
return

; Builds Developer Mode pixel-target data from active typed Config.ini color sections.
LLARS_DeveloperPixelTargets()
{
	global LLARS_SCRIPT_DIR, LLARS_DISABLE_SCRIPT_CONFIG

	targets := []
	if (LLARS_DISABLE_SCRIPT_CONFIG)
	{
		targets.Push({Message: "Script Config.ini: Not Required"})
		return targets
	}

	ConfigPath := LLARS_SCRIPT_DIR . "\Config.ini"
	if !FileExist(ConfigPath)
	{
		targets.Push({Message: "Config.ini not found"})
		return targets
	}

	sections := LLARS_ConfigSectionList(ConfigPath)
	if (sections = "ERROR")
	{
		targets.Push({Message: "Unable to read Config.ini"})
		return targets
	}

	pointSections := []
	colorSections := []

	Loop, Parse, sections, `n, `r
	{
		section := LLARS_NormalizeConfigSectionName(A_LoopField)
		if (section = "")
			continue

		if !LLARS_DeveloperConfigSectionActive(ConfigPath, section)
			continue

		configType := GetConfigType(ConfigPath, section)
		if (configType = "coordinate")
		{
			x := LLARS_ConfigReadFile(ConfigPath, section, "x", "ERROR")
			y := LLARS_ConfigReadFile(ConfigPath, section, "y", "ERROR")
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
		targetColor := LLARS_ConfigReadFile(ConfigPath, colorSection, colorKey, "ERROR")
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

; Human-readable, scrollable inspector snapshot. Visible panes are native
; controls on the Developer Mode window, so their labels cannot disappear
; behind independently displayed child GUIs. Values still refresh live.
LLARS_DeveloperInspectorSummary(status, mouseX, mouseY, mouseColor, targets)
{
    output := "Game Status: " . status . "`r`n"
    output .= "Mouse X: " . mouseX . "`r`n"
    output .= "Mouse Y: " . mouseY . "`r`n"
    output .= "Mouse RGB: " . mouseColor . "`r`n"
    output .= "Detection: " . (IsFunc("LLARS_DetectionDisplay") ? LLARS_DetectionDisplay(true) : "None")
    if (!IsObject(targets) || targets.Length() = 0)
        return output . "`r`n`r`nNo configured color targets."
    for _, targetInfo in targets
    {
        if (targetInfo.HasKey("Message"))
            output .= "`r`n`r`n" . targetInfo.Message
        else
        {
            output .= "`r`n`r`n" . targetInfo.Name . ": " . targetInfo.Coordinates
            output .= "`r`nTarget RGB: " . targetInfo.TargetColor
            if (targetInfo.HasFixedPoint)
                output .= "`r`nActual RGB: " . targetInfo.ActualColor
        }
    }
    return output
}

LLARS_DeveloperConfigSectionActive(ConfigPath, section)
{
	option := LLARS_ConfigReadFile(ConfigPath, section, "option", "true")
	option := Trim(option)
	StringLower, optionLower, option
	if (optionLower = "false")
		return false

	depends := LLARS_ConfigReadFile(ConfigPath, section, "depends", "ERROR")
	if (depends != "ERROR" && Trim(depends) != "")
	{
		depends := Trim(depends)
		dependsOption := LLARS_ConfigReadFile(ConfigPath, depends, "option", "true")
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
	mappedCoordinate := LLARS_ConfigReadFile(ConfigPath, colorSection, "coordinate", "ERROR")
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
	sections := LLARS_ConfigSectionList(ConfigPath)
	if (sections = "ERROR")
		return ""

	Loop, Parse, sections, `n, `r
	{
		section := LLARS_NormalizeConfigSectionName(A_LoopField)
		if (section = "")
			continue

		if (GetConfigType(ConfigPath, section) != "hotkey")
			continue

		option := LLARS_ConfigReadFile(ConfigPath, section, "option", "true")
		option := Trim(option)
		StringLower, optionLower, option
		if (optionLower = "false")
			continue

		depends := LLARS_ConfigReadFile(ConfigPath, section, "depends", "ERROR")
		if (depends != "ERROR" && Trim(depends) != "")
		{
			depends := Trim(depends)
			dependsOption := LLARS_ConfigReadFile(ConfigPath, depends, "option", "true")
			dependsOption := Trim(dependsOption)
			StringLower, dependsOptionLower, dependsOption
			if (dependsOptionLower = "false")
				continue
		}

		hotkeyValue := LLARS_ConfigReadFile(ConfigPath, section, "hotkey", "ERROR")
		if (hotkeyValue = "ERROR" || Trim(hotkeyValue) = "")
			hotkeys .= section . ": Not Set`n"
		else
			hotkeys .= section . ": " . LLARS_DeveloperHotkeyDisplay(Trim(hotkeyValue)) . "`n"
	}

	return RTrim(hotkeys, "`n`r")
}

LLARS_DeveloperConfigDiagnostics()
{
	global LLARS_SCRIPT_DIR, LLARS_DISABLE_SCRIPT_CONFIG

	if (LLARS_DISABLE_SCRIPT_CONFIG)
		return "Script Config.ini: Not Required"

	ConfigPath := LLARS_SCRIPT_DIR "\Config.ini"
	if !FileExist(ConfigPath)
		return "Config.ini not found"

	diagnostics := ""
	sections := LLARS_ConfigSectionList(ConfigPath)
	if (sections = "ERROR")
		return "Unable to read Config.ini"

	Loop, Parse, sections, `n, `r
	{
		section := LLARS_NormalizeConfigSectionName(A_LoopField)
		if (section = "")
			continue

		option := LLARS_ConfigReadFile(ConfigPath, section, "option", "true")
		option := Trim(option)
		StringLower, optionLower, option
		if (optionLower = "false")
			continue

		depends := LLARS_ConfigReadFile(ConfigPath, section, "depends", "ERROR")
		if (depends != "ERROR" && Trim(depends) != "")
		{
			depends := Trim(depends)
			dependsOption := LLARS_ConfigReadFile(ConfigPath, depends, "option", "true")
			dependsOption := Trim(dependsOption)
			StringLower, dependsOptionLower, dependsOption
			if (dependsOptionLower = "false")
				continue
		}

		configType := GetConfigType(ConfigPath, section)
		if (configType = "hotkey")
		{
			hotkeyValue := LLARS_ConfigReadFile(ConfigPath, section, "hotkey", "ERROR")
			if (hotkeyValue = "ERROR" || Trim(hotkeyValue) = "")
				diagnostics .= section . ": Hotkey missing`n"
			else if (!LLARS_IsValidConfigHotkey(hotkeyValue))
				diagnostics .= section . ": Hotkey invalid`n"
			continue
		}

		if (configType = "coordinate")
		{
			x := LLARS_ConfigReadFile(ConfigPath, section, "x", "ERROR")
			y := LLARS_ConfigReadFile(ConfigPath, section, "y", "ERROR")
			xmin := LLARS_ConfigReadFile(ConfigPath, section, "xmin", "ERROR")
			xmax := LLARS_ConfigReadFile(ConfigPath, section, "xmax", "ERROR")
			ymin := LLARS_ConfigReadFile(ConfigPath, section, "ymin", "ERROR")
			ymax := LLARS_ConfigReadFile(ConfigPath, section, "ymax", "ERROR")

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
				diagnostics .= section . ": Coordinates missing/invalid`n"
			continue
		}

		if (configType = "color")
		{
			colorKey := LLARS_GetColorKey(ConfigPath, section)
			colorValue := LLARS_ConfigReadFile(ConfigPath, section, colorKey, "ERROR")
			if (colorValue = "ERROR" || !RegExMatch(Trim(colorValue), "i)^0x[0-9A-F]{6}$"))
				diagnostics .= section . ": Color missing/invalid`n"
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
		LLARS_VisualPrepare("Client")
		Gui Client: Font, s13 Bold cEF4444, Segoe UI
		Gui Client: Add, Text, Center w220 x5, ERROR
		Gui Client: Add, Text, center x5 w220,
		Gui Client: Font, s12 Bold c24324A, Segoe UI
		Gui Client: Add, Text, Center w220 x5, RuneScape and Jagex Launcher Both Found.
		Gui Client: Add, Text, center x5 w220,
		Gui Client: Font, s10 Norm c24324A, Segoe UI
		Gui Client: Add, Text, Center w220 x5, Please select below either RuneScape or Jagex to launch the appropriate client for your account.
		Gui Client: Add, Text, center x5 w220,
		Gui Client: Add, Button, gJagex w150 x40 center, Jagex
		Gui Client: Add, Button, gRuneScape w150 x40 center, RuneScape
		Gui Client: +ToolWindow
		Gui Client: -caption
		Gui Client: Show, center w230, Multiple Client
		LLARS_VisualFinish("Client")
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
	LLARS_VisualPrepare("Client")
	Gui Client: Font, s13 Bold cEF4444, Segoe UI
	Gui Client: Add, Text, Center w220 x5, ERROR
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Font, s12 Bold c24324A, Segoe UI
	Gui Client: Add, Text, Center w220 x5, Neither RuneScape Nor Jagex Launcher Were Found.
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Font, s10 Norm c24324A, Segoe UI
	Gui Client: Add, Text, Center w220 x5, No game client was detected in its expected location, please manually launch RuneScape.
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Add, Text, Center w220 x5, Please ensure that RuneScape is open before attempting to start the script again.
	Gui Client: Add, Text, center x5 w220,
	Gui Client: Add, Button, gCloseClient w150 x40 center, Close Error
	Gui Client: +ToolWindow
	Gui Client: -caption
	Gui Client: Show, center w230, No Client Detected
	LLARS_VisualFinish("Client")
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
