; ================================================================
; |     LLARS CORE     -     LLARS CORE                          |
; ================================================================

global LLARS_CONFIG_FILE
global LLARS_DISABLE_SCRIPT_CONFIG

; ================================================================
; |     CORE FUNCTIONS     -     CORE FUNCTIONS                  |
; ================================================================
; Allows LLARS borderless GUI windows to be dragged with the mouse.
WM_LBUTTONDOWN() {
	global LLARS_CHECKPOS_DISABLED

	If (A_Gui)
	{
		if GetKeyState("Ctrl", "P")
			LLARS_CHECKPOS_DISABLED := true
		PostMessage, 0xA1, 2
	}
}

; Restores normal CheckPOS protection after a Ctrl+drag move completes.
WM_EXITSIZEMOVE(wParam := 0, lParam := 0, msg := 0, hwnd := 0) {
	global LLARS_CHECKPOS_DISABLED, LLARSMainGuiHwnd, DeveloperGuiHwnd

	LLARS_CHECKPOS_DISABLED := false
	if (LLARSMainGuiHwnd && hwnd = LLARSMainGuiHwnd)
		LLARS_MainSavePosition(LLARSMainGuiHwnd)
	if (DeveloperGuiHwnd && hwnd = DeveloperGuiHwnd)
		LLARS_DeveloperSavePosition(DeveloperGuiHwnd)
}

; Rechecks interactive LLARS window positions whenever Windows reports a move.
WM_WINDOWPOSCHANGED(wParam, lParam, msg, hwnd) {
	CheckPOS(hwnd)
}

; Keeps every interactive LLARS GUI fully inside the visible desktop area.
CheckPOS(hwnd := "")
{
	global LLARS_CHECKPOS_DISABLED

	if (LLARS_CHECKPOS_DISABLED)
		return

	if (hwnd = "")
		hwnd := WinExist("A")

	if (!hwnd)
		return

	WinGet, processID, PID, ahk_id %hwnd%
	if (processID != DllCall("GetCurrentProcessId"))
		return

	WinGetTitle, guiTitle, ahk_id %hwnd%
	isLLARSMainTitle := (guiTitle = "LLARS" || InStr(guiTitle, "LLARS - v") = 1)
	if (!isLLARSMainTitle)
	{
		if guiTitle not in Combo,Reset Configuration,Coordinates,Colors,Hotkeys,Information,Input Settings,Developer Mode,Multiple Client,No Client Detected,Config Error,Game Not Found,Timer
			return
	}

	WinGetPos, GUIx, GUIy, GUIw, GUIh, ahk_id %hwnd%
	if (GUIw = "" || GUIh = "")
		return

	; Clamp against the work area of the monitor nearest this window instead of the primary monitor.
	hMonitor := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
	if (hMonitor)
	{
		VarSetCapacity(monitorInfo, 40, 0)
		NumPut(40, monitorInfo, 0, "UInt")
		if DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", &monitorInfo)
		{
			workLeft := NumGet(monitorInfo, 20, "Int")
			workTop := NumGet(monitorInfo, 24, "Int")
			workRight := NumGet(monitorInfo, 28, "Int")
			workBottom := NumGet(monitorInfo, 32, "Int")
		}
	}

	if (workRight = "" || workBottom = "")
	{
		workLeft := 0
		workTop := 0
		workRight := A_ScreenWidth
		workBottom := A_ScreenHeight
	}

	X := GUIx
	Y := GUIy
	maxX := workRight - GUIw
	maxY := workBottom - GUIh
	if (maxX < workLeft)
		maxX := workLeft
	if (maxY < workTop)
		maxY := workTop

	if (X < workLeft)
		X := workLeft
	if (Y < workTop)
		Y := workTop
	if (X > maxX)
		X := maxX
	if (Y > maxY)
		Y := maxY

	if (X != GUIx || Y != GUIy)
		WinMove, ahk_id %hwnd%,, X, Y
}

; Reads the current main LLARS GUI position by HWND only.
LLARS_MainGetPosition(ByRef x, ByRef y, hwnd := 0)
{
	global LLARSMainGuiHwnd

	if (!hwnd)
		hwnd := LLARSMainGuiHwnd
	if (!hwnd || !WinExist("ahk_id " . hwnd))
		return false

	WinGetPos, x, y,,, ahk_id %hwnd%
	if !LLARS_IsNumericConfigValue(x) || !LLARS_IsNumericConfigValue(y)
		return false

	x := Round(x + 0)
	y := Round(y + 0)
	return true
}

; Reads a valid saved main LLARS GUI top-left position.
LLARS_MainLoadPosition(ByRef x, ByRef y)
{
	global LLARS_CONFIG_FILE

	IniRead, x, %LLARS_CONFIG_FILE%, GUI POS, guix, ERROR
	IniRead, y, %LLARS_CONFIG_FILE%, GUI POS, guiy, ERROR
	x := Trim(x)
	y := Trim(y)
	if (x = "ERROR" || y = "ERROR" || !LLARS_IsNumericConfigValue(x) || !LLARS_IsNumericConfigValue(y))
	{
		x := ""
		y := ""
		return false
	}

	x := Round(x + 0)
	y := Round(y + 0)
	return true
}

; Saves the main LLARS GUI position only when its actual HWND still exists and Windows returned valid coordinates.
LLARS_MainSavePosition(hwnd := 0)
{
	global LLARS_CONFIG_FILE, LLARSMainGuiHwnd

	if (!hwnd)
		hwnd := LLARSMainGuiHwnd
	if !LLARS_MainGetPosition(x, y, hwnd)
		return false

	IniWrite, %x%, %LLARS_CONFIG_FILE%, GUI POS, guix
	IniWrite, %y%, %LLARS_CONFIG_FILE%, GUI POS, guiy
	return true
}

; Reads a valid saved Developer Mode top-left position.
LLARS_DeveloperLoadPosition(ByRef x, ByRef y)
{
	global LLARS_CONFIG_FILE

	IniRead, x, %LLARS_CONFIG_FILE%, Developer Mode GUI POS, guix, ERROR
	IniRead, y, %LLARS_CONFIG_FILE%, Developer Mode GUI POS, guiy, ERROR
	x := Trim(x)
	y := Trim(y)
	if (x = "ERROR" || y = "ERROR")
		return false
	if !LLARS_IsNumericConfigValue(x) || !LLARS_IsNumericConfigValue(y)
		return false
	x := Round(x + 0)
	y := Round(y + 0)
	return true
}

; Saves Developer Mode by HWND only when Windows returned real coordinates.
LLARS_DeveloperSavePosition(hwnd := 0)
{
	global LLARS_CONFIG_FILE, DeveloperGuiHwnd

	if (!hwnd)
		hwnd := DeveloperGuiHwnd
	if (!hwnd || !WinExist("ahk_id " . hwnd))
		return false

	WinGetPos, x, y,,, ahk_id %hwnd%
	if !LLARS_IsNumericConfigValue(x) || !LLARS_IsNumericConfigValue(y)
		return false

	IniWrite, %x%, %LLARS_CONFIG_FILE%, Developer Mode GUI POS, guix
	IniWrite, %y%, %LLARS_CONFIG_FILE%, Developer Mode GUI POS, guiy
	return true
}

; Waits for the primary key of a configured hotkey to be released.
LLARS_WaitForHotkeyRelease(hotkey)
{
	hotkey := Trim(hotkey)
	if (hotkey = "")
		return

	keyName := RegExReplace(hotkey, "^[\$\*\~<>\^!+#]+")
	if (keyName = "" || InStr(keyName, " & "))
		return

	KeyWait, %keyName%
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
			WinClose, % "ahk_id " hWnd
		}
	}

	Loop, %hWndList2%
	{
		hWnd := hWndList2%A_Index%
		WinGet, processName, ProcessName, ahk_id %hWnd%
		if (processName = "AutoHotkey.exe" || processName = "AutoHotkeyU64.exe" || processName = "AutoHotkeyU32.exe")
		{
			WinClose, % "ahk_id " hWnd
		}
	}
}

; Forces normal LLARS keyboard hotkeys to use AutoHotkey's keyboard hook
; instead of Windows RegisterHotKey.
LLARS_HookHotkey(hotkey)
{
	hotkey := Trim(hotkey)
	if (hotkey = "")
		return ""
	if (SubStr(hotkey, 1, 1) = "$")
		return hotkey
	return "$" . hotkey
}

; Developer Mode remains available even if Ctrl/Alt/Shift/Win happens to be held.
LLARS_AlwaysHotkey(hotkey)
{
	hotkey := Trim(hotkey)
	if (hotkey = "")
		return ""
	hotkey := RegExReplace(hotkey, "^[\$\*]+")
	return "$*" . hotkey
}

; Reads the shared LLARS hotkeys and safely enables, disables, or remaps them.
SetLLARSHOTKEYS(state := "On", startOnly := false)
{
	global LLARS_lhk1
	global LLARS_lhk2
	global LLARS_lhk3
	global LLARS_lhk4
	global LLARS_RUNNING
	global LLARS_CONTROLS_LOCKED

	IniRead, lhk1, %LLARS_CONFIG_FILE%, Start Hotkey, hotkey
	if (lhk1 = "ERROR")
		lhk1 := ""
	lhk1 := Trim(lhk1)

	oldlhk1 := LLARS_HookHotkey(LLARS_lhk1)
	newlhk1 := LLARS_HookHotkey(lhk1)

	; Disable the previously configured Start hotkey if it changed.
	if (oldlhk1 != "" && LLARS_lhk1 != lhk1)
		Hotkey, %oldlhk1%, Start, Off

	; Save the current Start hotkey.
	LLARS_lhk1 := lhk1

	; Enable/disable the current Start hotkey.
	if (newlhk1 != "")
	{
		if (state = "On" && !LLARS_RUNNING && !LLARS_CONTROLS_LOCKED)
			Hotkey, %newlhk1%, Start, On
		else
			Hotkey, %newlhk1%, Start, Off
	}

	; Only update the Start hotkey when requested.
	if (startOnly)
		return true

	IniRead, lhk2, %LLARS_CONFIG_FILE%, Information Hotkey, hotkey
	IniRead, lhk3, %LLARS_CONFIG_FILE%, color/coordinate/hotkey Hotkey, hotkey
	IniRead, lhk4, %LLARS_CONFIG_FILE%, Exit Hotkey, hotkey
	if (lhk2 = "ERROR")
		lhk2 := ""
	if (lhk3 = "ERROR")
		lhk3 := ""
	if (lhk4 = "ERROR")
		lhk4 := ""
	lhk2 := Trim(lhk2)
	lhk3 := Trim(lhk3)
	lhk4 := Trim(lhk4)

	oldlhk2 := LLARS_HookHotkey(LLARS_lhk2)
	newlhk2 := LLARS_HookHotkey(lhk2)
	oldlhk3 := LLARS_HookHotkey(LLARS_lhk3)
	newlhk3 := LLARS_HookHotkey(lhk3)
	oldlhk4 := LLARS_HookHotkey(LLARS_lhk4)
	newlhk4 := LLARS_HookHotkey(lhk4)

	; Disable the previously configured Information/Pause hotkey if it changed.
	if (oldlhk2 != "" && LLARS_lhk2 != lhk2)
	{
		Hotkey, %oldlhk2%, Info, Off
		Hotkey, %oldlhk2%, pauseb, Off
	}

	; Save the current Information/Pause hotkey.
	LLARS_lhk2 := lhk2
	if (newlhk2 != "")
	{
		if (state = "On" && !LLARS_CONTROLS_LOCKED)
		{
			if (LLARS_RUNNING)
			{
				Hotkey, %newlhk2%, Info, Off
				Hotkey, %newlhk2%, pauseb, On
			}
			else
			{
				Hotkey, %newlhk2%, pauseb, Off
				Hotkey, %newlhk2%, Info, On
			}
		}
		else
		{
			Hotkey, %newlhk2%, Info, Off
			Hotkey, %newlhk2%, pauseb, Off
		}
	}

	; Disable the previously configured Combo/Resume hotkey if it changed.
	if (oldlhk3 != "" && LLARS_lhk3 != lhk3)
	{
		Hotkey, %oldlhk3%, Combo, Off
		Hotkey, %oldlhk3%, resumeb, Off
	}

	; Save the current Combo/Resume hotkey.
	LLARS_lhk3 := lhk3
	if (newlhk3 != "")
	{
		if (state = "On" && !LLARS_CONTROLS_LOCKED)
		{
			if (LLARS_RUNNING)
			{
				Hotkey, %newlhk3%, Combo, Off
				Hotkey, %newlhk3%, resumeb, On
			}
			else
			{
				Hotkey, %newlhk3%, resumeb, Off
				Hotkey, %newlhk3%, Combo, On
			}
		}
		else
		{
			Hotkey, %newlhk3%, Combo, Off
			Hotkey, %newlhk3%, resumeb, Off
		}
	}

	; Exit uses the same normal dynamic-hotkey path as Pause/Resume and stays enabled.
	if (lhk4 = "" || !LLARS_IsValidConfigHotkey(lhk4))
		return false

	if (oldlhk4 != "" && LLARS_lhk4 != lhk4)
		Hotkey, %oldlhk4%, ExitB, Off

	LLARS_lhk4 := lhk4
	Hotkey, %newlhk4%, ExitB, On

	return true
}

; Keeps Developer Mode available independently of normal LLARS hotkey state.
LLARS_EnableDeveloperHotkey(lhk5 := "")
{
	global LLARS_lhk5

	if (lhk5 = "")
		IniRead, lhk5, %LLARS_CONFIG_FILE%, Developer Mode, hotkey

	if (lhk5 = "ERROR")
		lhk5 := ""
	lhk5 := Trim(lhk5)

	; A temporary missing/blank config read never disables the last known Developer Mode hotkey.
	if (lhk5 = "")
		return

	; If the configured Developer Mode key is unchanged, explicitly make sure its hook is still enabled after any GUI/control/hotkey state transition.
	if (LLARS_lhk5 = lhk5)
	{
		newlhk5 := LLARS_AlwaysHotkey(lhk5)
		Hotkey, %newlhk5%, DeveloperModeHotkey, On
		return
	}

	oldlhk5 := LLARS_AlwaysHotkey(LLARS_lhk5)
	newlhk5 := LLARS_AlwaysHotkey(lhk5)

	if (oldlhk5 != "")
		Hotkey, %oldlhk5%, DeveloperModeHotkey, Off

	LLARS_lhk5 := lhk5
	Hotkey, %newlhk5%, DeveloperModeHotkey, On
}

; Applies shared hotkey config changes without cycling unchanged bindings.
LLARS_CheckHotkeyConfig()
{
	global LLARS_lhk1, LLARS_lhk2, LLARS_lhk3, LLARS_lhk4, LLARS_lhk5

	IniRead, lhk1, %LLARS_CONFIG_FILE%, Start Hotkey, hotkey
	IniRead, lhk2, %LLARS_CONFIG_FILE%, Information Hotkey, hotkey
	IniRead, lhk3, %LLARS_CONFIG_FILE%, color/coordinate/hotkey Hotkey, hotkey
	IniRead, lhk4, %LLARS_CONFIG_FILE%, exit Hotkey, hotkey
	IniRead, lhk5, %LLARS_CONFIG_FILE%, Developer Mode, hotkey

	if (lhk1 = "ERROR" || lhk2 = "ERROR" || lhk3 = "ERROR" || lhk4 = "ERROR")
		return

	if (lhk5 = "ERROR")
		lhk5 := ""

	lhk1 := Trim(lhk1)
	lhk2 := Trim(lhk2)
	lhk3 := Trim(lhk3)
	lhk4 := Trim(lhk4)
	lhk5 := Trim(lhk5)

	if (lhk1 != LLARS_lhk1 || lhk2 != LLARS_lhk2 || lhk3 != LLARS_lhk3 || lhk4 != LLARS_lhk4)
		SetLLARSHOTKEYS("On")

	LLARS_EnableDeveloperHotkey(lhk5)
}

; Normalizes an individual section name supplied by config enumeration or callers.
LLARS_NormalizeConfigSectionName(section)
{
	section := Trim(section)
	section := StrReplace(section, Chr(0xFEFF))
	section := StrReplace(section, "[")
	section := StrReplace(section, "]")
	return Trim(section)
}

; Filters disabled sections for status/diagnostics; validation stays in CheckConfigFile().
LLARS_ConfigSectionEnabled(ConfigPath, section)
{
	section := LLARS_NormalizeConfigSectionName(section)
	IniRead, option, %ConfigPath%, %section%, option, true
	option := Trim(option)
	StringLower, optionLower, option
	if (optionLower = "false")
		return false

	IniRead, depends, %ConfigPath%, %section%, depends, ERROR
	if (depends = "ERROR" || Trim(depends) = "")
		return true

	depends := Trim(depends)
	IniRead, dependsOption, %ConfigPath%, %depends%, option, true
	dependsOption := Trim(dependsOption)
	StringLower, dependsOptionLower, dependsOption
	return (dependsOptionLower != "false")
}

; Summarizes required script configuration for the main LLARS status display.
LLARS_UpdateConfigStatus()
{
	global LLARS_SCRIPT_DIR, LLARS_DISABLE_SCRIPT_CONFIG
	global LLARS_CONFIG_READY, LLARS_CONFIG_MISSING_COUNT, LLARS_CONFIG_REQUIRED_COUNT

	LLARS_CONFIG_READY := false
	LLARS_CONFIG_MISSING_COUNT := 0
	LLARS_CONFIG_REQUIRED_COUNT := 0

	if (LLARS_DISABLE_SCRIPT_CONFIG)
	{
		LLARS_SetConfigStatusText("ConfigStatusHotkeys", "ConfigStatusHotkeysLabel", 0, 0)
		LLARS_SetConfigStatusText("ConfigStatusCoordinates", "ConfigStatusCoordinatesLabel", 0, 0)
		LLARS_SetConfigStatusText("ConfigStatusColors", "ConfigStatusColorsLabel", 0, 0)
		LLARS_CONFIG_READY := true
		return true
	}

	ConfigPath := LLARS_SCRIPT_DIR "\Config.ini"
	if !FileExist(ConfigPath)
		return false

	hotkeyRequired := 0
	hotkeyMissing := 0
	coordinateRequired := 0
	coordinateMissing := 0
	colorRequired := 0
	colorMissing := 0

	sections := LLARS_ConfigSectionList(ConfigPath)
	if (sections = "ERROR")
		return

	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		if !LLARS_ConfigSectionEnabled(ConfigPath, section)
			continue

		configType := GetConfigType(ConfigPath, section)
		if (configType = "hotkey")
		{
			hotkeyRequired++
			IniRead, hotkeyValue, %ConfigPath%, %section%, hotkey, ERROR
			if (hotkeyValue = "ERROR" || Trim(hotkeyValue) = "" || !LLARS_IsValidConfigHotkey(hotkeyValue))
				hotkeyMissing++
			continue
		}

		if (configType = "coordinate")
		{
			coordinateRequired++
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
				coordinateMissing++
			continue
		}

		if (configType = "color")
		{
			colorRequired++
			colorKey := LLARS_GetColorKey(ConfigPath, section)
			IniRead, colorValue, %ConfigPath%, %section%, %colorKey%, ERROR
			if (colorValue = "ERROR" || !RegExMatch(Trim(colorValue), "i)^0x[0-9A-F]{6}$"))
				colorMissing++
		}
	}

	LLARS_CONFIG_REQUIRED_COUNT := hotkeyRequired + coordinateRequired + colorRequired
	LLARS_CONFIG_MISSING_COUNT := hotkeyMissing + coordinateMissing + colorMissing
	LLARS_CONFIG_READY := (LLARS_CONFIG_MISSING_COUNT = 0)

	LLARS_SetConfigStatusText("ConfigStatusHotkeys", "ConfigStatusHotkeysLabel", hotkeyRequired, hotkeyMissing)
	LLARS_SetConfigStatusText("ConfigStatusCoordinates", "ConfigStatusCoordinatesLabel", coordinateRequired, coordinateMissing)
	LLARS_SetConfigStatusText("ConfigStatusColors", "ConfigStatusColorsLabel", colorRequired, colorMissing)
	return LLARS_CONFIG_READY
}

 ; Formats one main-GUI configuration status category.
LLARS_SetConfigStatusText(controlName, labelName, requiredCount, missingCount)
{
	if (requiredCount = 0)
	{
		statusText := "Not Required"
		statusColor := "Black"
	}
	else if (missingCount > 0)
	{
		statusText := "Missing"
		statusColor := "Red"
	}
	else
	{
		statusText := "Ready"
		statusColor := "Green"
	}

	Gui, 1: Font, s10 Bold cBlack
	GuiControl, 1: Font, %labelName%
	Gui, 1: Font, s10 Bold c%statusColor%
	GuiControl, 1: Font, %controlName%
	GuiControl, 1:, %controlName%, %statusText%
}

; Locks normal LLARS controls while a configuration/editor flow is active.
DisableHotkey()
{
	global LLARS_CONTROLS_LOCKED

	LLARS_CONTROLS_LOCKED := true
	Control, Disable,, Button1, LLARS ahk_class AutoHotkeyGUI
	Control, Disable,, Button2, LLARS ahk_class AutoHotkeyGUI
	Control, Disable,, Button3, LLARS ahk_class AutoHotkeyGUI
	SetLLARSHOTKEYS("Off")
	LLARS_EnableDeveloperHotkey()
}

; Re-enables the normal LLARS controls and hotkeys after an editor closes.
EnableHotkey()
{
	global LLARS_CONTROLS_LOCKED

	LLARS_CONTROLS_LOCKED := false
	Control, Enable,, Button1, LLARS ahk_class AutoHotkeyGUI
	Control, Enable,, Button2, LLARS ahk_class AutoHotkeyGUI
	Control, Enable,, Button3, LLARS ahk_class AutoHotkeyGUI
	SetLLARSHOTKEYS("On")
	LLARS_EnableDeveloperHotkey()
}

; Disables only the Start control while the timed script is running.
DisableButton()
{
	Control, Disable,, Button1, LLARS ahk_class AutoHotkeyGUI
	SetLLARSHOTKEYS("Off", true)
	LLARS_EnableDeveloperHotkey()
}

; Re-enables the Start control after the timed run is finished.
EnableButton()
{
	Control, Enable,, Button1, LLARS ahk_class AutoHotkeyGUI
	SetLLARSHOTKEYS("On", true)
	LLARS_EnableDeveloperHotkey()
}

; Walks upward from the script folder until the LLARS project root is found.
LLARS_FindRoot()
{
	CurrentDir := A_ScriptDir
	Loop
	{
		if (FileExist(CurrentDir "\Core\LLARS.ahk"))
			return CurrentDir

		SplitPath, CurrentDir, , ParentDir
		if (ParentDir = "" || ParentDir = CurrentDir)
			break
		CurrentDir := ParentDir
	}

	return ""
}

; Performs shared startup: locates LLARS, loads settings, checks files,
; prepares hotkeys and creates the main GUI.
LLARS_Initialize()
{
	global LLARS_ROOT, LLARS_SCRIPT_DIR, LLARS_CONFIG_FILE
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_lhk1, LLARS_lhk2, LLARS_lhk3, LLARS_lhk4, LLARS_lhk5, LLARS_CONTROLS_LOCKED, LLARS_CHECKPOS_DISABLED
	global LLARS_DeveloperActions, LLARS_DeveloperActionSerial, LLARS_DeveloperAuditActions, LLARS_DeveloperLastHotkey, LLARS_RunStartTick, LLARS_RUN_TYPE
	global LLARS_DeveloperLastSleepValue, LLARS_DeveloperLastSleepName
	global LLARS_DeveloperKeyboardHook, LLARS_DeveloperKeyboardCallback, LLARS_DeveloperMessageHwnd
	global LLARS_DeveloperHotkeyMap, LLARS_DeveloperKeyStates, LLARS_DeveloperControlKeyStates
	global LLARS_RunRuneScapeHwnd
	global LLARS_DeveloperLightweight, LLARS_DeveloperLastInputEngine, LLARS_DeveloperLastLightweightDebug
	global LLARS_DiagnosticWarnings, LLARS_DiagnosticErrors, LLARS_DiagnosticRecoveries, LLARS_LastDiagnostic
global LLARS_DetectionName, LLARS_DetectionState, LLARS_DetectionConfidence, LLARS_DetectionThreshold, LLARS_DetectionDetail, LLARS_DetectionTick, LLARS_DetectionSignature
	global LLARS_AHI_GateStartTick, LLARS_AHI_GateReady, LLARS_AHI_GateElapsed
	global LLARS_AHI_InitStartTick, LLARS_AHI_InitElapsed, LLARS_AHI_FullyReady
	global EstimationRunCount
	global coordcount, frcount, LastClickTime, clickspot, scriptname, LLARS_GUIScriptName

	CoordMode, Pixel, Client
	CoordMode, Mouse, Client
	LLARS_SCRIPT_DIR := A_ScriptDir
	LLARS_ROOT := LLARS_FindRoot()
	LLARS_CONFIG_FILE := LLARS_ROOT "\LLARS Config.ini"
	if (LLARS_ROOT = "")
	{
		MsgBox, 48, LLARS Error, Unable to locate the LLARS Core folder.`n`nThe script must be located somewhere inside the LLARS Scripts folder.
		return false
	}

	SetWorkingDir, %LLARS_SCRIPT_DIR%
	CloseOtherLLARS()
	if (!LLARS_CheckStartupFiles())
		return false
	if (!LLARS_CheckConfigCompatibility(LLARS_ROOT))
		return false

	; Complete the bounded GitHub release check before input-backend checks or the script GUI.
	; Scripts launched by the selector inherit its completed-check marker and skip it.
	LLARS_CheckForUpdates()

	; Supports both normal Script Selector launches and scripts opened directly.
	; AHI is the recommended input backend; Standard AutoHotkey remains the
	; fallback when AHI is declined or unavailable.
	LLARS_AHI_GateStartTick := A_TickCount
	LLARS_AHI_GateReady := LLARS_AHI_StartupGate(LLARS_ROOT, true)
	LLARS_AHI_GateElapsed := A_TickCount - LLARS_AHI_GateStartTick
	LLARS_lhk1 := ""
	LLARS_lhk2 := ""
	LLARS_lhk3 := ""
	LLARS_lhk4 := ""
	LLARS_lhk5 := ""
	LLARS_CONTROLS_LOCKED := false
	LLARS_RUNNING := false
	LLARS_PAUSED := false
	LLARS_RunRuneScapeHwnd := 0
	LLARS_CHECKPOS_DISABLED := false
	LLARS_DeveloperActions := ""
	LLARS_DeveloperActionSerial := 0
	LLARS_DeveloperAuditActions := []
	LLARS_DeveloperLastHotkey := "None"
	LLARS_DeveloperLastSleepValue := ""
	LLARS_DeveloperLastSleepName := ""
	LLARS_DeveloperKeyboardHook := 0
	LLARS_DeveloperKeyboardCallback := 0
	LLARS_DeveloperMessageHwnd := A_ScriptHwnd
	LLARS_DeveloperHotkeyMap := {}
	LLARS_DeveloperKeyStates := {}
	LLARS_DeveloperControlKeyStates := {}
	LLARS_DeveloperLightweight := false
	LLARS_DeveloperLastInputEngine := ""
	LLARS_DeveloperLastLightweightDebug := ""
	LLARS_DiagnosticWarnings := 0
	LLARS_DiagnosticErrors := 0
	LLARS_DiagnosticRecoveries := 0
	LLARS_LastDiagnostic := "None"
	LLARS_DetectionName := "None"
	LLARS_DetectionState := "Idle"
	LLARS_DetectionConfidence := ""
	LLARS_DetectionThreshold := ""
	LLARS_DetectionDetail := ""
	LLARS_DetectionTick := 0
	LLARS_DetectionSignature := ""
	LLARS_RunStartTick := 0
	LLARS_RUN_TYPE := "Not Started"

	if !SetLLARSHOTKEYS("On")
	{
		MsgBox, 16, LLARS Exit Hotkey Error, The configured Exit hotkey is invalid.`n`nLLARS will close instead of running without a working Exit key.
		ExitApp
	}
	LLARS_DeveloperInitializeKeyboardHook()
	LLARS_EnableDeveloperHotkey()
	SetTimer, LLARS_AlwaysOnHotkeyWatchdog, 250
	DetectHiddenWindows, On

	coordcount = 0
	frcount = 0
	LastClickTime := 0
	clickspot := 1
	SetTimer, CheckLLARSConfig, 1000
	scriptname := regexreplace(A_scriptname,"\..*","")
	LLARS_GUIScriptName := RegExReplace(scriptname, "i)\s+Script Template$")
	if (LLARS_GUIScriptName = "")
		LLARS_GUIScriptName := scriptname
	EstimationRunCount := 1000
	LLARS_CreateMainGUI()

	; The LLARS window is visible before CLR/AHI device initialization begins.
	; LLARS_Initialize() still does not return until AHI is ready (or has safely
	; fallen back), so automation cannot start against an uninitialized backend.
	LLARS_AHI_InitStartTick := A_TickCount
	LLARS_AHI_Initialize(LLARS_ROOT)
	LLARS_AHI_InitElapsed := A_TickCount - LLARS_AHI_InitStartTick
	LLARS_AHI_FullyReady := (LLARS_AHI_IsReady("mouse") && LLARS_AHI_IsReady("keyboard"))
	; StartupGate already owns first-run/install/restart messaging. Only show an
	; additional runtime warning when the gate was healthy but AHI initialization
	; still failed or only one physical input route was available.
	if (LLARS_AHI_GateReady && !LLARS_AHI_FullyReady && !LLARS_AHI_PendingRestart(LLARS_ROOT))
		LLARS_AHI_ShowRuntimeProblem(LLARS_ROOT)
	LLARS_AHI_LogDeveloperStatus(LLARS_ROOT)
	LLARS_DeveloperAction("AHI Startup || Gate=" . LLARS_AHI_GateElapsed . " ms || Initialize=" . LLARS_AHI_InitElapsed . " ms")

	OnMessage(0x0047, "WM_WINDOWPOSCHANGED")
	OnMessage(0x8001, "LLARS_DeveloperKeyboardMessage")
	OnMessage(0x0201, "WM_LBUTTONDOWN")
	OnMessage(0x0232, "WM_EXITSIZEMOVE")
	LLARS_DeveloperRefreshHotkeyMap(true)
	return true
}

; Returns the compact GUI name without a trailing "Script Template" suffix.
LLARS_DisplayScriptName()
{
	global LLARS_GUIScriptName, scriptname

	if (LLARS_GUIScriptName != "")
		return LLARS_GUIScriptName
	return scriptname
}

; Installs the low-level keyboard hook used by Developer timing.
LLARS_DeveloperInitializeKeyboardHook()
{
	global LLARS_DeveloperKeyboardHook, LLARS_DeveloperKeyboardCallback

	if (LLARS_DeveloperKeyboardHook)
		return true

	LLARS_DeveloperKeyboardCallback := RegisterCallback("LLARS_DeveloperKeyboardProc", "Fast")
	if (!LLARS_DeveloperKeyboardCallback)
		return false

	LLARS_DeveloperKeyboardHook := DllCall("SetWindowsHookEx"
		, "Int", 13
		, "Ptr", LLARS_DeveloperKeyboardCallback
		, "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
		, "UInt", 0
		, "Ptr")
	return (LLARS_DeveloperKeyboardHook != 0)
}

LLARS_DeveloperKeyboardProc(nCode, wParam, lParam)
{
	global LLARS_DeveloperMessageHwnd

	if (nCode >= 0 && lParam)
	{
		vkCode := NumGet(lParam + 0, 0, "UInt")
		flags := NumGet(lParam + 0, 8, "UInt")
		extraInfo := NumGet(lParam + 0, 16, "UPtr")

		; Developer timing remains diagnostic only.
		if (LLARS_DeveloperMessageHwnd && (flags & 0x10))
		{
			if (extraInfo = 0xFFC3D44F || extraInfo = 0xFFC3D44E || extraInfo = 0xFFC3D44D)
			{
				if (wParam = 0x0100 || wParam = 0x0101 || wParam = 0x0104 || wParam = 0x0105)
				{
					keyUp := (wParam = 0x0101 || wParam = 0x0105) ? 1 : 0
					eventTick := NumGet(lParam + 0, 12, "UInt")
					messageKey := vkCode + (keyUp ? 0x10000 : 0)
					DllCall("PostMessage"
						, "Ptr", LLARS_DeveloperMessageHwnd
						, "UInt", 0x8001
						, "Ptr", messageKey
						, "Ptr", eventTick)
				}
			}
		}
	}

	return DllCall("CallNextHookEx"
		, "Ptr", 0
		, "Int", nCode
		, "Ptr", wParam
		, "Ptr", lParam
		, "Ptr")
}

; Moves keyboard diagnostics out of the low-level hook callback and back onto
; the normal LLARS thread before any config lookup or Developer Mode updates.
LLARS_DeveloperKeyboardMessage(wParam, lParam, msg, hwnd)
{
	vkCode := Mod(wParam + 0, 0x10000)
	keyUp := ((wParam + 0) >= 0x10000) ? true : false
	eventTick := lParam + 0
	if (eventTick < 0)
		eventTick += 4294967296
	LLARS_DeveloperScriptKey(vkCode, keyUp, eventTick)
	return 0
}

; Refreshes the script hotkey lookup used by Developer diagnostics.
LLARS_DeveloperRefreshHotkeyMap(force := false)
{
	global LLARS_SCRIPT_DIR, LLARS_DeveloperHotkeyMap
	static lastRefreshTick := 0

	if (!force && lastRefreshTick && (A_TickCount - lastRefreshTick) < 1000)
		return

	lastRefreshTick := A_TickCount
	LLARS_DeveloperHotkeyMap := {}
	ConfigPath := LLARS_SCRIPT_DIR . "\Config.ini"
	if !FileExist(ConfigPath)
		return

	sections := LLARS_ConfigSectionList(ConfigPath)
	if (sections = "ERROR")
		return

	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		if !LLARS_ConfigSectionEnabled(ConfigPath, section)
			continue

		IniRead, sectionData, %ConfigPath%, %section%
		if (sectionData = "ERROR")
			continue

		Loop, Parse, sectionData, `n, `r
		{
			configLine := Trim(A_LoopField)
			separatorPos := InStr(configLine, "=")
			if (!separatorPos)
				continue

			keyName := Trim(SubStr(configLine, 1, separatorPos - 1))
			configuredHotkey := Trim(SubStr(configLine, separatorPos + 1))
			keyNameLower := keyName
			StringLower, keyNameLower, keyNameLower
			if (!InStr(keyNameLower, "hotkey") || configuredHotkey = "" || configuredHotkey = "ERROR")
				continue

			compareKey := RegExReplace(configuredHotkey, "^[\$\*\~<>\^!+#]+")
			if (compareKey = "")
				continue

			configuredVK := GetKeyVK(compareKey)
			if (!configuredVK)
				continue

			displaySection := section
			if (keyNameLower != "hotkey")
				displaySection .= " / " . keyName

			if !LLARS_DeveloperHotkeyMap.HasKey(configuredVK)
				LLARS_DeveloperHotkeyMap[configuredVK] := {Section: displaySection, Hotkey: configuredHotkey}
		}
	}
}

; Records script-generated key transitions and suppresses duplicate key-downs.
LLARS_DeveloperScriptKey(vkCode, keyUp := false, eventTick := "")
{
	global LLARS_RUNNING, LLARS_DeveloperHotkeyMap, LLARS_DeveloperKeyStates, LLARS_DeveloperKeyboardHook

	; Hook timestamps measure actual down/up transitions; direct calls are fallback only.
	if (eventTick = "")
	{
		if (LLARS_DeveloperKeyboardHook)
			return
		eventTick := A_TickCount
	}

	keyName := GetKeyName("vk" . Format("{:02X}", vkCode))
	if (keyName = "")
		keyName := "VK" . Format("{:02X}", vkCode)

	; Keep modifier transitions too.

	if (keyUp)
	{
		if !LLARS_DeveloperKeyStates.HasKey(vkCode)
			return

		keyInfo := LLARS_DeveloperKeyStates[vkCode]
		LLARS_DeveloperKeyStates.Delete(vkCode)
		keyHoldElapsed := eventTick - keyInfo.DownTick
		if (keyHoldElapsed < 0)
			keyHoldElapsed += 4294967296

		if (keyInfo.Type = "Hotkey")
		{
			LLARS_DeveloperAction("KeyPress || Hotkey " . keyInfo.Section . " || " . keyInfo.Hotkey . " || Hold=" . keyHoldElapsed . " ms")
			LLARS_DeveloperAction("Hotkey || Released || " . keyInfo.Section . " || " . keyInfo.Hotkey)
		}
		else
		{
			LLARS_DeveloperAction("KeyPress || Key " . keyInfo.KeyName . " || Hold=" . keyHoldElapsed . " ms")
			LLARS_DeveloperAction("Key || Released || " . keyInfo.KeyName)
		}
		return
	}

	if (!LLARS_RUNNING || !LLARS_IsRuneScapeActive())
		return
	if LLARS_DeveloperKeyStates.HasKey(vkCode)
		return

	LLARS_DeveloperRefreshHotkeyMap()
	if (LLARS_DeveloperHotkeyMap.HasKey(vkCode))
	{
		hotkeyInfo := LLARS_DeveloperHotkeyMap[vkCode]
		LLARS_DeveloperKeyStates[vkCode] := {Type: "Hotkey", Section: hotkeyInfo.Section, Hotkey: hotkeyInfo.Hotkey, DownTick: eventTick}
		LLARS_DeveloperAction("Hotkey || Pressed || " . hotkeyInfo.Section . " || " . hotkeyInfo.Hotkey)
	}
	else
	{
		LLARS_DeveloperKeyStates[vkCode] := {Type: "Key", KeyName: keyName, DownTick: eventTick}
		LLARS_DeveloperAction("Key || Pressed || " . keyName)
	}
}

; Compatibility entry point for existing callers.
LLARS_DeveloperKeyPressed(vkCode)
{
	LLARS_DeveloperScriptKey(vkCode, false)
}

LLARS_DeveloperAction(action, lightweight := true)
{
	global LLARS_DeveloperActions, LLARS_DeveloperActionSerial

	; Keep timestamping and insertion atomic so simultaneous GUI/hotkey/timer
	; events cannot be appended out of chronological order. Preserve an outer
	; Critical section if the caller already owns one.
	developerWasCritical := A_IsCritical
	Critical, On

	; Normalize legacy spaced separators in Developer Console actions.
	action := StrReplace(action, " | ", " || ")
	LLARS_DeveloperCaptureAuditAction(action)

	; Keep raw MouseMove audit-only while leaving useful input timing visible.
	if RegExMatch(action, "i)^(?:Status|MouseMove) \|\|")
	{
		if (!developerWasCritical)
			Critical, Off
		return
	}

	; Preserve intentional multi-line diagnostics and indent continuation lines
	; so wrapped blocks remain visually grouped under the first timestamp.
	action := StrReplace(action, "`r`n", "`n")
	action := StrReplace(action, "`r", "`n")
	if InStr(action, "`n")
		action := StrReplace(action, "`n", "`n              ")

	FormatTime, developerActionTime,, HH:mm:ss
	developerActionTime .= "." . Format("{:03}", A_MSec)
	developerActionLine := developerActionTime . "  " . action
	if (LLARS_DeveloperActions = "")
		LLARS_DeveloperActions := developerActionLine
	else
		LLARS_DeveloperActions .= "`n" . developerActionLine

	developerActionCount := 0
	Loop, Parse, LLARS_DeveloperActions, `n, `r
		developerActionCount++

	while (developerActionCount > 500)
	{
		developerActionBreak := InStr(LLARS_DeveloperActions, "`n")
		if (!developerActionBreak)
			break
		LLARS_DeveloperActions := SubStr(LLARS_DeveloperActions, developerActionBreak + 1)
		developerActionCount--
	}

	; Every visible action advances a monotonic serial. Developer Mode renders
	; one stable serial+text snapshot and only marks it current after verifying
	; that the visible console accepted the complete snapshot.
	LLARS_DeveloperActionSerial++
	if (!developerWasCritical)
		Critical, Off

	; Event producers only update the authoritative action buffer. Developer
	; Mode renders stable snapshots from that buffer; producers never write to
	; the visible console directly.
}

; Records framework warning/error/recovery state in the existing Developer Action stream.
; This is intentionally lightweight: no additional log file or persistent telemetry store is created.
LLARS_DiagnosticRecord(kind, summary, detail := "")
{
	global LLARS_DiagnosticWarnings, LLARS_DiagnosticErrors, LLARS_DiagnosticRecoveries, LLARS_LastDiagnostic

	kind := Trim(kind)
	summary := Trim(summary)
	detail := Trim(detail)
	if (kind = "")
		kind := "Info"
	if (summary = "")
		summary := "Framework diagnostic"

	kindLower := kind
	StringLower, kindLower, kindLower
	if (kindLower = "warning" || kindLower = "blocked")
		LLARS_DiagnosticWarnings++
	else if (kindLower = "error")
		LLARS_DiagnosticErrors++
	else if (kindLower = "recovery" || kindLower = "recovered")
		LLARS_DiagnosticRecoveries++

	LLARS_LastDiagnostic := kind . ": " . summary
	action := "Diagnostic || " . kind . " || " . summary
	if (detail != "")
		action .= " || " . detail
	LLARS_DeveloperAction(action)
	return true
}

; Returns the compact diagnostic state consumed by Developer/support reporting.
LLARS_DiagnosticSnapshot()
{
	global LLARS_DiagnosticWarnings, LLARS_DiagnosticErrors, LLARS_DiagnosticRecoveries, LLARS_LastDiagnostic
	return {Warnings:(LLARS_DiagnosticWarnings + 0)
		, Errors:(LLARS_DiagnosticErrors + 0)
		, Recoveries:(LLARS_DiagnosticRecoveries + 0)
		, Last:(LLARS_LastDiagnostic = "" ? "None" : LLARS_LastDiagnostic)}
}

; Tracks the latest shared detection state for Developer Mode and support reporting.
; This is process-local diagnostic state only; scripts keep their own gameplay state machines.
LLARS_DetectionRecord(name, state, confidence := "", threshold := "", detail := "", logChange := true)
{
	global LLARS_DetectionName, LLARS_DetectionState, LLARS_DetectionConfidence, LLARS_DetectionThreshold
	global LLARS_DetectionDetail, LLARS_DetectionTick, LLARS_DetectionSignature

	name := Trim(name)
	state := Trim(state)
	detail := Trim(detail)
	if (name = "")
		name := "Detection"
	if (state = "")
		state := "Unknown"

	LLARS_DetectionName := name
	LLARS_DetectionState := state
	LLARS_DetectionConfidence := confidence
	LLARS_DetectionThreshold := threshold
	LLARS_DetectionDetail := detail
	LLARS_DetectionTick := A_TickCount

	signature := name . "|" . state . "|" . confidence . "|" . threshold . "|" . detail
	if (logChange && signature != LLARS_DetectionSignature)
	{
		action := "Detection || " . name . " || " . state
		if (confidence != "")
			action .= " || Confidence=" . confidence
		if (threshold != "")
			action .= " || Threshold=" . threshold
		if (detail != "")
			action .= " || " . detail
		LLARS_DeveloperAction(action)
	}
	LLARS_DetectionSignature := signature
	return true
}

LLARS_DetectionSnapshot()
{
	global LLARS_DetectionName, LLARS_DetectionState, LLARS_DetectionConfidence, LLARS_DetectionThreshold
	global LLARS_DetectionDetail, LLARS_DetectionTick
	return {Name:(LLARS_DetectionName = "" ? "None" : LLARS_DetectionName)
		, State:(LLARS_DetectionState = "" ? "Idle" : LLARS_DetectionState)
		, Confidence:LLARS_DetectionConfidence
		, Threshold:LLARS_DetectionThreshold
		, Detail:LLARS_DetectionDetail
		, Tick:(LLARS_DetectionTick + 0)}
}

LLARS_DetectionDisplay(short := false)
{
	state := LLARS_DetectionSnapshot()
	if !IsObject(state)
		return "None"
	text := short ? state.State : (state.Name . " " . state.State)
	if (state.Confidence != "")
	{
		text .= " " . state.Confidence
		if (state.Threshold != "")
			text .= "/" . state.Threshold
	}
	if (!short && state.Detail != "")
		text .= " | " . state.Detail
	return text
}

; Standard user-facing issue format: what happened, what LLARS did, and what to do next.
LLARS_ReportIssue(severity, title, whatHappened, whatLLARSDid := "", whatUserShouldDo := "", detail := "", showMessage := true)
{
	severity := Trim(severity)
	title := Trim(title)
	whatHappened := Trim(whatHappened)
	whatLLARSDid := Trim(whatLLARSDid)
	whatUserShouldDo := Trim(whatUserShouldDo)
	if (title = "")
		title := "LLARS"
	if (whatHappened = "")
		whatHappened := "An unexpected framework condition occurred."

	LLARS_DiagnosticRecord(severity, whatHappened, detail)
	if (!showMessage)
		return false

	message := "What happened:`n" . whatHappened
	if (whatLLARSDid != "")
		message .= "`n`nWhat LLARS did:`n" . whatLLARSDid
	if (whatUserShouldDo != "")
		message .= "`n`nWhat you should do:`n" . whatUserShouldDo

	severityLower := severity
	StringLower, severityLower, severityLower
	if (severityLower = "error")
		options := 0x40010
	else if (severityLower = "warning" || severityLower = "blocked")
		options := 0x40030
	else
		options := 0x40040
	MsgBox, %options%, %title%, %message%
	return false
}

LLARS_ReportWarning(title, whatHappened, whatLLARSDid := "", whatUserShouldDo := "", detail := "", showMessage := true)
{
	return LLARS_ReportIssue("Warning", title, whatHappened, whatLLARSDid, whatUserShouldDo, detail, showMessage)
}

LLARS_ReportError(title, whatHappened, whatLLARSDid := "", whatUserShouldDo := "", detail := "", showMessage := true)
{
	return LLARS_ReportIssue("Error", title, whatHappened, whatLLARSDid, whatUserShouldDo, detail, showMessage)
}

; Recovery events stay non-modal and flow into the same existing Developer/support stream.
LLARS_ReportRecovery(summary, detail := "")
{
	return LLARS_DiagnosticRecord("Recovery", summary, detail)
}

LLARS_DeveloperActionSnapshot()
{
	global LLARS_DeveloperActions, LLARS_DeveloperActionSerial

	; Avoid changing AHK thread Critical state just to take the snapshot. If an
	; action lands between reads, retry until the serial is stable around the
	; copied text. AHK executes event producers serially, so this converges fast.
	Loop, 4
	{
		serialBefore := LLARS_DeveloperActionSerial + 0
		textSnapshot := LLARS_DeveloperActions
		serialAfter := LLARS_DeveloperActionSerial + 0
		if (serialBefore = serialAfter)
			return {Serial:serialAfter, Text:textSnapshot}
	}

	return {Serial:(LLARS_DeveloperActionSerial + 0), Text:LLARS_DeveloperActions}
}


LLARS_DeveloperConfigureActionControl(hwnd)
{
	if (!hwnd)
		return false

	; Standard multiline Edit controls default to a comparatively small text
	; limit. LLARS keeps at most 500 action lines, so 1 MiB is ample headroom.
	; EM_SETLIMITTEXT = 0x00C5.
	DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x00C5, "Ptr", 1048576, "Ptr", 0)
	return true
}

LLARS_DeveloperReadActionControl(hwnd)
{
	if (!hwnd)
		return ""

	textLength := DllCall("GetWindowTextLengthW", "Ptr", hwnd, "Int")
	if (textLength <= 0)
		return ""

	VarSetCapacity(textBuffer, (textLength + 1) * 2, 0)
	DllCall("GetWindowTextW", "Ptr", hwnd, "Ptr", &textBuffer, "Int", textLength + 1)
	return StrGet(&textBuffer, textLength, "UTF-16")
}

LLARS_DeveloperNormalizeActionText(text)
{
	text := StrReplace(text, "`r`n", "`n")
	return StrReplace(text, "`r", "`n")
}

LLARS_DeveloperActionRenderMatches(hwnd, expected)
{
	actual := LLARS_DeveloperReadActionControl(hwnd)
	return (LLARS_DeveloperNormalizeActionText(actual) = LLARS_DeveloperNormalizeActionText(expected))
}

LLARS_DeveloperRenderActions(hwnd, actions)
{
	static rendering := false

	if (!hwnd || rendering)
		return false
	if (actions = "")
		actions := "No framework actions recorded yet."

	; Content and ordering are more important than per-line styling. A normal
	; read-only multiline Edit control receives the entire authoritative snapshot
	; in one SetWindowText call, eliminating RichEdit selection/formatting races.
	rendering := true
	Critical, On
	LLARS_DeveloperConfigureActionControl(hwnd)
	plainText := StrReplace(LLARS_DeveloperNormalizeActionText(actions), "`n", "`r`n")
	DllCall("SetWindowTextW", "Ptr", hwnd, "WStr", plainText)

	renderVerified := LLARS_DeveloperActionRenderMatches(hwnd, actions)
	if (renderVerified)
	{
		; Keep the newest action visible after each successful full snapshot.
		; For a standard Edit control, -1/-1 does not reliably place the caret
		; at the end. Use the actual text length, then force the vertical
		; scrollbar to the bottom so live updates stay on the newest entry.
		renderedLength := DllCall("GetWindowTextLengthW", "Ptr", hwnd, "Int")
		DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x00B1, "Ptr", renderedLength, "Ptr", renderedLength) ; EM_SETSEL
		DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x00B7, "Ptr", 0, "Ptr", 0) ; EM_SCROLLCARET
		DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x0115, "Ptr", 7, "Ptr", 0) ; WM_VSCROLL / SB_BOTTOM
	}

	rendering := false
	Critical, Off
	return renderVerified
}


; Stores the concise event history consumed by Developer Timing Audit.
LLARS_DeveloperCaptureAuditAction(action)
{
	global LLARS_DeveloperAuditActions

	if !LLARS_DeveloperAuditActionWanted(action)
		return

	if !IsObject(LLARS_DeveloperAuditActions)
		LLARS_DeveloperAuditActions := []

	LLARS_DeveloperAuditActions.Push(action)
	while (LLARS_DeveloperAuditActions.Length() > 500)
		LLARS_DeveloperAuditActions.RemoveAt(1)
}

; Keeps only the timing/input events shown by Developer Timing Audit.
LLARS_DeveloperAuditActionWanted(action)
{
	if RegExMatch(action, "i)^(KeyPress|Key Press|Key Hold|Keyboard Timing|Mouse Timing|MouseMove|Move|Left Click|Right Click|Middle Click|XButton[12] Click|NaturalClick(?: Timing| Movement)?) \|\|")
		return true

	if RegExMatch(action, "i)^(Color Search|Color Click|Divination Color Audit) \|\|")
		return true

	if RegExMatch(action, "i)^[^|]+ \|\| \d+(?:\.\d+)?-\d+(?:\.\d+)? ms \|\| \d+(?:\.\d+)? ms$")
		return true

	if RegExMatch(action, "i)^[^|]*(?:Sleep|Wait|Timer)[^|]* \|\| \d+(?:\.\d+)? ms$")
		return true

	return false
}

; Records LLARS GUI lifecycle events only.
LLARS_DeveloperUIAction(windowName, action := "Opened")
{
	static guiStates := {}

	windowName := Trim(windowName)
	action := Trim(action)
	if (windowName = "")
		return
	if (action = "")
		action := "Opened"

	; Keep GUI lifecycle entries symmetrical without duplicating them when a dashboard is rebuilt or a close path is reached more than once.
	if (action = "Opened")
	{
		if (guiStates.HasKey(windowName) && guiStates[windowName])
			return
		guiStates[windowName] := true
	}
	else if (action = "Closed")
	{
		if (!guiStates.HasKey(windowName) || !guiStates[windowName])
			return
		guiStates[windowName] := false
	}

	LLARS_DeveloperAction("GUI || " . action . " || " . windowName)
}

; Records a shared LLARS hotkey when the current label was entered by a hotkey.
LLARS_DeveloperHotkey(action)
{
	global LLARS_DeveloperLastHotkey, LLARS_DeveloperControlKeyStates

	if (A_ThisHotkey = "")
		return

	developerHotkey := A_ThisHotkey
	StringReplace, developerHotkey, developerHotkey, $, , All
	; LLARS control hotkeys are user input, but they are framework commands.
	controlKey := RegExReplace(developerHotkey, "^[\$\*\~<>\^!+#]+")
	controlKey := RegExReplace(controlKey, "i)\s+up$")
	controlKey := Trim(controlKey)
	if (controlKey = "" || !GetKeyState(controlKey, "P"))
		return

	LLARS_DeveloperLastHotkey := developerHotkey . " - " . action
	LLARS_DeveloperAction("Control Hotkey || Pressed || " . action . " || " . developerHotkey)

	stateKey := action . "|" . developerHotkey
	LLARS_DeveloperControlKeyStates[stateKey] := {Action: action, Hotkey: developerHotkey, KeyName: controlKey}
	SetTimer, LLARS_DeveloperControlHotkeyReleaseTimer, 25
}

; Polls only LLARS control hotkeys that were explicitly recorded above so their
; release events can be paired without monitoring arbitrary physical input.
LLARS_DeveloperCheckControlHotkeyReleases()
{
	global LLARS_DeveloperControlKeyStates

	if !IsObject(LLARS_DeveloperControlKeyStates)
	{
		SetTimer, LLARS_DeveloperControlHotkeyReleaseTimer, Off
		return
	}

	releasedKeys := []
	for stateKey, keyInfo in LLARS_DeveloperControlKeyStates
	{
		if !GetKeyState(keyInfo.KeyName, "P")
		{
			LLARS_DeveloperAction("Control Hotkey || Released || " . keyInfo.Action . " || " . keyInfo.Hotkey)
			releasedKeys.Push(stateKey)
		}
	}

	for _, stateKey in releasedKeys
		LLARS_DeveloperControlKeyStates.Delete(stateKey)

	if (LLARS_DeveloperControlKeyStates.Count() = 0)
		SetTimer, LLARS_DeveloperControlHotkeyReleaseTimer, Off
}

; Returns the live cursor position in RuneScape client coordinates and the
; RGB pixel color directly under the cursor without changing LLARS CoordMode.
LLARS_DeveloperMousePixel(ByRef mouseX, ByRef mouseY, ByRef pixelColor, ByRef inspectorStatus)
{
	mouseX := "--"
	mouseY := "--"
	pixelColor := "--"
	inspectorStatus := "INACTIVE"

	; Never inspect another application.
	developerRuneScapeHWND := WinExist("A")
	if !LLARS_IsRuneScapeWindow(developerRuneScapeHWND)
	{
		if LLARS_FindRuneScapeWindow()
			inspectorStatus := "INACTIVE"
		else
			inspectorStatus := "NOT FOUND"
		return false
	}

	inspectorStatus := "ACTIVE"
	VarSetCapacity(developerPoint, 8, 0)
	if !DllCall("GetCursorPos", "Ptr", &developerPoint)
		return false

	developerScreenX := NumGet(developerPoint, 0, "Int")
	developerScreenY := NumGet(developerPoint, 4, "Int")

	developerDC := DllCall("GetDC", "Ptr", 0, "Ptr")
	if (developerDC)
	{
		developerColor := DllCall("GetPixel", "Ptr", developerDC, "Int", developerScreenX, "Int", developerScreenY, "UInt")
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", developerDC)
		if (developerColor != 0xFFFFFFFF)
		{
			developerRed := developerColor & 0xFF
			developerGreen := (developerColor >> 8) & 0xFF
			developerBlue := (developerColor >> 16) & 0xFF
			pixelColor := Format("0x{:02X}{:02X}{:02X}", developerRed, developerGreen, developerBlue)
		}
	}

	NumPut(developerScreenX, developerPoint, 0, "Int")
	NumPut(developerScreenY, developerPoint, 4, "Int")
	if DllCall("ScreenToClient", "Ptr", developerRuneScapeHWND, "Ptr", &developerPoint)
	{
		mouseX := NumGet(developerPoint, 0, "Int")
		mouseY := NumGet(developerPoint, 4, "Int")
	}

	return true
}

; Confirms RuneScape is available before allowing automation to begin.
LLARS_CheckGame()
{
	if LLARS_FindRuneScapeWindow()
		return true

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
	Gui GNF: +ToolWindow
	Gui GNF: -caption
	Gui GNF: Show, center w230, Game Not Found
	return false
}

; Validates and starts a RunCount script, including the requested run count
; and runtime-estimation state used by the RunCount GUI.
LLARS_StartRun()
{
	global scriptname, frcount, LLARS_RUNNING
	global count
	global runcount, runcount3, startcheck
	global StartTime, StartTimeStamp
	global EstLoopStartTick, EstLoopTime, EstAverageLoopTime, EstFollowingAverageLoopTime, EstFollowingCompletedLoops, EstCompletedLoops
	global EstFinalSleepActive, EstFinalSleepEndTick
	global LLARS_RunStartTick, LLARS_RUN_TYPE

	if (!LLARS_CheckGame())
		return false

	if (ConfigError())
		return false

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_DeveloperHotkey("Start")
	InputBox, runcount, Run How Many Times?,,,250,100
	if (ErrorLevel)
	{
		Reload
		return false
	}

	if (runcount = "" || !RegExMatch(runcount, "^\d+$") || runcount <= 0)
	{
		MsgBox, 48, Invalid Input, Please enter a valid whole number greater than 0.
		return false
	}

	if (runcount > 1000)
	{
		MsgBox, 48, Invalid Input, Please enter a number between 1 and 1000.
		return false
	}

	if (frcount = 0)
		LLARS_CreateRunCountGUI()
	GuiControl,, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl,, State3, Running
	DisableButton()
	startcheck := 1
	LLARS_ResetRunState()
	LLARS_RUNNING := true
	LLARS_PAUSED := false
	SetLLARSHOTKEYS("On")
	runcount3 := runcount
	StartTime := A_TickCount
	LLARS_RunStartTick := StartTime
	LLARS_RUN_TYPE := "RunCount"
	StartTimeStamp := A_Hour ":" A_Min ":" A_Sec
	LLARS_DeveloperAction("Run Started || " . runcount3 . " runs")
	EstLoopStartTick := 0
	EstLoopTime := 0
	EstAverageLoopTime := 0
	EstFollowingAverageLoopTime := 0
	EstFollowingCompletedLoops := 0
	EstCompletedLoops := 0
	EstFinalSleepActive := false
	EstFinalSleepEndTick := 0
	if (!CalculateScriptRuntime())
	{
		GuiControl,, EstLoopRemaining, Estimate Error
		GuiControl,, EstRunRemaining, Estimate Error
		Gui, Show
		Sleep, 250
		MsgBox, 48, LLARS Estimate Error, Unable to calculate the estimated loop/run time.`n`nRunCount scripts need at least one enabled LLARS_Sleep("Sleep Section") or LLARS_RandomSleep() call inside the editable script section so LLARS can estimate the loop safely.`n`nThe automation loop will not start.
		LLARS_RUNNING := false
		EnableButton()
		return false
	}

	Gosub, UpdateEstimatedTime
	Gui, Show
	Sleep, 500
	SetTimer, UpdateEstimatedTime, 250
	if IsFunc("LLARS_ActivateRuneScapeAtRunStart")
	{
		if !LLARS_ActivateRuneScapeAtRunStart()
		{
			LLARS_RUNNING := false
			SetTimer, UpdateEstimatedTime, Off
			EnableButton()
			return false
		}
	}
	return true
}

; Validates and starts a condition-driven script that runs until the script itself reports completion.
LLARS_StartUntilDoneRun()
{
	global LLARS_RUNNING, LLARS_PAUSED
	global startcheck, LLARS_RunStartTick, LLARS_RUN_TYPE, LLARS_DeveloperKeyStates

	if (!LLARS_CheckGame())
		return false

	if (ConfigError())
		return false

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_DeveloperHotkey("Start")
	startcheck := 1
	LLARS_DeveloperKeyStates := {}
	LLARS_RUNNING := true
	LLARS_PAUSED := false
	LLARS_RunStartTick := A_TickCount
	LLARS_RUN_TYPE := "UntilDone"
	LLARS_DeveloperAction("Until-Done Run Started")
	LLARS_CreateUntilDoneGUI()
	GuiControl,, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl,, State3, Running
	DisableButton()
	SetLLARSHOTKEYS()
	if IsFunc("LLARS_ActivateRuneScapeAtRunStart")
	{
		if !LLARS_ActivateRuneScapeAtRunStart()
		{
			LLARS_RUNNING := false
			EnableButton()
			return false
		}
	}
	return true
}

; Clears shared running state after a condition-driven script reaches its own completion condition.
LLARS_EndUntilDoneRun()
{
	global LLARS_RUNNING, LLARS_RunStartTick, LLARS_DeveloperKeyStates
	global LLARS_RunRuneScapeHwnd

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_DeveloperAction("Until-Done Run Completed")
	if IsFunc("LLARS_AHI_ReleaseAllInput")
		LLARS_AHI_ReleaseAllInput()
	LLARS_RUNNING := false
	LLARS_DeveloperKeyStates := {}
	LLARS_RunStartTick := 0
	LLARS_RunRuneScapeHwnd := 0
	EnableButton()
	SetLLARSHOTKEYS()
}

; Validates and starts a duration-based script using the user's run time.
LLARS_StartTimerRun()
{
	global scriptname, LLARS_RUNNING, LLARS_PAUSED
	global timeToRunMinutes, timeToRunMS, endTime, startcheck
	global LLARS_RunStartTick, LLARS_RUN_TYPE, LLARS_DeveloperKeyStates

	if (!LLARS_CheckGame())
		return false

	if (ConfigError())
		return false

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_DeveloperHotkey("Start")
	InputBox, timeToRunMinutes, Set Run Time, Enter how long to run in minutes.`nExample: 1 = 1 minute or 0.5 = 30 seconds.,,270,165
	if (ErrorLevel)
	{
		Reload
		return false
	}

	timeToRunMinutes := Trim(timeToRunMinutes)
	if (!RegExMatch(timeToRunMinutes, "^\d+(\.\d+)?$") || timeToRunMinutes <= 0)
	{
		MsgBox, 48, Invalid Input, Please enter a valid number greater than 0.
		return false
	}

	timeToRunMS := timeToRunMinutes * 60 * 1000
	endTime := A_TickCount + timeToRunMS
	startcheck := 1
	LLARS_DeveloperKeyStates := {}
	LLARS_RUNNING := true
	LLARS_PAUSED := false
	LLARS_RunStartTick := A_TickCount
	LLARS_RUN_TYPE := "Timer"
	LLARS_DeveloperAction("Timed Run Started || " . timeToRunMinutes . " min")
	LLARS_CreateTimerGUI()
	GuiControl,, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl,, State3, Running
	GuiControl,, TimerCount, % LLARS_TimerRemainingText(endTime - A_TickCount)
	DisableButton()
	SetLLARSHOTKEYS()
	if IsFunc("LLARS_ActivateRuneScapeAtRunStart")
	{
		if !LLARS_ActivateRuneScapeAtRunStart()
		{
			LLARS_RUNNING := false
			EnableButton()
			return false
		}
	}
	LLARS_DeveloperScriptTimerAction("Timer set to " timeToRunMinutes " minutes")
	return true
}

; Clears the shared running state and restores controls after a timed run.
LLARS_EndTimerRun()
{
	global LLARS_RUNNING, LLARS_RunStartTick, LLARS_DeveloperKeyStates
	global LLARS_RunRuneScapeHwnd

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_DeveloperAction("Timed Run Completed")
	if IsFunc("LLARS_AHI_ReleaseAllInput")
		LLARS_AHI_ReleaseAllInput()
	LLARS_RUNNING := false
	LLARS_DeveloperKeyStates := {}
	LLARS_RunStartTick := 0
	LLARS_RunRuneScapeHwnd := 0
	EnableButton()
	SetLLARSHOTKEYS()
}

; Converts remaining milliseconds into the timer text shown in the GUI.
LLARS_TimerRemainingText(time)
{
	if (time <= 0)
		return "0m 0s"

	; Countdown text represents time still remaining, so retain a partial
	; final second instead of displaying zero before the timer is actually due.
	totalSeconds := Ceil(time / 1000)
	minutes := Floor(totalSeconds / 60)
	seconds := Mod(totalSeconds, 60)
	return minutes . "m " . seconds . "s"
}

; Resets shared counters and first-run flags before a new RunCount session.
LLARS_ResetRunState()
{
	global count2, sleepcount, totalSleepTime, rightclick, clickcount
	global LLARS_RunRuneScapeHwnd
	global firstrun, prime, bobprime
	global LLARS_DeveloperKeyStates
	global LLARS_RandomSleepPending, LLARS_RandomSleepPendingRun
	global LLARS_RandomSleepPendingChance, LLARS_RandomSleepPendingRoll
	global EstRandomSleepAdjustment, EstConfiguredSleepAdjustment

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_RunRuneScapeHwnd := 0
	LLARS_DeveloperKeyStates := {}
	EstRandomSleepAdjustment := 0
	EstConfiguredSleepAdjustment := 0
	LLARS_RandomSleepPending := false
	LLARS_RandomSleepPendingRun := false
	LLARS_RandomSleepPendingChance := ""
	LLARS_RandomSleepPendingRoll := ""
	count2 := 0
	sleepcount := 0
	totalSleepTime := 0
	rightclick := 0
	clickcount := 0
	firstrun := 0
	prime := 0
	bobprime := 0
}

; Marks the beginning of one RunCount loop and updates loop tracking.
LLARS_BeginLoop()
{
	global EstLoopStartTick, count, count2, runcount, runcount3
	global EstFinalSleepActive, EstFinalSleepEndTick
	global LLARS_RandomSleepPending, LLARS_RandomSleepPendingRun
	global LLARS_RandomSleepPendingChance, LLARS_RandomSleepPendingRoll
	global EstRandomSleepAdjustment, EstConfiguredSleepAdjustment
	global scriptname

	; Each loop starts from configured averages. Individual LLARS_Sleep calls
	; replace their average contribution with the actual randomized duration as
	; soon as that duration is chosen. Random Sleep is adjusted independently.
	EstRandomSleepAdjustment := 0
	EstConfiguredSleepAdjustment := 0

	; A prepared Random Sleep roll is valid for one RunCount loop only.
	LLARS_RandomSleepPending := false
	LLARS_RandomSleepPendingRun := false
	LLARS_RandomSleepPendingChance := ""
	LLARS_RandomSleepPendingRoll := ""

	EstFinalSleepActive := false
	EstFinalSleepEndTick := 0
	EstLoopStartTick := A_TickCount
	LLARS_DeveloperAction("Loop Started || " . (count2 + 1) . "/" . runcount3)
	if IsFunc("LLARS_WaitForRuneScape")
		LLARS_WaitForRuneScape("RunCount loop start")

	++count
	++count2
	GuiControl,, Counter, %count%
	GuiControl,, Counter2, %count2% / %runcount3%
	GuiControl,, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl,, State3, Running
	DisableButton()
}

; Finds the configured timer section that produced the current randomized
; duration so Developer Mode can show the timer name, range, and actual value.
LLARS_DeveloperTimerInfo(time, ByRef timerName, ByRef timerMin, ByRef timerMax)
{
	global LLARS_SCRIPT_DIR, sa1, sa2

	timerName := ""
	timerMin := ""
	timerMax := ""
	configFile := LLARS_SCRIPT_DIR . "\Config.ini"

	if !FileExist(configFile)
		return false

	developerSections := LLARS_ConfigSectionList(configFile)
	bestRange := ""

	Loop, Parse, developerSections, `n, `r
	{
		sectionName := Trim(A_LoopField)
		if (sectionName = "")
			continue

		IniRead, sectionMin, %configFile%, %sectionName%, min, ERROR
		IniRead, sectionMax, %configFile%, %sectionName%, max, ERROR

		if (sectionMin = "ERROR" || sectionMax = "ERROR")
			continue
		if sectionMin is not number
			continue
		if sectionMax is not number
			continue

		if (sa1 != "" && sa2 != "" && sectionMin = sa1 && sectionMax = sa2)
		{
			timerName := sectionName
			timerMin := sectionMin
			timerMax := sectionMax
			return true
		}

		if (time >= sectionMin && time <= sectionMax)
		{
			sectionRange := sectionMax - sectionMin
			if (bestRange = "" || sectionRange < bestRange)
			{
				bestRange := sectionRange
				timerName := sectionName
				timerMin := sectionMin
				timerMax := sectionMax
			}
		}
	}

	return (timerName != "")
}

; Adds one compact configured-timer entry to Recent Framework Actions.
LLARS_DeveloperTimerAction(time)
{
	global LLARS_DeveloperLastSleepValue, LLARS_DeveloperLastSleepName

	if LLARS_DeveloperTimerInfo(time, timerName, timerMin, timerMax)
	{
		LLARS_DeveloperAction(timerName . " || " . timerMin . "-" . timerMax . " ms || " . time . " ms")
		LLARS_DeveloperLastSleepName := timerName
	}
	else
	{
		LLARS_DeveloperAction("Sleep || " . time . " ms")
		LLARS_DeveloperLastSleepName := "Sleep"
	}

	LLARS_DeveloperLastSleepValue := time
}

; Runs an ordinary configured sleep while the current-loop display remains
; predictive. LLARS_FinalSleep() performs the exact per-loop handoff.
LLARS_EstimatedSleep(time)
{
	; Ordinary configured sleep. The GUI remains on the predictive loop
	; estimate until the script explicitly reaches LLARS_FinalSleep().
	LLARS_DeveloperTimerAction(time)
	Sleep, %time%
	if (LLARS_RUNNING && IsFunc("LLARS_WaitForRuneScape"))
		LLARS_WaitForRuneScape("Estimated sleep complete")
}

; Rolls the shared Random Sleep chance and stores the result for this loop.
LLARS_RandomSleepRoll()
{
	global LLARS_CONFIG_FILE
	global LLARS_RandomSleepPending, LLARS_RandomSleepPendingRun
	global LLARS_RandomSleepPendingChance, LLARS_RandomSleepPendingRoll

	LLARS_RandomSleepPending := true
	LLARS_RandomSleepPendingRun := false
	LLARS_RandomSleepPendingChance := ""
	LLARS_RandomSleepPendingRoll := ""

	IniRead, option, %LLARS_CONFIG_FILE%, Random Sleep, option, false
	option := Trim(option)
	StringLower, option, option

	if (option != "true")
	{
		LLARS_DeveloperRandomSleepConfig("Disabled")
		return false
	}

	IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance, ERROR
	chance := Trim(chance)
	if chance is not number
	{
		LLARS_DeveloperAction("Random Sleep || Config Error || Chance=" . chance)
		return false
	}

	chance += 0
	if (chance < 0 || chance > 100)
	{
		LLARS_DeveloperAction("Random Sleep || Config Error || Chance=" . chance . "%")
		return false
	}

	LLARS_DeveloperRandomSleepConfig("Enabled", chance)
	LLARS_RandomSleepPendingChance := chance

	Random, RandomNumber, 1, 100
	LLARS_RandomSleepPendingRoll := RandomNumber
	LLARS_RandomSleepPendingRun := (RandomNumber <= chance)
	rollResult := LLARS_RandomSleepPendingRun ? "Triggered" : "Skipped"
	LLARS_DeveloperAction("Random Sleep || Rolled || " . RandomNumber . "/100 || Chance=" . chance . "% || " . rollResult)

	return LLARS_RandomSleepPendingRun
}

; Reports Random Sleep configuration only when it changes so the developer feed
; stays informative without repeating the same configuration every loop.
LLARS_DeveloperRandomSleepConfig(state, chance := "")
{
	global LLARS_RunStartTick
	static lastConfig := "", lastRunStartTick := ""

	configText := state
	if (state = "Enabled")
		configText .= " || Chance=" . chance . "%"

	if (configText = lastConfig && lastRunStartTick = LLARS_RunStartTick)
		return

	lastConfig := configText
	lastRunStartTick := LLARS_RunStartTick
	LLARS_DeveloperAction("Random Sleep || " . configText)
}

; Returns the probability-weighted Random Sleep amount already included in
; the normal RunCount estimate for one LLARS_RandomSleep() occurrence.
LLARS_RandomSleepExpectedContribution()
{
	global LLARS_CONFIG_FILE

	IniRead, option, %LLARS_CONFIG_FILE%, Random Sleep, option, false
	option := Trim(option)
	StringLower, option, option
	if (option != "true")
		return 0

	IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance, 0
	IniRead, rs1, %LLARS_CONFIG_FILE%, Random Sleep, min, 0
	IniRead, rs2, %LLARS_CONFIG_FILE%, Random Sleep, max, 0
	chance := Trim(chance)
	rs1 := Trim(rs1)
	rs2 := Trim(rs2)

	if chance is not number
		return 0
	if rs1 is not integer
		return 0
	if rs2 is not integer
		return 0

	chance += 0
	rs1 += 0
	rs2 += 0
	if (chance < 0 || chance > 100 || rs1 < 0 || rs2 < rs1)
		return 0

	return ((rs1 + rs2) / 2) * (chance / 100)
}

; Replaces the probability-weighted Random Sleep contribution in the current loop estimate with what actually happened on this occurrence.
LLARS_AdjustRandomSleepEstimate(actualSleep)
{
	global LLARS_RUNNING, LLARS_RUN_TYPE
	global EstRandomSleepAdjustment

	if (!LLARS_RUNNING || LLARS_RUN_TYPE != "RunCount")
		return

	expectedSleep := LLARS_RandomSleepExpectedContribution()
	EstRandomSleepAdjustment += (actualSleep - expectedSleep)
	Gosub, UpdateEstimatedTime
}

; Runs the optional shared Random Sleep configured in LLARS Config.ini.
LLARS_RandomSleep()
{
	global LLARS_CONFIG_FILE
	global LLARS_RandomSleepPending, LLARS_RandomSleepPendingRun
	global LLARS_RandomSleepPendingChance, LLARS_RandomSleepPendingRoll
	global sleepcount, totalSleepTime
	global EndTime, RandomSleepAmount
	global scriptname

	if (!LLARS_RandomSleepPending)
		LLARS_RandomSleepRoll()

	shouldRun := LLARS_RandomSleepPendingRun
	chance := LLARS_RandomSleepPendingChance
	RandomNumber := LLARS_RandomSleepPendingRoll

	; Consume the prepared result immediately so it can never leak into a later call.
	LLARS_RandomSleepPending := false
	LLARS_RandomSleepPendingRun := false
	LLARS_RandomSleepPendingChance := ""
	LLARS_RandomSleepPendingRoll := ""

	if (!shouldRun)
	{
		LLARS_AdjustRandomSleepEstimate(0)
		return 0
	}

	; Recheck the option immediately before sleeping so Random Sleep can never run after the shared setting has been disabled.
	IniRead, option, %LLARS_CONFIG_FILE%, Random Sleep, option, false
	option := Trim(option)
	StringLower, option, option
	if (option != "true")
	{
		LLARS_DeveloperRandomSleepConfig("Disabled")
		return 0
	}

	IniRead, rs1, %LLARS_CONFIG_FILE%, Random Sleep, min, ERROR
	IniRead, rs2, %LLARS_CONFIG_FILE%, Random Sleep, max, ERROR
	rs1 := Trim(rs1)
	rs2 := Trim(rs2)

	if rs1 is not integer
	{
		LLARS_DeveloperAction("Random Sleep || Config Error || Min=" . rs1)
		return 0
	}

	if rs2 is not integer
	{
		LLARS_DeveloperAction("Random Sleep || Config Error || Max=" . rs2)
		return 0
	}

	rs1 += 0
	rs2 += 0
	if (rs1 < 0 || rs2 < rs1)
	{
		LLARS_DeveloperAction("Random Sleep || Config Error || Range=" . rs1 . "-" . rs2 . " ms")
		return 0
	}

	Random, RandomSleepAmount, %rs1%, %rs2%
	++sleepcount
	totalSleepTime += RandomSleepAmount
	EndTime := A_TickCount + RandomSleepAmount
	LLARS_AdjustRandomSleepEstimate(RandomSleepAmount)

	GuiControl, 1:, ScriptBlue, Random Sleep
	Gui, 1: Font, s10 Bold cRed
	GuiControl, 1: Font, State3
	Gui, 1: Font, s10 Bold cBlack
	GuiControl, 1:, State3, % RandomSleepAmountToMinutesSeconds(RandomSleepAmount)
	LLARS_DeveloperAction("Random Sleep || Sleeping || " . RandomSleepAmount . " ms")
	LLARS_DeveloperLoggedSleepAction("RANDOM SLEEP", "Sleep=" RandomSleepAmount " ms | Chance=" chance "% | Roll=" RandomNumber)

	SetTimer, UpdateCountdown, Off
	SetTimer, UpdateCountdown, 1000
	Sleep, %RandomSleepAmount%
	if (LLARS_RUNNING && IsFunc("LLARS_WaitForRuneScape"))
		LLARS_WaitForRuneScape("Random Sleep complete")
	SetTimer, UpdateCountdown, Off

	Gui, 1: Font, s10 Bold cBlue
	GuiControl, 1: Font, State3
	Gui, 1: Font, s10 Bold cBlack
	GuiControl, 1:, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl, 1:, State3, Running
	Gosub, UpdateEstimatedTime

	return RandomSleepAmount
}

; Uses the actual randomized duration of the final sleep for this iteration.
LLARS_FinalSleep(time)
{
	global EstFinalSleepActive, EstFinalSleepEndTick
	global LLARS_RUNNING

	EstFinalSleepActive := true
	EstFinalSleepEndTick := A_TickCount + time
	LLARS_DeveloperTimerAction(time)
	Gosub, UpdateEstimatedTime
	Sleep, %time%
	if (LLARS_RUNNING && IsFunc("LLARS_WaitForRuneScape"))
		LLARS_WaitForRuneScape("Final sleep complete")
}

; Records the completed loop time and updates the live runtime estimate.
LLARS_EndLoop()
{
	global EstLoopStartTick, EstLoopTime, EstCompletedLoops, EstAverageLoopTime
	global EstFollowingAverageLoopTime, EstFollowingCompletedLoops

	EstLoopTime := A_TickCount - EstLoopStartTick
	++EstCompletedLoops
	if (EstCompletedLoops = 1)
	{
		EstAverageLoopTime := EstLoopTime
	}
	else
	{
		++EstFollowingCompletedLoops
		if (EstFollowingCompletedLoops = 1)
			EstFollowingAverageLoopTime := EstLoopTime
		else
			EstFollowingAverageLoopTime := ((EstFollowingAverageLoopTime * (EstFollowingCompletedLoops - 1)) + EstLoopTime) / EstFollowingCompletedLoops

		EstAverageLoopTime := ((EstAverageLoopTime * (EstCompletedLoops - 1)) + EstLoopTime) / EstCompletedLoops
	}

	Gosub, UpdateEstimatedTime
	LLARS_DeveloperAction("Loop Completed || " . EstCompletedLoops)
}

; Finalizes a completed RunCount session, restores controls, and performs
; the configured completion behavior.
LLARS_RunComplete()
{
	global scriptname, runcount3, sleepcount, totalSleepTime, StartTime, StartTimeStamp
	global LLARS_RUNNING, LLARS_RunRuneScapeHwnd
	global EndTimeStamp, EndTime
	global TotalTimeSeconds, AverageTimeSecondsTotal
	global TotalTimeHours, TotalTimeMinutes, TotalTimeSecondsDisplay
	global AverageTimeMinutes, AverageTimeSecondsDisplay, percentage
	global totalSleepTimeSeconds, TotalSleepHours, TotalSleepMinutes, TotalSleepSeconds
	global chance
	global LLARS_RunStartTick

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_DeveloperAction("Run Completed || " . runcount3 . " runs")
	if IsFunc("LLARS_AHI_ReleaseAllInput")
		LLARS_AHI_ReleaseAllInput()
	Logout()
	SetTimer, UpdateEstimatedTime, Off
	GuiControl,, EstLoopRemaining, 0h 0m 0s
	GuiControl,, EstRunRemaining, 0h 0m 0s
	GuiControl,, ScriptGreen, % LLARS_DisplayScriptName()
	GuiControl,, State1, Finished
	EndTimeStamp := A_Hour ":" A_Min ":" A_Sec
	EndTime := A_TickCount
	TotalTimeSeconds := Floor((EndTime - StartTime) / 1000)
	AverageTimeSecondsTotal := Floor(TotalTimeSeconds / runcount3)
	TotalTimeHours := Floor(TotalTimeSeconds / 3600)
	TotalTimeMinutes := Floor(Mod(TotalTimeSeconds, 3600) / 60)
	TotalTimeSecondsDisplay := Mod(TotalTimeSeconds, 60)
	AverageTimeMinutes := Floor(AverageTimeSecondsTotal / 60)
	AverageTimeSecondsDisplay := Mod(AverageTimeSecondsTotal, 60)
	percentage := Round((sleepcount / runcount3) * 100)
	totalSleepTimeSeconds := Floor(totalSleepTime / 1000)
	TotalSleepHours := Floor(totalSleepTimeSeconds / 3600)
	TotalSleepMinutes := Floor(Mod(totalSleepTimeSeconds, 3600) / 60)
	TotalSleepSeconds := Mod(totalSleepTimeSeconds, 60)
	SoundPlay, C:\Windows\Media\Ring06.wav, 1
	IniRead, chance, %LLARS_CONFIG_FILE%, Random Sleep, chance
	MsgBox, 64, LLARS Run Info, %scriptname% has completed %runcount3% runs`n`nTotal time: %TotalTimeHours%h : %TotalTimeMinutes%m : %TotalTimeSecondsDisplay%s`nAverage loop: %AverageTimeMinutes%m : %AverageTimeSecondsDisplay%s`n`nStart time: %StartTimeStamp%`nEnd time: %EndTimeStamp%`n`nSet sleep chance: %chance%`%`nActual sleep chance: %percentage%`%`nTotal random sleeps: %sleepcount%`nTotal time slept: %TotalSleepHours%h : %TotalSleepMinutes%m : %TotalSleepSeconds%s
	LLARS_RUNNING := false
	LLARS_RunStartTick := 0
	LLARS_RunRuneScapeHwnd := 0
	EnableButton()
	SetLLARSHOTKEYS("On")
}

; ================================================================
; |     CONFIGURATION     -     CONFIGURATION                    |
; ================================================================
; Shows the shared startup error used when a required config file is missing.
LLARS_ShowMissingConfigFile(fileName)
{
	Menu, Tray, NoIcon
	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5,ERROR
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, % fileName . " not found"
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
	Gui Error: +ToolWindow
	Gui Error: -caption
	Gui Error: Show, center w230, Config Error
}

; Checks that the script and shared LLARS configuration files are present.
LLARS_CheckStartupFiles()
{
	global LLARS_DISABLE_SCRIPT_CONFIG, LLARS_ROOT

	if !FileExist(LLARS_ROOT "\VERSION")
	{
		MsgBox, 48, LLARS Files Missing, LLARS is missing VERSION.`n`nRe-extract or redownload the complete LLARS release before continuing.
		return false
	}

	if (!LLARS_DISABLE_SCRIPT_CONFIG)
	{
		if !FileExist("Config.ini")
		{
			LLARS_ShowMissingConfigFile("Config.ini")
			return false
		}

	}

	if !FileExist(LLARS_CONFIG_FILE)
	{
		LLARS_ShowMissingConfigFile("LLARS Config.ini")
		return false
	}

	return true
}

; Runs validation against the script Config.ini when enabled and always validates
; the shared LLARS Config.ini used by framework hotkeys and global settings.
ConfigError()
{
	global LLARS_DISABLE_SCRIPT_CONFIG

	if (!LLARS_DISABLE_SCRIPT_CONFIG && CheckConfigFile("Config.ini"))
		return true

	if (CheckConfigFile(LLARS_CONFIG_FILE))
		return true

	return false
}

; Opens the affected config, shows one framework error, logs it, and reloads.
LLARS_ShowConfigError(file, message, logDetails)
{
	if InStr(file, ":\")
		Run, %file%
	else
		Run, %A_ScriptDir%\%file%
	GuiControl,, ScriptRed, CONFIG
	GuiControl,, State2, ERROR
	LLARS_ReportError("Config Error", message
		, "Opened the affected configuration file and stopped normal startup."
		, "Enter a valid value, save the file, then allow LLARS to reload."
		, logDetails)
	Reload
}

; Reports a required configuration value that is missing or blank.
ConfigErrorMessage(file, section, key)
{
	message := "Please enter a value for:`n`n[" . section . "]`n" . key
	LLARS_ShowConfigError(file, message, file . " | [" . section . "] " . key . " is blank")
}

; Reports a present configuration value that fails semantic validation.
ConfigSemanticErrorMessage(file, section, key, details)
{
	message := "Invalid configuration value:`n`n[" . section . "]`n" . key . "`n`n" . details
	LLARS_ShowConfigError(file, message, file . " | [" . section . "] " . key . " | " . details)
}

; Returns true when a value is a complete signed integer or decimal.
LLARS_IsNumericConfigValue(value)
{
	value := Trim(value)
	return RegExMatch(value, "^-?(?:\d+(?:\.\d*)?|\.\d+)$")
}

; Validates the standard AutoHotkey hotkey strings produced by the
; LLARS Hotkey editor, including modifier prefixes and mouse wheel keys.
LLARS_IsValidConfigHotkey(value)
{
	value := Trim(value)
	if (value = "")
		return false

	keyName := value
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

	if (keyName = "")
		return false

	if (GetKeyVK(keyName) || GetKeySC(keyName))
		return true

	if keyName in WheelUp,WheelDown,WheelLeft,WheelRight
		return true

	return false
}

; Validates required values and semantics for every active config section.
CheckConfigFile(file)
{
	global LLARS_SCRIPT_DIR
	global LLARS_CONFIG_FILE

	ConfigPath := InStr(file, ":\") ? file : LLARS_SCRIPT_DIR "\" file
	sections := LLARS_ConfigSectionList(ConfigPath)
	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		IniRead, keys, %ConfigPath%, %section%

		; Validate option metadata before deciding whether the section is active.
		IniRead, option, %ConfigPath%, %section%, option, ERROR
		if (option != "ERROR")
		{
			option := Trim(option)
			StringLower, optionLower, option
			if (optionLower != "true" && optionLower != "false")
			{
				ConfigSemanticErrorMessage(file, section, "option", "Expected true or false. Found: " option)
				return true
			}
		}
		else
			optionLower := "true"

		; Treat type as framework metadata only for recognized editor sections.
		typeIsMetadata := false
		hasCoordinateKeys := RegExMatch(keys, "im)^(x|y|xmin|xmax|ymin|ymax)=")
		hasHotkeyKey := RegExMatch(keys, "im)^hotkey=")
		IniRead, sectionType, %ConfigPath%, %section%, type, ERROR
		if (sectionType != "ERROR")
		{
			sectionType := Trim(sectionType)
			StringLower, sectionTypeLower, sectionType
			if (sectionTypeLower = "color" || sectionTypeLower = "coordinate" || sectionTypeLower = "hotkey")
				typeIsMetadata := true
			else if (hasCoordinateKeys || hasHotkeyKey)
			{
				ConfigSemanticErrorMessage(file, section, "type", "This editor section requires type=coordinate or type=hotkey. Found: " sectionType)
				return true
			}
		}
		else
			sectionTypeLower := ""

		; Validate dependency metadata and skip dependent sections while their parent option is disabled.
		IniRead, depends, %ConfigPath%, %section%, depends, ERROR
		if (depends != "ERROR" && Trim(depends) != "")
		{
			depends := Trim(depends)
			IniRead, dependsKeys, %ConfigPath%, %depends%
			if (dependsKeys = "ERROR")
			{
				ConfigSemanticErrorMessage(file, section, "depends", "Referenced section does not exist: " depends)
				return true
			}

			IniRead, dependsOption, %ConfigPath%, %depends%, option, true
			StringLower, dependsOption, dependsOption
			if (dependsOption = "false")
				continue
		}

		if (optionLower = "false")
			continue

		; Determine whether this section is a coordinate section.
		configType := typeIsMetadata ? GetConfigType(file, section) : ""
		if (configType = "coordinate")
		{

			; Read all possible coordinate values.
			IniRead, x, %ConfigPath%, %section%, x, ERROR
			IniRead, y, %ConfigPath%, %section%, y, ERROR
			IniRead, xmin, %ConfigPath%, %section%, xmin, ERROR
			IniRead, xmax, %ConfigPath%, %section%, xmax, ERROR
			IniRead, ymin, %ConfigPath%, %section%, ymin, ERROR
			IniRead, ymax, %ConfigPath%, %section%, ymax, ERROR

			; Determine which coordinate format is being used.
			;
			; If x or y exists, this is treated as a point coordinate.
			hasPointCoordinates := (x != "ERROR" || y != "ERROR")

			; If any rectangle coordinate exists, this is treated as a rectangle coordinate.
			hasRectangleCoordinates := (xmin != "ERROR" || xmax != "ERROR" || ymin != "ERROR" || ymax != "ERROR")
			if (hasPointCoordinates)
			{
				missingCoordinates := ""
				if (x = "ERROR" || Trim(x) = "")
					missingCoordinates .= "x`n"
				if (y = "ERROR" || Trim(y) = "")
					missingCoordinates .= "y`n"
				if (missingCoordinates != "")
				{
					missingCoordinates := RTrim(missingCoordinates, "`n")
					ConfigErrorMessage(file, section, missingCoordinates)
					return true
				}

				if !LLARS_IsNumericConfigValue(x)
				{
					ConfigSemanticErrorMessage(file, section, "x", "Coordinate values must be numeric. Found: " x)
					return true
				}
				if !LLARS_IsNumericConfigValue(y)
				{
					ConfigSemanticErrorMessage(file, section, "y", "Coordinate values must be numeric. Found: " y)
					return true
				}
			}
			else if (hasRectangleCoordinates)
			{
				missingCoordinates := ""
				if (xmin = "ERROR" || Trim(xmin) = "")
					missingCoordinates .= "xmin`n"
				if (xmax = "ERROR" || Trim(xmax) = "")
					missingCoordinates .= "xmax`n"
				if (ymin = "ERROR" || Trim(ymin) = "")
					missingCoordinates .= "ymin`n"
				if (ymax = "ERROR" || Trim(ymax) = "")
					missingCoordinates .= "ymax`n"
				if (missingCoordinates != "")
				{
					missingCoordinates := RTrim(missingCoordinates, "`n")
					ConfigErrorMessage(file, section, missingCoordinates)
					return true
				}

				if !LLARS_IsNumericConfigValue(xmin)
				{
					ConfigSemanticErrorMessage(file, section, "xmin", "Coordinate values must be numeric. Found: " xmin)
					return true
				}
				if !LLARS_IsNumericConfigValue(xmax)
				{
					ConfigSemanticErrorMessage(file, section, "xmax", "Coordinate values must be numeric. Found: " xmax)
					return true
				}
				if !LLARS_IsNumericConfigValue(ymin)
				{
					ConfigSemanticErrorMessage(file, section, "ymin", "Coordinate values must be numeric. Found: " ymin)
					return true
				}
				if !LLARS_IsNumericConfigValue(ymax)
				{
					ConfigSemanticErrorMessage(file, section, "ymax", "Coordinate values must be numeric. Found: " ymax)
					return true
				}
				if ((xmin + 0) > (xmax + 0))
				{
					ConfigSemanticErrorMessage(file, section, "xmin / xmax", "xmin cannot be greater than xmax.")
					return true
				}
				if ((ymin + 0) > (ymax + 0))
				{
					ConfigSemanticErrorMessage(file, section, "ymin / ymax", "ymin cannot be greater than ymax.")
					return true
				}
			}
			else
			{

				; No coordinate keys exist at all.
				ConfigErrorMessage(file, section, "coordinates")
				return true
			}

		}

		Loop, Parse, keys, `n, `r
		{
			line := A_LoopField
			equalsPos := InStr(line, "=")
			if (!equalsPos)
				continue
			key := Trim(SubStr(line, 1, equalsPos - 1))
			value := Trim(SubStr(line, equalsPos + 1))
			if (key = "option" || key = "depends")
				continue
			if (key = "type" && typeIsMetadata)
				continue
			if (value = "")
			{
				; Script Selector Favorites/Recent are optional preference lists and may be empty.
				if (ConfigPath = LLARS_CONFIG_FILE && section = "Script Selector" && (key = "favorites" || key = "recent"))
					continue
				ConfigErrorMessage(file, section, key)
				return true
			}
		}

		; Validate hotkey sections after the blank-value pass.
		if (configType = "hotkey")
		{
			IniRead, hotkeyValue, %ConfigPath%, %section%, hotkey, ERROR
			if (hotkeyValue = "ERROR")
			{
				ConfigErrorMessage(file, section, "hotkey")
				return true
			}
			if !LLARS_IsValidConfigHotkey(hotkeyValue)
			{
				ConfigSemanticErrorMessage(file, section, "hotkey", "Invalid AutoHotkey key name or modifier combination. Found: " hotkeyValue)
				return true
			}
		}

		; Validate color sections using the same 0xRRGGBB format expected by the LLARS color editor.
		if (configType = "color")
		{
			colorKey := LLARS_GetColorKey(ConfigPath, section)
			IniRead, colorValue, %ConfigPath%, %section%, %colorKey%, ERROR
			if (colorValue = "ERROR" || !RegExMatch(Trim(colorValue), "i)^0x[0-9A-F]{6}$"))
			{
				ConfigSemanticErrorMessage(file, section, colorKey, "Colors must use 0xRRGGBB format. Found: " colorValue)
				return true
			}
		}

		; min/max pairs are used throughout LLARS for sleeps, counts, scrolling, offsets, and other random ranges.
		IniRead, minValue, %ConfigPath%, %section%, min, ERROR
		IniRead, maxValue, %ConfigPath%, %section%, max, ERROR
		if (minValue != "ERROR" || maxValue != "ERROR")
		{
			if (minValue = "ERROR" || maxValue = "ERROR")
			{
				ConfigSemanticErrorMessage(file, section, "min / max", "Both min and max must exist when either one is used.")
				return true
			}
			if !LLARS_IsNumericConfigValue(minValue)
			{
				ConfigSemanticErrorMessage(file, section, "min", "Range values must be numeric. Found: " minValue)
				return true
			}
			if !LLARS_IsNumericConfigValue(maxValue)
			{
				ConfigSemanticErrorMessage(file, section, "max", "Range values must be numeric. Found: " maxValue)
				return true
			}
			if ((minValue + 0) > (maxValue + 0))
			{
				ConfigSemanticErrorMessage(file, section, "min / max", "min cannot be greater than max.")
				return true
			}
		}

		; Offset-style ranges use minx/maxx and miny/maxy.
		IniRead, minxValue, %ConfigPath%, %section%, minx, ERROR
		IniRead, maxxValue, %ConfigPath%, %section%, maxx, ERROR
		if (minxValue != "ERROR" || maxxValue != "ERROR")
		{
			if (minxValue = "ERROR" || maxxValue = "ERROR" || !LLARS_IsNumericConfigValue(minxValue) || !LLARS_IsNumericConfigValue(maxxValue))
			{
				ConfigSemanticErrorMessage(file, section, "minx / maxx", "Both values must exist and be numeric.")
				return true
			}
			if ((minxValue + 0) > (maxxValue + 0))
			{
				ConfigSemanticErrorMessage(file, section, "minx / maxx", "minx cannot be greater than maxx.")
				return true
			}
		}

		IniRead, minyValue, %ConfigPath%, %section%, miny, ERROR
		IniRead, maxyValue, %ConfigPath%, %section%, maxy, ERROR
		if (minyValue != "ERROR" || maxyValue != "ERROR")
		{
			if (minyValue = "ERROR" || maxyValue = "ERROR" || !LLARS_IsNumericConfigValue(minyValue) || !LLARS_IsNumericConfigValue(maxyValue))
			{
				ConfigSemanticErrorMessage(file, section, "miny / maxy", "Both values must exist and be numeric.")
				return true
			}
			if ((minyValue + 0) > (maxyValue + 0))
			{
				ConfigSemanticErrorMessage(file, section, "miny / maxy", "miny cannot be greater than maxy.")
				return true
			}
		}

		; Script-specific hotkey keys such as bank hotkey and toolbar hotkey use the same AutoHotkey syntax as typed hotkey sections.
		Loop, Parse, keys, `n, `r
		{
			line := A_LoopField
			equalsPos := InStr(line, "=")
			if (!equalsPos)
				continue
			key := Trim(SubStr(line, 1, equalsPos - 1))
			value := Trim(SubStr(line, equalsPos + 1))
			StringLower, keyLower, key
			if (InStr(keyLower, "hotkey") && keyLower != "hotkey" && value != "")
			{
				if !LLARS_IsValidConfigHotkey(value)
				{
					ConfigSemanticErrorMessage(file, section, key, "Invalid AutoHotkey key name or modifier combination. Found: " value)
					return true
				}
			}
		}

		; Portable renewal counts must be positive whole numbers when enabled.
		IniRead, portablesValue, %ConfigPath%, %section%, portables, ERROR
		if (portablesValue != "ERROR" && Trim(portablesValue) != "")
		{
			if !RegExMatch(Trim(portablesValue), "^\d+$") || (portablesValue + 0) < 1
			{
				ConfigSemanticErrorMessage(file, section, "portables", "Portables must be a positive whole number. Found: " portablesValue)
				return true
			}
		}

		; Known boolean fields outside the option metadata use true/false.
		IniRead, scrollValue, %ConfigPath%, %section%, scroll, ERROR
		if (scrollValue != "ERROR" && Trim(scrollValue) != "")
		{
			scrollValue := Trim(scrollValue)
			StringLower, scrollLower, scrollValue
			if (scrollLower != "true" && scrollLower != "false")
			{
				ConfigSemanticErrorMessage(file, section, "scroll", "Expected true or false. Found: " scrollValue)
				return true
			}
		}

		; Percentage-style chance values must stay within 0-100.
		IniRead, chanceValue, %ConfigPath%, %section%, chance, ERROR
		if (chanceValue != "ERROR")
		{
			if !LLARS_IsNumericConfigValue(chanceValue)
			{
				ConfigSemanticErrorMessage(file, section, "chance", "Chance must be numeric and between 0 and 100. Found: " chanceValue)
				return true
			}
			if ((chanceValue + 0) < 0 || (chanceValue + 0) > 100)
			{
				ConfigSemanticErrorMessage(file, section, "chance", "Chance must be between 0 and 100. Found: " chanceValue)
				return true
			}
		}
	}

	return false
}

; Finds the key used to store a color value inside a color section.
; Supports both section-name keys and named keys such as red=0x5D1616.
LLARS_GetColorKey(file, section)
{
	IniRead, keys, %file%, %section%
	candidateKey := ""
	candidateCount := 0

	Loop, Parse, keys, `n, `r
	{
		line := Trim(A_LoopField)
		if (line = "")
			continue

		equalsPos := InStr(line, "=")
		if (!equalsPos)
			continue

		key := Trim(SubStr(line, 1, equalsPos - 1))
		color := Trim(SubStr(line, equalsPos + 1))
		if (key = "option" || key = "type" || key = "depends" || key = "coordinate" || key = "action")
			continue

		candidateKey := key
		candidateCount++

		if (key = section)
			return key

		if RegExMatch(color, "i)^0x[0-9A-F]{6}$")
			return key
	}

	; A typed color section with exactly one non-metadata key keeps that same key even after its value is reset to blank.
	if (candidateCount = 1)
		return candidateKey

	return section
}

; Returns true when a typed editor section contains a resettable saved value.
LLARS_ConfigItemHasResettableValue(file, section, configType)
{
	if (GetConfigType(file, section) != configType)
		return false

	if (configType = "hotkey")
	{
		IniRead, value, %file%, %section%, hotkey, ERROR
		return (value != "ERROR" && Trim(value) != "")
	}

	if (configType = "coordinate")
	{
		coordinateKeys := "x|y|xmin|xmax|ymin|ymax"
		Loop, Parse, coordinateKeys, |
		{
			key := A_LoopField
			IniRead, value, %file%, %section%, %key%, ERROR
			if (value != "ERROR" && Trim(value) != "")
				return true
		}
		return false
	}

	if (configType = "color")
	{
		colorKey := LLARS_GetColorKey(file, section)
		IniRead, value, %file%, %section%, %colorKey%, ERROR
		return (value != "ERROR" && Trim(value) != "")
	}

	return false
}

; Clears only the framework-owned value(s) for one typed editor section.
LLARS_ResetConfigItem(file, section, configType)
{
	if (GetConfigType(file, section) != configType)
		return false

	blank := ""
	changed := false

	if (configType = "hotkey")
	{
		IniRead, value, %file%, %section%, hotkey, ERROR
		if (value = "ERROR")
			return false

		IniWrite, %blank%, %file%, %section%, hotkey
		return true
	}

	if (configType = "coordinate")
	{
		coordinateKeys := "x|y|xmin|xmax|ymin|ymax"
		Loop, Parse, coordinateKeys, |
		{
			key := A_LoopField
			IniRead, value, %file%, %section%, %key%, ERROR
			if (value = "ERROR")
				continue

			IniWrite, %blank%, %file%, %section%, %key%
			changed := true
		}
		return changed
	}

	if (configType = "color")
	{
		colorKey := LLARS_GetColorKey(file, section)
		IniRead, value, %file%, %section%, %colorKey%, ERROR
		if (value = "ERROR")
			return false

		IniWrite, %blank%, %file%, %section%, %colorKey%
		return true
	}

	return false
}

; Returns color, coordinate, or hotkey for recognized editor sections.
GetConfigType(file, section)
{
	section := LLARS_NormalizeConfigSectionName(section)

	; Read the type value.
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

; Formats framework events for the Developer Mode console.
LLARS_DeveloperAntiAFKAction(Event, Details := "")
{
	global SleepAmount

	eventUpper := Event
	StringUpper, eventUpper, eventUpper

	detailText := Trim(Details)
	rangeText := ""
	actualValue := ""

	if RegExMatch(detailText, "i)(\d+)\D+(?:to|and|-)\D*(\d+)", timerRange)
		rangeText := timerRange1 . "-" . timerRange2 . " ms"
	else if RegExMatch(detailText, "i)(\d+)\s*-\s*(\d+)", timerRange)
		rangeText := timerRange1 . "-" . timerRange2 . " ms"

	if (rangeText != "")
	{
		rangeEndPos := InStr(detailText, timerRange2, false, 1)
		if (rangeEndPos)
		{
			remainingDetails := SubStr(detailText, rangeEndPos + StrLen(timerRange2))
			if RegExMatch(remainingDetails, "(\d+)", actualTimer)
				actualValue := actualTimer1
		}
	}

	if (actualValue = "" && SleepAmount != "")
		actualValue := SleepAmount

	if (InStr(eventUpper, "TIMER"))
	{
		if (rangeText != "" && actualValue != "")
			LLARS_DeveloperAction("Anti-AFK Timer Set || " . rangeText . " || " . actualValue . " ms")
		else if (rangeText != "")
			LLARS_DeveloperAction("Anti-AFK Timer Set || " . rangeText)
		else if RegExMatch(detailText, "i)(\d+)\s*ms", timerValue)
			LLARS_DeveloperAction("Anti-AFK Timer Set || " . timerValue1 . " ms")
		else
			LLARS_DeveloperAction("Anti-AFK Timer Set")
		return
	}

	if (InStr(eventUpper, "TRIGGER"))
	{
		LLARS_DeveloperAction("Anti-AFK Triggered")
		return
	}

	if (InStr(eventUpper, "MOVE") || InStr(eventUpper, "MOUSE"))
	{
		LLARS_DeveloperAction("Mouse Moved")
		return
	}

	if (InStr(eventUpper, "CLICK"))
	{
		LLARS_DeveloperAction("Mouse Clicked")
		return
	}

	if (InStr(eventUpper, "KEY") || InStr(eventUpper, "HOTKEY"))
	{
		if RegExMatch(detailText, "i)(?:key|hotkey)\s*[=:|-]?\s*([^\s|,;]+)", keyValue)
			LLARS_DeveloperAction("Key Pressed || " . keyValue1)
		else
			LLARS_DeveloperAction("Key Pressed")
		return
	}

	if (InStr(detailText, "Mouse moved"))
	{
		LLARS_DeveloperAction("Mouse Moved")
		return
	}

	if (InStr(detailText, "Mouse clicked"))
	{
		LLARS_DeveloperAction("Mouse Clicked")
		return
	}

	if (detailText != "")
	{
		StringReplace, detailText, detailText, ANTI-AFK, , All
		StringReplace, detailText, detailText, Anti-AFK, , All
		detailText := Trim(detailText, " `t-|:")
		if (StrLen(detailText) > 60)
			detailText := SubStr(detailText, 1, 57) . "..."
	}

	if (detailText != "")
		LLARS_DeveloperAction(detailText)
	else
		LLARS_DeveloperAction("Anti-AFK")
}

LLARS_DeveloperLoggedSleepAction(Event, Details := "")
{
	global SleepAmount
	global LLARS_SCRIPT_DIR, LLARS_CONFIG_FILE
	global LLARS_DeveloperLastSleepValue, LLARS_DeveloperLastSleepName

	eventText := Trim(Event)
	detailText := Trim(Details)

	if LLARS_DeveloperStatusOnly(eventText, detailText)
		return

	actualValue := ""
	timerName := ""
	timerMin := ""
	timerMax := ""

	if RegExMatch(detailText, "i)(\d+)\s*ms", loggedSleepValue)
		actualValue := loggedSleepValue1
	else if (SleepAmount != "")
		actualValue := SleepAmount

	if RegExMatch(detailText, "i)^\s*([^:|]+?)\s+(?:completed|triggered|started|set)\s*[:|-]?", loggedSleepName)
		timerName := Trim(loggedSleepName1)

	if (timerName = "" && InStr(eventText, "SLEEP"))
	{
		timerName := RegExReplace(eventText, "i)\s+WAIT$")
		timerName := Trim(timerName)
		StringLower, timerName, timerName
		StringUpper, timerName, timerName, T
	}

	if (eventText = "RANDOM SLEEP")
	{
		timerName := "Random Sleep"
		IniRead, timerMin, %LLARS_CONFIG_FILE%, Random Sleep, min, ERROR
		IniRead, timerMax, %LLARS_CONFIG_FILE%, Random Sleep, max, ERROR
		if (timerMin = "ERROR" || timerMax = "ERROR")
		{
			timerMin := ""
			timerMax := ""
		}
	}
	else if (actualValue != "" && LLARS_DeveloperTimerInfo(actualValue, configuredName, configuredMin, configuredMax))
	{
		if (timerName = "" || timerName = "Wait" || timerName = "Sleep")
			timerName := configuredName

		timerMin := configuredMin
		timerMax := configuredMax
	}

	if (timerName = "")
		timerName := "Sleep"

	; Suppress the matching follow-up after a framework sleep finishes.
	if (actualValue != "" && actualValue = LLARS_DeveloperLastSleepValue)
	{
		if (LLARS_DeveloperLastSleepName = timerName || LLARS_DeveloperLastSleepName = "Sleep" || timerName = "Sleep")
		{
			LLARS_DeveloperLastSleepValue := ""
			LLARS_DeveloperLastSleepName := ""
			return
		}
	}

	if (actualValue != "" && timerMin != "" && timerMax != "")
		LLARS_DeveloperAction(timerName . " || " . timerMin . "-" . timerMax . " ms || " . actualValue . " ms")
	else if (actualValue != "")
		LLARS_DeveloperAction(timerName . " || " . actualValue . " ms")
	else
		LLARS_DeveloperAction(timerName)
}

LLARS_DeveloperScriptTimerAction(Details)
{
	global SleepAmount

	detailText := Trim(Details)
	if (detailText = "")
		return

	; Recent Framework Actions is for actions that actually occurred.
	if RegExMatch(detailText, "i)\b(disabled|stopped|turned off|not enabled|inactive|skipped)\b")
		return

	; The run-start message is a duration, not a named action timer.
	if RegExMatch(detailText, "i)^Timer\s+set\s+to\s+(\d+)\s+minutes?\b", runTimerMatch)
	{
		LLARS_DeveloperAction("Run Timer || " . runTimerMatch1 . " min")
		return
	}

	timerName := detailText
	timerName := RegExReplace(timerName, "i)\s+(timer\s+)?(triggered|rescheduled|scheduled|set|completed|started|fired).*$")
	timerName := Trim(timerName, " `t-|:")

	if (timerName = "")
		timerName := "Timer"

	if (SubStr(timerName, 1, 1) ~= "[a-z]")
		StringUpper, timerName, timerName, T

	if LLARS_DeveloperTimerInfo(SleepAmount, configuredName, timerMin, timerMax)
	{
		if (InStr(configuredName, timerName) || InStr(timerName, configuredName))
			timerName := configuredName
	}

	if (SleepAmount != "" && LLARS_DeveloperTimerInfo(SleepAmount, configuredName, timerMin, timerMax))
		LLARS_DeveloperAction(timerName . " || " . timerMin . "-" . timerMax . " ms || " . SleepAmount . " ms")
	else
		LLARS_DeveloperAction(timerName)
}

LLARS_DeveloperColorConfigAction(Details)
{
	detailText := Trim(Details)
	colorSection := detailText
	colorValue := ""

	pipePos := InStr(detailText, "|")
	if (pipePos)
		colorSection := Trim(SubStr(detailText, 1, pipePos - 1))

	if RegExMatch(detailText, "i)(0x[0-9A-F]{6})", developerColorValue)
		colorValue := developerColorValue1

	if (colorSection = "")
		colorSection := "Color"

	if (colorValue != "")
		LLARS_DeveloperAction("Color Config || " . colorSection . " || " . colorValue, false)
	else
		LLARS_DeveloperAction("Color Config || " . colorSection, false)
}

LLARS_DeveloperStatusOnly(Event, Details := "")
{
	statusText := Trim(Event . " " . Details)

	if RegExMatch(statusText, "i)\b(disabled|not enabled|inactive|turned off|stopped|skipped)\b")
		return true

	return false
}


; Returns the active typed coordinate section containing a click target.
LLARS_DeveloperClickTarget(x, y)
{
	global LLARS_SCRIPT_DIR

	ConfigPath := LLARS_SCRIPT_DIR . "\Config.ini"
	if !FileExist(ConfigPath)
		return ""

	sections := LLARS_ConfigSectionList(ConfigPath)
	if (sections = "ERROR")
		return ""

	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		if (GetConfigType(ConfigPath, section) != "coordinate")
			continue

		if !LLARS_ConfigSectionEnabled(ConfigPath, section)
			continue

		IniRead, configX, %ConfigPath%, %section%, x, ERROR
		IniRead, configY, %ConfigPath%, %section%, y, ERROR
		if (configX != "ERROR" && configY != "ERROR")
		{
			configX := Trim(configX)
			configY := Trim(configY)
			if (configX != "" && configY != "" && x = configX && y = configY)
				return section
		}

		IniRead, xmin, %ConfigPath%, %section%, xmin, ERROR
		IniRead, xmax, %ConfigPath%, %section%, xmax, ERROR
		IniRead, ymin, %ConfigPath%, %section%, ymin, ERROR
		IniRead, ymax, %ConfigPath%, %section%, ymax, ERROR

		if (xmin = "ERROR" || xmax = "ERROR" || ymin = "ERROR" || ymax = "ERROR")
			continue

		xmin := Trim(xmin)
		xmax := Trim(xmax)
		ymin := Trim(ymin)
		ymax := Trim(ymax)
		if (xmin = "" || xmax = "" || ymin = "" || ymax = "")
			continue

		if (x >= xmin && x <= xmax && y >= ymin && y <= ymax)
			return section
	}

	return ""
}

; Identifies RuneScape by known process name, with exact-title fallback.
LLARS_IsRuneScapeWindow(hwnd)
{
	if (!hwnd)
		return false

	WinGet, processName, ProcessName, ahk_id %hwnd%
	StringLower, processName, processName
	if processName in runescape.exe,rs2client.exe
		return true

	WinGetTitle, windowTitle, ahk_id %hwnd%
	return (windowTitle = "RuneScape")
}

; Returns true only when the active window is the RuneScape client.
LLARS_IsRuneScapeActive()
{
	return LLARS_IsRuneScapeWindow(WinExist("A"))
}

; Finds RuneScape, preferring the active client before other visible matches.
LLARS_FindRuneScapeWindow()
{
	activeHwnd := WinExist("A")
	if (LLARS_IsRuneScapeWindow(activeHwnd))
		return activeHwnd

	WinGet, titleHwnd, ID, RuneScape
	if (titleHwnd && LLARS_IsRuneScapeWindow(titleHwnd))
		return titleHwnd

	WinGet, windowList, List
	Loop, %windowList%
	{
		hwnd := windowList%A_Index%
		if (!DllCall("IsWindowVisible", "Ptr", hwnd))
			continue

		if (LLARS_IsRuneScapeWindow(hwnd))
			return hwnd
	}

	return 0
}

; Activates RuneScape only after resolving a window through the shared validator.
LLARS_ActivateValidatedRuneScape()
{
	runeScapeHwnd := LLARS_FindRuneScapeWindow()
	if (!runeScapeHwnd)
		return 0

	WinActivate, ahk_id %runeScapeHwnd%
	return runeScapeHwnd
}

; Returns the RuneScape HWND NaturalClick may use, reclaiming run focus if needed.
LLARS_ActivateRuneScapeForNaturalClick()
{
	global LLARS_RUNNING

	if (LLARS_RUNNING && IsFunc("LLARS_WaitForRuneScape"))
	{
		if !LLARS_WaitForRuneScape("NaturalClick")
			return 0
	}

	runeScapeHwnd := WinExist("A")
	if !LLARS_IsRuneScapeWindow(runeScapeHwnd)
	{
		return 0
	}

	return runeScapeHwnd
}

; Guards NaturalClick focus and reclaims the run client before a retry.
LLARS_NaturalClickRuneScapeGuard(reason, runeScapeHwnd := "")
{
	global LLARS_NaturalClickFocusLost, LLARS_RUNNING

	activeHwnd := DllCall("GetForegroundWindow", "Ptr")
	if (runeScapeHwnd != "")
	{
		if (activeHwnd = runeScapeHwnd)
			return true
	}
	else if (LLARS_IsRuneScapeWindow(activeHwnd))
	{
		return true
	}

	LLARS_NaturalClickFocusLost := true
	if (LLARS_RUNNING && IsFunc("LLARS_WaitForRuneScape"))
		LLARS_WaitForRuneScape("NaturalClick")
	return false
}

; Records an actual NaturalClick and includes the matching Config.ini
; coordinate section name whenever the target belongs to one.
LLARS_DeveloperNaturalClick(x, y, button, clickTarget := "")
{
	if (clickTarget = "")
		clickTarget := LLARS_DeveloperClickTarget(x, y)

	button := Trim(button)
	StringLower, button, button
	if (button != "right")
		button := "left"

	details := "NaturalClick || " . button
	if (clickTarget != "")
		details .= " || " . clickTarget
	details .= " || (" . x . ", " . y . ")"
	LLARS_DeveloperAction(details)
}

; ================================================================
; |     HUMAN RANDOMNESS     -     HUMAN RANDOMNESS              |
; ================================================================
; Uses Windows' system RNG when available instead of relying on AutoHotkey's process-local pseudo-random stream.
LLARS_RandomUInt()
{
	VarSetCapacity(randomBytes, 4, 0)
	status := DllCall("bcrypt\BCryptGenRandom"
		, "Ptr", 0
		, "Ptr", &randomBytes
		, "UInt", 4
		, "UInt", 0x00000002
		, "UInt")

	if (status = 0)
		return NumGet(randomBytes, 0, "UInt")

	Random, fallbackValue, 0, 2147483647
	return (fallbackValue * 2) + Mod(A_TickCount, 2)
}

; Returns a high-resolution random value in [0, 1).
LLARS_RandomUnit()
{
	return LLARS_RandomUInt() / 4294967296.0
}

; Remembers a short history per stream and avoids immediately recycling the
; exact same integer values when the available range is wide enough.
LLARS_HumanRememberedInt(value, minimum, maximum, stream := "", avoidRecent := 3)
{
	static histories := {}

	minimum := Round(minimum)
	maximum := Round(maximum)
	value := Round(value)

	if (maximum < minimum)
	{
		swap := minimum
		minimum := maximum
		maximum := swap
	}

	rangeSize := maximum - minimum + 1
	if (rangeSize <= 1 || avoidRecent <= 0)
		return value

	; Very small ranges naturally repeat.
	if (rangeSize <= 8)
		return value
	if (rangeSize <= 20 && avoidRecent > 1)
		avoidRecent := 1
	if (avoidRecent >= rangeSize)
		avoidRecent := rangeSize - 1

	if (stream = "")
		stream := minimum . ":" . maximum

	if !histories.HasKey(stream)
		histories[stream] := []

	history := histories[stream]
	attempts := 0
	Loop
	{
		repeated := false
		for _, previousValue in history
		{
			if (value = previousValue)
			{
				repeated := true
				break
			}
		}

		if (!repeated || attempts >= 10)
			break

		value := minimum + Floor(LLARS_RandomUnit() * rangeSize)
		attempts++
	}

	while (history.Length() >= avoidRecent)
		history.RemoveAt(1)

	history.Push(value)
	histories[stream] := history
	return value
}

; Uniform integer selection backed by the system RNG, with optional recent-value avoidance.
LLARS_HumanRandomInt(minimum, maximum, stream := "", avoidRecent := 3)
{
	minimum := Round(minimum)
	maximum := Round(maximum)

	if (maximum < minimum)
	{
		swap := minimum
		minimum := maximum
		maximum := swap
	}

	rangeSize := maximum - minimum + 1
	if (rangeSize <= 1)
		return minimum

	value := minimum + Floor(LLARS_RandomUnit() * rangeSize)
	return LLARS_HumanRememberedInt(value, minimum, maximum, stream, avoidRecent)
}

 ; Uses averaged random samples for a soft center instead of uniform timing.
LLARS_HumanTiming(minimum, maximum, stream := "", longChance := 0, longMinimum := "", longMaximum := "")
{
	minimum := Round(minimum)
	maximum := Round(maximum)

	if (maximum < minimum)
	{
		swap := minimum
		minimum := maximum
		maximum := swap
	}

	if (longChance > 0 && longMinimum != "" && longMaximum != "" && LLARS_RandomUnit() < longChance)
		return LLARS_HumanRandomInt(longMinimum, longMaximum, stream . ".Long", 4)

	shape := (LLARS_RandomUnit() + LLARS_RandomUnit() + LLARS_RandomUnit() + LLARS_RandomUnit()) / 4.0
	value := minimum + Round(shape * (maximum - minimum))
	return LLARS_HumanRememberedInt(value, minimum, maximum, stream, 4)
}

 ; Avoids overusing neat 5 ms endings while preserving the configured range.
LLARS_HumanizeTimingEnding(value, minimum, maximum, stream := "")
{
	value := Round(value)
	minimum := Round(minimum)
	maximum := Round(maximum)

	if (Mod(value, 5) != 0 || LLARS_RandomUnit() < 0.01)
		return value

	offset := LLARS_HumanRandomInt(1, 4, stream . ".FineEnding", 2)
	if (LLARS_RandomUnit() < 0.5)
		offset := -offset

	adjusted := value + offset
	if (adjusted < minimum || adjusted > maximum)
		adjusted := value - offset

	if (adjusted < minimum || adjusted > maximum)
		return value

	return adjusted
}

; Prevents an immediately repeated requested timing value while preserving the configured range.
; This operates on the requested LLARS timing value; Windows scheduler granularity can
; still make two measured elapsed durations display the same millisecond afterward.
LLARS_HumanDistinctTiming(value, minimum, maximum, stream := "")
{
	static lastValues := {}
	value := Round(value)
	minimum := Round(minimum)
	maximum := Round(maximum)

	if (maximum < minimum)
	{
		swap := minimum
		minimum := maximum
		maximum := swap
	}

	if (stream = "" || maximum <= minimum)
		return value

	if (lastValues.HasKey(stream) && value = lastValues[stream])
	{
		candidate := LLARS_HumanRandomInt(minimum, maximum, stream . ".Distinct", 4)
		if (candidate = lastValues[stream])
		{
			candidate := (value < maximum) ? value + 1 : value - 1
			if (candidate < minimum)
				candidate := minimum
		}
		value := candidate
	}

	lastValues[stream] := value
	return value
}

; Performs one physical mouse-button press with a varied down/up hold time.
LLARS_HumanMouseClick(button := "left")
{
	button := Trim(button)
	StringLower, button, button

	holdTime := LLARS_HumanTiming(38, 108, "MouseClick.Hold." . button, 0.045, 118, 176)
	holdMinimum := (holdTime >= 118) ? 118 : 38
	holdMaximum := (holdTime >= 118) ? 176 : 108
	holdTime := LLARS_HumanizeTimingEnding(holdTime, holdMinimum, holdMaximum, "MouseClick.Hold." . button)
	holdTime := LLARS_HumanDistinctTiming(holdTime, holdMinimum, holdMaximum, "MouseClick.Hold.Final." . button)

	wasCritical := A_IsCritical
	if (!wasCritical)
		Critical, On

	DllCall("QueryPerformanceFrequency", "Int64*", mouseHoldPerformanceFrequency)
	if !LLARS_InputMouseButton(button, 1)
	{
		if (!wasCritical)
			Critical, Off
		return 0
	}
	DllCall("QueryPerformanceCounter", "Int64*", mouseHoldStartCounter)
	Sleep, %holdTime%
	DllCall("QueryPerformanceCounter", "Int64*", mouseHoldEndCounter)
	LLARS_InputMouseButton(button, 0)
	if (!wasCritical)
		Critical, Off

	actualHoldTime := Round(((mouseHoldEndCounter - mouseHoldStartCounter) * 1000.0) / mouseHoldPerformanceFrequency)
	displayButton := (button = "right") ? "Right" : (button = "middle") ? "Middle" : (button = "xbutton1") ? "XButton1" : (button = "xbutton2") ? "XButton2" : "Left"
	transportName := IsFunc("LLARS_AHI_TransportName") ? LLARS_AHI_TransportName("mouse") : "Standard AutoHotkey"
	LLARS_DeveloperAction(displayButton . " Click || Hold=" . actualHoldTime . " ms || " . transportName)
	return actualHoldTime
}

; Developer coordinate overlays are debugger-only.
LLARS_DeveloperCoordinateOverlayShowSafe(x, y, section := "", scope := "script")
{
	if !IsFunc("LLARS_DeveloperCoordinateOverlay")
		return false

	try
		return LLARS_DeveloperCoordinateOverlay(x, y, section, scope)
	catch error
		return false
}

LLARS_DeveloperCoordinateOverlayHideSafe(delay := 0)
{
	if !IsFunc("LLARS_DeveloperCoordinateOverlayHide")
		return false

	try
	{
		LLARS_DeveloperCoordinateOverlayHide(delay)
		return true
	}
	catch error
		return false
}

; ================================================================
; |     MOUSE     -     MOUSE     -     MOUSE     -     MOUSE    |
; ================================================================

; Builds one distance-aware movement profile with fast travel and slower correction.
LLARS_NaturalMovementProfile(distance, stream := "NaturalClick")
{
	if (distance < 0)
		distance := 0

	; Transport speed rises with distance without making long reaches too fast.
	preferredBallisticSpeed := 600 + (22 * Sqrt(distance))

	; Short corrections can still be brisk, but bias them slightly away from the fastest tail.
	distanceFactor := distance / 1800.0
	if (distanceFactor < 0)
		distanceFactor := 0
	if (distanceFactor > 1)
		distanceFactor := 1
	minimumSpeedMultiplier := 0.72
	maximumSpeedMultiplier := 1.18 - (0.24 * distanceFactor)
	speedShape := 1.12 + (1.45 * distanceFactor)
	speedRoll := LLARS_RandomUnit() ** speedShape
	speedMultiplier := minimumSpeedMultiplier + ((maximumSpeedMultiplier - minimumSpeedMultiplier) * speedRoll)
	ballisticSpeed := preferredBallisticSpeed * speedMultiplier

	; Vary travel and correction proportions so equal-distance moves do not share a pace.
	ballisticDistanceFraction := 0.89 + (LLARS_RandomUnit() * 0.06)
	ballisticTimeFraction := 0.55 + (LLARS_RandomUnit() * 0.11)
	timingJitter := 0.96 + (LLARS_RandomUnit() * 0.08)

	duration := Round((((distance * ballisticDistanceFraction) / ballisticSpeed) * 1000) / ballisticTimeFraction * timingJitter)

	; Slow medium/long reaches progressively while preserving per-call variation.
	distanceSlowdownFactor := (distance - 300) / 1500.0
	if (distanceSlowdownFactor < 0)
		distanceSlowdownFactor := 0
	if (distanceSlowdownFactor > 1)
		distanceSlowdownFactor := 1
	distanceSlowdownStrength := (0.62 * distanceSlowdownFactor) + (0.64 * (distanceSlowdownFactor ** 1.5))
	distanceSlowdownMultiplier := 1.12 + distanceSlowdownStrength
	duration := Round(duration * distanceSlowdownMultiplier)

	; Add small timing jitter so similar profiles do not end on repeated values.
	fineTimingRange := Round(duration * 0.025)
	if (fineTimingRange < 7)
		fineTimingRange := 7
	if (fineTimingRange > 43)
		fineTimingRange := 43
	fineTimingJitter := LLARS_HumanRandomInt(-fineTimingRange, fineTimingRange, stream . ".FineTiming", 10)
	duration += fineTimingJitter

	if (stream = "AntiAFKShortMove")
		durationCap := 1600
	else if (stream = "NaturalClick")
		durationCap := 3000
	else
		durationCap := 6500
	if (duration < 55)
		duration := 55
	if (duration > durationCap)
		duration := durationCap
	duration := LLARS_HumanizeTimingEnding(duration, 55, durationCap, stream . ".Movement")

	; Keep meaningful timing bounds available without forcing the selected duration into fixed buckets or rounded-looking values.
	fastestBallisticSpeed := preferredBallisticSpeed * maximumSpeedMultiplier
	slowestBallisticSpeed := preferredBallisticSpeed * minimumSpeedMultiplier
	minimumDuration := Round((((distance * 0.89) / fastestBallisticSpeed) * 1000) / 0.66 * 0.96)
	maximumDuration := Round((((distance * 0.95) / slowestBallisticSpeed) * 1000) / 0.55 * 1.04)
	minimumDuration := Round(minimumDuration * distanceSlowdownMultiplier)
	maximumDuration := Round(maximumDuration * distanceSlowdownMultiplier)
	if (minimumDuration < 55)
		minimumDuration := 55
	if (minimumDuration > durationCap)
		minimumDuration := durationCap
	if (maximumDuration > durationCap)
		maximumDuration := durationCap

	; Add enough samples to keep slower long movements visually smooth.
	stepSpacing := LLARS_HumanRandomInt(5, 9, stream . ".StepSpacing", 4)
	steps := Round(distance / stepSpacing)
	if (steps < 12)
		steps := 12
	minimumTimingSteps := Round(duration / 8)
	if (steps < minimumTimingSteps)
		steps := minimumTimingSteps
	if (steps > 820)
		steps := 820

	; Preserve the existing per-call acceleration/deceleration variation.
	timingExponentPercent := LLARS_HumanRandomInt(68, 142, stream . ".TimingCurve", 6)
	timingExponent := timingExponentPercent / 100.0

	return {duration:duration
		, minimumDuration:minimumDuration
		, maximumDuration:maximumDuration
		, steps:steps
		, timingExponent:timingExponent}
}

; Natural movement owns its cadence: block framework timers, remove MouseMove
; delay, use 1 ms timer resolution, then restore normal timing afterward.
LLARS_NaturalMovementTimingBegin()
{
	global LLARS_lhk5

	LLARS_EnableDeveloperHotkey(LLARS_lhk5)
	Thread, NoTimers, true
	SetMouseDelay, -1
	DllCall("winmm\timeBeginPeriod", "UInt", 1)
}

LLARS_NaturalMovementTimingEnd()
{
	DllCall("winmm\timeEndPeriod", "UInt", 1)
	SetMouseDelay, 10
	Thread, NoTimers, false
}

; Keeps RunCount estimates moving while natural mouse movement blocks timers.
LLARS_NaturalMovementRefreshEstimate()
{
	global LLARS_RUNNING, LLARS_SCRIPT_TYPE
	static lastUpdate := 0

	if (!LLARS_RUNNING || LLARS_SCRIPT_TYPE != "RunCount")
		return
	if ((A_TickCount - lastUpdate) < 200)
		return

	lastUpdate := A_TickCount
	if IsFunc("LLARS_UpdateEstimatedTimeNow")
		LLARS_UpdateEstimatedTimeNow()
}

; Plans an occasional slight overshoot so the existing NaturalClick path can miss
; past the true click point before a short corrective submovement returns to it.
LLARS_NaturalClickOvershootPlan(startX, startY, targetX, targetY, runeScapeHwnd)
{
	dx := targetX - startX
	dy := targetY - startY
	distance := Sqrt((dx * dx) + (dy * dy))
	if (distance < 45 || LLARS_RandomUnit() >= 0.20)
		return ""

	VarSetCapacity(clientRect, 16, 0)
	if !DllCall("GetClientRect", "Ptr", runeScapeHwnd, "Ptr", &clientRect)
		return ""
	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")
	if (clientWidth <= 2 || clientHeight <= 2)
		return ""

	unitX := dx / distance
	unitY := dy / distance
	perpX := -unitY
	perpY := unitX
	; Make the miss visible enough to read as a genuine overshoot instead of tiny endpoint jitter.
	overshootDistance := LLARS_HumanRandomInt(22, 38, "NaturalClick.OvershootDistance", 5)
	lateralOffset := LLARS_HumanRandomInt(-7, 7, "NaturalClick.OvershootLateral", 4)
	missX := Round(targetX + (unitX * overshootDistance) + (perpX * lateralOffset))
	missY := Round(targetY + (unitY * overshootDistance) + (perpY * lateralOffset))

	if (missX < 1)
		missX := 1
	if (missY < 1)
		missY := 1
	if (missX >= clientWidth)
		missX := clientWidth - 1
	if (missY >= clientHeight)
		missY := clientHeight - 1

	correctionDX := targetX - missX
	correctionDY := targetY - missY
	correctionDistance := Sqrt((correctionDX * correctionDX) + (correctionDY * correctionDY))
	if (correctionDistance < 5)
		return ""

	return {x:missX, y:missY}
}

; Corrects an overshot NaturalClick endpoint back to the exact click coordinate.
; The correction intentionally continues a few pixels in the incoming direction,
; bends around in a visible arc, then makes a slower controlled final approach.
; No click can occur at the miss point.
LLARS_NaturalClickCorrectOvershoot(missX, missY, targetX, targetY, runeScapeHwnd, runBound := false, sourceStartX := "", sourceStartY := "")
{
	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before NaturalClick overshoot correction", runeScapeHwnd))
		return -1
	if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
		return 0

	correctionDX := targetX - missX
	correctionDY := targetY - missY
	correctionDistance := Sqrt((correctionDX * correctionDX) + (correctionDY * correctionDY))
	if (correctionDistance <= 1)
	{
		LLARS_InputMouseMove(targetX, targetY, 0)
		return 1
	}

	; Preserve the incoming direction so the cursor does not instantly reverse on a
	; straight line. The first control point continues slightly past the miss before
	; the correction curves back toward the real target.
	incomingDX := missX - sourceStartX
	incomingDY := missY - sourceStartY
	incomingDistance := Sqrt((incomingDX * incomingDX) + (incomingDY * incomingDY))
	if (sourceStartX = "" || sourceStartY = "" || incomingDistance < 1)
	{
		incomingX := -correctionDX / correctionDistance
		incomingY := -correctionDY / correctionDistance
	}
	else
	{
		incomingX := incomingDX / incomingDistance
		incomingY := incomingDY / incomingDistance
	}
	correctionUnitX := correctionDX / correctionDistance
	correctionUnitY := correctionDY / correctionDistance
	perpX := -correctionUnitY
	perpY := correctionUnitX

	turnExtension := LLARS_HumanRandomInt(7, 14, "NaturalClick.OvershootCorrectionTurnExtension", 4)
	curveSign := (LLARS_RandomUnit() < 0.5) ? -1 : 1
	arcAmount := LLARS_HumanRandomInt(6, 13, "NaturalClick.OvershootCorrectionArc", 4) * curveSign
	entryArc := arcAmount * (LLARS_HumanRandomInt(35, 65, "NaturalClick.OvershootCorrectionEntryArc", 4) / 100.0)
	finalLead := LLARS_HumanRandomInt(7, 13, "NaturalClick.OvershootCorrectionFinalLead", 4)

	cp1X := missX + (incomingX * turnExtension) + (perpX * entryArc)
	cp1Y := missY + (incomingY * turnExtension) + (perpY * entryArc)
	cp2X := targetX - (correctionUnitX * finalLead) + (perpX * arcAmount)
	cp2Y := targetY - (correctionUnitY * finalLead) + (perpY * arcAmount)

	; Deliberately slower than the ballistic reach. Short corrections remain under a
	; second, but are long enough to look like visual reacquisition rather than snap-back.
	baseDuration := 220 + Round(correctionDistance * 7.5)
	durationPercent := LLARS_HumanRandomInt(90, 118, "NaturalClick.OvershootCorrectionDuration", 6)
	duration := Round(baseDuration * durationPercent / 100)
	if (duration < 340)
		duration := 340
	if (duration > 640)
		duration := 640
	duration := LLARS_HumanizeTimingEnding(duration, 340, 640, "NaturalClick.OvershootCorrection.Movement")

	rawSteps := Round(correctionDistance * 3.5)
	if (rawSteps < 80)
		rawSteps := 80
	if (rawSteps > 180)
		rawSteps := 180
	seedX := LLARS_HumanRandomInt(1, 2147483000, "NaturalClick.OvershootCorrectionNoiseSeedX", 6)
	seedY := LLARS_HumanRandomInt(1, 2147483000, "NaturalClick.OvershootCorrectionNoiseSeedY", 6)
	noiseAmount := correctionDistance * 0.035
	if (noiseAmount < 0.55)
		noiseAmount := 0.55
	if (noiseAmount > 1.65)
		noiseAmount := 1.65

	; Build the full curved path first and then traverse it by arc length, matching
	; NaturalClick's movement character instead of interpolating directly to target.
	points := []
	lengths := []
	totalLength := 0
	previousX := missX
	previousY := missY
	points.Push({x:missX, y:missY})
	lengths.Push(0)
	previousNoiseX := 0
	previousNoiseY := 0
	Loop, %rawSteps%
	{
		t := A_Index / rawSteps
		inv := 1 - t
		currentX := (inv * inv * inv * missX)
		currentX += (3 * inv * inv * t * cp1X)
		currentX += (3 * inv * t * t * cp2X)
		currentX += (t * t * t * targetX)
		currentY := (inv * inv * inv * missY)
		currentY += (3 * inv * inv * t * cp1Y)
		currentY += (3 * inv * t * t * cp2Y)
		currentY += (t * t * t * targetY)

		noiseFade := Sin(t * 3.14159265)
		if (t > 0.78)
		{
			fade := (1 - t) / 0.22
			if (fade < 0)
				fade := 0
			noiseFade *= fade
		}
		rawNoiseX := NaturalNoise(seedX, t + 7.17) * noiseAmount * noiseFade
		rawNoiseY := NaturalNoise(seedY, t + 19.41) * noiseAmount * noiseFade
		noiseX := (previousNoiseX * 0.72) + (rawNoiseX * 0.28)
		noiseY := (previousNoiseY * 0.72) + (rawNoiseY * 0.28)
		previousNoiseX := noiseX
		previousNoiseY := noiseY
		currentX += noiseX
		currentY += noiseY

		segmentDX := currentX - previousX
		segmentDY := currentY - previousY
		segmentLength := Sqrt((segmentDX * segmentDX) + (segmentDY * segmentDY))
		totalLength += segmentLength
		points.Push({x:currentX, y:currentY})
		lengths.Push(totalLength)
		previousX := currentX
		previousY := currentY
	}

	steps := Round(duration / 7)
	if (steps < 48)
		steps := 48
	if (steps > 92)
		steps := 92
	startTick := A_TickCount
	searchIndex := 2
	previousX := missX
	previousY := missY
	Loop, %steps%
	{
		if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus during NaturalClick overshoot correction", runeScapeHwnd))
			return -1
		if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
			return 0

		t := A_Index / steps
		; Blend linear progress with smoothstep so the correction retains visible
		; momentum out of the miss, then settles progressively into the true target.
		smoothT := t * t * (3 - (2 * t))
		timingT := (0.24 * t) + (0.76 * smoothT)
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
		blend := (lengthRange <= 0) ? 0 : (targetLength - prevLength) / lengthRange
		point1 := points[prevIndex]
		point2 := points[searchIndex]
		currentX := Round(point1.x + ((point2.x - point1.x) * blend))
		currentY := Round(point1.y + ((point2.y - point1.y) * blend))
		if (currentX != previousX || currentY != previousY)
		{
			LLARS_InputMouseMove(currentX, currentY, 0)
			previousX := currentX
			previousY := currentY
		}

		LLARS_NaturalMovementRefreshEstimate()
		targetElapsed := Round(duration * t)
		delay := targetElapsed - (A_TickCount - startTick)
		if (delay > 0)
		{
			if (delay > 24)
				delay := 24
			Sleep, %delay%
		}
	}

	LLARS_InputMouseMove(targetX, targetY, 0)
	LLARS_DeveloperAction("NaturalClick Overshoot Correction || (" . missX . ", " . missY . ") > (" . targetX . ", " . targetY . ") || Arc=" . Round(totalLength) . " px || " . duration . " ms")
	return 1
}

; ================================================================
; |     REDCLICK VERIFICATION     -     REDCLICK VERIFICATION    |
; ================================================================
; RedClick uses the exact NaturalClick movement/click path, but verifies that
; RuneScape drew its red world-interaction X around the intended click point.
; Use this only for interactions that normally produce that red X.
;
; FrameRecorder calibration (2026-10-13):
; - 16/16 successful world-object clicks produced the same X signature.
; - Dominant solid X color: RGB 156,9,6 (0x9C0906).
; - Solid body spans roughly 14x14 px centered on the click (-7..+6).
; - First detectable frame: ~47-79 ms after mouse-down.
; - Strong/full signature: ~125-172 ms.
; - Still detectable through ~375-438 ms.
; - Two non-world/UI clicks produced no matching signature at all.
;
; Keep the verification area deliberately tight around the click so nearby red
; scenery/UI cannot satisfy the check.
LLARS_RedClickArmPresent(centerX, centerY, signX, signY, clientWidth, clientHeight)
{
	; The recorded X occupies only the immediate ~8 px around the click.
	if (signX < 0)
	{
		x1 := centerX - 8
		x2 := centerX - 1
	}
	else
	{
		x1 := centerX
		x2 := centerX + 7
	}

	if (signY < 0)
	{
		y1 := centerY - 8
		y2 := centerY - 1
	}
	else
	{
		y1 := centerY
		y2 := centerY + 7
	}

	if (x1 < 0)
		x1 := 0
	if (y1 < 0)
		y1 := 0
	if (x2 >= clientWidth)
		x2 := clientWidth - 1
	if (y2 >= clientHeight)
		y2 := clientHeight - 1
	if (x1 > x2 || y1 > y2)
		return false

	; Calibrated against the recorded solid-core red. A small variation allows
	; minor render/anti-alias differences while remaining far tighter than the
	; generic "red" search.
	PixelSearch, redX, redY, %x1%, %y1%, %x2%, %y2%, 0x9C0906, 18, Fast RGB
	return !ErrorLevel
}

LLARS_RedClickArmMask(centerX, centerY, runeScapeHwnd)
{
	if (!runeScapeHwnd || !DllCall("IsWindow", "Ptr", runeScapeHwnd))
		return 0

	VarSetCapacity(clientRect, 16, 0)
	if !DllCall("GetClientRect", "Ptr", runeScapeHwnd, "Ptr", &clientRect)
		return 0
	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")
	if (clientWidth < 2 || clientHeight < 2)
		return 0

	mask := 0
	if LLARS_RedClickArmPresent(centerX, centerY, -1, -1, clientWidth, clientHeight)
		mask := mask | 1 ; north-west
	if LLARS_RedClickArmPresent(centerX, centerY, 1, -1, clientWidth, clientHeight)
		mask := mask | 2 ; north-east
	if LLARS_RedClickArmPresent(centerX, centerY, -1, 1, clientWidth, clientHeight)
		mask := mask | 4 ; south-west
	if LLARS_RedClickArmPresent(centerX, centerY, 1, 1, clientWidth, clientHeight)
		mask := mask | 8 ; south-east
	return mask
}

LLARS_RedClickArmCount(mask)
{
	count := 0
	Loop, 4
	{
		bit := 1 << (A_Index - 1)
		if (mask & bit)
			count++
	}
	return count
}

LLARS_RedClickMaskLooksLikeX(mask)
{
	; The capture corpus showed all four arms every time. Requiring three arms
	; keeps a little tolerance for scaling/render variance while still proving
	; both diagonal axes are present.
	if (LLARS_RedClickArmCount(mask) < 3)
		return false
	if (!(mask & 9)) ; NW / SE axis
		return false
	if (!(mask & 6)) ; NE / SW axis
		return false
	return true
}

LLARS_WaitForRedClickConfirmation(centerX, centerY, runeScapeHwnd, baselineMask := 0, timeoutMs := 520)
{
	startTick := A_TickCount
	consecutive := 0
	bestMask := 0
	bestArms := 0
	baselineLooksLikeX := LLARS_RedClickMaskLooksLikeX(baselineMask)
	baselineArms := LLARS_RedClickArmCount(baselineMask)

	Loop
	{
		if ((A_TickCount - startTick) > timeoutMs)
			break
		if (!DllCall("IsWindow", "Ptr", runeScapeHwnd) || WinExist("A") != runeScapeHwnd)
			return false

		mask := LLARS_RedClickArmMask(centerX, centerY, runeScapeHwnd)
		arms := LLARS_RedClickArmCount(mask)
		if (arms > bestArms)
		{
			bestArms := arms
			bestMask := mask
		}

		looksLikeX := LLARS_RedClickMaskLooksLikeX(mask)
		; Reject a pre-existing static red-X-like pattern. In normal use the
		; baseline is empty and the new 4-arm signature appears after the click.
		freshEvidence := !baselineLooksLikeX || (mask != baselineMask && arms >= baselineArms)

		if (looksLikeX && freshEvidence)
		{
			consecutive++
			if (consecutive >= 2)
			{
				LLARS_DeveloperAction("RedClick || Calibrated red X confirmed || Mask=" . mask . " || Arms=" . arms . " || " . (A_TickCount - startTick) . " ms")
				LLARS_DetectionRecord("RedClick", "Confirmed", arms, 3, "Mask=" . mask, false)
				return true
			}
		}
		else
		{
			consecutive := 0
		}

		Sleep, 16
	}

	LLARS_DeveloperAction("RedClick || Calibrated red X not detected || BestMask=" . bestMask . " || BestArms=" . bestArms . " || BaselineMask=" . baselineMask . " || Timeout=" . timeoutMs . " ms")
	LLARS_DetectionRecord("RedClick", "Not confirmed", bestArms, 3, "BestMask=" . bestMask, false)
	return false
}

; Right-clicks do not create RuneScape's red interaction X. Verify them by
; confirming that a RuneScape context menu appears over/near the target.
LLARS_RightClickContextMenuVisible(centerX, centerY, runeScapeHwnd)
{
	if (!IsFunc("LLARS_ColorCaptureVisibleClient")
		|| !IsFunc("LLARS_ColorContextMenuOverlapsTarget")
		|| !IsFunc("LLARS_CreatorReleaseCapture"))
	{
		return -1
	}

	if (!runeScapeHwnd || !DllCall("IsWindow", "Ptr", runeScapeHwnd))
		return -1
	if (DllCall("GetForegroundWindow", "Ptr") != runeScapeHwnd)
		return -1

	VarSetCapacity(clientRect, 16, 0)
	if !DllCall("GetClientRect", "Ptr", runeScapeHwnd, "Ptr", &clientRect)
		return -1

	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")
	if (clientWidth <= 0 || clientHeight <= 0)
		return -1

	captureMethod := ""
	capture := LLARS_ColorCaptureVisibleClient(runeScapeHwnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return -1

	visible := LLARS_ColorContextMenuOverlapsTarget(capture, centerX, centerY)
	LLARS_CreatorReleaseCapture(capture)
	return visible ? 1 : 0
}

LLARS_WaitForRightClickConfirmation(centerX, centerY, runeScapeHwnd, timeoutMs := 650)
{
	startTick := A_TickCount
	captureFailures := 0

	Loop
	{
		state := LLARS_RightClickContextMenuVisible(centerX, centerY, runeScapeHwnd)
		if (state = 1)
		{
			LLARS_DeveloperAction("RedClick || Right-click context menu confirmed || " . (A_TickCount - startTick) . " ms")
			LLARS_DetectionRecord("RightClick", "Confirmed", "", "", "Context menu", false)
			return true
		}
		if (state < 0)
			captureFailures++

		if ((A_TickCount - startTick) >= timeoutMs)
			break

		Sleep, 15
	}

	LLARS_DeveloperAction("RedClick || Right-click context menu not detected || CaptureFailures=" . captureFailures . " || Timeout=" . timeoutMs . " ms")
	LLARS_DetectionRecord("RightClick", "Not confirmed", "", "", "CaptureFailures=" . captureFailures, false)
	return false
}

LLARS_WaitForVerifiedClickConfirmation(centerX, centerY, button, runeScapeHwnd, redBaselineMask := 0)
{
	button := Trim(button)
	StringLower, button, button

	if (button = "right")
		return LLARS_WaitForRightClickConfirmation(centerX, centerY, runeScapeHwnd)

	return LLARS_WaitForRedClickConfirmation(centerX, centerY, runeScapeHwnd, redBaselineMask)
}

LLARS_StopRunTimersForMisclick()
{
	; Creator/API timers are tracked centrally. Legacy scripts also have a small
	; set of literal run timers, so stop those when their labels exist in the
	; currently loaded script. UI/developer watchdog timers are intentionally
	; left alone so the user can recover and start a new run normally.
	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()

	runTimerLabels := ["Countdown", "UpdateCountdown", "UpdateEstimatedTime", "UpdateTime"
		, "CheckClicks", "CheckClicksPixel", "CheckColorClick", "CheckInventoryPixels"
		, "CheckPixel", "ResetCheck", "ColorSearchTick", "DivinationTick", "EternalTreeTick", "updatebob"]
	for _, labelName in runTimerLabels
	{
		if IsLabel(labelName)
			SetTimer, %labelName%, Off
	}
}

LLARS_AbortRunForMisclick(x, y, clickTarget := "")
{
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_RunStartTick, LLARS_RunRuneScapeHwnd
	global LLARS_DeveloperKeyStates, LLARS_DeveloperControlKeyStates, LLARS_RUN_TYPE

	if (clickTarget = "")
		clickTarget := "verified world interaction"

	LLARS_DeveloperAction("RedClick Verification Failed || " . clickTarget . " || (" . x . ", " . y . ") || Run aborted")
	if IsFunc("LLARS_AHI_ReleaseAllInput")
		LLARS_AHI_ReleaseAllInput()
	LLARS_StopRunTimersForMisclick()

	LLARS_RUNNING := false
	LLARS_PAUSED := false
	LLARS_RunStartTick := 0
	LLARS_RunRuneScapeHwnd := 0
	LLARS_DeveloperKeyStates := {}
	LLARS_DeveloperControlKeyStates := {}
	LLARS_DeveloperCoordinateOverlayHideSafe()

	if IsFunc("EnableButton")
		EnableButton()
	if IsFunc("SetLLARSHOTKEYS")
		SetLLARSHOTKEYS("On")
	if IsFunc("LLARS_SetStatus")
		LLARS_SetStatus("Error", "Misclick detected")

	; TimerCount exists only on Timer-mode GUIs. RunCount/UntilDone scripts
	; must not touch it from the shared verified-click misclick halt path.
	; Keep this recovery-only GUI update from escaping into LLARS_RunCount's outer try/catch.
	if (LLARS_RUN_TYPE = "Timer")
	{
		try
			GuiControl,, TimerCount, Misclick
		catch
		{
		}
	}

	SoundBeep, 880, 180
	misclickWhat := "The expected RuneScape interaction confirmation was not detected.`nTarget: " . clickTarget . "`nCoordinate: (" . x . ", " . y . ")"
	LLARS_ReportError("LLARS Misclick Detected", misclickWhat
		, "Stopped this run, stopped run timers, and released LLARS-held input."
		, "Check RuneScape and start the run again when ready."
		, "Target=" . clickTarget . " || Coordinate=(" . x . ", " . y . ")")
	return false
}

; Direct-coordinate verified click. This keeps NaturalClick's movement,
; overshoot/correction, focus safety, and click timing unchanged. A failed
; verification is fatal for the active run.
RedClick(x, y, button := "left", coordinateSection := "", coordinateScope := "script")
{
	return NaturalClick(x, y, button, coordinateSection, coordinateScope, true, "abort")
}

; Nonfatal verified click for workflows that are expected to occasionally
; miss and can safely reacquire/retry the action themselves.
RedClickRetry(x, y, button := "left", coordinateSection := "", coordinateScope := "script")
{
	return NaturalClick(x, y, button, coordinateSection, coordinateScope, true, "return")
}

; ================================================================
; |     LLARS MOUSE LIBRARY     -     LLARS MOUSE LIBRARY        |
; ================================================================
; Moves the mouse to a target using LLARS naturalized movement, then clicks.
NaturalClick(x, y, button := "left", coordinateSection := "", coordinateScope := "script", verifyRedClick := false, redClickFailureMode := "abort")
{
	global LLARS_NaturalClickFocusLost, LLARS_RUNNING

	LLARS_NaturalClickFocusLost := false
	DllCall("QueryPerformanceFrequency", "Int64*", naturalClickPerformanceFrequency)
	DllCall("QueryPerformanceCounter", "Int64*", naturalClickStartCounter)
	runBound := LLARS_RUNNING ? true : false
	runeScapeHwnd := LLARS_ActivateRuneScapeForNaturalClick()
	if (!runeScapeHwnd)
		return false

	; Retry from the current cursor position if final verification is displaced.
	Loop
	{
		if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
		{
			LLARS_DeveloperCoordinateOverlayHideSafe()
			return false
		}

		; Refresh the Developer coordinate overlay on every NaturalClick retry.
		LLARS_DeveloperCoordinateOverlayShowSafe(x, y, coordinateSection, coordinateScope)

		result := LLARS_NaturalClickAttempt(x, y, button, runeScapeHwnd, runBound, coordinateSection, verifyRedClick, redClickFailureMode)
		if (result = 1)
		{
			; Leave the target visible briefly after the successful physical click so the developer can see exactly where the action landed.
			LLARS_DeveloperCoordinateOverlayHideSafe(500)
			DllCall("QueryPerformanceCounter", "Int64*", naturalClickEndCounter)
			naturalClickElapsed := Round(((naturalClickEndCounter - naturalClickStartCounter) * 1000.0) / naturalClickPerformanceFrequency)
			LLARS_DeveloperAction("NaturalClick Timing || " . naturalClickElapsed . " ms")
			return true
		}
		if (result = 0)
		{
			LLARS_DeveloperCoordinateOverlayHideSafe()
			return false
		}

		if (!DllCall("IsWindow", "Ptr", runeScapeHwnd) || !LLARS_IsRuneScapeWindow(runeScapeHwnd))
		{
			LLARS_DeveloperCoordinateOverlayHideSafe()
			return false
		}

		if (WinExist("A") != runeScapeHwnd)
		{
			if (!LLARS_RUNNING || !IsFunc("LLARS_WaitForRuneScape"))
			{
				LLARS_DeveloperCoordinateOverlayHideSafe()
				return false
			}
			if !LLARS_WaitForRuneScape("NaturalClick retry")
			{
				LLARS_DeveloperCoordinateOverlayHideSafe()
				return false
			}
		}

		Sleep, 10
	}
}

; Performs one complete natural mouse path.
LLARS_NaturalClickAttempt(x, y, button, runeScapeHwnd, runBound := false, coordinateSection := "", verifyRedClick := false, redClickFailureMode := "abort")
{
	if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
		return 0

	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before NaturalClick attempt", runeScapeHwnd))
		return -1

	MouseGetPos, startX, startY
	dx := x - startX
	dy := y - startY
	distance := Sqrt((dx * dx) + (dy * dy))
	overshootPlan := LLARS_NaturalClickOvershootPlan(startX, startY, x, y, runeScapeHwnd)
	movementX := x
	movementY := y
	if IsObject(overshootPlan)
	{
		movementX := overshootPlan.x
		movementY := overshootPlan.y
		dx := movementX - startX
		dy := movementY - startY
		distance := Sqrt((dx * dx) + (dy * dy))
	}
	if (distance <= 2)
	{
		DllCall("QueryPerformanceFrequency", "Int64*", movementPerformanceFrequency)
		DllCall("QueryPerformanceCounter", "Int64*", movementStartCounter)
		LLARS_InputMouseMove(x, y, 0)
		DllCall("QueryPerformanceCounter", "Int64*", movementEndCounter)
		actualMovementElapsed := Round(((movementEndCounter - movementStartCounter) * 1000.0) / movementPerformanceFrequency)
		moveTransport := IsFunc("LLARS_AHI_TransportName") ? LLARS_AHI_TransportName("mouse") : "Standard AutoHotkey"
		LLARS_DeveloperAction("Move || " . actualMovementElapsed . " ms || " . moveTransport . " || (" . startX . ", " . startY . ") -> (" . x . ", " . y . ")")
		pause := LLARS_HumanTiming(42, 126, "NaturalClick.TargetDwell", 0.035, 135, 215)
		Sleep, %pause%
		if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before NaturalClick verification", runeScapeHwnd))
			return -1
		MouseGetPos, clickX, clickY
		if (clickX != x || clickY != y)
			return -1
		if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus immediately before NaturalClick", runeScapeHwnd))
			return -1
		MouseGetPos, clickX, clickY
		if (clickX != x || clickY != y)
			return -1
		verificationButton := Trim(button)
		StringLower, verificationButton, verificationButton
		redBaselineMask := (verifyRedClick && verificationButton != "right") ? LLARS_RedClickArmMask(x, y, runeScapeHwnd) : 0
		LLARS_HumanMouseClick(button)
		if (verifyRedClick)
		{
			verificationType := (verificationButton = "right") ? "ContextMenu" : "RedX"
			LLARS_DeveloperAction("RedClick || Click sent || Button=" . verificationButton . " || Verify=" . verificationType . " || (" . x . ", " . y . ")")
			if !LLARS_WaitForVerifiedClickConfirmation(x, y, verificationButton, runeScapeHwnd, redBaselineMask)
			{
				LLARS_DeveloperNaturalClick(x, y, button, coordinateSection)
				if (redClickFailureMode = "return" || redClickFailureMode = "retry")
				{
					LLARS_DeveloperAction("RedClick Verification Failed || " . coordinateSection . " || (" . x . ", " . y . ") || Retry requested")
					return 0
				}
				LLARS_AbortRunForMisclick(x, y, coordinateSection)
				Exit
			}
		}
		LLARS_DeveloperNaturalClick(x, y, button, coordinateSection)
		return true
	}

	movementProfile := LLARS_NaturalMovementProfile(distance, "NaturalClick")
	duration := movementProfile.duration
	steps := movementProfile.steps
	timingExponent := movementProfile.timingExponent
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
	curveBase := LLARS_HumanRandomInt(-100, 100, "NaturalClick.CurveBase", 4)
	curveBase := curveBase * curveLimit / 100
	curveVariation1 := LLARS_HumanRandomInt(-25, 25, "NaturalClick.CurveVariation1", 4)
	curveVariation2 := LLARS_HumanRandomInt(-25, 25, "NaturalClick.CurveVariation2", 4)
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
	cp1Percent := LLARS_HumanRandomInt(25, 38, "NaturalClick.ControlPoint1", 3)
	cp2Percent := LLARS_HumanRandomInt(62, 75, "NaturalClick.ControlPoint2", 3)
	cp1X := startX + (dx * cp1Percent / 100)
	cp1Y := startY + (dy * cp1Percent / 100)
	cp2X := startX + (dx * cp2Percent / 100)
	cp2Y := startY + (dy * cp2Percent / 100)
	cp1X += perpX * curveAmount1
	cp1Y += perpY * curveAmount1
	cp2X += perpX * curveAmount2
	cp2Y += perpY * curveAmount2
	seedX := LLARS_HumanRandomInt(1, 2147483000, "NaturalClick.NoiseSeedX", 6)
	seedY := LLARS_HumanRandomInt(1, 2147483000, "NaturalClick.NoiseSeedY", 6)
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
		currentX += (ease * ease * ease * movementX)
		currentY := (inv * inv * inv * startY)
		currentY += (3 * inv * inv * ease * cp1Y)
		currentY += (3 * inv * ease * ease * cp2Y)
		currentY += (ease * ease * ease * movementY)
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

	DllCall("QueryPerformanceFrequency", "Int64*", movementPerformanceFrequency)
	DllCall("QueryPerformanceCounter", "Int64*", movementStartCounter)
	startTime := A_TickCount
	searchIndex := 2
	previousX := startX
	previousY := startY
	movementResult := 1
	; Keep framework timers from interrupting the path and let the explicit movement profile control the real elapsed time without hidden mouse delay.
	LLARS_NaturalMovementTimingBegin()
	Loop, %steps%
	{
		if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus during NaturalClick movement", runeScapeHwnd))
		{
			movementResult := -1
			break
		}
		if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
		{
			movementResult := 0
			break
		}

		t := A_Index / steps
		timingInput := t ** timingExponent
		timingT := timingInput * timingInput * (3 - (2 * timingInput))
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
			LLARS_InputMouseMove(currentX, currentY, 0)
			previousX := currentX
			previousY := currentY
		}

		LLARS_NaturalMovementRefreshEstimate()

		targetElapsed := Round(duration * t)
		actualElapsed := A_TickCount - startTime
		delay := targetElapsed - actualElapsed
		if (delay > 0)
		{
			if (delay > 35)
				delay := 35
			; AutoHotkey Sleep yields to hotkeys while Thread NoTimers continues to protect the path from timer callbacks.
			Sleep, %delay%
		}
	}

	if (movementResult != 1)
	{
		LLARS_NaturalMovementTimingEnd()
		return movementResult
	}

 	; Avoid scheduler clustering on neat 5 ms movement endings.
	DllCall("QueryPerformanceCounter", "Int64*", movementEndCounter)
	actualMovementElapsed := Round(((movementEndCounter - movementStartCounter) * 1000.0) / movementPerformanceFrequency)
	if (Mod(actualMovementElapsed, 5) = 0 && LLARS_RandomUnit() >= 0.01)
	{
		fineMovementDelay := LLARS_HumanRandomInt(1, 4, "NaturalClick.ActualMovementEnding", 2)
		Sleep, %fineMovementDelay%
	}
	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before NaturalClick final position", runeScapeHwnd))
	{
		LLARS_NaturalMovementTimingEnd()
		return -1
	}
	LLARS_InputMouseMove(movementX, movementY, 0)
	if IsObject(overshootPlan)
	{
		correctionResult := LLARS_NaturalClickCorrectOvershoot(movementX, movementY, x, y, runeScapeHwnd, runBound, startX, startY)
		if (correctionResult != 1)
		{
			LLARS_NaturalMovementTimingEnd()
			return correctionResult
		}
		LLARS_DeveloperAction("NaturalClick Overshoot || Target=(" . x . ", " . y . ") || Miss=(" . movementX . ", " . movementY . ") || Corrected")
	}
	else
	{
		LLARS_InputMouseMove(x, y, 0)
	}
	DllCall("QueryPerformanceCounter", "Int64*", movementEndCounter)
	actualMovementElapsed := Round(((movementEndCounter - movementStartCounter) * 1000.0) / movementPerformanceFrequency)
	LLARS_NaturalMovementTimingEnd()
	moveTransport := IsFunc("LLARS_AHI_TransportName") ? LLARS_AHI_TransportName("mouse") : "Standard AutoHotkey"
	LLARS_DeveloperAction("Move || " . actualMovementElapsed . " ms || " . moveTransport . " || (" . startX . ", " . startY . ") -> (" . x . ", " . y . ")")
	pause := LLARS_HumanTiming(42, 126, "NaturalClick.TargetDwell", 0.035, 135, 215)
	Sleep, %pause%
	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before NaturalClick verification", runeScapeHwnd))
		return -1
	MouseGetPos, clickX, clickY
	if (clickX != x || clickY != y)
	{
		LLARS_DeveloperAction("Cursor Validation || Target=(" . x . ", " . y . ") || Actual=(" . clickX . ", " . clickY . ") || Retry")
		return -1
	}
	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus immediately before NaturalClick", runeScapeHwnd))
		return -1
	MouseGetPos, clickX, clickY
	if (clickX != x || clickY != y)
	{
		LLARS_DeveloperAction("Cursor Validation || Target=(" . x . ", " . y . ") || Actual=(" . clickX . ", " . clickY . ") || Retry")
		return -1
	}
	verificationButton := Trim(button)
	StringLower, verificationButton, verificationButton
	redBaselineMask := (verifyRedClick && verificationButton != "right") ? LLARS_RedClickArmMask(x, y, runeScapeHwnd) : 0
	LLARS_HumanMouseClick(button)
	if (verifyRedClick)
	{
		verificationType := (verificationButton = "right") ? "ContextMenu" : "RedX"
		LLARS_DeveloperAction("RedClick || Click sent || Button=" . verificationButton . " || Verify=" . verificationType . " || (" . x . ", " . y . ")")
		if !LLARS_WaitForVerifiedClickConfirmation(x, y, verificationButton, runeScapeHwnd, redBaselineMask)
		{
			LLARS_DeveloperNaturalClick(x, y, button, coordinateSection)
			if (redClickFailureMode = "return" || redClickFailureMode = "retry")
			{
				LLARS_DeveloperAction("RedClick Verification Failed || " . coordinateSection . " || (" . x . ", " . y . ") || Retry requested")
				return 0
			}
			LLARS_AbortRunForMisclick(x, y, coordinateSection)
			Exit
		}
	}
	LLARS_DeveloperNaturalClick(x, y, button, coordinateSection)
	return true
}

; Moves the mouse naturally without clicking for anti-AFK activity.
AntiAFKNaturalClick(x, y, movementStream := "AntiAFKNaturalClick")
{
	global LLARS_RUNNING

	runBound := LLARS_RUNNING ? true : false
	runeScapeHwnd := LLARS_ActivateRuneScapeForNaturalClick()
	if (!runeScapeHwnd)
		return false

	MouseGetPos, startX, startY
	dx := x - startX
	dy := y - startY
	distance := Sqrt((dx * dx) + (dy * dy))

	if (distance <= 2)
	{
		Random, pause, 50, 120
		Sleep, %pause%
		if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
			return false
		if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before AntiAFKNaturalClick movement", runeScapeHwnd))
			return false
		LLARS_InputMouseMove(x, y, 0)
		return true
	}

	movementProfile := LLARS_NaturalMovementProfile(distance, movementStream)
	duration := movementProfile.duration
	steps := movementProfile.steps
	timingExponent := movementProfile.timingExponent
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
	curveBase := LLARS_HumanRandomInt(-100, 100, "AntiAFKNaturalClick.CurveBase", 4)
	curveBase := curveBase * curveLimit / 100
	curveVariation1 := LLARS_HumanRandomInt(-25, 25, "AntiAFKNaturalClick.CurveVariation1", 4)
	curveVariation2 := LLARS_HumanRandomInt(-25, 25, "AntiAFKNaturalClick.CurveVariation2", 4)
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
	cp1Percent := LLARS_HumanRandomInt(25, 38, "AntiAFKNaturalClick.ControlPoint1", 3)
	cp2Percent := LLARS_HumanRandomInt(62, 75, "AntiAFKNaturalClick.ControlPoint2", 3)
	cp1X := startX + (dx * cp1Percent / 100)
	cp1Y := startY + (dy * cp1Percent / 100)
	cp2X := startX + (dx * cp2Percent / 100)
	cp2Y := startY + (dy * cp2Percent / 100)
	cp1X += perpX * curveAmount1
	cp1Y += perpY * curveAmount1
	cp2X += perpX * curveAmount2
	cp2Y += perpY * curveAmount2
	seedX := LLARS_HumanRandomInt(1, 2147483000, "AntiAFKNaturalClick.NoiseSeedX", 6)
	seedY := LLARS_HumanRandomInt(1, 2147483000, "AntiAFKNaturalClick.NoiseSeedY", 6)
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
	movementResult := true
	; Use the same explicit, timer-protected cadence as NaturalClick.
	LLARS_NaturalMovementTimingBegin()

	Loop, %steps%
	{
		if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
		{
			movementResult := false
			break
		}
		if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus during AntiAFKNaturalClick movement", runeScapeHwnd))
		{
			movementResult := false
			break
		}

		t := A_Index / steps
		timingInput := t ** timingExponent
		timingT := timingInput * timingInput * (3 - (2 * timingInput))
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
			LLARS_InputMouseMove(currentX, currentY, 0)
			previousX := currentX
			previousY := currentY
		}

		LLARS_NaturalMovementRefreshEstimate()

		targetElapsed := Round(duration * t)
		actualElapsed := A_TickCount - startTime
		delay := targetElapsed - actualElapsed

		if (delay < 1)
			delay := 1

		if (delay > 35)
			delay := 35
		; Keep the movement timer-protected but never keyboard-protected.
		Sleep, %delay%
	}

	if (!movementResult)
	{
		LLARS_NaturalMovementTimingEnd()
		return false
	}
	if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
	{
		LLARS_NaturalMovementTimingEnd()
		return false
	}
	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before AntiAFKNaturalClick final position", runeScapeHwnd))
	{
		LLARS_NaturalMovementTimingEnd()
		return false
	}
	LLARS_InputMouseMove(x, y, 0)
	LLARS_NaturalMovementTimingEnd()
	return true
}

; Produces layered deterministic noise used to vary natural mouse movement.
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

; Generates one interpolated noise layer for the natural movement path.
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

; Converts a numeric input into a repeatable pseudo-random value from 0 to 1.
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
