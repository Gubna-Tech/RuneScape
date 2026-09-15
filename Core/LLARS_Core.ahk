; ================================================================
; |     LLARS CORE     -     LLARS CORE                          |
; ================================================================

global LLARS_CONFIG_FILE

; ================================================================
; |     CORE FUNCTIONS     -     CORE FUNCTIONS                  |
; ================================================================

; ================================================================
; |     LLARS CORE LIBRARY     -     LLARS CORE LIBRARY          |
; ================================================================
; Allows LLARS borderless GUI windows to be dragged with the mouse.
; Holding Ctrl when beginning the drag temporarily disables CheckPOS so
; an LLARS GUI can intentionally be moved onto another monitor.
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
; Developer Mode also saves its exact position here so the next toggle opens
; at the last completed drag location even if another close path is used.
WM_EXITSIZEMOVE(wParam := 0, lParam := 0, msg := 0, hwnd := 0) {
	global LLARS_CHECKPOS_DISABLED, DeveloperGuiHwnd

	LLARS_CHECKPOS_DISABLED := false
	if (DeveloperGuiHwnd && hwnd = DeveloperGuiHwnd)
		LLARS_DeveloperSavePosition(DeveloperGuiHwnd)
}

; Provides a Developer Mode keyboard fallback for the configured Exit hotkey.
; The normal global hotkey remains registered; this only handles the case where
; the Developer Mode GUI itself receives the key instead of the global hotkey.
LLARS_DeveloperExitKey(wParam, lParam, msg, hwnd)
{
	global LLARS_lhk4

	rootHwnd := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")
	if (!rootHwnd)
		rootHwnd := hwnd

	WinGetTitle, guiTitle, ahk_id %rootHwnd%
	if (guiTitle != "Developer Mode")
		return

	exitHotkey := Trim(LLARS_lhk4)
	if (exitHotkey = "")
		return

	requiresCtrl := InStr(exitHotkey, "^")
	requiresAlt := InStr(exitHotkey, "!")
	requiresShift := InStr(exitHotkey, "+")
	requiresWin := InStr(exitHotkey, "#")

	exitKey := RegExReplace(exitHotkey, "^[\$\*\~<>\^!+#]+")
	if (exitKey = "")
		return

	exitVK := GetKeyVK(exitKey)
	if (!exitVK || wParam != exitVK)
		return

	if (requiresCtrl && !GetKeyState("Ctrl", "P"))
		return
	if (requiresAlt && !GetKeyState("Alt", "P"))
		return
	if (requiresShift && !GetKeyState("Shift", "P"))
		return
	if (requiresWin && !GetKeyState("LWin", "P") && !GetKeyState("RWin", "P"))
		return

	SetTimer, ExitB, -1
	return 0
}

; Rechecks interactive LLARS window positions whenever Windows reports a move.
WM_WINDOWPOSCHANGED(wParam, lParam, msg, hwnd) {
	CheckPOS(hwnd)
}

; Keeps every interactive LLARS GUI fully inside the visible desktop area.
; Preview and border helper windows are intentionally excluded because some
; of them are positioned off-screen as part of normal LLARS behavior.
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
	if guiTitle not in LLARS,Combo,Reset Configuration,Coordinates,Colors,Hotkeys,Information,Developer Mode,Multiple Client,No Client Detected,Config Error,Game Not Found,Timer
		return

	WinGetPos, GUIx, GUIy, GUIw, GUIh, ahk_id %hwnd%
	if (GUIw = "" || GUIh = "")
		return

	; Clamp against the work area of the monitor nearest this window instead
	; of the primary monitor. This preserves saved positions on secondary
	; monitors, including monitors positioned left/above the primary display.
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

; Reads a valid saved Developer Mode top-left position. Blank/corrupt values
; are ignored so the GUI can safely fall back to its normal centered position.
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
; This prevents a failed title lookup from overwriting the last good position.
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

; Waits for the primary key of a configured hotkey to be released. This keeps
; key-repeat from turning one deliberate Developer Mode toggle into two.
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

; Forces LLARS keyboard hotkeys to use AutoHotkey's keyboard hook instead
; of Windows RegisterHotKey. This is especially important for F12, which
; Windows reserves for debugger use and should not be registered globally.
LLARS_HookHotkey(hotkey)
{
	hotkey := Trim(hotkey)
	if (hotkey = "")
		return ""
	if (SubStr(hotkey, 1, 1) = "$")
		return hotkey
	return "$" . hotkey
}

; Reads the shared LLARS hotkeys and safely enables, disables, or remaps them.
; Start/Information/Combo follow the current LLARS state. Exit is managed
; separately and is never disabled by normal framework control locking.
SetLLARSHOTKEYS(state := "On", startOnly := false)
{
	global LLARS_lhk1
	global LLARS_lhk2
	global LLARS_lhk3
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
		return

	IniRead, lhk2, %LLARS_CONFIG_FILE%, Information Hotkey, hotkey
	IniRead, lhk3, %LLARS_CONFIG_FILE%, color/coordinate/hotkey Hotkey, hotkey
	if (lhk2 = "ERROR")
		lhk2 := ""
	if (lhk3 = "ERROR")
		lhk3 := ""
	lhk2 := Trim(lhk2)
	lhk3 := Trim(lhk3)

	oldlhk2 := LLARS_HookHotkey(LLARS_lhk2)
	newlhk2 := LLARS_HookHotkey(lhk2)
	oldlhk3 := LLARS_HookHotkey(LLARS_lhk3)
	newlhk3 := LLARS_HookHotkey(lhk3)

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
}

; Keeps the Exit hotkey independent of every other LLARS control state.
; Once registered it is left alone until the configured key actually changes.
LLARS_EnableExitHotkey(lhk4 := "")
{
	global LLARS_lhk4

	if (lhk4 = "")
		IniRead, lhk4, %LLARS_CONFIG_FILE%, exit Hotkey, hotkey

	if (lhk4 = "ERROR")
		lhk4 := ""
	lhk4 := Trim(lhk4)

	; A temporary missing/blank config read never disables the last known
	; Exit hotkey.
	if (lhk4 = "")
		return

	; If the configured Exit key is unchanged, explicitly make sure its
	; hook is still enabled. This restores Exit after any GUI/hotkey state
	; change without tearing down or remapping the registration.
	if (LLARS_lhk4 = lhk4)
	{
		newlhk4 := LLARS_HookHotkey(lhk4)
		Hotkey, %newlhk4%, exitb, On
		return
	}

	oldlhk4 := LLARS_HookHotkey(LLARS_lhk4)
	newlhk4 := LLARS_HookHotkey(lhk4)

	if (oldlhk4 != "")
		Hotkey, %oldlhk4%, exitb, Off

	LLARS_lhk4 := lhk4
	Hotkey, %newlhk4%, exitb, On
}

; Keeps the Developer Mode hotkey independent of the normal Start /
; Information / Configuration state. Modifier combinations such as ^+D
; are supported and remain available while a script is running.
LLARS_EnableDeveloperHotkey(lhk5 := "")
{
	global LLARS_lhk5

	if (lhk5 = "")
		IniRead, lhk5, %LLARS_CONFIG_FILE%, Developer Mode, hotkey

	if (lhk5 = "ERROR")
		lhk5 := ""
	lhk5 := Trim(lhk5)

	; A temporary missing/blank config read never disables the last known
	; Developer Mode hotkey.
	if (lhk5 = "")
		return

	; If the configured Developer Mode key is unchanged, explicitly make sure
	; its hook is still enabled after any GUI/control/hotkey state transition.
	if (LLARS_lhk5 = lhk5)
	{
		newlhk5 := LLARS_HookHotkey(lhk5)
		Hotkey, %newlhk5%, DeveloperModeHotkey, On
		return
	}

	oldlhk5 := LLARS_HookHotkey(LLARS_lhk5)
	newlhk5 := LLARS_HookHotkey(lhk5)

	if (oldlhk5 != "")
		Hotkey, %oldlhk5%, DeveloperModeHotkey, Off

	LLARS_lhk5 := lhk5
	Hotkey, %newlhk5%, DeveloperModeHotkey, On
}

; Checks the shared config for actual hotkey changes. The old implementation
; rewrote the hotkey table every 250 ms even when nothing changed. This keeps
; the same live-config behavior without continuously cycling hotkeys Off/On.
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

	if (lhk1 != LLARS_lhk1 || lhk2 != LLARS_lhk2 || lhk3 != LLARS_lhk3)
		SetLLARSHOTKEYS("On")

	if (lhk4 != "")
		LLARS_EnableExitHotkey(lhk4)

	LLARS_EnableDeveloperHotkey(lhk5)
}

; Summarizes the script-specific GUI configuration requirements shown
; on the main LLARS window. Only active type=hotkey, type=coordinate,
; and type=color sections are included. Disabled optional sections and
; sections whose dependency is disabled are intentionally not required.
LLARS_UpdateConfigStatus()
{
	global LLARS_SCRIPT_DIR

	ConfigPath := LLARS_SCRIPT_DIR "\Config.ini"
	if !FileExist(ConfigPath)
		return

	hotkeyRequired := 0
	hotkeyMissing := 0
	coordinateRequired := 0
	coordinateMissing := 0
	colorRequired := 0
	colorMissing := 0

	IniRead, sections, %ConfigPath%
	if (sections = "ERROR")
		return

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

	LLARS_SetConfigStatusText("ConfigStatusHotkeys", "ConfigStatusHotkeysLabel", hotkeyRequired, hotkeyMissing)
	LLARS_SetConfigStatusText("ConfigStatusCoordinates", "ConfigStatusCoordinatesLabel", coordinateRequired, coordinateMissing)
	LLARS_SetConfigStatusText("ConfigStatusColors", "ConfigStatusColorsLabel", colorRequired, colorMissing)
}

; Converts configuration requirement counts into the compact text used by
; the main GUI. A category with no active requirements is shown explicitly
; as Not Required so users do not mistake it for missing configuration.
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

; Temporarily disables the non-exit LLARS controls and hotkeys.
; The lock prevents the periodic hotkey refresh from re-enabling them
; while a configuration/editor flow is still active.
DisableHotkey()
{
	global LLARS_CONTROLS_LOCKED

	LLARS_CONTROLS_LOCKED := true
	Control, Disable,, Button1, LLARS ahk_class AutoHotkeyGUI
	Control, Disable,, Button2, LLARS ahk_class AutoHotkeyGUI
	Control, Disable,, Button3, LLARS ahk_class AutoHotkeyGUI
	SetLLARSHOTKEYS("Off")
	LLARS_EnableExitHotkey()
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
	LLARS_EnableExitHotkey()
	LLARS_EnableDeveloperHotkey()
}

; Disables only the Start control while the timed script is running.
DisableButton()
{
	Control, Disable,, Button1, LLARS ahk_class AutoHotkeyGUI
	SetLLARSHOTKEYS("Off", true)
	LLARS_EnableExitHotkey()
	LLARS_EnableDeveloperHotkey()
}

; Re-enables the Start control after the timed run is finished.
EnableButton()
{
	Control, Enable,, Button1, LLARS ahk_class AutoHotkeyGUI
	SetLLARSHOTKEYS("On", true)
	LLARS_EnableExitHotkey()
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
; prepares hotkeys/logging, and creates the main GUI.
LLARS_Initialize()
{
	global LLARS_ROOT, LLARS_SCRIPT_DIR, LLARS_CONFIG_FILE, LastLogTick
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_lhk1, LLARS_lhk2, LLARS_lhk3, LLARS_lhk4, LLARS_lhk5, LLARS_CONTROLS_LOCKED, LLARS_CHECKPOS_DISABLED
	global LLARS_DeveloperActions, LLARS_DeveloperLastHotkey, LLARS_RunStartTick, LLARS_RUN_TYPE
	global LLARS_DeveloperPixelWatchActive, LLARS_DeveloperDetectedPixelColor, LLARS_DeveloperPixelSource
	global LLARS_DeveloperLastSleepValue, LLARS_DeveloperLastSleepName
	global LLARS_DeveloperKeyboardHook, LLARS_DeveloperKeyboardCallback, LLARS_DeveloperMessageHwnd
	global LLARS_DeveloperHotkeyMap, LLARS_DeveloperKeyStates, LLARS_DeveloperControlKeyStates
	global LLARS_RunRuneScapeHwnd
	global LLARS_DeveloperLightweight
	global EstimationRunCount
	global coordcount, frcount, LastClickTime, clickspot, scriptname, LLARS_GUIScriptName

	LLARS_SCRIPT_DIR := A_ScriptDir
	LLARS_ROOT := LLARS_FindRoot()
	LLARS_CONFIG_FILE := LLARS_ROOT "\LLARS Config.ini"
	if (LLARS_ROOT = "")
	{
		MsgBox, 48, LLARS Error, Unable to locate the LLARS Core folder.`n`nThe script must be located somewhere inside the LLARS Scripts folder.
		return false
	}

	SetWorkingDir, %LLARS_SCRIPT_DIR%
	LastLogTick := 0
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
	LLARS_DeveloperLastHotkey := "None"
	LLARS_DeveloperPixelWatchActive := false
	LLARS_DeveloperDetectedPixelColor := ""
	LLARS_DeveloperPixelSource := ""
	LLARS_DeveloperLastSleepValue := ""
	LLARS_DeveloperLastSleepName := ""
	LLARS_DeveloperKeyboardHook := 0
	LLARS_DeveloperKeyboardCallback := 0
	LLARS_DeveloperMessageHwnd := A_ScriptHwnd
	LLARS_DeveloperHotkeyMap := {}
	LLARS_DeveloperKeyStates := {}
	LLARS_DeveloperControlKeyStates := {}
	LLARS_DeveloperLightweight := false
	LLARS_RunStartTick := 0
	LLARS_RUN_TYPE := "Not Started"
	SetLLARSHOTKEYS("On")
	LLARS_EnableExitHotkey()
	LLARS_EnableDeveloperHotkey()
	StartLogSession()
	Log("STARTUP", "Script started")
	DetectHiddenWindows, On
	Log("DUPLICATE CHECK", "Checking for other LLARS windows")
	CloseOtherLLARS()
	if (!LLARS_CheckStartupFiles())
		return false

	CoordMode, Pixel, Client
	CoordMode, Mouse, Client
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
	OnMessage(0x0047, "WM_WINDOWPOSCHANGED")
	OnMessage(0x0100, "LLARS_DeveloperExitKey")
	OnMessage(0x0104, "LLARS_DeveloperExitKey")
	OnMessage(0x8001, "LLARS_DeveloperKeyboardMessage")
	OnMessage(0x0201, "WM_LBUTTONDOWN")
	OnMessage(0x0232, "WM_EXITSIZEMOVE")
	LLARS_DeveloperRefreshHotkeyMap(true)
	LLARS_DeveloperInitializeKeyboardHook()
	return true
}

; Returns the concise name used in compact LLARS GUI fields. Maintained
; templates keep their full file name on disk while omitting the trailing
; "Script Template" text in narrow GUI labels.
LLARS_DisplayScriptName()
{
	global LLARS_GUIScriptName, scriptname

	if (LLARS_GUIScriptName != "")
		return LLARS_GUIScriptName
	return scriptname
}

; Stores a short in-memory history for the Developer Mode live action panel.
; The history is intentionally limited and is never written to disk.
LLARS_DeveloperInitializeKeyboardHook()
{
	global LLARS_DeveloperKeyboardHook, LLARS_DeveloperKeyboardCallback

	if (LLARS_DeveloperKeyboardHook)
		return

	LLARS_DeveloperKeyboardCallback := RegisterCallback("LLARS_DeveloperKeyboardProc", "Fast")
	if (!LLARS_DeveloperKeyboardCallback)
		return

	LLARS_DeveloperKeyboardHook := DllCall("SetWindowsHookEx"
		, "Int", 13
		, "Ptr", LLARS_DeveloperKeyboardCallback
		, "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
		, "UInt", 0
		, "Ptr")
}

LLARS_DeveloperKeyboardProc(nCode, wParam, lParam)
{
	global LLARS_DeveloperMessageHwnd

	; The hook stays installed for LLARS hotkey reliability. For diagnostics,
	; only AutoHotkey-generated keyboard events are forwarded. Physical input
	; and unrelated driver-generated injected input are ignored here.
	if (nCode >= 0 && lParam && LLARS_DeveloperMessageHwnd)
	{
		flags := NumGet(lParam + 0, 8, "UInt")
		if (flags & 0x10)
		{
			extraInfo := NumGet(lParam + 0, 16, "UPtr")
			if (extraInfo = 0xFFC3D44F || extraInfo = 0xFFC3D44E || extraInfo = 0xFFC3D44D)
			{
				if (wParam = 0x0100 || wParam = 0x0101 || wParam = 0x0104 || wParam = 0x0105)
				{
					vkCode := NumGet(lParam + 0, 0, "UInt")
					keyUp := (wParam = 0x0101 || wParam = 0x0105) ? 1 : 0
					DllCall("PostMessage"
						, "Ptr", LLARS_DeveloperMessageHwnd
						, "UInt", 0x8001
						, "Ptr", vkCode
						, "Ptr", keyUp)
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
	LLARS_DeveloperScriptKey(wParam + 0, lParam ? true : false)
	return 0
}

; Refreshes the creator-configured hotkey lookup at most once per second.
; The hook itself never reads Config.ini. Both typed hotkey sections and older
; script sections with named *hotkey keys are recognized for useful labels.
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

	IniRead, sections, %ConfigPath%
	if (sections = "ERROR")
		return

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

; Records only script-generated key transitions. Duplicate down events are
; suppressed until the matching release so press/release history stays useful.
; The description captured on key-down is reused on key-up so each pair stays
; uniform even if Config.ini changes while a key is being held.
LLARS_DeveloperScriptKey(vkCode, keyUp := false)
{
	global LLARS_RUNNING, LLARS_DeveloperHotkeyMap, LLARS_DeveloperKeyStates

	keyName := GetKeyName("vk" . Format("{:02X}", vkCode))
	if (keyName = "")
		keyName := "VK" . Format("{:02X}", vkCode)

	; Modifier transitions generated internally by Send are implementation
	; details. The configured hotkey value on the base key retains modifiers.
	if keyName in LControl,RControl,Control,LShift,RShift,Shift,LAlt,RAlt,Alt,LWin,RWin
		return

	if (keyUp)
	{
		if !LLARS_DeveloperKeyStates.HasKey(vkCode)
			return

		keyInfo := LLARS_DeveloperKeyStates[vkCode]
		LLARS_DeveloperKeyStates.Delete(vkCode)
		if (keyInfo.Type = "Hotkey")
			LLARS_DeveloperAction("Hotkey || Released || " . keyInfo.Section . " || " . keyInfo.Hotkey)
		else
			LLARS_DeveloperAction("Key || Released || " . keyInfo.KeyName)
		return
	}

	if (!LLARS_RUNNING || !WinActive("RuneScape"))
		return
	if LLARS_DeveloperKeyStates.HasKey(vkCode)
		return

	LLARS_DeveloperRefreshHotkeyMap()
	if (LLARS_DeveloperHotkeyMap.HasKey(vkCode))
	{
		hotkeyInfo := LLARS_DeveloperHotkeyMap[vkCode]
		LLARS_DeveloperKeyStates[vkCode] := {Type: "Hotkey", Section: hotkeyInfo.Section, Hotkey: hotkeyInfo.Hotkey}
		LLARS_DeveloperAction("Hotkey || Pressed || " . hotkeyInfo.Section . " || " . hotkeyInfo.Hotkey)
	}
	else
	{
		LLARS_DeveloperKeyStates[vkCode] := {Type: "Key", KeyName: keyName}
		LLARS_DeveloperAction("Key || Pressed || " . keyName)
	}
}

; Backward-compatible entry point retained for any older internal callers.
LLARS_DeveloperKeyPressed(vkCode)
{
	LLARS_DeveloperScriptKey(vkCode, false)
}

LLARS_DeveloperAction(action, lightweight := true)
{
	global LLARS_DeveloperActions, LLARS_DeveloperLastActions, DeveloperActionsHwnd

	; Keep every Developer Console field separator visually consistent. Producers
	; that still emit a spaced single pipe are normalized here without changing
	; ordinary logs, Config.ini syntax, or unspaced pipe characters in values.
	action := StrReplace(action, " | ", " || ")

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

	while (developerActionCount > 40)
	{
		developerActionBreak := InStr(LLARS_DeveloperActions, "`n")
		if (!developerActionBreak)
			break
		LLARS_DeveloperActions := SubStr(LLARS_DeveloperActions, developerActionBreak + 1)
		developerActionCount--
	}

	; Recent Framework Actions should reflect framework events immediately instead
	; of waiting for the normal 750 ms Developer Mode dashboard refresh.
	if (DeveloperActionsHwnd && WinExist("Developer Mode ahk_class AutoHotkeyGUI"))
	{
		GuiControl, Dev:, DeveloperActionsText, %LLARS_DeveloperActions%
		LLARS_DeveloperLastActions := LLARS_DeveloperActions
		PostMessage, 0x115, 7, 0,, ahk_id %DeveloperActionsHwnd%
	}
}

; Records a semantic LLARS interface event without treating the user's raw
; mouse/keyboard input as a framework action. This keeps Developer Mode useful
; when navigating LLARS configuration windows while filtering unrelated input.
LLARS_DeveloperUIAction(windowName, action := "Opened")
{
	static guiStates := {}

	windowName := Trim(windowName)
	action := Trim(action)
	if (windowName = "")
		return
	if (action = "")
		action := "Opened"

	; Keep GUI lifecycle entries symmetrical without duplicating them when a
	; dashboard is rebuilt or a close path is reached more than once.
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

; Returns the newest lines from the shared Developer Mode action history.
; Retained for callers that intentionally want a shorter excerpt. Full and
; Lightweight Developer Mode both render LLARS_DeveloperActions directly.
LLARS_DeveloperRecentActions(maxLines := 8)
{
	global LLARS_DeveloperActions

	if (LLARS_DeveloperActions = "")
		return "No framework actions recorded yet."

	actionLines := []
	Loop, Parse, LLARS_DeveloperActions, `n, `r
	{
		if (A_LoopField != "")
			actionLines.Push(A_LoopField)
	}

	lineCount := actionLines.Length()
	if (lineCount = 0)
		return "No framework actions recorded yet."

	startIndex := lineCount - maxLines + 1
	if (startIndex < 1)
		startIndex := 1

	recentActions := ""
	Loop, % lineCount - startIndex + 1
	{
		lineIndex := startIndex + A_Index - 1
		if (recentActions != "")
			recentActions .= "`n"
		recentActions .= actionLines[lineIndex]
	}

	return recentActions
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
	; Record only these known controls instead of recording arbitrary user keys.
	; A_ThisHotkey can outlive the thread that originally set it, so verify the
	; underlying physical key is actually down before treating this label entry
	; as a hotkey press. GUI button clicks therefore cannot inherit a stale key.
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

	; Never inspect another application. Only the currently active RuneScape
	; client is eligible for live coordinate/color inspection.
	developerRuneScapeHWND := WinActive("RuneScape")
	if (!developerRuneScapeHWND)
	{
		if WinExist("RuneScape")
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
	if WinExist("RuneScape")
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
	Log("START", "Start button/hotkey activated")
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
		MsgBox, 48, LLARS Estimate Error, Unable to calculate the estimated loop/run time.`n`nThe automation loop will not start.
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
	Log("RUN START", "Starting " runcount3 " runs")
	return true
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
	Log("START", "Start button/hotkey activated")
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
	Log("TIMER", "Timer set to " timeToRunMinutes " minutes")
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
	if (time < 0)
		time := 0
	minutes := Floor(time / 60000)
	seconds := Mod(Floor(time / 1000), 60)
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
	global EstRandomSleepAdjustment

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()
	LLARS_RunRuneScapeHwnd := 0
	LLARS_DeveloperKeyStates := {}
	EstRandomSleepAdjustment := 0
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
	global EstRandomSleepAdjustment
	global scriptname

	; Each loop starts from the normal probability-weighted Random Sleep estimate.
	; LLARS_RandomSleep() replaces that expected contribution with the actual result.
	EstRandomSleepAdjustment := 0

	; A prepared Random Sleep roll is valid for one RunCount loop only.
	; Clear anything left by an abandoned/conditional path before this loop rolls.
	LLARS_RandomSleepPending := false
	LLARS_RandomSleepPendingRun := false
	LLARS_RandomSleepPendingChance := ""
	LLARS_RandomSleepPendingRoll := ""

	EstFinalSleepActive := false
	EstFinalSleepEndTick := 0
	EstLoopStartTick := A_TickCount
	Log("LOOP START", "Iteration=" A_Index " of " runcount)
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

	IniRead, developerSections, %configFile%
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
; Scripts that need to know whether Random Sleep will run can call this early.
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
		Log("CONFIG ERROR", "Random Sleep chance is invalid: " chance)
		LLARS_DeveloperAction("Random Sleep || Config Error || Chance=" . chance)
		return false
	}

	chance += 0
	if (chance < 0 || chance > 100)
	{
		Log("CONFIG ERROR", "Random Sleep chance must be between 0 and 100: " chance)
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

; Replaces the probability-weighted Random Sleep contribution in the current
; loop estimate with what actually happened on this occurrence. Future loops
; keep using the configured probability-weighted average.
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
; A prepared roll is consumed when present; otherwise the chance is rolled here.
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

	; Recheck the option immediately before sleeping so Random Sleep can never
	; run after the shared setting has been disabled.
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
		Log("CONFIG ERROR", "Random Sleep minimum duration is invalid: " rs1)
		LLARS_DeveloperAction("Random Sleep || Config Error || Min=" . rs1)
		return 0
	}

	if rs2 is not integer
	{
		Log("CONFIG ERROR", "Random Sleep maximum duration is invalid: " rs2)
		LLARS_DeveloperAction("Random Sleep || Config Error || Max=" . rs2)
		return 0
	}

	rs1 += 0
	rs2 += 0
	if (rs1 < 0 || rs2 < rs1)
	{
		Log("CONFIG ERROR", "Random Sleep duration range is invalid: " rs1 "-" rs2 " ms")
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
	Log("RANDOM SLEEP", "Sleep=" RandomSleepAmount " ms | Chance=" chance "% | Roll=" RandomNumber)

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
; From this point until the next loop, the GUI shows an exact countdown.
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
	Log("COMPLETE", "Completed " runcount3 " runs | Total time=" TotalTimeSeconds " seconds | Random sleeps=" sleepcount)
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

; ================================================================
; |     LLARS CONFIG LIBRARY     -     LLARS CONFIG LIBRARY      |
; ================================================================
; Checks that the required LLARS configuration files are present.
LLARS_CheckStartupFiles()
{
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
		Gui Error: +ToolWindow
		Gui Error: -caption
		Gui Error: Show, center w230, Config Error
		return false
	}

	Log("CONFIG LOADED", "Config.ini loaded successfully")
	if !FileExist(LLARS_CONFIG_FILE)
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
		Gui Error: +ToolWindow
		Gui Error: -caption
		Gui Error: Show, center w230, Config Error
		return false
	}

	Log("LLARS CONFIG LOADED", "LLARS Config.ini loaded successfully")
	return true
}

; Runs validation against both the script Config.ini and shared LLARS Config.ini.
ConfigError()
{
	if (CheckConfigFile("Config.ini"))
		return true

	if (CheckConfigFile(LLARS_CONFIG_FILE))
		return true

	return false
}

; Displays the configuration error, opens the affected file, logs
; the missing value(s), and reloads the script after the user fixes it.
ConfigErrorMessage(file, section, key)
{
	if InStr(file, ":\")
		Run, %file%
	else
		Run, %A_ScriptDir%\%file%
	GuiControl,, ScriptRed, CONFIG
	GuiControl,, State2, ERROR
	MsgBox, 4112, Config Error, Please enter a value for:`n`n[%section%]`n%key%
	Log("CONFIG ERROR", file " | [" section "] " key " is blank")
	Reload
}

; Displays a semantic configuration error for values that are present
; but invalid, inconsistent, or outside the supported configuration rules.
ConfigSemanticErrorMessage(file, section, key, details)
{
	if InStr(file, ":\")
		Run, %file%
	else
		Run, %A_ScriptDir%\%file%
	GuiControl,, ScriptRed, CONFIG
	GuiControl,, State2, ERROR
	MsgBox, 4112, Config Error, Invalid configuration value:`n`n[%section%]`n%key%`n`n%details%
	Log("CONFIG ERROR", file " | [" section "] " key " | " details)
	Reload
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

; Dynamically scans every section/key in a configuration file. The first
; stage checks required values; the second stage validates their meaning.
; Sections with option=false are skipped after their metadata is validated.
CheckConfigFile(file)
{
	global LLARS_SCRIPT_DIR
	global LLARS_CONFIG_FILE

	ConfigPath := InStr(file, ":\") ? file : LLARS_SCRIPT_DIR "\" file
	IniRead, sections, %ConfigPath%
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
			if (section = "Logging" && ConfigPath = LLARS_CONFIG_FILE)
			{
				if (optionLower != "enabled" && optionLower != "disabled")
				{
					ConfigSemanticErrorMessage(file, section, "option", "Expected enabled or disabled. Found: " option)
					return true
				}
			}
			else if (optionLower != "true" && optionLower != "false")
			{
				ConfigSemanticErrorMessage(file, section, "option", "Expected true or false. Found: " option)
				return true
			}
		}
		else
			optionLower := "true"

		; A key named type is only framework metadata when it uses a
		; recognized editor type, or when the section clearly contains
		; coordinate/hotkey editor fields. This preserves script-specific
		; keys such as [Plank Type] type=0.
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

		; Validate dependency metadata and skip dependent sections while
		; their parent option is disabled.
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

			; If any rectangle coordinate exists, this is treated
			; as a rectangle coordinate.
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

		; Validate color sections using the same 0xRRGGBB format expected
		; by the LLARS color editor.
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

		; min/max pairs are used throughout LLARS for sleeps, counts,
		; scrolling, offsets, and other random ranges.
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

		; Script-specific hotkey keys such as bank hotkey and toolbar hotkey
		; use the same AutoHotkey syntax as typed hotkey sections.
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
		if (key = "option" || key = "type" || key = "depends")
			continue

		candidateKey := key
		candidateCount++

		if (key = section)
			return key

		if RegExMatch(color, "i)^0x[0-9A-F]{6}$")
			return key
	}

	; A typed color section with exactly one non-metadata key keeps that
	; same key even after its value is reset to blank. This allows the
	; normal Color editor to refill the original key rather than creating
	; a new key named after the section.
	if (candidateCount = 1)
		return candidateKey

	return section
}

; Returns true when a typed Config.ini section currently contains a saved
; value that the Reset Config GUI is allowed to clear. Only the three
; framework editor types are eligible; timers, offsets, ranges, options,
; and all other script-specific values are intentionally ignored.
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

; Clears one explicitly typed editor value from Config.ini. This function
; never deletes sections and never touches unrecognized keys. Coordinate
; resets are limited to coordinate fields, hotkey resets to hotkey, and
; color resets to the color key resolved by the framework.
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

; ================================================================
; |     LOGGING     -     LOGGING     -     LOGGING              |
; ================================================================

; ================================================================
; |     LLARS LOGGING LIBRARY     -     LLARS LOGGING LIBRARY    |
; ================================================================
; Checks LLARS Config.ini to determine if logging is enabled.
LoggingCheck()
{
	global LLARS_SCRIPT_DIR

	IniRead, LoggingOption, %LLARS_CONFIG_FILE%, Logging, option, disabled
	if (LoggingOption = "enabled")
		return true

	return false
}

; Centralized logging functions used throughout the script to record
; events, timestamps, session state, and important actions.
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

	; LLARS_EstimatedSleep() / LLARS_FinalSleep() already add the sleep when it
	; begins. Many scripts also Log("SLEEP", ...) after it finishes. Suppress
	; that one matching follow-up so Recent Framework Actions stays concise.
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
	; Configuration/state messages such as a timer being disabled or stopped
	; belong in the normal log, not the live action pane.
	if RegExMatch(detailText, "i)\b(disabled|stopped|turned off|not enabled|inactive|skipped)\b")
		return

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

LLARS_DeveloperPixelDetectedAction()
{
	global color, currentColor
	global LLARS_DeveloperPixelWatchActive, LLARS_DeveloperDetectedPixelColor, LLARS_DeveloperPixelSource

	LLARS_DeveloperPixelWatchActive := true
	LLARS_DeveloperDetectedPixelColor := ""
	LLARS_DeveloperPixelSource := ""

	if (currentColor != "")
	{
		LLARS_DeveloperDetectedPixelColor := currentColor
		LLARS_DeveloperPixelSource := "currentColor"
	}
	else if (color != "")
	{
		LLARS_DeveloperDetectedPixelColor := color
		LLARS_DeveloperPixelSource := "color"
	}

	LLARS_DeveloperAction("Pixel Detected")
}

LLARS_DeveloperCheckPixelReset()
{
	global color, currentColor
	global LLARS_DeveloperPixelWatchActive, LLARS_DeveloperDetectedPixelColor, LLARS_DeveloperPixelSource

	if (!LLARS_DeveloperPixelWatchActive)
		return

	if (LLARS_DeveloperDetectedPixelColor = "")
		return

	if (LLARS_DeveloperPixelSource = "currentColor")
		developerCurrentPixel := currentColor
	else if (LLARS_DeveloperPixelSource = "color")
		developerCurrentPixel := color
	else
		return

	if (developerCurrentPixel = "")
		return

	if (developerCurrentPixel = LLARS_DeveloperDetectedPixelColor)
		return

	LLARS_DeveloperPixelWatchActive := false
	LLARS_DeveloperDetectedPixelColor := ""
	LLARS_DeveloperPixelSource := ""
	LLARS_DeveloperAction("Pixel Search Reset")
}

LLARS_DeveloperStatusOnly(Event, Details := "")
{
	statusText := Trim(Event . " " . Details)

	if RegExMatch(statusText, "i)\b(disabled|not enabled|inactive|turned off|stopped|skipped)\b")
		return true

	return false
}

Log(Event, Details := "")
{
	global LogCount
	global LLARS_SCRIPT_DIR

	if !LLARS_DeveloperStatusOnly(Event, Details)
	{
		if (InStr(Event, "ANTI-AFK") = 1)
			LLARS_DeveloperAntiAFKAction(Event, Details)
		else if (Event = "TIMER")
			LLARS_DeveloperScriptTimerAction(Details)
		else if (InStr(Event, "SLEEP") || (Event = "WAIT" && InStr(Details, "sleep")))
			LLARS_DeveloperLoggedSleepAction(Event, Details)
		else if (Event = "COLOR CHANGED IN CONFIG")
			LLARS_DeveloperColorConfigAction(Details)
		else if (Event = "PIXEL DETECTED")
			LLARS_DeveloperPixelDetectedAction()
		else if (Event = "KEY TIMING")
			LLARS_DeveloperAction("KeyPress || " . Details)
		else if (Event = "CLICK TIMING")
			LLARS_DeveloperAction("Mouse Timing || " . Details)
	}

	if !LoggingCheck()
		return

	FormatTime, LogTime,, yyyy-MM-dd HH:mm:ss
	LogCount++
	IniWrite, %LogCount%, %LLARS_SCRIPT_DIR%\log.ini, Log, Count
	LogEntry := "[Log" LogCount "]`r`n"
	LogEntry .= "Time=" LogTime "`r`n"
	LogEntry .= "Event=" Event "`r`n"
	LogEntry .= "Details=" Details "`r`n`r`n"
	FileAppend, %LogEntry%, %LLARS_SCRIPT_DIR%\log.ini
}

; Initializes a new logging session, continuing the log count from
; the previous session and marking the current session as running.
StartLogSession()
{
	global LogCount
	global LLARS_SCRIPT_DIR

	if !LoggingCheck()
		return

	IniRead, LogCount, %LLARS_SCRIPT_DIR%\log.ini, Log, Count, 0
	FormatTime, StartTime,, yyyy-MM-dd HH:mm:ss
	SessionBarrier =
    (
`r`n============================================================
NEW SESSION - %StartTime%
============================================================`r`n
    )
	FileAppend, %SessionBarrier%, %LLARS_SCRIPT_DIR%\log.ini
	IniWrite, RUNNING, %LLARS_SCRIPT_DIR%\log.ini, Session, Status
	IniWrite, %StartTime%, %LLARS_SCRIPT_DIR%\log.ini, Session, StartTime
}

; Marks the current logging session as stopped and records the
; reason and ending timestamp.
EndLogSession(Reason := "Normal Exit")
{
	global LLARS_SCRIPT_DIR

	if !LoggingCheck()
		return

	FormatTime, EndTime,, yyyy-MM-dd HH:mm:ss
	IniWrite, STOPPED, %LLARS_SCRIPT_DIR%\log.ini, Session, Status
	IniWrite, %EndTime%, %LLARS_SCRIPT_DIR%\log.ini, Session, EndTime
	Log("STOP", Reason)
}

; Returns the active typed coordinate section that contains a click target.
; This lets Developer Mode identify configured locations without requiring
; script creators to add diagnostic-only click labels.
LLARS_DeveloperClickTarget(x, y)
{
	global LLARS_SCRIPT_DIR

	ConfigPath := LLARS_SCRIPT_DIR . "\Config.ini"
	if !FileExist(ConfigPath)
		return ""

	IniRead, sections, %ConfigPath%
	if (sections = "ERROR")
		return ""

	Loop, Parse, sections, `n, `r
	{
		section := Trim(A_LoopField)
		if (section = "")
			continue

		if (GetConfigType(ConfigPath, section) != "coordinate")
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

; Returns true only when the supplied window belongs to the RuneScape client.
; Known RuneScape process names are accepted, with the exact RuneScape window
; title retained as a compatibility fallback for alternate installations.
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

; Finds the RuneScape game window without assuming it is already active.
; The current active client is preferred, then the normal LLARS RuneScape title
; match, then any visible window owned by a known RuneScape process.
LLARS_FindRuneScapeWindow()
{
	activeHwnd := WinExist("A")
	if (LLARS_IsRuneScapeWindow(activeHwnd))
		return activeHwnd

	WinGet, titleHwnd, ID, RuneScape
	if (titleHwnd)
		return titleHwnd

	WinGet, windowList, List
	Loop, %windowList%
	{
		hwnd := windowList%A_Index%
		if (!DllCall("IsWindowVisible", "Ptr", hwnd))
			continue

		WinGet, processName, ProcessName, ahk_id %hwnd%
		StringLower, processName, processName
		if processName in runescape.exe,rs2client.exe
			return hwnd
	}

	return 0
}

; Returns the active RuneScape HWND NaturalClick may use. During an active
; LLARS run, focus loss is handled by reclaiming the exact run target before
; mouse movement continues.
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
		Log("NATURAL CLICK BLOCKED", "RuneScape is not the active window")
		return 0
	}

	return runeScapeHwnd
}

; Stops the current NaturalClick attempt if focus leaves the exact RuneScape
; client selected when the click began. During a run, reclaim that client before
; returning so the caller can safely retry the intended click.
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
	Log("NATURAL CLICK BLOCKED", reason)
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
; Uses Windows' system RNG when available instead of relying on AutoHotkey's
; process-local pseudo-random stream. AHK Random remains a fallback only.
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

	; Very small ranges naturally repeat. Forcing alternation there creates a
	; stronger pattern than allowing an occasional duplicate.
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

; Uniform integer selection backed by the system RNG, with optional recent-value
; avoidance. This is useful for large ranges such as path speed and noise seeds.
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

; Human timing is intentionally not uniform. Averaging several independent
; samples creates a soft center with occasional faster/slower values, which is
; closer to natural motor timing than repeatedly choosing every millisecond with
; equal probability.
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

; Keeps human input timings inside their existing ranges while making neat
; multiples of five uncommon. A small minority are intentionally preserved so
; naturally occurring round values are still possible rather than forbidden.
LLARS_HumanizeTimingEnding(value, minimum, maximum, stream := "")
{
	value := Round(value)
	minimum := Round(minimum)
	maximum := Round(maximum)

	if (Mod(value, 5) != 0 || LLARS_RandomUnit() < 0.08)
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

; Performs one physical mouse-button press with a varied down/up hold time.
; NaturalClick verifies the exact target pixel immediately before calling this.
LLARS_HumanMouseClick(button := "left")
{
	button := Trim(button)
	StringLower, button, button

	holdTime := LLARS_HumanTiming(38, 108, "MouseClick.Hold." . button, 0.045, 118, 176)
	holdMinimum := (holdTime >= 118) ? 118 : 38
	holdMaximum := (holdTime >= 118) ? 176 : 108
	holdTime := LLARS_HumanizeTimingEnding(holdTime, holdMinimum, holdMaximum, "MouseClick.Hold." . button)

	if (button = "right")
	{
		Click, Right Down
		Sleep, %holdTime%
		Click, Right Up
	}
	else
	{
		Click, Down
		Sleep, %holdTime%
		Click, Up
	}

	Log("CLICK TIMING", "Hold=" . holdTime . " ms")
	return true
}

; Developer coordinate overlays are debugger-only. A visual overlay failure
; must never stop creator automation or turn a RunCount callback into an error.
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

; Builds one human movement timing profile. The timing model follows the two-part
; structure seen in human pointing: most distance is covered during a quicker
; ballistic reach, while the final portion consumes proportionally more time for
; visual correction. Longer reaches gain speed, but not enough to make their total
; movement time collapse toward the short-movement range.
LLARS_NaturalMovementProfile(distance, stream := "NaturalClick")
{
	if (distance < 0)
		distance := 0

	; Human pointing does not use one constant cursor speed. Peak/transport speed
	; rises with movement amplitude, while total movement time still increases.
	; The square-root growth keeps long reaches from becoming unnaturally brisk.
	preferredBallisticSpeed := 600 + (22 * Sqrt(distance))

	; Short corrections can legitimately be very brisk. As distance grows, remove
	; more of the high-speed tail and bias the random draw toward deliberate reaches.
	distanceFactor := distance / 1800.0
	if (distanceFactor < 0)
		distanceFactor := 0
	if (distanceFactor > 1)
		distanceFactor := 1
	minimumSpeedMultiplier := 0.72
	maximumSpeedMultiplier := 1.35 - (0.25 * distanceFactor)
	speedShape := 0.70 + (1.60 * distanceFactor)
	speedRoll := LLARS_RandomUnit() ** speedShape
	speedMultiplier := minimumSpeedMultiplier + ((maximumSpeedMultiplier - minimumSpeedMultiplier) * speedRoll)
	ballisticSpeed := preferredBallisticSpeed * speedMultiplier

	; Mouse-pointing studies show the initial ballistic phase covers roughly 90%+
	; of the distance while using only around 60% of the total movement time. Vary
	; both proportions independently so identical-distance calls do not share a pace.
	ballisticDistanceFraction := 0.89 + (LLARS_RandomUnit() * 0.06)
	ballisticTimeFraction := 0.55 + (LLARS_RandomUnit() * 0.11)
	timingJitter := 0.96 + (LLARS_RandomUnit() * 0.08)

	duration := Round((((distance * ballisticDistanceFraction) / ballisticSpeed) * 1000) / ballisticTimeFraction * timingJitter)

	; Preserve the researched distance/speed model, then add a small independent
	; millisecond-scale variation so real movement times do not cluster around
	; visually generic values even when the larger movement profile is similar.
	fineTimingRange := Round(duration * 0.025)
	if (fineTimingRange < 7)
		fineTimingRange := 7
	if (fineTimingRange > 43)
		fineTimingRange := 43
	fineTimingJitter := LLARS_HumanRandomInt(-fineTimingRange, fineTimingRange, stream . ".FineTiming", 10)
	duration += fineTimingJitter
	if (Mod(duration, 25) = 0)
	{
		fineTimingNudge := LLARS_HumanRandomInt(3, 13, stream . ".FineTimingNudge", 6)
		if (LLARS_RandomUnit() < 0.5)
			fineTimingNudge := -fineTimingNudge
		duration += fineTimingNudge
	}

	if (duration < 55)
		duration := 55
	if (duration > 3200)
		duration := 3200

	; Keep meaningful model bounds available to callers/debuggers without forcing
	; the selected duration into fixed buckets or rounded-looking timing values.
	fastestBallisticSpeed := preferredBallisticSpeed * maximumSpeedMultiplier
	slowestBallisticSpeed := preferredBallisticSpeed * minimumSpeedMultiplier
	minimumDuration := Round((((distance * 0.89) / fastestBallisticSpeed) * 1000) / 0.66 * 0.96)
	maximumDuration := Round((((distance * 0.95) / slowestBallisticSpeed) * 1000) / 0.55 * 1.04)
	if (minimumDuration < 55)
		minimumDuration := 55
	if (maximumDuration > 3200)
		maximumDuration := 3200

	; Preserve the working NaturalClick path density exactly. Timing changes must
	; not alter the geometric character that already feels natural.
	stepSpacing := LLARS_HumanRandomInt(5, 9, stream . ".StepSpacing", 4)
	steps := Round(distance / stepSpacing)
	if (steps < 12)
		steps := 12
	if (steps > 120)
		steps := 120

	; Preserve the existing per-call acceleration/deceleration variation.
	timingExponentPercent := LLARS_HumanRandomInt(68, 142, stream . ".TimingCurve", 6)
	timingExponent := timingExponentPercent / 100.0

	return {duration:duration
		, minimumDuration:minimumDuration
		, maximumDuration:maximumDuration
		, steps:steps
		, timingExponent:timingExponent}
}

; NaturalClick controls its own movement cadence. Removing AutoHotkey's hidden
; per-MouseMove delay prevents that fixed cost from collapsing different distance
; bands into similar elapsed times. The movement loops use Win32 Sleep while this
; 1 ms timer period is active so sub-10 ms waits are not rounded into large stalls.
; The normal 10 ms mouse delay is restored after each natural movement path.
LLARS_NaturalMovementTimingBegin()
{
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

; ================================================================
; |     LLARS MOUSE LIBRARY     -     LLARS MOUSE LIBRARY        |
; ================================================================
; Moves the mouse to a target using LLARS naturalized movement, then clicks.
NaturalClick(x, y, button := "left", coordinateSection := "", coordinateScope := "script")
{
	global LLARS_NaturalClickFocusLost, LLARS_RUNNING

	LLARS_NaturalClickFocusLost := false
	DllCall("QueryPerformanceFrequency", "Int64*", naturalClickPerformanceFrequency)
	DllCall("QueryPerformanceCounter", "Int64*", naturalClickStartCounter)
	runBound := LLARS_RUNNING ? true : false
	runeScapeHwnd := LLARS_ActivateRuneScapeForNaturalClick()
	if (!runeScapeHwnd)
		return false

	; Never click a displaced cursor. If the cursor is not on the exact requested
	; pixel during final verification, restart the natural movement from its current
	; position and keep trying until the target is truly reached or the run ends.
	Loop
	{
		if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
		{
			LLARS_DeveloperCoordinateOverlayHideSafe()
			return false
		}

		; While Developer Mode is open, keep the configured coordinate region
		; visible as a click-through overlay for the entire NaturalClick. Refresh
		; it on every retry so it stays visible while the user fights the mouse.
		LLARS_DeveloperCoordinateOverlayShowSafe(x, y, coordinateSection, coordinateScope)

		result := LLARS_NaturalClickAttempt(x, y, button, runeScapeHwnd, runBound, coordinateSection)
		if (result = 1)
		{
			; Leave the target visible briefly after the successful physical click so
			; the developer can see exactly where the action landed.
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

; Performs one complete natural mouse path. A return value of -1 means the
; target was displaced or focus changed and NaturalClick should try again.
LLARS_NaturalClickAttempt(x, y, button, runeScapeHwnd, runBound := false, coordinateSection := "")
{
	if (runBound && IsFunc("LLARS_RunActive") && !LLARS_RunActive())
		return 0

	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before NaturalClick attempt", runeScapeHwnd))
		return -1

	MouseGetPos, startX, startY
	LLARS_DeveloperAction("MouseMove || (" . startX . ", " . startY . ") > (" . x . ", " . y . ")")
	dx := x - startX
	dy := y - startY
	distance := Sqrt((dx * dx) + (dy * dy))
	if (distance <= 2)
	{
		MouseMove, %x%, %y%, 0
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
		LLARS_HumanMouseClick(button)
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
	movementResult := 1
	; Keep framework timers from interrupting the path and let the explicit
	; movement profile control the real elapsed time without hidden mouse delay.
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
			MouseMove, %currentX%, %currentY%, 0
			previousX := currentX
			previousY := currentY
		}

		targetElapsed := Round(duration * t)
		actualElapsed := A_TickCount - startTime
		delay := targetElapsed - actualElapsed
		if (delay < 1)
			delay := 1
		if (delay > 35)
			delay := 35
		DllCall("Sleep", "UInt", delay)
	}
	if (movementResult != 1)
	{
		LLARS_NaturalMovementTimingEnd()
		return movementResult
	}

	if (!LLARS_NaturalClickRuneScapeGuard("RuneScape lost focus before NaturalClick final position", runeScapeHwnd))
	{
		LLARS_NaturalMovementTimingEnd()
		return -1
	}
	MouseMove, %x%, %y%, 0
	LLARS_NaturalMovementTimingEnd()
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
	LLARS_HumanMouseClick(button)
	LLARS_DeveloperNaturalClick(x, y, button, coordinateSection)
	return true
}

; Moves the mouse naturally without clicking for anti-AFK activity. This is a
; framework-level variant so any LLARS script can use the same natural idle move.
AntiAFKNaturalClick(x, y)
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
		MouseMove, %x%, %y%, 0
		return true
	}

	movementProfile := LLARS_NaturalMovementProfile(distance, "AntiAFKNaturalClick")
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
			MouseMove, %currentX%, %currentY%, 0
			previousX := currentX
			previousY := currentY
		}

		targetElapsed := Round(duration * t)
		actualElapsed := A_TickCount - startTime
		delay := targetElapsed - actualElapsed

		if (delay < 1)
			delay := 1

		if (delay > 35)
			delay := 35
		DllCall("Sleep", "UInt", delay)
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
	MouseMove, %x%, %y%, 0
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
