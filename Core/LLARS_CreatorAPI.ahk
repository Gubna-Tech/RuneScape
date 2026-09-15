; ================================================================
; |     LLARS CREATOR API     -     LLARS CREATOR API            |
; ================================================================

; ================================================================
; |     INTERNAL API SUPPORT     -     INTERNAL API SUPPORT      |
; ================================================================
; Routes creator-API configuration errors through both the normal log and the
; shared Developer Mode action stream. Startup validation remains authoritative;
; this only makes runtime API failures immediately visible while developing.
LLARS_CreatorConfigError(message)
{
	message := Trim(message)
	if (message = "")
		message := "Unknown creator API configuration error"

	Log("CONFIG ERROR", message)
	if IsFunc("LLARS_DeveloperAction")
		LLARS_DeveloperAction("Config Error || " . message)
	return false
}

; Records a blocked creator input action without sending anything to another
; application. Input helpers use this when no active LLARS run/RuneScape target
; is available.
LLARS_CreatorInputBlocked(action, reason)
{
	action := Trim(action)
	reason := Trim(reason)
	if (action = "")
		action := "Input"
	if (reason = "")
		reason := "Input safety check failed"

	Log("INPUT BLOCKED", action . " | " . reason)
	if IsFunc("LLARS_DeveloperAction")
		LLARS_DeveloperAction("Input Blocked || " . action . " || " . reason)
	return false
}

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

; Returns true when a named section exists in the selected configuration file.
LLARS_ConfigSectionExists(section, scope := "script")
{
	section := Trim(section)
	if (section = "")
		return false

	configFile := LLARS_ConfigPath(scope)
	if !FileExist(configFile)
		return false

	IniRead, sections, %configFile%
	Loop, Parse, sections, `n, `r
	{
		if (Trim(A_LoopField) = section)
			return true
	}

	return false
}

; Returns true when a key exists inside a named configuration section.
LLARS_ConfigKeyExists(section, key, scope := "script")
{
	section := Trim(section)
	key := Trim(key)
	if (section = "" || key = "")
		return false

	configFile := LLARS_ConfigPath(scope)
	if !FileExist(configFile)
		return false
	if !LLARS_ConfigSectionExists(section, scope)
		return false

	IniRead, sectionData, %configFile%, %section%
	Loop, Parse, sectionData, `n, `r
	{
		line := A_LoopField
		equalsPos := InStr(line, "=")
		if (!equalsPos)
			continue
		lineKey := Trim(SubStr(line, 1, equalsPos - 1))
		if (lineKey = key)
			return true
	}

	return false
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
			LLARS_CreatorConfigError(section . " " . key . " is missing")
		return default
	}

	value := Trim(value)
	if (required && value = "")
	{
		LLARS_CreatorConfigError(section . " " . key . " is blank")
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
			LLARS_CreatorConfigError(section . " " . key . " is missing")
		return default
	}

	if value is not integer
	{
		LLARS_CreatorConfigError(section . " " . key . " must be an integer: " . value)
		return default
	}

	value += 0
	if (minAllowed != "" && value < minAllowed)
	{
		LLARS_CreatorConfigError(section . " " . key . " is below " . minAllowed . ": " . value)
		return default
	}

	if (maxAllowed != "" && value > maxAllowed)
	{
		LLARS_CreatorConfigError(section . " " . key . " is above " . maxAllowed . ": " . value)
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
			LLARS_CreatorConfigError(section . " " . key . " is missing")
		return default
	}

	if value is not number
	{
		LLARS_CreatorConfigError(section . " " . key . " must be numeric: " . value)
		return default
	}

	value += 0
	if (minAllowed != "" && value < minAllowed)
	{
		LLARS_CreatorConfigError(section . " " . key . " is below " . minAllowed . ": " . value)
		return default
	}

	if (maxAllowed != "" && value > maxAllowed)
	{
		LLARS_CreatorConfigError(section . " " . key . " is above " . maxAllowed . ": " . value)
		return default
	}

	return value
}

; Reads a value that must match one of the supplied choices. choices may be
; an AutoHotkey array/object or a pipe-delimited string such as "One|Two|Three".
; The canonical value from choices is returned so creator code gets predictable
; capitalization even when the Config.ini value uses different case.
LLARS_ConfigReadChoice(section, key, choices, default := "", required := false, scope := "script")
{
	value := LLARS_ConfigReadString(section, key, default, required, scope)
	if (value = "" && default = "")
		return default

	allowedText := ""
	if IsObject(choices)
	{
		for _, choice in choices
		{
			choice := Trim(choice)
			if (choice = "")
				continue
			if (allowedText != "")
				allowedText .= "|"
			allowedText .= choice
			if (value = choice)
				return choice
		}
	}
	else
	{
		Loop, Parse, choices, |
		{
			choice := Trim(A_LoopField)
			if (choice = "")
				continue
			if (allowedText != "")
				allowedText .= "|"
			allowedText .= choice
			if (value = choice)
				return choice
		}
	}

	LLARS_CreatorConfigError(section . " " . key . " is not an allowed value: " . value . " | Allowed=" . allowedText)
	return default
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
		LLARS_CreatorConfigError(section . " " . key . " is missing")
		return ""
	}

	if IsFunc("LLARS_IsValidConfigHotkey")
	{
		if !LLARS_IsValidConfigHotkey(hotkey)
		{
			LLARS_CreatorConfigError(section . " " . key . " is invalid: " . hotkey)
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
		LLARS_CreatorConfigError(section . " " . key . " is invalid: " . colorValue)
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

	LLARS_CreatorConfigError(section . " " . key . " must be true or false: " . value)
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
		LLARS_CreatorConfigError("Dependency chain is too deep for section: " . section)
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
		LLARS_CreatorConfigError(section . " option must be true or false: " . option)
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
		LLARS_CreatorConfigError(section . " minimum is invalid: " . minValue)
		return false
	}

	if maxValue is not number
	{
		LLARS_CreatorConfigError(section . " maximum is invalid: " . maxValue)
		return false
	}

	minValue += 0
	maxValue += 0
	if (minValue < 0 || maxValue < minValue)
	{
		LLARS_CreatorConfigError(section . " range is invalid: " . minValue . "-" . maxValue)
		return false
	}

	return true
}

; Preferred creator-facing name for reading a configured min/max pair.
LLARS_ConfigReadRange(section, ByRef minValue, ByRef maxValue, scope := "script")
{
	return LLARS_ConfigRange(section, minValue, maxValue, scope)
}

; Chooses a rectangle point using the system-backed random source while only
; avoiding exact recent point repeats. Reusing an X or Y value by itself is
; allowed because forced axis alternation looks less natural than real aiming.
LLARS_CreatorHumanPoint(section, scope, xmin, xmax, ymin, ymax, ByRef x, ByRef y)
{
	static recentPoints := {}

	if !IsFunc("LLARS_HumanRandomInt")
	{
		Random, x, %xmin%, %xmax%
		Random, y, %ymin%, %ymax%
		return true
	}

	pointCount := (xmax - xmin + 1) * (ymax - ymin + 1)
	if (pointCount >= 25)
		avoidRecent := 4
	else if (pointCount >= 9)
		avoidRecent := 2
	else
		avoidRecent := 0

	historyKey := scope . "|" . section
	if !recentPoints.HasKey(historyKey)
		recentPoints[historyKey] := []
	history := recentPoints[historyKey]

	attempts := 0
	Loop
	{
		x := LLARS_HumanRandomInt(xmin, xmax, "", 0)
		y := LLARS_HumanRandomInt(ymin, ymax, "", 0)
		repeatedPoint := false

		if (avoidRecent > 0)
		{
			for _, previousPoint in history
			{
				if (x = previousPoint.X && y = previousPoint.Y)
				{
					repeatedPoint := true
					break
				}
			}
		}

		if (!repeatedPoint || attempts >= 10)
			break
		attempts++
	}

	if (avoidRecent > 0)
	{
		while (history.Length() >= avoidRecent)
			history.RemoveAt(1)
		history.Push({X: x, Y: y})
		recentPoints[historyKey] := history
	}

	return true
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
			LLARS_CreatorConfigError(section . " x coordinate is invalid: " . xValue)
			return false
		}
		if yValue is not number
		{
			LLARS_CreatorConfigError(section . " y coordinate is invalid: " . yValue)
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
		LLARS_CreatorConfigError(section . " xmin is invalid: " . xmin)
		return false
	}
	if xmax is not number
	{
		LLARS_CreatorConfigError(section . " xmax is invalid: " . xmax)
		return false
	}
	if ymin is not number
	{
		LLARS_CreatorConfigError(section . " ymin is invalid: " . ymin)
		return false
	}
	if ymax is not number
	{
		LLARS_CreatorConfigError(section . " ymax is invalid: " . ymax)
		return false
	}

	xmin := Round(xmin + 0)
	xmax := Round(xmax + 0)
	ymin := Round(ymin + 0)
	ymax := Round(ymax + 0)
	if (xmax < xmin || ymax < ymin)
	{
		LLARS_CreatorConfigError(section . " coordinate range is invalid")
		return false
	}

	return LLARS_CreatorHumanPoint(section, scope, xmin, xmax, ymin, ymax, x, y)
}

; Preferred creator-facing name for resolving a fixed or randomized point.
LLARS_ConfigReadPoint(section, ByRef x, ByRef y, scope := "script")
{
	return LLARS_ConfigPoint(section, x, y, scope)
}

; ================================================================
; |     RUN STATE     -     RUN STATE     -     RUN STATE          |
; ================================================================
; Returns true only while a LLARS run is active and not paused. Set
; requireRuneScape=true when the caller also needs the game to be the active
; foreground window before continuing.
LLARS_RunActive(requireRuneScape := false)
{
	global LLARS_RUNNING, LLARS_PAUSED

	if (!LLARS_RUNNING || LLARS_PAUSED)
		return false
	if (requireRuneScape && !LLARS_IsRuneScapeActive())
		return false

	return true
}

; Captures the exact RuneScape client used for this run and brings it to the
; foreground before automation begins. The captured HWND remains the run target
; so later focus recovery cannot accidentally switch to a different client.
LLARS_ActivateRuneScapeAtRunStart()
{
	global LLARS_RunRuneScapeHwnd

	if !LLARS_RunActive()
		return false

	runeScapeHwnd := LLARS_FindRuneScapeWindow()
	if (!runeScapeHwnd)
	{
		LLARS_CreatorInputBlocked("Run start", "RuneScape window was not found")
		return false
	}

	LLARS_RunRuneScapeHwnd := runeScapeHwnd
	return LLARS_WaitForRuneScape("Run start")
}

; Framework focus gate for every game-facing action. While a run is active,
; RuneScape owns automation focus: the user may Alt-Tab during waits, but when
; the next LLARS action becomes due this function restores the exact RuneScape
; client selected at run start and verifies it is foreground before returning.
; Pause/Exit remain the explicit ways to stop LLARS from reclaiming focus.
LLARS_WaitForRuneScape(action := "Automation", requireRun := true)
{
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_RunRuneScapeHwnd
	global LLARS_CreatorCurrentStatus, LLARS_CreatorCurrentActivity

	if (requireRun && !LLARS_RUNNING)
	{
		LLARS_CreatorInputBlocked(action, "No active LLARS run")
		return false
	}

	runeScapeHwnd := LLARS_RunRuneScapeHwnd
	if (runeScapeHwnd)
	{
		if (!DllCall("IsWindow", "Ptr", runeScapeHwnd) || !LLARS_IsRuneScapeWindow(runeScapeHwnd))
		{
			LLARS_CreatorInputBlocked(action, "The RuneScape window selected for this run is no longer available")
			return false
		}
	}
	else
	{
		runeScapeHwnd := LLARS_FindRuneScapeWindow()
		if (!runeScapeHwnd)
		{
			LLARS_CreatorInputBlocked(action, "RuneScape window was not found")
			return false
		}
		LLARS_RunRuneScapeHwnd := runeScapeHwnd
	}

	if (DllCall("GetForegroundWindow", "Ptr") = runeScapeHwnd)
		return true

	previousStatus := LLARS_CreatorCurrentStatus
	previousActivity := LLARS_CreatorCurrentActivity
	if (previousStatus = "")
		previousStatus := "Running"

	LLARS_CreatorCurrentStatus := "Restoring RuneScape"
	GuiControl, 1:, State3, Restoring RuneScape
	Log("FOCUS RECLAIM", action . " restoring RuneScape foreground")

	; Prevent managed timers from entering another creator callback while focus
	; recovery is in progress. Hotkeys such as Pause and Exit remain available.
	Thread, NoTimers, true
	Loop
	{
		if (requireRun && !LLARS_RUNNING)
			break

		; If the user pauses while an action is waiting to dispatch, do not keep
		; stealing focus. Resume focus recovery only after the run is resumed.
		if (LLARS_PAUSED)
		{
			Sleep, 100
			continue
		}

		if (!DllCall("IsWindow", "Ptr", runeScapeHwnd) || !LLARS_IsRuneScapeWindow(runeScapeHwnd))
			break

		WinGet, minMaxState, MinMax, ahk_id %runeScapeHwnd%
		if (minMaxState = -1)
			WinRestore, ahk_id %runeScapeHwnd%

		WinActivate, ahk_id %runeScapeHwnd%
		WinWaitActive, ahk_id %runeScapeHwnd%,, 0.5

		if (DllCall("GetForegroundWindow", "Ptr") = runeScapeHwnd)
			break

		Sleep, 100
	}
	Thread, NoTimers, false

	if (requireRun && !LLARS_RUNNING)
		return false

	if (LLARS_PAUSED)
		return false

	if (DllCall("GetForegroundWindow", "Ptr") != runeScapeHwnd)
	{
		LLARS_CreatorInputBlocked(action, "RuneScape could not be restored to the foreground")
		return false
	}

	LLARS_CreatorCurrentStatus := previousStatus
	LLARS_CreatorCurrentActivity := previousActivity
	GuiControl, 1:, State3, %previousStatus%
	Log("FOCUS RESTORED", action . " resumed in RuneScape")
	LLARS_DeveloperAction("Focus Reclaimed")
	return true
}


; Passive foreground gate used only by pixel/color detection. Unlike the normal
; LLARS focus gate, this function never activates, restores, or otherwise pulls
; RuneScape to the foreground. If the user Alt-Tabs away, pixel sampling simply
; waits until the exact RuneScape client selected for the run is foreground again.
LLARS_WaitForRuneScapePixelRead(action := "Pixel read", requireRun := true)
{
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_RunRuneScapeHwnd

	if (requireRun && !LLARS_RUNNING)
		return false

	runeScapeHwnd := LLARS_RunRuneScapeHwnd
	if (runeScapeHwnd)
	{
		if (!DllCall("IsWindow", "Ptr", runeScapeHwnd) || !LLARS_IsRuneScapeWindow(runeScapeHwnd))
		{
			LLARS_CreatorInputBlocked(action, "The RuneScape window selected for this run is no longer available")
			return false
		}
	}
	else
	{
		runeScapeHwnd := LLARS_FindRuneScapeWindow()
		if (!runeScapeHwnd)
		{
			LLARS_CreatorInputBlocked(action, "RuneScape window was not found")
			return false
		}
		LLARS_RunRuneScapeHwnd := runeScapeHwnd
	}

	Loop
	{
		if (requireRun && !LLARS_RUNNING)
			return false

		if (!DllCall("IsWindow", "Ptr", runeScapeHwnd) || !LLARS_IsRuneScapeWindow(runeScapeHwnd))
		{
			LLARS_CreatorInputBlocked(action, "The RuneScape window selected for this run is no longer available")
			return false
		}

		; Pause and Alt-Tab both suspend pixel sampling without changing focus.
		if (!LLARS_PAUSED && DllCall("GetForegroundWindow", "Ptr") = runeScapeHwnd)
			return true

		Sleep, 100
	}
}


; Resolves a creator callback supplied either as a function name or as an
; AutoHotkey function/bound-function object. Public lifecycle/timer helpers use
; this so creator scripts never need labels for executable callbacks.
LLARS_CreatorResolveCallback(callback, purpose := "Callback")
{
	if IsObject(callback)
		return callback

	callbackName := Trim(callback)
	if (callbackName != "" && IsFunc(callbackName))
		return Func(callbackName)

	LLARS_CreatorConfigError(purpose . " requires a valid function callback")
	return ""
}

; Runs a complete RunCount session around one creator callback. LLARS owns the
; start prompt, loop bookkeeping, runtime measurement, GUI counters, cleanup,
; and completion behavior. The callback receives one context object:
;   ctx.Iteration / ctx.Total / ctx.IsFirst / ctx.IsLast / ctx.Remaining
; Existing scripts may continue using LLARS_StartRun/BeginLoop/EndLoop directly
; while they are migrated to this lifecycle API.
LLARS_RunCount(callback)
{
	global LLARS_RUNNING, runcount3, count2

	callbackFn := LLARS_CreatorResolveCallback(callback, "LLARS_RunCount")
	if !IsObject(callbackFn)
		return false

	if !LLARS_StartRun()
		return false

	totalRuns := runcount3
	Loop, %totalRuns%
	{
		if (!LLARS_RUNNING)
			break

		iteration := A_Index
		if !LLARS_WaitForRuneScape("RunCount iteration " . iteration)
			break

		LLARS_BeginLoop()
		ctx := {Iteration: iteration
			, Total: totalRuns
			, IsFirst: (iteration = 1)
			, IsLast: (iteration = totalRuns)
			, Completed: (iteration - 1)
			, Remaining: (totalRuns - iteration)}

		try
			callbackFn.Call(ctx)
		catch error
		{
			LLARS_CreatorRunError(error, iteration, totalRuns)
			return false
		}

		if (!LLARS_RUNNING)
			break

		LLARS_EndLoop()
	}

	if (LLARS_RUNNING && count2 >= totalRuns)
	{
		LLARS_RunComplete()
		return true
	}

	return false
}

; Restores a safe idle state if a creator callback throws. This intentionally
; avoids the normal success/completion dialog and logout behavior.
LLARS_CreatorRunError(error, iteration := "", totalRuns := "")
{
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_RunStartTick
	global LLARS_RunRuneScapeHwnd

	message := "Creator callback failed"
	if IsObject(error)
	{
		if (error.Message != "")
			message .= ": " . error.Message
		if (error.Line != "")
			message .= " | Line=" . error.Line
	}
	if (iteration != "")
		message .= " | Iteration=" . iteration . "/" . totalRuns

	if IsFunc("LLARS_TimerStopAll")
		LLARS_TimerStopAll()

	; Countdown exists only in legacy timer-style scripts. Use a dynamic
	; timer target so AutoHotkey does not require the optional label at load time.
	legacyCountdownLabel := "Countdown"
	if IsLabel(legacyCountdownLabel)
		SetTimer, %legacyCountdownLabel%, Off

	; Keep estimator cleanup safe even if this API file is included without the
	; shared label library during isolated creator/API testing.
	estimatorTimerLabel := "UpdateEstimatedTime"
	if IsLabel(estimatorTimerLabel)
		SetTimer, %estimatorTimerLabel%, Off
	LLARS_RUNNING := false
	LLARS_PAUSED := false
	LLARS_RunStartTick := 0
	LLARS_RunRuneScapeHwnd := 0
	EnableButton()
	SetLLARSHOTKEYS("On")
	LLARS_SetStatus("Error")
	Log("SCRIPT ERROR", message)
	LLARS_DeveloperAction("Script Error || " . message)
	MsgBox, 4112, LLARS Script Error, %message%
	return false
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

	if !LLARS_RunActive()
		return 0
	if !LLARS_ConfigEnabled(section, true, scope)
		return 0
	if !LLARS_ConfigReadRange(section, minValue, maxValue, scope)
		return 0

	Random, sleepAmount, %minValue%, %maxValue%
	sleepAmount := Round(sleepAmount)
	LLARS_DeveloperAction(section . " || " . minValue . "-" . maxValue . " ms || " . sleepAmount . " ms")
	LLARS_DeveloperLastSleepValue := sleepAmount
	LLARS_DeveloperLastSleepName := section

	if (final)
	{
		EstFinalSleepActive := true
		EstFinalSleepEndTick := A_TickCount + sleepAmount
		Gosub, UpdateEstimatedTime
	}

	Sleep, %sleepAmount%
	if LLARS_RunActive()
		LLARS_WaitForRuneScape("Sleep " . section)
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
	LLARS_DeveloperAction("Timer || " . section . " || " . minValue . "-" . maxValue . " ms || " . timerInterval . " ms")
	return timerInterval
}

; Schedules a creator callback once after a randomized interval from the named
; timer section. Returns a numeric timer handle that can be passed to
; LLARS_TimerStop(), or 0 when the timer could not be scheduled.
LLARS_TimerOnce(section, callback, scope := "script")
{
	return LLARS_CreatorTimerScheduleCallback(section, callback, false, scope)
}

; Repeats a creator callback using a freshly randomized interval after every
; callback. The timer is implemented as chained one-shot callbacks rather than
; a fixed SetTimer period, so each cycle honors the configured min/max range.
; Returns a numeric timer handle or 0.
LLARS_TimerRepeat(section, callback, scope := "script")
{
	return LLARS_CreatorTimerScheduleCallback(section, callback, true, scope)
}

; Internal callback-timer scheduler used by LLARS_TimerOnce/LLARS_TimerRepeat.
LLARS_CreatorTimerScheduleCallback(section, callback, repeat := false, scope := "script")
{
	global LLARS_CreatorTimers, LLARS_CreatorTimerNextId

	section := Trim(section)
	if (section = "")
	{
		LLARS_CreatorConfigError("Callback timer requires a config section")
		return 0
	}

	callbackFn := LLARS_CreatorResolveCallback(callback, "Timer " . section)
	if !IsObject(callbackFn)
		return 0
	if !LLARS_RunActive()
		return 0

	interval := LLARS_TimerInterval(section, scope)
	if (interval <= 0)
		return 0

	if !IsObject(LLARS_CreatorTimers)
		LLARS_CreatorTimers := {}
	LLARS_CreatorTimerNextId += 1
	timerId := LLARS_CreatorTimerNextId
	timerKey := "Callback:" . timerId
	timerHandler := Func("LLARS_CreatorTimerDispatch").Bind(timerId)
	timerPeriod := -interval

	LLARS_CreatorTimers[timerKey] := {Kind: "Callback"
		, ID: timerId
		, Section: section
		, Callback: callbackFn
		, Handler: timerHandler
		, Interval: interval
		, Repeat: repeat
		, Scope: scope}

	SetTimer, %timerHandler%, %timerPeriod%
	timerMode := repeat ? "Repeating Random" : "One Shot"
	LLARS_DeveloperAction("Timer Scheduled || #" . timerId . " || " . section . " || " . interval . " ms || " . timerMode)
	return timerId
}

; Dispatches one creator callback timer. Repeating timers are rescheduled as a
; new one-shot timer after the callback, producing a fresh randomized interval.
LLARS_CreatorTimerDispatch(timerId)
{
	global LLARS_CreatorTimers

	timerKey := "Callback:" . timerId
	if (!IsObject(LLARS_CreatorTimers) || !LLARS_CreatorTimers.HasKey(timerKey))
		return

	timerInfo := LLARS_CreatorTimers[timerKey]
	if !LLARS_RunActive()
	{
		LLARS_TimerStop(timerId)
		return
	}

	if !LLARS_WaitForRuneScape("Timer " . timerInfo.Section)
	{
		LLARS_TimerStop(timerId)
		return
	}

	try
		timerInfo.Callback.Call()
	catch error
	{
		LLARS_TimerStop(timerId)
		LLARS_CreatorRunError(error)
		return
	}

	; The callback may have stopped itself or ended the run.
	if (!LLARS_RunActive() || !IsObject(LLARS_CreatorTimers) || !LLARS_CreatorTimers.HasKey(timerKey))
		return

	if (!timerInfo.Repeat)
	{
		LLARS_TimerStop(timerId)
		return
	}

	interval := LLARS_TimerInterval(timerInfo.Section, timerInfo.Scope)
	if (interval <= 0)
	{
		LLARS_TimerStop(timerId)
		return
	}

	timerInfo.Interval := interval
	LLARS_CreatorTimers[timerKey] := timerInfo
	timerHandler := timerInfo.Handler
	timerPeriod := -interval
	SetTimer, %timerHandler%, %timerPeriod%
	LLARS_DeveloperAction("Timer Rescheduled || #" . timerId . " || " . timerInfo.Section . " || " . interval . " ms")
}

; Compatibility API for existing label-based scripts. New creator code should
; use LLARS_TimerOnce() or LLARS_TimerRepeat() with Func("CallbackName").
; Managed legacy labels are dispatched through a function wrapper so RuneScape
; is reclaimed and verified at the moment the timer actually fires.
LLARS_TimerSchedule(labelName, section, repeat := false, scope := "script")
{
	global LLARS_CreatorTimers

	labelName := Trim(labelName)
	section := Trim(section)
	if (labelName = "" || section = "")
	{
		LLARS_CreatorConfigError("Timer schedule requires both a label and config section")
		return 0
	}

	if !IsLabel(labelName)
	{
		LLARS_CreatorConfigError("Timer label does not exist: " . labelName)
		return 0
	}

	if !LLARS_RunActive()
		return 0

	if !IsObject(LLARS_CreatorTimers)
		LLARS_CreatorTimers := {}

	; Re-scheduling the same managed label replaces its previous schedule.
	if (LLARS_CreatorTimers.HasKey(labelName))
		LLARS_TimerStop(labelName)

	interval := LLARS_TimerInterval(section, scope)
	if (interval <= 0)
		return 0

	timerHandler := Func("LLARS_CreatorLegacyTimerDispatch").Bind(labelName)
	timerPeriod := repeat ? interval : -interval
	LLARS_CreatorTimers[labelName] := {Kind: "LegacyLabel"
		, Label: labelName
		, Handler: timerHandler
		, Section: section
		, Interval: interval
		, Repeat: repeat
		, Scope: scope}
	SetTimer, %timerHandler%, %timerPeriod%

	timerMode := repeat ? "Repeating" : "One Shot"
	LLARS_DeveloperAction("Legacy Timer Scheduled || " . labelName . " || " . section . " || " . interval . " ms || " . timerMode)
	return interval
}

; Focus-safe dispatcher for label-based managed timers. Gosub can call a public
; label from inside a function in AutoHotkey v1, letting old scripts keep their
; label bodies while the timer itself gains the same RuneScape focus gate as
; callback timers.
LLARS_CreatorLegacyTimerDispatch(labelName)
{
	global LLARS_CreatorTimers

	if (!IsObject(LLARS_CreatorTimers) || !LLARS_CreatorTimers.HasKey(labelName))
		return

	timerInfo := LLARS_CreatorTimers[labelName]
	if !LLARS_RunActive()
	{
		LLARS_TimerStop(labelName)
		return
	}

	if !LLARS_WaitForRuneScape("Timer " . timerInfo.Section)
		return

	; A one-shot timer removes its tracking entry before entering creator code.
	; The timer function object is released automatically when this call returns.
	if (!timerInfo.Repeat)
		LLARS_CreatorTimers.Delete(labelName)

	if IsLabel(labelName)
		Gosub, %labelName%
}

; Stops one managed timer. Pass the numeric handle returned by
; LLARS_TimerOnce/LLARS_TimerRepeat. Existing label names remain supported.
LLARS_TimerStop(timerRef)
{
	global LLARS_CreatorTimers

	if !IsObject(LLARS_CreatorTimers)
		return false

	callbackKey := "Callback:" . timerRef
	if (LLARS_CreatorTimers.HasKey(callbackKey))
	{
		timerInfo := LLARS_CreatorTimers[callbackKey]
		timerHandler := timerInfo.Handler
		SetTimer, %timerHandler%, Delete
		LLARS_CreatorTimers.Delete(callbackKey)
		LLARS_DeveloperAction("Timer Stopped || #" . timerInfo.ID . " || " . timerInfo.Section)
		return true
	}

	labelName := Trim(timerRef)
	if (labelName = "" || !LLARS_CreatorTimers.HasKey(labelName))
		return false

	timerInfo := LLARS_CreatorTimers[labelName]
	if (timerInfo.Kind = "LegacyLabel" && IsObject(timerInfo.Handler))
	{
		timerHandler := timerInfo.Handler
		SetTimer, %timerHandler%, Delete
	}
	else
	{
		SetTimer, %labelName%, Off
	}
	LLARS_CreatorTimers.Delete(labelName)
	LLARS_DeveloperAction("Legacy Timer Stopped || " . labelName)
	return true
}

; Stops every timer created through the Creator API. Core calls this during run
; completion/startup cleanup and normal LLARS exit so creator timers cannot leak
; into a later run. Returns the number of tracked timers that were stopped.
LLARS_TimerStopAll()
{
	global LLARS_CreatorTimers

	if !IsObject(LLARS_CreatorTimers)
	{
		LLARS_CreatorTimers := {}
		return 0
	}

	stoppedCount := 0
	for timerKey, timerInfo in LLARS_CreatorTimers
	{
		if (timerInfo.Kind = "Callback")
		{
			timerHandler := timerInfo.Handler
			SetTimer, %timerHandler%, Delete
		}
		else if (timerInfo.Kind = "LegacyLabel" && IsObject(timerInfo.Handler))
		{
			timerHandler := timerInfo.Handler
			SetTimer, %timerHandler%, Delete
		}
		else
		{
			labelName := timerInfo.Label
			if (labelName = "")
				labelName := timerKey
			SetTimer, %labelName%, Off
		}
		stoppedCount++
	}

	LLARS_CreatorTimers := {}
	if (stoppedCount > 0)
		LLARS_DeveloperAction("Timer Cleanup || " . stoppedCount . " tracked timer(s)")

	return stoppedCount
}

; ================================================================
; |     INPUT / STATUS     -     INPUT / STATUS                  |
; ================================================================
; Activates and locks onto the RuneScape client immediately before a creator
; keyboard action. No key is sent unless the exact RuneScape HWND is active.
LLARS_CreatorPrepareKeyboardInput(action := "Keyboard")
{
	if !LLARS_WaitForRuneScape(action)
		return 0

	runeScapeHwnd := WinExist("A")
	if !LLARS_IsRuneScapeWindow(runeScapeHwnd)
	{
		LLARS_CreatorInputBlocked(action, "RuneScape lost focus before keyboard input")
		return 0
	}

	return runeScapeHwnd
}

; Dispatches keyboard input only while the exact RuneScape HWND captured by the
; focus gate is still the foreground window. If the user changes focus in the
; narrow gap between validation and dispatch, retry the gate instead of sending
; to the newly active application. All creator-facing keyboard APIs route here.
LLARS_CreatorSendInput(sendSequence, action := "Keyboard")
{
	Loop
	{
		runeScapeHwnd := LLARS_CreatorPrepareKeyboardInput(action)
		if (!runeScapeHwnd)
			return false

		; A small lead-in varies the gap before the physical key transition. The
		; final exact-HWND check happens after this delay so focus can never be
		; stolen during the humanized timing window.
		if IsFunc("LLARS_HumanTiming")
			leadIn := LLARS_HumanTiming(7, 31, "Keyboard.LeadIn", 0.025, 38, 72)
		else
		{
			Random, leadIn, 7, 31
		}
		Sleep, %leadIn%

		; GetForegroundWindow is checked immediately before SendEvent. This exact-
		; HWND comparison is stricter than a title check and prevents another
		; RuneScape client or unrelated application from receiving the action.
		if (DllCall("GetForegroundWindow", "Ptr") != runeScapeHwnd)
		{
			Log("KEYBOARD INPUT RETRY", action . " focus changed before dispatch")
			continue
		}

		if IsFunc("LLARS_HumanTiming")
		{
			keyDelay := LLARS_HumanTiming(11, 34, "Keyboard.InterKey", 0.020, 38, 58)
			keyHold := LLARS_HumanTiming(43, 112, "Keyboard.Hold", 0.055, 120, 188)
		}
		else
		{
			Random, keyDelay, 11, 34
			Random, keyHold, 43, 112
		}

		if IsFunc("LLARS_HumanizeTimingEnding")
		{
			keyHoldMinimum := (keyHold >= 120) ? 120 : 43
			keyHoldMaximum := (keyHold >= 120) ? 188 : 112
			keyHold := LLARS_HumanizeTimingEnding(keyHold, keyHoldMinimum, keyHoldMaximum, "Keyboard.Hold")
		}

		previousKeyDelay := A_KeyDelay
		previousKeyDuration := A_KeyDuration
		SetKeyDelay, %keyDelay%, %keyHold%
		SendEvent, %sendSequence%
		SetKeyDelay, %previousKeyDelay%, %previousKeyDuration%

		; Explicit key-down/key-up sends represent a real held state rather than
		; a normal timed key press. Feed those transitions into the Developer key
		; tracker directly so a held Prayer key logs one press and its later release
		; instead of reporting a misleading synthetic hold duration.
		if RegExMatch(sendSequence, "i)^\{([^{}]+)\s+(down|up)\}$", keyStateMatch)
		{
			stateKey := Trim(keyStateMatch1)
			stateDirection := keyStateMatch2
			StringLower, stateDirection, stateDirection
			stateVK := GetKeyVK(stateKey)
			if (stateVK && IsFunc("LLARS_DeveloperScriptKey"))
				LLARS_DeveloperScriptKey(stateVK, stateDirection = "up")
		}
		else
			Log("KEY TIMING", action . " | Hold=" . keyHold . " ms")
		return true
	}
}

; Returns true when a plain AutoHotkey key name can be sent safely through the
; creator API. Modifier combinations belong in LLARS_PressHotkey().
LLARS_CreatorValidKeyName(keyName)
{
	keyName := Trim(keyName)
	if (keyName = "")
		return false

	; Mouse clicks belong in LLARS_Click() so they keep NaturalClick safety.
	if keyName in LButton,RButton,MButton,XButton1,XButton2
		return false
	if keyName in WheelUp,WheelDown,WheelLeft,WheelRight
		return true
	if (GetKeyVK(keyName) || GetKeySC(keyName))
		return true

	return false
}

; Converts an AutoHotkey hotkey expression such as ^+D or !F1 into the matching
; Send sequence. Hotkey-only prefixes (~ * $) are ignored for sending while
; left/right modifier prefixes (< >) are preserved.
LLARS_CreatorHotkeySendSequence(hotkey)
{
	hotkey := Trim(hotkey)
	if (hotkey = "")
		return ""

	hotkey := RegExReplace(hotkey, "i)\s+Up$")
	hotkey := RegExReplace(hotkey, "^[~*$]+")
	modifiers := ""

	Loop
	{
		if !RegExMatch(hotkey, "^([<>]?[\^!+#])", modifier)
			break
		modifiers .= modifier
		hotkey := SubStr(hotkey, StrLen(modifier) + 1)
	}

	baseKey := Trim(hotkey)
	if !LLARS_CreatorValidKeyName(baseKey)
		return ""

	return modifiers . "{" . baseKey . "}"
}

; Presses one plain key while protecting unrelated applications from scripted
; input. Examples: LLARS_PressKey("Space"), LLARS_PressKey("Enter"),
; LLARS_PressKey("4"). Use LLARS_PressHotkey() for configured combinations.
LLARS_PressKey(keyName)
{
	keyName := Trim(keyName)
	if !LLARS_CreatorValidKeyName(keyName)
	{
		LLARS_CreatorConfigError("Invalid key name: " . keyName)
		return false
	}

	sendSequence := "{" . keyName . "}"
	if !LLARS_CreatorSendInput(sendSequence, "Key " . keyName)
		return false
	if keyName in WheelUp,WheelDown,WheelLeft,WheelRight
		LLARS_DeveloperAction("Mouse Wheel || " . keyName)
	Log("KEY", "Pressed " . keyName)
	return true
}

; Reads a typed hotkey section and presses that combination in RuneScape. This
; replaces the common IniRead + Send pattern in older scripts.
LLARS_PressHotkey(section, key := "hotkey", scope := "script")
{
	hotkey := LLARS_ConfigReadHotkey(section, key, scope)
	if (hotkey = "")
		return false

	sendSequence := LLARS_CreatorHotkeySendSequence(hotkey)
	if (sendSequence = "")
	{
		LLARS_CreatorConfigError(section . " " . key . " cannot be converted to a sendable hotkey: " . hotkey)
		return false
	}

	if !LLARS_CreatorSendInput(sendSequence, "Hotkey " . section)
		return false
	Log("HOTKEY", section . " = " . hotkey)
	return true
}

; Clicks a configured fixed point or randomized coordinate rectangle using the
; RuneScape-only NaturalClick safety checks.
LLARS_Click(section, button := "left", scope := "script")
{
	global LLARS_NaturalClickFocusLost

	; Creator-facing task clicks are only valid during an active LLARS run.
	; If the user changed focus during a wait, reclaim RuneScape before clicking.
	if !LLARS_RunActive()
		return false

	button := Trim(button)
	StringLower, button, button
	if button not in left,right
	{
		LLARS_CreatorConfigError("LLARS_Click button must be left or right: " . button)
		return false
	}

	if !LLARS_ConfigReadPoint(section, x, y, scope)
		return false

	Loop
	{
		if !LLARS_WaitForRuneScape("Click " . section)
			return false

		LLARS_NaturalClickFocusLost := false
		if NaturalClick(x, y, button, section, scope)
			return true

		; NaturalClick deliberately aborts if focus changes during mouse movement.
		; Once RuneScape is active again, restart that same intended click.
		if (!LLARS_NaturalClickFocusLost || !LLARS_RunActive())
			return false
	}
}

; Updates the standard LLARS status row without requiring scripts to know the
; underlying GUI control names. Activity defaults to the current script name.
LLARS_SetStatus(status, activity := "")
{
	global scriptname, LLARS_CreatorCurrentStatus, LLARS_CreatorCurrentActivity
	static lastStatus := "", lastActivity := ""

	if (activity = "")
		activity := scriptname

	LLARS_CreatorCurrentStatus := status
	LLARS_CreatorCurrentActivity := activity

	; The main LLARS GUI already has separate blue and red status controls.
	; Route script errors through the red controls instead of displaying Error
	; in the normal blue Running/working status field.
	normalizedStatus := Trim(status)
	StringLower, normalizedStatus, normalizedStatus
	if (normalizedStatus = "error")
	{
		GuiControl, 1:, ScriptBlue,
		GuiControl, 1:, State3,
		GuiControl, 1:, ScriptRed, %activity%
		GuiControl, 1:, State2, %status%
	}
	else
	{
		GuiControl, 1:, ScriptRed,
		GuiControl, 1:, State2,
		GuiControl, 1:, ScriptBlue, %activity%
		GuiControl, 1:, State3, %status%
	}

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
; Reads the current RGB color at an exact configured x/y pixel coordinate.
; Pixel detection is intentionally passive: if the user Alt-Tabs away, LLARS
; waits for the selected RuneScape client to become foreground again but never
; activates or restores it just to perform a pixel read. The function returns an
; uppercase 0xRRGGBB string, or an empty string when the run ends, the RuneScape
; client disappears, the section is disabled, or the coordinate is invalid.
LLARS_PixelColor(coordinateSection, scope := "script")
{
	if !LLARS_ConfigEnabled(coordinateSection, true, scope)
		return ""

	x := Trim(LLARS_ConfigRead(coordinateSection, "x", "ERROR", scope))
	y := Trim(LLARS_ConfigRead(coordinateSection, "y", "ERROR", scope))
	if x is not number
	{
		LLARS_CreatorConfigError(coordinateSection . " x coordinate is invalid: " . x)
		return ""
	}
	if y is not number
	{
		LLARS_CreatorConfigError(coordinateSection . " y coordinate is invalid: " . y)
		return ""
	}

	x := Round(x + 0)
	y := Round(y + 0)

	; Wait passively for the exact run target. This prevents PixelGetColor from
	; sampling another application while also allowing the user to remain Alt-Tabbed.
	if !LLARS_WaitForRuneScapePixelRead("Pixel read " . coordinateSection)
		return ""

	PixelGetColor, currentColor, %x%, %y%, RGB
	StringUpper, currentColor, currentColor
	return currentColor
}

; Keeps Developer Mode pixel searching/detection messages useful without
; flooding Recent Framework Actions every 100 ms. One search message is shown
; when a watch begins/rearms, and one detected message is shown for each new
; matched target state. This diagnostic state never changes detection behavior.
LLARS_CreatorPixelSearchAction(coordinateSection, colorSections, currentColor, matchedSection := "", scope := "script")
{
	global LLARS_CreatorPixelSearchStates, LLARS_RunStartTick

	if !IsFunc("LLARS_DeveloperAction")
		return

	if !IsObject(LLARS_CreatorPixelSearchStates)
		LLARS_CreatorPixelSearchStates := {}

	colorDisplay := ""
	if IsObject(colorSections)
	{
		for _, colorSection in colorSections
		{
			colorSection := Trim(colorSection)
			if (colorSection = "")
				continue
			if (colorDisplay != "")
				colorDisplay .= ", "
			colorDisplay .= colorSection
		}
	}
	else
	{
		Loop, Parse, colorSections, |
		{
			colorSection := Trim(A_LoopField)
			if (colorSection = "")
				continue
			if (colorDisplay != "")
				colorDisplay .= ", "
			colorDisplay .= colorSection
		}
	}

	if (colorDisplay = "")
		colorDisplay := "Color Target"

	stateKey := scope . "|" . coordinateSection . "|" . colorDisplay
	runToken := LLARS_RunStartTick + 0

	if LLARS_CreatorPixelSearchStates.HasKey(stateKey)
		state := LLARS_CreatorPixelSearchStates[stateKey]
	else
		state := {RunToken: runToken, LastMatch: "", SearchShown: false}

	if (state.RunToken != runToken)
		state := {RunToken: runToken, LastMatch: "", SearchShown: false}

	if (matchedSection != "")
	{
		; A target can already be present on the very first poll. Report that the
		; watch started before reporting the match so Developer Mode never appears
		; to skip the search phase.
		if (!state.SearchShown && state.LastMatch = "")
			LLARS_DeveloperAction("Pixel Search || " . coordinateSection . " || " . colorDisplay)

		if (state.LastMatch != matchedSection)
			LLARS_DeveloperAction("Pixel Detected || " . coordinateSection . " || " . matchedSection . " || " . currentColor)

		state.LastMatch := matchedSection
		state.SearchShown := true
	}
	else
	{
		; Log once when a watch first starts and once when a previously detected
		; target clears/rearms. Do not spam one search line per 100 ms poll.
		if (!state.SearchShown || state.LastMatch != "")
			LLARS_DeveloperAction("Pixel Search || " . coordinateSection . " || " . colorDisplay)

		state.LastMatch := ""
		state.SearchShown := true
	}

	LLARS_CreatorPixelSearchStates[stateKey] := state
}

; Returns true when a configured pixel coordinate currently matches a configured
; RGB color. This keeps IniRead/PixelGetColor boilerplate out of creator scripts.
LLARS_PixelMatches(coordinateSection, colorSection, scope := "script")
{
	if !LLARS_ConfigEnabled(colorSection, true, scope)
		return false

	currentColor := LLARS_PixelColor(coordinateSection, scope)
	if (currentColor = "")
		return false

	targetColor := LLARS_ConfigReadColor(colorSection, "", scope)
	if (targetColor = "")
		return false

	matched := (currentColor = targetColor)
	LLARS_CreatorPixelSearchAction(coordinateSection, colorSection, currentColor, matched ? colorSection : "", scope)
	return matched
}

; Compares one configured pixel against several configured color sections while
; sampling the pixel only once. colorSections may be an array/object or a
; pipe-delimited string. The matching section name is returned, or "" for no
; match. This is intended for multi-state/multi-color scripts.
LLARS_PixelMatchesAny(coordinateSection, colorSections, scope := "script")
{
	currentColor := LLARS_PixelColor(coordinateSection, scope)
	if (currentColor = "")
		return ""

	matchedSection := ""
	if IsObject(colorSections)
	{
		for _, colorSection in colorSections
		{
			colorSection := Trim(colorSection)
			if (colorSection = "" || !LLARS_ConfigEnabled(colorSection, true, scope))
				continue
			targetColor := LLARS_ConfigReadColor(colorSection, "", scope)
			if (targetColor != "" && currentColor = targetColor)
			{
				matchedSection := colorSection
				break
			}
		}
	}
	else
	{
		Loop, Parse, colorSections, |
		{
			colorSection := Trim(A_LoopField)
			if (colorSection = "" || !LLARS_ConfigEnabled(colorSection, true, scope))
				continue
			targetColor := LLARS_ConfigReadColor(colorSection, "", scope)
			if (targetColor != "" && currentColor = targetColor)
			{
				matchedSection := colorSection
				break
			}
		}
	}

	LLARS_CreatorPixelSearchAction(coordinateSection, colorSections, currentColor, matchedSection, scope)
	return matchedSection
}
