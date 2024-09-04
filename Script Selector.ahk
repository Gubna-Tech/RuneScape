#SingleInstance Force
#Persistent
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

SetWorkingDir, %A_ScriptDir%

Hotkey, enter, Select
Hotkey, esc, Exit

Gui +LastFound +OwnDialogs +AlwaysOnTop
Gui Font, s12 Bold cBlue
Gui -caption
Menu Tray, NoIcon
Gui  Add, Text, Center w410 x5,Choose a script below and press`n"Select Script"
Gui Font, cGreen
Gui  Add, Text, Center w410 x5,Total Scripts: %ScriptTotal%
Gui Font, s11 Bold cBlack
Gui Add, ListBox, vScriptListBox gDoubleClick x12 w395 r15

Loop, read, ScriptList.ini
{
    section := A_LoopReadLine
    GuiControl,, ScriptListBox, %section%
}

Gui, Add, Button, gSelect w115 x152 center, Select Script
Gui Add, Button, gExit w115 x152 center, Close Selector
WinSet, ExStyle, ^0x80
Gui, Show, w420 h425 center, Script Selector

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

DoubleClick:
if A_GuiEvent = DoubleClick
Select:
GuiControlGet, selectedScript, , ScriptListBox
Switch selectedScript
{
	Case "AFK Combat":
	script := "AFK Combat"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send afk{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Alchemy":
	script := "Alchemy"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send alc{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Amulet Stringer":
	script := "Amulet Stringer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send amu{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Anti-AFK":
	script := "Anti-AFK"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send anti{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Armour Crafter - Portables - Walking":
	script := "Armour Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\crafting\Armour Crafter\Armour Crafter - With Walking
	WinWait %script%
	sleep 1500
	send arm{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Armour Crafter - Portables - Non-Walking":
	script := "Armour Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\crafting\Armour Crafter\Armour Crafter - No Walking
	WinWait %script%
	sleep 1500
	send arm{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Armour Crafter":
	script := "Armour Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send arm{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Arrow Fletcher":
	script := "Arrow Fletcher"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send arr{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Ash 2 Incense":
	script := "Ash 2 Incense"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\incense\%script%\
	WinWait %script%
	sleep 1500
	send ash{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "AutoClicker":
	script := "AutoClicker"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\misc\%script%\
	WinWait %script%
	sleep 1500
	send aut{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "AutoTele":
	script := "AutoTele"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send aut{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bake Pie - Lunar Spell":
	script := "Bake Pie"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Lunar Spells\%script%\
	WinWait %script%
	sleep 1500
	send bak{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bar Smelter":
	script := "Bar Smelter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send bar{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bar Smelter - Smelting Gloves":
	script := "Bar Smelter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Bar Smelter
	WinWait %script%
	sleep 1500
	send sme{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Barbarian Course - Advanced":
	script := "Advanced"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\Barbarian\Advanced\
	WinWait %script%
	sleep 1500
	send bar{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Barbarian Course - Basic":
	script := "Basic"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\Barbarian\Basic\
	WinWait %script%
	sleep 1500
	send bar{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bones 2 Bananas":
	script := "Bones 2 Bananas"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send bon{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bow Cutter":
	script := "Bow Cutter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send bow{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bow Cutter - Portables - Non-Walking":
	script := "Bow Cutter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\fletching\bow cutter - no walking\
	WinWait %script%
	sleep 1500
	send bow{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bow Cutter - Portables - Walking":
	script := "Bow Cutter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\fletching\bow cutter - with walking\
	WinWait %script%
	sleep 1500
	send bow{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bow Stringer":
	script := "Bow Stringer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send bow{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bow Stringer - Portables - Non-Walking":
	script := "Bow Stringer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\fletching\bow stringer - no walking\
	WinWait %script%
	sleep 1500
	send bow{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Bow Stringer - Portables - Walking":
	script := "Bow Stringer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\fletching\bow stringer - with walking\
	WinWait %script%
	sleep 1500
	send bow{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Brick Maker - Fort Forinthry":
	script := "Limestone Brick"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\Limestone Brick
	WinWait %script%
	sleep 1500
	send bri{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Burthrope Agility":
	script := "Burthorpe"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\%script%\
	WinWait %script%
	sleep 1500
	send bur{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Candle Crafter":
	script := "Candle Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\necromancy\%script%\
	WinWait %script%
	sleep 1500
	send can{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Cape Cleaner - Herblore (Skillcape Perk)":
	script := "Herb Cleaner"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\herb cleaner\
	WinWait %script%
	sleep 1500
	send cap{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Clay Fire - Portables - Non-Walking":
	script := "Clay Fire"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\crafting\clay\clay fire\clay fire - no walking\
	WinWait %script%
	sleep 1500
	send cla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Clay Fire - Portables - Walking":
	script := "Clay Fire"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\crafting\clay\clay fire\clay fire - with walking\
	WinWait %script%
	sleep 1500
	send cla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Clay Form - Portables - Non-Walking":
	script := "Clay Form"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\crafting\clay\clay Form\clay Form - no walking\
	WinWait %script%
	sleep 1500
	send cla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Clay Form - Portables - Walking":
	script := "Clay Form"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\crafting\clay\clay Form\clay Form - with walking\
	WinWait %script%
	sleep 1500
	send cla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Cooking - Burthorpe":
	script := "Cooking"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send coo{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Cooking - Fort Forinthry":
	script := "Cooking"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\Cooking\
	WinWait %script%
	sleep 1500
	send Coo{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Cooking - Portables - Non-Walking":
	script := "Cooking"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Cooking\Cooking - no walking\
	WinWait %script%
	sleep 1500
	send coo{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Cooking - Portables - Walking":
	script := "Cooking"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Cooking\Cooking - with walking\
	WinWait %script%
	sleep 1500
	send coo{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Decoration Maker":
	script := "Decoration Maker"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Events\2023\Christmas\%script%\
	WinWait %script%
	sleep 1500
	send dec{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Fire + Form - Portables":
	script := "Fire + Form"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Crafting\Clay\%script%\
	WinWait %script%
	sleep 1500
	send fir{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Fire Urn - Lunar Spell":
	script := "Fire Urn"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Lunar Spells\%script%\
	WinWait %script%
	sleep 1500
	send fir{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Firemaking - Portables - Non-Walking":
	script := "Firemaking"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Firemaking\Firemaking - no walking\
	WinWait %script%
	sleep 1500
	send fir{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Firemaking - Portables - Walking":
	script := "Firemaking"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Firemaking\Firemaking - with walking\
	WinWait %script%
	sleep 1500
	send fir{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Frame Maker - Fort Forinthry":
	script := "Frame Maker"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\%script%\
	WinWait %script%
	sleep 1500
	send fra{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Gem Cutter":
	script := "Gem Cutter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send gem{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Gem Cutter - Portables - Non-Walking":
	script := "Gem Cutter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Crafting\Gem Cutter\Gem Cutter - no walking\
	WinWait %script%
	sleep 1500
	send gem{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Gem Cutter - Portables - Walking":
	script := "Gem Cutter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Crafting\Gem Cutter\Gem Cutter - with walking\
	WinWait %script%
	sleep 1500
	send gem{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Glassblowing":
	script := "Glassblowing"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send gla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Gnome Course - Advanced":
	script := "Advanced"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\Gnome\Advanced\
	WinWait %script%
	sleep 1500
	send gno{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Gnome Course - Basic":
	script := "Basic"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\Gnome\Basic\
	WinWait %script%
	sleep 1500
	send gno{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Herb 2 Incense":
	script := "Herb 2 Incense"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\incense\%script%\
	WinWait %script%
	sleep 1500
	send her{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Herb Cleaner":
	script := "Herb Cleaner"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send her{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Het's Oasis":
	script := "Het's Oasis"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\%script%\
	WinWait %script%
	sleep 1500
	send het{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Incense Crafter":
	script := "Incense Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Incense\%script%\
	WinWait %script%
	sleep 1500
	send inc{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Ink Crafter":
	script := "Ink Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\%script%\
	WinWait %script%
	sleep 1500
	send ink{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Jewellery Crafter - Lumbridge":
	script := "Jewellery Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send jew{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Jewellery Crafter - Fort Forinthry":
	script := "Jewellery Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\%script%\
	WinWait %script%
	sleep 1500
	send jew{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Jewellery Enchanter":
	script := "Jewellery Enchant"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send jew{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Jewellery Stringer - Lunar Spell":
	script := "String Jewellery"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Lunar Spells\%script%\
	WinWait %script%
	sleep 1500
	send jew{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Plank + Refined - Fort Forinthry":
	script := "Plank + Refined"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\%script%\
	WinWait %script%
	sleep 1500
	send pla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Plank Maker - Fort Forinthry":
	script := "Plank Maker"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\%script%\
	WinWait %script%
	sleep 1500
	send pla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Potion Mixer":
	script := "Potion Mixer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send pot{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Potion Mixer - Portables - Non-Walking":
	script := "Potion Mixer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Herblore\Potion Mixer - no walking\
	WinWait %script%
	sleep 1500
	send pot{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Potion Mixer - Portables - Walking":
	script := "Potion Mixer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Herblore\Potion Mixer - with walking\
	WinWait %script%
	sleep 1500
	send pot{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Prayer":
	script := "Prayer"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send pra{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Protean Bar - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Bar
	WinWait Protean Bar
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Bar
	exitapp
	
	Case "Protean Bar - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Bar
	WinWait Protean Bar
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Bar
	exitapp
	
	Case "Protean Cog - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Cog
	WinWait Protean Cog
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Cog
	exitapp
	
	Case "Protean Cog - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Cog
	WinWait Protean Cog
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Cog
	exitapp
	
	Case "Protean Essence - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Essence
	WinWait Protean Essence
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Essence
	exitapp
	
	Case "Protean Essence - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Essence
	WinWait Protean Essence
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Essence
	exitapp
	
	Case "Protean Hide - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Hide
	WinWait Protean Hide
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Hide
	exitapp
	
	Case "Protean Hide - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Hide
	WinWait Protean Hide
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Hide
	exitapp
	
	Case "Protean Logs - Fletch - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Logs\Fletch
	WinWait Fletch
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Fletch
	exitapp
	
	Case "Protean Logs - Fletch - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Logs\Fletch
	WinWait Fletch
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Fletch
	exitapp
	
	Case "Protean Logs - Fletch/Burn - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Logs\Fletch & Burn
	WinWait Fletch & Burn
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Fletch & Burn
	exitapp
	
	Case "Protean Logs - Fletch/Burn - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Logs\Fletch & Burn
	WinWait Fletch & Burn
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Fletch & Burn
	exitapp
	
	Case "Protean Memory - Normal":
	script := "Protean Memory"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Memory
	WinWait %script%
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Memory
	exitapp
	
	Case "Protean Memory - Unstable":
	script := "Protean Memory"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Memory
	WinWait %script%
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Memory
	exitapp
	
	Case "Protean Plank - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Plank
	WinWait Protean Plank
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Plank
	exitapp
	
	Case "Protean Plank - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Plank
	WinWait Protean Plank
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Plank
	exitapp
	
	Case "Protean Protein - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Protein
	WinWait Protean Protein
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Protein
	exitapp
	
	Case "Protean Protein - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Protein
	WinWait Protean Protein
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Protein
	exitapp
	
	Case "Protean Shake - Normal":
	script := "Normal Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Shake
	WinWait Protean Shake
	sleep 1500
	send nor{enter}
	winwait LLARS
	winclose Protean Shake
	exitapp
	
	Case "Protean Shake - Unstable":
	script := "Unstable Protean"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\Protean Shake
	WinWait Protean Shake
	sleep 1500
	send uns{enter}
	winwait LLARS
	winclose Protean Shake
	exitapp
	
	Case "Protean Trap":
	script := "Protean Trap"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Protean\%script%\
	WinWait %script%
	sleep 1500
	send pro{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Pyre Crafter":
	script := "Pyre Crafter"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send pyr{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Refined Plank - Fort Forinthry":
	script := "Refined Planks"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\%script%\
	WinWait %script%
	sleep 1500
	send ref{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Rituals - Communion & Material - Focus Storage":
	script := "Rituals"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\%script%\Communion & Material\Focus Storage
	WinWait Focus Storage
	sleep 1500
	send rit{enter}
	winwait LLARS
	winclose Focus Storage
	exitapp
	
	Case "Rituals - Communion & Material - Without Storage":
	script := "Rituals"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\%script%\Communion & Material\Without Focus Storage
	WinWait Without Focus Storage
	sleep 1500
	send rit{enter}
	winwait LLARS
	winclose Without Focus Storage
	exitapp
	
	Case "Rituals - Ectoplasm - Focus Storage":
	script := "Rituals"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\%script%\Ectoplasm\Focus Storage
	WinWait Focus Storage
	sleep 1500
	send rit{enter}
	winwait LLARS
	winclose Focus Storage
	exitapp
	
	Case "Rituals - Ectoplasm - Without Storage":
	script := "Rituals"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\%script%\Ectoplasm\Without Focus Storage
	WinWait Without Focus Storage
	sleep 1500
	send rit{enter}
	winwait LLARS
	winclose Without Focus Storage
	exitapp
	
	Case "Rituals - Essence & Necroplasm - Focus Storage":
	script := "Rituals"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\%script%\Essence & Necroplasm\Focus Storage
	WinWait Focus Storage
	sleep 1500
	send rit{enter}
	winwait LLARS
	winclose Focus Storage
	exitapp
	
	Case "Rituals - Essence & Necroplasm - Without Storage":
	script := "Rituals"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\%script%\Essence & Necroplasm\Without Focus Storage
	WinWait Without Focus Storage
	sleep 1500
	send rit{enter}
	winwait LLARS
	winclose Without Focus Storage
	exitapp
	
	Case "Sawmill - Portables - Non-Walking":
	script := "Sawmill"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Sawmill\Sawmill - no walking\
	WinWait %script%
	sleep 1500
	send saw{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Sawmill - Portables - Walking":
	script := "Sawmill"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Sawmill\Sawmill - with walking\
	WinWait %script%
	sleep 1500
	send saw{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Sift Soil - Lunar Spell":
	script := "Sift Soil"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Lunar Spells\%script%\
	WinWait %script%
	sleep 1500
	send sif{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Slime Collector":
	script := "Slime Collector"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Necromancy\Slime Collector - Notepaper\
	WinWait Slime Collector - Notepaper
	sleep 1500
	send sli{enter}
	winwait LLARS
	winclose Slime Collector - Notepaper
	exitapp
	
	Case "Smithing":
	script := "Smithing"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send smi{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Stone Wall - Fort Forinthry":
	script := "Stone Wall"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Fort Forinthry\%script%\
	WinWait %script%
	sleep 1500
	send sto{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Tanning - Portables - Non-Walking":
	script := "Tanning"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Crafting\Tanning\Tanning - no walking\
	WinWait %script%
	sleep 1500
	send tan{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Tanning - Portables - Walking":
	script := "Tanning"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Crafting\Tanning\Tanning - with walking\
	WinWait %script%
	sleep 1500
	send tan{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Tele Grind - Lunar Spell - No Banking":
	script := "Tele Grind"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Lunar Spells\Telekinetic Grind\Telekinetic Grind with No Banking\
	WinWait Telekinetic Grind with No Banking
	sleep 1500
	send tel{enter}
	winwait LLARS
	winclose Telekinetic Grind with No Banking
	exitapp
	
	Case "Tele Grind - Lunar Spell - With Banking":
	script := "Tele Grind"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\Lunar Spells\Telekinetic Grind\Telekinetic Grind with Banking\
	WinWait Telekinetic Grind with Banking
	sleep 1500
	send tel{enter}
	winwait LLARS
	winclose Telekinetic Grind with Banking
	exitapp
	
	Case "Watchtower Shortcut":
	script := "Watchtower Shortcut"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\%script%\
	WinWait %script%
	sleep 1500
	send wat{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Wilderness Course":
	script := "Wilderness"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\agility\%script%\
	WinWait %script%
	sleep 1500
	send wil{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Wine Maker":
	script := "Wine Maker"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\%script%\
	WinWait %script%
	sleep 1500
	send win{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Flatpack Maker - Portables - Non-Walking":
	script := "Flatpack Maker"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Construction\Flatpack Maker - no walking\
	WinWait %script%
	sleep 1500
	send fla{enter}
	winwait LLARS
	winclose %script%
	exitapp
	
	Case "Flatpack Maker - Portables - Walking":
	script := "Flatpack Maker"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%
	Run, %A_ScriptDir%\portables\Construction\Flatpack Maker - with walking\
	WinWait %script%
	sleep 1500
	send fla{enter}
	winwait LLARS
	winclose %script%
	exitapp
}
Return

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