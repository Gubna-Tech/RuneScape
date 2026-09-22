; ================================================================
; |     LLARS CREATOR API     -     LLARS CREATOR API            |
; ================================================================

; ================================================================
; |     INTERNAL API SUPPORT     -     INTERNAL API SUPPORT      |
; ================================================================
; Reports creator API configuration errors in Developer Mode.
LLARS_CreatorConfigError(message)
{
	message := Trim(message)
	if (message = "")
		message := "Unknown creator API configuration error"

	return false
}

; Reports blocked creator input without sending it.
LLARS_CreatorInputBlocked(action, reason)
{
	action := Trim(action)
	reason := Trim(reason)
	if (action = "")
		action := "Input"
	if (reason = "")
		reason := "Input safety check failed"

	return false
}

; ================================================================
; |     CONFIGURATION     -     CONFIGURATION                    |
; ================================================================
; Returns either the current script Config.ini or the shared LLARS Config.ini.
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

; Reads a boolean value using creator-facing Read naming.
LLARS_ConfigReadBool(section, key := "option", default := false, scope := "script")
{
	return LLARS_ConfigBool(section, key, default, scope)
}

; Reads one numeric value and optionally enforces an allowed minimum/maximum.
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

; Reads a value that must match one of the supplied choices.
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

; Reads and validates a configured hotkey.
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

; Reads and validates an RGB color.
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

; Returns whether a typed/optional section is currently enabled.
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

; Chooses a rectangle point using the system-backed random source while only avoiding exact recent point repeats.
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

; Captures the exact RuneScape client used for this run and brings it to the foreground before automation begins.
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

; Framework focus gate for every game-facing action.
LLARS_WaitForRuneScape(action := "Automation", requireRun := true)
{
	global LLARS_RUNNING, LLARS_PAUSED, LLARS_RunRuneScapeHwnd
	global LLARS_CreatorCurrentStatus, LLARS_CreatorCurrentActivity
	global LLARS_lhk4, LLARS_lhk5

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
	GuiControl, 1:, State3, Restoring Game

	; Prevent managed timers from entering another creator callback while focus recovery is in progress.
	LLARS_EnableExitHotkey(LLARS_lhk4)
	LLARS_EnableDeveloperHotkey(LLARS_lhk5)
	Thread, NoTimers, true
	Loop
	{
		if (requireRun && !LLARS_RUNNING)
			break

		; If the user pauses while an action is waiting to dispatch, do not keep stealing focus.
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
	LLARS_DeveloperAction("Focus || RuneScape reclaimed || " . action)
	return true
}


; Passive foreground gate used only by pixel/color detection.
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


; Resolves a creator callback supplied either as a function name or as an AutoHotkey function/bound-function object.
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

; Runs a complete RunCount session around one creator callback.
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

; Restores a safe idle state if a creator callback throws.
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

	; Countdown exists only in legacy timer-style scripts.
	legacyCountdownLabel := "Countdown"
	if IsLabel(legacyCountdownLabel)
		SetTimer, %legacyCountdownLabel%, Off

	; Keep estimator cleanup safe even if this API file is included without the shared label library during isolated creator/API testing.
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

; Returns one randomized interval for a SetTimer-based script.
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

; Schedules a creator callback once after a randomized interval from the named timer section.
; LLARS_TimerStop(), or 0 when the timer could not be scheduled.
LLARS_TimerOnce(section, callback, scope := "script")
{
	return LLARS_CreatorTimerScheduleCallback(section, callback, false, scope)
}

; Repeats a creator callback using a freshly randomized interval after every callback.
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

; Dispatches one creator callback timer.
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

; Focus-safe dispatcher for label-based managed timers.
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

; Stops every timer created through the Creator API.
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
; Activates and locks onto the RuneScape client immediately before a creator keyboard action.
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

; Dispatches keyboard input only while the exact RuneScape HWND captured by the focus gate is still the foreground window.
LLARS_CreatorSendInput(sendSequence, action := "Keyboard")
{
	Loop
	{
		runeScapeHwnd := LLARS_CreatorPrepareKeyboardInput(action)
		if (!runeScapeHwnd)
			return false

		; A small lead-in varies the gap before the physical key transition.
		if IsFunc("LLARS_HumanTiming")
			leadIn := LLARS_HumanTiming(7, 31, "Keyboard.LeadIn", 0.025, 38, 72)
		else
		{
			Random, leadIn, 7, 31
		}
		Sleep, %leadIn%

		; GetForegroundWindow is checked immediately before SendEvent.
		if (DllCall("GetForegroundWindow", "Ptr") != runeScapeHwnd)
		{
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

		; Explicit key-down/key-up sends represent a real held state rather than a normal timed key press.
		; fallback inside LLARS_DeveloperScriptKey().
		if RegExMatch(sendSequence, "i)^\{([^{}]+)\s+(down|up)\}$", keyStateMatch)
		{
			stateKey := Trim(keyStateMatch1)
			stateDirection := keyStateMatch2
			StringLower, stateDirection, stateDirection
			stateVK := GetKeyVK(stateKey)
			if (stateVK && IsFunc("LLARS_DeveloperScriptKey"))
				LLARS_DeveloperScriptKey(stateVK, stateDirection = "up")
		}
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

; Converts an AutoHotkey hotkey expression such as ^+D or !F1 into the matching Send sequence.
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
	return true
}

; Reads a typed hotkey section and presses that combination in RuneScape.
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
	return true
}

; Clicks a configured fixed point or randomized coordinate rectangle using the
; RuneScape-only NaturalClick safety checks.
LLARS_Click(section, button := "left", scope := "script")
{
	global LLARS_NaturalClickFocusLost

	; Creator-facing task clicks are only valid during an active LLARS run.
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
		if (!LLARS_NaturalClickFocusLost || !LLARS_RunActive())
			return false
	}
}

; Updates the standard LLARS status row without requiring scripts to know the underlying GUI control names.
LLARS_SetStatus(status, activity := "")
{
	global scriptname, LLARS_CreatorCurrentStatus, LLARS_CreatorCurrentActivity
	static lastStatus := "", lastActivity := ""

	if (activity = "")
		activity := scriptname

	LLARS_CreatorCurrentStatus := status
	LLARS_CreatorCurrentActivity := activity

	; The main LLARS GUI already has separate blue and red status controls.
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

	; Wait passively for the exact run target.
	if !LLARS_WaitForRuneScapePixelRead("Pixel read " . coordinateSection)
		return ""

	PixelGetColor, currentColor, %x%, %y%, RGB
	StringUpper, currentColor, currentColor
	return currentColor
}

; Keeps Developer Mode pixel searching/detection messages useful without flooding Recent Framework Actions.
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
		; A target can already be present on the very first poll.
		if (!state.SearchShown && state.LastMatch = "")
			LLARS_DeveloperAction("Pixel Watch || " . coordinateSection . " || Waiting for " . colorDisplay)

		if (state.LastMatch != matchedSection)
			LLARS_DeveloperAction("Pixel Match || " . coordinateSection . " || " . matchedSection . " || Actual=" . currentColor)

		state.LastMatch := matchedSection
		state.SearchShown := true
	}
	else
	{
		; Report only the initial watch. A cleared match silently rearms it.
		if (!state.SearchShown)
			LLARS_DeveloperAction("Pixel Watch || " . coordinateSection . " || Waiting for " . colorDisplay)

		state.LastMatch := ""
		state.SearchShown := true
	}

	LLARS_CreatorPixelSearchStates[stateKey] := state
}

; Returns true when a configured pixel coordinate currently matches a configured RGB color.
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

; Compares one configured pixel against several configured color sections while sampling the pixel only once.
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

; ================================================================
; |     ADVANCED COLOR HELPERS     -     ADVANCED COLOR HELPERS  |
; ================================================================
; Shared capture, comparison, center-out search, and validation helpers used
; by color-driven creator scripts.

LLARS_RGBWithinTolerance(actualColor, targetColor, tolerance := 2)
{
	actualColor := Trim(actualColor)
	targetColor := Trim(targetColor)
	if !RegExMatch(actualColor, "i)^0x[0-9A-F]{6}$")
		return false
	if !RegExMatch(targetColor, "i)^0x[0-9A-F]{6}$")
		return false
	tolerance := Max(0, Round(tolerance + 0))

	actualR := LLARS_HexByte(SubStr(actualColor, 3, 2))
	actualG := LLARS_HexByte(SubStr(actualColor, 5, 2))
	actualB := LLARS_HexByte(SubStr(actualColor, 7, 2))
	targetR := LLARS_HexByte(SubStr(targetColor, 3, 2))
	targetG := LLARS_HexByte(SubStr(targetColor, 5, 2))
	targetB := LLARS_HexByte(SubStr(targetColor, 7, 2))
	if (actualR < 0 || actualG < 0 || actualB < 0 || targetR < 0 || targetG < 0 || targetB < 0)
		return false

	return (Abs(actualR - targetR) <= tolerance
		&& Abs(actualG - targetG) <= tolerance
		&& Abs(actualB - targetB) <= tolerance)
}

LLARS_HexByte(hexPair)
{
	hexPair := Trim(hexPair)
	StringUpper, hexPair, hexPair
	if !RegExMatch(hexPair, "^[0-9A-F]{2}$")
		return -1

	hexDigits := "0123456789ABCDEF"
	highNibble := InStr(hexDigits, SubStr(hexPair, 1, 1), true) - 1
	lowNibble := InStr(hexDigits, SubStr(hexPair, 2, 1), true) - 1
	if (highNibble < 0 || lowNibble < 0)
		return -1
	return (highNibble * 16) + lowNibble
}

LLARS_PixelChangedFrom(coordinateSection, baselineColor, ByRef currentColor, scope := "script")
{
	global LLARS_RunStartTick
	static changeStates := {}

	currentColor := ""
	baselineColor := Trim(baselineColor)
	if !RegExMatch(baselineColor, "i)^0x[0-9A-F]{6}$")
	{
		LLARS_CreatorConfigError("Pixel baseline is invalid for " . coordinateSection . ": " . baselineColor)
		return false
	}
	StringUpper, baselineColor, baselineColor

	currentColor := LLARS_PixelColor(coordinateSection, scope)
	if (currentColor = "")
		return false

	changed := (currentColor != baselineColor)
	stateKey := scope . "|" . coordinateSection . "|" . baselineColor
	runToken := LLARS_RunStartTick + 0
	if changeStates.HasKey(stateKey)
		state := changeStates[stateKey]
	else
		state := {RunToken: runToken, Changed: false, Initialized: false}

	if (state.RunToken != runToken)
		state := {RunToken: runToken, Changed: false, Initialized: false}

	if (!state.Initialized)
	{
		LLARS_DeveloperAction("Pixel Baseline || " . coordinateSection . " || " . baselineColor)
		state.Initialized := true
	}

	if (changed && !state.Changed)
		LLARS_DeveloperAction("Pixel Changed || " . coordinateSection . " || " . baselineColor . " > " . currentColor)
	else if (!changed && state.Changed)
		LLARS_DeveloperAction("Pixel Restored || " . coordinateSection . " || " . currentColor)

	state.Changed := changed
	changeStates[stateKey] := state
	return changed
}

; Reads a configured pixel from the RuneScape client's own off-screen render, allowing a covered/non-foreground client to be sampled without activating, restoring, moving, hiding, or clicking any window.
LLARS_PixelChangedFromRuneScapePrintWindow(coordinateSection, baselineColor, ByRef currentColor, scope := "script")
{
	global LLARS_RunRuneScapeHwnd, LLARS_RunStartTick
	static changeStates := {}
	static captureStates := {}

	currentColor := ""
	baselineColor := Trim(baselineColor)
	if !RegExMatch(baselineColor, "i)^0x[0-9A-F]{6}$")
	{
		LLARS_CreatorConfigError("Pixel baseline is invalid for " . coordinateSection . ": " . baselineColor)
		return false
	}
	StringUpper, baselineColor, baselineColor

	x := Trim(LLARS_ConfigRead(coordinateSection, "x", "ERROR", scope))
	y := Trim(LLARS_ConfigRead(coordinateSection, "y", "ERROR", scope))
	if x is not number
		return false
	if y is not number
		return false
	x := Round(x + 0)
	y := Round(y + 0)

	runeScapeHwnd := LLARS_RunRuneScapeHwnd
	if (!runeScapeHwnd || !DllCall("IsWindow", "Ptr", runeScapeHwnd) || !LLARS_IsRuneScapeWindow(runeScapeHwnd))
		return false

	captureMethod := ""
	capturedColor := LLARS_CreatorPrintWindowPixel(runeScapeHwnd, x, y, captureMethod)
	runToken := LLARS_RunStartTick + 0
	captureKey := runToken . "|" . scope . "|" . coordinateSection

	if (capturedColor = "" || capturedColor = "0x000000")
		return false

	StringUpper, capturedColor, capturedColor
	currentColor := capturedColor
	if !captureStates.HasKey(captureKey)
	{
		LLARS_DeveloperAction("Hidden Pixel Reader || " . coordinateSection . " || Ready || RuneScape / " . captureMethod)
		captureStates[captureKey] := true
	}

	changed := (currentColor != baselineColor)
	stateKey := runToken . "|PrintWindow|" . scope . "|" . coordinateSection . "|" . baselineColor
	if changeStates.HasKey(stateKey)
		state := changeStates[stateKey]
	else
		state := {Changed: false, Initialized: false}

	if (!state.Initialized)
		state.Initialized := true

	if (changed && !state.Changed)
		LLARS_DeveloperAction("Pixel Changed || " . coordinateSection . " || " . baselineColor . " > " . currentColor)
	else if (!changed && state.Changed)
		LLARS_DeveloperAction("Pixel Restored || " . coordinateSection . " || " . currentColor)

	state.Changed := changed
	changeStates[stateKey] := state
	return changed
}

; Compares a configured pixel and color with per-channel RGB tolerance.
LLARS_PixelMatchesWithinTolerance(coordinateSection, colorSection, tolerance := 0, scope := "script")
{
	if !LLARS_ConfigEnabled(colorSection, true, scope)
		return false

	currentColor := LLARS_PixelColor(coordinateSection, scope)
	if (currentColor = "")
		return false

	targetColor := LLARS_ConfigReadColor(colorSection, "", scope)
	if (targetColor = "")
		return false

	StringUpper, currentColor, currentColor
	StringUpper, targetColor, targetColor
	tolerance := Max(0, Round(tolerance + 0))
	matched := LLARS_RGBWithinTolerance(currentColor, targetColor, tolerance)
	LLARS_CreatorPixelSearchAction(coordinateSection, colorSection, currentColor, matched ? colorSection : "", scope)
	return matched
}

; Prototype trigger reader for Alt1/RuneApps overlay pixels.
LLARS_PixelMatchesWithinTolerancePrintWindow(coordinateSection, colorSection, tolerance := 0, scope := "script")
{
	global LLARS_RunRuneScapeHwnd, LLARS_RunStartTick
	static observedStates := {}

	if !LLARS_ConfigEnabled(colorSection, true, scope)
		return false

	targetColor := LLARS_ConfigReadColor(colorSection, "", scope)
	if (targetColor = "")
		return false

	x := Trim(LLARS_ConfigRead(coordinateSection, "x", "ERROR", scope))
	y := Trim(LLARS_ConfigRead(coordinateSection, "y", "ERROR", scope))
	if x is not number
		return false
	if y is not number
		return false
	x := Round(x + 0)
	y := Round(y + 0)
	tolerance := Max(0, Round(tolerance + 0))

	runeScapeHwnd := LLARS_RunRuneScapeHwnd
	if (!runeScapeHwnd || !DllCall("IsWindow", "Ptr", runeScapeHwnd) || !LLARS_IsRuneScapeWindow(runeScapeHwnd))
		return false

	VarSetCapacity(screenPoint, 8, 0)
	NumPut(x, screenPoint, 0, "Int")
	NumPut(y, screenPoint, 4, "Int")
	if !DllCall("ClientToScreen", "Ptr", runeScapeHwnd, "Ptr", &screenPoint)
		return false
	screenX := NumGet(screenPoint, 0, "Int")
	screenY := NumGet(screenPoint, 4, "Int")

	previousDetectHidden := A_DetectHiddenWindows
	DetectHiddenWindows, On
	WinGet, windowList, List
	matched := false
	observedColor := ""
	observedSource := ""

	Loop, %windowList%
	{
		hWnd := windowList%A_Index%
		if (!hWnd || hWnd = runeScapeHwnd || hWnd = A_ScriptHwnd)
			continue

		WinGet, processName, ProcessName, ahk_id %hWnd%
		WinGetTitle, windowTitle, ahk_id %hWnd%
		WinGetClass, windowClass, ahk_id %hWnd%
		identity := processName . "|" . windowTitle . "|" . windowClass
		if !RegExMatch(identity, "i)(alt\s*1|runeapps)")
			continue

		VarSetCapacity(clientPoint, 8, 0)
		NumPut(screenX, clientPoint, 0, "Int")
		NumPut(screenY, clientPoint, 4, "Int")
		if !DllCall("ScreenToClient", "Ptr", hWnd, "Ptr", &clientPoint)
			continue
		clientX := NumGet(clientPoint, 0, "Int")
		clientY := NumGet(clientPoint, 4, "Int")

		VarSetCapacity(clientRect, 16, 0)
		if !DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &clientRect)
			continue
		clientWidth := NumGet(clientRect, 8, "Int")
		clientHeight := NumGet(clientRect, 12, "Int")
		if (clientX < 0 || clientY < 0 || clientX >= clientWidth || clientY >= clientHeight)
			continue

		captureMethod := ""
		capturedColor := LLARS_CreatorPrintWindowPixel(hWnd, clientX, clientY, captureMethod)
		if (capturedColor = "")
			continue

		if (observedColor = "")
		{
			observedColor := capturedColor
			observedSource := processName . " / " . captureMethod
		}

		if LLARS_RGBWithinTolerance(capturedColor, targetColor, tolerance)
		{
			matched := true
			observedColor := capturedColor
			observedSource := processName . " / " . captureMethod
			break
		}
	}

	DetectHiddenWindows, %previousDetectHidden%

	if (observedColor != "")
	{
		stateKey := (LLARS_RunStartTick + 0) . "|" . scope . "|" . coordinateSection . "|" . colorSection
		observedToken := "READY|" . observedSource
		if (!observedStates.HasKey(stateKey) || observedStates[stateKey] != observedToken)
		{
			LLARS_DeveloperAction("Hidden Pixel Reader || " . coordinateSection . " || Ready || " . observedSource)
			observedStates[stateKey] := observedToken
		}
		LLARS_CreatorPixelSearchAction(coordinateSection, colorSection, observedColor, matched ? colorSection : "", scope)
		if (matched)
			return true
	}
	else
	{
		; Make an unsupported/unavailable Alt1 capture obvious during prototype testing.
		stateKey := (LLARS_RunStartTick + 0) . "|" . scope . "|" . coordinateSection . "|" . colorSection
		observedToken := "UNAVAILABLE"
		if (!observedStates.HasKey(stateKey) || observedStates[stateKey] != observedToken)
		{
			LLARS_DeveloperAction("Hidden Pixel Reader || " . coordinateSection . " || Unavailable || Visible fallback only")
			observedStates[stateKey] := observedToken
		}
	}

	; The normal reader is safe only while the selected RuneScape client is the foreground window; otherwise it would wait for focus and defeat this probe.
	if (DllCall("GetForegroundWindow", "Ptr") = runeScapeHwnd)
		return LLARS_PixelMatchesWithinTolerance(coordinateSection, colorSection, tolerance, scope)

	return false
}

; Renders a full target-window client into a top-down DIB and samples the requested pixel afterward.
LLARS_CreatorPrintWindowPixel(hWnd, clientX, clientY, ByRef captureMethod := "")
{
	captureMethod := ""
	if (!hWnd || clientX < 0 || clientY < 0)
		return ""
	if DllCall("IsIconic", "Ptr", hWnd)
		return ""

	VarSetCapacity(clientRect, 16, 0)
	if !DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &clientRect)
		return ""
	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")
	if (clientWidth < 1 || clientHeight < 1 || clientWidth > 16384 || clientHeight > 16384)
		return ""
	if (clientX >= clientWidth || clientY >= clientHeight)
		return ""

	hScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
	if (!hScreenDC)
		return ""
	hMemoryDC := DllCall("gdi32\CreateCompatibleDC", "Ptr", hScreenDC, "Ptr")
	if (!hMemoryDC)
	{
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)
		return ""
	}

	VarSetCapacity(bitmapInfo, 40, 0)
	NumPut(40, bitmapInfo, 0, "UInt")
	NumPut(clientWidth, bitmapInfo, 4, "Int")
	NumPut(-clientHeight, bitmapInfo, 8, "Int")
	NumPut(1, bitmapInfo, 12, "UShort")
	NumPut(32, bitmapInfo, 14, "UShort")
	bits := 0
	hBitmap := DllCall("gdi32\CreateDIBSection", "Ptr", hScreenDC, "Ptr", &bitmapInfo, "UInt", 0, "Ptr*", bits, "Ptr", 0, "UInt", 0, "Ptr")
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)
	if (!hBitmap || !bits)
	{
		if (hBitmap)
			DllCall("gdi32\DeleteObject", "Ptr", hBitmap)
		DllCall("gdi32\DeleteDC", "Ptr", hMemoryDC)
		return ""
	}

	oldBitmap := DllCall("gdi32\SelectObject", "Ptr", hMemoryDC, "Ptr", hBitmap, "Ptr")
	bufferBytes := clientWidth * clientHeight * 4
	pixelOffset := ((clientY * clientWidth) + clientX) * 4
	pixel := 0
	printed := false

	; PW_CLIENTONLY | PW_RENDERFULLCONTENT first gives GPU/composited windows the broadest opportunity to paint.
	DllCall("ntdll\RtlZeroMemory", "Ptr", bits, "UPtr", bufferBytes)
	printed := DllCall("PrintWindow", "Ptr", hWnd, "Ptr", hMemoryDC, "UInt", 3)
	if (printed)
	{
		pixel := NumGet(bits + pixelOffset, 0, "UInt")
		captureMethod := "Full client flags=3"
	}

	if (!printed || pixel = 0)
	{
		DllCall("ntdll\RtlZeroMemory", "Ptr", bits, "UPtr", bufferBytes)
		printedClient := DllCall("PrintWindow", "Ptr", hWnd, "Ptr", hMemoryDC, "UInt", 1)
		if (printedClient)
		{
			printed := true
			pixel := NumGet(bits + pixelOffset, 0, "UInt")
			captureMethod := "Full client flags=1"
		}
	}

	if (oldBitmap)
		DllCall("gdi32\SelectObject", "Ptr", hMemoryDC, "Ptr", oldBitmap, "Ptr")
	DllCall("gdi32\DeleteObject", "Ptr", hBitmap)
	DllCall("gdi32\DeleteDC", "Ptr", hMemoryDC)

	if (printed && pixel != 0)
	{
		blue := pixel & 0xFF
		green := (pixel >> 8) & 0xFF
		red := (pixel >> 16) & 0xFF
		return Format("0x{:02X}{:02X}{:02X}", red, green, blue)
	}

	; A window DC is a final non-interactive fallback for layered or GPU-backed clients.
	hClientDC := DllCall("GetDC", "Ptr", hWnd, "Ptr")
	if (hClientDC)
	{
		colorRef := DllCall("gdi32\GetPixel", "Ptr", hClientDC, "Int", clientX, "Int", clientY, "UInt")
		DllCall("ReleaseDC", "Ptr", hWnd, "Ptr", hClientDC)
		if (colorRef != 0xFFFFFFFF)
		{
			captureMethod := "Window DC fallback"
			red := colorRef & 0xFF
			green := (colorRef >> 8) & 0xFF
			blue := (colorRef >> 16) & 0xFF
			return Format("0x{:02X}{:02X}{:02X}", red, green, blue)
		}
	}

	if (printed)
	{
		captureMethod := "Full client black frame"
		return "0x000000"
	}

	return ""
}

; Searches the visible RuneScape client from the center outward for any enabled configured color section.
LLARS_FindColorCenterOut(colorSections, ByRef foundX, ByRef foundY, ByRef matchedSection, avoidSection := "", searchName := "Color", avoidX := "", avoidY := "", scope := "script", tolerance := 0, allowAvoidFallback := false, requireNeighborhood := false)
{
	global LLARS_RunRuneScapeHwnd

	foundX := ""
	foundY := ""
	matchedSection := ""
	avoidSection := Trim(avoidSection)
	searchName := Trim(searchName)
	if (searchName = "")
		searchName := "Color"
	tolerance := Max(0, Round(tolerance + 0))

	targets := LLARS_CreatorCenterOutTargets(colorSections, scope)
	if (!IsObject(targets) || targets.Length() = 0)
	{
		LLARS_CreatorConfigError("Center-out color search has no valid enabled colors")
		return false
	}

	LLARS_CreatorShuffleArray(targets, "CenterOut.ColorPriority." . searchName)

	if !LLARS_WaitForRuneScapePixelRead("Center-out color search")
	{
		LLARS_DeveloperAction("Center-Out Blocked || " . searchName . " || Pixel read gate")
		return false
	}

	hWnd := LLARS_RunRuneScapeHwnd
	if (!hWnd || !DllCall("IsWindow", "Ptr", hWnd))
		hWnd := WinExist("A")
	if (!hWnd || !LLARS_IsRuneScapeWindow(hWnd))
	{
		LLARS_DeveloperAction("Center-Out Blocked || " . searchName . " || RuneScape HWND unavailable")
		return false
	}

	VarSetCapacity(clientRect, 16, 0)
	if !DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &clientRect)
	{
		LLARS_DeveloperAction("Center-Out Blocked || " . searchName . " || GetClientRect failed")
		return false
	}
	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")
	if (clientWidth <= 0 || clientHeight <= 0)
	{
		LLARS_DeveloperAction("Center-Out Blocked || " . searchName . " || Invalid client size")
		return false
	}

	capture := LLARS_CreatorCaptureClientPixels(hWnd, clientWidth, clientHeight)
	if !IsObject(capture)
	{
		LLARS_DeveloperAction("Center-Out Blocked || " . searchName . " || Desktop capture failed")
		return false
	}

	matchedTarget := ""
	candidates := ""
	ringRadius := 0
	usedAvoidFallback := false
	if !LLARS_CreatorFindTargetFromCapture(targets, avoidSection, capture, matchedTarget, candidates, ringRadius, usedAvoidFallback, searchName, tolerance, allowAvoidFallback, requireNeighborhood)
	{
		LLARS_CreatorReleaseCapture(capture)
		return false
	}

	if (!IsObject(matchedTarget) || !IsObject(candidates) || candidates.Length() = 0)
	{
		LLARS_CreatorReleaseCapture(capture)
		return false
	}

	choicePool := []
	for _, candidate in candidates
	{
		if (matchedTarget.Section = avoidSection && avoidX != "" && avoidY != "" && candidate.X = avoidX && candidate.Y = avoidY && candidates.Length() > 1)
			continue
		choicePool.Push(candidate)
	}
	if (choicePool.Length() = 0)
		choicePool := candidates

	; Prefer interior pixels while keeping a small randomized top-density pool.
	bestDensity := -1
	scoredCandidates := []
	for _, candidate in choicePool
	{
		density := LLARS_CreatorColorDensity(capture, candidate.X, candidate.Y, matchedTarget.RGB, 5, tolerance)
		scoredCandidates.Push({Candidate:candidate, Density:density})
		if (density > bestDensity)
			bestDensity := density
	}
	topDensityPool := []
	minimumDensity := Max(0, bestDensity - 2)
	for _, scored in scoredCandidates
	{
		if (scored.Density >= minimumDensity)
			topDensityPool.Push(scored.Candidate)
	}
	if (topDensityPool.Length() > 0)
		choicePool := topDensityPool

	choiceIndex := LLARS_HumanRandomInt(1, choicePool.Length(), "CenterOut.PixelChoice." . searchName . "." . matchedTarget.Section, 6)
	choice := choicePool[choiceIndex]
	foundX := choice.X
	foundY := choice.Y
	matchedSection := matchedTarget.Section
	LLARS_CreatorReleaseCapture(capture)
	return true
}

; Reacquires a configured color near a previously found point on a fresh frame.
LLARS_VerifyColorTarget(ByRef x, ByRef y, colorSection, actionName := "Color", scope := "script", radius := 28, tolerance := 0, confirmationDelay := 0, confirmationRadius := "")
{
	global LLARS_RunRuneScapeHwnd

	if !LLARS_ConfigEnabled(colorSection, true, scope)
		return false

	if x is not number
		return false
	if y is not number
		return false
	x := Round(x + 0)
	y := Round(y + 0)
	radius := Max(1, Round(radius + 0))
	tolerance := Max(0, Round(tolerance + 0))
	confirmationDelay := Max(0, Round(confirmationDelay + 0))
	if confirmationRadius is not number
		confirmationRadius := radius
	confirmationRadius := Max(1, Round(confirmationRadius + 0))

	targetColor := LLARS_ConfigReadColor(colorSection, "", scope)
	if (targetColor = "")
		return false
	targetRGB := targetColor + 0

	actionName := Trim(actionName)
	if (actionName = "")
		actionName := colorSection
	if !LLARS_WaitForRuneScapePixelRead("Verify " . actionName . " color")
		return false

	hWnd := LLARS_RunRuneScapeHwnd
	if (!hWnd || !DllCall("IsWindow", "Ptr", hWnd) || !LLARS_IsRuneScapeWindow(hWnd))
		return false

	VarSetCapacity(clientRect, 16, 0)
	if !DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &clientRect)
		return false
	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")
	if (clientWidth <= 0 || clientHeight <= 0 || x < 0 || y < 0 || x >= clientWidth || y >= clientHeight)
		return false

	capture := LLARS_CreatorCaptureClientPixels(hWnd, clientWidth, clientHeight)
	if !IsObject(capture)
		return false
	verified := LLARS_CreatorReacquireNearby(capture, x, y, targetRGB, radius, tolerance)
	LLARS_CreatorReleaseCapture(capture)
	if (!verified || confirmationDelay <= 0)
		return verified

	Sleep, %confirmationDelay%
	capture := LLARS_CreatorCaptureClientPixels(hWnd, clientWidth, clientHeight)
	if !IsObject(capture)
		return false
	verified := LLARS_CreatorReacquireNearby(capture, x, y, targetRGB, confirmationRadius, tolerance)
	LLARS_CreatorReleaseCapture(capture)
	return verified
}

; Clicks a runtime client coordinate, retrying the same intended click after a
; temporary focus loss while the run remains active.
LLARS_ClickPoint(x, y, button := "left", actionName := "Pixel Target")
{
	global LLARS_NaturalClickFocusLost

	if !LLARS_RunActive()
		return false
	if x is not number
	{
		LLARS_CreatorConfigError("Runtime click X coordinate is invalid: " . x)
		return false
	}
	if y is not number
	{
		LLARS_CreatorConfigError("Runtime click Y coordinate is invalid: " . y)
		return false
	}

	x := Round(x + 0)
	y := Round(y + 0)
	button := Trim(button)
	StringLower, button, button
	if button not in left,right
	{
		LLARS_CreatorConfigError("LLARS_ClickPoint button must be left or right: " . button)
		return false
	}

	Loop
	{
		if !LLARS_WaitForRuneScape("Runtime click " . actionName)
			return false

		LLARS_NaturalClickFocusLost := false
		if NaturalClick(x, y, button)
		{
			return true
		}

		if (!LLARS_NaturalClickFocusLost || !LLARS_RunActive())
			return false
	}
}

LLARS_CreatorReacquireNearby(capture, ByRef x, ByRef y, targetRGB, radius := 28, tolerance := 0)
{
	if !IsObject(capture)
		return false

	originalX := x
	originalY := y
	bestX := ""
	bestY := ""
	bestDensity := -1
	bestDistance := ""
	x1 := Max(0, originalX - radius)
	x2 := Min(capture.Width - 1, originalX + radius)
	y1 := Max(0, originalY - radius)
	y2 := Min(capture.Height - 1, originalY + radius)

	scanY := y1
	while (scanY <= y2)
	{
		scanX := x1
		while (scanX <= x2)
		{
			localOffset := ((scanY * capture.Width) + scanX) * 4
			localRGB := NumGet(capture.Bits + localOffset, 0, "UInt") & 0xFFFFFF
			matched := (tolerance > 0) ? LLARS_RGBWithinToleranceValue(localRGB, targetRGB, tolerance) : (localRGB = targetRGB)
			if (matched)
			{
				density := LLARS_CreatorColorDensity(capture, scanX, scanY, targetRGB, 4, tolerance)
				dx := scanX - originalX
				dy := scanY - originalY
				distance := (dx * dx) + (dy * dy)
				if (density > bestDensity || (density = bestDensity && (bestDistance = "" || distance < bestDistance)))
				{
					bestDensity := density
					bestDistance := distance
					bestX := scanX
					bestY := scanY
				}
			}
			scanX++
		}
		scanY++
	}

	if (bestX = "" || bestY = "")
		return false
	x := bestX
	y := bestY
	return true
}

LLARS_CreatorCenterOutTargets(colorSections, scope := "script")
{
	targets := []
	if IsObject(colorSections)
	{
		for _, section in colorSections
			LLARS_CreatorCenterOutAddTarget(targets, section, scope)
	}
	else
	{
		Loop, Parse, colorSections, |
			LLARS_CreatorCenterOutAddTarget(targets, A_LoopField, scope)
	}
	return targets
}

LLARS_CreatorCenterOutAddTarget(ByRef targets, section, scope)
{
	section := Trim(section)
	if (section = "" || !LLARS_ConfigEnabled(section, true, scope))
		return
	colorValue := LLARS_ConfigReadColor(section, "", scope)
	if (colorValue = "")
		return
	targets.Push({Section: section, Color: colorValue, RGB: colorValue + 0})
}

LLARS_CreatorShuffleArray(ByRef values, stream := "LLARS.Shuffle")
{
	if !IsObject(values)
		return
	count := values.Length()
	if (count <= 1)
		return

	index := count
	while (index > 1)
	{
		swapIndex := LLARS_HumanRandomInt(1, index, stream . "." . index, 0)
		temp := values[index]
		values[index] := values[swapIndex]
		values[swapIndex] := temp
		index--
	}
}

; Captures the visible RuneScape client into a top-down 32-bit DIB.
LLARS_CreatorCaptureClientPixels(runeScapeHwnd, clientWidth, clientHeight)
{
	if (!runeScapeHwnd || clientWidth <= 0 || clientHeight <= 0)
		return ""

	VarSetCapacity(clientPoint, 8, 0)
	NumPut(0, clientPoint, 0, "Int")
	NumPut(0, clientPoint, 4, "Int")
	if !DllCall("ClientToScreen", "Ptr", runeScapeHwnd, "Ptr", &clientPoint)
		return ""
	screenX := NumGet(clientPoint, 0, "Int")
	screenY := NumGet(clientPoint, 4, "Int")

	hScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
	if (!hScreenDC)
		return ""
	hMemoryDC := DllCall("gdi32\CreateCompatibleDC", "Ptr", hScreenDC, "Ptr")
	if (!hMemoryDC)
	{
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)
		return ""
	}

	VarSetCapacity(bitmapInfo, 40, 0)
	NumPut(40, bitmapInfo, 0, "UInt")
	NumPut(clientWidth, bitmapInfo, 4, "Int")
	NumPut(-clientHeight, bitmapInfo, 8, "Int")
	NumPut(1, bitmapInfo, 12, "UShort")
	NumPut(32, bitmapInfo, 14, "UShort")
	NumPut(0, bitmapInfo, 16, "UInt")
	bits := 0
	hBitmap := DllCall("gdi32\CreateDIBSection", "Ptr", hScreenDC, "Ptr", &bitmapInfo, "UInt", 0, "Ptr*", bits, "Ptr", 0, "UInt", 0, "Ptr")
	if (!hBitmap || !bits)
	{
		DllCall("gdi32\DeleteDC", "Ptr", hMemoryDC)
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)
		return ""
	}

	oldBitmap := DllCall("gdi32\SelectObject", "Ptr", hMemoryDC, "Ptr", hBitmap, "Ptr")
	DllCall("dwmapi\DwmFlush")
	copied := DllCall("gdi32\BitBlt", "Ptr", hMemoryDC, "Int", 0, "Int", 0, "Int", clientWidth, "Int", clientHeight, "Ptr", hScreenDC, "Int", screenX, "Int", screenY, "UInt", 0x00CC0020)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)
	if (!copied)
	{
		if (oldBitmap)
			DllCall("gdi32\SelectObject", "Ptr", hMemoryDC, "Ptr", oldBitmap, "Ptr")
		DllCall("gdi32\DeleteObject", "Ptr", hBitmap)
		DllCall("gdi32\DeleteDC", "Ptr", hMemoryDC)
		return ""
	}

	return {Bits: bits, Width: clientWidth, Height: clientHeight, MemoryDC: hMemoryDC, Bitmap: hBitmap, OldBitmap: oldBitmap}
}

LLARS_CreatorReleaseCapture(ByRef capture)
{
	if !IsObject(capture)
		return
	if (capture.MemoryDC && capture.OldBitmap)
		DllCall("gdi32\SelectObject", "Ptr", capture.MemoryDC, "Ptr", capture.OldBitmap, "Ptr")
	if (capture.Bitmap)
		DllCall("gdi32\DeleteObject", "Ptr", capture.Bitmap)
	if (capture.MemoryDC)
		DllCall("gdi32\DeleteDC", "Ptr", capture.MemoryDC)
	capture := ""
}

LLARS_CreatorFindTargetFromCapture(targets, avoidSection, capture, ByRef matchedTarget, ByRef matchedCandidates, ByRef ringRadius, ByRef usedAvoidFallback, searchName := "Color", tolerance := 0, allowAvoidFallback := false, requireNeighborhood := false)
{
	matchedTarget := ""
	matchedCandidates := ""
	ringRadius := 0
	usedAvoidFallback := false
	if !IsObject(capture)
		return false
	searchName := Trim(searchName)
	if (searchName = "")
		searchName := "Color"
	tolerance := Max(0, Round(tolerance + 0))

	targetByRGB := {}
	for _, target in targets
	{
		if (tolerance > 0)
			LLARS_CreatorAddTolerantTargetMap(targetByRGB, target, tolerance)
		else
			targetByRGB[target.RGB] := {Target:target, Distance:0}
	}

	clientWidth := capture.Width
	clientHeight := capture.Height
	centerX := Floor((clientWidth - 1) / 2)
	centerY := Floor((clientHeight - 1) / 2)
	ringStep := 28
	maxRadiusX := Max(centerX, clientWidth - 1 - centerX)
	maxRadiusY := Max(centerY, clientHeight - 1 - centerY)
	maxRadius := Max(maxRadiusX, maxRadiusY)
	visibleSections := []
	visibleMatches := {}
	repeatMatch := ""

	; Find each visible color's nearest ring, then choose the color randomly.
	outer := ringStep
	while (outer <= maxRadius + ringStep)
	{
		if (outer > maxRadius)
			outer := maxRadius
		inner := outer - ringStep
		if (inner < 0)
			inner := 0

		left := Max(0, centerX - outer)
		right := Min(clientWidth - 1, centerX + outer)
		top := Max(0, centerY - outer)
		bottom := Min(clientHeight - 1, centerY + outer)

		if (inner = 0)
		{
			rects := [{X1:left, Y1:top, X2:right, Y2:bottom}]
		}
		else
		{
			innerLeft := Max(0, centerX - inner)
			innerRight := Min(clientWidth - 1, centerX + inner)
			innerTop := Max(0, centerY - inner)
			innerBottom := Min(clientHeight - 1, centerY + inner)
			rects := []
			if (top <= innerTop - 1)
				rects.Push({X1:left, Y1:top, X2:right, Y2:innerTop - 1})
			if (innerBottom + 1 <= bottom)
				rects.Push({X1:left, Y1:innerBottom + 1, X2:right, Y2:bottom})
			if (left <= innerLeft - 1 && innerTop <= innerBottom)
				rects.Push({X1:left, Y1:innerTop, X2:innerLeft - 1, Y2:innerBottom})
			if (innerRight + 1 <= right && innerTop <= innerBottom)
				rects.Push({X1:innerRight + 1, Y1:innerTop, X2:right, Y2:innerBottom})
			LLARS_CreatorShuffleArray(rects, "CenterOut.Ring." . searchName . "." . outer)
		}

		for _, rect in rects
		{
			y := rect.Y1
			while (y <= rect.Y2)
			{
				x := rect.X1
				pixelOffset := ((y * clientWidth) + x) * 4
				while (x <= rect.X2)
				{
					pixelRGB := NumGet(capture.Bits + pixelOffset, 0, "UInt") & 0xFFFFFF
					if targetByRGB.HasKey(pixelRGB)
					{
						targetEntry := targetByRGB[pixelRGB]
						target := targetEntry.Target
						section := target.Section
						if (requireNeighborhood && !LLARS_CreatorHasColorNeighborhood(capture, x, y, target.RGB, 4, 5, tolerance))
						{
							x++
							pixelOffset += 4
							continue
						}
						if (avoidSection != "" && section = avoidSection)
						{
							if (allowAvoidFallback)
							{
								if !IsObject(repeatMatch)
									repeatMatch := {Target:target, Candidates:[], Ring:outer}
								if (repeatMatch.Ring = outer && repeatMatch.Candidates.Length() < 96)
									repeatMatch.Candidates.Push({X:x, Y:y, RGB:pixelRGB})
							}
							x++
							pixelOffset += 4
							continue
						}

						; Keep only this color's nearest ring.
						if !visibleMatches.HasKey(section)
						{
							visibleMatches[section] := {Target:target, Candidates:[], Ring:outer}
							visibleSections.Push(section)
						}
						match := visibleMatches[section]
						if (match.Ring = outer && match.Candidates.Length() < 96)
							match.Candidates.Push({X:x, Y:y, RGB:pixelRGB})
					}
					x++
					pixelOffset += 4
				}
				y++
			}
		}

		if (outer >= maxRadius)
			break
		outer += ringStep
	}

	if (visibleSections.Length() = 0)
	{
		if (allowAvoidFallback && IsObject(repeatMatch) && IsObject(repeatMatch.Candidates) && repeatMatch.Candidates.Length() > 0)
		{
			matchedTarget := repeatMatch.Target
			matchedCandidates := repeatMatch.Candidates
			ringRadius := repeatMatch.Ring
			usedAvoidFallback := true
			return true
		}
		return false
	}

	sectionIndex := LLARS_HumanRandomInt(1, visibleSections.Length(), "CenterOut.VisibleColorChoice." . searchName, 0)
	section := visibleSections[sectionIndex]
	match := visibleMatches[section]
	if (!IsObject(match) || !IsObject(match.Candidates) || match.Candidates.Length() = 0)
		return false

	matchedTarget := match.Target
	matchedCandidates := match.Candidates
	ringRadius := match.Ring
	return true
}

LLARS_CreatorAddTolerantTargetMap(ByRef targetByRGB, target, tolerance := 4)
{
	if !IsObject(targetByRGB)
		targetByRGB := {}
	if !IsObject(target)
		return

	targetRGB := target.RGB & 0xFFFFFF
	targetR := (targetRGB >> 16) & 0xFF
	targetG := (targetRGB >> 8) & 0xFF
	targetB := targetRGB & 0xFF
	tolerance := Max(0, Round(tolerance + 0))

	rStart := Max(0, targetR - tolerance)
	rEnd := Min(255, targetR + tolerance)
	gStart := Max(0, targetG - tolerance)
	gEnd := Min(255, targetG + tolerance)
	bStart := Max(0, targetB - tolerance)
	bEnd := Min(255, targetB + tolerance)

	r := rStart
	while (r <= rEnd)
	{
		g := gStart
		while (g <= gEnd)
		{
			b := bStart
			while (b <= bEnd)
			{
				rgb := (r << 16) | (g << 8) | b
				distance := Abs(r - targetR) + Abs(g - targetG) + Abs(b - targetB)
				if (!targetByRGB.HasKey(rgb) || distance < targetByRGB[rgb].Distance)
					targetByRGB[rgb] := {Target:target, Distance:distance}
				b++
			}
			g++
		}
		r++
	}
}

LLARS_RGBWithinToleranceValue(actualRGB, targetRGB, tolerance := 0)
{
	actualRGB := actualRGB & 0xFFFFFF
	targetRGB := targetRGB & 0xFFFFFF
	tolerance := Max(0, Round(tolerance + 0))

	actualR := (actualRGB >> 16) & 0xFF
	actualG := (actualRGB >> 8) & 0xFF
	actualB := actualRGB & 0xFF
	targetR := (targetRGB >> 16) & 0xFF
	targetG := (targetRGB >> 8) & 0xFF
	targetB := targetRGB & 0xFF

	return (Abs(actualR - targetR) <= tolerance
		&& Abs(actualG - targetG) <= tolerance
		&& Abs(actualB - targetB) <= tolerance)
}

LLARS_CreatorColorDensity(capture, centerX, centerY, targetRGB, radius := 4, tolerance := 0)
{
	if !IsObject(capture)
		return 0

	x1 := Max(0, centerX - radius)
	x2 := Min(capture.Width - 1, centerX + radius)
	y1 := Max(0, centerY - radius)
	y2 := Min(capture.Height - 1, centerY + radius)
	density := 0

	y := y1
	while (y <= y2)
	{
		x := x1
		pixelOffset := ((y * capture.Width) + x) * 4
		while (x <= x2)
		{
			pixelRGB := NumGet(capture.Bits + pixelOffset, 0, "UInt") & 0xFFFFFF
			matched := (tolerance > 0) ? LLARS_RGBWithinToleranceValue(pixelRGB, targetRGB, tolerance) : (pixelRGB = targetRGB)
			if (matched)
				density++
			x++
			pixelOffset += 4
		}
		y++
	}
	return density
}

LLARS_CreatorHasColorNeighborhood(capture, centerX, centerY, targetRGB, radius := 4, minimumNeighbors := 7, tolerance := 0)
{
	if !IsObject(capture)
		return false

	x1 := Max(0, centerX - radius)
	x2 := Min(capture.Width - 1, centerX + radius)
	y1 := Max(0, centerY - radius)
	y2 := Min(capture.Height - 1, centerY + radius)
	neighbors := 0

	y := y1
	while (y <= y2)
	{
		x := x1
		pixelOffset := ((y * capture.Width) + x) * 4
		while (x <= x2)
		{
			if (x != centerX || y != centerY)
			{
				pixelRGB := NumGet(capture.Bits + pixelOffset, 0, "UInt") & 0xFFFFFF
				matched := (tolerance > 0) ? LLARS_RGBWithinToleranceValue(pixelRGB, targetRGB, tolerance) : (pixelRGB = targetRGB)
				if (matched)
				{
					neighbors++
					if (neighbors >= minimumNeighbors)
						return true
				}
			}
			x++
			pixelOffset += 4
		}
		y++
	}
	return false
}

; ================================================================
; |     COLOR DETECTION     -     COLOR DETECTION                |
; ================================================================

; Resolves a script-supplied RGB matcher so color detection can reuse the same
; capture, cluster, verification, and tracking machinery for different objects.
LLARS_ColorResolveMatcher(matcher)
{
	if IsObject(matcher)
		return matcher

	matcher := Trim(matcher)
	if (matcher = "" || !IsFunc(matcher))
		return ""

	return Func(matcher)
}

; Returns the active RuneScape client geometry without forcing focus.
LLARS_ColorGetRuneScapeClient(ByRef hWnd, ByRef clientWidth, ByRef clientHeight, requireRun := true)
{
	global LLARS_RUNNING, LLARS_RunRuneScapeHwnd

	hWnd := 0
	clientWidth := 0
	clientHeight := 0
	if (requireRun && !LLARS_RUNNING)
		return false

	hWnd := LLARS_RunRuneScapeHwnd
	if (!hWnd || !DllCall("IsWindow", "Ptr", hWnd) || !LLARS_IsRuneScapeWindow(hWnd))
		return false
	if DllCall("IsIconic", "Ptr", hWnd)
		return false

	VarSetCapacity(clientRect, 16, 0)
	if !DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &clientRect)
		return false
	clientWidth := NumGet(clientRect, 8, "Int")
	clientHeight := NumGet(clientRect, 12, "Int")
	return (clientWidth > 0 && clientHeight > 0 && clientWidth <= 16384 && clientHeight <= 16384)
}

; Captures the visible foreground RuneScape client using the normal desktop path.
LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, ByRef captureMethod := "")
{
	captureMethod := ""
	if (!hWnd || clientWidth <= 0 || clientHeight <= 0)
		return ""
	if (DllCall("GetForegroundWindow", "Ptr") != hWnd)
		return ""

	capture := LLARS_CreatorCaptureClientPixels(hWnd, clientWidth, clientHeight)
	if !IsObject(capture)
		return ""

	captureMethod := "Visible BitBlt"
	capture.Method := captureMethod
	return capture
}

; Rejects empty/black off-screen captures before any detector trusts the frame.
LLARS_ColorCaptureHasContent(bits, width, height)
{
	if (!bits || width <= 0 || height <= 0)
		return false

	nonBlack := 0
	total := 0
	step := 32
	y := 0
	while (y < height)
	{
		x := 0
		while (x < width)
		{
			rgb := NumGet(bits + (((y * width) + x) * 4), 0, "UInt") & 0xFFFFFF
			if (rgb != 0)
				nonBlack++
			total++
			x += step
		}
		y += step
	}

	return (total > 0 && nonBlack >= Max(8, Round(total * 0.02)))
}

; Captures one full client frame through PrintWindow.
LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, ByRef captureMethod := "")
{
	captureMethod := ""
	if (!hWnd || clientWidth <= 0 || clientHeight <= 0)
		return ""

	hScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
	if (!hScreenDC)
		return ""
	hMemoryDC := DllCall("gdi32\CreateCompatibleDC", "Ptr", hScreenDC, "Ptr")
	if (!hMemoryDC)
	{
		DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)
		return ""
	}

	VarSetCapacity(bitmapInfo, 40, 0)
	NumPut(40, bitmapInfo, 0, "UInt")
	NumPut(clientWidth, bitmapInfo, 4, "Int")
	NumPut(-clientHeight, bitmapInfo, 8, "Int")
	NumPut(1, bitmapInfo, 12, "UShort")
	NumPut(32, bitmapInfo, 14, "UShort")
	NumPut(0, bitmapInfo, 16, "UInt")
	bits := 0
	hBitmap := DllCall("gdi32\CreateDIBSection", "Ptr", hScreenDC, "Ptr", &bitmapInfo, "UInt", 0, "Ptr*", bits, "Ptr", 0, "UInt", 0, "Ptr")
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)
	if (!hBitmap || !bits)
	{
		if (hBitmap)
			DllCall("gdi32\DeleteObject", "Ptr", hBitmap)
		DllCall("gdi32\DeleteDC", "Ptr", hMemoryDC)
		return ""
	}

	oldBitmap := DllCall("gdi32\SelectObject", "Ptr", hMemoryDC, "Ptr", hBitmap, "Ptr")
	bufferBytes := clientWidth * clientHeight * 4
	printed := false

	; Keep the proven RuneScape path to one full composited render per check.
	DllCall("ntdll\RtlZeroMemory", "Ptr", bits, "UPtr", bufferBytes)
	printed := DllCall("PrintWindow", "Ptr", hWnd, "Ptr", hMemoryDC, "UInt", 3)
	if (printed && LLARS_ColorCaptureHasContent(bits, clientWidth, clientHeight))
		captureMethod := "PrintWindow flags=3"
	else
		printed := false

	if (!printed)
	{
		if (oldBitmap)
			DllCall("gdi32\SelectObject", "Ptr", hMemoryDC, "Ptr", oldBitmap, "Ptr")
		DllCall("gdi32\DeleteObject", "Ptr", hBitmap)
		DllCall("gdi32\DeleteDC", "Ptr", hMemoryDC)
		return ""
	}

	return {Bits:bits, Width:clientWidth, Height:clientHeight, MemoryDC:hMemoryDC, Bitmap:hBitmap, OldBitmap:oldBitmap, Method:captureMethod}
}

; Counts matcher-qualified pixels around a point using a configurable sample grid.
LLARS_ColorDensity(capture, matcher, centerX, centerY, radius := 32, sampleStep := 4)
{
	if !IsObject(capture)
		return 0
	matcherFunc := LLARS_ColorResolveMatcher(matcher)
	if !IsObject(matcherFunc)
		return 0

	x1 := Max(0, Round(centerX) - radius)
	x2 := Min(capture.Width - 1, Round(centerX) + radius)
	y1 := Max(0, Round(centerY) - radius)
	y2 := Min(capture.Height - 1, Round(centerY) + radius)
	density := 0
	y := y1
	while (y <= y2)
	{
		x := x1
		while (x <= x2)
		{
			offset := ((y * capture.Width) + x) * 4
			rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
			if (matcherFunc.Call(rgb))
				density++
			x += sampleStep
		}
		y += sampleStep
	}
	return density
}

; Finds the large matcher-qualified cluster nearest the client center and chooses
; a dense interior point rather than an edge/background pixel.
LLARS_ColorFindLargeClusterFromCapture(capture, matcher, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity, minimumClusterSamples := 260, sampleStep := 4, cellSize := 48, minimumPointDensity := 30, pointDensityRadius := 8, pointDensityStep := 2, targetDensityRadius := 32, targetDensityStep := 4, selectionMode := "spread")
{
	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0
	if !IsObject(capture)
		return false
	matcherFunc := LLARS_ColorResolveMatcher(matcher)
	if !IsObject(matcherFunc)
		return false

	cells := {}
	y := 0
	while (y < capture.Height)
	{
		x := 0
		pixelOffset := (y * capture.Width) * 4
		while (x < capture.Width)
		{
			rgb := NumGet(capture.Bits + pixelOffset, 0, "UInt") & 0xFFFFFF
			if (matcherFunc.Call(rgb))
			{
				cellX := Floor(x / cellSize)
				cellY := Floor(y / cellSize)
				key := cellX . "|" . cellY
				if !cells.HasKey(key)
					cells[key] := {Count:0, SumX:0, SumY:0}
				cell := cells[key]
				cell.Count++
				cell.SumX += x
				cell.SumY += y
			}
			x += sampleStep
			pixelOffset += sampleStep * 4
		}
		y += sampleStep
	}

	clientCenterX := (capture.Width - 1) / 2.0
	clientCenterY := (capture.Height - 1) / 2.0
	bestScore := 0
	bestCellX := ""
	bestCellY := ""
	bestCenterX := ""
	bestCenterY := ""
	bestScreenDistance := ""
	for key, cell in cells
	{
		parts := StrSplit(key, "|")
		baseX := parts[1] + 0
		baseY := parts[2] + 0
		clusterCount := 0
		clusterSumX := 0
		clusterSumY := 0

		dyCell := -1
		while (dyCell <= 1)
		{
			dxCell := -1
			while (dxCell <= 1)
			{
				neighborKey := (baseX + dxCell) . "|" . (baseY + dyCell)
				if cells.HasKey(neighborKey)
				{
					neighbor := cells[neighborKey]
					clusterCount += neighbor.Count
					clusterSumX += neighbor.SumX
					clusterSumY += neighbor.SumY
				}
				dxCell++
			}
			dyCell++
		}

		if (clusterCount < minimumClusterSamples)
			continue

		centerX := Round(clusterSumX / clusterCount)
		centerY := Round(clusterSumY / clusterCount)
		dxScreen := centerX - clientCenterX
		dyScreen := centerY - clientCenterY
		screenDistance := (dxScreen * dxScreen) + (dyScreen * dyScreen)
		if (bestScreenDistance = "" || screenDistance < bestScreenDistance || (screenDistance = bestScreenDistance && clusterCount > bestScore))
		{
			bestScore := clusterCount
			bestCellX := baseX
			bestCellY := baseY
			bestCenterX := centerX
			bestCenterY := centerY
			bestScreenDistance := screenDistance
		}
	}

	if (bestScore <= 0 || bestCellX = "" || bestCellY = "")
		return false

	; The 3x3 cluster chooses which object wins.
	x1 := Max(0, (bestCellX - 1) * cellSize)
	x2 := Min(capture.Width - 1, ((bestCellX + 2) * cellSize) - 1)
	y1 := Max(0, (bestCellY - 1) * cellSize)
	y2 := Min(capture.Height - 1, ((bestCellY + 2) * cellSize) - 1)
	seedX := ""
	seedY := ""
	seedDensity := -1
	seedDistance := ""

	y := y1
	while (y <= y2)
	{
		x := x1
		while (x <= x2)
		{
			offset := ((y * capture.Width) + x) * 4
			rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
			if (matcherFunc.Call(rgb))
			{
				density := LLARS_ColorDensity(capture, matcherFunc, x, y, pointDensityRadius, pointDensityStep)
				dx := x - bestCenterX
				dy := y - bestCenterY
				distance := (dx * dx) + (dy * dy)
				if (density > seedDensity || (density = seedDensity && (seedDistance = "" || distance < seedDistance)))
				{
					seedDensity := density
					seedDistance := distance
					seedX := x
					seedY := y
				}
			}
			x += 2
		}
		y += 2
	}

	if (seedX = "" || seedY = "" || seedDensity < minimumPointDensity)
		return false

	componentStep := 2
	componentRadius := Max(200, cellSize * 5)
	regionSize := Max(28, Round(cellSize * 0.67))
	componentLeft := Max(0, seedX - componentRadius)
	componentRight := Min(capture.Width - 1, seedX + componentRadius)
	componentTop := Max(0, seedY - componentRadius)
	componentBottom := Min(capture.Height - 1, seedY + componentRadius)
	queueX := [seedX]
	queueY := [seedY]
	visited := {}
	visited[seedX . "|" . seedY] := true
	head := 1
	candidateRegions := {}
	candidateCount := 0

	while (head <= queueX.Length())
	{
		pointX := queueX[head]
		pointY := queueY[head]
		head++

		density := LLARS_ColorDensity(capture, matcherFunc, pointX, pointY, pointDensityRadius, pointDensityStep)
		if (density >= minimumPointDensity)
		{
			regionX := Floor(pointX / regionSize)
			regionY := Floor(pointY / regionSize)
			regionKey := regionX . "|" . regionY
			if !candidateRegions.HasKey(regionKey)
				candidateRegions[regionKey] := []
			regionCandidates := candidateRegions[regionKey]
			regionCandidates.Push({X:pointX, Y:pointY, Density:density})
			candidateCount++
		}

		dyStep := -componentStep
		while (dyStep <= componentStep)
		{
			dxStep := -componentStep
			while (dxStep <= componentStep)
			{
				if (dxStep != 0 || dyStep != 0)
				{
					nextX := pointX + dxStep
					nextY := pointY + dyStep
					if (nextX >= componentLeft && nextX <= componentRight && nextY >= componentTop && nextY <= componentBottom)
					{
						pointKey := nextX . "|" . nextY
						if !visited.HasKey(pointKey)
						{
							visited[pointKey] := true
							offset := ((nextY * capture.Width) + nextX) * 4
							rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
							if (matcherFunc.Call(rgb))
							{
								queueX.Push(nextX)
								queueY.Push(nextY)
							}
						}
					}
				}
				dxStep += componentStep
			}
			dyStep += componentStep
		}
	}

	if (candidateCount <= 0)
		return false

	; Pick a spatial region first, then a safe point inside it.
	eligibleRegions := []
	for regionKey, regionCandidates in candidateRegions
	{
		if (regionCandidates.Length() >= 6)
			eligibleRegions.Push(regionKey)
	}
	if (eligibleRegions.Length() = 0)
	{
		for regionKey, regionCandidates in candidateRegions
		{
			if (regionCandidates.Length() > 0)
				eligibleRegions.Push(regionKey)
		}
	}
	if (eligibleRegions.Length() = 0)
		return false

	matcherName := IsObject(matcher) ? "Matcher" : Trim(matcher)
	if (matcherName = "")
		matcherName := "Matcher"

	selectionMode := Trim(selectionMode)
	StringLower, selectionMode, selectionMode
	if (selectionMode = "center-biased" || selectionMode = "center")
	{
		; Small targets benefit from clicks near the visual center, but an exact center click every time looks mechanical.
		maxCandidateDistance := 0
		for regionKey, regionCandidates in candidateRegions
		{
			for candidateIndex, candidate in regionCandidates
			{
				dx := candidate.X - bestCenterX
				dy := candidate.Y - bestCenterY
				distance := Sqrt((dx * dx) + (dy * dy))
				if (distance > maxCandidateDistance)
					maxCandidateDistance := distance
			}
		}

		centerRadius := Max(8, Round(maxCandidateDistance * 0.55))
		densityFloor := Max(minimumPointDensity, Floor(seedDensity * 0.70))
		centerCandidates := []
		for regionKey, regionCandidates in candidateRegions
		{
			for candidateIndex, candidate in regionCandidates
			{
				dx := candidate.X - bestCenterX
				dy := candidate.Y - bestCenterY
				if (((dx * dx) + (dy * dy)) <= (centerRadius * centerRadius)
					&& candidate.Density >= densityFloor)
					centerCandidates.Push(candidate)
			}
		}

		if (centerCandidates.Length() = 0)
		{
			for regionKey, regionCandidates in candidateRegions
			{
				for candidateIndex, candidate in regionCandidates
				{
					dx := candidate.X - bestCenterX
					dy := candidate.Y - bestCenterY
					if (((dx * dx) + (dy * dy)) <= (centerRadius * centerRadius))
						centerCandidates.Push(candidate)
				}
			}
		}

		if (centerCandidates.Length() > 0)
		{
			choiceIndex := LLARS_HumanRandomInt(1, centerCandidates.Length(), "Color.LargeCluster.CenterPoint." . matcherName, 8)
			choice := centerCandidates[choiceIndex]
		}
	}

	if !IsObject(choice)
	{
		regionIndex := LLARS_HumanRandomInt(1, eligibleRegions.Length(), "Color.LargeCluster.SafeRegion." . matcherName, 4)
		chosenRegion := eligibleRegions[regionIndex]
		regionCandidates := candidateRegions[chosenRegion]
		choiceIndex := LLARS_HumanRandomInt(1, regionCandidates.Length(), "Color.LargeCluster.SafePoint." . matcherName . "." . chosenRegion, 8)
		choice := regionCandidates[choiceIndex]
	}

	foundX := choice.X
	foundY := choice.Y
	targetScore := bestScore
	targetDensity := LLARS_ColorDensity(capture, matcherFunc, foundX, foundY, targetDensityRadius, targetDensityStep)
	return (targetDensity > 0)
}

; Foreground-only convenience wrapper for large-cluster acquisition.
LLARS_ColorFindRuneScapeLargeCluster(matcher, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity, minimumClusterSamples := 260, sampleStep := 4, cellSize := 48, minimumPointDensity := 30, pointDensityRadius := 8, pointDensityStep := 2, targetDensityRadius := 32, targetDensityStep := 4, selectionMode := "spread")
{
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return false

	captureMethod := ""
	capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return false

	found := LLARS_ColorFindLargeClusterFromCapture(capture, matcher, foundX, foundY, targetScore, targetDensity, minimumClusterSamples, sampleStep, cellSize, minimumPointDensity, pointDensityRadius, pointDensityStep, targetDensityRadius, targetDensityStep, selectionMode)
	LLARS_CreatorReleaseCapture(capture)
	return found
}

; Keeps the chosen dense point when it remains safe; otherwise reacquires nearby.
LLARS_ColorReacquireDensePoint(capture, matcher, ByRef clientX, ByRef clientY, radius := 24, minimumDensity := 20, densityRadius := 6, densityStep := 2)
{
	if !IsObject(capture)
		return false
	matcherFunc := LLARS_ColorResolveMatcher(matcher)
	if !IsObject(matcherFunc)
		return false

	originalX := Round(clientX + 0)
	originalY := Round(clientY + 0)
	if (originalX >= 0 && originalX < capture.Width && originalY >= 0 && originalY < capture.Height)
	{
		originalOffset := ((originalY * capture.Width) + originalX) * 4
		originalRGB := NumGet(capture.Bits + originalOffset, 0, "UInt") & 0xFFFFFF
		if (matcherFunc.Call(originalRGB))
		{
			originalDensity := LLARS_ColorDensity(capture, matcherFunc, originalX, originalY, densityRadius, densityStep)
			if (originalDensity >= minimumDensity)
				return true
		}
	}

	x1 := Max(0, originalX - radius)
	x2 := Min(capture.Width - 1, originalX + radius)
	y1 := Max(0, originalY - radius)
	y2 := Min(capture.Height - 1, originalY + radius)
	bestX := ""
	bestY := ""
	bestDensity := -1
	bestDistance := ""

	; Only reacquire when the originally selected point is no longer safe.
	y := y1
	while (y <= y2)
	{
		x := x1
		while (x <= x2)
		{
			offset := ((y * capture.Width) + x) * 4
			rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
			if (matcherFunc.Call(rgb))
			{
				density := LLARS_ColorDensity(capture, matcherFunc, x, y, densityRadius, densityStep)
				dx := x - originalX
				dy := y - originalY
				distance := (dx * dx) + (dy * dy)
				if (density > bestDensity || (density = bestDensity && (bestDistance = "" || distance < bestDistance)))
				{
					bestDensity := density
					bestDistance := distance
					bestX := x
					bestY := y
				}
			}
			x += 2
		}
		y += 2
	}

	if (bestX = "" || bestY = "" || bestDensity < minimumDensity)
		return false

	clientX := bestX
	clientY := bestY
	return true
}

; Verifies that a target is still a dense match immediately before clicking it.
LLARS_ColorClickDenseTarget(ByRef clientX, ByRef clientY, matcher, actionName := "Color Target", button := "left", reacquireRadius := 24, minimumReacquireDensity := 20, minimumTargetDensity := 40, targetDensityRadius := 32, targetDensityStep := 4)
{
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return false

	captureMethod := ""
	capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return false

	verified := LLARS_ColorReacquireDensePoint(capture, matcher, clientX, clientY, reacquireRadius, minimumReacquireDensity, 6, 2)
	targetDensity := verified ? LLARS_ColorDensity(capture, matcher, clientX, clientY, targetDensityRadius, targetDensityStep) : 0
	LLARS_CreatorReleaseCapture(capture)

	if (!verified || targetDensity < minimumTargetDensity)
		return false

	return LLARS_ClickPoint(clientX, clientY, button, actionName)
}

; Tracks only the connected matcher-qualified component attached to the last known target point.
LLARS_ColorTrackConnectedComponent(capture, matcher, ByRef clientX, ByRef clientY, ByRef trackingScore, radius := 118, seedRadius := 34, step := 4, minimumSamples := 78, minimumWidth := 38, minimumHeight := 38)
{
	trackingScore := 0
	if !IsObject(capture)
		return false
	matcherFunc := LLARS_ColorResolveMatcher(matcher)
	if !IsObject(matcherFunc)
		return false

	originalX := Round(clientX + 0)
	originalY := Round(clientY + 0)
	seedX := ""
	seedY := ""
	bestSeedDistance := ""

	seedTop := Max(0, originalY - seedRadius)
	seedBottom := Min(capture.Height - 1, originalY + seedRadius)
	seedLeft := Max(0, originalX - seedRadius)
	seedRight := Min(capture.Width - 1, originalX + seedRadius)
	y := seedTop
	while (y <= seedBottom)
	{
		x := seedLeft
		while (x <= seedRight)
		{
			offset := ((y * capture.Width) + x) * 4
			rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
			if (matcherFunc.Call(rgb))
			{
				dx := x - originalX
				dy := y - originalY
				distance := (dx * dx) + (dy * dy)
				if (bestSeedDistance = "" || distance < bestSeedDistance)
				{
					bestSeedDistance := distance
					seedX := x
					seedY := y
				}
			}
			x += step
		}
		y += step
	}

	if (seedX = "" || seedY = "")
		return false

	x1 := Max(0, originalX - radius)
	x2 := Min(capture.Width - 1, originalX + radius)
	y1 := Max(0, originalY - radius)
	y2 := Min(capture.Height - 1, originalY + radius)
	queueX := [seedX]
	queueY := [seedY]
	visited := {}
	visited[seedX . "|" . seedY] := true
	head := 1
	count := 0
	minX := seedX
	maxX := seedX
	minY := seedY
	maxY := seedY

	while (head <= queueX.Length())
	{
		pointX := queueX[head]
		pointY := queueY[head]
		head++
		count++
		minX := Min(minX, pointX)
		maxX := Max(maxX, pointX)
		minY := Min(minY, pointY)
		maxY := Max(maxY, pointY)

		dyStep := -step
		while (dyStep <= step)
		{
			dxStep := -step
			while (dxStep <= step)
			{
				if (dxStep != 0 || dyStep != 0)
				{
					nextX := pointX + dxStep
					nextY := pointY + dyStep
					if (nextX >= x1 && nextX <= x2 && nextY >= y1 && nextY <= y2)
					{
						key := nextX . "|" . nextY
						if !visited.HasKey(key)
						{
							visited[key] := true
							offset := ((nextY * capture.Width) + nextX) * 4
							rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
							if (matcherFunc.Call(rgb))
							{
								queueX.Push(nextX)
								queueY.Push(nextY)
							}
						}
					}
				}
				dxStep += step
			}
			dyStep += step
		}
	}

	trackingScore := count
	if (count < minimumSamples)
		return false
	if ((maxX - minX) < minimumWidth || (maxY - minY) < minimumHeight)
		return false

	clientX := seedX
	clientY := seedY
	return true
}

; Builds a compact, spatially distributed signature from one connected color component.
LLARS_ColorBuildComponentSignature(capture, matcher, centerX, centerY, radius := 46, seedRadius := 8, componentStep := 2, minimumSamples := 12, minimumWidth := 8, minimumHeight := 8, gridSize := 3)
{
	if !IsObject(capture)
		return ""
	matcherFunc := LLARS_ColorResolveMatcher(matcher)
	if !IsObject(matcherFunc)
		return ""

	if (componentStep < 1)
		componentStep := 1
	if (gridSize < 2)
		gridSize := 2
	if (gridSize > 5)
		gridSize := 5

	originalX := Round(centerX + 0)
	originalY := Round(centerY + 0)
	seedX := ""
	seedY := ""
	bestSeedDistance := ""
	seedTop := Max(0, originalY - seedRadius)
	seedBottom := Min(capture.Height - 1, originalY + seedRadius)
	seedLeft := Max(0, originalX - seedRadius)
	seedRight := Min(capture.Width - 1, originalX + seedRadius)

	y := seedTop
	while (y <= seedBottom)
	{
		x := seedLeft
		while (x <= seedRight)
		{
			offset := ((y * capture.Width) + x) * 4
			rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
			if (matcherFunc.Call(rgb))
			{
				dx := x - originalX
				dy := y - originalY
				distance := (dx * dx) + (dy * dy)
				if (bestSeedDistance = "" || distance < bestSeedDistance)
				{
					bestSeedDistance := distance
					seedX := x
					seedY := y
				}
			}
			x += componentStep
		}
		y += componentStep
	}

	if (seedX = "" || seedY = "")
		return ""

	x1 := Max(0, originalX - radius)
	x2 := Min(capture.Width - 1, originalX + radius)
	y1 := Max(0, originalY - radius)
	y2 := Min(capture.Height - 1, originalY + radius)
	queueX := [seedX]
	queueY := [seedY]
	visited := {}
	visited[seedX . "|" . seedY] := true
	componentPoints := []
	head := 1
	minX := seedX
	maxX := seedX
	minY := seedY
	maxY := seedY

	while (head <= queueX.Length())
	{
		pointX := queueX[head]
		pointY := queueY[head]
		head++
		componentPoints.Push({X:pointX, Y:pointY})
		minX := Min(minX, pointX)
		maxX := Max(maxX, pointX)
		minY := Min(minY, pointY)
		maxY := Max(maxY, pointY)

		dyStep := -componentStep
		while (dyStep <= componentStep)
		{
			dxStep := -componentStep
			while (dxStep <= componentStep)
			{
				if (dxStep != 0 || dyStep != 0)
				{
					nextX := pointX + dxStep
					nextY := pointY + dyStep
					if (nextX >= x1 && nextX <= x2 && nextY >= y1 && nextY <= y2)
					{
						key := nextX . "|" . nextY
						if !visited.HasKey(key)
						{
							visited[key] := true
							offset := ((nextY * capture.Width) + nextX) * 4
							rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
							if (matcherFunc.Call(rgb))
							{
								queueX.Push(nextX)
								queueY.Push(nextY)
							}
						}
					}
				}
				dxStep += componentStep
			}
			dyStep += componentStep
		}
	}

	pointCount := componentPoints.Length()
	if (pointCount < minimumSamples)
		return ""
	if ((maxX - minX) < minimumWidth || (maxY - minY) < minimumHeight)
		return ""

	; Pick one dense interior point from each occupied spatial cell.
	signaturePoints := []
	spanWidth := Max(1, (maxX - minX) + 1)
	spanHeight := Max(1, (maxY - minY) + 1)
	row := 0
	while (row < gridSize)
	{
		cellTop := minY + Floor((spanHeight * row) / gridSize)
		cellBottom := minY + Floor((spanHeight * (row + 1)) / gridSize) - 1
		if (row = gridSize - 1)
			cellBottom := maxY

		column := 0
		while (column < gridSize)
		{
			cellLeft := minX + Floor((spanWidth * column) / gridSize)
			cellRight := minX + Floor((spanWidth * (column + 1)) / gridSize) - 1
			if (column = gridSize - 1)
				cellRight := maxX

			bestPoint := ""
			bestDistance := ""
			cellCenterX := (cellLeft + cellRight) / 2.0
			cellCenterY := (cellTop + cellBottom) / 2.0
			for pointIndex, point in componentPoints
			{
				if (point.X >= cellLeft && point.X <= cellRight && point.Y >= cellTop && point.Y <= cellBottom)
				{
					dx := point.X - cellCenterX
					dy := point.Y - cellCenterY
					distance := (dx * dx) + (dy * dy)
					if (bestDistance = "" || distance < bestDistance)
					{
						bestDistance := distance
						bestPoint := point
					}
				}
			}

			if IsObject(bestPoint)
				signaturePoints.Push({DX:bestPoint.X - originalX, DY:bestPoint.Y - originalY, Group:(row * gridSize) + column + 1})
			column++
		}
		row++
	}

	if (signaturePoints.Length() < 4)
		return ""

	return {AnchorX:originalX
		, AnchorY:originalY
		, Points:signaturePoints
		, PointCount:signaturePoints.Length()
		, ComponentSamples:pointCount
		, Width:(maxX - minX)
		, Height:(maxY - minY)
		, CaptureWidth:capture.Width
		, CaptureHeight:capture.Height}
}

; Foreground convenience wrapper for building a component signature immediately
; after a target is acquired/clicked.
LLARS_ColorBuildRuneScapeComponentSignature(matcher, centerX, centerY, radius := 46, seedRadius := 8, componentStep := 2, minimumSamples := 12, minimumWidth := 8, minimumHeight := 8, gridSize := 3)
{
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return ""

	captureMethod := ""
	capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return ""

	signature := LLARS_ColorBuildComponentSignature(capture, matcher, centerX, centerY, radius, seedRadius, componentStep, minimumSamples, minimumWidth, minimumHeight, gridSize)
	LLARS_CreatorReleaseCapture(capture)
	return signature
}

LLARS_ColorSignaturePointMatches(capture, matcherFunc, x, y, radius := 2)
{
	if !IsObject(capture) || !IsObject(matcherFunc)
		return false

	left := Max(0, Round(x) - radius)
	right := Min(capture.Width - 1, Round(x) + radius)
	top := Max(0, Round(y) - radius)
	bottom := Min(capture.Height - 1, Round(y) + radius)
	yy := top
	while (yy <= bottom)
	{
		xx := left
		while (xx <= right)
		{
			offset := ((yy * capture.Width) + xx) * 4
			rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
			if (matcherFunc.Call(rgb))
				return true
			xx++
		}
		yy++
	}
	return false
}

; Matches a previously built component signature inside a small translation window.
LLARS_ColorMatchComponentSignature(capture, signature, matcher, ByRef matchRatio := 0.0, ByRef matchedPoints := 0, searchRadius := 8, searchStep := 2, pointRadius := 2, minimumRatio := 0.45, minimumMatchedPoints := 4, minimumCoverage := 0.0)
{
	matchRatio := 0.0
	matchedPoints := 0
	if !IsObject(capture) || !IsObject(signature) || !IsObject(signature.Points)
		return false
	if (signature.CaptureWidth != capture.Width || signature.CaptureHeight != capture.Height)
		return false
	matcherFunc := LLARS_ColorResolveMatcher(matcher)
	if !IsObject(matcherFunc)
		return false
	if (searchStep < 1)
		searchStep := 1

	bestMatched := 0
	bestCoverage := 0.0
	bestOffsetX := 0
	bestOffsetY := 0
	bestOffsetDistance := ""
	offsetY := -searchRadius
	while (offsetY <= searchRadius)
	{
		offsetX := -searchRadius
		while (offsetX <= searchRadius)
		{
			currentMatched := 0
			matchedMinDX := ""
			matchedMaxDX := ""
			matchedMinDY := ""
			matchedMaxDY := ""
			for pointIndex, point in signature.Points
			{
				x := signature.AnchorX + point.DX + offsetX
				y := signature.AnchorY + point.DY + offsetY
				if LLARS_ColorSignaturePointMatches(capture, matcherFunc, x, y, pointRadius)
				{
					currentMatched++
					if (matchedMinDX = "" || point.DX < matchedMinDX)
						matchedMinDX := point.DX
					if (matchedMaxDX = "" || point.DX > matchedMaxDX)
						matchedMaxDX := point.DX
					if (matchedMinDY = "" || point.DY < matchedMinDY)
						matchedMinDY := point.DY
					if (matchedMaxDY = "" || point.DY > matchedMaxDY)
						matchedMaxDY := point.DY
				}
			}

			coverageX := (currentMatched > 1) ? ((matchedMaxDX - matchedMinDX) / Max(1.0, signature.Width)) : 0.0
			coverageY := (currentMatched > 1) ? ((matchedMaxDY - matchedMinDY) / Max(1.0, signature.Height)) : 0.0
			currentCoverage := Min(coverageX, coverageY)
			offsetDistance := (offsetX * offsetX) + (offsetY * offsetY)
			if (currentMatched > bestMatched
				|| (currentMatched = bestMatched && currentCoverage > bestCoverage)
				|| (currentMatched = bestMatched && currentCoverage = bestCoverage && currentMatched > 0 && (bestOffsetDistance = "" || offsetDistance < bestOffsetDistance)))
			{
				bestMatched := currentMatched
				bestCoverage := currentCoverage
				bestOffsetX := offsetX
				bestOffsetY := offsetY
				bestOffsetDistance := offsetDistance
			}
			offsetX += searchStep
		}
		offsetY += searchStep
	}

	matchedPoints := bestMatched
	matchRatio := (signature.PointCount > 0) ? (bestMatched * 1.0 / signature.PointCount) : 0.0
	signature.LastOffsetX := bestOffsetX
	signature.LastOffsetY := bestOffsetY
	signature.LastCoverage := bestCoverage
	return (bestMatched >= minimumMatchedPoints
		&& matchRatio >= minimumRatio
		&& (minimumCoverage <= 0 || bestCoverage >= minimumCoverage))
}

; Tracks a DTM-style component signature in foreground or through the same proven throttled PrintWindow(flags=3) background path used by the connected tracker.
LLARS_ColorTrackRuneScapeSignature(signature, matcher, ByRef matchRatio, ByRef matchedPoints, trackerKey := "Color Signature", searchRadius := 8, searchStep := 2, pointRadius := 2, minimumRatio := 0.45, minimumMatchedPoints := 4, backgroundInterval := 2000, useContextMenuGuard := true, minimumCoverage := 0.0)
{
	static backgroundCaptureTicks := ""

	matchRatio := 0.0
	matchedPoints := 0
	if !IsObject(signature)
		return -1
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return -1

	if !IsObject(backgroundCaptureTicks)
		backgroundCaptureTicks := {}
	trackerKey := Trim(trackerKey)
	if (trackerKey = "")
		trackerKey := "Color Signature"
	lastBackgroundCaptureTick := backgroundCaptureTicks.HasKey(trackerKey) ? backgroundCaptureTicks[trackerKey] : 0

	if (DllCall("GetForegroundWindow", "Ptr") != hWnd)
	{
		if (lastBackgroundCaptureTick && (A_TickCount - lastBackgroundCaptureTick) < backgroundInterval)
			return -1

		backgroundCaptureTicks[trackerKey] := A_TickCount
		captureMethod := ""
		capture := LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, captureMethod)
	}
	else
	{
		backgroundCaptureTicks[trackerKey] := 0
		captureMethod := ""
		capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	}

	if !IsObject(capture)
		return -1

	if (useContextMenuGuard && LLARS_ColorContextMenuOverlapsTarget(capture, signature.AnchorX, signature.AnchorY))
	{
		LLARS_CreatorReleaseCapture(capture)
		return -1
	}

	present := LLARS_ColorMatchComponentSignature(capture, signature, matcher, matchRatio, matchedPoints, searchRadius, searchStep, pointRadius, minimumRatio, minimumMatchedPoints, minimumCoverage)
	if (present)
	{
		; Follow only a high-confidence local translation.
		anchorUpdateRatio := Max(0.58, minimumRatio + 0.14)
		if (matchRatio >= anchorUpdateRatio)
		{
			signature.AnchorX := Max(0, Min(capture.Width - 1, signature.AnchorX + signature.LastOffsetX))
			signature.AnchorY := Max(0, Min(capture.Height - 1, signature.AnchorY + signature.LastOffsetY))
		}
	}
	LLARS_CreatorReleaseCapture(capture)
	return present ? 1 : 0
}

; RuneScape right-click menus are dark text panels that can visually cover a target.
LLARS_ColorContextMenuOverlapsTarget(capture, centerX, centerY)
{
	if !IsObject(capture)
		return false

	searchLeft := Max(0, Round(centerX) - 165)
	searchRight := Min(capture.Width - 1, Round(centerX) + 165)
	searchTop := Max(0, Round(centerY) - 125)
	searchBottom := Min(capture.Height - 1, Round(centerY) + 125)
	windowWidth := 120
	windowHeight := 56
	windowStep := 16
	sampleStep := 8

	top := searchTop
	while (top + windowHeight <= searchBottom)
	{
		left := searchLeft
		while (left + windowWidth <= searchRight)
		{
			if (left <= centerX + 52 && left + windowWidth >= centerX - 52
				&& top <= centerY + 52 && top + windowHeight >= centerY - 52)
			{
				dark := 0
				bright := 0
				total := 0
				y := top
				while (y <= top + windowHeight)
				{
					x := left
					while (x <= left + windowWidth)
					{
						offset := ((y * capture.Width) + x) * 4
						rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
						red := (rgb >> 16) & 0xFF
						green := (rgb >> 8) & 0xFF
						blue := rgb & 0xFF
						maximum := Max(red, green, blue)
						if (maximum <= 58)
							dark++
						else if (maximum >= 155)
							bright++
						total++
						x += sampleStep
					}
					y += sampleStep
				}

				if (total > 0 && dark >= Round(total * 0.42) && bright >= 5)
					return true
			}
			left += windowStep
		}
		top += windowStep
	}

	return false
}

LLARS_RGBDifferenceValue(rgbA, rgbB)
{
	redA := (rgbA >> 16) & 0xFF
	greenA := (rgbA >> 8) & 0xFF
	blueA := rgbA & 0xFF
	redB := (rgbB >> 16) & 0xFF
	greenB := (rgbB >> 8) & 0xFF
	blueB := rgbB & 0xFF

	return Max(Abs(redA - redB), Abs(greenA - greenB), Abs(blueA - blueB))
}

; Builds a reusable signature from stable pixels inside one capture region.
LLARS_ColorBuildStableRegionSignature(frameA, frameB, left, top, right, bottom, sampleStep := 3, stabilityThreshold := 14, maximumBrightness := "", maximumChroma := "")
{
	if !IsObject(frameA) || !IsObject(frameB)
		return ""
	if (frameA.Width != frameB.Width || frameA.Height != frameB.Height)
		return ""

	left := Max(0, Round(left))
	top := Max(0, Round(top))
	right := Min(frameA.Width - 1, Round(right))
	bottom := Min(frameA.Height - 1, Round(bottom))
	if (right <= left || bottom <= top)
		return ""

	if (sampleStep < 1)
		sampleStep := 1

	points := []
	y := top
	while (y <= bottom)
	{
		x := left
		while (x <= right)
		{
			offset := ((y * frameA.Width) + x) * 4
			rgbA := NumGet(frameA.Bits + offset, 0, "UInt") & 0xFFFFFF
			rgbB := NumGet(frameB.Bits + offset, 0, "UInt") & 0xFFFFFF

			if (LLARS_RGBDifferenceValue(rgbA, rgbB) <= stabilityThreshold)
			{
				red := (rgbA >> 16) & 0xFF
				green := (rgbA >> 8) & 0xFF
				blue := rgbA & 0xFF
				maximum := Max(red, green, blue)
				minimum := Min(red, green, blue)
				chroma := maximum - minimum

				if ((maximumBrightness = "" || maximum <= maximumBrightness)
					&& (maximumChroma = "" || chroma <= maximumChroma))
					points.Push({X:x, Y:y, RGB:rgbA})
			}
			x += sampleStep
		}
		y += sampleStep
	}

	if (points.Length() = 0)
		return ""

	return {Points:points, Width:frameA.Width, Height:frameA.Height, Left:left, Top:top, Right:right, Bottom:bottom}
}

; Compares a live frame against a previously learned stable-region signature.
LLARS_ColorRegionSignatureDifference(capture, signature, differenceThreshold := 38, ByRef changedSamples := 0, ByRef totalSamples := 0)
{
	changedSamples := 0
	totalSamples := 0
	if !IsObject(capture) || !IsObject(signature) || !IsObject(signature.Points)
		return -1
	if (capture.Width != signature.Width || capture.Height != signature.Height)
		return -1

	for index, point in signature.Points
	{
		if (point.X < 0 || point.X >= capture.Width || point.Y < 0 || point.Y >= capture.Height)
			continue

		offset := ((point.Y * capture.Width) + point.X) * 4
		rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF
		totalSamples++
		if (LLARS_RGBDifferenceValue(point.RGB, rgb) >= differenceThreshold)
			changedSamples++
	}

	return (totalSamples > 0) ? (changedSamples * 100.0 / totalSamples) : -1
}

; Measures broad frame movement while ignoring pixels accepted by the supplied
; object matcher so target animation does not look like camera motion.
LLARS_ColorFrameMovementPercent(frameA, frameB, ignoreMatcher := "", step := 20, differenceThreshold := 85)
{
	if !IsObject(frameA) || !IsObject(frameB)
		return 100.0
	if (frameA.Width != frameB.Width || frameA.Height != frameB.Height)
		return 100.0

	matcherFunc := LLARS_ColorResolveMatcher(ignoreMatcher)
	moved := 0
	total := 0
	y := 0
	while (y < frameA.Height)
	{
		x := 0
		while (x < frameA.Width)
		{
			offset := ((y * frameA.Width) + x) * 4
			rgbA := NumGet(frameA.Bits + offset, 0, "UInt") & 0xFFFFFF
			rgbB := NumGet(frameB.Bits + offset, 0, "UInt") & 0xFFFFFF
			ignoreA := IsObject(matcherFunc) ? matcherFunc.Call(rgbA) : false
			ignoreB := IsObject(matcherFunc) ? matcherFunc.Call(rgbB) : false
			if (!ignoreA && !ignoreB)
			{
				total++
				if (LLARS_RGBDifferenceValue(rgbA, rgbB) >= differenceThreshold)
					moved++
			}
			x += step
		}
		y += step
	}

	return (total > 0) ? (moved * 100.0 / total) : 100.0
}

; Returns 1 while the same connected target is present, 0 for a trustworthy
; absent frame, and -1 when capture, occlusion, throttling, or motion is unsafe.
LLARS_ColorTrackRuneScapeTarget(ByRef clientX, ByRef clientY, matcher, ByRef trackingScore, ByRef cameraMotion, trackerKey := "Color Target", componentRadius := 118, seedRadius := 34, componentStep := 4, minimumSamples := 78, minimumWidth := 38, minimumHeight := 38, backgroundInterval := 2000, motionThreshold := 18.0, confirmationDelay := 110, useContextMenuGuard := true)
{
	global LLARS_RUNNING
	static backgroundCaptureTicks := ""

	if !IsObject(backgroundCaptureTicks)
		backgroundCaptureTicks := {}
	trackingScore := 0
	cameraMotion := 0
	matcherFunc := LLARS_ColorResolveMatcher(matcher)
	if !IsObject(matcherFunc)
		return -1
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return -1

	trackerKey := Trim(trackerKey)
	if (trackerKey = "")
		trackerKey := "Color Target"
	lastBackgroundCaptureTick := backgroundCaptureTicks.HasKey(trackerKey) ? backgroundCaptureTicks[trackerKey] : 0

	if (DllCall("GetForegroundWindow", "Ptr") != hWnd)
	{
		if (lastBackgroundCaptureTick && (A_TickCount - lastBackgroundCaptureTick) < backgroundInterval)
			return -1

		backgroundCaptureTicks[trackerKey] := A_TickCount
		captureMethod := ""
		frame := LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, captureMethod)
		if !IsObject(frame)
			return -1

		if (useContextMenuGuard && LLARS_ColorContextMenuOverlapsTarget(frame, clientX, clientY))
		{
			LLARS_CreatorReleaseCapture(frame)
			return -1
		}

		tracked := LLARS_ColorTrackConnectedComponent(frame, matcherFunc, clientX, clientY, trackingScore, componentRadius, seedRadius, componentStep, minimumSamples, minimumWidth, minimumHeight)
		LLARS_CreatorReleaseCapture(frame)
		return tracked ? 1 : 0
	}

	backgroundCaptureTicks[trackerKey] := 0
	captureMethod := ""
	frameA := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(frameA)
		return -1

	Sleep, %confirmationDelay%
	if (!LLARS_RUNNING)
	{
		LLARS_CreatorReleaseCapture(frameA)
		return -1
	}

	frameB := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(frameB)
	{
		LLARS_CreatorReleaseCapture(frameA)
		return -1
	}

	if (useContextMenuGuard && LLARS_ColorContextMenuOverlapsTarget(frameB, clientX, clientY))
	{
		LLARS_CreatorReleaseCapture(frameA)
		LLARS_CreatorReleaseCapture(frameB)
		return -1
	}

	cameraMotion := LLARS_ColorFrameMovementPercent(frameA, frameB, matcherFunc)
	if (cameraMotion > motionThreshold)
	{
		LLARS_CreatorReleaseCapture(frameA)
		LLARS_CreatorReleaseCapture(frameB)
		return -1
	}

	tracked := LLARS_ColorTrackConnectedComponent(frameB, matcherFunc, clientX, clientY, trackingScore, componentRadius, seedRadius, componentStep, minimumSamples, minimumWidth, minimumHeight)
	LLARS_CreatorReleaseCapture(frameA)
	LLARS_CreatorReleaseCapture(frameB)
	return tracked ? 1 : 0
}

; Validates that the required leading entries are configured and that every
; configured color in the supplied set uses a unique RGB value.
LLARS_ValidateUniqueColorSet(sections, groupName, requiredCount := 3, scope := "script", messageTitle := "LLARS Color Configuration")
{
	seen := {}
	for index, section in sections
	{
		color := LLARS_ConfigReadColor(section, "", scope)
		if (color = "")
		{
			if (index <= requiredCount)
			{
				message := groupName . " requires " . requiredCount . " configured colors. [" . section . "] is not configured."
				LLARS_CreatorConfigError(message)
				MsgBox, 48, %messageTitle%, %message%
				return false
			}
			continue
		}
		StringUpper, color, color
		if seen.HasKey(color)
		{
			message := groupName . " must use unique RGB values. [" . section . "] matches [" . seen[color] . "] at " . color . "."
			LLARS_CreatorConfigError(message)
			MsgBox, 48, %messageTitle%, %message%
			return false
		}
		seen[color] := section
	}
	return true
}
