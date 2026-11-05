; Shared configurable Timer editor for explicit type=timer min/max sections.
; Does not change gameplay timers, only existing script Config.ini values.
LLARS_TimerSetupSections()
{
    global LLARS_SCRIPT_DIR
    configPath := LLARS_SCRIPT_DIR . "\Config.ini"
    sections := LLARS_ConfigSectionList(configPath)
    results := []
    if (sections = "ERROR")
        return results
    Loop, Parse, sections, `n, `r
    {
        section := LLARS_NormalizeConfigSectionName(A_LoopField)
        if (section = "" || LLARS_ConfigCapabilitySectionType(configPath, section) != "timer")
            continue
        ; Both keys must already exist; this editor never invents config fields.
        if (!LLARS_ConfigKeyExistsFile(configPath, section, "min") || !LLARS_ConfigKeyExistsFile(configPath, section, "max"))
            continue
        results.Push(section)
    }
    return results
}

LLARS_TimerSetupShow()
{
    global LLARS_TIMER_SECTIONS, LLARSTimerSelection, LLARSTimerMin, LLARSTimerMax
    global LLARSTimerSetupHwnd, LLARS_RUNNING
    if (LLARS_RUNNING)
        return
    LLARS_TIMER_SECTIONS := LLARS_TimerSetupSections()
    if (!LLARS_TIMER_SECTIONS.Length())
    {
        MsgBox, 262192, LLARS Timer, This script has no configurable timer ranges.
        return
    }
    LLARS_DeveloperUIAction("Timer Configuration")
    Gui, Combo:Destroy
    Gui, 1:Hide
    DisableHotkey()
    Gui, TimerSetup:Destroy
    Gui, TimerSetup:New, +AlwaysOnTop +OwnDialogs -ToolWindow +E0x40000 +HwndLLARSTimerSetupHwnd, Timer Settings
    Gui, TimerSetup:Margin, 0, 0
    LLARS_VisualPrepare("TimerSetup")
    LLARS_VisualModalHeader("TimerSetup", 460, "Timer Settings")
    LLARS_VisualCard("TimerSetup", 14, 84, 432, 265)
    Gui, TimerSetup:Font, s11 Norm c24324A, Segoe UI
    Gui, TimerSetup:Add, Text, x32 y99 w396 h25 BackgroundTrans, Choose a timer from this script's configuration:
    names := ""
    for _, section in LLARS_TIMER_SECTIONS
        names .= (names = "" ? "" : "|") . section
    Gui, TimerSetup:Add, DropDownList, x32 y132 w396 h235 AltSubmit Choose1 vLLARSTimerSelection gTimerSetupChoose, %names%
    Gui, TimerSetup:Add, Text, x32 y177 w190 h24 BackgroundTrans, Minimum (milliseconds)
    Gui, TimerSetup:Add, Text, x238 y177 w190 h24 BackgroundTrans, Maximum (milliseconds)
    Gui, TimerSetup:Add, Edit, x32 y207 w190 h31 Number vLLARSTimerMin
    Gui, TimerSetup:Add, Edit, x238 y207 w190 h31 Number vLLARSTimerMax
    Gui, TimerSetup:Font, s10 Norm c526783, Segoe UI
    Gui, TimerSetup:Add, Text, x32 y250 w396 h43 BackgroundTrans, 1000 ms = 1 second. 60000 ms = 1 minute.`nKeep the minimum no higher than the maximum.
    Gui, TimerSetup:Font, s11 Bold c24324A, Segoe UI
    Gui, TimerSetup:Add, Button, x44 y301 w177 h36 gTimerSetupSave, Save Timer
    Gui, TimerSetup:Add, Button, x239 y301 w177 h36 gTimerSetupClose, Close
    LLARS_TimerSetupLoadSelected()
    Gui, TimerSetup:Show, Center w460 h363, Timer Settings
    LLARS_VisualFinish("TimerSetup")
    ; Focus the selection list, not an Edit, so the numeric values are not selected.
    GuiControl, TimerSetup:Focus, LLARSTimerSelection
}

LLARS_TimerSetupLoadSelected()
{
    global LLARS_TIMER_SECTIONS, LLARSTimerSelection, LLARS_SCRIPT_DIR
    GuiControlGet, selectedIndex, TimerSetup:, LLARSTimerSelection
    if (selectedIndex < 1 || selectedIndex > LLARS_TIMER_SECTIONS.Length())
        return
    section := LLARS_TIMER_SECTIONS[selectedIndex]
    path := LLARS_SCRIPT_DIR . "\Config.ini"
    minValue := LLARS_ConfigReadFile(path, section, "min", "")
    maxValue := LLARS_ConfigReadFile(path, section, "max", "")
    GuiControl, TimerSetup:, LLARSTimerMin, %minValue%
    GuiControl, TimerSetup:, LLARSTimerMax, %maxValue%
}

LLARS_TimerSetupSaveSelected()
{
    global LLARS_TIMER_SECTIONS, LLARSTimerSelection, LLARS_SCRIPT_DIR
    GuiControlGet, selectedIndex, TimerSetup:, LLARSTimerSelection
    if (selectedIndex < 1 || selectedIndex > LLARS_TIMER_SECTIONS.Length())
        return
    GuiControlGet, minValue, TimerSetup:, LLARSTimerMin
    GuiControlGet, maxValue, TimerSetup:, LLARSTimerMax
    minValue := Trim(minValue)
    maxValue := Trim(maxValue)
    if (!RegExMatch(minValue, "^\d+$") || !RegExMatch(maxValue, "^\d+$"))
    {
        MsgBox, 262192, LLARS Timer, Enter non-negative whole numbers for both timer values.
        return
    }
    if ((minValue + 0) > (maxValue + 0))
    {
        MsgBox, 262192, LLARS Timer, Minimum cannot be greater than maximum.
        return
    }
    section := LLARS_TIMER_SECTIONS[selectedIndex]
    configPath := LLARS_SCRIPT_DIR . "\Config.ini"
    ; Validate against the current disk schema before writing; no arbitrary section edit.
    if (LLARS_ConfigCapabilitySectionType(configPath, section) != "timer")
        return
    oldMin := LLARS_ConfigReadFile(configPath, section, "min", "ERROR")
    oldMax := LLARS_ConfigReadFile(configPath, section, "max", "ERROR")
    if (oldMin = "ERROR" || oldMax = "ERROR")
        return
    if (!LLARS_ConfigWriteFile(configPath, section, "min", minValue))
    {
        MsgBox, 262192, LLARS Timer, Could not update the timer minimum. Check file permissions.
        return
    }
    if (!LLARS_ConfigWriteFile(configPath, section, "max", maxValue))
    {
        LLARS_ConfigWriteFile(configPath, section, "min", oldMin)
        MsgBox, 262192, LLARS Timer, Could not update the timer maximum. The previous minimum was restored where possible.
        return
    }
    LLARS_UpdateConfigStatus()
    LLARS_VisualConfigNotice("Timer Updated", section . " saved: " . minValue . "-" . maxValue . " ms", "Timer")
}

LLARS_TimerSetupClose()
{
    global LLARSTimerSetupHwnd, LLARS_TIMER_SECTIONS
    Gui, TimerSetup:Destroy
    LLARSTimerSetupHwnd := 0
    LLARS_TIMER_SECTIONS := []
    LLARS_DeveloperUIAction("Timer Configuration", "Closed")
    Gui, 1:Show
    EnableHotkey()
    LLARS_VisualRestoreMain()
    LLARS_UpdateConfigStatus()
}
