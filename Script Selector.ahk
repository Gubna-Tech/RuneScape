#SingleInstance Force
#Persistent
#NoTrayIcon
SetBatchLines, -1

DetectHiddenWindows, On
closeotherllars()

if (InStr(A_ScriptDir, ".zip" or ".rar") > 0) {
	Menu, Tray, NoIcon
	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5,ERROR
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, Files Are Zipped
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, cBlack
	Gui Error: Add, Text, Center w220 x5, Please extract all files from the zipped (.zip) folder:
	Gui Error: Font, underline s12
	Gui Error: Add, Text, cGreen center w220 x5, RuneScape-main.zip
	Gui Error: Font, s11 norm Bold c0x152039
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Add, Text, Center w220 x5,Created by Gubna
	Gui Error: Add, Button, gDiscordError w150 x40 center,Discord
	Gui Error: add, button, gCloseError w150 x40 center,Close Error
	WinSet, ExStyle, ^0x80
	Gui Error: -caption
	Gui Error: Show, center w230, File Error
	return
}

if !FileExist("ScriptList.ini")
{
	Menu, Tray, NoIcon
	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5,ERROR
	Gui Error: Add, Text, center x5 w220,
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, ScriptList.ini not found
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
	return
}

FileRead, ScriptCount, ScriptList.ini
ScriptTotal := StrSplit(ScriptCount, "`n").Length()

Hotkey, enter, Select
Hotkey, esc, Exit

Gui +LastFound +OwnDialogs +AlwaysOnTop -caption
Gui Font, s12 Bold cBlue
Gui  Add, Text, Center w410 x5,Select a script from the list below and`n click 'Select Script' or press Enter
Gui Font, cGreen
Gui  Add, Text, Center w410 x5,Total Scripts: %ScriptTotal%
Gui Font, s11 Bold cBlack
Gui Add, ListBox, sort vScriptListBox gScriptSelect x12 w395 r15
GuiControl, -Redraw, ScriptListBox
Loop, read, ScriptList.ini
{
    section := A_LoopReadLine
    GuiControl,, ScriptListBox, %section%
}
GuiControl, +Redraw, ScriptListBox
Gui, Add, Button, gSelect w120 x150 center, Select Script
Gui, Add, Button, gClear w120 x150 center, Clear Selection
Gui, Add, Button, gExit w120 x150 center, Close Selector
Gui, Show, w420 h460 center, Script Selector
WinSet, ExStyle, ^0x80

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

CheckPOS() {
    allowedWindows := "|Script Selector|"
    
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

GuiBalance()
{
	wingetpos,,,,bottomH, BottomGUI
	wingetpos,,,,topH, TopGUI
	
	topPOS := (bottomH - topH) / 2
	
	Gui, TopGUI: +LabelTopGUI
	WinMove, TopGUI,, , %topPOS%
}

GuiBorder()
{
	Gui Border: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui Border: Color, Green
	WinSet, ExStyle, ^0x80
	Gui Border: -caption
	Gui Border: Show, NoActivate xcenter y0 w505 h165, BottomGUI
}

GuiReset()
{
	Gui Border: destroy
	Gui Info: destroy
}

ScriptSelect:
if A_GuiEvent = Normal
{
	GuiControlGet, selectedScript, , ScriptListBox
	Switch selectedScript
	{	
		Case "AFK Combat":
		script := "AFK Combat"
		scriptinfo := "Uses Agro pots/flasks to stay in combat for a predetermined length of time. Other pots/flasks can be used by changing the Config.ini"
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Alchemy":
		script := "Alchemy"
		scriptinfo := "Low/High Alchs a selected item(s) in your inventory for a predetermined amount of times."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Amulet Stringer":
		script := "Amulet Stringer"
		scriptinfo := "Strings amulets by using in-game bank preset to make a predetermined amount of inventories of jewellery."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Anti-AFK":
		script := "Anti-AFK"
		scriptinfo := "Moves the mouse within the RuneScape client border, based on a random timer configured through Config.ini"
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Armour Crafter - Portables - Walking":
		script := "Armour Crafter"
		scriptinfo := "Uses a Portable Crafter that is more than (1) tile from a bank and requires walking. With the Portable Crafter, it will make your desired amount of a selected armour."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Armour Crafter - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Armour Crafter - Portables - Non-Walking":
		script := "Armour Crafter"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. With the Portable Crafter, it will make your desired amount of a selected armour."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Armour Crafter - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Armour Crafter":
		script := "Armour Crafter"
		scriptinfo := "Crafts your selected armour for a predetermined amount of runs."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Arrow Fletcher":
		script := "Arrow Fletcher"
		scriptinfo := "Adds the tip to a headless arrow. Can be used for darts and/or bolts."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Ash 2 Incense":
		script := "Ash 2 Incense"
		scriptinfo := "Adds ash to an already crafted incense stick. Use this after 'Incense Crafter' and before 'Herb 2 Incense'."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "AutoClicker":
		script := "AutoClicker"
		scriptinfo := "Clicks randomly within a predetermined coordinate range set by the user. Timer for the clicks can be changed in the Config.ini"
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "AutoTele":
		script := "AutoTele"
		scriptinfo := "Casts the same Teleportation spell a set number of times using hotkeys."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bake Pie - Lunar Spell":
		script := "Bake Pie"
		scriptinfo := "Bakes all uncooked pies in your inventory."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bake Pie - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bar Smelter":
		script := "Bar Smelter"
		scriptinfo := "Creates metal bars, type of bar is set by the user as is the run count."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bar Smelter - Smelting Gloves":
		script := "Smelting Glove"
		scriptinfo := "Uses the Smelting Gauntlets from Family Crest Quest to make Gold Bars. Smelted Gold Bars go to metal bank and not inventory."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bar Smelter - Smelting Gloves
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Barbarian - Advanced":
		script := "Barbarian Course"
		scriptinfo := "Runs laps of the Barbarian - Advanced agility course. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Barbarian - Advanced
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Barbarian - Basic":
		script := "Barbarian Course"
		scriptinfo := "Runs laps of the Barbarian - Basic agility course. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Barbarian - Basic
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bones 2 Bananas":
		script := "Bones 2 Bananas"
		scriptinfo := "Turns all normal bones, big bones and monkey bones in your inventory into bananas."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bow Cutter":
		script := "Bow Cutter"
		scriptinfo := "Cuts logs into unstrung bows. Use 'Bow Stringer' to string the bows after."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bow Cutter - Portables - Walking":
		script := "Bow Cutter"
		scriptinfo := "Uses a Portable Crafter that is more than (1) tile from a bank and requires walking. With the Portable Crafter, it will cut logs into unstrung bows."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bow Cutter - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bow Cutter - Portables - Non-Walking":
		script := "Bow Cutter"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. With the Portable Crafter, it will cut logs into unstrung bows."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bow Cutter - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bow Stringer":
		script := "Bow Stringer"
		scriptinfo := "Combines bowstring with unstrung bows using the in-game bank preset hotkey."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bow Stringer - Portables - Walking":
		script := "Bow Stringer"
		scriptinfo := "Uses a Portable Crafter that is more than (1) tile from a bank and requires walking. With the Portable Crafter, it will combine bowstring with unstrung bows."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bow Stringer - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Bow Stringer - Portables - Non-Walking":
		script := "Bow Stringer"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. With the Portable Crafter, it will combine bowstring with unstrung bows."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bow Stringer - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Brick Maker - Fort Forinthry":
		script := "Limestone Brick"
		scriptinfo := "Cuts limtestone into limestone bricks using the stonecutter."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Brick Maker - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Burthrope":
		script := "Burthorpe"
		scriptinfo := "Runs laps of the Burthrope agility course. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Burthrope
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Candle Crafter":
		script := "Candle Crafter"
		scriptinfo := "Crafts candles for the Necromancy skill."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Cape Cleaner - Herblore (Skillcape Perk)":
		script := "Cape Cleaner"
		scriptinfo := "Uses the 99/120 Herblore Skillcape to instantly clean a full inventory of dirty herbs. Requires the Skillcape to be worn."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cape Cleaner - Herblore (Skillcape Perk)
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Clay Fire - Portables - Non-Walking":
		script := "Clay Fire"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. Using the Portable Crafter, it will fire an unfired urn."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Clay Fire - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Clay Fire - Portables - Walking":
		script := "Clay Fire"
		scriptinfo := "Uses a Portable Crafter that is more than (1) tile from a bank and requires walking. Using the Portable Crafter, it will fire an unfired urn."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Clay Fire - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Clay Form - Portables - Non-Walking":
		script := "Clay Form"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. Using the Portable Crafter, it will form an unfired urn of your choice."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Clay Form - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Clay Form - Portables - Walking":
		script := "Clay Form"
		scriptinfo := "Uses a Portable Crafter that is more than (1) tile from a bank and requires walking. Using the Portable Crafter, it will form an unfired urn of your choice."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Clay Form - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Cooking - Burthorpe":
		script := "Cooking"
		scriptinfo := "Walks between the Range and main bank in Burthrope to cook an inventory of food. Portables and Fort cooking are recommended over this script."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cooking - Burthorpe
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Cooking - Fort Forinthry":
		script := "Cooking"
		scriptinfo := "Cooks food at the Fort using the bank chest next to the Range."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cooking - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Cooking - Portables - Non-Walking":
		script := "Cooking"
		scriptinfo := "Uses a Portable Range within (1) tile of a bank. Using the Portable Range, it will cook an inventory of food."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cooking - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Cooking - Portables - Walking":
		script := "Cooking"
		scriptinfo := "Uses a Portable Range that is more than (1) tile from a bank and requires walking. Using the Portable Range, it will cook an inventory of food."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cooking - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Decoration Maker":
		script := "Decoration Maker"
		scriptinfo := "Made for the 2023 Christmas Event, creates decorations for crafting xp and holiday rewards."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Fire + Form - Portables":
		script := "Fire + Form"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. Using the Portable Crafter, it will form an urn and then fire it before repeating the process."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Fire + Form - Portables
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Fire Urn - Lunar Spell":
		script := "Fire Urn"
		scriptinfo := "Uses the Lunar Spell 'Fire Urn' to fire an inventory of unfired urns."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Fire Urn - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Firemaking - Portables - Non-Walking":
		script := "Firemaking"
		scriptinfo := "Uses a Portable Brazier within (1) tile of a bank. Using the Portable Brazier, it will burn an inventory of logs."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Firemaking - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Firemaking - Portables - Walking":
		script := "Firemaking"
		scriptinfo := "Uses a Portable Brazier that is more than (1) tile from a bank and requires walking. Using the Portable Brazier, it will burn an inventory of logs."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Firemaking - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Frame Maker - Fort Forinthry":
		script := "Frame Maker"
		scriptinfo := "Walks between the bank chest and woodworking bench to make frames."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Frame Maker - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Gem Cutter":
		script := "Gem Cutter"
		scriptinfo := "Cuts an inventory of uncut gems, opens the bank, withdraws more, and repeats."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Gem Cutter - Portables - Non-Walking":
		script := "Gem Cutter"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. Using the Portable Crafter, it will cut an inventory of uncut gems."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Gem Cutter - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Gem Cutter - Portables - Walking":
		script := "Gem Cutter"
		scriptinfo := "Uses a Portable Crafter that is more than (1) tile from a bank and requires walking. Using the Portable Crafter, it will cut an inventory of uncut gems."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Gem Cutter - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Glassblowing":
		script := "Glassblowing"
		scriptinfo := "Turns molten glass into your selected glass item. Crafts full inventories, banks, and repeats."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Gnome - Advanced":
		script := "Gnome Course"
		scriptinfo := "Runs laps of the Gnome - Advanced agility course. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Gnome - Advanced
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Gnome - Basic":
		script := "Gnome Course"
		scriptinfo := "Runs laps of the Gnome - Basic agility course. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Gnome - Basic
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Herb 2 Incense":
		script := "Herb 2 Incense"
		scriptinfo := "Adds a herb to an ashy incense stick. Use 'Ash 2 Incense' first or ashy incense sticks from the Grand Exchange."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Herb Cleaner":
		script := "Herb Cleaner"
		scriptinfo := "Cleans full inventories of dirty herbs."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Het's Oasis":
		script := "Het's Oasis"
		scriptinfo := "Runs laps of the Het's Oasis agility course. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Het's Oasis
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Incense Crafter":
		script := "Incense Crafter"
		scriptinfo := "Cuts logs into incense sticks. Use this before 'Ash 2 Incense'."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Ink Crafter":
		script := "Ink Crafter"
		scriptinfo := "Crafts ink for the Necromancy skill."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Jewellery Crafter - Lumbridge":
		script := "Jewellery Crafter"
		scriptinfo := "Runs between the Combat Academy bank chest and Lumbridge Furnace to craft your selected Jewellery. Config.ini needs manual setup to work."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Jewellery Crafter - Lumbridge
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Jewellery Crafter - Fort Forinthry":
		script := "Jewellery Crafter"
		scriptinfo := "Runs between the bank chest and furnace at the Fort to craft your selected Jewellery. Config.ini needs manual setup to work."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Jewellery Crafter - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Jewellery Enchanter":
		script := "Jewel Enchant"
		scriptinfo := "Casts the selected 'Enchanted Cast' spell to enchant jewellery in your inventory."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Jewellery Stringer - Lunar Spell":
		script := "String Jewellery"
		scriptinfo := "String an inventory of jewellery using the Lunar Spell."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Jewellery Stringer - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Plank + Refined - Fort Forinthry":
		script := "Plank + Refined"
		scriptinfo := "Cuts and refines the plank at the Fort."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Plank + Refined - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Plank Maker - Fort Forinthry":
		script := "Plank Maker"
		scriptinfo := "Cuts logs into planks using the sawmill at the Fort."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Plank Maker - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Potion Mixer":
		script := "Potion Mixer"
		scriptinfo := "Combines an inventory of ingredients to make potions."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Potion Mixer - Portables - Non-Walking":
		script := "Potion Mixer"
		scriptinfo := "Uses a Portable Well within (1) tile of a bank. Using the Portable Well, it will combine an inventory of ingredients to make potions."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Potion Mixer - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Potion Mixer - Portables - Walking":
		script := "Potion Mixer"
		scriptinfo := "Uses a Portable Well that is more than (1) tile from a bank and requires walking. Using the Portable Well, it will combine an inventory of ingredients to make potions."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Potion Mixer - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Prayer":
		script := "Prayer"
		scriptinfo := "Buries an inventory of bones or scatters an inventory of ashes. This is a bank-standing script and does not work with altars."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Bar - Normal":
		script := "Normal Protean"
		scriptinfo := "Crafts Normal Protean Bars, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Bar - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Bar - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Crafts Unstable Protean Bars, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Bar - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Cog - Normal":
		script := "Normal Protean"
		scriptinfo := "Processes Normal Protean Cogs, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Cog - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Cog - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Processes Unstable Protean Cogs, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Cog - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Essence - Normal":
		script := "Normal Protean"
		scriptinfo := "Crafts Normal Protean Essence, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Essence - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Essence - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Crafts Unstable Protean Essence, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Essence - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Hide - Normal":
		script := "Normal Protean"
		scriptinfo := "Crafts Normal Protean Hides, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Hide - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Hide - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Crafts Unstable Protean Hides, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Hide - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Logs - Fletch - Normal":
		script := "Normal Protean"
		scriptinfo := "Fletches Normal Protean Logs, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Logs - Fletch - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Logs - Fletch - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Fletches Unstable Protean Logs, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Logs - Fletch - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Logs - Fletch/Burn - Normal":
		script := "Normal Protean"
		scriptinfo := "Fletches && burns Normal Protean Logs, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Logs - Fletch/Burn - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Logs - Fletch/Burn - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Fletches && burns Unstable Protean Logs, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Logs - Fletch/Burn - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Memory - Normal":
		script := "Normal Protean"
		scriptinfo := "Converts Normal Protean Memories, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Memory - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Memory - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Converts Unstable Protean Memories, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Memory - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Plank - Normal":
		script := "Normal Protean"
		scriptinfo := "Processes Normal Protean Planks, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Plank - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Plank - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Processes Unstable Protean Planks, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Plank - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Protein - Normal":
		script := "Normal Protean"
		scriptinfo := "Cooks Normal Protean Protein, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Protein - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Protein - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Cooks Unstable Protean Protein, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Protein - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Shake - Normal":
		script := "Normal Protean"
		scriptinfo := "Processes Normal Protean Shakes, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Shake - Normal
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Shake - Unstable":
		script := "Unstable Protean"
		scriptinfo := "Processes Unstable Protean Shakes, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Protean Shake - Unstable
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Protean Trap":
		script := "Protean Trap"
		scriptinfo := "Sets Protean Traps and refreshes them based on a random timer, best used with Double XP events."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Pyre Crafter":
		script := "Pyre Crafter"
		scriptinfo := "Adds Sacred Oil to logs to craft Pyre Logs."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Refined Plank - Fort Forinthry":
		script := "Refined Planks"
		scriptinfo := "Refines planks at the sawmill so they can be used to make frames."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Refined Plank - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Rituals - Communion & Material - Focus Storage":
		script := "Rituals"
		scriptinfo := "Performs the Communion && Material ritual using the focus storage for material. Place materials for rituals into focus storage for this to work."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Communion && Material - Focus Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Rituals - Communion & Material - Without Storage":
		script := "Rituals"
		scriptinfo := "Performs the Communion && Material ritual using the player inventory for material. Keep materials in your inventory and do not use the focus storage."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Communion && Material - Without Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Rituals - Ectoplasm - Focus Storage":
		script := "Rituals"
		scriptinfo := "Performs the Ectoplasm ritual using the focus storage for material. Place materials for rituals into focus storage for this to work."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Ectoplasm - Focus Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Rituals - Ectoplasm - Without Storage":
		script := "Rituals"
		scriptinfo := "Performs the Ectoplasm ritual using the player inventory for material. Keep materials in your inventory and do not use the focus storage."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Ectoplasm - Without Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Rituals - Essence & Necroplasm - Focus Storage":
		script := "Rituals"
		scriptinfo := "Performs the Essence && Necroplasm ritual using the focus storage for material. Place materials for rituals into focus storage for this to work."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Essence && Necroplasm - Focus Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Rituals - Essence & Necroplasm - Without Storage":
		script := "Rituals"
		scriptinfo := "Performs the Essence && Necroplasm ritual using the player inventory for material. Keep materials in your inventory and do not use the focus storage."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Essence && Necroplasm - Without Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Sawmill - Portables - Non-Walking":
		script := "Sawmill"
		scriptinfo := "Uses a Portable Sawmill within (1) tile of a bank. With the Portable Sawmill, it will cut logs into planks."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Sawmill - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Sawmill - Portables - Walking":
		script := "Sawmill"
		scriptinfo := "it will tan various hides."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Sawmill - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Sift Soil - Lunar Spell":
		script := "Sift Soil"
		scriptinfo := "Uses the Lunar Spell Sift Soil to screen various soils."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Sift Soil - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		Case "Slime Collector":
		script := "Slime Collector"
		scriptinfo := "Collects Buckets of Slime and uses them on magic/enchanted notepaper to note them before collecting more slime."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Slime Collector
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Smithing":
		script := "Smithing"
		scriptinfo := "An underpowered smithing script best used for making arrowheads and dart tips. Can be used to smith any item, but does not currently support reheating the forge."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Stone Wall - Fort Forinthry":
		script := "Stone Wall"
		scriptinfo := "Turns limestone bricks into wall segments at the stonecutter in the Fort."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Stone Wall - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Tanning - Portables - Non-Walking":
		script := "Tanning"
		scriptinfo := "Uses a Portable Crafter within (1) tile of a bank. With the Portable Crafter, it will tan various hides."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Tanning - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Tanning - Portables - Walking":
		script := "Tanning"
		scriptinfo := "Uses a Portable Crafter that is more than (1) tile from a bank and requires walking. With the Portable Crafter, it will cut logs into planks."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Tanning - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Tele Grind - Lunar Spell - No Banking":
		script := "Tele Grind"
		scriptinfo := "Casts the Lunar Spell Telekinetic Grind to grind any eligible items in your inventory."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Tele Grind - Lunar Spell - No Banking
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Tele Grind - Lunar Spell - With Banking":
		script := "Tele Grind"
		scriptinfo := "Casts the Lunar Spell Telekinetic Grind to grind any eligible items in your inventory. Does not support banking, assumes items stack in inventory."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Tele Grind - Lunar Spell - With Banking
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Watchtower Shortcut":
		script := "Watchtower Shortcut"
		scriptinfo := "Runs laps of the Watchtower Shortcut. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Watchtower Shortcut
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Agility - Wilderness":
		script := "Wilderness"
		scriptinfo := "Runs laps of the Wilderness agility course. Can be tricky to configure coordinates due to large amounts of walking."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Wilderness
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Wine Maker":
		script := "Wine Maker"
		scriptinfo := "Combines jugs of water with grapes with make jugs of wine."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Beginner
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Flatpack Maker - Portables - Non-Walking":
		script := "Flatpack Maker"
		scriptinfo := "Uses a Portable Workbench within (1) tile of a bank. With the Portable Workbench, it will create various flatpacks."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Flatpack Maker - Portables - Non-Walking
		Gui Info: Font, s13 normal bold c0xCC5500
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Intermediate
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Flatpack Maker - Portables - Walking":
		script := "Flatpack Maker"
		scriptinfo := "Uses a Portable Workbench that is more than (1) tile from a bank and requires walking. With the Portable Workbench, it will create various flatpacks."
		GuiReset()
		GuiBorder()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Flatpack Maker - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Advanced
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
	}
	return
}

Select:
if A_GuiEvent = DoubleClick
GuiControlGet, selectedScript, , ScriptListBox
Switch selectedScript
{	
			Case "AFK Combat":
			script := "AFK Combat"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Alchemy":
			script := "Alchemy"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Amulet Stringer":
			script := "Amulet Stringer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Anti-AFK":
			script := "Anti-AFK"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Armour Crafter - Portables - Walking":
			script := "Armour Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\crafting\Armour Crafter\Armour Crafter - With Walking
			Run, %script%.ahk
			Goto exit
			
			Case "Armour Crafter - Portables - Non-Walking":
			script := "Armour Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\crafting\Armour Crafter\Armour Crafter - No Walking
			Run, %script%.ahk
			Goto exit
			
			Case "Armour Crafter":
			script := "Armour Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Arrow Fletcher":
			script := "Arrow Fletcher"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Ash 2 Incense":
			script := "Ash 2 Incense"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Incense\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "AutoClicker":
			script := "AutoClicker"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Misc\Autoclicker
			Run, %script%.ahk
			Goto exit
			
			Case "AutoTele":
			script := "AutoTele"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Bake Pie - Lunar Spell":
			script := "Bake Pie"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Lunar Spells\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Bar Smelter":
			script := "Bar Smelter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Bar Smelter - Smelting Gloves":
			script := "Smelting Glove"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Bar Smelter
			Run, %script%.ahk
			Goto exit
			
			Case "Agility - Barbarian - Advanced":
			script := "Barbarian Course"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\agility\Barbarian\Advanced
			Run, %script%.ahk
			Goto exit
			
			Case "Agility - Barbarian - Basic":
			script := "Barbarian Course"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\agility\Barbarian\Basic
			Run, %script%.ahk
			Goto exit
			
			Case "Bones 2 Bananas":
			script := "Bones 2 Bananas"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Bow Cutter":
			script := "Bow Cutter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Bow Cutter - Portables - Walking":
			script := "Bow Cutter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\fletching\Bow Cutter - With Walking
			Run, %script%.ahk
			Goto exit
			
			Case "Bow Cutter - Portables - Non-Walking":
			script := "Bow Cutter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\fletching\Bow Cutter - No Walking
			Run, %script%.ahk
			Goto exit
			
			Case "Bow Stringer":
			script := "Bow Stringer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Bow Stringer - Portables - Walking":
			script := "Bow Stringer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\fletching\Bow Stringer - With Walking
			Run, %script%.ahk
			Goto exit
			
			Case "Bow Stringer - Portables - Non-Walking":
			script := "Bow Stringer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\fletching\Bow Stringer - No Walking
			Run, %script%.ahk
			Goto exit
			
			Case "Brick Maker - Fort Forinthry":
			script := "Limestone Brick"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\Limestone Brick
			Run, Brick Maker.ahk
			Goto exit
			
			Case "Agility - Burthrope":
			script := "Burthorpe"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Agility\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Candle Crafter":
			script := "Candle Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Necromancy\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Cape Cleaner - Herblore (Skillcape Perk)":
			script := "Cape Cleaner"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Herb Cleaner
			Run, %script%.ahk
			Goto exit
			
			Case "Clay Fire - Portables - Non-Walking":
			script := "Clay Fire"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\crafting\clay\clay fire\clay fire - no walking
			Run, %script%.ahk
			Goto exit
			
			Case "Clay Fire - Portables - Walking":
			script := "Clay Fire"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\crafting\clay\clay fire\clay fire - with walking
			Run, %script%.ahk
			Goto exit
			
			Case "Clay Form - Portables - Non-Walking":
			script := "Clay Form"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\crafting\clay\clay Form\clay Form - no walking
			Run, %script%.ahk
			Goto exit
			
			Case "Clay Form - Portables - Walking":
			script := "Clay Form"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\crafting\clay\clay Form\clay Form - with walking
			Run, %script%.ahk
			Goto exit
			
			Case "Cooking - Burthorpe":
			script := "Cooking"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Cooking - Fort Forinthry":
			script := "Cooking"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Cooking - Portables - Non-Walking":
			script := "Cooking"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\cooking\cooking - no walking
			Run, %script%.ahk
			Goto exit
			
			Case "Cooking - Portables - Walking":
			script := "Cooking"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\cooking\cooking - with walking
			Run, %script%.ahk
			Goto exit
			
			Case "Decoration Maker":
			script := "Decoration Maker"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Events\2023\Christmas\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Fire + Form - Portables":
			script := "Fire + Form"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\crafting\clay\fire + form
			Run, %script%.ahk
			Goto exit
			
			Case "Fire Urn - Lunar Spell":
			script := "Fire Urn"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\lunar spells\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Firemaking - Portables - Non-Walking":
			script := "Firemaking"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Firemaking\Firemaking - no walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Firemaking - Portables - Walking":
			script := "Firemaking"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Firemaking\Firemaking - with walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Frame Maker - Fort Forinthry":
			script := "Frame Maker"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Gem Cutter":
			script := "Gem Cutter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Gem Cutter - Portables - Non-Walking":
			script := "Gem Cutter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Crafting\Gem Cutter\Gem Cutter - no walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Gem Cutter - Portables - Walking":
			script := "Gem Cutter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Crafting\Gem Cutter\Gem Cutter - with walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Glassblowing":
			script := "Glassblowing"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Agility - Gnome - Advanced":
			script := "Gnome Course"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\agility\Gnome\Advanced\
			Run, %script%.ahk
			Goto exit
			
			Case "Agility - Gnome - Basic":
			script := "Gnome Course"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\agility\Gnome\Basic\
			Run, %script%.ahk
			Goto exit
			
			Case "Herb 2 Incense":
			script := "Herb 2 Incense"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Incense\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Herb Cleaner":
			script := "Herb Cleaner"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Agility - Het's Oasis":
			script := "Het's Oasis"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\agility\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Incense Crafter":
			script := "Incense Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Incense\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Ink Crafter":
			script := "Ink Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Necromancy\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Jewellery Crafter - Lumbridge":
			script := "Jewellery Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Jewellery Crafter - Fort Forinthry":
			script := "Jewellery Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Jewellery Enchanter":
			script := "Jewel Enchant"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Jewellery Enchant
			Run, %script%.ahk
			Goto exit
			
			Case "Jewellery Stringer - Lunar Spell":
			script := "String Jewellery"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\lunar spells\%script%
			Run, Jewel Stringer.ahk
			Goto exit
			
			Case "Plank + Refined - Fort Forinthry":
			script := "Plank + Refined"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Plank Maker - Fort Forinthry":
			script := "Plank Maker"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Potion Mixer":
			script := "Potion Mixer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Potion Mixer - Portables - Non-Walking":
			script := "Potion Mixer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Herblore\Potion Mixer - no walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Potion Mixer - Portables - Walking":
			script := "Potion Mixer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Herblore\Potion Mixer - with walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Prayer":
			script := "Prayer"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Bar - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean bar
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Bar - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean bar
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Cog - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Cog
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Cog - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Cog
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Essence - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Essence
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Essence - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Essence
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Hide - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Hide
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Hide - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Hide
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Logs - Fletch - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean logs\fletch
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Logs - Fletch - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean logs\fletch
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Logs - Fletch/Burn - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean logs\fletch & burn
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Logs - Fletch/Burn - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean logs\fletch & burn
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Memory - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Memory
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Memory - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Memory
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Plank - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Plank
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Plank - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Plank
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Protein - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Protein
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Protein - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Protein
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Shake - Normal":
			script := "Normal Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Shake
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Shake - Unstable":
			script := "Unstable Protean"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\protean Shake
			Run, %script%.ahk
			Goto exit
			
			Case "Protean Trap":
			script := "Protean Trap"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\protean\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Pyre Crafter":
			script := "Pyre Crafter"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Refined Plank - Fort Forinthry":
			script := "Refined Planks"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Rituals - Communion & Material - Focus Storage":
			script := "Rituals"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\\Necromancy\%script%\Communion & Material\Focus Storage
			Run, %script%.ahk
			Goto exit
			
			Case "Rituals - Communion & Material - Without Storage":
			script := "Rituals"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\\Necromancy\%script%\Communion & Material\Without Focus Storage
			Run, %script%.ahk
			Goto exit
			
			Case "Rituals - Ectoplasm - Focus Storage":
			script := "Rituals"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\\Necromancy\%script%\Ectoplasm\Focus Storage
			Run, %script%.ahk
			Goto exit
			
			Case "Rituals - Ectoplasm - Without Storage":
			script := "Rituals"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\\Necromancy\%script%\Ectoplasm\Without Focus Storage
			Run, %script%.ahk
			Goto exit
			
			Case "Rituals - Essence & Necroplasm - Focus Storage":
			script := "Rituals"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\\Necromancy\%script%\Essence & Necroplasm\Focus Storage
			Run, %script%.ahk
			Goto exit
			
			Case "Rituals - Essence & Necroplasm - Without Storage":
			script := "Rituals"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\\Necromancy\%script%\Essence & Necroplasm\Without Focus Storage
			Run, %script%.ahk
			Goto exit
			
			Case "Sawmill - Portables - Non-Walking":
			script := "Sawmill"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Sawmill\Sawmill - no walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Sawmill - Portables - Walking":
			script := "Sawmill"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Sawmill\Sawmill - with walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Sift Soil - Lunar Spell":
			script := "Sift Soil"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Lunar Spells\%script%\
			Run, %script%.ahk
			Goto exit
			
			Case "Slime Collector":
			script := "Slime Collector"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Necromancy\Slime Collector - Notepaper\
			Run, %script%.ahk
			Goto exit
			
			Case "Smithing":
			script := "Smithing"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Stone Wall - Fort Forinthry":
			script := "Stone Wall"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Fort Forinthry\%script%\
			Run, %script%.ahk
			Goto exit
			
			Case "Tanning - Portables - Non-Walking":
			script := "Tanning"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Crafting\Tanning\Tanning - no walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Tanning - Portables - Walking":
			script := "Tanning"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Crafting\Tanning\Tanning - with walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Tele Grind - Lunar Spell - No Banking":
			script := "Tele Grind"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Lunar Spells\Telekinetic Grind\Telekinetic Grind with No Banking\
			Run, %script%.ahk
			Goto exit
			
			Case "Tele Grind - Lunar Spell - With Banking":
			script := "Tele Grind"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\Lunar Spells\Telekinetic Grind\Telekinetic Grind with Banking\
			Run, %script%.ahk
			Goto exit
			
			Case "Agility - Watchtower Shortcut":
			script := "Watchtower Shortcut"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\agility\%script%\
			Run, watchtower.ahk
			Goto exit
			
			Case "Agility - Wilderness":
			script := "Wilderness"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\agility\%script%\
			Run, %script%.ahk
			Goto exit
			
			Case "Wine Maker":
			script := "Wine Maker"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\%script%
			Run, %script%.ahk
			Goto exit
			
			Case "Flatpack Maker - Portables - Non-Walking":
			script := "Flatpack Maker"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Construction\Flatpack Maker - no walking\
			Run, %script%.ahk
			Goto exit
			
			Case "Flatpack Maker - Portables - Walking":
			script := "Flatpack Maker"
			Gui destroy
			SetWorkingDir, %A_ScriptDir%\portables\Construction\Flatpack Maker - with walking\
			Run, %script%.ahk
			Goto exit
		}
	Return
	
	Clear:
	GuiReset()
	GuiControl, Choose, ScriptListBox, 1
	GuiControl, Choose, ScriptListBox, 0
	GuiControl, Focus, ScriptListBox
	return
	
	Exit:
	GuiClose:
	ExitApp
	
	GitLink:
	run, https://github.com/Gubna-Tech/RuneScape
	Exitapp
	
	DiscordError:
	Run, https://discord.gg/Wmmf65myPG
	Exitapp
	
	CloseError:	
	ExitApp
