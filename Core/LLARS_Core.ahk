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
WM_LBUTTONDOWN() {
	If (A_Gui)
		PostMessage, 0xA1, 2
}

; Rechecks the LLARS window position whenever Windows reports a move.
WM_WINDOWPOSCHANGED() {
	CheckPOS()
}

; Keeps the LLARS GUI fully inside the visible desktop area.
CheckPOS()
{
	IfWinNotActive, LLARS
	return

	WinGetPos, GUIx, GUIy, GUIw, GUIh, LLARS
	xmin := GUIx
	xmax := GUIw + GUIx
	ymin := GUIy
	ymax := GUIh + GUIy
	xadj := A_ScreenWidth - GUIw
	yadj := A_ScreenHeight - GUIh
	X := GUIx
	Y := GUIy
	if (xmin < 0)
		X := 0
	if (ymin < 0)
		Y := 0
	if (xmax > A_ScreenWidth)
		X := xadj
	if (ymax > A_ScreenHeight)
		Y := yadj
	if (X != GUIx || Y != GUIy)
		WinMove, LLARS,, X, Y
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

; Reads the shared LLARS hotkeys and safely enables, disables, or remaps them.
; The Exit hotkey always remains available.
SetLLARSHOTKEYS(state := "On", startOnly := false)
{
	global LLARS_lhk1
	global LLARS_lhk2
	global LLARS_lhk3
	global LLARS_lhk4
	global LLARS_RUNNING
	global LLARS_CONTROLS_LOCKED

	IniRead, lhk1, %LLARS_CONFIG_FILE%, Start Hotkey, hotkey

	; Disable the previously configured Start hotkey if it changed.
	if (LLARS_lhk1 != "" && LLARS_lhk1 != lhk1)
		Hotkey, %LLARS_lhk1%, Start, Off

	; Save the current Start hotkey.
	LLARS_lhk1 := lhk1

	; Enable/disable the current Start hotkey.
	if (lhk1 != "")
	{
		if (state = "On" && !LLARS_RUNNING && !LLARS_CONTROLS_LOCKED)
			Hotkey, %lhk1%, Start, On
		else
			Hotkey, %lhk1%, Start, Off
	}

	; Only update the Start hotkey when requested.
	if (startOnly)
		return

	IniRead, lhk2, %LLARS_CONFIG_FILE%, Information Hotkey, hotkey
	IniRead, lhk3, %LLARS_CONFIG_FILE%, color/coordinate/hotkey Hotkey, hotkey
	IniRead, lhk4, %LLARS_CONFIG_FILE%, exit Hotkey, hotkey

	; Disable the previously configured Information/Pause hotkey if it changed.
	if (LLARS_lhk2 != "" && LLARS_lhk2 != lhk2)
	{
		Hotkey, %LLARS_lhk2%, Info, Off
		Hotkey, %LLARS_lhk2%, pauseb, Off
	}

	; Save the current Information/Pause hotkey.
	LLARS_lhk2 := lhk2
	if (lhk2 != "")
	{
		if (state = "On" && !LLARS_CONTROLS_LOCKED)
		{
			if (LLARS_RUNNING)
			{
				Hotkey, %lhk2%, Info, Off
				Hotkey, %lhk2%, pauseb, On
			}
			else
			{
				Hotkey, %lhk2%, pauseb, Off
				Hotkey, %lhk2%, Info, On
			}
		}
		else
		{
			Hotkey, %lhk2%, Info, Off
			Hotkey, %lhk2%, pauseb, Off
		}
	}

	; Disable the previously configured Combo/Resume hotkey if it changed.
	if (LLARS_lhk3 != "" && LLARS_lhk3 != lhk3)
	{
		Hotkey, %LLARS_lhk3%, Combo, Off
		Hotkey, %LLARS_lhk3%, resumeb, Off
	}

	; Save the current Combo/Resume hotkey.
	LLARS_lhk3 := lhk3
	if (lhk3 != "")
	{
		if (state = "On" && !LLARS_CONTROLS_LOCKED)
		{
			if (LLARS_RUNNING)
			{
				Hotkey, %lhk3%, Combo, Off
				Hotkey, %lhk3%, resumeb, On
			}
			else
			{
				Hotkey, %lhk3%, resumeb, Off
				Hotkey, %lhk3%, Combo, On
			}
		}
		else
		{
			Hotkey, %lhk3%, Combo, Off
			Hotkey, %lhk3%, resumeb, Off
		}
	}

	LLARS_EnableExitHotkey(lhk4)
}

; Keeps the Exit hotkey registered independently of the normal LLARS
; control state. A temporary missing/blank config read never disables the
; last known Exit hotkey.
LLARS_EnableExitHotkey(lhk4 := "")
{
	global LLARS_lhk4

	if (lhk4 = "")
		IniRead, lhk4, %LLARS_CONFIG_FILE%, exit Hotkey, hotkey

	if (lhk4 = "" || lhk4 = "ERROR")
	{
		if (LLARS_lhk4 != "")
			Hotkey, %LLARS_lhk4%, exitb, On
		return
	}

	; Disable the previously configured Exit hotkey only after a valid
	; replacement has been read.
	if (LLARS_lhk4 != "" && LLARS_lhk4 != lhk4)
		Hotkey, %LLARS_lhk4%, exitb, Off

	LLARS_lhk4 := lhk4
	Hotkey, %LLARS_lhk4%, exitb, On
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
}

; Disables only the Start control while the timed script is running.
DisableButton()
{
	Control, Disable,, start
	SetLLARSHOTKEYS("Off", true)
	LLARS_EnableExitHotkey()
}

; Re-enables the Start control after the timed run is finished.
EnableButton()
{
	Control, Enable,, start
	SetLLARSHOTKEYS("On", true)
	LLARS_EnableExitHotkey()
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
	global LLARS_RUNNING, LLARS_lhk1, LLARS_lhk2, LLARS_lhk3, LLARS_lhk4, LLARS_CONTROLS_LOCKED
	global EstimationRunCount
	global coordcount, frcount, LastClickTime, clickspot, scriptname

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
	LLARS_CONTROLS_LOCKED := false
	SetLLARSHOTKEYS("On")
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
	SetTimer, CheckLLARSConfig, 250
	scriptname := regexreplace(A_scriptname,"\..*","")
	LLARS_RUNNING := false
	EstimationRunCount := 1000
	LLARS_CreateMainGUI()
	OnMessage(0x0047, "WM_WINDOWPOSCHANGED")
	OnMessage(0x0201, "WM_LBUTTONDOWN")
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
	WinSet, ExStyle, ^0x80
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

	if (!LLARS_CheckGame())
		return false

	if (ConfigError())
		return false

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
	GuiControl,, ScriptBlue, %scriptname%
	GuiControl,, State3, Running
	DisableButton()
	startcheck := 1
	LLARS_ResetRunState()
	LLARS_RUNNING := true
	runcount3 := runcount
	StartTime := A_TickCount
	StartTimeStamp := A_Hour ":" A_Min ":" A_Sec
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
	Log("RUN START", "Starting " runcount3 " runs")
	return true
}

; Validates and starts a duration-based script using the user's run time.
LLARS_StartTimerRun()
{
	global scriptname, LLARS_RUNNING
	global timeToRunMinutes, timeToRunMS, endTime, startcheck

	if (!LLARS_CheckGame())
		return false

	if (ConfigError())
		return false

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
	LLARS_RUNNING := true
	LLARS_CreateTimerGUI()
	GuiControl,, ScriptBlue, %scriptname%
	GuiControl,, State3, Running
	GuiControl,, TimerCount, % LLARS_TimerRemainingText(endTime - A_TickCount)
	DisableButton()
	SetLLARSHOTKEYS()
	Log("TIMER", "Timer set to " timeToRunMinutes " minutes")
	return true
}

; Clears the shared running state and restores controls after a timed run.
LLARS_EndTimerRun()
{
	global LLARS_RUNNING

	LLARS_RUNNING := false
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
	global firstrun, prime, bobprime

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
	global scriptname

	EstFinalSleepActive := false
	EstFinalSleepEndTick := 0
	EstLoopStartTick := A_TickCount
	Log("LOOP START", "Iteration=" A_Index " of " runcount)
	IfWinNotActive, RuneScape
	{
		WinActivate, RuneScape
		Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
	}

	++count
	++count2
	GuiControl,, Counter, %count%
	GuiControl,, Counter2, %count2% / %runcount3%
	GuiControl,, ScriptBlue, %scriptname%
	GuiControl,, State3, Running
	DisableButton()
}

; Runs an ordinary configured sleep while the current-loop display remains
; predictive. LLARS_FinalSleep() performs the exact per-loop handoff.
LLARS_EstimatedSleep(time)
{
	; Ordinary configured sleep. The GUI remains on the predictive loop
	; estimate until the script explicitly reaches LLARS_FinalSleep().
	Sleep, %time%
}

; Uses the actual randomized duration of the final sleep for this iteration.
; From this point until the next loop, the GUI shows an exact countdown.
LLARS_FinalSleep(time)
{
	global EstFinalSleepActive, EstFinalSleepEndTick

	EstFinalSleepActive := true
	EstFinalSleepEndTick := A_TickCount + time
	Gosub, UpdateEstimatedTime
	Sleep, %time%
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
}

; Finalizes a completed RunCount session, restores controls, and performs
; the configured completion behavior.
LLARS_RunComplete()
{
	global scriptname, runcount3, sleepcount, totalSleepTime, StartTime, StartTimeStamp
	global LLARS_RUNNING
	global EndTimeStamp, EndTime
	global TotalTimeSeconds, AverageTimeSecondsTotal
	global TotalTimeHours, TotalTimeMinutes, TotalTimeSecondsDisplay
	global AverageTimeMinutes, AverageTimeSecondsDisplay, percentage
	global totalSleepTimeSeconds, TotalSleepHours, TotalSleepMinutes, TotalSleepSeconds
	global chance

	Logout()
	SetTimer, UpdateEstimatedTime, Off
	GuiControl,, EstLoopRemaining, 0h 0m 0s
	GuiControl,, EstRunRemaining, 0h 0m 0s
	GuiControl,, ScriptGreen, %scriptname%
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
	EnableButton()
	LLARS_RUNNING := false
	SetLLARSHOTKEYS()
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
		WinSet, ExStyle, ^0x80
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
		WinSet, ExStyle, ^0x80
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
	Loop, Parse, keys, `n, `r
	{
		line := Trim(A_LoopField)
		if (line = "")
			continue
		StringSplit, part, line, =
		key := Trim(part1)
		color := Trim(part2)
		if (key = "option" || key = "type")
			continue
		if RegExMatch(color, "i)^0x[0-9A-F]{6}$")
			return key
	}

	return section
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
Log(Event, Details := "")
{
	global LogCount
	global LLARS_SCRIPT_DIR

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

; ================================================================
; |     MOUSE     -     MOUSE     -     MOUSE     -     MOUSE    |
; ================================================================

; ================================================================
; |     LLARS MOUSE LIBRARY     -     LLARS MOUSE LIBRARY        |
; ================================================================
; Moves the mouse to a target using LLARS naturalized movement, then clicks.
NaturalClick(x, y, button := "left")
{
	MouseGetPos, startX, startY
	dx := x - startX
	dy := y - startY
	distance := Sqrt((dx * dx) + (dy * dy))
	if (distance <= 2)
	{
		Random, pause, 50, 120
		Sleep, %pause%
		if (button = "right")
			Click, Right
		else
			Click
		return
	}

	; Distance-based mouse speed.
	; Short movements are more deliberate.
	; Longer movements naturally become faster.
	if (distance < 75)
	{
		Random, speed, 1400, 2100
	}
	else if (distance < 200)
	{
		Random, speed, 1800, 2600
	}
	else if (distance < 400)
	{
		Random, speed, 2200, 3100
	}
	else if (distance < 700)
	{
		Random, speed, 2500, 3500
	}
	else if (distance < 1100)
	{
		Random, speed, 2700, 3800
	}
	else
	{
		Random, speed, 2900, 4100
	}

	duration := (distance / speed) * 1000
	if (duration < 180)
		duration := 180
	if (duration > 900)
		duration := 900
	steps := Round(distance / 6)
	if (steps < 15)
		steps := 15
	if (steps > 100)
		steps := 100
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
	Random, curveBase, -100, 100
	curveBase := curveBase * curveLimit / 100
	Random, curveVariation1, -25, 25
	Random, curveVariation2, -25, 25
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
	Random, cp1Percent, 25, 38
	Random, cp2Percent, 62, 75
	cp1X := startX + (dx * cp1Percent / 100)
	cp1Y := startY + (dy * cp1Percent / 100)
	cp2X := startX + (dx * cp2Percent / 100)
	cp2Y := startY + (dy * cp2Percent / 100)
	cp1X += perpX * curveAmount1
	cp1Y += perpY * curveAmount1
	cp2X += perpX * curveAmount2
	cp2Y += perpY * curveAmount2
	Random, seedX, 1, 100000
	Random, seedY, 1, 100000
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
	Loop, %steps%
	{
		t := A_Index / steps
		timingT := t * t * (3 - (2 * t))
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
		if (delay > 20)
			delay := 20
		Sleep, %delay%
	}

	MouseMove, %x%, %y%, 0
	Random, pause, 50, 120
	Sleep, %pause%
	if (button = "right")
		Click, Right
	else
		Click
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
