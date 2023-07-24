#SingleInstance Force
#Persistent
SetBatchLines, -1

DetectHiddenWindows, On
closeotherllars()

IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit

settimer, configcheck, 250

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
Gui, Add, Button, x35 y90 w150 h25 gExitb , Exit LLARS
Gui, Font, cBlue
Gui, Add, Text, x135 y65 w70 h25 vState3
Gui, Add, Text, x8 y65 w125 h25 vScriptBlue
Gui, Font, cRed
Gui, Add, Text, x135 y65 w70 h25 vState2
Gui, Add, Text, x8 y65 w125 h25 vScriptRed
GuiControl,,State2, ** OFF **
Gui, Add, Text, x8 y65 w125 h25, %scriptname%
Gui, Show,w220 h120, LLARS
Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico

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
	Gui, Add, Button, x15 y35 w90 h25 gPauseb , Pause
	Gui, Add, Button, x115 y35 w90 h25 gResumeb , Resume
	Gui, Add, Button, x35 y90 w150 h25 gExitb , Exit LLARS
	Gui, Font, cBlue
	Gui, Add, Text, x135 y65 w70 h25 vState3
	Gui, Add, Text, x8 y65 w125 h25 vScriptBlue
	Gui, Font, cRed
	Gui, Add, Text, x135 y65 w70 h25 vState2
	Gui, Add, Text, x8 y65 w125 h25 vScriptRed
	GuiControl,,State2, ** OFF **
	Gui, Add, Text, x8 y65 w125 h25, %scriptname%
	Gui, Show,w220 h120, LLARS
	WinMove, LLARS,, X, Y,
}

else
	
sleep 250

GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running

IniRead, option,Config.ini, Agro, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Agro, min
	IniRead, sa2, Config.ini, Agro, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Agro, %sleepamount%
	
	IniRead, hk, Config.ini, Agro, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Agro, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}

IniRead, option,Config.ini, Prayer, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Prayer, min
	IniRead, sa2, Config.ini, Prayer, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Prayer, %sleepamount%
	
	IniRead, hk, Config.ini, Prayer, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Prayer, (xm+15), (ym+15),1
		sleep 25		
	}
	tooltip	
}

IniRead, option,Config.ini, Strength, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Strength, min
	IniRead, sa2, Config.ini, Strength, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Strength, %sleepamount%
	
	IniRead, hk, Config.ini, Strength, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Strength, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}

IniRead, option,Config.ini, Attack, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Attack, min
	IniRead, sa2, Config.ini, Attack, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Attack, %sleepamount%
	
	IniRead, hk, Config.ini, Attack, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Attack, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Magic, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Magic, min
	IniRead, sa2, Config.ini, Magic, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Magic, %sleepamount%
	
	IniRead, hk, Config.ini, Magic, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Magic, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}

IniRead, option,Config.ini, Ranged, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Ranged, min
	IniRead, sa2, Config.ini, Ranged, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Ranged, %sleepamount%
	
	IniRead, hk, Config.ini, Ranged, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Range, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}

IniRead, option,Config.ini, Overload, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Overload, min
	IniRead, sa2, Config.ini, Overload, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Overload, %sleepamount%
	
	IniRead, hk, Config.ini, Overload, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Overload, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}

IniRead, option,Config.ini, Warmaster, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Warmaster, min
	IniRead, sa2, Config.ini, Warmaster, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Warmaster, %sleepamount%
	
	IniRead, hk, Config.ini, Warmaster, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Warmaster, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Antifire, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Antifire, min
	IniRead, sa2, Config.ini, Antifire, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Antifire, %sleepamount%
	
	IniRead, hk, Config.ini, Antifire, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Antifire, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Antipoison, option
if option=true
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Antipoison, min
	IniRead, sa2, Config.ini, Antipoison, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Antipoison, %sleepamount%
	
	IniRead, hk, Config.ini, Antipoison, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Antipoison, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

return

Agro:
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Agro, min
	IniRead, sa2, Config.ini, Agro, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Agro, %sleepamount%	
	
	IniRead, hk, Config.ini, Agro, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Agro, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Strength:
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Strength, min
	IniRead, sa2, Config.ini, Strength, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Strength, %sleepamount%	
	
	IniRead, hk, Config.ini, Strength, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Strength, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Attack:
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Attack, min
	IniRead, sa2, Config.ini, Attack, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Attack, %sleepamount%	
	
	IniRead, hk, Config.ini, Attack, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Attack, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Magic:
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Magic, min
	IniRead, sa2, Config.ini, Magic, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Magic, %sleepamount%	
	
	IniRead, hk, Config.ini, Magic, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Magic, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Ranged:
{
	winactivate, RuneScape	
	
	IniRead, sa1, Config.ini, Ranged, min
	IniRead, sa2, Config.ini, Ranged, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Ranged, %sleepamount%	
	
	IniRead, hk, Config.ini, Ranged, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Range, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Overload:
{
	winactivate, RuneScape	

	IniRead, sa1, Config.ini, Overload, min
	IniRead, sa2, Config.ini, Overload, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Overload, %sleepamount%	
	
	IniRead, hk, Config.ini, Overload, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Overload, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Warmaster:
{
	winactivate, RuneScape
	
	IniRead, sa1, Config.ini, Warmaster, min
	IniRead, sa2, Config.ini, Warmaster, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Warmaster, %sleepamount%	
	
	IniRead, hk, Config.ini, Warmaster, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Warmaster, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

Antifire:
{
	winactivate, RuneScape
	
	IniRead, sa1, Config.ini, Antifire, min
	IniRead, sa2, Config.ini, Antifire, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Antifire, %sleepamount%	
	
	IniRead, hk, Config.ini, Antifire, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Antifire, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

Antipoison:
{
	winactivate, RuneScape
	
	IniRead, sa1, Config.ini, Antipoison, min
	IniRead, sa2, Config.ini, Antipoison, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Antipoison, %sleepamount%	
	
	IniRead, hk, Config.ini, Antipoison, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Antipoison, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

Prayer:
{
	winactivate, RuneScape
	
	IniRead, sa1, Config.ini, Prayer, min
	IniRead, sa2, Config.ini, Prayer, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Prayer, %sleepamount%	
	
	IniRead, hk, Config.ini, Prayer, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Prayer, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return