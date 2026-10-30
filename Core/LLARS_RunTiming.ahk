; ================================================================
; |     LLARS RUN TIMING     -     RUNCOUNT & COUNTDOWNS         |
; ================================================================
; Owns Core-dependent run lifecycle timing, countdowns, runtime-estimate
; correction hooks, and Random Sleep timing.

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
	LLARS_RunInputPrompt(runcount, "Run How Many Times?", "Enter how many times to run this script (1-1000).", 350, 155)
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
	LLARS_VisualShowStatus("blue")
	DisableButton()
	startcheck := 1
	LLARS_ResetRunState()
	LLARS_RUNNING := true
	LLARS_PAUSED := false
	SetLLARSHOTKEYS("On")
	runcount3 := runcount
	StartTime := LLARS_NowMS()
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
	LLARS_RunStartTick := LLARS_NowMS()
	LLARS_RUN_TYPE := "UntilDone"
	LLARS_DeveloperAction("Until-Done Run Started")
	LLARS_CreateUntilDoneGUI()
	GuiControl,, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl,, State3, Running
	LLARS_VisualShowStatus("blue")
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
	LLARS_RunInputPrompt(timeToRunMinutes, "Set Run Time", "Enter how long to run in minutes.`nExample: 1 = 1 minute or 0.5 = 30 seconds.", 365, 165)
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
	endTime := LLARS_NowMS() + timeToRunMS
	startcheck := 1
	LLARS_DeveloperKeyStates := {}
	LLARS_RUNNING := true
	LLARS_PAUSED := false
	LLARS_RunStartTick := LLARS_NowMS()
	LLARS_RUN_TYPE := "Timer"
	LLARS_DeveloperAction("Timed Run Started || " . timeToRunMinutes . " min")
	LLARS_CreateTimerGUI()
	GuiControl,, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl,, State3, Running
	LLARS_VisualShowStatus("blue")
	GuiControl,, TimerCount, % LLARS_TimerRemainingText(endTime - LLARS_NowMS())
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
	EstLoopStartTick := LLARS_NowMS()
	LLARS_DeveloperAction("Loop Started || " . (count2 + 1) . "/" . runcount3)
	if IsFunc("LLARS_WaitForRuneScape")
		LLARS_WaitForRuneScape("RunCount loop start")

	++count
	++count2
	GuiControl,, Counter, %count%
	GuiControl,, Counter2, %count2% / %runcount3%
	GuiControl,, ScriptBlue, % LLARS_DisplayScriptName()
	GuiControl,, State3, Running
	LLARS_VisualShowStatus("blue")
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

		sectionMin := LLARS_ConfigReadFile(configFile, sectionName, "min", "ERROR")
		sectionMax := LLARS_ConfigReadFile(configFile, sectionName, "max", "ERROR")

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

	option := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "option", "false")
	option := Trim(option)
	StringLower, option, option

	if (option != "true")
	{
		LLARS_DeveloperRandomSleepConfig("Disabled")
		return false
	}

	chance := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "chance", "ERROR")
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

	option := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "option", "false")
	option := Trim(option)
	StringLower, option, option
	if (option != "true")
		return 0

	chance := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "chance", 0)
	rs1 := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "min", 0)
	rs2 := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "max", 0)
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
	option := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "option", "false")
	option := Trim(option)
	StringLower, option, option
	if (option != "true")
	{
		LLARS_DeveloperRandomSleepConfig("Disabled")
		return 0
	}

	rs1 := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "min", "ERROR")
	rs2 := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "max", "ERROR")
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
	EndTime := LLARS_NowMS() + RandomSleepAmount
	LLARS_AdjustRandomSleepEstimate(RandomSleepAmount)

	GuiControl, 1:, ScriptBlue, Random Sleep
	Gui, 1: Font, s10 Bold cRed
	GuiControl, 1: Font, State3
	Gui, 1: Font, s10 Bold cBlack
	GuiControl, 1:, State3, % RandomSleepAmountToMinutesSeconds(RandomSleepAmount)
	LLARS_VisualShowStatus("blue")
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
	LLARS_VisualShowStatus("blue")
	Gosub, UpdateEstimatedTime

	return RandomSleepAmount
}

; Uses the actual randomized duration of the final sleep for this iteration.
LLARS_FinalSleep(time)
{
	global EstFinalSleepActive, EstFinalSleepEndTick
	global LLARS_RUNNING

	EstFinalSleepActive := true
	EstFinalSleepEndTick := LLARS_NowMS() + time
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

	EstLoopTime := LLARS_NowMS() - EstLoopStartTick
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
	LLARS_VisualShowStatus("green")
	EndTimeStamp := A_Hour ":" A_Min ":" A_Sec
	EndTime := LLARS_NowMS()
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
	chance := LLARS_ConfigReadFile(LLARS_CONFIG_FILE, "Random Sleep", "chance", "ERROR")
	MsgBox, 64, LLARS Run Info, %scriptname% has completed %runcount3% runs`n`nTotal time: %TotalTimeHours%h : %TotalTimeMinutes%m : %TotalTimeSecondsDisplay%s`nAverage loop: %AverageTimeMinutes%m : %AverageTimeSecondsDisplay%s`n`nStart time: %StartTimeStamp%`nEnd time: %EndTimeStamp%`n`nSet sleep chance: %chance%`%`nActual sleep chance: %percentage%`%`nTotal random sleeps: %sleepcount%`nTotal time slept: %TotalSleepHours%h : %TotalSleepMinutes%m : %TotalSleepSeconds%s
	LLARS_RUNNING := false
	LLARS_RunStartTick := 0
	LLARS_RunRuneScapeHwnd := 0
	EnableButton()
	SetLLARSHOTKEYS("On")
}

; Native InputBox is modal and does not offer an AlwaysOnTop option.
; Watch only this process's temporary input dialog while it is open;
; match its exact title, keep it above LLARS, and retain native full opacity.
LLARS_RunInputPrompt(ByRef result, title, instructions, width := 350, height := 155)
{
    global LLARS_RunPromptTitle, LLARS_RunPromptHwnd
    LLARS_RunPromptTitle := title
    LLARS_RunPromptHwnd := 0
    SetTimer, LLARS_RunPromptOnTop, 60
    InputBox, result, %title%, %instructions%,, %width%, %height%
    cancelled := ErrorLevel
    SetTimer, LLARS_RunPromptOnTop, Off
    LLARS_RunPromptTitle := ""
    LLARS_RunPromptHwnd := 0
    ErrorLevel := cancelled
    return !cancelled
}

LLARS_RunPromptOnTop:
    global LLARS_RunPromptTitle, LLARS_RunPromptHwnd
    if (LLARS_RunPromptTitle != "")
    {
        pid := DllCall("GetCurrentProcessId")
        dialog := WinExist(LLARS_RunPromptTitle . " ahk_class #32770 ahk_pid " . pid)
        if (dialog && dialog != LLARS_RunPromptHwnd)
        {
            WinSet, AlwaysOnTop, On, % "ahk_id " . dialog
            LLARS_RunPromptHwnd := dialog
        }
    }
return
