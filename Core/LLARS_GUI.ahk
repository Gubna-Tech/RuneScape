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

	IniRead, value, %LLARS_CONFIG_FILE%, Transparent, value
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	Gui, Font, s12 Bold
	Gui, Add, Text, x5 y5 w270 h25 Center, LLARS
	Gui, Font, s10 Bold
	Gui, Add, Text, x5 y29 w270 h18 Center cGray, %scriptname%
	Gui, Add, Text, x5 y49 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x10 y57 w125 h25 gStart , Start
	Gui, Add, Button, x145 y57 w125 h25 gInfo, Information
	Gui, Add, Button, x10 y86 w260 h25 gCombo, Color/Coordinate/Hotkey
	Gui, Add, Text, x5 y117 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y123 w165 h20, Run Count
	Gui, Font, s10
	Gui, Add, Text, x170 y123 w115 h20 Center vCounter
	GuiControl,,Counter, ** NOT SET **
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y147 w165 h20, Status
	Gui, Font, s10 Bold cBlue
	Gui, Add, Text, x175 y147 w95 h20 Center vState3
	Gui, Add, Text, x10 y147 w165 h20 vScriptBlue
	Gui, Font, s10 Bold cRed
	Gui, Add, Text, x175 y147 w95 h20 Center vState2
	Gui, Add, Text, x10 y147 w165 h20 vScriptRed
	GuiControl,,State2, ** OFF **
	Gui, Add, Text, x10 y147 w165 h20, %scriptname%
	Gui, Add, Text, x5 y171 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x55 y178 w170 h29 gExitb , Exit LLARS
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
		Menu, Tray, Icon, %LLARS_SCRIPT_DIR%\LLARS Logo.ico
	}

	WinSet, Transparent, %value%
	Gui, Show,w290 h215, LLARS

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

	LLARS_RUNNING := true
	SetLLARSHOTKEYS()
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	Gui, Font, s12 Bold
	Gui, Add, Text, x5 y5 w270 h25 Center, LLARS
	Gui, Font, s10 Bold
	Gui, Add, Text, x5 y29 w270 h18 Center cGray, %scriptname%
	Gui, Add, Text, x5 y49 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x10 y57 w125 h25 gStart, Start
	Gui, Add, Button, x145 y57 w125 h25 gInfo, Information
	Gui, Add, Button, x10 y86 w125 h25 gPauseb, Pause
	Gui, Add, Button, x145 y86 w125 h25 gResumeb, Resume
	Gui, Add, Text, x5 y114 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y120 w165 h20, Run Count
	Gui, Font, s10
	Gui, Add, Text, x175 y120 w95 h20 Center vCounter2
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y141 w165 h20, Total Run Count
	Gui, Font, s10
	Gui, Add, Text, x175 y141 w95 h20 Center vCounter
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y162 w165 h20, Est. Loop Remaining
	Gui, Font, s10
	Gui, Add, Text, x175 y162 w95 h20 Center vEstLoopRemaining
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y183 w165 h20, Est. Run Remaining
	Gui, Font, s10
	Gui, Add, Text, x175 y183 w95 h20 Center vEstRunRemaining
	Gui, Add, Text, x5 y205 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y211 w165 h20, Status
	Gui, Font, s10 Bold cGreen
	Gui, Add, Text, x175 y211 w95 h20 Center vState1
	Gui, Add, Text, x10 y211 w165 h20 vScriptGreen
	Gui, Font, s10 Bold cBlue
	Gui, Add, Text, x175 y211 w95 h20 Center vState3
	Gui, Add, Text, x10 y211 w165 h20 vScriptBlue
	Gui, Font, s10 Bold cRed
	Gui, Add, Text, x175 y211 w95 h20 Center vState2
	Gui, Add, Text, x10 y211 w165 h20 vScriptRed
	GuiControl,, State2, ** OFF **
	Gui, Font, s10 Bold
	Gui, Add, Button, x55 y239 w170 h29 gExitb, Exit LLARS
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
	Menu, Tray, Icon, %LLARS_SCRIPT_DIR%\LLARS Logo.ico
	}

	WinSet, Transparent, %value%
	Gui, Show, w290 h275, LLARS
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

	IniRead, value, %LLARS_CONFIG_FILE%, Transparent, value
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	Gui, Font, s12 Bold
	Gui, Add, Text, x5 y5 w270 h25 Center, LLARS
	Gui, Font, s10 Bold
	Gui, Add, Text, x5 y29 w270 h18 Center cGray, %scriptname%
	Gui, Add, Text, x5 y49 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Button, x10 y57 w125 h25 gStart, Start
	Gui, Add, Button, x145 y57 w125 h25 gInfo, Information
	Gui, Add, Button, x10 y86 w125 h25 gPauseb, Pause
	Gui, Add, Button, x145 y86 w125 h25 gResumeb, Resume
	Gui, Add, Text, x5 y114 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y120 w165 h20, Time Remaining
	Gui, Font, s10
	Gui, Add, Text, x175 y120 w95 h20 Center vTimerCount
	Gui, Add, Text, x5 y142 w270 h2 0x10
	Gui, Font, s10 Bold
	Gui, Add, Text, x10 y148 w165 h20, Status
	Gui, Font, s10 Bold cBlue
	Gui, Add, Text, x175 y148 w95 h20 Center vState3
	Gui, Add, Text, x10 y148 w165 h20 vScriptBlue
	Gui, Font, s10 Bold cRed
	Gui, Add, Text, x175 y148 w95 h20 Center vState2
	Gui, Add, Text, x10 y148 w165 h20 vScriptRed
	GuiControl,, State2, ** OFF **
	Gui, Font, s10 Bold
	Gui, Add, Button, x55 y176 w170 h29 gExitb, Exit LLARS
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
		Menu, Tray, Icon, %LLARS_SCRIPT_DIR%\LLARS Logo.ico
	}

	WinSet, Transparent, %value%
	Gui, Show, w290 h212, LLARS
	WinMove, LLARS,, X, Y
	if FileExist(LLARS_SCRIPT_DIR "\LLARS Logo.ico")
	{
		hIcon := DllCall("LoadImage", uint, 0, str, LLARS_SCRIPT_DIR "\LLARS Logo.ico"
			, uint, 1, int, 0, int, 0, uint, 0x10)
		SendMessage, 0x80, 0, hIcon
		SendMessage, 0x80, 1, hIcon
	}
}
