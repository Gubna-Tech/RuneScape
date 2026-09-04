; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
#NoTrayIcon
SetBatchLines, -1

; ===============================================================================
; |     DUPLICATE CHECK     -     DUPLICATE CHECK     -     DUPLICATE CHECK     |
; ===============================================================================

; Enables detection of hidden windows and closes any existing
; LLARS-related selector windows before continuing.
DetectHiddenWindows, On
CloseOtherLLARS()

; ================================================================
; |     FILE CHECK     -     FILE CHECK     -     FILE CHECK     |
; ================================================================

; Checks whether the script is being run directly from a
; compressed archive.
IsArchivePath := RegExMatch(A_ScriptDir, "\.(zip|rar|7z)(\\|$)")

if (IsArchivePath)
{
	Menu, Tray, NoIcon	
	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop	
	Gui Error: Font, S13 bold underline cRed
	Gui Error: Add, Text, Center w220 x5, ERROR	
	Gui Error: Add, Text, Center x5 w220,	
	Gui Error: Font, s12 norm bold
	Gui Error: Add, Text, Center w220 x5, Files Are Zipped	
	Gui Error: Add, Text, Center x5 w220,	
	Gui Error: Font, cBlack
	Gui Error: Add, Text, Center w220 x5, Please extract all files from the zipped (.zip) folder:	
	Gui Error: Font, underline s12
	Gui Error: Add, Text, cGreen Center w220 x5, RuneScape-main.zip
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

; ===================================================================
; |     ARRAY SETUP     -     ARRAY SETUP     -     ARRAY SETUP     |
; ===================================================================

; List of available scripts.
scriptArray := "AFK Combat|Alchemy|Amulet Stringer|Anti-AFK|Armour Crafter|Armour Crafter - Portables - Non-Walking|Armour Crafter - Portables - Walking|Arrow Fletcher|Ash to Incense|AutoClicker|AutoTele|Bake Pie - Lunar Spell|Bar Smelter|Bar Smelter - Smelting Gloves|Agility - Barbarian - Advanced|Agility - Barbarian - Basic|Bones 2 Bananas|Bow Cutter|Bow Cutter - Portables - Non-Walking|Bow Cutter - Portables - Walking|Bow Stringer|Bow Stringer - Portables - Non-Walking|Bow Stringer - Portables - Walking|Brick Maker - Fort Forinthry|Agility - Burthrope|Candle Crafter|Herb Cleaner - Skillcape|Clay Fire - Portables - Non-Walking|Clay Fire - Portables - Walking|Clay Form - Portables - Non-Walking|Clay Form - Portables - Walking|Cooking - Burthorpe|Cooking - Fort Forinthry|Cooking - Portables - Non-Walking|Cooking - Portables - Walking|Decoration Maker|Fire + Form - Portables|Fire Urn - Lunar Spell|Firemaking - Portables - Non-Walking|Firemaking - Portables - Walking|Flatpack Maker - Portables - Non-Walking|Flatpack Maker - Portables - Walking|Frame Maker - Fort Forinthry|Gem Cutter|Gem Cutter - Portables - Non-Walking|Gem Cutter - Portables - Walking|Glassblowing|Agility - Gnome - Advanced|Agility - Gnome - Basic|Herb to Incense|Herb Cleaner|Agility - Het's Oasis|Incense Crafter|Ink Crafter|Jewellery Crafter - Lumbridge|Jewellery Crafter - Fort Forinthry|Jewellery Enchanter|Jewellery Stringer - Lunar Spell|Plank + Refined - Fort Forinthry|Plank Maker - Fort Forinthry|Potion Mixer|Potion Mixer - Portables - Non-Walking|Potion Mixer - Portables - Walking|Prayer|Pyre Crafter|Refined Plank - Fort Forinthry|Rituals - Communion & Material - Focus Storage|Rituals - Communion & Material - Without Storage|Rituals - Ectoplasm - Focus Storage|Rituals - Ectoplasm - Without Storage|Rituals - Essence & Necroplasm - Focus Storage|Rituals - Essence & Necroplasm - Without Storage|Sawmill - Portables - Non-Walking|Sawmill - Portables - Walking|Sift Soil - Lunar Spell|Slime Collector|Smithing|Stone Wall - Fort Forinthry|Tanning - Portables - Non-Walking|Tanning - Portables - Walking|Tele Grind - Lunar Spell - No Banking|Tele Grind - Lunar Spell - With Banking|Agility - Watchtower Shortcut|Agility - Wilderness|Wine Maker|Contract Binding|Fletching - Corrupted Magic Logs|Prifddinas - Cooking|Prifddinas - Firemaking|Spinning Wheel - Fort Forinthry|Spinning Wheel - Fungal Bowstring - Fort Forinthry|Disassembly - Invention|Sharp Shell Burning|"

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
return

WM_WINDOWPOSCHANGED() {
	If (A_Gui) {
		checkpos()
	}
}
return

CheckPOS()
{
	; Windows allowed to use the position correction routine.
	allowedWindows := "|Script Selector|"
	
	; Get the currently active window title.
	WinGetTitle, activeWindowTitle, A
	
	; Ignore windows that are not part of this selector.
	if (InStr(allowedWindows, "|" activeWindowTitle "|") <= 0)
	{
		return
	}
	
	; Get the current GUI position and size.
	WinGetPos, GUIx, GUIy, GUIw, GUIh, A
	
	xmin := GUIx
	xmax := GUIw + GUIx
	ymin := GUIy
	ymax := GUIh + GUIy
	
	xadj := A_ScreenWidth - GUIw
	yadj := A_ScreenHeight - GUIh
	
	WinGetPos, X, Y,,, A
	
	
	; Keep the left edge on-screen.
	if (xmin < 0)
	{
		WinMove, A,, 0
	}
	
	; Keep the top edge on-screen.
	if (ymin < 0)
	{
		WinMove, A,,, 0
	}
	
	; Keep the right edge on-screen.
	if (xmax > A_ScreenWidth)
	{
		WinMove, A,, xadj
	}
	
	; Keep the bottom edge on-screen.
	if (ymax > A_ScreenHeight)
	{
		WinMove, A,,, yadj
	}
}

CloseOtherLLARS()
{
	; Find all windows with LLARS in the title.
	WinGet, hWndList, List, LLARS
	
	Loop, %hWndList%
	{
		hWnd := hWndList%A_Index%
		
		WinClose, % "ahk_id " hWnd
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

GuiBorderA()
{
	Gui Border: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui Border: Color, Red
	
	WinSet, ExStyle, ^0x80
	
	Gui Border: -caption
	Gui Border: Show, NoActivate xcenter y0 w505 h165, BottomGUI
}

GuiBorderB()
{
	Gui Border: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
	Gui Border: Color, Green
	
	WinSet, ExStyle, ^0x80
	
	Gui Border: -caption
	Gui Border: Show, NoActivate xcenter y0 w505 h165, BottomGUI
}

GuiBorderI()
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

ScriptSelect:
if (A_GuiEvent = "DoubleClick")
{
	Gosub, Select
}
return

if A_GuiEvent = Normal
{
	GuiControlGet, selectedScript, , ScriptListBox
	Switch selectedScript
	{	
		Case "AFK Combat":
		script := "AFK Combat"
		scriptinfo := "Uses Agro pots/flasks to stay in combat for a predetermined length of time. Other pots/flasks can be used by changing the Config.ini"
		GuiReset()
		GuiBorderI()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderI()
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
		GuiBorderB()
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
		
		Case "Ash to Incense":
		script := "Ash to Incense"
		scriptinfo := "Adds ash to an already crafted incense stick. Use this after 'Incense Crafter' and before 'Herb to Incense'."
		GuiReset()
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderI()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderB()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderB()
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
		
		Case "Herb Cleaner - Skillcape":
		script := "Skillcape Cleaner"
		scriptinfo := "Uses the 99/120 Herblore Skillcape to instantly clean a full inventory of dirty herbs. Requires the Skillcape to be worn."
		GuiReset()
		GuiBorderB()
		Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled
		Gui Info: Color, White
		Gui Info: Font, s14 bold underline cBlue
		Gui Info: Add, Text, center x5 w480, Herb Cleaner - Skillcape
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderI()
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
		GuiBorderA()
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
		
		Case "Fletching - Corrupted Magic Logs":
		script := "Fletching"
		scriptinfo := "Fletches corrupted magic logs. This method 'destroys' the log and leaves the inventory empty."
		GuiReset()
		GuiBorderB()
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
		
		Case "Frame Maker - Fort Forinthry":
		script := "Frame Maker"
		scriptinfo := "Walks between the bank chest and woodworking bench to make frames."
		GuiReset()
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderA()
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
		
		Case "Herb to Incense":
		script := "Herb to Incense"
		scriptinfo := "Adds a herb to an ashy incense stick. Use 'Ash to Incense' first or ashy incense sticks from the Grand Exchange."
		GuiReset()
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderA()
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
		scriptinfo := "Cuts logs into incense sticks. Use this before 'Ash to Incense'."
		GuiReset()
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderI()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderB()
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
		GuiBorderA()
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
		GuiBorderA()
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
		GuiBorderB()
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
		GuiBorderI()
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
		GuiBorderA()
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
		
		Case "Contract Binding":
		script := "Contract Binding"
		scriptinfo := "Creates Binding Contracts at the obelisk in Taverly."
		GuiReset()
		GuiBorderA()
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
		
		Case "Prifddinas - Cooking":
		script := "Cooking"
		scriptinfo := "Uses the bonfire in the Tower of Voices to cook."
		GuiReset()
		GuiBorderA()
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
		
		Case "Prifddinas - Firemaking":
		script := "Firemaking"
		scriptinfo := "Uses the bonfire in the Tower of Voices to burn logs."
		GuiReset()
		GuiBorderA()
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
		
		Case "Spinning Wheel - Fort Forinthry":
		script := "Spinning Wheel"
		scriptinfo := "Crafts various items using the spinning wheel in the Rangers Workshop."
		GuiReset()
		GuiBorderA()
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
		
		Case "Spinning Wheel - Fungal Bowstring - Fort Forinthry":
		script := "Fungal Bowstring"
		scriptinfo := "Creates fungal bowstrings using the spinning wheel in the Rangers Workshop."
		GuiReset()
		GuiBorderB()
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
		
		Case "Disassembly - Invention":
		script := "Disassembly"
		scriptinfo := "Disassembles items using a hotkey to gather materials for the Invention skill."
		GuiReset()
		GuiBorderB()
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
		
		Case "Sharp Shell Burning":
		script := "Sharp Shell Burning"
		scriptinfo := "Uses the Right-Click Ignite option on Sharp Shell Shards for Firemaking XP."
		GuiReset()
		GuiBorderB()
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
	}
	return
}

Select:
GuiControlGet, selectedScript, , ScriptListBox

scriptFile := ""
scriptDir := ""
script := ""

Switch selectedScript
{
    Case "AFK Combat":
        script := "AFK Combat"
        scriptDir := A_ScriptDir . "\" . script

    Case "Alchemy":
        script := "Alchemy"
        scriptDir := A_ScriptDir . "\" . script

    Case "Amulet Stringer":
        script := "Amulet Stringer"
        scriptDir := A_ScriptDir . "\" . script

    Case "Anti-AFK":
        script := "Anti-AFK"
        scriptDir := A_ScriptDir . "\" . script

    Case "Armour Crafter - Portables - Walking":
        script := "Armour Crafter"
        scriptDir := A_ScriptDir . "\portables\crafting\Armour Crafter\Armour Crafter - With Walking"

    Case "Armour Crafter - Portables - Non-Walking":
        script := "Armour Crafter"
        scriptDir := A_ScriptDir . "\portables\crafting\Armour Crafter\Armour Crafter - No Walking"

    Case "Armour Crafter":
        script := "Armour Crafter"
        scriptDir := A_ScriptDir . "\" . script

    Case "Arrow Fletcher":
        script := "Arrow Fletcher"
        scriptDir := A_ScriptDir . "\" . script

    Case "Ash to Incense":
        script := "Ash to Incense"
        scriptDir := A_ScriptDir . "\Incense\" . script

    Case "AutoClicker":
        script := "AutoClicker"
        scriptDir := A_ScriptDir . "\Misc\Autoclicker"

    Case "AutoTele":
        script := "AutoTele"
        scriptDir := A_ScriptDir . "\" . script

    Case "Bake Pie - Lunar Spell":
        script := "Bake Pie"
        scriptDir := A_ScriptDir . "\Lunar Spells\" . script

    Case "Bar Smelter":
        script := "Bar Smelter"
        scriptDir := A_ScriptDir . "\" . script

    Case "Bar Smelter - Smelting Gloves":
        script := "Smelting Glove"
        scriptDir := A_ScriptDir . "\Bar Smelter"

    Case "Agility - Barbarian - Advanced":
        script := "Barbarian Course"
        scriptDir := A_ScriptDir . "\agility\Barbarian\Advanced"

    Case "Agility - Barbarian - Basic":
        script := "Barbarian Course"
        scriptDir := A_ScriptDir . "\agility\Barbarian\Basic"

    Case "Bones 2 Bananas":
        script := "Bones 2 Bananas"
        scriptDir := A_ScriptDir . "\" . script

    Case "Bow Cutter":
        script := "Bow Cutter"
        scriptDir := A_ScriptDir . "\" . script

    Case "Bow Cutter - Portables - Walking":
        script := "Bow Cutter"
        scriptDir := A_ScriptDir . "\portables\fletching\Bow Cutter - With Walking"

    Case "Bow Cutter - Portables - Non-Walking":
        script := "Bow Cutter"
        scriptDir := A_ScriptDir . "\portables\fletching\Bow Cutter - No Walking"

    Case "Bow Stringer":
        script := "Bow Stringer"
        scriptDir := A_ScriptDir . "\" . script

    Case "Bow Stringer - Portables - Walking":
        script := "Bow Stringer"
        scriptDir := A_ScriptDir . "\portables\fletching\Bow Stringer - With Walking"

    Case "Bow Stringer - Portables - Non-Walking":
        script := "Bow Stringer"
        scriptDir := A_ScriptDir . "\portables\fletching\Bow Stringer - No Walking"

    Case "Brick Maker - Fort Forinthry":
        script := "Limestone Brick"
        scriptDir := A_ScriptDir . "\Fort Forinthry\Limestone Brick"
        scriptFile := "Brick Maker.ahk"

    Case "Agility - Burthrope":
        script := "Burthorpe"
        scriptDir := A_ScriptDir . "\Agility\" . script

    Case "Candle Crafter":
        script := "Candle Crafter"
        scriptDir := A_ScriptDir . "\Necromancy\" . script

    Case "Herb Cleaner - Skillcape":
        script := "Skillcape Cleaner"
        scriptDir := A_ScriptDir . "\Herb Cleaner - Skillcape"

    Case "Clay Fire - Portables - Non-Walking":
        script := "Clay Fire"
        scriptDir := A_ScriptDir . "\portables\crafting\clay\clay fire\clay fire - no walking"

    Case "Clay Fire - Portables - Walking":
        script := "Clay Fire"
        scriptDir := A_ScriptDir . "\portables\crafting\clay\clay fire\clay fire - with walking"

    Case "Clay Form - Portables - Non-Walking":
        script := "Clay Form"
        scriptDir := A_ScriptDir . "\portables\crafting\clay\clay Form\clay Form - no walking"

    Case "Clay Form - Portables - Walking":
        script := "Clay Form"
        scriptDir := A_ScriptDir . "\portables\crafting\clay\clay Form\clay Form - with walking"

    Case "Cooking - Burthorpe":
        script := "Cooking"
        scriptDir := A_ScriptDir . "\" . script

    Case "Cooking - Fort Forinthry":
        script := "Cooking"
        scriptDir := A_ScriptDir . "\Fort Forinthry\" . script

    Case "Cooking - Portables - Non-Walking":
        script := "Cooking"
        scriptDir := A_ScriptDir . "\portables\cooking\cooking - no walking"

    Case "Cooking - Portables - Walking":
        script := "Cooking"
        scriptDir := A_ScriptDir . "\portables\cooking\cooking - with walking"

    Case "Decoration Maker":
        script := "Decoration Maker"
        scriptDir := A_ScriptDir . "\Events\2023\Christmas\" . script

    Case "Fire + Form - Portables":
        script := "Fire + Form"
        scriptDir := A_ScriptDir . "\portables\crafting\clay\fire + form"

    Case "Fire Urn - Lunar Spell":
        script := "Fire Urn"
        scriptDir := A_ScriptDir . "\lunar spells\" . script

    Case "Firemaking - Portables - Non-Walking":
        script := "Firemaking"
        scriptDir := A_ScriptDir . "\portables\Firemaking\Firemaking - no walking"

    Case "Firemaking - Portables - Walking":
        script := "Firemaking"
        scriptDir := A_ScriptDir . "\portables\Firemaking\Firemaking - with walking"

    Case "Frame Maker - Fort Forinthry":
        script := "Frame Maker"
        scriptDir := A_ScriptDir . "\Fort Forinthry\" . script

    Case "Gem Cutter":
        script := "Gem Cutter"
        scriptDir := A_ScriptDir . "\" . script

    Case "Gem Cutter - Portables - Non-Walking":
        script := "Gem Cutter"
        scriptDir := A_ScriptDir . "\portables\Crafting\Gem Cutter\Gem Cutter - no walking"

    Case "Gem Cutter - Portables - Walking":
        script := "Gem Cutter"
        scriptDir := A_ScriptDir . "\portables\Crafting\Gem Cutter\Gem Cutter - with walking"

    Case "Glassblowing":
        script := "Glassblowing"
        scriptDir := A_ScriptDir . "\" . script

    Case "Agility - Gnome - Advanced":
        script := "Gnome Course"
        scriptDir := A_ScriptDir . "\agility\Gnome\Advanced"

    Case "Agility - Gnome - Basic":
        script := "Gnome Course"
        scriptDir := A_ScriptDir . "\agility\Gnome\Basic"

    Case "Herb to Incense":
        script := "Herb to Incense"
        scriptDir := A_ScriptDir . "\Incense\" . script

    Case "Herb Cleaner":
        script := "Herb Cleaner"
        scriptDir := A_ScriptDir . "\" . script

    Case "Agility - Het's Oasis":
        script := "Het's Oasis"
        scriptDir := A_ScriptDir . "\agility\" . script

    Case "Incense Crafter":
        script := "Incense Crafter"
        scriptDir := A_ScriptDir . "\Incense\" . script

    Case "Ink Crafter":
        script := "Ink Crafter"
        scriptDir := A_ScriptDir . "\Necromancy\" . script

    Case "Jewellery Crafter - Lumbridge":
        script := "Jewellery Crafter"
        scriptDir := A_ScriptDir . "\" . script

    Case "Jewellery Crafter - Fort Forinthry":
        script := "Jewellery Crafter"
        scriptDir := A_ScriptDir . "\Fort Forinthry\" . script

    Case "Jewellery Enchanter":
        script := "Jewel Enchant"
        scriptDir := A_ScriptDir . "\Jewellery Enchant"

    Case "Jewellery Stringer - Lunar Spell":
        script := "String Jewellery"
        scriptDir := A_ScriptDir . "\lunar spells\" . script
        scriptFile := "Jewel Stringer.ahk"

    Case "Plank + Refined - Fort Forinthry":
        script := "Plank + Refined"
        scriptDir := A_ScriptDir . "\Fort Forinthry\" . script

    Case "Plank Maker - Fort Forinthry":
        script := "Plank Maker"
        scriptDir := A_ScriptDir . "\Fort Forinthry\" . script

    Case "Potion Mixer":
        script := "Potion Mixer"
        scriptDir := A_ScriptDir . "\" . script

    Case "Potion Mixer - Portables - Non-Walking":
        script := "Potion Mixer"
        scriptDir := A_ScriptDir . "\portables\Herblore\Potion Mixer - no walking"

    Case "Potion Mixer - Portables - Walking":
        script := "Potion Mixer"
        scriptDir := A_ScriptDir . "\portables\Herblore\Potion Mixer - with walking"

    Case "Prayer":
        script := "Prayer"
        scriptDir := A_ScriptDir . "\" . script

    Case "Pyre Crafter":
        script := "Pyre Crafter"
        scriptDir := A_ScriptDir . "\" . script

    Case "Refined Plank - Fort Forinthry":
        script := "Refined Planks"
        scriptDir := A_ScriptDir . "\Fort Forinthry\" . script

    Case "Rituals - Communion & Material - Focus Storage":
        script := "Rituals"
        scriptDir := A_ScriptDir . "\Necromancy\" . script . "\Communion & Material\Focus Storage"

    Case "Rituals - Communion & Material - Without Storage":
        script := "Rituals"
        scriptDir := A_ScriptDir . "\Necromancy\" . script . "\Communion & Material\Without Focus Storage"

    Case "Rituals - Ectoplasm - Focus Storage":
        script := "Rituals"
        scriptDir := A_ScriptDir . "\Necromancy\" . script . "\Ectoplasm\Focus Storage"

    Case "Rituals - Ectoplasm - Without Storage":
        script := "Rituals"
        scriptDir := A_ScriptDir . "\Necromancy\" . script . "\Ectoplasm\Without Focus Storage"

    Case "Rituals - Essence & Necroplasm - Focus Storage":
        script := "Rituals"
        scriptDir := A_ScriptDir . "\Necromancy\" . script . "\Essence & Necroplasm\Focus Storage"

    Case "Rituals - Essence & Necroplasm - Without Storage":
        script := "Rituals"
        scriptDir := A_ScriptDir . "\Necromancy\" . script . "\Essence & Necroplasm\Without Focus Storage"

    Case "Sawmill - Portables - Non-Walking":
        script := "Sawmill"
        scriptDir := A_ScriptDir . "\portables\Sawmill\Sawmill - no walking"

    Case "Sawmill - Portables - Walking":
        script := "Sawmill"
        scriptDir := A_ScriptDir . "\portables\Sawmill\Sawmill - with walking"

    Case "Sift Soil - Lunar Spell":
        script := "Sift Soil"
        scriptDir := A_ScriptDir . "\Lunar Spells\" . script

    Case "Slime Collector":
        script := "Slime Collector"
        scriptDir := A_ScriptDir . "\Necromancy\Slime Collector - Notepaper"

    Case "Smithing":
        script := "Smithing"
        scriptDir := A_ScriptDir . "\" . script

    Case "Stone Wall - Fort Forinthry":
        script := "Stone Wall"
        scriptDir := A_ScriptDir . "\Fort Forinthry\" . script

    Case "Tanning - Portables - Non-Walking":
        script := "Tanning"
        scriptDir := A_ScriptDir . "\portables\Crafting\Tanning\Tanning - no walking"

    Case "Tanning - Portables - Walking":
        script := "Tanning"
        scriptDir := A_ScriptDir . "\portables\Crafting\Tanning\Tanning - with walking"

    Case "Tele Grind - Lunar Spell - No Banking":
        script := "Tele Grind"
        scriptDir := A_ScriptDir . "\Lunar Spells\Telekinetic Grind\Telekinetic Grind with No Banking"

    Case "Tele Grind - Lunar Spell - With Banking":
        script := "Tele Grind"
        scriptDir := A_ScriptDir . "\Lunar Spells\Telekinetic Grind\Telekinetic Grind with Banking"

    Case "Agility - Watchtower Shortcut":
        script := "Watchtower Shortcut"
        scriptDir := A_ScriptDir . "\agility\" . script
        scriptFile := "watchtower.ahk"

    Case "Agility - Wilderness":
        script := "Wilderness"
        scriptDir := A_ScriptDir . "\agility\" . script

    Case "Wine Maker":
        script := "Wine Maker"
        scriptDir := A_ScriptDir . "\" . script

    Case "Flatpack Maker - Portables - Non-Walking":
        script := "Flatpack Maker"
        scriptDir := A_ScriptDir . "\portables\Construction\Flatpack Maker - no walking"

    Case "Flatpack Maker - Portables - Walking":
        script := "Flatpack Maker"
        scriptDir := A_ScriptDir . "\portables\Construction\Flatpack Maker - with walking"

    Case "Contract Binding":
        script := "Contract Binding"
        scriptDir := A_ScriptDir . "\" . script

    Case "Fletching - Corrupted Magic Logs":
        script := "Fletching"
        scriptDir := A_ScriptDir . "\Fletching - Corrupted Magic Logs"

    Case "Prifddinas - Cooking":
        script := "Cooking"
        scriptDir := A_ScriptDir . "\Prifddinas\Cooking"

    Case "Prifddinas - Firemaking":
        script := "Firemaking"
        scriptDir := A_ScriptDir . "\Prifddinas\Firemaking"

    Case "Spinning Wheel - Fort Forinthry":
        script := "Spinning Wheel"
        scriptDir := A_ScriptDir . "\Fort Forinthry\Spinning Wheel"

    Case "Spinning Wheel - Fungal Bowstring - Fort Forinthry":
        script := "Fungal Bowstring"
        scriptDir := A_ScriptDir . "\Fort Forinthry\Spinning Wheel"

    Case "Disassembly - Invention":
        script := "Disassembly"
        scriptDir := A_ScriptDir . "\Invention\Disassembly"

    Case "Sharp Shell Burning":
        script := "Shell Burning"
        scriptDir := A_ScriptDir . "\Sharp Shell Burning"

    Default:
        MsgBox, 48, Script Missing, No launch location is configured for:`n%selectedScript%
        return
}

; If the Case did not set a special filename, use script . ".ahk".
if (scriptFile = "")
	scriptFile := script . ".ahk"

; RunSelectedScript receives the actual directory and exact filename.
if !RunSelectedScript(scriptDir, scriptFile)
	return

Goto, exit
return

RunSelectedScript(ScriptDirectory, ScriptFile)
{
    ; Remove any trailing backslash.
	ScriptDirectory := RTrim(ScriptDirectory, "\")
	
    ; Build the exact script path.
	FullDiskPath := ScriptDirectory . "\" . ScriptFile
	
	if !FileExist(FullDiskPath)
	{
        ; Display the path relative to the selector's root folder.
		RootPrefix := RTrim(A_ScriptDir, "\") . "\"
		
		StringLower, LowerFullDiskPath, FullDiskPath
		StringLower, LowerRootPrefix, RootPrefix
		
		if (SubStr(LowerFullDiskPath, 1, StrLen(LowerRootPrefix)) = LowerRootPrefix)
			DisplayPath := SubStr(FullDiskPath, StrLen(RootPrefix) + 1)
		else
			DisplayPath := FullDiskPath
		
		Gui, Hide
		MsgBox, 48, Script Missing
            , The selected script could not be found.`n`nExpected Location:`nLLARS\%DisplayPath%
		Reload
		return false
	}
	
	Gui, TopGUI:Destroy
	Gui, BottomGUI:Destroy
	Gui, Info:Cancel
	Gui, Info:Destroy
	Gui, Border:Destroy
	Gui, Destroy
	
    ; Launch the script using ScriptDirectory as its working directory.
	Run, %FullDiskPath%, %ScriptDirectory%
	
	exitapp
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