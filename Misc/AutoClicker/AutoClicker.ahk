#SingleInstance Force
#Persistent
SetBatchLines, -1

DetectHiddenWindows, On
closeotherllars()

IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
IniRead, value, LLARS Config.ini, Transparent, value

settimer, configcheck, 250
settimer, guicheck

scriptname := regexreplace(A_scriptname,"\..*","")

Hotkey %lhk1%, Start
Hotkey %lhk2%, coordb
Hotkey %lhk3%, Configb
Hotkey %lhk4%, exitb

Gui +LastFound +OwnDialogs +AlwaysOnTop
Gui, Font, s11
Gui, font, bold
Gui, Add, Button, x15 y5 w190 h25 gStart , Start %scriptname%
Gui, Add, Button, x15 y35 w90 h25 gCoordb , Coordinates
Gui, Add, Button, x115 y35 w90 h25 gConfigb , Config File
Gui, Add, Button, x35 y115 w150 h25 gExitb , Exit LLARS
Gui, Font, cBlue
Gui, Add, Text, x135 y65 w70 h25 vState3
Gui, Add, Text, x8 y65 w125 h25 vScriptBlue
Gui, Add, Text, x8 y90 w100 h25 vTimerLabel
Gui, Add, Text, x135 y90 w70 h25 vTimerCount
GuiControl,,TimerLabel, Remaining:
GuiControl,,TimerCount, ** OFF **
Gui, Font, cRed
Gui, Add, Text, x135 y65 w70 h25 vState2
Gui, Add, Text, x8 y65 w125 h25 vScriptRed
GuiControl,,State2, ** OFF **
Gui, Add, Text, x8 y65 w125 h25, %scriptname%
Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
WinSet, Transparent, %value%
Gui, Show,w220 h150, LLARS

IniRead, x, LLARS Config.ini, GUI POS, guix
IniRead, y, LLARS Config.ini, GUI POS, guiy
WinMove A, ,%X%, %y%

hIcon := DllCall("LoadImage", uint, 0, str, "LLARS Logo.ico"
   	, uint, 1, int, 0, int, 0, uint, 0x10)
SendMessage, 0x80, 0, hIcon
SendMessage, 0x80, 1, hIcon

coordcount = 0
frcount = 0

OnMessage(0x0201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN() {
	If (A_Gui)
		PostMessage, 0xA1, 2
}
return

CheckPOS(){
	WinGetPos, GUIx, GUIy, GUIw, GUIh, LLARS
	xmin := GUIx
	xmax :=GUIw + GUIx
	ymin :=GUIy
	ymax :=GUIh + GUIy
	xadj :=A_ScreenWidth-GUIw
	yadj :=A_ScreenHeight-GUIh
	WinGetPos, X, Y,,, LLARS	
 	
	if (xmin<0)
	{
		WinMove, LLARS,,0
	}
	if (ymin<0)
	{
		WinMove, LLARS,,,0
	}
	if (xmax>A_ScreenWidth)
	{
		WinMove, LLARS,,xadj	
	}
	if (ymax>A_ScreenHeight)
	{
		WinMove, LLARS,,,yadj
	}
}

guicheck:
checkpos()
return

CloseOtherLLARS()
{
	WinGet, hWndList, List, LLARS
	
	Loop, %hWndList%
	{
		hWnd := hWndList%A_Index%
		WinClose, % "ahk_id " hWnd
	}
}

CoordB:
If (coordcount = 0)
{
	++coordcount
	CoordMode, Mouse, Screen
	MouseGetPos,X,Y
	settimer, tooltipcoord1, 25	
	return
}
else if (coordcount = 1)
{	
	++coordcount
	CoordMode, Mouse, Screen	
	MouseGetPos,X2,Y2
	IniWrite,----------`nxmin=%x%`nxmax=%x2%`nymin=%y%`nymax=%y2%,Coordinates.ini, Coordinates [%A_Hour%:%A_Min%:%A_Sec%] - %A_MM%/%A_DD%
	settimer, tooltipcoord1, OFF
	settimer, tooltipcoord2, 100
	clipboard =
(
xmin=%x%
xmax=%x2%
ymin=%y%
ymax=%y2%
)
	ClipWait
	clipboard := clipboard
	return
}
else if (coordcount = 2)
{
	settimer, tooltipcoord2, off
	ToolTip
	coordcount = 0
	return
}
Return

DisableButton(disable := true) {
	Control, Disable,, start
	
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	Hotkey, %lhk1%, off
}

EnableButton(enable := true) {
	Control, Enable,, start
	
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	Hotkey, %lhk1%, On
}

tooltipcoord1:
mousegetpos xn, yn
ToolTip,x=%X% y=%Y%, (xn+7), (yn+7),1
return

tooltipcoord2:
mousegetpos xn, yn
ToolTip, xmin=%x%`nxmax=%x2%`nymin=%y%`nymax=%y2%`n`nCoordinates are stored in clipboard and`n%A_ScriptDir%\Coordinates.ini`n`nPress F10 to clear this message, (xn+7), (yn+7),1
return

ConfigB:
Run %A_ScriptDir%\Config.ini
Return

ResumeB:
GuiControl,,State3, Running
GuiControl,,ScriptBlue, %scriptname%
Pause
Return

PauseB:
GuiControl,,State2, Paused
GuiControl,,ScriptRed, %scriptname%
Pause
Return

Configcheck:
{
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
}
return

Countdown:
remainingTimeMS := endTime - A_TickCount
remainingTimeMinutes := Floor(remainingTimeMS / 60000)
remainingTimeSeconds := Mod(Floor(remainingTimeMS / 1000), 60)

GuiControl,, TimerCount, %remainingTimeMinutes%m %remainingTimeSeconds%s
DisableButton()

if (remainingTimeMS <= 0 and startcheck=1)
{
	SetTimer, Countdown, off
	SetTimer, RandomClick, Off
	GuiControl,, TimerCount, Done
	GuiControl,,State3, Done
	EnableButton()
	Logout()
	Goto EndMsg
}
return

ExitB:
guiclose:
exitapp

Start:
If (frcount = 0)
{
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	IniRead, value, LLARS Config.ini, Transparent, value
	
	Hotkey %lhk1%, Start
	Hotkey %lhk2%, pauseb
	Hotkey %lhk3%, resumeb
	Hotkey %lhk4%, exitb
	
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	Gui, Font, s11
	Gui, font, bold
	Gui, Add, Button, x15 y5 w190 h25 gStart , Start %scriptname%
	Gui, Add, Button, x15 y35 w90 h25 gCoordb , Coordinates
	Gui, Add, Button, x115 y35 w90 h25 gConfigb , Config File
	Gui, Add, Button, x35 y115 w150 h25 gExitb , Exit LLARS
	Gui, Font, cBlue
	Gui, Add, Text, x135 y65 w70 h25 vState3
	Gui, Add, Text, x8 y65 w125 h25 vScriptBlue
	Gui, Add, Text, x8 y90 w100 h25 vTimerLabel
	Gui, Add, Text, x135 y90 w70 h25 vTimerCount
	GuiControl,,TimerLabel, Remaining:
	GuiControl,,TimerCount, ** OFF **
	Gui, Font, cRed
	Gui, Add, Text, x135 y65 w70 h25 vState2
	Gui, Add, Text, x8 y65 w125 h25 vScriptRed
	GuiControl,,State2, ** OFF **
	Gui, Add, Text, x8 y65 w125 h25, %scriptname%
	Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
	WinSet, Transparent, %value%
	Gui, Show,w220 h150, LLARS
	WinMove, LLARS,, X, Y,
}

else
	
sleep 250

InputBox, timeToRunMinutes, Set Timer, Enter the time duration in minutes`n(example: 1 for 1 minute):,,250,150
timeToRunMS := timeToRunMinutes * 60 * 1000

endTime := A_TickCount + timeToRunMS

if (timeToRunMinutes = "" or timeToRunMinutes = 0)
{
	MsgBox, 48, Invalid Input, Please enter a valid number greater than 0.
	return
}

SetTimer, Countdown, 1000

sleep 250

GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running
DisableButton()
startcheck=1

winactivate, RuneScape

IniRead, x1, Config.ini, Click, xmin
IniRead, x2, Config.ini, Click, xmax
IniRead, y1, Config.ini, Click, ymin
IniRead, y2, Config.ini, Click, ymax
Random, x, %x1%, %x2%
Random, y, %y1%, %y2%
Click, %x%, %y%

IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max
Random, SleepClick, %sa1%, %sa2%
SetTimer, RandomClick, %SleepClick%

	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated AutoClicker, (xm+15), (ym+15),1
		sleep 25
}
tooltip	

return

RandomClick:
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, x1, Config.ini, Click, xmin
	IniRead, x2, Config.ini, Click, xmax
	IniRead, y1, Config.ini, Click, ymin
	IniRead, y2, Config.ini, Click, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	Click, %x%, %y%
	
	IniRead, sa1, Config.ini, Timer, min
	IniRead, sa2, Config.ini, Timer, max
	Random, SleepClick, %sa1%, %sa2%
	SetTimer, RandomClick, %SleepClick%
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated AutoClicker, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Logout(){
	IniRead, option, LLARS Config.ini, Logout, option
	if option=true
	{
		send {esc}	
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%	
		
		CoordMode, Mouse, Screen
		IniRead, x1, LLARS Config.ini, Logout, xmin
		IniRead, x2, LLARS Config.ini, Logout, xmax
		IniRead, y1, LLARS Config.ini, Logout, ymin
		IniRead, y2, LLARS Config.ini, Logout, ymax
		if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, %scriptname%		
			GuiControl,,State2, ERROR
			MsgBox, 48, Config Error, Please enter valid coordinates in the config for Logout.
			return
		}
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%
	}
}

EndMsg:
hours := timeToRunMinutes // 60
minutes := Mod(timeToRunMinutes, 60)
SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nTotal time: %hours%h %minutes%m
return