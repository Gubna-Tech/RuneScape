; Setup helpers are read-only except for opening the existing Timer Settings editor.
; Coordinate previews use the shared client-to-screen overlay and never move the mouse.
LLARS_CoordinateVerifierSections()
{
    global LLARS_SCRIPT_DIR, LLARS_CONFIG_FILE
    result := []
    for _, configPath in [LLARS_SCRIPT_DIR . "\Config.ini", LLARS_CONFIG_FILE]
    {
        if !FileExist(configPath)
            continue
        scope := (configPath = LLARS_CONFIG_FILE) ? "LLARS" : "Script"
        sections := LLARS_ConfigSectionList(configPath)
        if (sections = "ERROR")
            continue
        Loop, Parse, sections, `n, `r
        {
            section := LLARS_NormalizeConfigSectionName(A_LoopField)
            if (section = "" || LLARS_ConfigCapabilitySectionType(configPath, section) != "coordinate")
                continue
            result.Push({Label:scope . " - " . section, Section:section, Path:configPath})
        }
    }
    return result
}

LLARS_CoordinateVerifierShow()
{
    global LLARS_VERIFIER_SECTIONS, LLARSVerifierSection, LLARSVerifierStatus
    LLARS_VERIFIER_SECTIONS := LLARS_CoordinateVerifierSections()
    if (!LLARS_VERIFIER_SECTIONS.Length())
    {
        MsgBox, 262192, Coordinate Verifier, No saved coordinate sections are available for this script.
        return
    }
    items := ""
    for _, item in LLARS_VERIFIER_SECTIONS
        items .= (items = "" ? "" : "|") . item.Label
    LLARS_HideCoordinatePreview()
    Gui, Combo:Hide
    Gui, CoordinateVerifier:Destroy
    Gui, CoordinateVerifier:New, +AlwaysOnTop +OwnDialogs -ToolWindow +E0x40000, Coordinate Verifier
    LLARS_VisualPrepare("CoordinateVerifier")
    Gui, CoordinateVerifier:Color, FFFFFF, FFFFFF
    LLARS_VisualModalHeader("CoordinateVerifier", 320, "Coordinate Verifier")
    Gui, CoordinateVerifier:Font, s10 Norm c24324A, Segoe UI
    Gui, CoordinateVerifier:Add, Text, x18 y95 w284 h58 +Wrap BackgroundTrans, Choose a saved coordinate section to outline it over the target window. No settings are changed.
    Gui, CoordinateVerifier:Add, DropDownList, x18 y163 w284 h210 vLLARSVerifierSection AltSubmit Choose1 gLLARS_CoordinateVerifierChoose, %items%
    Gui, CoordinateVerifier:Add, Text, x12 y198 w296 h2 0x10
    Gui, CoordinateVerifier:Font, s10 Bold c24324A, Segoe UI
    Gui, CoordinateVerifier:Add, Button, x18 y214 w136 h36 gLLARS_CoordinateVerifierChoose, Show Overlay
    Gui, CoordinateVerifier:Add, Button, x166 y214 w136 h36 gLLARS_CoordinateVerifierClear, Clear Overlay
    Gui, CoordinateVerifier:Add, Button, x92 y260 w136 h36 gLLARS_CloseCoordinateVerifier, Close
    Gui, CoordinateVerifier:Add, Text, x12 y305 w296 h2 0x10
    Gui, CoordinateVerifier:Font, s10 Norm c24324A, Segoe UI
    Gui, CoordinateVerifier:Add, Text, x18 y314 w284 h38 +Wrap vLLARSVerifierStatus BackgroundTrans, Nothing is being changed.
    Gui, CoordinateVerifier:Show, Center w320 h362, Coordinate Verifier
    LLARS_VisualFinish("CoordinateVerifier")
}

LLARS_CoordinateVerifierPreview()
{
    global LLARS_VERIFIER_SECTIONS
    LLARS_HideCoordinatePreview()
    GuiControlGet, selected, CoordinateVerifier:, LLARSVerifierSection
    if (selected < 1 || selected > LLARS_VERIFIER_SECTIONS.Length())
        return
    item := LLARS_VERIFIER_SECTIONS[selected]
    x1 := Trim(LLARS_ConfigReadFile(item.Path, item.Section, "xmin", ""))
    x2 := Trim(LLARS_ConfigReadFile(item.Path, item.Section, "xmax", ""))
    y1 := Trim(LLARS_ConfigReadFile(item.Path, item.Section, "ymin", ""))
    y2 := Trim(LLARS_ConfigReadFile(item.Path, item.Section, "ymax", ""))
    if (!RegExMatch(x1, "^-?\d+$") || !RegExMatch(x2, "^-?\d+$") || !RegExMatch(y1, "^-?\d+$") || !RegExMatch(y2, "^-?\d+$"))
    {
        x1 := Trim(LLARS_ConfigReadFile(item.Path, item.Section, "x", ""))
        y1 := Trim(LLARS_ConfigReadFile(item.Path, item.Section, "y", ""))
        if (!RegExMatch(x1, "^-?\d+$") || !RegExMatch(y1, "^-?\d+$"))
        {
            GuiControl, CoordinateVerifier:, LLARSVerifierStatus, This coordinate has not been captured yet.
            return
        }
        x2 := x1 + 6, y2 := y1 + 6, x1 -= 6, y1 -= 6
    }
    if (LLARS_ShowCoordinatePreview(x1 + 0, y1 + 0, x2 + 0, y2 + 0) = false)
    {
        GuiControl, CoordinateVerifier:, LLARSVerifierStatus, Open the configured target window before showing an overlay.
        return
    }
    GuiControl, CoordinateVerifier:, LLARSVerifierStatus, % "Showing " . item.Label . " over the target window. Close to clear."
}

LLARS_CoordinateVerifierClose()
{
    LLARS_HideCoordinatePreview()
    Gui, CoordinateVerifier:Destroy
    Gui, Combo:Show
}

LLARS_TimerHelperShow()
{
    global LLARS_TIMER_HELPER_TICK, LLARS_TIMER_HELPER_ACTIVE, LLARS_TimerHelperGuiHwnd, LLARSTimerHelperResult
    LLARS_TIMER_HELPER_TICK := 0
    LLARS_TIMER_HELPER_ACTIVE := false
    Gui, Combo:Hide
    Gui, TimerHelper:Destroy
    Gui, TimerHelper:New, +AlwaysOnTop +OwnDialogs -ToolWindow +E0x40000 +HwndLLARS_TimerHelperGuiHwnd, Timer Helper
    LLARS_VisualPrepare("TimerHelper")
    Gui, TimerHelper:Color, FFFFFF, FFFFFF
    LLARS_VisualModalHeader("TimerHelper", 320, "Timer Helper")
    Gui, TimerHelper:Font, s10 Norm c24324A, Segoe UI
    Gui, TimerHelper:Add, Text, x18 y102 w284 h54 +Wrap BackgroundTrans, Press F10 to start and F11 to stop timing, even while another app is focused. LLARS sends no input.
    Gui, TimerHelper:Add, Text, x12 y161 w296 h2 0x10
    Gui, TimerHelper:Font, s11 Bold c24324A, Segoe UI
    Gui, TimerHelper:Add, Text, x18 y174 w284 h36 Center +0x200 vLLARSTimerHelperResult BackgroundTrans, No measurement yet.
    Gui, TimerHelper:Add, Text, x12 y221 w296 h2 0x10
    Gui, TimerHelper:Font, s10 Bold c24324A, Segoe UI
    Gui, TimerHelper:Add, Button, x18 y233 w136 h36 gLLARS_TimerHelperStart, Start (F10)
    Gui, TimerHelper:Add, Button, x166 y233 w136 h36 gLLARS_TimerHelperStop, Stop (F11)
    Gui, TimerHelper:Add, Button, x18 y282 w136 h36 gLLARS_TimerHelperEdit, Edit Timers
    Gui, TimerHelper:Add, Button, x166 y282 w136 h36 gLLARS_CloseTimerHelper, Close
    Gui, TimerHelper:Show, Center w320 h330, Timer Helper
    LLARS_VisualFinish("TimerHelper")
    LLARS_TIMER_HELPER_ACTIVE := true
}

LLARS_TimerHelperHotkeysActive()
{
    global LLARS_TIMER_HELPER_ACTIVE, LLARS_TimerHelperGuiHwnd
    return (LLARS_TIMER_HELPER_ACTIVE && LLARS_TimerHelperGuiHwnd
        && WinExist("ahk_id " . LLARS_TimerHelperGuiHwnd))
}

LLARS_TimerHelperStart()
{
    global LLARS_TIMER_HELPER_TICK
    if (LLARS_TIMER_HELPER_TICK > 0)
        return
    LLARS_TIMER_HELPER_TICK := LLARS_NowMS()
    GuiControl, TimerHelper:, LLARSTimerHelperResult, Timing started. Press F11 to stop.
}

LLARS_TimerHelperStop()
{
    global LLARS_TIMER_HELPER_TICK
    if (LLARS_TIMER_HELPER_TICK <= 0)
    {
        GuiControl, TimerHelper:, LLARSTimerHelperResult, Press F10 or Start before stopping the timer.
        return
    }
    elapsed := Max(0, Round(LLARS_NowMS() - LLARS_TIMER_HELPER_TICK))
    LLARS_TIMER_HELPER_TICK := 0
    GuiControl, TimerHelper:, LLARSTimerHelperResult, % "Measured: " . elapsed . " ms (" . Round(elapsed / 1000, 2) . " s)"
}

LLARS_TimerHelperOpenEditor()
{
    global LLARS_TIMER_HELPER_TICK, LLARS_TIMER_HELPER_ACTIVE, LLARS_TimerHelperGuiHwnd
    ; Keep this helper open if the selected script has no editable timers.
    timerSections := LLARS_TimerSetupSections()
    if (!timerSections.Length())
    {
        MsgBox, 262192, Timer Helper, This script has no configurable timer ranges.
        return
    }
    LLARS_TIMER_HELPER_ACTIVE := false
    LLARS_TIMER_HELPER_TICK := 0
    Gui, TimerHelper:Destroy
    LLARS_TimerHelperGuiHwnd := 0
    LLARS_TimerSetupShow()
}

LLARS_TimerHelperClose()
{
    global LLARS_TIMER_HELPER_TICK, LLARS_TIMER_HELPER_ACTIVE, LLARS_TimerHelperGuiHwnd
    LLARS_TIMER_HELPER_ACTIVE := false
    LLARS_TIMER_HELPER_TICK := 0
    Gui, TimerHelper:Destroy
    LLARS_TimerHelperGuiHwnd := 0
    Gui, Combo:Show
}
