#Requires AutoHotkey v1.1.37.02
#NoEnv
#SingleInstance Force

; LLARS ships the pinned AutoHotInterception runtime. The soft include keeps
; first launch working before AHI setup is complete and preserves fallback input.
#Include *i %A_ScriptDir%\Vendor\AutoHotInterception\Lib\AutoHotInterception.ahk
#Include %A_ScriptDir%\Core\LLARS_Timing.ahk
#Include %A_ScriptDir%\Core\LLARS_Config.ahk
#Include %A_ScriptDir%\Core\LLARS_CreatorRegistry.ahk
#Include %A_ScriptDir%\Core\LLARS_AHI.ahk
#Include %A_ScriptDir%\Core\LLARS_Update.ahk
#Include %A_ScriptDir%\Core\LLARS_Visual.ahk

EnvGet, LLARSValidationMode, LLARS_VALIDATION_MODE
if (LLARSValidationMode = "1")
	ExitApp

; Confirms the complete LLARS project structure is available before the
; Script Selector attempts to use project folders or launch scripts.
if (!FileExist(A_ScriptDir . "\Core")
|| !FileExist(A_ScriptDir . "\Scripts")
|| !FileExist(A_ScriptDir . "\Scripts - Menu Entry Swapper")
|| !FileExist(A_ScriptDir . "\LLARS Config.ini")
|| !FileExist(A_ScriptDir . "\VERSION"))
{
	Menu, Tray, NoIcon

	Gui Error: +LastFound +OwnDialogs +AlwaysOnTop
	LLARS_VisualPrepare("Error")
	Gui Error: Font, s13 Bold cEF4444, Segoe UI
	Gui Error: Add, Text, Center w220 x5, ERROR
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Font, s12 Bold c24324A, Segoe UI
	Gui Error: Add, Text, Center w220 x5, LLARS Project Files Missing
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Font, s10 Norm c24324A, Segoe UI
	Gui Error: Add, Text, Center w220 x5, The complete LLARS project could not be found.
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Add, Text, Center w220 x5, If you opened this file from a ZIP, RAR, or 7Z archive, extract the entire LLARS folder before running it.
	Gui Error: Font, s11 Bold c24324A, Segoe UI
	Gui Error: Add, Text, Center x5 w220,
	Gui Error: Add, Text, Center w220 x5, Created by Gubna
	Gui Error: Add, Button, gDiscordError w150 x40 Center, Discord
	Gui Error: Add, Button, gCloseError w150 x40 Center, Close Error

	Gui Error: +ToolWindow

	Gui Error: -caption
	Gui Error: Show, Center w230, File Error
	LLARS_VisualFinish("Error")

	return
}

LLARS_SelectorIconPath := A_ScriptDir . "\Assets\Logo\LLARS\LLARS Logo.ico"
if FileExist(LLARS_SelectorIconPath)
	Menu, Tray, Icon, %LLARS_SelectorIconPath%

; Loads the local release version used by update checks and GUI titles.
LLARS_GetVersion(A_ScriptDir)
if !LLARS_CheckConfigCompatibility(A_ScriptDir)
	ExitApp

; Close an older LLARS/script-selector window before any update prompt or Save As dialog.
CloseOtherLLARS()

; Keep the update indicator visible as a startup indicator through subsequent work.
; Selected scripts inherit the completed-check marker and do not check twice.
LLARS_StartupContinuation := true
LLARS_CheckForUpdates()
LLARS_StartupStage("Checking input setup...", "Checking keyboard and mouse input readiness.")

; Applies AHI input-backend setup/readiness checks before the selector opens.
; AHI is recommended; Standard AutoHotkey remains available as a fallback.
LLARS_AHI_StartupGate(A_ScriptDir, true)

; =======================================================================
; |     LLARS PATH SETUP     -     LLARS PATH SETUP                     |
; =======================================================================

; Script roots used by the Selector.
LLARS_SCRIPTS_DIR := A_ScriptDir . "\Scripts"
LLARS_MENU_ENTRY_SWAPPER_DIR := A_ScriptDir . "\Scripts - Menu Entry Swapper"

; ===================================================================
; |     ARRAY SETUP     -     ARRAY SETUP     -     ARRAY SETUP     |
; ===================================================================

; Authoritative Selector registry. Every display name, info-panel title, setup
; difficulty, description, and launch target is defined exactly once here.
LLARS_StartupStage("Loading available scripts...", "Reading script entries and their Setup requirements.")
LLARS_SelectorRegistryLoadError := ""
LLARS_SelectorRegistry := LLARS_SelectorBuildRegistry()
if (LLARS_SelectorRegistryLoadError != "")
{
    LLARS_HideUpdateCheckSplash()
	MsgBox, 262192, Script Selector Registry, % "Generated Creator registry is invalid. Existing entries were preserved.`n" . LLARS_SelectorRegistryLoadError
	ExitApp
}
LLARS_SelectorRegistryError := ""
if !LLARS_SelectorValidateRegistry(LLARS_SelectorRegistry, LLARS_SelectorRegistryError)
{
    LLARS_HideUpdateCheckSplash()
	MsgBox, 262192, Script Selector Registry, The Script Selector registry is invalid.`n`n%LLARS_SelectorRegistryError%
	ExitApp
}

LLARS_StartupStage("Preparing script choices...", "Restoring filters and preparing the script list.")
; Compatibility list generated from the registry for existing filter/preferences logic.
scriptArray := LLARS_SelectorRegistryNameList(LLARS_SelectorRegistry)
ScriptTotal := LLARS_SelectorRegistry.Entries.Length()
LLARS_SelectorCategoryList := LLARS_SelectorRegistryCategoryList(LLARS_SelectorRegistry)
LLARS_SelectorCategoryOptions := "All Categories" . (LLARS_SelectorCategoryList = "" ? "" : "|" . LLARS_SelectorCategoryList)

; Selector preferences reuse LLARS Config.ini so Favorites/Recent participate in
; the existing backup/restore workflow without introducing another state file.
LLARS_SelectorFavorites := ""
LLARS_SelectorRecent := ""
LLARS_SelectorFilteredCount := ScriptTotal
LLARS_SelectorLoadPreferences()

; ======================================================================
; |     HOTKEY SETUP     -     HOTKEY SETUP     -     HOTKEY SETUP     |
; ======================================================================

; Enter selects the highlighted script.
Hotkey, Enter, Select

; Ctrl+F jumps directly to selector search.
Hotkey, ^f, SelectorFocusSearch

; Escape closes the selector.
Hotkey, Esc, Exit

; =====================================================================================
; |     MAIN GUI CREATION     -     MAIN GUI CREATION     -     MAIN GUI CREATION     |
; =====================================================================================

; The status splash creates a named GUI. Always build Selector on GUI 1.
Gui, 1:Default
; Creates the script selector GUI.
Gui +LastFound +OwnDialogs +AlwaysOnTop -caption
Gui, +HwndLLARSSelectorHwnd
LLARS_VisualPrepare("1")
LLARS_VisualAccent("1", 420)
LLARS_VisualBanner("1", 420, 88)
LLARS_VisualCard("1", 8, 92, 404, 68)
LLARS_VisualCard("1", 8, 430, 404, 108)
LLARS_SelectorMoving := false
; Register borderless-window movement before the first handler label so these
; callbacks are active during the Selector's entire lifetime. Display changes
; are handled separately so normal dragging can cross monitor boundaries.
OnMessage(0x0201, "WM_LBUTTONDOWN")
OnMessage(0x0231, "WM_ENTERSIZEMOVE")
OnMessage(0x0232, "WM_EXITSIZEMOVE")
OnMessage(0x007E, "WM_DISPLAYCHANGE")
Gui, Font, s21 Bold cFFFFFF, Bahnschrift
Gui, Add, Text, Center w396 x12 y3 h36 BackgroundTrans, LLARS
Gui, Font, s9 Bold cE2EAF6, Segoe UI
Gui, Add, Text, Center w396 x12 y37 h28 +0x200 BackgroundTrans, Local Library of Automated Routines and Scripts
Gui, Font, s9 Bold c9DC9FF, Segoe UI
Gui, Add, Text, Center w396 x12 y68 h18 BackgroundTrans vTS, Showing: %ScriptTotal% of %ScriptTotal%
Gui, Font, s10 Norm c24324A, Segoe UI
Gui, Add, Edit, x12 y96 w250 h27 vSelectorSearch gSelectorFilterChanged hwndLLARSSelectorSearchHwnd
DllCall("SendMessageW", "Ptr", LLARSSelectorSearchHwnd, "UInt", 0x1501, "Ptr", 1, "WStr", "Search scripts...")
Gui, Add, DropDownList, x270 y96 w138 vSelectorView gSelectorFilterChanged Choose1, All Scripts|Favorites|Recent
Gui, Add, DropDownList, x12 y131 w126 vSelectorCategory gSelectorFilterChanged Choose1, %LLARS_SelectorCategoryOptions%
Gui, Add, DropDownList, x145 y131 w126 vSelectorDifficulty gSelectorFilterChanged Choose1, All Difficulties|Easy|Intermediate|Hard
Gui, Add, DropDownList, x278 y131 w130 vSelectorScriptFamily gSelectorFilterChanged Choose1, All Types|Normal|Menu Entry Swapper
Gui, Font, s9 Bold c60768F, Segoe UI
Gui, Add, Text, x20 y171 w250 h19, AVAILABLE SCRIPTS
Gui, Font, s11 Norm c24324A, Segoe UI
Gui, Add, ListBox, vScriptListBox gScriptSelect x12 y194 w396 h226, %scriptArray%
Gui, Font, s10 Bold c24324A, Segoe UI
Gui, Add, Button, gSelect w110 h34 x24 y446 Center, Select Script
Gui, Add, Button, gSelectorToggleFavorite w128 h34 x146 y446 vSelectorFavoriteButton Center, Add Favorite
Gui, Add, Button, gSelectorClearFilters w110 h34 x286 y446 Center, Clear Filters
Gui, Add, Button, gExit w128 h34 x146 y488 Center, Close Selector
if LLARS_SelectorLoadWindowPosition(selectorX, selectorY)
	selectorShowOptions := "w420 h550 x" . selectorX . " y" . selectorY
else
	selectorShowOptions := "w420 h550 Center"
Gui, Show, %selectorShowOptions%, Script Selector
LLARS_VisualWindow(LLARSSelectorHwnd)
LLARS_HideUpdateCheckSplash()
Gui, +ToolWindow
if FileExist(LLARS_SelectorIconPath)
{
	hIcon := DllCall("LoadImage", uint, 0, str, LLARS_SelectorIconPath, uint, 1, int, 0, int, 0, uint, 0x10)
	SendMessage, 0x80, 0, hIcon,, ahk_id %LLARSSelectorHwnd%
	SendMessage, 0x80, 1, hIcon,, ahk_id %LLARSSelectorHwnd%
}
CheckPOS(LLARSSelectorHwnd)
LLARS_SelectorSavePosition(LLARSSelectorHwnd)
LLARS_SelectorApplyFilter()
GuiControl, Focus, ScriptListBox

; Builds the single authoritative in-code catalog used by list, info, and launch paths.
LLARS_SelectorBuildRegistry()
{
	registry := {Entries: [], ByName: {}}
	LLARS_SelectorRegistryAdd(registry, "AFK Combat", "AFK Combat", "Intermediate", "Uses Agro pots/flasks to stay in combat for a predetermined length of time. Other pots/flasks can be used by changing the Config.ini", "AFK Combat", "AFK Combat.ahk", "Combat")
	LLARS_SelectorRegistryAdd(registry, "Alchemy", "Alchemy", "Easy", "Low/High Alchs a selected item(s) in your inventory for a predetermined amount of times.", "Alchemy", "Alchemy.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Amulet Stringer", "Amulet Stringer", "Easy", "Strings amulets by using in-game bank preset to make a predetermined amount of inventories of jewellery.", "Amulet Stringer", "Amulet Stringer.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Anti-AFK", "Anti-AFK", "Easy", "Moves the mouse within the RuneScape client border, based on a random timer configured through Config.ini", "Anti-AFK", "Anti-AFK.ahk", "Utility")
	LLARS_SelectorRegistryAdd(registry, "Armour Crafter", "Armour Crafter", "Intermediate", "Crafts your selected armour for a predetermined amount of runs.", "Armour Crafter", "Armour Crafter.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Arrow Fletcher", "Arrow Fletcher", "Easy", "Adds the tip to a headless arrow. Can be used for darts and/or bolts.", "Arrow Fletcher", "Arrow Fletcher.ahk", "Fletching")
	LLARS_SelectorRegistryAdd(registry, "Ash to Incense", "Ash to Incense", "Easy", "Adds ash to an already crafted incense stick. Use this after 'Incense Crafter' and before 'Herb to Incense'.", "Incense\Ash to Incense", "Ash to Incense.ahk", "Firemaking")
	LLARS_SelectorRegistryAdd(registry, "AutoClicker", "AutoClicker", "Easy", "Clicks randomly within a predetermined coordinate range set by the user. Timer for the clicks can be changed in the Config.ini", "AutoClicker", "AutoClicker.ahk", "Utility")
	LLARS_SelectorRegistryAdd(registry, "AutoTele", "AutoTele", "Easy", "Casts the same Teleportation spell a set number of times using hotkeys.", "AutoTele", "AutoTele.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Bake Pie - Lunar Spell", "Bake Pie", "Easy", "Bakes all uncooked pies in your inventory.", "Lunar Spells\Bake Pie", "Bake Pie.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Bar Smelter", "Bar Smelter", "Intermediate", "Creates metal bars, type of bar is set by the user as is the run count.", "Bar Smelter", "Bar Smelter.ahk", "Smithing")
	LLARS_SelectorRegistryAdd(registry, "Bar Smelter - Smelting Gloves", "Smelting Glove", "Intermediate", "Uses the Smelting Gauntlets from Family Crest Quest to make Gold Bars. Smelted Gold Bars go to metal bank and not inventory.", "Bar Smelter", "Smelting Glove.ahk", "Smithing")
	LLARS_SelectorRegistryAdd(registry, "Agility - Barbarian - Advanced", "Barbarian Course", "Hard", "Runs laps of the Barbarian - Advanced agility course. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Barbarian\Advanced", "Barbarian Course.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Agility - Barbarian - Basic", "Barbarian Course", "Hard", "Runs laps of the Barbarian - Basic agility course. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Barbarian\Basic", "Barbarian Course.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Bones 2 Bananas", "Bones 2 Bananas", "Easy", "Turns all normal bones, big bones and monkey bones in your inventory into bananas.", "Bones 2 Bananas", "Bones 2 Bananas.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Bow Cutter", "Bow Cutter", "Intermediate", "Cuts logs into unstrung bows. Use 'Bow Stringer' to string the bows after.", "Bow Cutter", "Bow Cutter.ahk", "Fletching")
	LLARS_SelectorRegistryAdd(registry, "Bow Stringer", "Bow Stringer", "Easy", "Combines bowstring with unstrung bows using the in-game bank preset hotkey.", "Bow Stringer", "Bow Stringer.ahk", "Fletching")
	LLARS_SelectorRegistryAdd(registry, "Brick Maker - Fort Forinthry", "Limestone Brick", "Hard", "Cuts limtestone into limestone bricks using the stonecutter.", "Fort Forinthry\Limestone Brick", "Brick Maker.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Agility - Burthorpe", "Burthorpe", "Hard", "Runs laps of the Burthorpe agility course. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Burthorpe", "Burthorpe.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Candle Crafter", "Candle Crafter", "Easy", "Crafts candles for the Necromancy skill.", "Necromancy\Candle Crafter", "Candle Crafter.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Herb Cleaner - Skillcape", "Skillcape Cleaner", "Easy", "Uses the 99/120 Herblore Skillcape to instantly clean a full inventory of dirty herbs. Requires the Skillcape to be worn.", "Herb Cleaner - Skillcape", "Skillcape Cleaner.ahk", "Herblore")
	LLARS_SelectorRegistryAdd(registry, "Cooking - Burthorpe", "Cooking", "Hard", "Walks between the Range and main bank in Burthorpe to cook an inventory of food. Fort Forinthry cooking is recommended over this script.", "Cooking", "Cooking.ahk", "Cooking")
	LLARS_SelectorRegistryAdd(registry, "Cooking - Fort Forinthry", "Cooking", "Hard", "Cooks food at the Fort using the bank chest next to the Range.", "Fort Forinthry\Cooking", "Cooking.ahk", "Cooking")
	LLARS_SelectorRegistryAdd(registry, "Fire Urn - Lunar Spell", "Fire Urn", "Easy", "Uses the Lunar Spell 'Fire Urn' to fire an inventory of unfired urns.", "Lunar Spells\Fire Urn", "Fire Urn.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Frame Maker - Fort Forinthry", "Frame Maker", "Hard", "Walks between the bank chest and woodworking bench to make frames.", "Fort Forinthry\Frame Maker", "Frame Maker.ahk", "Construction")
	LLARS_SelectorRegistryAdd(registry, "Gem Cutter", "Gem Cutter", "Easy", "Cuts an inventory of uncut gems, opens the bank, withdraws more, and repeats.", "Gem Cutter", "Gem Cutter.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Glassblowing", "Glassblowing", "Intermediate", "Turns molten glass into your selected glass item. Crafts full inventories, banks, and repeats.", "Glassblowing", "Glassblowing.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Agility - Gnome - Advanced", "Gnome Course", "Hard", "Runs laps of the Gnome - Advanced agility course. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Gnome\Advanced", "Gnome Course.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Agility - Gnome - Basic", "Gnome Course", "Hard", "Runs laps of the Gnome - Basic agility course. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Gnome\Basic", "Gnome Course.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Herb to Incense", "Herb to Incense", "Easy", "Adds a herb to an ashy incense stick. Use 'Ash to Incense' first or ashy incense sticks from the Grand Exchange.", "Incense\Herb to Incense", "Herb to Incense.ahk", "Firemaking")
	LLARS_SelectorRegistryAdd(registry, "Herb Cleaner", "Herb Cleaner", "Easy", "Cleans full inventories of dirty herbs.", "Herb Cleaner", "Herb Cleaner.ahk", "Herblore")
	LLARS_SelectorRegistryAdd(registry, "Agility - Het's Oasis", "Het's Oasis", "Hard", "Runs laps of the Het's Oasis agility course. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Het's Oasis", "Het's Oasis.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Incense Crafter", "Incense Crafter", "Easy", "Cuts logs into incense sticks. Use this before 'Ash to Incense'.", "Incense\Incense Crafter", "Incense Crafter.ahk", "Firemaking")
	LLARS_SelectorRegistryAdd(registry, "Ink Crafter", "Ink Crafter", "Easy", "Crafts ink for the Necromancy skill.", "Necromancy\Ink Crafter", "Ink Crafter.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Jewellery Crafter - Lumbridge", "Jewellery Crafter", "Hard", "Runs between the Combat Academy bank chest and Lumbridge Furnace to craft your selected Jewellery. Config.ini needs manual setup to work.", "Jewellery Crafter", "Jewellery Crafter.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Jewellery Crafter - Fort Forinthry", "Jewellery Crafter", "Hard", "Runs between the bank chest and furnace at the Fort to craft your selected Jewellery. Config.ini needs manual setup to work.", "Fort Forinthry\Jewellery Crafter", "Jewellery Crafter.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Jewellery Enchanter", "Jewel Enchant", "Easy", "Casts the selected 'Enchanted Cast' spell to enchant jewellery in your inventory.", "Jewellery Enchant", "Jewel Enchant.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Jewellery Stringer - Lunar Spell", "String Jewellery", "Easy", "String an inventory of jewellery using the Lunar Spell.", "Lunar Spells\String Jewellery", "Jewel Stringer.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Plank + Refined - Fort Forinthry", "Plank + Refined", "Hard", "Cuts and refines the plank at the Fort.", "Fort Forinthry\Plank + Refined", "Plank + Refined.ahk", "Construction")
	LLARS_SelectorRegistryAdd(registry, "Plank Maker - Fort Forinthry", "Plank Maker", "Hard", "Cuts logs into planks using the sawmill at the Fort.", "Fort Forinthry\Plank Maker", "Plank Maker.ahk", "Construction")
	LLARS_SelectorRegistryAdd(registry, "Potion Mixer", "Potion Mixer", "Easy", "Combines an inventory of ingredients to make potions.", "Potion Mixer", "Potion Mixer.ahk", "Herblore")
	LLARS_SelectorRegistryAdd(registry, "Prayer", "Prayer", "Easy", "Buries an inventory of bones or scatters an inventory of ashes. This is a bank-standing script and does not work with altars.", "Prayer", "Prayer.ahk", "Prayer")
	LLARS_SelectorRegistryAdd(registry, "Pyre Crafter", "Pyre Crafter", "Easy", "Adds Sacred Oil to logs to craft Pyre Logs.", "Pyre Crafter", "Pyre Crafter.ahk", "Firemaking")
	LLARS_SelectorRegistryAdd(registry, "Refined Plank - Fort Forinthry", "Refined Planks", "Hard", "Refines planks at the sawmill so they can be used to make frames.", "Fort Forinthry\Refined Plank", "Refined Plank.ahk", "Construction")
	LLARS_SelectorRegistryAdd(registry, "Rituals - Communion & Material - Focus Storage", "Rituals", "Hard", "Performs the Communion && Material ritual using the focus storage for material. Place materials for rituals into focus storage for this to work.", "Necromancy\Rituals\Communion & Material\Focus Storage", "Rituals.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Rituals - Communion & Material - Without Storage", "Rituals", "Hard", "Performs the Communion && Material ritual using the player inventory for material. Keep materials in your inventory and do not use the focus storage.", "Necromancy\Rituals\Communion & Material\Without Focus Storage", "Rituals.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Rituals - Ectoplasm - Focus Storage", "Rituals", "Hard", "Performs the Ectoplasm ritual using the focus storage for material. Place materials for rituals into focus storage for this to work.", "Necromancy\Rituals\Ectoplasm\Focus Storage", "Rituals.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Rituals - Ectoplasm - Without Storage", "Rituals", "Hard", "Performs the Ectoplasm ritual using the player inventory for material. Keep materials in your inventory and do not use the focus storage.", "Necromancy\Rituals\Ectoplasm\Without Focus Storage", "Rituals.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Rituals - Essence & Necroplasm - Focus Storage", "Rituals", "Hard", "Performs the Essence && Necroplasm ritual using the focus storage for material. Place materials for rituals into focus storage for this to work.", "Necromancy\Rituals\Essence & Necroplasm\Focus Storage", "Rituals.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Rituals - Essence & Necroplasm - Without Storage", "Rituals", "Hard", "Performs the Essence && Necroplasm ritual using the player inventory for material. Keep materials in your inventory and do not use the focus storage.", "Necromancy\Rituals\Essence & Necroplasm\Without Focus Storage", "Rituals.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Sift Soil - Lunar Spell", "Sift Soil", "Easy", "Uses the Lunar Spell Sift Soil to screen various soils.", "Lunar Spells\Sift Soil", "Sift Soil.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Slime Collector", "Slime Collector", "Easy", "Collects Buckets of Slime and uses them on magic/enchanted notepaper to note them before collecting more slime.", "Necromancy\Slime Collector - Notepaper", "Slime Collector.ahk", "Necromancy")
	LLARS_SelectorRegistryAdd(registry, "Smithing", "Smithing", "Intermediate", "An underpowered smithing script best used for making arrowheads and dart tips. Can be used to smith any item, but does not currently support reheating the forge.", "Smithing", "Smithing.ahk", "Smithing")
	LLARS_SelectorRegistryAdd(registry, "Stone Wall - Fort Forinthry", "Stone Wall", "Hard", "Turns limestone bricks into wall segments at the stonecutter in the Fort.", "Fort Forinthry\Stone Wall", "Stone Wall.ahk", "Construction")
	LLARS_SelectorRegistryAdd(registry, "Tele Grind - Lunar Spell - No Banking", "Tele Grind", "Easy", "Casts the Lunar Spell Telekinetic Grind to grind any eligible items in your inventory.", "Lunar Spells\Telekinetic Grind\Telekinetic Grind with No Banking", "Tele Grind.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Tele Grind - Lunar Spell - With Banking", "Tele Grind", "Easy", "Casts the Lunar Spell Telekinetic Grind to grind any eligible items in your inventory. Does not support banking, assumes items stack in inventory.", "Lunar Spells\Telekinetic Grind\Telekinetic Grind with Banking", "Tele Grind.ahk", "Magic")
	LLARS_SelectorRegistryAdd(registry, "Agility - Watchtower Shortcut", "Watchtower Shortcut", "Hard", "Runs laps of the Watchtower Shortcut. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Watchtower Shortcut", "Watchtower.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Agility - Wilderness", "Wilderness", "Hard", "Runs laps of the Wilderness agility course. Can be tricky to configure coordinates due to large amounts of walking.", "Agility\Wilderness", "Wilderness.ahk", "Agility")
	LLARS_SelectorRegistryAdd(registry, "Wine Maker", "Wine Maker", "Easy", "Combines jugs of water with grapes with make jugs of wine.", "Wine Maker", "Wine Maker.ahk", "Cooking")
	LLARS_SelectorRegistryAdd(registry, "Contract Binding", "Contract Binding", "Hard", "Creates Binding Contracts at the obelisk in Taverly.", "Contract Binding", "Contract Binding.ahk", "Summoning")
	LLARS_SelectorRegistryAdd(registry, "Fletching - Corrupted Magic Logs", "Fletching", "Easy", "Fletches corrupted magic logs. This method 'destroys' the log and leaves the inventory empty.", "Fletching - Corrupted Magic Logs", "Fletching.ahk", "Fletching")
	LLARS_SelectorRegistryAdd(registry, "Prifddinas - Cooking", "Cooking", "Hard", "Uses the bonfire in the Tower of Voices to cook.", "Prifddinas\Cooking", "Cooking.ahk", "Cooking")
	LLARS_SelectorRegistryAdd(registry, "Prifddinas - Firemaking", "Firemaking", "Hard", "Uses the bonfire in the Tower of Voices to burn logs.", "Prifddinas\Firemaking", "Firemaking.ahk", "Firemaking")
	LLARS_SelectorRegistryAdd(registry, "Spinning Wheel - Fort Forinthry", "Spinning Wheel", "Hard", "Crafts various items using the spinning wheel in the Rangers Workshop.", "Fort Forinthry\Spinning Wheel", "Spinning Wheel.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Spinning Wheel - Fungal Bowstring - Fort Forinthry", "Fungal Bowstring", "Easy", "Creates fungal bowstrings using the spinning wheel in the Rangers Workshop.", "Fort Forinthry\Spinning Wheel", "Fungal Bowstring.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Disassembly - Invention", "Disassembly", "Easy", "Disassembles items using a hotkey to gather materials for the Invention skill.", "Invention\Disassembly", "Disassembly.ahk", "Invention")
	LLARS_SelectorRegistryAdd(registry, "Sharp Shell Burning", "Sharp Shell Burning", "Easy", "Uses the Right-Click Ignite option on Sharp Shell Shards for Firemaking XP.", "Sharp Shell Burning", "Shell Burning.ahk", "Firemaking")
	LLARS_SelectorRegistryAdd(registry, "Archaeology - Excavate", "Archaeology - Excavate", "Hard", "Monitors Archaeology XP through ALT1 AfkWarden and reacts when XP gains stop. ALT1 with AfkWarden is required.", "Archaeology\Excavate", "Excavate.ahk", "Archaeology")
	LLARS_SelectorRegistryAdd(registry, "Croesus Front", "Croesus Front", "Hard", "Monitors XP through ALT1 AfkWarden and clicks the configured Decaying Guard location when XP gains stop. ALT1 with AfkWarden is required.", "Croesus Front", "Croesus Front.ahk", "Hunter")
	LLARS_SelectorRegistryAdd(registry, "Eternal Tree", "Eternal Tree", "Easy", "Finds and cuts Eternal Trees using built-in color detection, then tracks the selected tree until it is depleted before finding the next one.", "Eternal Tree", "Eternal Tree.ahk", "Woodcutting")
	LLARS_SelectorRegistryAdd(registry, "Waterfall Fishing", "Waterfall Fishing", "Hard", "Monitors Waterfall Fishing XP through ALT1 AfkWarden and clicks the configured fishing spot when XP gains stop. ALT1 with AfkWarden is required.", "Waterfall Fishing", "Waterfall Fishing.ahk", "Fishing")
	LLARS_SelectorRegistryAdd(registry, "Divination - Divine Conversion - Monolith Power", "Divination - Divine Conversion - Monolith Power", "Easy", "Use RuneScape High Contrast Mode. Finds resources with enriched priority, tracks depletion, and handles full inventories using the Divine Conversion - Monolith Power.", "Divination\Divine Conversion - Monolith Power", "Divination - High Contrast.ahk", "Divination")
	LLARS_SelectorRegistryAdd(registry, "Divination - Normal - Non-Monolith Power", "Divination - Normal - Non-Monolith Power", "Easy", "Use RuneScape High Contrast Mode. Finds resources with enriched priority, tracks depletion, and handles full inventories using the Normal - Non-Monolith Power.", "Divination\Normal - Non-Monolith Power", "Divination - High Contrast.ahk", "Divination")
	; Menu Entry Swapper variants are separate launch targets and never replace the normal scripts.
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Amulet Stringer")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Armour Crafter")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Bones 2 Bananas")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Bow Cutter")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Bow Stringer")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Cooking - Burthorpe")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Fletching - Corrupted Magic Logs")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Cooking - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Frame Maker - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Jewellery Crafter - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Brick Maker - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Plank + Refined - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Plank Maker - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Refined Plank - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Spinning Wheel - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Stone Wall - Fort Forinthry")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Gem Cutter")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Glassblowing")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Herb Cleaner")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Herb Cleaner - Skillcape")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Ash to Incense")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Herb to Incense")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Incense Crafter")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Jewellery Crafter - Lumbridge")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Jewellery Enchanter")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Bake Pie - Lunar Spell")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Fire Urn - Lunar Spell")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Sift Soil - Lunar Spell")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Jewellery Stringer - Lunar Spell")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Tele Grind - Lunar Spell - With Banking")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Ink Crafter")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Potion Mixer")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Prayer")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Prifddinas - Cooking")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Prifddinas - Firemaking")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Pyre Crafter")
	LLARS_SelectorRegistryAddMenuEntrySwapper(registry, "Wine Maker")

	; Generator-managed entries join the one authoritative registry, rather
	; than maintaining a second independent Selector list or editing shipped rows.
	global LLARS_SelectorRegistryLoadError
	created := LLARS_CreatorRegistryRead(A_ScriptDir, LLARS_SelectorRegistryLoadError)
	if (LLARS_SelectorRegistryLoadError != "")
		return registry
	for _, item in created
	{
		; Deleted user scripts do not prevent the shipped Selector from opening.
		; If restored, their registered metadata becomes visible again.
		target := A_ScriptDir . "\" . item.RootDirectory . "\" . item.RelativeDirectory . "\" . item.FileName
		if !FileExist(target)
			continue
		LLARS_SelectorRegistryAdd(registry, item.Name, item.InfoTitle, item.Difficulty
			, item.Description, item.RelativeDirectory, item.FileName, item.Category
			, item.RootDirectory, item.ScriptFamily)
	}

	return registry
}

LLARS_SelectorRegistryAdd(ByRef registry, Name, InfoTitle, Difficulty, Description, RelativeDirectory, FileName, Category, RootDirectory := "Scripts", ScriptFamily := "Normal")
{
	scriptDir := A_ScriptDir . "\" . RootDirectory . "\" . RelativeDirectory
	scriptPath := scriptDir . "\" . FileName
	configPath := scriptDir . "\Config.ini"
	capabilities := LLARS_ConfigCapabilityScan(configPath, scriptPath)
	record := {Name: Name, InfoTitle: InfoTitle, Difficulty: Difficulty, Description: Description, RelativeDirectory: RelativeDirectory, FileName: FileName, Category: Category
		, RootDirectory: RootDirectory, ScriptFamily: ScriptFamily
		, Capabilities: capabilities, SetupType: capabilities.SetupType, SetupText: capabilities.SetupText, RequiresLocalConfig: capabilities.RequiresLocalConfig}
	registry.Entries.Push(record)
	registry.ByName[Name] := record
	return record
}

LLARS_SelectorRegistryAddMenuEntrySwapper(ByRef registry, SourceName)
{
	if !registry.ByName.HasKey(SourceName)
		return ""

	source := registry.ByName[SourceName]
	description := source.Description
	description := StrReplace(description, "by using in-game bank preset", "using Menu Entry Swapper banking")
	description := StrReplace(description, "using the in-game bank preset hotkey", "using Menu Entry Swapper banking")
	description .= " This version uses the bank interaction to load the last preset automatically and does not press a Bank Preset hotkey."
	return LLARS_SelectorRegistryAdd(registry
		, source.Name . " - MES"
		, source.InfoTitle . " - MES"
		, source.Difficulty
		, description
		, source.RelativeDirectory
		, source.FileName
		, source.Category
		, "Scripts - Menu Entry Swapper"
		, "Menu Entry Swapper")
}

LLARS_SelectorValidateRegistry(registry, ByRef errorDetail := "")
{
	errorDetail := ""
	if !IsObject(registry) || !IsObject(registry.Entries) || !IsObject(registry.ByName)
	{
		errorDetail := "Registry container is unavailable."
		return false
	}

	seenNames := {}
	seenTargets := {}
	for index, record in registry.Entries
	{
		if !IsObject(record)
		{
			errorDetail := "Registry entry " . index . " is not an object."
			return false
		}

		if (record.Name = "" || record.InfoTitle = "" || record.Description = "" || record.RelativeDirectory = "" || record.FileName = "" || record.RootDirectory = "" || record.ScriptFamily = "")
		{
			errorDetail := "Registry entry " . index . " has an empty required field."
			return false
		}

		if (record.Difficulty != "Easy" && record.Difficulty != "Intermediate" && record.Difficulty != "Hard")
		{
			errorDetail := "Registry entry " . record.Name . " has an invalid setup difficulty."
			return false
		}

		if (record.Category = "")
		{
			errorDetail := "Registry entry " . record.Name . " has an empty category."
			return false
		}

		if (record.ScriptFamily != "Normal" && record.ScriptFamily != "Menu Entry Swapper")
		{
			errorDetail := "Registry entry " . record.Name . " has an invalid script family."
			return false
		}

		if !IsObject(record.Capabilities)
		{
			errorDetail := "Registry entry " . record.Name . " has no derived setup capability object."
			return false
		}

		if (record.SetupType != record.Capabilities.SetupType || record.SetupText != record.Capabilities.SetupText || record.RequiresLocalConfig != record.Capabilities.RequiresLocalConfig)
		{
			errorDetail := "Registry entry " . record.Name . " does not match its derived setup capabilities."
			return false
		}

		nameKey := record.Name
		StringLower, nameKey, nameKey
		if seenNames.HasKey(nameKey)
		{
			errorDetail := "Duplicate Selector display name: " . record.Name
			return false
		}
		seenNames[nameKey] := true

		targetPath := A_ScriptDir . "\" . record.RootDirectory . "\" . record.RelativeDirectory . "\" . record.FileName
		if !FileExist(targetPath)
		{
			errorDetail := "Missing Selector target: " . record.Name . " -> " . targetPath
			return false
		}

		targetKey := targetPath
		StringLower, targetKey, targetKey
		if seenTargets.HasKey(targetKey)
		{
			errorDetail := "Duplicate Selector target: " . record.Name
			return false
		}
		seenTargets[targetKey] := true
	}

	return true
}

LLARS_SelectorRegistryNameList(registry)
{
	names := ""
	if !IsObject(registry) || !IsObject(registry.Entries)
		return names

	for _, record in registry.Entries
		names .= (names = "" ? "" : "|") . record.Name
	return names
}

LLARS_SelectorRegistryCategoryList(registry)
{
	categories := ""
	seen := {}
	if !IsObject(registry) || !IsObject(registry.Entries)
		return categories

	for _, record in registry.Entries
	{
		if (record.Category = "" || seen.HasKey(record.Category))
			continue
		seen[record.Category] := true
		categories .= (categories = "" ? "" : "|") . record.Category
	}
	if (categories != "")
		Sort, categories, D|
	return categories
}

LLARS_SelectorGetRecord(scriptName)
{
	global LLARS_SelectorRegistry
	if (scriptName = "" || !IsObject(LLARS_SelectorRegistry) || !IsObject(LLARS_SelectorRegistry.ByName))
		return ""
	if !LLARS_SelectorRegistry.ByName.HasKey(scriptName)
		return ""
	return LLARS_SelectorRegistry.ByName[scriptName]
}

; Loads persistent selector Favorites/Recent from the existing LLARS Config.ini.
LLARS_SelectorLoadPreferences()
{
	global LLARS_SelectorFavorites, LLARS_SelectorRecent
	configPath := A_ScriptDir . "\LLARS Config.ini"

	favorites := LLARS_ConfigReadFile(configPath, "Script Selector", "favorites", "")
	recent := LLARS_ConfigReadFile(configPath, "Script Selector", "recent", "")

	LLARS_SelectorFavorites := LLARS_SelectorSanitizePreferenceList(favorites, 0)
	LLARS_SelectorRecent := LLARS_SelectorSanitizePreferenceList(recent, 5)
	return true
}

LLARS_SelectorLoadWindowPosition(ByRef x, ByRef y)
{
	configPath := A_ScriptDir . "\LLARS Config.ini"
	x := LLARS_ConfigReadFile(configPath, "Script Selector", "window_x", "")
	y := LLARS_ConfigReadFile(configPath, "Script Selector", "window_y", "")
	return RegExMatch(x, "^-?\d+$") && RegExMatch(y, "^-?\d+$")
}

LLARS_SelectorSavePosition(hwnd)
{
	if (!hwnd)
		return false
	WinGetPos, x, y,,, ahk_id %hwnd%
	if (x = "" || y = "")
		return false
	configPath := A_ScriptDir . "\LLARS Config.ini"
	if !LLARS_ConfigWriteFile(configPath, "Script Selector", "window_x", x)
		return false
	return LLARS_ConfigWriteFile(configPath, "Script Selector", "window_y", y)
}

; Keeps only current selector names and removes duplicates from persisted lists.
LLARS_SelectorSanitizePreferenceList(listText, maxItems := 0)
{
	if (listText = "" || listText = "ERROR")
		return ""

	clean := ""
	count := 0
	for _, item in StrSplit(listText, "|")
	{
		item := Trim(item)
		if (item = "" || !LLARS_SelectorScriptExists(item) || LLARS_SelectorListContains(clean, item))
			continue
		clean .= (clean = "" ? "" : "|") . item
		count++
		if (maxItems > 0 && count >= maxItems)
			break
	}
	return clean
}

LLARS_SelectorScriptExists(scriptName)
{
	return IsObject(LLARS_SelectorGetRecord(scriptName))
}

LLARS_SelectorListContains(listText, scriptName)
{
	if (listText = "" || scriptName = "")
		return false
	for _, item in StrSplit(listText, "|")
	{
		if (item = scriptName)
			return true
	}
	return false
}

; Stores only selector preferences in the existing root LLARS Config.ini.
LLARS_SelectorSavePreferences()
{
	global LLARS_SelectorFavorites, LLARS_SelectorRecent
	configPath := A_ScriptDir . "\LLARS Config.ini"
	if !LLARS_ConfigWriteFile(configPath, "Script Selector", "favorites", LLARS_SelectorFavorites)
		return false
	return LLARS_ConfigWriteFile(configPath, "Script Selector", "recent", LLARS_SelectorRecent)
}

; Records the last five successfully selected scripts, newest first.
LLARS_SelectorRememberRecent(scriptName)
{
	global LLARS_SelectorRecent
	if (scriptName = "" || !LLARS_SelectorScriptExists(scriptName))
		return false

	updated := scriptName
	count := 1
	for _, item in StrSplit(LLARS_SelectorRecent, "|")
	{
		if (item = "" || item = scriptName)
			continue
		updated .= "|" . item
		count++
		if (count >= 5)
			break
	}
	LLARS_SelectorRecent := updated
	LLARS_SelectorSavePreferences()
	return true
}

; Applies live Search plus All/Favorites/Recent without maintaining a second script catalog.
LLARS_SelectorApplyFilter()
{
	global scriptArray, ScriptTotal, LLARS_SelectorFavorites, LLARS_SelectorRecent
	global LLARS_SelectorFilteredCount

	GuiControlGet, searchText, , SelectorSearch
	GuiControlGet, selectorView, , SelectorView
	GuiControlGet, selectorCategory, , SelectorCategory
	GuiControlGet, selectorDifficulty, , SelectorDifficulty
	GuiControlGet, selectorScriptFamily, , SelectorScriptFamily
	searchText := Trim(searchText)

	if (selectorView = "Recent")
		baseList := LLARS_SelectorRecent
	else
		baseList := scriptArray

	filtered := ""
	count := 0
	for _, scriptName in StrSplit(baseList, "|")
	{
		if (scriptName = "")
			continue
		if (selectorView = "Favorites" && !LLARS_SelectorListContains(LLARS_SelectorFavorites, scriptName))
			continue
		record := LLARS_SelectorGetRecord(scriptName)
		if !IsObject(record)
			continue
		if (selectorCategory != "All Categories" && record.Category != selectorCategory)
			continue
		if (selectorDifficulty != "All Difficulties" && record.Difficulty != selectorDifficulty)
			continue
		if (selectorScriptFamily != "All Types" && record.ScriptFamily != selectorScriptFamily)
			continue
		if (searchText != "" && !InStr(scriptName, searchText, false))
			continue
		filtered .= (filtered = "" ? "" : "|") . scriptName
		count++
	}

	; All/Favorites stay alphabetical; Recent deliberately preserves launch order.
	if (selectorView != "Recent" && filtered != "")
		Sort, filtered, D|

	LLARS_SelectorFilteredCount := count
	GuiControl, , ScriptListBox, |%filtered%
	GuiControl, , TS, % "Showing: " . count . " of " . ScriptTotal
	if (count > 0)
		GuiControl, Choose, ScriptListBox, 1

	GuiReset()
	LLARS_SelectorUpdateFavoriteButton()
	return count
}

LLARS_SelectorUpdateFavoriteButton()
{
	global LLARS_SelectorFavorites
	GuiControlGet, selectedScript, , ScriptListBox
	if (selectedScript != "" && LLARS_SelectorListContains(LLARS_SelectorFavorites, selectedScript))
		buttonText := "Remove Favorite"
	else
		buttonText := "Add Favorite"
	GuiControl, , SelectorFavoriteButton, %buttonText%
	return true
}

SelectorFilterChanged:
LLARS_SelectorApplyFilter()
return

SelectorFocusSearch:
GuiControl, Focus, SelectorSearch
return

SelectorToggleFavorite:
GuiControlGet, selectedScript, , ScriptListBox
if (selectedScript = "")
	return
if LLARS_SelectorListContains(LLARS_SelectorFavorites, selectedScript)
{
	updated := ""
	for _, item in StrSplit(LLARS_SelectorFavorites, "|")
	{
		if (item = "" || item = selectedScript)
			continue
		updated .= (updated = "" ? "" : "|") . item
	}
	LLARS_SelectorFavorites := updated
}
else
{
	LLARS_SelectorFavorites .= (LLARS_SelectorFavorites = "" ? "" : "|") . selectedScript
}
LLARS_SelectorSavePreferences()
GuiControlGet, selectorView, , SelectorView
if (selectorView = "Favorites")
	LLARS_SelectorApplyFilter()
else
	LLARS_SelectorUpdateFavoriteButton()
return

SelectorClearFilters:
GuiControl, , SelectorSearch,
GuiControl, ChooseString, SelectorView, All Scripts
GuiControl, ChooseString, SelectorCategory, All Categories
GuiControl, ChooseString, SelectorDifficulty, All Difficulties
GuiControl, ChooseString, SelectorScriptFamily, All Types
LLARS_SelectorApplyFilter()
GuiControl, Focus, SelectorSearch
return

; ==================================================================================
; |     FUNCTION STORAGE     -     FUNCTION STORAGE     -     FUNCTION STORAGE     |
; ==================================================================================

; Allows the borderless Selector to be dragged from its background/header
; without stealing clicks from interactive controls. The move is intentionally
; unclamped until Windows ends the drag so crossing monitor boundaries works.
WM_LBUTTONDOWN(wParam := 0, lParam := 0, msg := 0, hwnd := 0) {
	global LLARSSelectorHwnd, LLARS_SelectorMoving
	if (!LLARSSelectorHwnd || !hwnd)
		return

	rootHwnd := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")
	if (rootHwnd != LLARSSelectorHwnd)
		return

	WinGetClass, clickedClass, ahk_id %hwnd%
	if (hwnd != LLARSSelectorHwnd && clickedClass != "Static")
		return

	LLARS_SelectorMoving := true
	PostMessage, 0xA1, 2,,, ahk_id %LLARSSelectorHwnd%
}

WM_ENTERSIZEMOVE(wParam := 0, lParam := 0, msg := 0, hwnd := 0) {
	global LLARSSelectorHwnd, LLARS_SelectorMoving
	if (hwnd = LLARSSelectorHwnd)
		LLARS_SelectorMoving := true
}

WM_EXITSIZEMOVE(wParam := 0, lParam := 0, msg := 0, hwnd := 0) {
	global LLARSSelectorHwnd, LLARS_SelectorMoving
	if (hwnd = LLARSSelectorHwnd)
	{
		LLARS_SelectorMoving := false
		CheckPOS(hwnd)
		LLARS_SelectorSavePosition(hwnd)
	}
}

; Recover the Selector after monitor attach/detach or desktop topology changes
; without continuously clamping the window during a user drag.
WM_DISPLAYCHANGE(wParam := 0, lParam := 0, msg := 0, hwnd := 0) {
	global LLARSSelectorHwnd, LLARS_SelectorMoving
	if (!LLARS_SelectorMoving && LLARSSelectorHwnd)
	{
		CheckPOS(LLARSSelectorHwnd)
		LLARS_SelectorSavePosition(LLARSSelectorHwnd)
	}
}

; Keeps the Selector inside the work area of the monitor nearest the window.
; This supports negative desktop coordinates and monitor removal without assuming
; the primary display dimensions.
CheckPOS(hwnd := "")
{
	global LLARSSelectorHwnd
	if (hwnd = "")
		hwnd := LLARSSelectorHwnd
	if (!hwnd || hwnd != LLARSSelectorHwnd)
		return

	WinGetPos, GUIx, GUIy, GUIw, GUIh, ahk_id %hwnd%
	if (GUIw = "" || GUIh = "")
		return

	hMonitor := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
	if (hMonitor)
	{
		VarSetCapacity(monitorInfo, 40, 0)
		NumPut(40, monitorInfo, 0, "UInt")
		if DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", &monitorInfo)
		{
			workLeft := NumGet(monitorInfo, 20, "Int")
			workTop := NumGet(monitorInfo, 24, "Int")
			workRight := NumGet(monitorInfo, 28, "Int")
			workBottom := NumGet(monitorInfo, 32, "Int")
		}
	}

	if (workRight = "" || workBottom = "")
	{
		SysGet, workLeft, 76
		SysGet, workTop, 77
		SysGet, virtualWidth, 78
		SysGet, virtualHeight, 79
		workRight := workLeft + virtualWidth
		workBottom := workTop + virtualHeight
	}

	X := GUIx
	Y := GUIy
	maxX := workRight - GUIw
	maxY := workBottom - GUIh
	if (maxX < workLeft)
		maxX := workLeft
	if (maxY < workTop)
		maxY := workTop

	if (X < workLeft)
		X := workLeft
	if (Y < workTop)
		Y := workTop
	if (X > maxX)
		X := maxX
	if (Y > maxY)
		Y := maxY

	if (X != GUIx || Y != GUIy)
		WinMove, ahk_id %hwnd%,, X, Y
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

GuiReset()
{
    Gui Info: Destroy
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
	LLARS_SelectorUpdateFavoriteButton()
	record := LLARS_SelectorGetRecord(selectedScript)
	if !IsObject(record)
	{
		GuiReset()
		return
	}

	script := record.InfoTitle
	scriptinfo := record.Description
	difficulty := record.Difficulty
	category := record.Category
	setupType := record.SetupText
	localConfigText := record.RequiresLocalConfig ? "Yes" : "No"
	GuiReset()
	Gui Info: +LastFound +AlwaysOnTop +OwnDialogs +Disabled +ToolWindow -Caption
	LLARS_VisualPrepare("Info")
	Gui Info: Color, FFFFFF, FFFFFF
	Gui Info: Margin, 0, 0
	if (difficulty = "Easy")
		infoFrameAsset := "script_info_easy.png"
	else if (difficulty = "Intermediate")
		infoFrameAsset := "script_info_intermediate.png"
	else
		infoFrameAsset := "script_info_hard.png"
	infoFramePath := LLARS_VisualAsset(infoFrameAsset)
    ; Size the colored border to the *rendered description*, not to a
    ; fixed tallest-case frame. Preserve the original 11pt readable copy.
    ; Keep 20 units of breathing room below the copy, while drawing the
    ; white inset slightly smaller inside the difficulty-colored frame.
    descriptionHeight := LLARS_SelectorDescriptionHeight(scriptinfo, 418)
    infoHeight := Max(270, Min(445, 221 + descriptionHeight + 20))
	if (infoFramePath != "")
        Gui Info: Add, Picture, x0 y0 w490 h%infoHeight%, %infoFramePath%
	Gui Info: Font, s16 Bold c24324A, Segoe UI
	Gui Info: Add, Text, Center x28 y22 w434 h30 BackgroundTrans, %script%
	LLARS_SelectorSetDifficultyFont(difficulty)
	Gui Info: Add, Text, Center x28 y54 w434 h28 BackgroundTrans, Setup Difficulty: %difficulty%
	LLARS_VisualDivider("Info", 38, 90, 414)
    ; Metadata fields are neutral. Only the DIFFICULTY heading and outer
    ; frame use the difficulty color; setup type is never a readiness alarm.
	Gui Info: Font, s11 Bold c24324A, Segoe UI
    Gui Info: Add, Text, Center x30 y98 w430 h25 BackgroundTrans, Category: %category%
    Gui Info: Add, Text, Center x30 y125 w430 h25 BackgroundTrans, % "Setup: " . setupType
    Gui Info: Add, Text, Center x30 y152 w430 h25 BackgroundTrans, Local config required: %localConfigText%
    LLARS_VisualDivider("Info", 38, 184, 414)
    Gui Info: Font, s11 Bold c45689A, Segoe UI
    Gui Info: Add, Text, Center x36 y190 w418 h25 BackgroundTrans, ABOUT THIS SCRIPT
    ; Restore normal reading-size copy. The longer frame is for the text,
    ; not an excuse to reduce its font compared with earlier releases.
	Gui Info: Font, s11 Norm c24324A, Segoe UI
    Gui Info: Add, Text, x36 y221 w418 h%descriptionHeight% +Wrap BackgroundTrans, %scriptinfo%
	infoTop := LLARS_SelectorInfoTop()
	Gui Info: Show, % "NoActivate xcenter y" . infoTop . " w490 h" . infoHeight, TopGUI
	LLARS_VisualFinish("Info")
}
return

; Place the Script Info popup near the top of the same monitor as Selector.
; Monitor work areas support secondary monitors and top-docked taskbars.
LLARS_SelectorInfoTop()
{
    global LLARSSelectorHwnd
    if (!LLARSSelectorHwnd || !DllCall("user32\IsWindow", "Ptr", LLARSSelectorHwnd))
        return 8
    monitor := DllCall("user32\MonitorFromWindow", "Ptr", LLARSSelectorHwnd, "UInt", 2, "Ptr")
    if (!monitor)
        return 8
    VarSetCapacity(monitorInfo, 40, 0)
    NumPut(40, monitorInfo, 0, "UInt")
    if (!DllCall("user32\GetMonitorInfoW", "Ptr", monitor, "Ptr", &monitorInfo))
        return 8
    return NumGet(monitorInfo, 24, "Int") + 2
}

; Measure Segoe UI 11pt with native Windows word-wrap metrics. All values
; returned to the GUI use AHK logical units so 100/125/150% DPI stays aligned.
; The old fixed frame was oversized for short descriptions and tempting to
; shrink the text; this keeps the text size and fits the frame instead.
LLARS_SelectorDescriptionHeight(description, logicalWidth)
{
    dpi := A_ScreenDPI ? A_ScreenDPI : 96
    fontHeight := -Round(11 * dpi / 72)
    hFont := DllCall("gdi32\CreateFontW", "Int", fontHeight, "Int", 0
        , "Int", 0, "Int", 0, "Int", 400, "UInt", 0, "UInt", 0
        , "UInt", 0, "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 5
        , "UInt", 0, "WStr", "Segoe UI", "Ptr")
    hdc := DllCall("user32\GetDC", "Ptr", 0, "Ptr")
    if (!hFont || !hdc)
    {
        if (hdc)
            DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", hdc)
        if (hFont)
            DllCall("gdi32\DeleteObject", "Ptr", hFont)
        return 76
    }
    oldFont := DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")
    VarSetCapacity(rect, 16, 0)
    NumPut(Round(logicalWidth * dpi / 96), rect, 8, "Int")
    ; DT_WORDBREAK | DT_CALCRECT. Explicit CR/LF remain respected.
    pixelHeight := DllCall("user32\DrawTextW", "Ptr", hdc, "WStr", description
        , "Int", -1, "Ptr", &rect, "UInt", 0x410, "Int")
    DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", oldFont, "Ptr")
    DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", hdc)
    DllCall("gdi32\DeleteObject", "Ptr", hFont)
    return Max(25, Ceil(pixelHeight * 96 / dpi) + 7)
}

LLARS_SelectorSetDifficultyFont(Difficulty)
{
	if (Difficulty = "Easy")
		Gui Info: Font, s12 Bold c128C79, Segoe UI
	else if (Difficulty = "Intermediate")
		Gui Info: Font, s12 Bold cB66B20, Segoe UI
	else
		Gui Info: Font, s12 Bold cEF4444, Segoe UI
}

; =================================================================
; |     SCRIPT LAUNCH MAPPING     -     SCRIPT LAUNCH MAPPING     |
; =================================================================

; Selection, information, and launch all resolve from the same registry record.
Select:
GuiControlGet, selectedScript, , ScriptListBox

if (selectedScript = "")
	return

record := LLARS_SelectorGetRecord(selectedScript)
if !IsObject(record)
{
	MsgBox, 48, Script Missing, No registry entry is configured for:`n%selectedScript%
	return
}

scriptDir := A_ScriptDir . "\" . record.RootDirectory . "\" . record.RelativeDirectory
scriptFile := record.FileName

if !LaunchSelectedScript(scriptDir, scriptFile, selectedScript)
	return
Goto, exit
return

; Validates the selected script before launch.
ValidateSelectedScript(ScriptDirectory, ScriptFile, ByRef FullDiskPath, ByRef DisplayPath)
{
	ScriptDirectory := RTrim(ScriptDirectory, "\")
	FullDiskPath := ScriptDirectory . "\" . ScriptFile

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

	return true
}

; Launches a validated script using its own directory as the working directory.
LaunchSelectedScript(ScriptDirectory, ScriptFile, ScriptDisplayName := "")
{
	if (ScriptDirectory = "" || ScriptFile = "")
		return false

	if !ValidateSelectedScript(ScriptDirectory, ScriptFile, FullDiskPath, DisplayPath)
	{
		Reload
		return false
	}

	LLARS_SelectorRememberRecent(ScriptDisplayName)

	; Keep one header theme across selector and selected script.
	sessionHeaderTheme := LLARS_VisualHeaderVariantName()
	EnvSet, LLARS_HEADER_THEME, %sessionHeaderTheme%

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
Gosub, SelectorClearFilters
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
