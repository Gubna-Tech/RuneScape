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

Hotkey, enter, Select
Hotkey, esc, Exit

Gui +LastFound +OwnDialogs +AlwaysOnTop
Gui Font, s12 Bold cBlue
Gui -caption
Menu Tray, NoIcon
Gui  Add, Text, Center w410 x5,Select a script from the list below and`n click 'Select Script' or press Enter
Gui Font, cGreen
Gui  Add, Text, Center w410 x5,Total Scripts: %ScriptTotal%
Gui Font, s11 Bold cBlack
Gui Add, ListBox, sort vScriptListBox gDoubleClick x12 w395 r15

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
	
	Case "Barbarian Course - Advanced":
	script := "Barbarian Course"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%\agility\Barbarian\Advanced
	Run, %script%.ahk
	Goto exit
	
	Case "Barbarian Course - Basic":
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
	
	Case "Burthrope Agility":
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
	
	Case "Gnome Course - Advanced":
	script := "Gnome Course"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%\agility\Gnome\Advanced\
	Run, %script%.ahk
	Goto exit
	
	Case "Gnome Course - Basic":
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
	
	Case "Het's Oasis":
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
	
	Case "Watchtower Shortcut":
	script := "Watchtower Shortcut"
	Gui destroy
	SetWorkingDir, %A_ScriptDir%\agility\%script%\
	Run, watchtower.ahk
	Goto exit
	
	Case "Wilderness Course":
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