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
LLARS_SelectorPerfMark("autoexecute_start")
LLARS_VisualEnsureIcon(A_ScriptDir)

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

	Gui Error: -ToolWindow +E0x40000

	Gui Error: -caption
	Gui Error: Show, Center w230, File Error
	LLARS_VisualFinish("Error")

	return
}

LLARS_VisualEnsureIcon(A_ScriptDir)

; Loads the local release version used by update checks and GUI titles.
LLARS_GetVersion(A_ScriptDir)
if !LLARS_CheckConfigCompatibility(A_ScriptDir)
	ExitApp
LLARS_SelectorPerfMark("config_compatible")

; Close an older LLARS/script-selector window before any update prompt or Save As dialog.
CloseOtherLLARS()

; Keep the update indicator visible as a startup indicator through subsequent work.
; Selected scripts inherit the completed-check marker and do not check twice.
LLARS_StartupContinuation := true
LLARS_CheckForUpdates()
LLARS_SelectorPerfMark("update_finished")
LLARS_StartupStage("Checking input setup...", "Checking keyboard and mouse input readiness.")

; Applies AHI input-backend setup/readiness checks before the selector opens.
; AHI is recommended; Standard AutoHotkey remains available as a fallback.
LLARS_AHI_StartupGate(A_ScriptDir, true)
LLARS_SelectorPerfMark("ahi_gate_finished")

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
LLARS_SelectorPerfMark("registry_built")
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

LLARS_SelectorPerfMark("registry_validated")
LLARS_StartupStage("Preparing script choices...", "Restoring filters and preparing the script list.")
; Compatibility list generated from the registry for existing filter/preferences logic.
scriptArray := LLARS_SelectorRegistryNameList(LLARS_SelectorRegistry)
; Sort before creating the ListBox. The normal All Scripts filter would
; otherwise sort and fully replace the same 100+ entries immediately after Show.
Sort, scriptArray, D|
ScriptTotal := LLARS_SelectorRegistry.Entries.Length()
LLARS_SelectorCategoryList := LLARS_SelectorRegistryCategoryList(LLARS_SelectorRegistry)
LLARS_SelectorCategoryOptions := "All Categories" . (LLARS_SelectorCategoryList = "" ? "" : "|" . LLARS_SelectorCategoryList)

; Selector preferences reuse LLARS Config.ini so Favorites/Recent participate in
; the existing backup/restore workflow without introducing another state file.
LLARS_SelectorFavorites := ""
LLARS_SelectorRecent := ""
LLARS_SelectorFilteredCount := ScriptTotal
LLARS_SelectorVisibleList := scriptArray
LLARS_SelectorLoadPreferences()
LLARS_SelectorPerfMark("preferences_ready")

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
Gui +LastFound +OwnDialogs +AlwaysOnTop -caption -ToolWindow +E0x40000
Gui, +HwndLLARSSelectorHwnd
LLARS_VisualPrepare("1")
LLARS_VisualAccent("1", 420)
LLARS_VisualBanner("1", 420, 88)
LLARS_VisualCard("1", 8, 92, 404, 68)
LLARS_VisualCard("1", 8, 420, 404, 142)
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
Gui, Add, Button, gSelect w110 h34 x24 y432 Center +0xB hwndLLARSSelectorSelectButtonHwnd, Select Script
Gui, Add, Button, gSelectorToggleFavorite w128 h34 x146 y432 vSelectorFavoriteButton Center +0xB hwndLLARSSelectorFavoriteButtonHwnd, Add Favorite
Gui, Add, Button, gSelectorClearFilters w110 h34 x286 y432 Center +0xB hwndLLARSSelectorClearButtonHwnd, Clear Filters
Gui, Add, Button, gSelectorHeaderPreferences w112 h34 x24 y474 Center +0xB hwndLLARSSelectorHeaderButtonHwnd, Header Style
Gui, Add, Button, gSelectorCreateScript w128 h34 x146 y474 Center +0xB hwndLLARSSelectorCreateButtonHwnd, Create Script
Gui, Add, Button, gExit w128 h34 x146 y516 Center +0xB hwndLLARSSelectorExitButtonHwnd, Close Selector
Gui, Add, Button, gSelectorCustomScripts w110 h34 x286 y474 Center +0xB hwndLLARSSelectorImportButtonHwnd, Import Scripts
; Register Selector buttons before the window first becomes visible.
LLARS_SelectorRegisterButtons()
if LLARS_SelectorLoadWindowPosition(selectorX, selectorY)
	selectorShowOptions := "w420 h570 x" . selectorX . " y" . selectorY
else
	selectorShowOptions := "w420 h570 Center"
; The shared visual finalizer also styles remaining native controls.
LLARS_VisualStyleControls(LLARSSelectorHwnd)
Gui, Show, %selectorShowOptions%, Script Selector
LLARS_SelectorPerfMark("gui_shown")
LLARS_VisualWindow(LLARSSelectorHwnd)
LLARS_HideUpdateCheckSplash()
LLARS_VisualMainIcon(LLARSSelectorHwnd, A_ScriptDir)
CheckPOS(LLARSSelectorHwnd)
LLARS_SelectorSavePosition(LLARSSelectorHwnd)
; All five filters are at their initial All/blank values. The pre-sorted
; list is already visible, so select its first entry instead of rebuilding it.
if (ScriptTotal > 0)
    GuiControl, 1:Choose, ScriptListBox, 1
LLARS_SelectorUpdateFavoriteButton()
LLARS_SelectorPerfMark("selector_input_ready")
GuiControl, 1:Focus, ScriptListBox
; Recheck native button painting after the initial window messages settle.
LLARS_SelectorPaintCallback := Func("LLARS_SelectorFinalizeButtonPaint")
SetTimer, % LLARS_SelectorPaintCallback, -120
; End the auto-execute section: never fall through into the Custom Scripts g-label.
return

SelectorCreateScript:
; Focus an already-open Creator rather than replacing unsaved work.
IfWinExist, LLARS Script Generator ahk_class AutoHotkeyGUI
{
    WinRestore, LLARS Script Generator ahk_class AutoHotkeyGUI
    WinActivate, LLARS Script Generator ahk_class AutoHotkeyGUI
    ExitApp
}
creatorPath := A_ScriptDir . "\Templates\Script Generator.ahk"
if !FileExist(creatorPath)
{
    MsgBox, 16, LLARS Script Selector, The Script Generator is missing from the Templates folder.
    return
}
Run, "%A_AhkPath%" "%creatorPath%", %A_ScriptDir%, UseErrorLevel
if (ErrorLevel)
{
    MsgBox, 16, LLARS Script Selector, Could not open the Script Generator. Check that AutoHotkey and the Templates folder are available.
    return
}
ExitApp

LLARS_SelectorFinalizeButtonPaint()
{
    global LLARSSelectorHwnd
    global LLARSSelectorSelectButtonHwnd, LLARSSelectorFavoriteButtonHwnd, LLARSSelectorClearButtonHwnd
    global LLARSSelectorHeaderButtonHwnd, LLARSSelectorExitButtonHwnd, LLARSSelectorImportButtonHwnd, LLARSSelectorCreateButtonHwnd
    if (!LLARSSelectorHwnd || !DllCall("user32\IsWindowVisible", "Ptr", LLARSSelectorHwnd))
        return
    LLARS_SelectorRegisterButtons()
    LLARS_VisualPaintReady(LLARSSelectorHwnd)
    LLARS_SelectorPerfMark("first_paint_finalized")
    for _, button in [LLARSSelectorSelectButtonHwnd, LLARSSelectorFavoriteButtonHwnd, LLARSSelectorClearButtonHwnd
        , LLARSSelectorHeaderButtonHwnd, LLARSSelectorCreateButtonHwnd, LLARSSelectorExitButtonHwnd, LLARSSelectorImportButtonHwnd]
    {
        if (button && DllCall("user32\IsWindow", "Ptr", button))
            DllCall("user32\RedrawWindow", "Ptr", button, "Ptr", 0, "Ptr", 0, "UInt", 0x105)
    }
}

LLARS_SelectorRegisterButtons()
{
    global LLARSSelectorSelectButtonHwnd, LLARSSelectorFavoriteButtonHwnd, LLARSSelectorClearButtonHwnd
    global LLARSSelectorHeaderButtonHwnd, LLARSSelectorExitButtonHwnd, LLARSSelectorImportButtonHwnd, LLARSSelectorCreateButtonHwnd
    LLARS_VisualRegisterButton(LLARSSelectorSelectButtonHwnd, "Select Script")
    LLARS_VisualRegisterButton(LLARSSelectorFavoriteButtonHwnd, "Add Favorite")
    LLARS_VisualRegisterButton(LLARSSelectorClearButtonHwnd, "Clear Filters")
    LLARS_VisualRegisterButton(LLARSSelectorHeaderButtonHwnd, "Header Style")
    LLARS_VisualRegisterButton(LLARSSelectorCreateButtonHwnd, "Create Script")
    LLARS_VisualRegisterButton(LLARSSelectorExitButtonHwnd, "Close Selector")
    LLARS_VisualRegisterButton(LLARSSelectorImportButtonHwnd, "Import Scripts")
}

; Opt-in startup evidence for v2.3.7. Set LLARS_SELECTOR_PROFILE=1 before
; launching the Selector. No persistent logging, new UI, or disk writes by default.
; Records timestamped stage deltas in Logs\Selector-Startup-Performance.log.
LLARS_SelectorPerfMark(stage)
{
    static enabled := "", started := 0, previous := 0, seen := {}
    if (enabled = "")
    {
        EnvGet, requested, LLARS_SELECTOR_PROFILE
        enabled := (requested = "1") ? "yes" : "no"
    }
    if (enabled != "yes" || seen.HasKey(stage))
        return
    seen[stage] := true
    now := A_TickCount
    if (!started)
        started := now
    delta := (previous = 0) ? 0 : (now - previous)
    previous := now
    logDir := A_ScriptDir . "\Logs"
    FileCreateDir, %logDir%
    logFile := logDir . "\Selector-Startup-Performance.log"
    entry := A_NowUTC . " UTC`t" . stage . "`t" . (now - started) . "`t" . delta . "`n"
    FileAppend, %entry%, %logFile%, UTF-8
}

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
	LLARS_SelectorRegistryAdd(registry, "Jewellery Crafter - Lumbridge", "Jewellery Crafter", "Hard", "Runs between the Combat Academy bank chest and Lumbridge Furnace to craft your selected Jewellery. Follow Instructions and complete Setup before starting.", "Jewellery Crafter", "Jewellery Crafter.ahk", "Crafting")
	LLARS_SelectorRegistryAdd(registry, "Jewellery Crafter - Fort Forinthry", "Jewellery Crafter", "Hard", "Runs between the bank chest and furnace at the Fort to craft your selected Jewellery. Follow Instructions and complete Setup before starting.", "Fort Forinthry\Jewellery Crafter", "Jewellery Crafter.ahk", "Crafting")
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
		added := LLARS_SelectorRegistryAdd(registry, item.Name, item.InfoTitle, item.Difficulty
			, item.Description, item.RelativeDirectory, item.FileName, item.Category
			, item.RootDirectory, item.ScriptFamily)
		added.Author := item.Author
	}

	return registry
}

LLARS_SelectorRegistryAdd(ByRef registry, Name, InfoTitle, Difficulty, Description, RelativeDirectory, FileName, Category, RootDirectory := "Scripts", ScriptFamily := "Normal")
{
	scriptDir := A_ScriptDir . "\" . RootDirectory . "\" . RelativeDirectory
	scriptPath := scriptDir . "\" . FileName
	configPath := scriptDir . "\Config.ini"
    ; Startup-only one-pass scan; unusual INIs use the canonical shared scanner.
    capabilities := LLARS_SelectorCapabilitiesFast(configPath, scriptPath)
	record := {Name: Name, InfoTitle: InfoTitle, Difficulty: Difficulty, Description: Description, RelativeDirectory: RelativeDirectory, FileName: FileName, Category: Category
		, RootDirectory: RootDirectory, ScriptFamily: ScriptFamily
		, Capabilities: capabilities, SetupType: capabilities.SetupType, SetupText: capabilities.SetupText, RequiresLocalConfig: capabilities.RequiresLocalConfig}
	registry.Entries.Push(record)
	registry.ByName[Name] := record
	return record
}


; Startup-only capability discovery. The shared LLARS_ConfigCapabilityScan remains
; authoritative for editors, scripts, Creator, and unusual user configurations.
; Read each simple local INI once instead of performing a separate Windows INI
; lookup for every field/section. Any ambiguous section/key layout falls back
; to the canonical scanner rather than guessing about setup requirements.
LLARS_SelectorCapabilitiesFast(configPath, scriptPath)
{
    disabled := LLARS_ConfigScriptDisabled(scriptPath)
    if (disabled || !FileExist(configPath))
        return LLARS_ConfigCapabilityScan(configPath, scriptPath, disabled ? true : false)

    FileRead, contents, %configPath%
    if (ErrorLevel || contents = "")
        return LLARS_ConfigCapabilityScan(configPath, scriptPath, false)

    sections := {}
    order := []
    sectionName := ""
    Loop, Parse, contents, `n, `r
    {
        line := Trim(StrReplace(A_LoopField, Chr(0xFEFF)))
        if (line = "" || SubStr(line, 1, 1) = ";" || SubStr(line, 1, 1) = "#")
            continue
        if RegExMatch(line, "^\[(.*)\]$", header)
        {
            sectionName := Trim(header1)
            if (sectionName = "")
                continue
            sectionName := LLARS_ConfigCanonicalCoordinateSection(LLARS_ConfigCanonicalHotkeySection(LLARS_ConfigCanonicalBankSection(sectionName)))
            ; Duplicate or case-variant headings can follow Windows INI merging
            ; rules; delegate those files to the unchanged canonical scanner.
            key := sectionName
            StringLower, key, key
            if sections.HasKey(key)
                return LLARS_ConfigCapabilityScan(configPath, scriptPath, false)
            sections[key] := {Name: sectionName, Type: "", TypeSeen: false, Min: false, Max: false}
            order.Push(key)
            continue
        }
        if (sectionName = "")
            continue
        pos := InStr(line, "=")
        if (!pos)
            continue
        field := Trim(SubStr(line, 1, pos - 1))
        StringLower, field, field
        value := Trim(SubStr(line, pos + 1))
        sectionKey := sectionName
        StringLower, sectionKey, sectionKey
        item := sections[sectionKey]
        if (field = "type")
        {
            if (item.TypeSeen || InStr(value, ";"))
                return LLARS_ConfigCapabilityScan(configPath, scriptPath, false)
            item.TypeSeen := true
            StringLower, value, value
            item.Type := value
        }
        else if (field = "min")
            item.Min := true
        else if (field = "max")
            item.Max := true
    }
    if (!order.Length())
        return LLARS_ConfigCapabilityScan(configPath, scriptPath, false)

    caps := {ConfigPath: configPath, ScriptPath: scriptPath, Disabled: false
        , ConfigExists: true, RequiresLocalConfig: true, Hotkeys: false
        , Coordinates: false, Colors: false, Timer: false, ScriptConfig: true
        , SetupType: "None", SetupText: "None"}
    for _, key in order
    {
        item := sections[key]
        if !LLARS_ConfigSectionUsedByScript(configPath, scriptPath, item.Name)
            continue
        kind := item.Type
        if (kind != "hotkey" && kind != "coordinate" && kind != "color" && kind != "timer")
        {
            ; Legacy timer sections without type=timer keep their v2.3.6 meaning.
            label := item.Name
            StringLower, label, label
            if ((label = "timer" || RegExMatch(label, "^(sleep |timer )")) && (item.Min || item.Max))
                kind := "timer"
        }
        if (kind = "hotkey")
            caps.Hotkeys := true
        else if (kind = "coordinate")
            caps.Coordinates := true
        else if (kind = "color")
            caps.Colors := true
        else if (kind = "timer")
            caps.Timer := true
    }
    setup := ""
    if (caps.Hotkeys)
        setup .= "Hotkeys"
    if (caps.Coordinates)
        setup .= (setup = "" ? "" : " + ") . "Coordinates"
    if (caps.Colors)
        setup .= (setup = "" ? "" : " + ") . "Colors"
    if (caps.Timer)
        setup .= (setup = "" ? "" : " + ") . "Timer"
    caps.SetupText := (setup = "") ? "None" : setup
    if (caps.Hotkeys && !caps.Coordinates && !caps.Colors && !caps.Timer)
        caps.SetupType := "Hotkey"
    else if (caps.Coordinates && !caps.Hotkeys && !caps.Colors && !caps.Timer)
        caps.SetupType := "Coordinate"
    else if (caps.Colors && caps.Coordinates && !caps.Hotkeys && !caps.Timer)
        caps.SetupType := "Color+Coordinate"
    else if (caps.Timer && !caps.Hotkeys && !caps.Coordinates && !caps.Colors)
        caps.SetupType := "Timer"
    else if (!caps.Hotkeys && !caps.Coordinates && !caps.Colors && !caps.Timer)
        caps.SetupType := "None"
    else
        caps.SetupType := "Mixed"
    return caps
}

; The Selector highlights only the setup choices a player must configure.
; Timer availability remains derived from Config.ini and visible in Setup.
LLARS_SelectorVisibleSetupText(capabilities)
{
    if !IsObject(capabilities)
        return "None"

    summary := ""
    if (capabilities.Hotkeys)
        summary .= "Hotkeys"
    if (capabilities.Coordinates)
        summary .= (summary = "" ? "" : " + ") . "Coordinates"
    if (capabilities.Colors)
        summary .= (summary = "" ? "" : " + ") . "Colors"
    return (summary = "") ? "None" : summary
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
	global LLARS_SelectorFilteredCount, LLARS_SelectorVisibleList

	GuiControlGet, searchText, 1:, SelectorSearch
	GuiControlGet, selectorView, 1:, SelectorView
	GuiControlGet, selectorCategory, 1:, SelectorCategory
	GuiControlGet, selectorDifficulty, 1:, SelectorDifficulty
	GuiControlGet, selectorScriptFamily, 1:, SelectorScriptFamily
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
	LLARS_SelectorVisibleList := filtered
	GuiControl, 1:, ScriptListBox, |%filtered%
	GuiControl, 1:, TS, % "Showing: " . count . " of " . ScriptTotal
	if (count > 0)
		GuiControl, 1:Choose, ScriptListBox, 1

	GuiReset()
	LLARS_SelectorUpdateFavoriteButton()
	return count
}

LLARS_SelectorUpdateFavoriteButton()
{
	global LLARS_SelectorFavorites
	GuiControlGet, selectedScript, 1:, ScriptListBox
	if (selectedScript != "" && LLARS_SelectorListContains(LLARS_SelectorFavorites, selectedScript))
		buttonText := "Remove Favorite"
	else
		buttonText := "Add Favorite"
	GuiControl, 1:, SelectorFavoriteButton, %buttonText%
	return true
}

; Rebuild from the existing in-code and Creator/imported registry owners.
; The previous UI catalog remains untouched if a newly written registry fails validation.
LLARS_SelectorRefreshRegistry(selectName := "", showAll := false)
{
    global LLARS_SelectorRegistry, LLARS_SelectorRegistryLoadError, scriptArray, ScriptTotal, LLARSSelectorHwnd
    global LLARS_SelectorCategoryList, LLARS_SelectorCategoryOptions, LLARS_SelectorVisibleList
    LLARS_SelectorRegistryLoadError := ""
    refreshed := LLARS_SelectorBuildRegistry()
    if (LLARS_SelectorRegistryLoadError != "" || !LLARS_SelectorValidateRegistry(refreshed, validationError))
        return false
    LLARS_SelectorRegistry := refreshed
    scriptArray := LLARS_SelectorRegistryNameList(refreshed)
    ScriptTotal := refreshed.Entries.Length()
    LLARS_SelectorCategoryList := LLARS_SelectorRegistryCategoryList(refreshed)
    LLARS_SelectorCategoryOptions := "All Categories" . (LLARS_SelectorCategoryList = "" ? "" : "|" . LLARS_SelectorCategoryList)
    ; All Selector control updates MUST address GUI 1. This helper is often
    ; invoked from an Import Scripts dialog g-label, not from the main GUI.
    GuiControl, 1:, SelectorCategory, % "|" . LLARS_SelectorCategoryOptions
    GuiControl, 1:ChooseString, SelectorCategory, All Categories
    if (showAll)
    {
        GuiControl, 1:, SelectorSearch,
        GuiControl, 1:ChooseString, SelectorView, All Scripts
        GuiControl, 1:ChooseString, SelectorDifficulty, All Difficulties
        GuiControl, 1:ChooseString, SelectorScriptFamily, All Types
    }
    LLARS_SelectorLoadPreferences()
    LLARS_SelectorSavePreferences()
    LLARS_SelectorApplyFilter()
    if (selectName != "")
    {
        ; Choose by exact item index, not ChooseString's prefix match.
        for position, item in StrSplit(LLARS_SelectorVisibleList, "|")
        {
            if (item = selectName)
            {
                GuiControl, 1:Choose, ScriptListBox, %position%
                break
            }
        }
        LLARS_SelectorUpdateFavoriteButton()
        GuiControl, 1:Focus, ScriptListBox
    }
    ; Refresh native controls after programmatic list replacement. AHK button
    ; owner-draw and translucent labels can otherwise wait for a later repaint.
    LLARS_VisualPaintReady(LLARSSelectorHwnd)
    return true
}

; Header Appearance remains an optional Selector modal. No preview, Cancel or
; settings navigation changes the active session theme or launch cursor.
; Script imports are opt-in and never run code while importing. The folder
; chooser copies the selected script's entire directory, preserving local INI
; files, relative includes and assets; registration and copying are separate.
LLARS_CustomScriptsShow()
{
    global LLARSCustomHwnd, LLARSCustomSelected, LLARSCustomSource, LLARSCustomLastImported, LLARSCustomPath, LLARSCustomName, LLARSCustomCategory
    global LLARSCustomDifficulty, LLARSCustomDescription, LLARSCustomManagedChoice, LLARSCustomViewButton, LLARS_SelectorRegistry
    ; Do not inherit the selected main-Selector entry. Import Scripts always
    ; opens with the same clean default state, regardless of previous imports.
    LLARSCustomSource := ""
    ; Each opening begins with an unselected form, even if Selector highlights
    ; a previously imported script or there is only one managed import.
    LLARSCustomSelected := ""
    LLARSCustomLastImported := ""
    managedChoices := LLARS_CustomScriptsManagedChoices()
    Gui, Info:Destroy
    Gui, CustomScripts:Destroy
    Gui, CustomScripts:New, +Owner1 +OwnDialogs +AlwaysOnTop +ToolWindow +HwndLLARSCustomHwnd, Import Scripts
    Gui, CustomScripts:Margin, 0, 0
    LLARS_VisualPrepare("CustomScripts")
    LLARS_VisualModalHeader("CustomScripts", 480, "IMPORT SCRIPTS")
    LLARS_VisualCard("CustomScripts", 10, 82, 460, 337)
    Gui, CustomScripts:Font, s9 Norm c24324A, Segoe UI
    Gui, CustomScripts:Add, Text, x22 y93 w434 h36 +Wrap BackgroundTrans, Import copies a script folder; root-level .ahk files are copied alone. Review code before launching. Nothing runs during import.
    Gui, CustomScripts:Add, Text, x22 y133 w434 h34 vLLARSCustomPath +Wrap BackgroundTrans, No source selected
    Gui, CustomScripts:Add, Button, x22 y170 w132 h30 gCustomBrowse, Choose .ahk File
    Gui, CustomScripts:Add, Text, x22 y210 w105 h18 BackgroundTrans, Display name
    Gui, CustomScripts:Add, Edit, x132 y207 w320 h24 vLLARSCustomName
    Gui, CustomScripts:Add, Text, x22 y241 w100 h18 BackgroundTrans, Category
    Gui, CustomScripts:Add, Edit, x132 y238 w148 h24 vLLARSCustomCategory, Custom
    Gui, CustomScripts:Add, Text, x286 y241 w64 h18 BackgroundTrans, Difficulty
    Gui, CustomScripts:Add, DropDownList, x348 y238 w106 vLLARSCustomDifficulty Choose2, Easy|Intermediate|Hard
    Gui, CustomScripts:Add, Text, x22 y272 w105 h18 BackgroundTrans, Description
    ; Blank by default: the user supplies actual metadata, not a canned description.
    Gui, CustomScripts:Add, Edit, x132 y269 w320 h52 +Multi vLLARSCustomDescription
    Gui, CustomScripts:Font, s8 Norm c526783, Segoe UI
    Gui, CustomScripts:Add, Text, x22 y337 w108 h18 BackgroundTrans, Manage existing
    Gui, CustomScripts:Add, DropDownList, x132 y329 w320 vLLARSCustomManagedChoice gCustomSelectManaged Choose1, %managedChoices%
    Gui, CustomScripts:Font, s9 Norm c24324A, Segoe UI
    Gui, CustomScripts:Add, Button, x22 y367 w104 h32 gCustomImport, Import Copy
    Gui, CustomScripts:Add, Button, x136 y367 w100 h32 gCustomEdit, Edit Details
    Gui, CustomScripts:Add, Button, x246 y367 w101 h32 gCustomRemove, Unregister
    Gui, CustomScripts:Add, Button, x357 y367 w99 h32 vLLARSCustomViewButton gCustomView, View Folder
    Gui, CustomScripts:Add, Button, x184 y433 w112 h31 gCustomClose, Close
    LLARS_VisualStyleControls(LLARSCustomHwnd)
    Gui, CustomScripts:Show, w480 h474 Center, Import Scripts
    LLARS_VisualFinish("CustomScripts")
    LLARS_CustomScriptsResetForm()
    LLARS_VisualPaintReady(LLARSCustomHwnd)
}

; Build the current choices from the single authoritative Creator/import registry.
; Names are already validated against the DropDownList separator by that owner.
LLARS_CustomScriptsManagedChoices()
{
    global LLARS_SelectorRegistry
    choices := "Select existing import"
    for _, item in LLARS_SelectorRegistry.Entries
        if LLARS_ImportIsManaged(item)
            choices .= "|" . item.Name
    return choices
}

; Rebuild the picker after a successful import. This is deliberately separate
; from form reset so a newly added entry is immediately available for editing.
LLARS_CustomScriptsRefreshManagedPicker()
{
    choices := LLARS_CustomScriptsManagedChoices()
    GuiControl, CustomScripts:, LLARSCustomManagedChoice, % "|" . choices
    GuiControl, CustomScripts:Choose, LLARSCustomManagedChoice, 1
}

; Opening the dialog, choosing the default picker item, or completing Import
; Copy must all produce the same neutral state; do not preselect last import.
LLARS_CustomScriptsResetForm()
{
    global LLARSCustomSelected, LLARSCustomSource
    LLARSCustomSelected := ""
    LLARSCustomSource := ""
    GuiControl, CustomScripts:, LLARSCustomPath, No source selected
    GuiControl, CustomScripts:, LLARSCustomName,
    GuiControl, CustomScripts:, LLARSCustomCategory, Custom
    GuiControl, CustomScripts:ChooseString, LLARSCustomDifficulty, Intermediate
    GuiControl, CustomScripts:, LLARSCustomDescription,
    GuiControl, CustomScripts:Choose, LLARSCustomManagedChoice, 1
}

; Load a managed entry explicitly, independently of the main list box's
; selection or the current default GUI (which may be a modal dialog).
LLARS_CustomScriptsLoadManaged(name)
{
    global LLARSCustomSelected, LLARSCustomSource
    record := LLARS_SelectorGetRecord(name)
    if !LLARS_ImportIsManaged(record)
    {
        LLARSCustomSelected := ""
        return false
    }
    LLARSCustomSelected := record.Name
    LLARSCustomSource := ""
    GuiControl, CustomScripts:, LLARSCustomPath, % "Managed script: " . record.RelativeDirectory
    GuiControl, CustomScripts:, LLARSCustomName, % record.Name
    GuiControl, CustomScripts:, LLARSCustomCategory, % record.Category
    GuiControl, CustomScripts:, LLARSCustomDescription, % record.Description
    GuiControl, CustomScripts:ChooseString, LLARSCustomDifficulty, % record.Difficulty
    return true
}

LLARS_CustomScriptsAlert(iconOptions, title, message)
{
    global LLARSCustomHwnd
    if (LLARSCustomHwnd && DllCall("user32\IsWindow", "Ptr", LLARSCustomHwnd))
        Gui, CustomScripts:Default
    else
        Gui, 1:Default
    Gui, +OwnDialogs +AlwaysOnTop
    MsgBox, % (iconOptions | 0x40000), %title%, %message%
    ; Repaint after an owned dialog closes; the modal may have obscured an
    ; owner-drawn control. Do not leave Selector's default GUI switched.
    if (LLARSCustomHwnd && DllCall("user32\IsWindow", "Ptr", LLARSCustomHwnd))
        LLARS_VisualPaintReady(LLARSCustomHwnd)
    Gui, 1:Default
}

LLARS_CustomScriptsConfirm(title, message)
{
    global LLARSCustomHwnd
    Gui, CustomScripts:Default
    Gui, +OwnDialogs +AlwaysOnTop
    MsgBox, 0x40024, %title%, %message%
    IfMsgBox, Yes
        accepted := true
    else
        accepted := false
    if (LLARSCustomHwnd && DllCall("user32\IsWindow", "Ptr", LLARSCustomHwnd))
        LLARS_VisualPaintReady(LLARSCustomHwnd)
    Gui, 1:Default
    return accepted
}

SelectorCustomScripts:
LLARS_CustomScriptsShow()
return

CustomSelectManaged:
GuiControlGet, managedChoice, CustomScripts:, LLARSCustomManagedChoice
if (managedChoice = "Select existing import")
{
    LLARS_CustomScriptsResetForm()
    return
}
LLARS_CustomScriptsLoadManaged(managedChoice)
return

CustomBrowse:
Gui, CustomScripts:Default
Gui, +OwnDialogs
FileSelectFile, selectedSource, 3,, Choose an LLARS-compatible script, AutoHotkey Script (*.ahk)
if (selectedSource != "")
{
    if (LLARSCustomSelected != "")
        LLARS_CustomScriptsResetForm()
    LLARSCustomSource := selectedSource
    SplitPath, selectedSource, sourceName, sourceFolder,, sourceBase
    GuiControl, CustomScripts:, LLARSCustomPath, %selectedSource%
    ; Preserve a manually typed display name/description when browsing.
    GuiControlGet, existingName, CustomScripts:, LLARSCustomName
    if (Trim(existingName) = "")
        GuiControl, CustomScripts:, LLARSCustomName, % "Custom - " . sourceBase
}
return

CustomImport:
if (LLARSCustomSource = "")
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", "Choose an .ahk file first.")
    return
}
GuiControlGet, importName, CustomScripts:, LLARSCustomName
GuiControlGet, importCategory, CustomScripts:, LLARSCustomCategory
GuiControlGet, importDescription, CustomScripts:, LLARSCustomDescription
GuiControlGet, importDifficulty, CustomScripts:, LLARSCustomDifficulty
if !LLARS_CustomScriptsConfirm("Import Custom Script", "Copy this script into managed imports?`n" . LLARSCustomSource . "`n`nA root-level .ahk is copied alone; other imports copy the containing folder. Review source before running it.`n`nContinue?")
    return
if !LLARS_ImportScript(A_ScriptDir, LLARSCustomSource, importName, importDifficulty, importDescription, importCategory, importError)
{
    LLARS_CustomScriptsAlert(48, "Custom Script Import", importError)
    return
}
if !LLARS_SelectorRefreshRegistry(importName, true)
{
    LLARS_CustomScriptsAlert(48, "Custom Script Import", "The copied script was registered but the Selector could not refresh. Restart LLARS to reload the catalog.")
    return
}
; Keep the Import Scripts dialog open and reset it, so each new import begins
; with the same empty form and the default managed-selection placeholder.
LLARS_CustomScriptsRefreshManagedPicker()
LLARSCustomLastImported := importName
LLARS_CustomScriptsResetForm()
; A neutral import form can still open the last successful import's folder.
; Keep the native button caption and visibility after the picker is rebuilt.
GuiControl, CustomScripts:, LLARSCustomViewButton, View Folder
GuiControl, CustomScripts:Show, LLARSCustomViewButton
LLARS_VisualPaintReady(LLARSCustomHwnd)
LLARS_CustomScriptsAlert(64, "Custom Script Import", "Imported successfully. Script files and settings were copied without execution.")
return

CustomEdit:
GuiControlGet, managedChoice, CustomScripts:, LLARSCustomManagedChoice
if (managedChoice != "Select existing import")
    LLARSCustomSelected := managedChoice
if (LLARSCustomSelected = "")
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", "Choose an imported script under Manage existing before editing.")
    return
}
selectedRecord := LLARS_SelectorGetRecord(LLARSCustomSelected)
GuiControlGet, editName, CustomScripts:, LLARSCustomName
GuiControlGet, editCategory, CustomScripts:, LLARSCustomCategory
GuiControlGet, editDescription, CustomScripts:, LLARSCustomDescription
GuiControlGet, editDifficulty, CustomScripts:, LLARSCustomDifficulty
if !LLARS_ImportUpdateMetadata(A_ScriptDir, selectedRecord, editName, editDifficulty, editDescription, editCategory, editError)
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", editError)
    return
}
; Keep Favorites and Recent entries when an imported display name is edited.
if (editName != LLARSCustomSelected)
{
    LLARS_SelectorFavorites := LLARS_SelectorReplacePreference(LLARS_SelectorFavorites, LLARSCustomSelected, editName)
    LLARS_SelectorRecent := LLARS_SelectorReplacePreference(LLARS_SelectorRecent, LLARSCustomSelected, editName)
    ; Refresh reloads Favorites/Recent from disk. Persist the rename BEFORE
    ; refreshing, or the old name gets sanitized away and both lists lose it.
    if !LLARS_SelectorSavePreferences()
        LLARS_CustomScriptsAlert(48, "Custom Scripts", "Details were updated but Favorites/Recent could not be saved. Check LLARS Config.ini write permissions.")
}
if !LLARS_SelectorRefreshRegistry(editName, true)
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", "Details saved but refresh failed. Restart Selector.")
    Gui, CustomScripts:Destroy
    return
}
Gui, CustomScripts:Destroy
LLARS_CustomScriptsAlert(64, "Custom Scripts", "Imported script details updated.")
return

CustomRemove:
GuiControlGet, managedChoice, CustomScripts:, LLARSCustomManagedChoice
if (managedChoice != "Select existing import")
    LLARSCustomSelected := managedChoice
if (LLARSCustomSelected = "")
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", "Choose an imported script under Manage existing before unregistering.")
    return
}
selectedRecord := LLARS_SelectorGetRecord(LLARSCustomSelected)
if !LLARS_CustomScriptsConfirm("Unregister Custom Script", "Remove '" . LLARSCustomSelected . "' from the Selector?`n`nIts folder, scripts, settings and assets will NOT be deleted.")
    return
if !LLARS_ImportUnregister(A_ScriptDir, selectedRecord, removeError)
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", removeError)
    return
}
if !LLARS_SelectorRefreshRegistry()
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", "Registration removed but refresh failed. Restart Selector.")
    Gui, CustomScripts:Destroy
    return
}
Gui, CustomScripts:Destroy
LLARS_CustomScriptsAlert(64, "Custom Scripts", "Registration removed. The original and copied files remain on disk.")
return

CustomView:
GuiControlGet, managedChoice, CustomScripts:, LLARSCustomManagedChoice
; The folder shortcut must NOT secretly select an entry for Edit/Unregister.
; Keep the import form's placeholder and neutral selected state intact.
if (managedChoice != "Select existing import")
    viewName := managedChoice
else if (LLARSCustomSelected != "")
    viewName := LLARSCustomSelected
else
    viewName := LLARSCustomLastImported
if (viewName = "")
{
    LLARS_CustomScriptsAlert(48, "Custom Scripts", "Choose an imported script under Manage existing before viewing its folder.")
    return
}
selectedRecord := LLARS_SelectorGetRecord(viewName)
if LLARS_ImportIsManaged(selectedRecord)
{
    importFolder := A_ScriptDir . "\" . selectedRecord.RootDirectory . "\" . selectedRecord.RelativeDirectory
    Run, % "explorer.exe """ . importFolder . """"
}
return

CustomClose:
CustomScriptsGuiClose:
CustomScriptsGuiEscape:
Gui, CustomScripts:Destroy
LLARSCustomHwnd := 0
return

LLARS_SelectorReplacePreference(list, oldName, newName)
{
    result := ""
    for _, item in StrSplit(list, "|")
    {
        if (item = "")
            continue
        if (item = oldName)
            item := newName
        result .= (result = "" ? "" : "|") . item
    }
    return result
}

SelectorHeaderPreferences:
LLARS_HeaderPrefsShow()
return

HeaderPrefsPrevious:
headerCatalog := LLARS_VisualHeaderCatalog()
LLARSHeaderPrefsIndex := (LLARSHeaderPrefsIndex <= 1) ? headerCatalog.Length() : LLARSHeaderPrefsIndex - 1
LLARS_HeaderPrefsPreviewChosen()
return

HeaderPrefsNext:
headerCatalog := LLARS_VisualHeaderCatalog()
LLARSHeaderPrefsIndex := Mod(LLARSHeaderPrefsIndex, headerCatalog.Length()) + 1
LLARS_HeaderPrefsPreviewChosen()
return

HeaderPrefsSave:
GuiControlGet, headerMode, HeaderPrefs:, LLARSHeaderPrefsMode
StringLower, headerMode, headerMode
headerItems := LLARS_VisualHeaderCatalog()
if (LLARSHeaderPrefsIndex < 1 || LLARSHeaderPrefsIndex > headerItems.Length())
{
    Gui, HeaderPrefs:Default
    Gui, +OwnDialogs +AlwaysOnTop
    MsgBox, 262192, Header Appearance, The selected header is unavailable. Please reopen Header Style.
    return
}
headerName := headerItems[LLARSHeaderPrefsIndex].Id
if !LLARS_VisualHeaderSavePreferences(headerMode, headerName, preferenceError)
{
    MsgBox, 262192, Header Appearance, %preferenceError%
    return
}
Gui, HeaderPrefs:Destroy
Gui, 1:Default
Gui, +OwnDialogs
MsgBox, 262208, Header Appearance, Preference saved. Your active session keeps its current header; the next launch uses the new setting.
return

HeaderPrefsCancel:
HeaderPrefsGuiClose:
HeaderPrefsGuiEscape:
Gui, HeaderPrefs:Destroy
return

SelectorFilterChanged:
LLARS_SelectorApplyFilter()
return

SelectorFocusSearch:
; Modal file pickers and confirmation boxes may own the focus. Never
; let the global Enter/Ctrl+F hotkeys launch a script while either dialog exists.
if ((LLARSHeaderPrefsHwnd && DllCall("user32\IsWindow", "Ptr", LLARSHeaderPrefsHwnd))
    || (LLARSCustomHwnd && DllCall("user32\IsWindow", "Ptr", LLARSCustomHwnd)))
    return
GuiControl, 1:Focus, SelectorSearch
return

SelectorToggleFavorite:
GuiControlGet, selectedScript, 1:, ScriptListBox
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
GuiControlGet, selectorView, 1:, SelectorView
if (selectorView = "Favorites")
	LLARS_SelectorApplyFilter()
else
	LLARS_SelectorUpdateFavoriteButton()
return

SelectorClearFilters:
GuiControl, 1:, SelectorSearch,
GuiControl, 1:ChooseString, SelectorView, All Scripts
GuiControl, 1:ChooseString, SelectorCategory, All Categories
GuiControl, 1:ChooseString, SelectorDifficulty, All Difficulties
GuiControl, 1:ChooseString, SelectorScriptFamily, All Types
LLARS_SelectorApplyFilter()
GuiControl, 1:Focus, SelectorSearch
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
	GuiControlGet, selectedScript, 1:, ScriptListBox
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
	setupType := LLARS_SelectorVisibleSetupText(record.Capabilities)
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
; Modal file pickers and confirmation boxes may own the focus. Never
; let the global Enter/Ctrl+F hotkeys launch a script while either dialog exists.
if ((LLARSHeaderPrefsHwnd && DllCall("user32\IsWindow", "Ptr", LLARSHeaderPrefsHwnd))
    || (LLARSCustomHwnd && DllCall("user32\IsWindow", "Ptr", LLARSCustomHwnd)))
    return
GuiControlGet, selectedScript, 1:, ScriptListBox

if (selectedScript = "")
	return

record := LLARS_SelectorGetRecord(selectedScript)
if !IsObject(record)
{
	MsgBox, 262192, Script Missing, No registry entry is configured for:`n%selectedScript%
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
		MsgBox, 262192, Script Missing
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
if (LLARSHeaderPrefsHwnd && DllCall("user32\IsWindow", "Ptr", LLARSHeaderPrefsHwnd))
{
    if WinActive("ahk_id " . LLARSHeaderPrefsHwnd)
        Gui, HeaderPrefs:Destroy
    return
}
if (LLARSCustomHwnd && DllCall("user32\IsWindow", "Ptr", LLARSCustomHwnd))
{
    if WinActive("ahk_id " . LLARSCustomHwnd)
        Gui, CustomScripts:Destroy
    return
}
ExitApp

GitLink:
run, https://github.com/Gubna-Tech/RuneScape
Exitapp

DiscordError:
Run, https://discord.gg/Wmmf65myPG
Exitapp

CloseError:	
ExitApp
