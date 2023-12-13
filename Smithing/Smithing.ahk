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
Gui, Add, Button, x35 y140 w150 h25 gExitb , Exit LLARS
Gui, Add, Text, x135 y90 w100 h25 vCounter
Gui, Add, Text, x8 y90 w125 h25, Total Run Count
Gui, Add, Text, x8 y65 w125 h25, Run Count
Gui, Add, Text, x135 y65 w150 h25 vCounter2
Gui, Font, cGreen
Gui, Add, Text, x135 y115 w70 h25 vState1
Gui, Add, Text, x8 y115 w125 h25 vScriptGreen
Gui, Font, cBlue
Gui, Add, Text, x135 y115 w70 h25 vState3
Gui, Add, Text, x8 y115 w125 h25 vScriptBlue
Gui, Font, cRed
Gui, Add, Text, x135 y115 w70 h25 vState2
Gui, Add, Text, x8 y115 w125 h25 vScriptRed
GuiControl,,State2, ** OFF **
Gui, Add, Text, x8 y115 w125 h25, %scriptname%
Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
WinSet, Transparent, %value%
Gui, Show,w220 h170, LLARS

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

ConfigError(){
	IniRead, x1, Config.ini, Anvil Coords, xmin
	IniRead, x2, Config.ini, Anvil Coords, xmax
	IniRead, y1, Config.ini, Anvil Coords, ymin
	IniRead, y2, Config.ini, Anvil Coords, ymax
	if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
	{
		Run %A_ScriptDir%\Config.ini
		GuiControl,,ScriptRed, CONFIG		
		GuiControl,,State2, ERROR
		MsgBox, 4112, Config Error, Please enter valid coordinates for [Anvil Coords] in the config.
		reload
	}
	
	IniRead, bar, Config.ini, Item Config, bar
	IniRead, x1, Config.ini, %bar%, xmin
	IniRead, x2, Config.ini, %bar%, xmax
	IniRead, y1, Config.ini, %bar%, ymin
	IniRead, y2, Config.ini, %bar%, ymax
	if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
	{
		Run %A_ScriptDir%\Config.ini
		GuiControl,,ScriptRed, CONFIG		
		GuiControl,,State2, ERROR
		MsgBox, 4112, Config Error, Please enter valid coordinates for the Bar in [Item Config] in the config.
		reload
	}
	
	IniRead, item, Config.ini, Item Config, item
	IniRead, x1, Config.ini, %item%, xmin
	IniRead, x2, Config.ini, %item%, xmax
	IniRead, y1, Config.ini, %item%, ymin
	IniRead, y2, Config.ini, %item%, ymax
	if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
	{
		Run %A_ScriptDir%\Config.ini
		GuiControl,,ScriptRed, CONFIG		
		GuiControl,,State2, ERROR
		MsgBox, 4112, Config Error, Please enter valid coordinates for Item in [Item Config] in the config.
		reload
	}
	
	IniRead, modifier, Config.ini, Item Config, modifier
	IniRead, x1, Config.ini, %modifier%, xmin
	IniRead, x2, Config.ini, %modifier%, xmax
	IniRead, y1, Config.ini, %modifier%, ymin
	IniRead, y2, Config.ini, %modifier%, ymax
	if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
	{
		Run %A_ScriptDir%\Config.ini
		GuiControl,,ScriptRed, CONFIG		
		GuiControl,,State2, ERROR
		MsgBox, 4112, Config Error, Please enter valid coordinates for modifier in [Item Config] in the config.
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

DisableHotkey(disable := true) {
	Control, Disable,, start
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	Hotkey, %lhk1%, off	
	Hotkey, %lhk2%, off
	Hotkey, %lhk3%, off
}

EnableHotkey(enable := true) {
	Control, Enable,, start
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	Hotkey, %lhk1%, on	
	Hotkey, %lhk2%, on
	Hotkey, %lhk3%, on
}

CoordB:
Gui 1: Hide
Gui 2: +LastFound +OwnDialogs +AlwaysOnTop
Gui 2: Font, s11 Bold
DisableHotkey()

IniRead, allContents, Config.ini
excludedSections := "|Sleep Brief|Sleep Normal|Sleep Short|skillbar hotkey|bank preset|scroll|item config|sleep smith|"

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
settimer, coordtt1, 10
return

CheckClicks:
if GetKeyState("RButton", "P")
{
	MouseGetPos, MouseX, MouseY
	settimer, coordtt1, off
	settimer, coordtt2, 10
	ClickCount++
	if (ClickCount = 1)
	{
		xmin := MouseX
		ymin := MouseY
	}
	else if (ClickCount = 2)
	{
		xmax := MouseX
		ymax := MouseY
		SetTimer, CheckClicks, Off
		
		IniWrite, %xmin%, Config.ini, %ButtonText%, xmin
		IniWrite, %xmax%, Config.ini, %ButtonText%, xmax
		IniWrite, %ymin%, Config.ini, %ButtonText%, ymin
		IniWrite, %ymax%, Config.ini, %ButtonText%, ymax
		
		Gui, 2: Destroy
		Gui, 1: Show
		
		Loop, 100
		{
			MouseGetPos, xm, ym
			settimer, coordtt2, off
			Tooltip, Coordinates have been updated in the config., %xm%+15, %ym%+15, 1
			Sleep, 25
			EnableHotkey()
		}
		Tooltip
	}
	
	Sleep, 250
}
return

coordtt1:
mousegetpos xn, yn
ToolTip,Right-click the top-left of the item you need the coordinates for., (xn+7), (yn+7),1
return

coordtt2:
mousegetpos xn, yn
ToolTip,Right-click the bottom-right of the item you need the coordinates for., (xn+7), (yn+7),1
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
excludedSections := "|Sleep Brief|Sleep Normal|Sleep Short|item config|scroll|base|1|2|3|4|5|burial|anvil coords|sleep smith|bronze wire|Bronze Bar|Iron Bar|Steel Bar|Mithril Bar|Adamant Bar|Rune Bar|Silver Bar|Gold Bar|Bronze Arrowhead|Bronze 2h sword|Bronze armoured boots|Bronze battleaxe|Bronze bolts|Bronze chainbody|Bronze claws|Bronze dagger|Bronze dart tip|Bronze full helm|Bronze gauntlets|Bronze hasta|Bronze hatchet|Bronze kiteshield|Bronze knife|Bronze limbs|Bronze longsword|Bronze mace|Bronze mattock|Bronze med helm|Bronze nails|Bronze off-hand battleaxe|Bronze off-hand claws|Bronze off-hand dagger|Bronze off-hand longsword|Bronze off-hand mace|Bronze off-hand scimitar|Bronze off-hand sword|Bronze off-hand warhammer|Bronze ore box|Bronze pickaxe|Bronze platebody|Bronze platelegs|Bronze plateskirt|Bronze scimitar|Bronze spear|Bronze square shield|Bronze sword|Bronze throwing axe|Bronze warhammer|Iron Arrowhead|Iron 2h sword|Iron armoured boots|Iron battleaxe|Iron bolts|Iron chainbody|Iron claws|Iron dagger|Iron dart tip|Iron full helm|Iron gauntlets|Iron hasta|Iron hatchet|Iron ingot|Iron kiteshield|Iron knife|Iron limbs|Iron longsword|Iron mace|Iron mattock|Iron med helm|Iron nails|Iron off-hand battleaxe|Iron off-hand claws|Iron off-hand dagger|Iron off-hand longsword|Iron off-hand mace|Iron off-hand scimitar|Iron off-hand sword|Iron off-hand warhammer|Iron ore box|Iron pickaxe|Iron platebody|Iron platelegs|Iron plateskirt|Iron railings|Iron scimitar|Iron spear|Iron spit|Iron square shield|Iron sword|Iron throwing axe|Iron warhammer|Off-hand iron knife|Off-hand iron throwing axe|Oil lantern frame|Steel Arrowhead|Bullseye lantern|Off-hand steel knife|Off-hand steel throwing axe|Steel 2h sword|Steel armoured boots|Steel battleaxe|Steel bolts|Steel chainbody|Steel claws|Steel dagger|Steel dart tip|Steel full helm|Steel gauntlets|Steel hasta|Steel hatchet|Steel ingot|Steel kite-shield|Steel knife|Steel limbs|Steel longsword|Steel mace|Steel mattock|Steel med helm|Steel nails|Steel off-hand battleaxe|Steel off-hand claws|Steel off-hand dagger|Steel off-hand longsword|Steel off-hand mace|Steel off-hand scimitar|Steel off-hand sword|Steel off-hand warhammer|Cannonball|Mithril Arrowhead|Mithril 2h sword|Mithril armoured boots|Mithril battleaxe|Mithril bolts|Mithril chainbody|Mithril claws|Mithril dagger|Mithril dart tip|Mithril full helm|Mithril gauntlets|Mithril grapple tip|Mithril hasta|Mithril hatchet|Mithril kiteshield|Mithril knife|Mithril limbs|Mithril longsword|Mithril mace|Mithril mattock|Mithril med helm|Mithril nails|Mithril off-hand battleaxe|Mithril off-hand claws|Mithril off-hand dagger|Mithril off-hand longsword|Mithril off-hand mace|Mithril off-hand scimitar|Mithril off-hand sword|Mithril off-hand warhammer|Mithril ore box|Mithril pickaxe|Mithril platebody|Mithril platelegs|Mithril plateskirt|Mithril scimitar|Mithril spear|Mithril square shield|Mithril sword|Adamant Arrowhead|Adamant 2h sword|Adamant armoured boots|Adamant battleaxe|Adamant bolts|Adamant chainbody|Adamant claws|Adamant dagger|Adamant dart tip|Adamant full helm|Adamant gauntlets|Adamant hasta|Adamant hatchet|Adamant kiteshield|Adamant knife|Adamant limbs|Adamant longsword|Adamant mace|Adamant mattock|Adamant med helm|Adamant nails|Adamant off-hand battleaxe|Adamant off-hand claws|Adamant off-hand dagger|Adamant off-hand longsword|Adamant off-hand mace|Adamant off-hand scimitar|Adamant off-hand sword|Adamant off-hand warhammer|Adamant ore box|Adamant pickaxe|Adamant platebody|Adamant platelegs|Adamant plateskirt|Adamant scimitar|Adamant spear|Adamant square shield|Adamant sword|Adamant throwing axe|Adamant warhammer|Rune Arrowhead|x|Off-hand rune knife|Off-hand rune throwing axe|Rune 2h sword|Rune armoured boots|Rune battleaxe|Rune bolts|Rune chainbody|Rune claws|Rune dagger|Rune dart tip|Rune full helm|Rune gauntlets|Rune hasta|Rune hatchet|Rune kiteshield|Rune knife|Rune limbs|Rune longsword|Rune mace|Rune mattock|Rune med helm|Rune nails|Rune off-hand battleaxe|Rune off-hand claws|Rune off-hand dagger|Rune off-hand longsword|Rune off-hand mace|Rune off-hand scimitar|Rune off-hand sword|Rune off-hand warhammer|Rune ore box|Rune pickaxe|Rune platebody|Rune platelegs|Orikalkum 2h warhammer|Orikalkum armoured boots|Orikalkum full helm|Orikalkum gauntlets|Orikalkum kiteshield|Orikalkum mattock|Orikalkum off hand warhammer|Orikalkum ore box|Orikalkum pickaxe|Orikalkum platebody|Orikalkum platelegs|Orikalkum warhammer|Necronium 2h greataxe|Necronium armoured boots|Necronium battleaxe|Necronium full helm|Necronium gauntlets|Necronium kiteshield|Necronium mattock|Necronium off hand battleaxe|Necronium ore box|Necronium pickaxe|Necronium platebody|Necronium platelegs|Bane 2h sword|Bane armoured boots|Bane full helm|Bane gauntlets|Bane longsword|Bane mattock|Bane off hand longsword|Bane ore box|Bane pickaxe|Bane platebody|Bane platelegs|Bane square shield|Elder rune 2h sword|Elder rune armoured boots|Elder rune full helm|Elder rune gauntlets|Elder rune longsword|Elder rune mattock|Elder rune off hand longsword|Elder rune ore box|Elder rune pickaxe|Elder rune platebody|Elder rune platelegs|Elder rune round shield|"

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
Gui, 1: Show
Loop, 100
{
	MouseGetPos, xm, ym
	Tooltip, Hotkey has been updated in the config file., %xm%+15, %ym%+15, 1
	Sleep, 25
	EnableHotkey()
}
Tooltip
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
}
return

UpdateCountdown:
RemainingTime := EndTime - A_TickCount
if (RemainingTime > 0) {
	GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RemainingTime)
}
return

RandomSleepAmountToMinutesSeconds(time) {
	minutes := Floor(time / 60000)
	seconds := Mod(Floor(time / 1000), 60)
	return minutes . "m " . seconds . "s"
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
exitapp

Start:
ConfigError()
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
	Gui, Add, Button, x15 y35 w90 h25 gPauseb , Pause
	Gui, Add, Button, x115 y35 w90 h25 gResumeb , Resume
	Gui, Add, Button, x35 y140 w150 h25 gExitb , Exit LLARS
	Gui, Add, Text, x135 y90 w65 h25 center vCounter
	Gui, Add, Text, x8 y90 w125 h25, Total Run Count
	Gui, Add, Text, x8 y65 w125 h25, Run Count
	Gui, Add, Text, x135 y65 w150 h25 vCounter2
	Gui, Font, cGreen
	Gui, Add, Text, x135 y115 w70 h25 vState1
	Gui, Add, Text, x8 y115 w125 h25 vScriptGreen
	Gui, Font, cBlue
	Gui, Add, Text, x135 y115 w70 h25 vState3
	Gui, Add, Text, x8 y115 w125 h25 vScriptBlue
	Gui, Font, cRed
	Gui, Add, Text, x135 y115 w70 h25 vState2
	Gui, Add, Text, x8 y115 w125 h25 vScriptRed
	GuiControl,,State2, ** OFF **
	Gui, Add, Text, x8 y115 w125 h25, %scriptname%
	Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
	WinSet, Transparent, %value%
	Gui, Show,w220 h170, LLARS
	WinMove, LLARS,, X, Y,
	
	count = 0
	++frcount
}

else
	
sleep 250

InputBox, runcount, Run How Many Times?,,,250, 100
if (runcount = "" or runcount = 0)
{
	MsgBox, 48, Invalid Input, Please enter a valid number greater than 0.
	return
}

sleep 250

GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running

runcount3 = %runcount%
count2 = 0
firstrun = 0
StartTime := A_TickCount
StartTimeStamp = %A_Hour%:%A_Min%:%A_Sec%
sleepcount = 0
totalSleepTime := 0

loop % runcount
{ 	
	If firstrun = 0
	{
		winactivate, RuneScape	
		
		++count
		++count2
		
		GuiControl,,Counter, %count%
		GuiControl,,Counter2, %count2% / %runcount3%
		GuiControl,,ScriptBlue, %scriptname%
		GuiControl,,State3, Running
		DisableButton()
		
		CoordMode, Mouse, Screen
		IniRead, x1, Config.ini, Anvil Coords, xmin
		IniRead, x2, Config.ini, Anvil Coords, xmax
		IniRead, y1, Config.ini, Anvil Coords, ymin
		IniRead, y2, Config.ini, Anvil Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%
		
		IniRead, sa1, Config.ini, Sleep Normal, min
		IniRead, sa2, Config.ini, Sleep Normal, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%		
		
		CoordMode, Mouse, Screen
		IniRead, bar, Config.ini, Item Config, bar
		IniRead, x1, Config.ini, %bar%, xmin
		IniRead, x2, Config.ini, %bar%, xmax
		IniRead, y1, Config.ini, %bar%, ymin
		IniRead, y2, Config.ini, %bar%, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%
		
		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		send {click}
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		CoordMode, Mouse, Screen
		IniRead, item, Config.ini, Item Config, item
		IniRead, x1, Config.ini, %item%, xmin
		IniRead, x2, Config.ini, %item%, xmax
		IniRead, y1, Config.ini, %item%, ymin
		IniRead, y2, Config.ini, %item%, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		mousemove, %x%, %y%
		
		IniRead, scroll1, Config.ini, Scroll, min
		IniRead, scroll2, Config.ini, Scroll, max
		Random, scrollrandom, %scroll1%, %scroll2%
		Sleep, %scrollrandom%
		
		loop % scrollrandom
		{
			send {wheeldown}
		}
		
		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		CoordMode, Mouse, Screen
		IniRead, item, Config.ini, Item Config, item
		IniRead, x1, Config.ini, %item%, xmin
		IniRead, x2, Config.ini, %item%, xmax
		IniRead, y1, Config.ini, %item%, ymin
		IniRead, y2, Config.ini, %item%, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		click, %x%, %y%
		
		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		send {click}
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		CoordMode, Mouse, Screen
		IniRead, modifier, Config.ini, Item Config, modifier
		IniRead, x1, Config.ini, %modifier%, xmin
		IniRead, x2, Config.ini, %modifier%, xmax
		IniRead, y1, Config.ini, %modifier%, ymin
		IniRead, y2, Config.ini, %modifier%, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%
		
		IniRead, sa1, Config.ini, Sleep Brief, min
		IniRead, sa2, Config.ini, Sleep Brief, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		send {click}
	}
	If firstrun = 1
	{
		++count
		++count2
		firstrun = 0
		
		winactivate, RuneScape	
		
		GuiControl,,Counter, %count%
		GuiControl,,Counter2, %count2% / %runcount3%
		GuiControl,,ScriptBlue, %scriptname%
		GuiControl,,State3, Running
		
		IniRead, sa1, Config.ini, Sleep Normal, min
		IniRead, sa2, Config.ini, Sleep Normal, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		CoordMode, Mouse, Screen
		IniRead, x1, Config.ini, Anvil Coords, xmin
		IniRead, x2, Config.ini, Anvil Coords, xmax
		IniRead, y1, Config.ini, Anvil Coords, ymin
		IniRead, y2, Config.ini, Anvil Coords, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%	
	}
	If firstrun = 0
	{
		++firstrun
		
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
		
		IniRead, option, LLARS Config.ini, Random Sleep, option
		if option = true
		{
			IniRead, chance, LLARS Config.ini, Random Sleep, chance
			Random, RandomNumber, 1, 100
			
			if % RandomNumber <= chance
			{
				
				++sleepcount
				GuiControl,, ScriptBlue, Random Sleep
				GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RandomSleepAmount)
				
				IniRead, rs1, LLARS Config.ini, Random Sleep, min
				IniRead, rs2, LLARS Config.ini, Random Sleep, max
				Random, RandomSleepAmount, %rs1%, %rs2%
				
				SetTimer, UpdateCountdown, 1000
				EndTime := A_TickCount + RandomSleepAmount
				totalSleepTime += RandomSleepAmount
				Sleep, RandomSleepAmount
				SetTimer, UpdateCountdown, Off
				
				GuiControl,,ScriptBlue, %scriptname%
				GuiControl,,State3, Running
			}
		}
		
		send {space}
		
		IniRead, sa1, Config.ini, Sleep Smith, min
		IniRead, sa2, Config.ini, Sleep Smith, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
	}	
}

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

GuiControl,,ScriptGreen, %scriptname%
GuiControl,,State1, Finished

EndTimeStamp = %A_Hour%:%A_Min%:%A_Sec%
EndTime := A_TickCount
TotalTime := (EndTime - StartTime) / 1000
AverageTime := TotalTime / runcount3

TotalTimeHours := Floor(TotalTime / 3600)
TotalTimeMinutes := Mod(Floor(TotalTime / 60), 60)
TotalTimeSeconds := Mod(TotalTime, 60)

AverageTimeMinutes := Floor(AverageTime / 60)
AverageTimeSeconds := Mod(AverageTime, 60)

TotalTimeHours := Round(TotalTimeHours)
TotalTimeMinutes := Round(TotalTimeMinutes)
TotalTimeSeconds := Round(TotalTimeSeconds)
AverageTimeMinutes := Round(AverageTimeMinutes)
AverageTimeSeconds := Round(AverageTimeSeconds)

percentage := Round((sleepcount / runcount) * 100)

totalSleepTimeSeconds := Floor(totalSleepTime / 1000)
TotalSleepHours := Floor(totalSleepTimeSeconds / 3600)
TotalSleepMinutes := Floor(Mod(totalSleepTimeSeconds, 3600) / 60)
TotalSleepSeconds := Mod(totalSleepTimeSeconds, 60)

SoundPlay, C:\Windows\Media\Ring06.wav, 1
IniRead, chance, LLARS Config.ini, Random Sleep, chance
MsgBox, 64, LLARS Run Info, %scriptname% has completed %runcount3% runs`n`nTotal time: %TotalTimeHours%h : %TotalTimeMinutes%m : %TotalTimeSeconds%s`nAverage loop: %AverageTimeMinutes%m : %AverageTimeSeconds%s`n`nStart time: %starttimestamp%`nEnd time: %endtimestamp%`n`nSet chance: %chance%`%`nActual chance: %percentage%`%`nTotal random sleeps: %sleepcount%`nTotal time slept: %TotalSleepHours%h : %TotalSleepMinutes%m : %TotalSleepSeconds%s

EnableButton()
return