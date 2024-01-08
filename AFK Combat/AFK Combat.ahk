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
Gui, Add, Button, x115 y35 w90 h25 gConfigb , Hotkeys
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

ConfigError(){
	IniRead, option,Config.ini, Agro, option
	if option=true
	{
		IniRead, hk, Config.ini, Agro, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Agro] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, AnimateDead, option
	if option=true
	{
		IniRead, hk, Config.ini, AnimateDead, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG	
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [AnimateDead] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Antipoison, option
	if option=true
	{
		IniRead, hk, Config.ini, Antipoison, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Antipoison] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Attack, option
	if option=true
	{
		IniRead, hk, Config.ini, Attack, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Attack] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Magic, option
	if option=true
	{
		IniRead, hk, Config.ini, Magic, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Magic] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Overload, option
	if option=true
	{
		IniRead, hk, Config.ini, Overload, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Overload] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Prayer, option
	if option=true
	{
		IniRead, hk, Config.ini, Prayer, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Prayer] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Ranged, option
	if option=true
	{
		IniRead, hk, Config.ini, Ranged, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Ranged] in the config.
			reload
		}	
	}
	
	
	IniRead, option,Config.ini, Strength, option
	if option=true
	{
		IniRead, hk, Config.ini, Strength, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Strength] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Warmaster, option
	if option=true
	{
		IniRead, hk, Config.ini, Warmaster, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Warmaster] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Weapon Poison, option
	if option=true
	{
		IniRead, hk, Config.ini, Weapon Poison, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Weapon Poison] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Ancient Elven Ritual Shard, option
	if option=true
	{
		IniRead, hk, Config.ini, Ancient Elven Ritual Shard, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Ancient Elven Ritual Shard] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Vecna Skull, option
	if option=true
	{
		IniRead, hk, Config.ini, Vecna Skull, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Vecna Skull] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Incense Sticks, option
	if option=true
	{
		IniRead, hk, Config.ini, Incense Sticks, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Incense Sticks] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Prayer Powder, option
	if option=true
	{
		IniRead, hk, Config.ini, Prayer Powder, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Prayer Powder] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Summon, option
	if option=true
	{
		IniRead, hk, Config.ini, Summon, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Summon] in the config.
			reload
		}	
	}
	
	IniRead, option,Config.ini, Saradomin Brew, option
	if option=true
	{
		IniRead, hk, Config.ini, Saradomin Brew, hotkey
		if (hk = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, CONFIG		
			GuiControl,,State2, ERROR
			MsgBox, 4112, Config Error, Please enter a valid hotkey for [Saradomin Brew] in the config.
			reload
		}	
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
Gui 1: Hide
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop
Gui 2: Font, s11 Bold
DisableHotkey()

IniRead, allContents, Config.ini
excludedSections := "Sleep Brief|Sleep Normal|Sleep Short|agro|prayer|afk|heal|strength|attack|magic|ranged|overload|warmaster|antifire|antipoison|weapon poison|animate dead|vecna skull|ancient elven ritual shard|incense sticks|prayer powder|summon|saradomin brew|loot|"

sectionList := " ***** Make a Selection ***** "

Loop, Parse, allContents, `n
{
	currentSection := A_LoopField
	
	if !InStr(excludedSections, "|" currentSection "|")
		sectionList .= "|" currentSection
}

Gui, 2: Add, DropDownList, w230 vSectionList Choose1 gDropDownChanged, % sectionList
Gui, 2: Add, Button, w230 gClose, Close

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

Gui 11: +AlwaysOnTop +OwnDialogs
Gui 11: Font, s16 bold
Gui 11: Add, Text, vTone center,Right-click the top-left of the item you need the coordinates for
Gui 11: -caption
Gui 11: Show, NoActivate xcenter y5

return

CheckClicks:
if GetKeyState("RButton", "P")
{	
	MouseGetPos, MouseX, MouseY
	ClickCount++
	if (ClickCount = 1)
	{
		Gui 11: destroy
		Gui 12: +AlwaysOnTop +OwnDialogs
		Gui 12: Font, s16 bold
		Gui 12: Add, Text, vTtwo center,Right-click the bottom-right of the item you need the coordinates for
		Gui 12: -caption
		Gui 12: Show, NoActivate xcenter y5
		
		xmin := MouseX
		ymin := MouseY
	}
	else if (ClickCount = 2)
	{
		Gui 12: destroy
		
		Gui 13: +AlwaysOnTop +OwnDialogs
		Gui 13: Color, Green
		Gui 13: Font, cWhite
		Gui 13: Font, s16 bold
		Gui 13: Add, Text, vTthree center,Coordinates have been updated in the Config.ini file
		Gui 13: -caption
		Gui 13: Show, NoActivate xcenter y5
		
		xmax := MouseX
		ymax := MouseY
		SetTimer, CheckClicks, Off
		
		IniWrite, %xmin%, Config.ini, %ButtonText%, xmin
		IniWrite, %xmax%, Config.ini, %ButtonText%, xmax
		IniWrite, %ymin%, Config.ini, %ButtonText%, ymin
		IniWrite, %ymax%, Config.ini, %ButtonText%, ymax
		
		Sleep, 3000
		
		Gui 13: destroy
		Gui, 2: Destroy
		Gui, 1: Show
		
		EnableHotkey()	
	}
	
	Sleep, 250
}
return

~Esc::
IfWinActive, Coordinates
	GoSub, close
Else IfWinActive, Hotkeys
	GoSub, close2
Else
	Return
Return

configB:
Gui 1: Hide
Gui 3: +LastFound +OwnDialogs +AlwaysOnTop
Gui 3: Font, s11 Bold
DisableHotkey()

IniRead, allContents, Config.ini
excludedSections := "|Sleep Brief|Sleep Normal|Sleep Short|prayer|afk|heal|loot|"

sectionList := " ***** Make a Selection ***** "

Loop, Parse, allContents, `n
{
    currentSection := A_LoopField

    if !InStr(excludedSections, "|" currentSection "|")
        sectionList .= "|" currentSection
}

Gui, 3: Add, DropDownList, w230 vSectionList Choose1 gDropDownChanged2, % sectionList
Gui, 3: Add, Text, w230 vHotkeysText, Hotkeys will be displayed here
Gui, 3: Add, Hotkey, x100 y60 w75 vChosenHotkey gHotkeyChanged Center, ** NONE **
Gui, 3: Add, Button, x10 y90 w230 gClose2, Close

Gui, 3: Show, w250 h100 Center, Hotkeys
Gui 3: -Caption
Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
WinSet, Transparent, %value%
return

Close2:
Gui 3: Destroy
Gui 1: Show
EnableHotkey()
return

DropDownChanged2:
GuiControlGet, selectedSection,, SectionList

if (selectedSection != " ***** Make a Selection ***** ") {
	IniRead, existingHotkey, Config.ini, %selectedSection%, Hotkey
	GuiControl,, ChosenHotkey, %existingHotkey%
	GoSub, ButtonClicked2
}

return

ButtonClicked2:
GuiControl,, HotkeysText, Enter new hotkey
GuiControl, Focus, ChosenHotkey
return

HotkeyChanged:
IniWrite, %ChosenHotkey%, Config.ini, %selectedSection%, Hotkey
Gui, 3: Destroy

Gui 13: +AlwaysOnTop +OwnDialogs
Gui 13: Color, Green
Gui 13: Font, cWhite
Gui 13: Font, s16 bold
Gui 13: Add, Text, vTthree center, Hotkey has been updated in the Config.ini file
Gui 13: -caption
Gui 13: Show, NoActivate xcenter y5

Sleep 3000

Gui 13: Destroy
Gui 1: Show
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
DisableButton()
remainingTimeMS := endTime - A_TickCount
remainingTimeMinutes := Floor(remainingTimeMS / 60000)
remainingTimeSeconds := Mod(Floor(remainingTimeMS / 1000), 60)

GuiControl,, TimerCount, %remainingTimeMinutes%m %remainingTimeSeconds%s

if (remainingTimeMS <= 360000) 
{
	SetTimer, Agro, Off
}
if (remainingTimeMS <= 0 and startcheck=1)
{
	SetTimer, Countdown, off
	SetTimer, AFK, Off
	SetTimer, AnimateDead, Off
	SetTimer, Antifire, Off
	SetTimer, Antipoison, Off
	SetTimer, Attack, Off
	SetTimer, Magic, Off
	SetTimer, Overload, Off
	SetTimer, Prayer, Off
	SetTimer, PrayerP, Off
	SetTimer, Ranged, Off
	SetTimer, Strength, Off
	SetTimer, Warmaster, Off
	SetTimer, WeaponPoison, Off
	SetTimer, Vecna, Off
	SetTimer, Shard, Off
	SetTimer, IncenseSticks, Off
	SetTimer, SaraBrew, Off
	SetTimer, Summon, Off
	SetTimer, Loot, Off
	GuiControl,, TimerCount, Done
	GuiControl,,State3, Done
	EnableButton()
	Logout()
	Goto EndMsg
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

ExitB:
guiclose:
WinGetPos, GUIxc, GUIyc,,,LLARS
IniWrite, %GUIxc%, LLARS Config.ini, GUI POS, guix
IniWrite, %GUIyc%, LLARS Config.ini, GUI POS, guiy
exitapp

Start:
ConfigError()
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

InputBox, timeToRunMinutes, Set Timer, Enter script run time in minutes`nexample: 25 for 25 minute`nrun time needs to be more than 5 minutes,,300,165
timeToRunMS := timeToRunMinutes * 60 * 1000
endTime := A_TickCount + timeToRunMS

if (timeToRunMinutes = "" or timeToRunMinutes <= 5)
{
	MsgBox, 48, Invalid Input, Please enter a run time greater than 5 minutes.
	return
}

SetTimer, Countdown, 1000

sleep 250

GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running
DisableButton()
startcheck=1
StartTimeStamp = %A_Hour%:%A_Min%:%A_Sec%

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

IniRead, option,Config.ini, AFk, option
if option=true
{
	winactivate, RuneScape
	DisableButton()
	
	WinGetPos, RSx, RSy, RSw, RSh, RuneScape
	xmin := RSx
	xmax :=RSw + RSx
	ymin :=RSy
	ymax :=RSh + RSy
	
	IniRead, sa1, Config.ini, AFK, min
	IniRead, sa2, Config.ini, AFK, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, AFK, %sleepamount%
	
	CoordMode, Mouse, Screen
	Random, x, %xmin%, %xmax%
	Random, y, %ymin%, %ymax%
	Random, RandomSpeed, 25, 100
	mousemove, %x%, %y%, %RandomSpeed%
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Anti-AFK, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Prayer, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
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
	DisableButton()
	
	IniRead, sa1, Config.ini, Strength, min
	IniRead, sa2, Config.ini, Strength, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Strength, %sleepamount%
	
	IniRead, hk, Config.ini, Strength, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Strength, (xm+15), (ym+15),1 ;*[AFK Combat]
		sleep 25
	}
	tooltip	
}

IniRead, option,Config.ini, Attack, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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

IniRead, option,Config.ini, Weapon Poison, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Weapon Poison, min
	IniRead, sa2, Config.ini, Weapon Poison, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, WeaponPoison, %sleepamount%
	
	IniRead, hk, Config.ini, Weapon Poison, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Weapon Poison, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Animate Dead, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Animate Dead, min
	IniRead, sa2, Config.ini, Animate Dead, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, AnimateDead, %sleepamount%
	
	IniRead, hk, Config.ini, Animate Dead, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Animate Dead, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Vecna Skull, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Vecna Skull, min
	IniRead, sa2, Config.ini, Vecna Skull, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Vecna, %sleepamount%
	
	IniRead, hk, Config.ini, Vecna Skull, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Vecna Skull, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Ancient Elven Ritual Shard, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Ancient Elven Ritual Shard, min
	IniRead, sa2, Config.ini, Ancient Elven Ritual Shard, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Shard, %sleepamount%
	
	IniRead, hk, Config.ini, Ancient Elven Ritual Shard, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Ancient Elven Ritual Shard, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Incense Sticks, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Incense Sticks, min
	IniRead, sa2, Config.ini, Incense Sticks, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, IncenseSticks, %sleepamount%
	
	IniRead, hk, Config.ini, Incense Sticks, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Incense Sticks, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Prayer Powder, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Prayer Powder, min
	IniRead, sa2, Config.ini, Prayer Powder, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, PrayerP, %sleepamount%
	
	IniRead, hk, Config.ini, Prayer Powder, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Prayer Powder, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Summon, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Summon, min
	IniRead, sa2, Config.ini, Summon, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Summon, %sleepamount%
	
	IniRead, hk, Config.ini, Summon, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Familiar Summoned, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Saradomin Brew, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Saradomin Brew, min
	IniRead, sa2, Config.ini, Saradomin Brew, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, SaraBrew, %sleepamount%
	
	IniRead, hk, Config.ini, Saradomin Brew, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Saradomin Brew Dose Consumed, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

IniRead, option,Config.ini, Loot, option
if option=true
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Loot, min
	IniRead, sa2, Config.ini, Loot, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Loot, %sleepamount%
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Auto-Loot Timer Set, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

return

Agro:
{
	winactivate, RuneScape	
	DisableButton()
	
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

AFK:
{
	winactivate, RuneScape
	DisableButton()
	
	WinGetPos, RSx, RSy, RSw, RSh, RuneScape
	xmin := RSx
	xmax :=RSw + RSx
	ymin :=RSy
	ymax :=RSh + RSy
	
	IniRead, sa1, Config.ini, AFK, min
	IniRead, sa2, Config.ini, AFK, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, AFK, %sleepamount%
	
	CoordMode, Mouse, Screen
	Random, x, %xmin%, %xmax%
	Random, y, %ymin%, %ymax%
	Random, RandomSpeed, 25, 100
	mousemove, %x%, %y%, %RandomSpeed%
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Anti-AFK, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip	
}
return

Strength:
{
	winactivate, RuneScape	
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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
	DisableButton()
	
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

WeaponPoison:
{
		winactivate, RuneScape	
		DisableButton()
		
		IniRead, sa1, Config.ini, Weapon Poison, min
		IniRead, sa2, Config.ini, Weapon Poison, max
		Random, SleepAmount, %sa1%, %sa2%
		settimer, WeaponPoison, %sleepamount%
		
		IniRead, hk, Config.ini, Weapon Poison, hotkey
		send {%hk%}
		
		loop 100
		{
			mousegetpos xm, ym
			tooltip, Activated Weapon Poison, (xm+15), (ym+15),1
			sleep 25
		}
		tooltip
}

AnimateDead:
{
	winactivate, RuneScape	
	DisableButton()
	
	IniRead, sa1, Config.ini, Animate Dead, min
	IniRead, sa2, Config.ini, Animate Dead, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, AnimateDead, %sleepamount%
	
	IniRead, hk, Config.ini, Animate Dead, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Animate Dead, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}

Vecna:
{
	winactivate, RuneScape
	DisableButton()
	
	IniRead, sa1, Config.ini, Vecna Skull, min
	IniRead, sa2, Config.ini, Vecna Skull, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Vecna, %sleepamount%	
	
	IniRead, hk, Config.ini, Vecna Skull, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Vecna Skull, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

Shard:
{
	winactivate, RuneScape
	DisableButton()
	
	IniRead, sa1, Config.ini, Ancient Elven Ritual Shard, min
	IniRead, sa2, Config.ini, Ancient Elven Ritual Shard, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Shard, %sleepamount%	
	
	IniRead, hk, Config.ini, Ancient Elven Ritual Shard, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Ancient Elven Ritual Shard, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

IncenseSticks:
{
	winactivate, RuneScape
	DisableButton()
	
	IniRead, sa1, Config.ini, Incense Sticks, min
	IniRead, sa2, Config.ini, Incense Sticks, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, IncenseSticks, %sleepamount%	
	
	IniRead, hk, Config.ini, Incense Sticks, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Incense Sticks, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

PrayerP:
{
	winactivate, RuneScape
	DisableButton()
	
	IniRead, sa1, Config.ini, Prayer Powder, min
	IniRead, sa2, Config.ini, Prayer Powder, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, PrayerP, %sleepamount%	
	
	IniRead, hk, Config.ini, Prayer Powder, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Activated Prayer Powder, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

Summon:
{
	winactivate, RuneScape
	DisableButton()
	
	IniRead, sa1, Config.ini, Summon, min
	IniRead, sa2, Config.ini, Summon, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Summon, %sleepamount%	
	
	IniRead, hk, Config.ini, Summon, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Familiar Summoned, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

SaraBrew:
{
	winactivate, RuneScape
	DisableButton()
	
	IniRead, sa1, Config.ini, Saradomin Brew, min
	IniRead, sa2, Config.ini, Saradomin Brew, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, SaraBrew, %sleepamount%	
	
	IniRead, hk, Config.ini, Saradomin Brew, hotkey
	send {%hk%}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Saradomin Brew Dose Consumed, (xm+15), (ym+15),1
		sleep 25
	}
	tooltip
}
return

Loot:
{
	winactivate, RuneScape
	DisableButton()
	
	IniRead, sa1, Config.ini, Loot, min
	IniRead, sa2, Config.ini, Loot, max
	Random, SleepAmount, %sa1%, %sa2%
	settimer, Loot, %sleepamount%	
	
	send {space}
	
	loop 100
	{
		mousegetpos xm, ym
		tooltip, Auto-Loot Activated, (xm+15), (ym+15),1
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
EndTimeStamp = %A_Hour%:%A_Min%:%A_Sec%
hours := timeToRunMinutes // 60
minutes := Mod(timeToRunMinutes, 60)
SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nTotal time: %hours%h %minutes%m`n`nStart time: %starttimestamp%`nEnd time: %endtimestamp%
return