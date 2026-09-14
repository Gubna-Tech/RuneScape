; ================================================================
; |     LLARS CREATOR API     -     LLARS CREATOR API            |
; ================================================================

; ================================================================
; |     CONFIGURATION     -     CONFIGURATION                    |
; ================================================================
; Returns either the current script Config.ini or the shared LLARS Config.ini.
; Creator-facing helpers use "script" by default. Pass "shared" only when a
; script intentionally needs a root LLARS setting.
LLARS_ConfigPath(scope := "script")
{
	global LLARS_SCRIPT_DIR, LLARS_CONFIG_FILE

	scope := Trim(scope)
	StringLower, scope, scope

	if scope in shared,llars,root
		return LLARS_CONFIG_FILE

	return LLARS_SCRIPT_DIR . "\Config.ini"
}

; Reads one configuration value without exposing IniRead boilerplate to scripts.
LLARS_ConfigRead(section, key, default := "ERROR", scope := "script")
{
	configFile := LLARS_ConfigPath(scope)
	if !FileExist(configFile)
		return default

	IniRead, value, %configFile%, %section%, %key%, %default%
	return value
}

; Reads a trimmed text value. Set required=true when an empty/missing value
; should be surfaced through the existing CONFIG ERROR path.
LLARS_ConfigReadString(section, key, default := "", required := false, scope := "script")
{
	value := LLARS_ConfigRead(section, key, "ERROR", scope)
	if (value = "ERROR")
	{
		if (required)
			Log("CONFIG ERROR", section . " " . key . " is missing")
		return default
	}

	value := Trim(value)
	if (required && value = "")
	{
		Log("CONFIG ERROR", section . " " . key . " is blank")
		return default
	}

	return value
}

; Reads a whole-number setting without silently rounding decimals.
LLARS_ConfigReadInteger(section, key, default := "", minAllowed := "", maxAllowed := "", scope := "script")
{
	value := Trim(LLARS_ConfigRead(section, key, "ERROR", scope))
	if (value = "ERROR" || value = "")
	{
		if (default = "")
			Log("CONFIG ERROR", section . " " . key . " is missing")
		return default
	}

	if value is not integer
	{
		Log("CONFIG ERROR", section . " " . key . " must be an integer: " . value)
		return default
	}

	value += 0
	if (minAllowed != "" && value < minAllowed)
	{
		Log("CONFIG ERROR", section . " " . key . " is below " . minAllowed . ": " . value)
		return default
	}

	if (maxAllowed != "" && value > maxAllowed)
	{
		Log("CONFIG ERROR", section . " " . key . " is above " . maxAllowed . ": " . value)
		return default
	}

	return value
}

; Reads a boolean value using creator-facing Read naming. Invalid values are
; reported through the existing CONFIG ERROR logging path and fall back safely.
LLARS_ConfigReadBool(section, key := "option", default := false, scope := "script")
{
	return LLARS_ConfigBool(section, key, default, scope)
}

; Reads one numeric value and optionally enforces an allowed minimum/maximum.
; An empty minAllowed/maxAllowed means that side is not constrained.
LLARS_ConfigReadNumber(section, key, default := "", minAllowed := "", maxAllowed := "", scope := "script")
{
	value := Trim(LLARS_ConfigRead(section, key, "ERROR", scope))
	if (value = "ERROR" || value = "")
	{
		if (default = "")
			Log("CONFIG ERROR", section . " " . key . " is missing")
		return default
	}

	if value is not number
	{
		Log("CONFIG ERROR", section . " " . key . " must be numeric: " . value)
		return default
	}

	value += 0
	if (minAllowed != "" && value < minAllowed)
	{
		Log("CONFIG ERROR", section . " " . key . " is below " . minAllowed . ": " . value)
		return default
	}

	if (maxAllowed != "" && value > maxAllowed)
	{
		Log("CONFIG ERROR", section . " " . key . " is above " . maxAllowed . ": " . value)
		return default
	}

	return value
}

; Reads and validates a configured hotkey. Disabled optional sections return
; an empty string so creators can use one simple conditional call.
LLARS_ConfigReadHotkey(section, key := "hotkey", scope := "script")
{
	if !LLARS_ConfigEnabled(section, true, scope)
		return ""

	hotkey := Trim(LLARS_ConfigRead(section, key, "", scope))
	if (hotkey = "")
	{
		Log("CONFIG ERROR", section . " " . key . " is missing")
		return ""
	}

	if IsFunc("LLARS_IsValidConfigHotkey")
	{
		if !LLARS_IsValidConfigHotkey(hotkey)
		{
			Log("CONFIG ERROR", section . " " . key . " is invalid: " . hotkey)
			return ""
		}
	}

	return hotkey
}

; Reads and validates an RGB color. When key is omitted, typed color sections
; use the same color-key discovery as the LLARS configuration GUI.
LLARS_ConfigReadColor(section, key := "", scope := "script")
{
	if !LLARS_ConfigEnabled(section, true, scope)
		return ""

	scopeName := Trim(scope)
	StringLower, scopeName, scopeName

	if (key = "")
	{
		if (scopeName = "script" && IsFunc("LLARS_GetColorKey"))
			key := LLARS_GetColorKey(LLARS_ConfigPath(scope), section)
		if (key = "")
			key := "color"
	}

	colorValue := Trim(LLARS_ConfigRead(section, key, "", scope))
	if !RegExMatch(colorValue, "i)^0x[0-9A-F]{6}$")
	{
		Log("CONFIG ERROR", section . " " . key . " is invalid: " . colorValue)
		return ""
	}

	StringUpper, colorValue, colorValue
	return colorValue
}

; Reads a true/false setting and returns an actual boolean value.
LLARS_ConfigBool(section, key, default := false, scope := "script")
{
	defaultText := default ? "true" : "false"
	value := LLARS_ConfigRead(section, key, defaultText, scope)
	value := Trim(value)
	StringLower, value, value

	if (value = "true")
		return true
	if (value = "false")
		return false

	Log("CONFIG ERROR", section . " " . key . " must be true or false: " . value)
	return default
}

; Returns whether a typed/optional section is currently enabled. A missing
; option key is treated as enabled so ordinary coordinate/timer sections work
; without requiring option=true. Dependency chains are honored automatically.
LLARS_ConfigEnabled(section, default := true, scope := "script")
{
	return LLARS_ConfigEnabledInternal(section, default, scope, 0)
}

LLARS_ConfigEnabledInternal(section, default, scope, depth)
{
	if (depth > 10)
	{
		Log("CONFIG ERROR", "Dependency chain is too deep for section: " . section)
		return false
	}

	configFile := LLARS_ConfigPath(scope)
	defaultText := default ? "true" : "false"
	IniRead, option, %configFile%, %section%, option, %defaultText%
	option := Trim(option)
	StringLower, option, option

	if (option = "false")
		return false
	if (option != "true")
	{
		Log("CONFIG ERROR", section . " option must be true or false: " . option)
		return default
	}

	IniRead, depends, %configFile%, %section%, depends, ERROR
	depends := Trim(depends)
	if (depends != "ERROR" && depends != "")
		return LLARS_ConfigEnabledInternal(depends, true, scope, depth + 1)

	return true
}

; Reads and validates a configured min/max range.
LLARS_ConfigRange(section, ByRef minValue, ByRef maxValue, scope := "script")
{
	minValue := LLARS_ConfigRead(section, "min", "ERROR", scope)
	maxValue := LLARS_ConfigRead(section, "max", "ERROR", scope)
	minValue := Trim(minValue)
	maxValue := Trim(maxValue)

	if minValue is not number
	{
		Log("CONFIG ERROR", section . " minimum is invalid: " . minValue)
		return false
	}

	if maxValue is not number
	{
		Log("CONFIG ERROR", section . " maximum is invalid: " . maxValue)
		return false
	}

	minValue += 0
	maxValue += 0
	if (minValue < 0 || maxValue < minValue)
	{
		Log("CONFIG ERROR", section . " range is invalid: " . minValue . "-" . maxValue)
		return false
	}

	return true
}

; Preferred creator-facing name for reading a configured min/max pair.
LLARS_ConfigReadRange(section, ByRef minValue, ByRef maxValue, scope := "script")
{
	return LLARS_ConfigRange(section, minValue, maxValue, scope)
}

; Resolves either a fixed x/y coordinate or a randomized xmin/xmax/ymin/ymax
; rectangle from a coordinate section.
LLARS_ConfigPoint(section, ByRef x, ByRef y, scope := "script")
{
	if !LLARS_ConfigEnabled(section, true, scope)
		return false

	xValue := Trim(LLARS_ConfigRead(section, "x", "ERROR", scope))
	yValue := Trim(LLARS_ConfigRead(section, "y", "ERROR", scope))

	if (xValue != "ERROR" && yValue != "ERROR" && xValue != "" && yValue != "")
	{
		if xValue is not number
		{
			Log("CONFIG ERROR", section . " x coordinate is invalid: " . xValue)
			return false
		}
		if yValue is not number
		{
			Log("CONFIG ERROR", section . " y coordinate is invalid: " . yValue)
			return false
		}

		x := Round(xValue + 0)
		y := Round(yValue + 0)
		return true
	}

	xmin := Trim(LLARS_ConfigRead(section, "xmin", "ERROR", scope))
	xmax := Trim(LLARS_ConfigRead(section, "xmax", "ERROR", scope))
	ymin := Trim(LLARS_ConfigRead(section, "ymin", "ERROR", scope))
	ymax := Trim(LLARS_ConfigRead(section, "ymax", "ERROR", scope))

	if xmin is not number
	{
		Log("CONFIG ERROR", section . " xmin is invalid: " . xmin)
		return false
	}
	if xmax is not number
	{
		Log("CONFIG ERROR", section . " xmax is invalid: " . xmax)
		return false
	}
	if ymin is not number
	{
		Log("CONFIG ERROR", section . " ymin is invalid: " . ymin)
		return false
	}
	if ymax is not number
	{
		Log("CONFIG ERROR", section . " ymax is invalid: " . ymax)
		return false
	}

	xmin := Round(xmin + 0)
	xmax := Round(xmax + 0)
	ymin := Round(ymin + 0)
	ymax := Round(ymax + 0)
	if (xmax < xmin || ymax < ymin)
	{
		Log("CONFIG ERROR", section . " coordinate range is invalid")
		return false
	}

	Random, x, %xmin%, %xmax%
	Random, y, %ymin%, %ymax%
	return true
}

; Preferred creator-facing name for resolving a fixed or randomized point.
LLARS_ConfigReadPoint(section, ByRef x, ByRef y, scope := "script")
{
	return LLARS_ConfigPoint(section, x, y, scope)
}

; ================================================================
; |     TIMING     -     TIMING     -     TIMING                  |
; ================================================================
; Reads a configured timer, randomizes it, records the exact framework action,
; and sleeps. Set final=true for the final deterministic sleep in a RunCount
; loop so LLARS can hand the estimate display to an exact countdown.
LLARS_Sleep(section, final := false, scope := "script")
{
	global EstFinalSleepActive, EstFinalSleepEndTick
	global LLARS_DeveloperLastSleepValue, LLARS_DeveloperLastSleepName

	if !LLARS_ConfigEnabled(section, true, scope)
		return 0
	if !LLARS_ConfigReadRange(section, minValue, maxValue, scope)
		return 0

	Random, sleepAmount, %minValue%, %maxValue%
	sleepAmount := Round(sleepAmount)
	LLARS_DeveloperAction(section . " || " . minValue . "-" . maxValue . " ms || " . sleepAmount)
	LLARS_DeveloperLastSleepValue := sleepAmount
	LLARS_DeveloperLastSleepName := section

	if (final)
	{
		EstFinalSleepActive := true
		EstFinalSleepEndTick := A_TickCount + sleepAmount
		Gosub, UpdateEstimatedTime
	}

	Sleep, %sleepAmount%
	return sleepAmount
}

; Returns one randomized interval for a SetTimer-based script. Disabled timer
; sections return 0, allowing a single simple enable/schedule pattern.
LLARS_TimerInterval(section, scope := "script")
{
	if !LLARS_ConfigEnabled(section, true, scope)
		return 0
	if !LLARS_ConfigReadRange(section, minValue, maxValue, scope)
		return 0

	Random, timerInterval, %minValue%, %maxValue%
	timerInterval := Round(timerInterval)
	LLARS_DeveloperAction("Timer || " . section . " || " . minValue . "-" . maxValue . " ms || " . timerInterval)
	return timerInterval
}

; ================================================================
; |     INPUT / STATUS     -     INPUT / STATUS                  |
; ================================================================
; Clicks a configured fixed point or randomized coordinate rectangle using the
; RuneScape-only NaturalClick safety checks.
LLARS_Click(section, button := "left", scope := "script")
{
	global LLARS_RUNNING

	; Creator-facing task clicks are only valid during an active LLARS run.
	; This prevents a timer/completion event from allowing a delayed action to
	; resume and click after the run has already ended.
	if (!LLARS_RUNNING)
		return false

	if !LLARS_ConfigReadPoint(section, x, y, scope)
		return false

	return NaturalClick(x, y, button)
}

; Updates the standard LLARS status row without requiring scripts to know the
; underlying GUI control names. Activity defaults to the current script name.
LLARS_SetStatus(status, activity := "")
{
	global scriptname
	static lastStatus := "", lastActivity := ""

	if (activity = "")
		activity := scriptname

	GuiControl,, ScriptBlue, %activity%
	GuiControl,, State3, %status%

	if (status != lastStatus || activity != lastActivity)
	{
		LLARS_DeveloperAction("Status || " . activity . " || " . status)
		lastStatus := status
		lastActivity := activity
	}

	return true
}

; ================================================================
; |     PIXEL / COLOR     -     PIXEL / COLOR                    |
; ================================================================
; Returns true when a configured pixel coordinate currently matches a configured
; RGB color. This keeps IniRead/PixelGetColor boilerplate out of creator scripts.
LLARS_PixelMatches(coordinateSection, colorSection, scope := "script")
{
	; Never sample another application's client area. Pixel/color creator API
	; calls are valid only while RuneScape is the active window.
	if !LLARS_IsRuneScapeActive()
		return false

	if !LLARS_ConfigEnabled(coordinateSection, true, scope)
		return false
	if !LLARS_ConfigEnabled(colorSection, true, scope)
		return false

	x := Trim(LLARS_ConfigRead(coordinateSection, "x", "ERROR", scope))
	y := Trim(LLARS_ConfigRead(coordinateSection, "y", "ERROR", scope))
	if x is not number
	{
		Log("CONFIG ERROR", coordinateSection . " x coordinate is invalid: " . x)
		return false
	}
	if y is not number
	{
		Log("CONFIG ERROR", coordinateSection . " y coordinate is invalid: " . y)
		return false
	}

	x := Round(x + 0)
	y := Round(y + 0)
	targetColor := LLARS_ConfigReadColor(colorSection, "", scope)
	if (targetColor = "")
		return false

	PixelGetColor, currentColor, %x%, %y%, RGB
	StringUpper, currentColor, currentColor

	if (currentColor = targetColor)
		return true

	return false
}
