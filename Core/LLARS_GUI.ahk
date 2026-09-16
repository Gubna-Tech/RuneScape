; ================================================================
; |     LLARS GUI     -     LLARS GUI     -     LLARS GUI        |
; ================================================================

; ================================================================
; |     LLARS GUI CORE LIBRARY     -     LLARS GUI CORE          |
; ================================================================
; Creates the main LLARS control window.
LLARS_CreateMainGUI()
{
	global value, scriptname, LLARS_ROOT, LLARS_SCRIPT_DIR
	global Counter, State3, State2, ScriptBlue, ScriptRed
	global ConfigStatusHotkeys, ConfigStatusCoordinates, ConfigStatusColors
	global ConfigStatusHotkeysLabel, ConfigStatusCoordinatesLabel, ConfigStatusColorsLabel
	displayScriptName := LLARS_DisplayScriptName()

	IniRead, value, %LLARS_CONFIG_FILE%, Transparent, value
	Gui +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSMainGuiHwnd
	Gui, Font, s12 Bold
	Gui, Add, Text, x5 y5 w305 h25 Center, LLARS
	Gui, Font, s10 Bold
	Gui, Add, Text, x5 y29 w305 h18 Center cGray, %displayScriptName%
	Gui, Add, Text, x5 y49 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x10 y57 w145 h25 gStart , Start
	Gui, Add, Button, x160 y57 w145 h25 gInfo, Information
	Gui, Add, Button, x10 y86 w295 h25 gCombo, Configuration
	Gui, Add, Button, x10 y115 w295 h25 gResetConfig, Reset Config
	Gui, Add, Text, x5 y146 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y152 w165 h20, Run Count
	Gui, Font, s10 cRed
	Gui, Add, Text, x180 y152 w125 h20 Center vCounter
	GuiControl,,Counter, ** NOT SET **
	Gui, Font, s10 Bold cBlack
	Gui, Add, Text, x10 y176 w165 h20, Status
	Gui, Font, s10 Bold cBlue
	Gui, Add, Text, x180 y176 w125 h20 Center vState3
	Gui, Add, Text, x10 y176 w165 h20 cBlack vScriptBlue
	Gui, Font, s10 Bold cRed
	Gui, Add, Text, x180 y176 w125 h20 Center vState2
	Gui, Add, Text, x10 y176 w165 h20 cBlack vScriptRed
	GuiControl,,State2, ** OFF **
	Gui, Font, s10 Bold cBlack
	Gui, Add, Text, x10 y176 w165 h20, %displayScriptName%
	Gui, Add, Text, x5 y200 w305 h2 0x10
	Gui, Font, s10 Bold cBlack
	Gui, Add, Text, x10 y207 w295 h20 Center, Configuration Status
	Gui, Font, s10 Bold cBlack
	Gui, Add, Text, x15 y230 w140 h18 vConfigStatusHotkeysLabel, Hotkeys
	Gui, Add, Text, x160 y230 w145 h18 Center vConfigStatusHotkeys, Checking...
	Gui, Add, Text, x15 y250 w140 h18 vConfigStatusCoordinatesLabel, Coordinates
	Gui, Add, Text, x160 y250 w145 h18 Center vConfigStatusCoordinates, Checking...
	Gui, Add, Text, x15 y270 w140 h18 vConfigStatusColorsLabel, Colors
	Gui, Add, Text, x160 y270 w145 h18 Center vConfigStatusColors, Checking...
	Gui, Add, Text, x5 y293 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x73 y301 w170 h29 gExitb , Exit LLARS
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
		Menu, Tray, Icon, %LLARS_SCRIPT_DIR%\LLARS Logo.ico
	}

	WinSet, Transparent, %value%, ahk_id %LLARSMainGuiHwnd%
	LLARS_UpdateConfigStatus()
	Gui, Show,w315 h337, LLARS

	; Restores the main LLARS GUI to its previously saved screen position.
	IniRead, x, %LLARS_CONFIG_FILE%, GUI POS, guix
	IniRead, y, %LLARS_CONFIG_FILE%, GUI POS, guiy
	WinMove, LLARS,, %X%, %y%

	; Loads the custom LLARS icon into the main GUI when available.
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
		hIcon := DllCall("LoadImage", uint, 0, str, LLARS_SCRIPT_DIR "\LLARS Logo.ico"
	   	, uint, 1, int, 0, int, 0, uint, 0x10)
		SendMessage, 0x80, 0, hIcon
		SendMessage, 0x80, 1, hIcon
	}
}

; ================================================================
; |     RUN COUNT GUI     -     RUN COUNT GUI                    |
; ================================================================

; Creates the LLARS running window for scripts controlled by a run count.
LLARS_CreateRunCountGUI()
{
	global scriptname, value, X, Y, frcount, count, LLARS_RUNNING, LLARS_ROOT, LLARS_SCRIPT_DIR
	global Counter, Counter2, EstLoopRemaining, EstRunRemaining, State1, State3, State2, ScriptGreen, ScriptBlue, ScriptRed
	displayScriptName := LLARS_DisplayScriptName()

	LLARS_RUNNING := true
	SetLLARSHOTKEYS()
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSMainGuiHwnd
	Gui, Font, s12 Bold
	Gui, Add, Text, x5 y5 w305 h25 Center, LLARS
	Gui, Font, s10 Bold
	Gui, Add, Text, x5 y29 w305 h18 Center cGray, %displayScriptName%
	Gui, Add, Text, x5 y49 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x10 y57 w145 h25 gStart, Start
	Gui, Add, Button, x160 y57 w145 h25 gInfo, Information
	Gui, Add, Button, x10 y86 w145 h25 gPauseb, Pause
	Gui, Add, Button, x160 y86 w145 h25 gResumeb, Resume
	Gui, Add, Text, x5 y114 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y120 w165 h20, Run Count
	Gui, Font, s10
	Gui, Add, Text, x180 y120 w125 h20 Center vCounter2
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y141 w165 h20, Total Run Count
	Gui, Font, s10
	Gui, Add, Text, x180 y141 w125 h20 Center vCounter
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y162 w165 h20, Est. Loop Remaining
	Gui, Font, s10
	Gui, Add, Text, x180 y162 w125 h20 Center vEstLoopRemaining
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y183 w165 h20, Est. Run Remaining
	Gui, Font, s10
	Gui, Add, Text, x180 y183 w125 h20 Center vEstRunRemaining
	Gui, Add, Text, x5 y205 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y211 w165 h20, Status
	Gui, Font, s10 Bold cGreen
	Gui, Add, Text, x180 y211 w125 h20 Center vState1
	Gui, Add, Text, x10 y211 w165 h20 cBlack vScriptGreen
	Gui, Font, s10 Bold cBlue
	Gui, Add, Text, x180 y211 w125 h20 Center vState3
	Gui, Add, Text, x10 y211 w165 h20 cBlack vScriptBlue
	Gui, Font, s10 Bold cRed
	Gui, Add, Text, x180 y211 w125 h20 Center vState2
	Gui, Add, Text, x10 y211 w165 h20 cBlack vScriptRed
	GuiControl,, State2, ** OFF **
	Gui, Font, s10 Bold
	Gui, Add, Button, x73 y239 w170 h29 gExitb, Exit LLARS
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
	Menu, Tray, Icon, %LLARS_SCRIPT_DIR%\LLARS Logo.ico
	}

	WinSet, Transparent, %value%, ahk_id %LLARSMainGuiHwnd%
	Gui, Show, w315 h275, LLARS
	WinMove, LLARS,, X, Y
	count = 0
	++frcount
}

; ================================================================
; |     TIMER GUI     -     TIMER GUI     -     TIMER GUI         |
; ================================================================

; Creates the LLARS control window used by duration-based scripts.
LLARS_CreateTimerGUI()
{
	global scriptname, value, X, Y, LLARS_ROOT, LLARS_SCRIPT_DIR
	global TimerCount, State3, State2, ScriptBlue, ScriptRed
	displayScriptName := LLARS_DisplayScriptName()

	IniRead, value, %LLARS_CONFIG_FILE%, Transparent, value
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSMainGuiHwnd
	Gui, Font, s12 Bold
	Gui, Add, Text, x5 y5 w305 h25 Center, LLARS
	Gui, Font, s10 Bold
	Gui, Add, Text, x5 y29 w305 h18 Center cGray, %displayScriptName%
	Gui, Add, Text, x5 y49 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x10 y57 w145 h25 gStart, Start
	Gui, Add, Button, x160 y57 w145 h25 gInfo, Information
	Gui, Add, Button, x10 y86 w145 h25 gPauseb, Pause
	Gui, Add, Button, x160 y86 w145 h25 gResumeb, Resume
	Gui, Add, Text, x5 y114 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y120 w165 h20, Time Remaining
	Gui, Font, s10
	Gui, Add, Text, x180 y120 w125 h20 Center vTimerCount
	Gui, Add, Text, x5 y142 w305 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y148 w165 h20, Status
	Gui, Font, s10 Bold cBlue
	Gui, Add, Text, x180 y148 w125 h20 Center vState3
	Gui, Add, Text, x10 y148 w165 h20 cBlack vScriptBlue
	Gui, Font, s10 Bold cRed
	Gui, Add, Text, x180 y148 w125 h20 Center vState2
	Gui, Add, Text, x10 y148 w165 h20 cBlack vScriptRed
	GuiControl,, State2, ** OFF **
	Gui, Font, s10 Bold
	Gui, Add, Button, x73 y176 w170 h29 gExitb, Exit LLARS
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
		Menu, Tray, Icon, %LLARS_SCRIPT_DIR%\LLARS Logo.ico
	}

	WinSet, Transparent, %value%, ahk_id %LLARSMainGuiHwnd%
	Gui, Show, w315 h212, LLARS
	WinMove, LLARS,, X, Y
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
		hIcon := DllCall("LoadImage", uint, 0, str, LLARS_SCRIPT_DIR "\LLARS Logo.ico"
			, uint, 1, int, 0, int, 0, uint, 0x10)
		SendMessage, 0x80, 0, hIcon
		SendMessage, 0x80, 1, hIcon
	}
}
