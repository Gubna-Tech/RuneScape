#SingleInstance Force
#Persistent
SetBatchLines, -1

DetectHiddenWindows, On
closeotherllars()

if !FileExist("Config.ini")
{
	Gui Error: +AlwaysOnTop +OwnDialogs
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
	Gui Error: -caption
	Gui Error: Show, center w230, Config Error
	return
}

if !FileExist("LLARS Config.ini")
{
	Gui Error: +AlwaysOnTop +OwnDialogs
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
	Gui Error: -caption
	Gui Error: Show, center w230, Config Error
	return
}

IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
IniRead, value, LLARS Config.ini, Transparent, value

settimer, configcheck, 250

scriptname := regexreplace(A_scriptname,"\..*","")

Hotkey %lhk1%, Start
Hotkey %lhk2%, coordb
Hotkey %lhk3%, Configb
Hotkey %lhk4%, exitb

Gui +LastFound +OwnDialogs +AlwaysOnTop
Gui, Font, s11
Gui, font, bold
Gui, Add, Button, x5 y5 w100 h25 gStart , Start
Gui, Add, Button, x115 y5 w100 h25 gInfo, Information
Gui, Add, Button, x5 y35 w100 h25 gCoordb , Coordinates
Gui, Add, Button, x115 y35 w100 h25 gConfigb , Timer
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
if FileExist("LLARS Logo.ico")
{
	Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
}
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

OnMessage(0x0047, "WM_WINDOWPOSCHANGED")
OnMessage(0x0201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN() {
	If (A_Gui)
		PostMessage, 0xA1, 2
}
return

WM_WINDOWPOSCHANGED() {
	If (A_Gui) {
		checkpos()
	}
}
return

ConfigError(){
	IniRead, x1, Config.ini, Click, xmin
	IniRead, x2, Config.ini, Click, xmax
	IniRead, y1, Config.ini, Click, ymin
	IniRead, y2, Config.ini, Click, ymax
	if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
	{
		Run %A_ScriptDir%\Config.ini
		GuiControl,,ScriptRed, CONFIG		
		GuiControl,,State2, ERROR
		MsgBox, 4112, Config Error, Please enter valid coordinates for [Click] in the config.
		reload
	}
	
	IniRead, option, LLARS Config.ini, Logout, option
	if option=true
	{
		IniRead, x1, LLARS Config.ini, Logout, xmin
		IniRead, x2, LLARS Config.ini, Logout, xmax
		IniRead, y1, LLARS Config.ini, Logout, ymin
		IniRead, y2, LLARS Config.ini, Logout, ymax
		if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
		{
			Run %A_ScriptDir%\LLARS Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter valid coordinates in the LLARS Config for Logout.
			reload
		}
	}
}

CheckPOS() {
	allowedWindows := "|LLARS|hotkeys|coordinates|"
	
	WinGetTitle, activeWindowTitle, A
	
	if (InStr(allowedWindows, "|" activeWindowTitle "|") <= 0) {
		return
	}
	
	WinGetPos, GUIx, GUIy, GUIw, GUIh, A
	xmin := GUIx
	xmax := GUIw + GUIx
	ymin := GUIy
	ymax := GUIh + GUIy
	xadj := A_ScreenWidth - GUIw
	yadj := A_ScreenHeight - GUIh
	WinGetPos, X, Y,,, A    
	
	if (xmin < 0) {
		WinMove, A,, 0
	}
	if (ymin < 0) {
		WinMove, A,,, 0
	}
	if (xmax > A_ScreenWidth) {
		WinMove, A,, xadj    
	}
	if (ymax > A_ScreenHeight) {
		WinMove, A,,, yadj
	}
}

CloseOtherLLARS()
{
	WinGet, hWndList, List, LLARS
	
	Loop, %hWndList%
	{
		hWnd := hWndList%A_Index%
		WinClose, % "ahk_id " hWnd
	}
}

DisableHotkey(disable := true) {
	Control, Disable,, start
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	Hotkey, %lhk1%, off	
	Hotkey, %lhk2%, off
	Hotkey, %lhk3%, off
	Hotkey, %lhk4%, off
}

EnableHotkey(enable := true) {
	Control, Enable,, start
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	Hotkey, %lhk1%, on	
	Hotkey, %lhk2%, on
	Hotkey, %lhk3%, on
	Hotkey, %lhk4%, on
	
}

CoordB:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy

Gui 1: Hide
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop
Gui 2: Font, s11 Bold
DisableHotkey()

IniRead, allContents, Config.ini
excludedSections := "|timer|"

sectionList := " ***** Make a Selection ***** "

Loop, Parse, allContents, `n
{
    currentSection := A_LoopField

    if !InStr(excludedSections, "|" currentSection "|")
        sectionList .= "|" currentSection
}

Gui, 2: Add, DropDownList, w230 vSectionList Choose1 gDropDownChanged, % sectionList
Gui, 2: Add, Button, x52 w150 gClose, Close Coordinates

Gui, 2: Show, w250 h45 Center, Coordinates
Gui 2: -Caption
Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
WinSet, Transparent, %value%
return

Close:
Gui 2: Destroy
Gui 1: Show
EnableHotkey()
return

DropDownChanged:
GuiControlGet, selectedSection,, SectionList

if (selectedSection != " ***** Make a Selection ***** ")
	GoSub, ButtonClicked

return

ButtonClicked:
Gui, 2: Hide

WinActivate, RuneScape

ClickCount := 0
xmin := ""
ymin := ""
xmax := ""
ymax := ""

ButtonText := selectedSection

SetTimer, CheckClicks, 10

Gui 11u: +AlwaysOnTop +OwnDialogs +Disabled
Gui 11u: Color, Red
Gui 11u: Font, cRed
Gui 11u: Font, s16 bold
Gui 11u: Add, Text, valertlabel center,----Right-click the item's top-left corner for its coordinates`n----
Gui 11u: -caption
Gui 11u: Show, NoActivate xcenter y0,  BottomGUI

Gui 11: +AlwaysOnTop +OwnDialogs +Disabled
Gui 11: Font, s16 bold
Gui 11: Add, Text, vTone center,Right-click the item's top-left corner for its coordinates
Gui 11: -caption
Gui 11: Show, NoActivate xcenter y9999, TopGUI

wingetpos,,,,bottomH, BottomGUI
wingetpos,,,,topH, TopGUI

topPOS := (bottomH - topH) / 2

Gui, TopGUI: +LabelTopGUI
WinMove, TopGUI,, , %topPOS%
return

CheckClicks:
if GetKeyState("RButton", "P")
{	
	MouseGetPos, MouseX, MouseY
	ClickCount++
	if (ClickCount = 1)
	{
		Gui 11: destroy
		Gui 11u: destroy
		
		Gui 12u: +AlwaysOnTop +OwnDialogs +Disabled
		Gui 12u: Color, Red
		Gui 12u: Font, cRed
		Gui 12u: Font, s16 bold
		Gui 12u: Add, Text, valertlabel center,----Right-click the item's bottom-right corner for its coordinates`n----
		Gui 12u: -caption
		Gui 12u: Show, NoActivate xcenter y0, BottomGUI
		
		Gui 12: +AlwaysOnTop +OwnDialogs +Disabled
		Gui 12: Font, s16 bold
		Gui 12: Add, Text, vTtwo center,Right-click the item's bottom-right corner for its coordinates
		Gui 12: -caption
		Gui 12: Show, NoActivate xcenter y9999, TopGUI
		
		Gui, TopGUI: +LabelTopGUI
		WinMove, TopGUI,, , %topPOS%
		
		xmin := MouseX
		ymin := MouseY
	}
	else if (ClickCount = 2)
	{
		Gui 12: destroy
		Gui 12u: destroy
		
		Gui 13u: +AlwaysOnTop +OwnDialogs +Disabled
		Gui 13u: Color, Green
		Gui 13u: Font, cGreen
		Gui 13u: Font, s16 bold
		Gui 13u: Add, Text, valertlabel center,----Coordinates have been updated in the Config.ini file`n----
		Gui 13u: -caption
		Gui 13u: Show, NoActivate xcenter y0, BottomGUI
		
		Gui 13: +AlwaysOnTop +OwnDialogs +Disabled
		Gui 13: Color, White
		Gui 13: Font, cGreen
		Gui 13: Font, s16 bold
		Gui 13: Add, Text, vTthree center,Coordinates have been updated in the Config.ini file
		Gui 13: -caption
		Gui 13: Show, NoActivate xcenter y9999, TopGUI
		
		Gui, TopGUI: +LabelTopGUI
		WinMove, TopGUI,, , %topPOS%
		
		xmax := MouseX
		ymax := MouseY
		SetTimer, CheckClicks, Off
		
		IniWrite, %xmin%, Config.ini, %ButtonText%, xmin
		IniWrite, %xmax%, Config.ini, %ButtonText%, xmax
		IniWrite, %ymin%, Config.ini, %ButtonText%, ymin
		IniWrite, %ymax%, Config.ini, %ButtonText%, ymax
		
		Sleep, 1500
		
		Gui 13: destroy
		Gui 13u: Destroy
		Gui, 2: Destroy
		Gui, 1: Show
		
		EnableHotkey()	
	}
	
	Sleep, 250
}
return

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

~Esc::
IfWinActive, Coordinates
{EnableHotkey()
GoSub, close
}
IfWinActive, Timer
{EnableHotkey()
Gui 5: destroy
Gui 1: show
}
IfWinActive, Information
{EnableHotkey()	
GoSub, closeinfo
}
Return

ConfigB:
DisableHotkey()
gui 1: Hide

IniRead, sa1, Config.ini, Timer, min
IniRead, sa2, Config.ini, Timer, max

Gui 5: Font, bold s12
Gui 5: Add, Text, x5 w190 center, Click Timer Interval
Gui 5: Font, s10
Gui 5: Add, Text, x5 w190 center, timers are in ms`n1000ms = 1sec
Gui 5: Add, Text,,
Gui 5: Font, s11
Gui 5: Add, Text, center x5 w190, Minimum click timer
Gui 5: Add, Edit, vMinEdit center x50 w100, % sa1
Gui 5: Add, Text,,
Gui 5: Add, Text, center x5 w190, Maximum click timer
Gui 5: Add, Edit, vMaxEdit center x50 w100, % sa2
Gui 5: Add, Text,,
Gui 5: Add, Button, Default gButtonSave x50 w100, Save Timer
gui 5: -caption
Gui 5: Show, center w200, Timer
Return

ButtonSave:
GuiControlGet, NewMin, , MinEdit
GuiControlGet, NewMax, , MaxEdit

IniWrite, %NewMin%, Config.ini, Timer, min
IniWrite, %NewMax%, Config.ini, Timer, max

Gui 5: Destroy

Gui 13u: +AlwaysOnTop +OwnDialogs +Disabled
Gui 13u: Color, Green
Gui 13u: Font, cGreen
Gui 13u: Font, s16 bold
Gui 13u: Add, Text, valertlabel center,----Timer has been updated in the Config.ini file`n----
Gui 13u: -caption
Gui 13u: Show, NoActivate xcenter y0, BottomGUI

Gui 13: +AlwaysOnTop +OwnDialogs
Gui 13: Color, White
Gui 13: Font, cGreen
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, Timer has been updated in the Config.ini file
Gui 13: -caption
Gui 13: Show, NoActivate xcenter y9999, TopGUI

wingetpos,,,,bottomH, BottomGUI
wingetpos,,,,topH, TopGUI

topPOS := (bottomH - topH) / 2

Gui, TopGUI: +LabelTopGUI
WinMove, TopGUI,, , %topPOS%

Sleep 1500

Gui 13u: Destroy
Gui 13: Destroy
gui 1: show
EnableHotkey()
return

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
	
	Hotkey %lhk1%, Start
	Hotkey %lhk2%, coordb
	Hotkey %lhk3%, Configb
	Hotkey %lhk4%, exitb
}
return

Config2check:
{
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	
	Hotkey %lhk1%, Start
	Hotkey %lhk2%, pauseb
	Hotkey %lhk3%, resumeb
	Hotkey %lhk4%, exitb
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
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy
exitapp

Start:
ConfigError()

InputBox, timeToRunMinutes, Set Timer, Enter the time duration in minutes`n(example: 1 for 1 minute):,,250,150
timeToRunMS := timeToRunMinutes * 60 * 1000

endTime := A_TickCount + timeToRunMS

if (timeToRunMinutes = "" or timeToRunMinutes = 0)
{
	MsgBox, 48, Invalid Input, Please enter a valid number greater than 0.
	return
}

If (frcount = 0)
{
	SetTimer, ConfigCheck, off
	SetTimer, Config2Check, 250
	
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
	Gui, Add, Button, x5 y5 w100 h25 gStart , Start
	Gui, Add, Button, x115 y5 w100 h25 gInfo, Information
	Gui, Add, Button, x5 y35 w100 h25 gPauseb , Pause
	Gui, Add, Button, x115 y35 w100 h25 gResumeb , Resume
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

SetTimer, Countdown, 1000

sleep 250

GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running
DisableButton()
startcheck=1

winactivate, RuneScape

CoordMode, Mouse, Window
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
	
	CoordMode, Mouse, Window
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

info:
DisableHotkey()
IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
IniRead, logout, LLARS Config.ini, Logout, option
IniRead, sleepoption, LLARS Config.ini, Random Sleep, option
IniRead, chance, LLARS Config.ini, Random Sleep, chance

WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy

Gui 1: hide
Gui 3: hide	
Gui 20: +AlwaysOnTop +OwnDialogs
Gui 20: Font, S13 bold cMaroon
Gui 20: Add, Text, Center w220 x5,%scriptname%
Gui 20: Font, s11 Bold underline cTeal
Gui 20: Add, Text, Center w220 x5,[ Script Hotkeys ]
Gui 20: Font, Norm
Gui 20: Add, Text, Center w220 x5,Start: %lhk1%`nCoordinates/Pause: %lhk2%`nHotkey/Resume: %lhk3%`nExit: %lhk4%
Gui 20: Add, Text, center x5 w220,
Gui 20: Font, Bold underline cPurple
Gui 20: Add, Text, Center w220 x5,[ Additional Info ]
Gui 20: Font, Norm
Gui 20: Add, Text, Center w220 x5,Logout: %logout%`nRandom Sleep: %sleepoption%`nSleep Chance: %chance%`%
Gui 20: Font, s11 Bold c0x152039
Gui 20: Add, Text, center x5 w220,
Gui 20: Add, Text, Center w220 x5,Created by Gubna
Gui 20: Add, Button, gInfoLLARS w150 x40 center,LLARS Config
Gui 20: Add, Button, gInfoConfig w150 x40 center,Script Config
Gui 20: Add, Button, gDiscord w150 x40 center,Discord
Gui 20: add, button, gCloseInfo w150 x40 center,Close Information
Gui 20: -caption
Gui 20: Show, center w230, Information
return

CloseInfo:
EnableHotkey()
gui 20: destroy
gui 1: Show		
return

discord:
EnableHotkey()
Gui 20: destroy
Run, https://discord.gg/Wmmf65myPG
gui 1: Show		
return

InfoConfig:
EnableHotkey()
Run %A_ScriptDir%\Config.ini
return

InfoLLARS:
EnableHotkey()
Run %A_ScriptDir%\LLARS Config.ini
return

GitLink:
run, https://github.com/Gubna-Tech/RuneScape
Exitapp

DiscordError:
Run, https://discord.gg/Wmmf65myPG
Exitapp

CloseError:	
ExitApp