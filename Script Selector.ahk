#Requires AutoHotkey v1.1.37.02

; Confirms the complete LLARS project structure is available before the
; Script Selector attempts to use project folders or launch scripts.
if (!FileExist(A_ScriptDir . "\Core")
|| !FileExist(A_ScriptDir . "\Scripts")
|| !FileExist(A_ScriptDir . "\LLARS Config.ini"))
{
	Menu, Tray, NoIcon

	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5, ERROR
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, LLARS Project Files Missing
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Font, cBlack
	Gui Error: Add, Text, Center w220 x5, The complete LLARS project could not be found.
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Add, Text, Center w220 x5, If you opened this file from a ZIP, RAR, or 7Z archive, extract the entire LLARS folder before running it.
	Gui Error: Font, s11 norm Bold c0x152039
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Add, Text, Center w220 x5, Created by Gubna
	Gui Error: Add, Button, gDiscordError w150 x40 Center, Discord
	Gui Error: Add, Button, gCloseError w150 x40 Center, Close Error

	WinSet, ExStyle, ^0x80

	Gui Error: -caption
	Gui Error: Show, Center w230, File Error

	return
}

; =======================================================================
; |     LLARS PATH SETUP     -     LLARS PATH SETUP                     |
; =======================================================================

; Root folder containing all selectable LLARS scripts.
LLARS_SCRIPTS_DIR := A_ScriptDir . "\Scripts"

CloseOtherLLARS()

; ===================================================================
; |     ARRAY SETUP     -     ARRAY SETUP     -     ARRAY SETUP     |
; ===================================================================

; List of available scripts.
scriptArray := "AFK Combat|Alchemy|Amulet Stringer|Anti-AFK|Armour Crafter|Armour Crafter - Portables - Non-Walking|Arrow Fletcher|Ash to Incense|AutoClicker|AutoTele|Bake Pie - Lunar Spell|Bar Smelter|Bar Smelter - Smelting Gloves|Agility - Barbarian - Advanced|Agility - Barbarian - Basic|Bones 2 Bananas|Bow Cutter|Bow Cutter - Portables - Non-Walking|Bow Cutter - Portables - Walking|Bow Stringer|Bow Stringer - Portables - Non-Walking|Bow Stringer - Portables - Walking|Brick Maker - Fort Forinthry|Agility - Burthrope|Candle Crafter|Herb Cleaner - Skillcape|Clay Fire - Portables - Non-Walking|Clay Fire - Portables - Walking|Clay Form - Portables - Non-Walking|Clay Form - Portables - Walking|Cooking - Burthorpe|Cooking - Fort Forinthry|Cooking - Portables - Non-Walking|Cooking - Portables - Walking|Fire + Form - Portables|Fire Urn - Lunar Spell|Firemaking - Portables - Non-Walking|Firemaking - Portables - Walking|Frame Maker - Fort Forinthry|Gem Cutter|Gem Cutter - Portables - Non-Walking|Gem Cutter - Portables - Walking|Glassblowing|Agility - Gnome - Advanced|Agility - Gnome - Basic|Herb to Incense|Herb Cleaner|Agility - Het's Oasis|Incense Crafter|Ink Crafter|Jewellery Crafter - Lumbridge|Jewellery Crafter - Fort Forinthry|Jewellery Enchanter|Jewellery Stringer - Lunar Spell|Plank + Refined - Fort Forinthry|Plank Maker - Fort Forinthry|Potion Mixer|Potion Mixer - Portables - Non-Walking|Potion Mixer - Portables - Walking|Prayer|Pyre Crafter|Refined Plank - Fort Forinthry|Rituals - Communion & Material - Focus Storage|Rituals - Communion & Material - Without Storage|Rituals - Ectoplasm - Focus Storage|Rituals - Ectoplasm - Without Storage|Rituals - Essence & Necroplasm - Focus Storage|Rituals - Essence & Necroplasm - Without Storage|Sawmill - Portables - Non-Walking|Sawmill - Portables - Walking|Sift Soil - Lunar Spell|Slime Collector|Smithing|Stone Wall - Fort Forinthry|Tanning - Portables - Non-Walking|Tanning - Portables - Walking|Tele Grind - Lunar Spell - No Banking|Tele Grind - Lunar Spell - With Banking|Agility - Watchtower Shortcut|Agility - Wilderness|Wine Maker|Contract Binding|Fletching - Corrupted Magic Logs|Prifddinas - Cooking|Prifddinas - Firemaking|Spinning Wheel - Fort Forinthry|Spinning Wheel - Fungal Bowstring - Fort Forinthry|Disassembly - Invention|Sharp Shell Burning|Archaeology - Excavate|Croesus Front|Eternal Tree|Waterfall Fishing"

; Calculates the total number of scripts.
ScriptTotal := StrSplit(scriptArray, "|").Length()

; ======================================================================
; |     HOTKEY SETUP     -     HOTKEY SETUP     -     HOTKEY SETUP     |
; ======================================================================

; Enter selects the highlighted script.
Hotkey, Enter, Select

; Escape closes the selector.
Hotkey, Esc, Exit

; =====================================================================================
; |     MAIN GUI CREATION     -     MAIN GUI CREATION     -     MAIN GUI CREATION     |
; =====================================================================================

; Creates the script selector GUI.
Gui +LastFound +OwnDialogs +AlwaysOnTop -caption
Gui, Font, s12 Bold cBlue
Gui, Add, Text, Center w410 x5, Select a script from the list below and`n click 'Select Script' or press Enter
Gui, Font, cGreen
Gui, Add, Text, Center w410 x5 vTS, Total Scripts: %ScriptTotal%
Gui, Font, s11 Bold cBlack
Gui, Add, ListBox, Sort vScriptListBox gScriptSelect x12 w395 r15, %scriptArray%
Gui, Add, Button, gSelect w120 x150 Center, Select Script
Gui, Add, Button, gClear w120 x150 Center, Clear Selection
Gui, Add, Button, gExit w120 x150 Center, Close Selector
Gui, Show, w420 h460 Center, Script Selector
WinSet, ExStyle, ^0x80

; ==================================================================================
; |     FUNCTION STORAGE     -     FUNCTION STORAGE     -     FUNCTION STORAGE     |
; ==================================================================================

; Registers Windows message handlers used to keep the custom LLARS
; windows movable and to monitor window position changes.
OnMessage(0x0047, "WM_WINDOWPOSCHANGED")
OnMessage(0x0201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN() {
	If (A_Gui)
		PostMessage, 0xA1, 2
}
WM_WINDOWPOSCHANGED() {
	CheckPOS()
}

; Keeps supported LLARS windows inside the visible screen area when
; their position changes or they are moved partially off-screen.
CheckPOS()
{
	IfWinNotActive, LLARS
	return
	
	WinGetPos, GUIx, GUIy, GUIw, GUIh, LLARS
	
	xmin := GUIx
	xmax := GUIw + GUIx
	ymin := GUIy
	ymax := GUIh + GUIy
	xadj := A_ScreenWidth - GUIw
	yadj := A_ScreenHeight - GUIh
	
	X := GUIx
	Y := GUIy
	
	if (xmin < 0)
		X := 0
	if (ymin < 0)
		Y := 0
	if (xmax > A_ScreenWidth)
		X := xadj
	if (ymax > A_ScreenHeight)
		Y := yadj
	
	if (X != GUIx || Y != GUIy)
		WinMove, LLARS,, X, Y
}

; Finds existing LLARS AutoHotkey windows and closes them
; to prevent multiple active LLARS instances from running simultaneously.
CloseOtherLLARS()
{
	WinGet, hWndList, List, LLARS
	WinGet, hWndList2, List, Script Selector
	
	Loop, %hWndList%
	{
		hWnd := hWndList%A_Index%
		
		WinGet, processName, ProcessName, ahk_id %hWnd%
		
		if (processName = "AutoHotkey.exe" || processName = "AutoHotkeyU64.exe" || processName = "AutoHotkeyU32.exe")
		{
			WinClose, % "ahk_id " hWnd
		}
	}
	
	Loop, %hWndList2%
	{
		hWnd := hWndList2%A_Index%
		
		WinGet, processName, ProcessName, ahk_id %hWnd%
		
		if (processName = "AutoHotkey.exe" || processName = "AutoHotkeyU64.exe" || processName = "AutoHotkeyU32.exe")
		{
			WinClose, % "ahk_id " hWnd
		}
	}
}

GuiBalance()
{
	; Get the heights of the two GUIs.
	WinGetPos,,,, bottomH, BottomGUI
	WinGetPos,,,, topH, TopGUI
	
	; Calculate the vertical position required to center TopGUI.
	topPOS := (bottomH - topH) / 2
	
	Gui, TopGUI: +LabelTopGUI
	
	WinMove, TopGUI,, , %topPOS%
}

; =======================================================================
; |     SETUP DIFFICULTY BORDERS     -     SETUP DIFFICULTY BORDERS     |
; =======================================================================

; Red border for scripts that are difficult to configure.
GuiBorderHard()
{
	Gui Border: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui Border: Color, Red
	
	WinSet, ExStyle, ^0x80
	
	Gui Border: -caption
	Gui Border: Show, NoActivate xcenter y0 w505 h165, BottomGUI
}

; Green border for scripts that are easy to configure.
GuiBorderEasy()
{
	Gui Border: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui Border: Color, Green
	
	WinSet, ExStyle, ^0x80
	
	Gui Border: -caption
	Gui Border: Show, NoActivate xcenter y0 w505 h165, BottomGUI
}

; Orange border for scripts with intermediate setup difficulty.
GuiBorderIntermediate()
{
	Gui Border: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui Border: Color, CC5500
	
	WinSet, ExStyle, ^0x80
	
	Gui Border: -caption
	Gui Border: Show, NoActivate xcenter y0 w505 h165, BottomGUI
}

GuiReset()
{
	Gui Border: Destroy
	Gui Info: Destroy
}

; Applies the standardized setup-difficulty border.
SetSetupDifficulty(Difficulty)
{
	if (Difficulty = "Easy")
		GuiBorderEasy()
	else if (Difficulty = "Intermediate")
		GuiBorderIntermediate()
	else if (Difficulty = "Hard")
		GuiBorderHard()
}

ScriptSelect:
if (A_GuiEvent = "DoubleClick")
{
	Gosub, Select
	return
}

if A_GuiEvent = Normal
{
	GuiControlGet, selectedScript, , ScriptListBox
	Switch selectedScript
	{	
		Case "AFK Combat":
		script := "AFK Combat"
		scriptinfo := "Uses Agro pots/flasks to stay in combat for a predetermined length of time. Other pots/flasks can be used by changing the Config.ini"
		GuiReset()
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Ash to Incense":
		script := "Ash to Incense"
		scriptinfo := "Adds ash to an already crafted incense stick. Use this after 'Incense Crafter' and before 'Herb to Incense'."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bake Pie - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Barbarian - Advanced
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Barbarian - Basic
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bow Cutter - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Bow Stringer - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Brick Maker - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Burthrope
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Herb Cleaner - Skillcape":
		script := "Skillcape Cleaner"
		scriptinfo := "Uses the 99/120 Herblore Skillcape to instantly clean a full inventory of dirty herbs. Requires the Skillcape to be worn."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Herb Cleaner - Skillcape
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Clay Fire - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Clay Form - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cooking - Burthorpe
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cooking - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Cooking - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Fire + Form - Portables
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Fire Urn - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Firemaking - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Fletching - Corrupted Magic Logs":
		script := "Fletching"
		scriptinfo := "Fletches corrupted magic logs. This method 'destroys' the log and leaves the inventory empty."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Frame Maker - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Gem Cutter - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Gnome - Advanced
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Gnome - Basic
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Herb to Incense":
		script := "Herb to Incense"
		scriptinfo := "Adds a herb to an ashy incense stick. Use 'Ash to Incense' first or ashy incense sticks from the Grand Exchange."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Het's Oasis
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Incense Crafter":
		script := "Incense Crafter"
		scriptinfo := "Cuts logs into incense sticks. Use this before 'Ash to Incense'."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Jewellery Crafter - Lumbridge
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Jewellery Crafter - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Jewellery Stringer - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Plank + Refined - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Plank Maker - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Potion Mixer - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Refined Plank - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Communion && Material - Focus Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Communion && Material - Without Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Ectoplasm - Focus Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Ectoplasm - Without Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Essence && Necroplasm - Focus Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Rituals - Essence && Necroplasm - Without Storage
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Sawmill - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Sift Soil - Lunar Spell
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Slime Collector
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Stone Wall - Fort Forinthry
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Intermediate")
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Tanning - Portables - Walking
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Tele Grind - Lunar Spell - No Banking
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Tele Grind - Lunar Spell - With Banking
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Watchtower Shortcut
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Agility - Wilderness
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
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
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Contract Binding":
		script := "Contract Binding"
		scriptinfo := "Creates Binding Contracts at the obelisk in Taverly."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Prifddinas - Cooking":
		script := "Cooking"
		scriptinfo := "Uses the bonfire in the Tower of Voices to cook."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Prifddinas - Firemaking":
		script := "Firemaking"
		scriptinfo := "Uses the bonfire in the Tower of Voices to burn logs."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Spinning Wheel - Fort Forinthry":
		script := "Spinning Wheel"
		scriptinfo := "Crafts various items using the spinning wheel in the Rangers Workshop."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Spinning Wheel - Fungal Bowstring - Fort Forinthry":
		script := "Fungal Bowstring"
		scriptinfo := "Creates fungal bowstrings using the spinning wheel in the Rangers Workshop."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Disassembly - Invention":
		script := "Disassembly"
		scriptinfo := "Disassembles items using a hotkey to gather materials for the Invention skill."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()
		
		Case "Sharp Shell Burning":
		script := "Sharp Shell Burning"
		scriptinfo := "Uses the Right-Click Ignite option on Sharp Shell Shards for Firemaking XP."
		GuiReset()
		SetSetupDifficulty("Easy")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cGreen
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Easy
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()

		Case "Archaeology - Excavate":
		script := "Archaeology - Excavate"
		scriptinfo := "Monitors Archaeology XP through ALT1 AfkWarden and reacts when XP gains stop. ALT1 with AfkWarden is required."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()

		Case "Croesus Front":
		script := "Croesus Front"
		scriptinfo := "Monitors XP through ALT1 AfkWarden and clicks the configured Decaying Guard location when XP gains stop. ALT1 with AfkWarden is required."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()

		Case "Eternal Tree":
		script := "Eternal Tree"
		scriptinfo := "Uses ALT1 AfkWarden to detect stopped Woodcutting XP and alternates between the East and West Eternal Trees. Start next to the West Tree. ALT1 with AfkWarden is required."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()

		Case "Waterfall Fishing":
		script := "Waterfall Fishing"
		scriptinfo := "Monitors Waterfall Fishing XP through ALT1 AfkWarden and clicks the configured fishing spot when XP gains stop. ALT1 with AfkWarden is required."
		GuiReset()
		SetSetupDifficulty("Hard")
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, %Script%
		Gui Info: Font, s13 normal bold cRed
		Gui Info: Add, Text, center x5 w480, Setup Difficulty: Hard
		Gui Info: Font, S12 cBlack
		Gui Info: Add, Text, center x5 w480, %scriptinfo%
		WinSet, ExStyle, ^0x80
		Gui Info: -caption
		Gui Info: Show, NoActivate xcenter y9999 w490 h150, TopGUI
		GuiBalance()

	}
	return
}

; =================================================================
; |     SCRIPT LAUNCH MAPPING     -     SCRIPT LAUNCH MAPPING     |
; =================================================================

; Existing selector entries now resolve from the single LLARS Scripts root.
; Automatic script discovery can replace this mapping in a later pass without
; changing the validation or launch helpers below.
Select:
GuiControlGet, selectedScript, , ScriptListBox

if (selectedScript = "")
	return

scriptDir := ""
scriptFile := ""

Switch selectedScript
{
	Case "AFK Combat":
		scriptDir := LLARS_SCRIPTS_DIR . "\AFK Combat"
		scriptFile := "AFK Combat.ahk"

	Case "Alchemy":
		scriptDir := LLARS_SCRIPTS_DIR . "\Alchemy"
		scriptFile := "Alchemy.ahk"

	Case "Amulet Stringer":
		scriptDir := LLARS_SCRIPTS_DIR . "\Amulet Stringer"
		scriptFile := "Amulet Stringer.ahk"

	Case "Anti-AFK":
		scriptDir := LLARS_SCRIPTS_DIR . "\Anti-AFK"
		scriptFile := "Anti-AFK.ahk"

	Case "Armour Crafter - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Armour Crafter\Armour Crafter - No Walking"
		scriptFile := "Armour Crafter.ahk"

	Case "Armour Crafter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Armour Crafter"
		scriptFile := "Armour Crafter.ahk"

	Case "Arrow Fletcher":
		scriptDir := LLARS_SCRIPTS_DIR . "\Arrow Fletcher"
		scriptFile := "Arrow Fletcher.ahk"

	Case "Ash to Incense":
		scriptDir := LLARS_SCRIPTS_DIR . "\Incense\Ash to Incense"
		scriptFile := "Ash to Incense.ahk"

	Case "AutoClicker":
		scriptDir := LLARS_SCRIPTS_DIR . "\AutoClicker"
		scriptFile := "AutoClicker.ahk"

	Case "AutoTele":
		scriptDir := LLARS_SCRIPTS_DIR . "\AutoTele"
		scriptFile := "AutoTele.ahk"

	Case "Bake Pie - Lunar Spell":
		scriptDir := LLARS_SCRIPTS_DIR . "\Lunar Spells\Bake Pie"
		scriptFile := "Bake Pie.ahk"

	Case "Bar Smelter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Bar Smelter"
		scriptFile := "Bar Smelter.ahk"

	Case "Bar Smelter - Smelting Gloves":
		scriptDir := LLARS_SCRIPTS_DIR . "\Bar Smelter"
		scriptFile := "Smelting Glove.ahk"

	Case "Agility - Barbarian - Advanced":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Barbarian\Advanced"
		scriptFile := "Barbarian Course.ahk"

	Case "Agility - Barbarian - Basic":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Barbarian\Basic"
		scriptFile := "Barbarian Course.ahk"

	Case "Bones 2 Bananas":
		scriptDir := LLARS_SCRIPTS_DIR . "\Bones 2 Bananas"
		scriptFile := "Bones 2 Bananas.ahk"

	Case "Bow Cutter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Bow Cutter"
		scriptFile := "Bow Cutter.ahk"

	Case "Bow Cutter - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Fletching\Bow Cutter - With Walking"
		scriptFile := "Bow Cutter.ahk"

	Case "Bow Cutter - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Fletching\Bow Cutter - No Walking"
		scriptFile := "Bow Cutter.ahk"

	Case "Bow Stringer":
		scriptDir := LLARS_SCRIPTS_DIR . "\Bow Stringer"
		scriptFile := "Bow Stringer.ahk"

	Case "Bow Stringer - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Fletching\Bow Stringer - WIth Walking"
		scriptFile := "Bow Stringer.ahk"

	Case "Bow Stringer - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Fletching\Bow Stringer - No Walking"
		scriptFile := "Bow Stringer.ahk"

	Case "Brick Maker - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Limestone Brick"
		scriptFile := "Brick Maker.ahk"

	Case "Agility - Burthrope":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Burthorpe"
		scriptFile := "Burthorpe.ahk"

	Case "Candle Crafter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Candle Crafter"
		scriptFile := "Candle Crafter.ahk"

	Case "Herb Cleaner - Skillcape":
		scriptDir := LLARS_SCRIPTS_DIR . "\Herb Cleaner - Skillcape"
		scriptFile := "Skillcape Cleaner.ahk"

	Case "Clay Fire - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Clay\Clay Fire\Clay Fire - No Walking"
		scriptFile := "Clay Fire.ahk"

	Case "Clay Fire - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Clay\Clay Fire\Clay Fire - With Walking"
		scriptFile := "Clay Fire.ahk"

	Case "Clay Form - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Clay\Clay Form\Clay Form - No Walking"
		scriptFile := "Clay Form.ahk"

	Case "Clay Form - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Clay\Clay Form\Clay Form - With Walking"
		scriptFile := "Clay Form.ahk"

	Case "Cooking - Burthorpe":
		scriptDir := LLARS_SCRIPTS_DIR . "\Cooking"
		scriptFile := "Cooking.ahk"

	Case "Cooking - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Cooking"
		scriptFile := "Cooking.ahk"

	Case "Cooking - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Cooking\Cooking - No Walking"
		scriptFile := "Cooking.ahk"

	Case "Cooking - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Cooking\Cooking - With Walking"
		scriptFile := "Cooking.ahk"

	Case "Fire + Form - Portables":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Clay\Fire + Form"
		scriptFile := "Fire + Form.ahk"

	Case "Fire Urn - Lunar Spell":
		scriptDir := LLARS_SCRIPTS_DIR . "\Lunar Spells\Fire Urn"
		scriptFile := "Fire Urn.ahk"

	Case "Firemaking - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Firemaking\Firemaking - No Walking"
		scriptFile := "Firemaking.ahk"

	Case "Firemaking - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Firemaking\Firemaking - With Walking"
		scriptFile := "Firemaking.ahk"

	Case "Frame Maker - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Frame Maker"
		scriptFile := "Frame Maker.ahk"

	Case "Gem Cutter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Gem Cutter"
		scriptFile := "Gem Cutter.ahk"

	Case "Gem Cutter - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Gem Cutter\Gem Cutter - No Walking"
		scriptFile := "Gem Cutter.ahk"

	Case "Gem Cutter - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Gem Cutter\Gem Cutter - With Walking"
		scriptFile := "Gem Cutter.ahk"

	Case "Glassblowing":
		scriptDir := LLARS_SCRIPTS_DIR . "\Glassblowing"
		scriptFile := "Glassblowinng.ahk"

	Case "Agility - Gnome - Advanced":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Gnome\Advanced"
		scriptFile := "Gnome Course.ahk"

	Case "Agility - Gnome - Basic":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Gnome\Basic"
		scriptFile := "Gnome Course.ahk"

	Case "Herb to Incense":
		scriptDir := LLARS_SCRIPTS_DIR . "\Incense\Herb to Incense"
		scriptFile := "Herb to Incense.ahk"

	Case "Herb Cleaner":
		scriptDir := LLARS_SCRIPTS_DIR . "\Herb Cleaner"
		scriptFile := "Herb Cleaner.ahk"

	Case "Agility - Het's Oasis":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Het's Oasis"
		scriptFile := "Het's Oasis.ahk"

	Case "Incense Crafter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Incense\Incense Crafter"
		scriptFile := "Incense Crafter.ahk"

	Case "Ink Crafter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Ink Crafter"
		scriptFile := "Ink Crafter.ahk"

	Case "Jewellery Crafter - Lumbridge":
		scriptDir := LLARS_SCRIPTS_DIR . "\Jewellery Crafter"
		scriptFile := "Jewellery Crafter.ahk"

	Case "Jewellery Crafter - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Jewellery Crafter"
		scriptFile := "Jewellery Crafter.ahk"

	Case "Jewellery Enchanter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Jewellery Enchant"
		scriptFile := "Jewel Enchant.ahk"

	Case "Jewellery Stringer - Lunar Spell":
		scriptDir := LLARS_SCRIPTS_DIR . "\Lunar Spells\String Jewellery"
		scriptFile := "Jewel Stringer.ahk"

	Case "Plank + Refined - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Plank + Refined"
		scriptFile := "Plank + Refined.ahk"

	Case "Plank Maker - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Plank Maker"
		scriptFile := "Plank Maker.ahk"

	Case "Potion Mixer":
		scriptDir := LLARS_SCRIPTS_DIR . "\Potion Mixer"
		scriptFile := "Potion Mixer.ahk"

	Case "Potion Mixer - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Herblore\Potion Mixer - No Walking"
		scriptFile := "Potion Mixer.ahk"

	Case "Potion Mixer - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Herblore\Potion Mixer - With Walking"
		scriptFile := "Potion Mixer.ahk"

	Case "Prayer":
		scriptDir := LLARS_SCRIPTS_DIR . "\Prayer"
		scriptFile := "Prayer.ahk"

	Case "Pyre Crafter":
		scriptDir := LLARS_SCRIPTS_DIR . "\Pyre Crafter"
		scriptFile := "Pyre Crafter.ahk"

	Case "Refined Plank - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Refined Plank"
		scriptFile := "Refined Plank.ahk"

	Case "Rituals - Communion & Material - Focus Storage":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Rituals\Communion & Material\Focus Storage"
		scriptFile := "Rituals.ahk"

	Case "Rituals - Communion & Material - Without Storage":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Rituals\Communion & Material\Without Focus Storage"
		scriptFile := "Rituals.ahk"

	Case "Rituals - Ectoplasm - Focus Storage":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Rituals\Ectoplasm\Focus Storage"
		scriptFile := "Rituals.ahk"

	Case "Rituals - Ectoplasm - Without Storage":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Rituals\Ectoplasm\Without Focus Storage"
		scriptFile := "Rituals.ahk"

	Case "Rituals - Essence & Necroplasm - Focus Storage":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Rituals\Essence & Necroplasm\Focus Storage"
		scriptFile := "Rituals.ahk"

	Case "Rituals - Essence & Necroplasm - Without Storage":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Rituals\Essence & Necroplasm\Without Focus Storage"
		scriptFile := "Rituals.ahk"

	Case "Sawmill - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Sawmill\Sawmill - No Walking"
		scriptFile := "Sawmill.ahk"

	Case "Sawmill - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Sawmill\Sawmill - With Walking"
		scriptFile := "Sawmill.ahk"

	Case "Sift Soil - Lunar Spell":
		scriptDir := LLARS_SCRIPTS_DIR . "\Lunar Spells\Sift Soil"
		scriptFile := "Sift Soil.ahk"

	Case "Slime Collector":
		scriptDir := LLARS_SCRIPTS_DIR . "\Necromancy\Slime Collector - Notepaper"
		scriptFile := "Slime Collector.ahk"

	Case "Smithing":
		scriptDir := LLARS_SCRIPTS_DIR . "\Smithing"
		scriptFile := "Smithing.ahk"

	Case "Stone Wall - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Stone Wall"
		scriptFile := "Stone Wall.ahk"

	Case "Tanning - Portables - Non-Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Tanning\Tanning - No Walking"
		scriptFile := "Tanning.ahk"

	Case "Tanning - Portables - Walking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Portables\Crafting\Tanning\Tanning - With Walking"
		scriptFile := "Tanning.ahk"

	Case "Tele Grind - Lunar Spell - No Banking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Lunar Spells\Telekinetic Grind\Telekinetic Grind with No Banking"
		scriptFile := "Tele Grind.ahk"

	Case "Tele Grind - Lunar Spell - With Banking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Lunar Spells\Telekinetic Grind\Telekinetic Grind with Banking"
		scriptFile := "Tele Grind.ahk"

	Case "Agility - Watchtower Shortcut":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Watchtower Shortcut"
		scriptFile := "Watchtower.ahk"

	Case "Agility - Wilderness":
		scriptDir := LLARS_SCRIPTS_DIR . "\Agility\Wilderness"
		scriptFile := "Wilderness.ahk"

	Case "Wine Maker":
		scriptDir := LLARS_SCRIPTS_DIR . "\Wine Maker"
		scriptFile := "Wine Maker.ahk"

	Case "Contract Binding":
		scriptDir := LLARS_SCRIPTS_DIR . "\Contract Binding"
		scriptFile := "Contract Binding.ahk"

	Case "Fletching - Corrupted Magic Logs":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fletching - Corrupted Magic Logs"
		scriptFile := "Fletching.ahk"

	Case "Prifddinas - Cooking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Prifddinas\Cooking"
		scriptFile := "Cooking.ahk"

	Case "Prifddinas - Firemaking":
		scriptDir := LLARS_SCRIPTS_DIR . "\Prifddinas\Firemaking"
		scriptFile := "Firemaking.ahk"

	Case "Spinning Wheel - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Spinning Wheel"
		scriptFile := "Spinning Wheel.ahk"

	Case "Spinning Wheel - Fungal Bowstring - Fort Forinthry":
		scriptDir := LLARS_SCRIPTS_DIR . "\Fort Forinthry\Spinning Wheel"
		scriptFile := "Fungal Bowstring.ahk"

	Case "Disassembly - Invention":
		scriptDir := LLARS_SCRIPTS_DIR . "\Invention\Disassembly"
		scriptFile := "Disassembly.ahk"

	Case "Sharp Shell Burning":
		scriptDir := LLARS_SCRIPTS_DIR . "\Sharp Shell Burning"
		scriptFile := "Shell Burning.ahk"


	Case "Archaeology - Excavate":
		scriptDir := LLARS_SCRIPTS_DIR . "\Archaeology\Excavate"
		scriptFile := "Excavate.ahk"

	Case "Croesus Front":
		scriptDir := LLARS_SCRIPTS_DIR . "\Croesus Front"
		scriptFile := "Croesus Front.ahk"

	Case "Eternal Tree":
		scriptDir := LLARS_SCRIPTS_DIR . "\Eternal Tree"
		scriptFile := "Eternal Tree.ahk"

	Case "Waterfall Fishing":
		scriptDir := LLARS_SCRIPTS_DIR . "\Waterfall Fishing"
		scriptFile := "Waterfall Fishing.ahk"
	Default:
		MsgBox, 48, Script Missing, No launch location is configured for:`n%selectedScript%
		return
}

if !LaunchSelectedScript(scriptDir, scriptFile)
	return
Goto, exit
return

; Validates the selected script and its local configuration before launch.
ValidateSelectedScript(ScriptDirectory, ScriptFile, ByRef FullDiskPath, ByRef DisplayPath)
{
	ScriptDirectory := RTrim(ScriptDirectory, "\")
	FullDiskPath := ScriptDirectory . "\" . ScriptFile
	ConfigPath := ScriptDirectory . "\Config.ini"

	RootPrefix := RTrim(A_ScriptDir, "\") . "\"
	StringLower, LowerFullDiskPath, FullDiskPath
	StringLower, LowerRootPrefix, RootPrefix

	if (SubStr(LowerFullDiskPath, 1, StrLen(LowerRootPrefix)) = LowerRootPrefix)
		DisplayPath := SubStr(FullDiskPath, StrLen(RootPrefix) + 1)
	else
		DisplayPath := FullDiskPath

	if !FileExist(FullDiskPath)
	{
		Gui, Hide
		MsgBox, 48, Script Missing
			, The selected script could not be found.`n`nExpected Location:`nLLARS\%DisplayPath%
		return false
	}

	if !FileExist(ConfigPath)
	{
		Gui, Hide
		MsgBox, 48, Config Missing
			, The selected script is missing its Config.ini.`n`nScript:`nLLARS\%DisplayPath%
		return false
	}

	return true
}

; Launches a validated script using its own directory as the working directory.
LaunchSelectedScript(ScriptDirectory, ScriptFile)
{
	if (ScriptDirectory = "" || ScriptFile = "")
		return false

	if !ValidateSelectedScript(ScriptDirectory, ScriptFile, FullDiskPath, DisplayPath)
	{
		Reload
		return false
	}

	Gui, TopGUI:Destroy
	Gui, BottomGUI:Destroy
	Gui, Info:Cancel
	Gui, Info:Destroy
	Gui, Border:Destroy
	Gui, Destroy

	Run, %FullDiskPath%, %ScriptDirectory%

	exitapp
	return true
}

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
