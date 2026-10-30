; LLARS runtime dashboard. Stable control IDs are part of the public script API.

; User-facing presentation only; input and run logic remain separate.



; Preserve every native control and font size. Only the dashboard coordinates
; and existing four background assets are compacted to remove excess spacing.
LLARS_GUIRuntimeSize(value)
{
    return Round(value * 0.89)
}

; Keep text and button control heights from the last accepted running layout;
; only their positions and widths are made more compact.
LLARS_GUIRuntimeControlHeight(value)
{
    return Round(value * 0.92)
}

LLARS_GUISetupY(value)
{
    ; Keep all native font/control heights. Shorten the shared navy header by
    ; moving the body layout up in lockstep with its background art.
    if (value >= 645)
        return value - 72
    if (value >= 550)
        return value - 60
    if (value >= 470)
        return value - 47
    if (value >= 275)
        return value - 36
    if (value >= 135)
        return value - 19
    return value
}

LLARS_GUIRuntimeY(value)
{
    global LLARS_GUIRuntimeMode
    if (LLARS_GUIRuntimeMode = "until_done")
        offset := (value >= 365) ? 22 : (value >= 260) ? 7 : 0
    else if (LLARS_GUIRuntimeMode = "timer")
        offset := (value >= 480) ? 37 : (value >= 380) ? 29 : (value >= 275) ? 7 : 0
    else
        offset := (value >= 560) ? 37 : (value >= 450) ? 29 : (value >= 275) ? 7 : 0
    ; Align every running-mode section and its buttons with the raised body card.
    ; The Actions heading and two button rows keep their inner breathing room;
    ; later sections gain the full 17-pixel header reduction.
    moveUp := (value = 143 || value = 175 || value = 216) ? 10 : (value >= 135 ? 17 : 0)
    return Round(value * 0.89) - offset - moveUp
}

LLARS_GUIRuntimeHeight(mode)
{
    return (mode = "running") ? 499 : (mode = "timer") ? 422 : 336
}

LLARS_GUIBase(scriptName, hwnd, mode := "setup")
{
    global LLARS_GUICompactMode, LLARS_GUIRuntimeMode, LLARS_GUIRemainingPaintCache
    LLARS_GUIRuntimeMode := mode
    LLARS_GUIRemainingPaintCache := {}
    LLARS_GUICompactMode := (mode = "running" || mode = "timer" || mode = "until_done")
    if (LLARS_GUICompactMode)
    {
        LLARS_GUIRuntimeBase(scriptName, hwnd, mode)
        return
    }
    global LLARS_ConfigStatusPaintCache
    LLARS_ConfigStatusPaintCache := {}
    LLARS_VisualPrepare("1", 10)
    ; A single original background is shared by the content and title area.
    ; Its layer is added before the live, accessible native controls.
    LLARS_VisualDashboard("1", mode)
    Gui, Font, s20 Bold cFFFFFF, Segoe UI
    Gui, Add, Text, Center x28 y3 w377 h34 BackgroundTrans, LLARS
    Gui, Font, s9 Bold cD6E5F8, Segoe UI
    Gui, Add, Text, Center x28 y35 w377 h30 +0x200 BackgroundTrans, Local Library of Automated Routines and Scripts
    Gui, Font, s13 Bold cFFFFFF, Segoe UI
    Gui, Add, Text, Center x28 y67 w377 h26 +0x4000 BackgroundTrans, %scriptName%
}

LLARS_GUISection(caption, x, y, width := 325)
{
    global LLARS_GUICompactMode
    if (LLARS_GUICompactMode)
    {
        LLARS_GUIRuntimeSection(caption, x, y, width)
        return
    }
    Gui, Font, s9 Bold c4E6382, Segoe UI
    Gui, Add, Text, % "x" . Round(x * 432 / 468) . " y" . LLARS_GUISetupY(y) . " w" . Round(width * 432 / 468) . " h18 BackgroundTrans", %caption%
}

LLARS_GUIActions(active := false)
{
    global LLARS_GUICompactMode
    if (LLARS_GUICompactMode)
    {
        LLARS_GUIRuntimeActions()
        return
    }
    LLARS_GUISection("ACTIONS", 39, 143)
    Gui, Font, s10 Norm c20334E, Segoe UI
    Gui, Add, Button, x33 y156 w175 h36 gStart, Start
    Gui, Add, Button, x222 y156 w175 h36 gInfo, Information
    if (active)
    {
        Gui, Add, Button, x33 y197 w175 h35 gPauseb, Pause
        Gui, Add, Button, x222 y197 w175 h35 gResumeb, Resume
    }
    else
    {
        Gui, Add, Button, x33 y197 w175 h35 gCombo, Setup
        Gui, Add, Button, x222 y197 w175 h35 gConfigSettings, Config Settings
    }
}

LLARS_GUIActivity(y, mode := "initial")
{
    global LLARS_GUICompactMode
    if (LLARS_GUICompactMode)
    {
        LLARS_GUIRuntimeActivity(y, mode)
        return
    }
    global ScriptGreen, State1, ScriptBlue, ScriptRed, State3, State2
    LLARS_GUISection("CURRENT ACTIVITY", 39, y+13)
    Gui, Font, s9 Bold c70829C, Segoe UI
    Gui, Add, Text, % "x315 y" . LLARS_GUISetupY(y+14) . " w83 h19 Right BackgroundTrans", STATUS
    Gui, Font, s11 Bold c20334E, Segoe UI
    controlY := LLARS_GUISetupY(y+45)
    if (mode = "running")
    {
        Gui, Add, Text, % "x34 y" . controlY . " w220 h24 +0x4000 vScriptGreen BackgroundTrans"
        Gui, Font, s11 Bold c128C79, Segoe UI
        Gui, Add, Text, % "x258 y" . controlY . " w140 h24 Right +0x4000 vState1 BackgroundTrans"
        Gui, Font, s11 Bold c20334E, Segoe UI
    }
    Gui, Add, Text, % "x34 y" . controlY . " w220 h24 +0x4000 vScriptBlue BackgroundTrans"
    Gui, Font, s11 Bold c3676E8, Segoe UI
    Gui, Add, Text, % "x258 y" . controlY . " w140 h24 Right +0x4000 vState3 BackgroundTrans"
    Gui, Font, s11 Bold c20334E, Segoe UI
    Gui, Add, Text, % "x34 y" . controlY . " w220 h24 +0x4000 vScriptRed BackgroundTrans"
    Gui, Font, s11 Bold cEF4444, Segoe UI
    Gui, Add, Text, % "x258 y" . controlY . " w140 h24 Right +0x4000 vState2 BackgroundTrans"
}

LLARS_GUIExit(y)
{
    global LLARS_GUICompactMode
    if (LLARS_GUICompactMode)
    {
        LLARS_GUIRuntimeExit(y)
        return
    }
    Gui, Font, s10 Norm c20334E, Segoe UI
    Gui, Add, Button, % "x147 y" . LLARS_GUISetupY(y) . " w138 h36 gExitb", Exit LLARS
}

LLARS_GUIPresent(title, height, hwnd, root, hasPosition := false, x := "", y := "")
{
    ; Create the native owner-draw state before the first Show to avoid flash.
    LLARS_VisualStyleControls(hwnd)
    global LLARS_GUICompactMode, LLARS_GUIRuntimeMode
    if (LLARS_GUICompactMode)
    {
        width := LLARS_GUIRuntimeSize(468)
        height := LLARS_GUIRuntimeHeight(LLARS_GUIRuntimeMode)
        if (hasPosition)
            Gui, Show, % "x" . x . " y" . y . " w" . width . " h" . height, %title%
        else
            Gui, Show, % "w" . width . " h" . height, %title%
    }
    else if (hasPosition)
        Gui, Show, % "x" . x . " y" . y . " w432 h" . height, %title%
    else
        Gui, Show, % "w432 h" . height, %title%
    LLARS_VisualWindow(hwnd)
    ; Use native fully opaque dashboard rendering for reliable text and panel painting.
    WinSet, Transparent, Off, % "ahk_id " . hwnd
    CheckPOS(hwnd)
    LLARS_VisualMainIcon(hwnd, root)
    LLARS_VisualPaintReady(hwnd)
}

LLARS_CreateMainGUI()
{
    global scriptname, LLARS_ROOT, LLARS_SCRIPT_DIR, LLARSMainGuiHwnd, LLARS_SCRIPT_TYPE, LLARS_CONFIG_FILE
    global Counter, State3, State2, ScriptBlue, ScriptRed
    global ConfigStatusHotkeys, ConfigStatusCoordinates, ConfigStatusColors, ConfigStatusTimer, ConfigStatusScriptConfig
    global ConfigStatusHotkeysLabel, ConfigStatusCoordinatesLabel, ConfigStatusColorsLabel, ConfigStatusTimerLabel, ConfigStatusScriptConfigLabel
    Gui, 1:Default
    name := LLARS_DisplayScriptName()
    title := LLARS_WindowTitle()
    Gui, +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSMainGuiHwnd
    LLARS_GUIBase(name, LLARSMainGuiHwnd, "setup")
    LLARS_GUIActions(false)

    LLARS_GUISection("SETUP CHECKLIST", 39, 286)
    Gui, Font, s10 Bold c253650, Segoe UI
    Gui, Add, Text, x36 y291 w209 h23 vConfigStatusHotkeysLabel gSetupStatusHotkeys BackgroundTrans, Hotkeys
    Gui, Add, Text, x36 y318 w209 h23 vConfigStatusCoordinatesLabel gSetupStatusCoordinates BackgroundTrans, Coordinates
    Gui, Add, Text, x36 y345 w209 h23 vConfigStatusColorsLabel gSetupStatusColors BackgroundTrans, Colors
    Gui, Add, Text, x36 y372 w209 h23 vConfigStatusTimerLabel gSetupStatusTimer BackgroundTrans, Timer
    Gui, Add, Text, x36 y399 w209 h23 vConfigStatusScriptConfigLabel gSetupStatusScriptConfig BackgroundTrans, Script Config
    Gui, Font, s10 Bold c2868D9, Segoe UI
    Gui, Add, Text, x252 y291 w146 h23 Right +0x4000 vConfigStatusHotkeys gSetupStatusHotkeys BackgroundTrans, Checking
    Gui, Add, Text, x252 y318 w146 h23 Right +0x4000 vConfigStatusCoordinates gSetupStatusCoordinates BackgroundTrans, Checking
    Gui, Add, Text, x252 y345 w146 h23 Right +0x4000 vConfigStatusColors gSetupStatusColors BackgroundTrans, Checking
    Gui, Add, Text, x252 y372 w146 h23 Right +0x4000 vConfigStatusTimer gSetupStatusTimer BackgroundTrans, Checking
    Gui, Add, Text, x252 y399 w146 h23 Right +0x4000 vConfigStatusScriptConfig gSetupStatusScriptConfig BackgroundTrans, Checking

    LLARS_GUISection("RUN CONFIGURATION", 39, 483)
    Gui, Font, s10 Bold c253650, Segoe UI
    Gui, Add, Text, x36 y466 w189 h23 BackgroundTrans, % (LLARS_SCRIPT_TYPE = "UntilDone" ? "Run mode" : "Run count")
    Gui, Font, s11 Bold cEF4444, Segoe UI
    Gui, Add, Text, x229 y465 w169 h24 Right vCounter BackgroundTrans, % (LLARS_SCRIPT_TYPE = "UntilDone" ? "Until complete" : "** NOT SET **")
    LLARS_GUIActivity(559, "initial")
    LLARS_GUIExit(654)
    LLARS_UpdateConfigStatus()
    GuiControl, 1:, ScriptRed, %name%
    GuiControl, 1:, State2, ** OFF **
    LLARS_VisualShowStatus("red")
    if FileExist(LLARS_ROOT "\Assets\Logo\LLARS\LLARS Logo.ico")
        Menu, Tray, Icon, %LLARS_ROOT%\Assets\Logo\LLARS\LLARS Logo.ico
    hasPosition := LLARS_MainLoadPosition(x, y)
    LLARS_GUIPresent(title, 633, LLARSMainGuiHwnd, LLARS_ROOT, hasPosition, x, y)
}

LLARS_CreateRunCountGUI()
{
    global scriptname, X, Y, frcount, count, LLARS_RUNNING, LLARS_ROOT, LLARS_SCRIPT_DIR, LLARSMainGuiHwnd, LLARS_CONFIG_FILE
    global Counter, Counter2, EstLoopRemaining, EstRunRemaining, State1, State3, State2, ScriptGreen, ScriptBlue, ScriptRed
    Gui, 1:Default
    name := LLARS_DisplayScriptName()
    title := LLARS_WindowTitle()
    LLARS_RUNNING := true
    SetLLARSHOTKEYS()
    hasPosition := LLARS_MainGetPosition(X, Y)
    if (!hasPosition)
        hasPosition := LLARS_MainLoadPosition(X, Y)
    Gui, Destroy
    Gui, +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSMainGuiHwnd
    LLARS_GUIBase(name, LLARSMainGuiHwnd, "running")
    LLARS_GUIActions(true)
    LLARS_GUISection("RUN PROGRESS", 39, 285)
    metrics := [{name:"Current run", id:"Counter2"}, {name:"Total runs", id:"Counter"}, {name:"Loop remaining", id:"EstLoopRemaining"}, {name:"Run remaining", id:"EstRunRemaining"}]
    for i, metric in metrics
    {
        ry := 321 + 31*(i-1)
        Gui, Font, s10 Bold c253650, Segoe UI
        Gui, Add, Text, % "x" . LLARS_GUIRuntimeSize(39) . " y" . LLARS_GUIRuntimeY(ry) . " w" . LLARS_GUIRuntimeSize(220) . " h" . LLARS_GUIRuntimeControlHeight(24) . " BackgroundTrans", % metric.name
        Gui, Font, s11 Bold c22334A, Segoe UI
        Gui, Add, Text, % "x" . LLARS_GUIRuntimeSize(265) . " y" . LLARS_GUIRuntimeY(ry) . " w" . LLARS_GUIRuntimeSize(166) . " h" . LLARS_GUIRuntimeControlHeight(24) . " Right +0x4000 v" . metric.id . " BackgroundTrans"
    }
    LLARS_GUIActivity(475, "running")
    LLARS_GUIExit(575)
    GuiControl, 1:, ScriptRed, %name%
    GuiControl, 1:, State2, ** OFF **
    LLARS_VisualShowStatus("red")
    if FileExist(LLARS_ROOT "\Assets\Logo\LLARS\LLARS Logo.ico")
        Menu, Tray, Icon, %LLARS_ROOT%\Assets\Logo\LLARS\LLARS Logo.ico
    LLARS_GUIPresent(title, 621, LLARSMainGuiHwnd, LLARS_ROOT, hasPosition, X, Y)
    count = 0
    ++frcount
}

LLARS_CreateTimerGUI()
{
    global scriptname, X, Y, LLARS_ROOT, LLARS_SCRIPT_DIR, LLARSMainGuiHwnd, LLARS_CONFIG_FILE
    global TimerCount, State3, State2, ScriptBlue, ScriptRed
    Gui, 1:Default
    name := LLARS_DisplayScriptName()
    title := LLARS_WindowTitle()
    hasPosition := LLARS_MainGetPosition(X, Y)
    if (!hasPosition)
        hasPosition := LLARS_MainLoadPosition(X, Y)
    Gui, Destroy
    Gui, +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSMainGuiHwnd
    LLARS_GUIBase(name, LLARSMainGuiHwnd, "timer")
    LLARS_GUIActions(true)
    LLARS_GUISection("TIME REMAINING", 39, 287)
    Gui, Font, s16 Bold c22334A, Segoe UI
    ; Center the remaining-time value within its section of the unified card.
    Gui, Add, Text, % "x" . LLARS_GUIRuntimeSize(39) . " y" . LLARS_GUIRuntimeY(321) . " w" . LLARS_GUIRuntimeSize(390) . " h" . LLARS_GUIRuntimeControlHeight(34) . " Center vTimerCount BackgroundTrans"
    LLARS_GUIActivity(389, "initial")
    LLARS_GUIExit(489)
    GuiControl, 1:, ScriptRed, %name%
    GuiControl, 1:, State2, ** OFF **
    LLARS_VisualShowStatus("red")
    if FileExist(LLARS_ROOT "\Assets\Logo\LLARS\LLARS Logo.ico")
        Menu, Tray, Icon, %LLARS_ROOT%\Assets\Logo\LLARS\LLARS Logo.ico
    LLARS_GUIPresent(title, 535, LLARSMainGuiHwnd, LLARS_ROOT, hasPosition, X, Y)
}

LLARS_CreateUntilDoneGUI()
{
    global scriptname, X, Y, LLARS_ROOT, LLARS_SCRIPT_DIR, LLARSMainGuiHwnd, LLARS_CONFIG_FILE
    global State3, State2, ScriptBlue, ScriptRed
    Gui, 1:Default
    name := LLARS_DisplayScriptName()
    title := LLARS_WindowTitle()
    hasPosition := LLARS_MainGetPosition(X, Y)
    if (!hasPosition)
        hasPosition := LLARS_MainLoadPosition(X, Y)
    Gui, Destroy
    Gui, +LastFound +OwnDialogs +AlwaysOnTop +HwndLLARSMainGuiHwnd
    LLARS_GUIBase(name, LLARSMainGuiHwnd, "until_done")
    LLARS_GUIActions(true)
    LLARS_GUIActivity(273, "initial")
    LLARS_GUIExit(375)
    GuiControl, 1:, ScriptRed, %name%
    GuiControl, 1:, State2, ** OFF **
    LLARS_VisualShowStatus("red")
    if FileExist(LLARS_ROOT "\Assets\Logo\LLARS\LLARS Logo.ico")
        Menu, Tray, Icon, %LLARS_ROOT%\Assets\Logo\LLARS\LLARS Logo.ico
    LLARS_GUIPresent(title, 421, LLARSMainGuiHwnd, LLARS_ROOT, hasPosition, X, Y)
}

; Running-state GUI: the same controls, fonts and section hierarchy as the
; existing dashboard, compacted within one continuous card. Native text sizes are unchanged
; to protect readability; no new running-mode controls or behaviors are added.
LLARS_GUIRuntimeBase(scriptName, hwnd, mode)
{
    global LLARS_ConfigStatusPaintCache
    LLARS_ConfigStatusPaintCache := {}
    LLARS_VisualPrepare("1", 10)
    LLARS_VisualDashboard("1", mode)
    x := LLARS_GUIRuntimeSize(30), w := LLARS_GUIRuntimeSize(408)
    Gui, Font, s20 Bold cFFFFFF, Segoe UI
    Gui, Add, Text, % "Center x" . x . " y3 w" . w . " h" . LLARS_GUIRuntimeControlHeight(34) . " BackgroundTrans", LLARS
    Gui, Font, s9 Bold cD6E5F8, Segoe UI
    Gui, Add, Text, % "Center x" . x . " y35 w" . w . " h" . LLARS_GUIRuntimeControlHeight(30) . " +0x200 BackgroundTrans", Local Library of Automated Routines and Scripts
    Gui, Font, s13 Bold cFFFFFF, Segoe UI
    Gui, Add, Text, % "Center x" . x . " y67 w" . w . " h" . LLARS_GUIRuntimeControlHeight(26) . " +0x4000 BackgroundTrans", %scriptName%
}

LLARS_GUIRuntimeSection(caption, x, y, width := 325)
{
    Gui, Font, s9 Bold c4E6382, Segoe UI
    Gui, Add, Text, % "x" . LLARS_GUIRuntimeSize(x) . " y" . LLARS_GUIRuntimeY(y) . " w" . LLARS_GUIRuntimeSize(width) . " h" . LLARS_GUIRuntimeControlHeight(18) . " BackgroundTrans", %caption%
}

LLARS_GUIRuntimeActions()
{
    LLARS_GUIRuntimeSection("ACTIONS", 39, 143)
    Gui, Font, s10 Norm c20334E, Segoe UI
    left := LLARS_GUIRuntimeSize(36), right := LLARS_GUIRuntimeSize(240)
    top := LLARS_GUIRuntimeY(175), bottom := LLARS_GUIRuntimeY(216)
    width := LLARS_GUIRuntimeSize(190), topH := LLARS_GUIRuntimeControlHeight(36), bottomH := LLARS_GUIRuntimeControlHeight(35)
    Gui, Add, Button, % "x" . left . " y" . top . " w" . width . " h" . topH . " gStart", Start
    Gui, Add, Button, % "x" . right . " y" . top . " w" . width . " h" . topH . " gInfo", Information
    Gui, Add, Button, % "x" . left . " y" . bottom . " w" . width . " h" . bottomH . " gPauseb", Pause
    Gui, Add, Button, % "x" . right . " y" . bottom . " w" . width . " h" . bottomH . " gResumeb", Resume
}

LLARS_GUIRuntimeActivity(y, mode := "initial")
{
    global ScriptGreen, State1, ScriptBlue, ScriptRed, State3, State2
    LLARS_GUIRuntimeSection("CURRENT ACTIVITY", 39, y+13)
    Gui, Font, s9 Bold c70829C, Segoe UI
    Gui, Add, Text, % "x" . LLARS_GUIRuntimeSize(341) . " y" . LLARS_GUIRuntimeY(y+14) . " w" . LLARS_GUIRuntimeSize(90) . " h" . LLARS_GUIRuntimeControlHeight(19) . " Right BackgroundTrans", STATUS
    nameX := LLARS_GUIRuntimeSize(37), nameW := LLARS_GUIRuntimeSize(239)
    stateX := LLARS_GUIRuntimeSize(279), stateW := LLARS_GUIRuntimeSize(151)
    textY := LLARS_GUIRuntimeY(y+45), textH := LLARS_GUIRuntimeControlHeight(24)
    Gui, Font, s11 Bold c20334E, Segoe UI
    if (mode = "running")
    {
        Gui, Add, Text, % "x" . nameX . " y" . textY . " w" . nameW . " h" . textH . " +0x4000 vScriptGreen BackgroundTrans"
        runningColor := "128C79"
        Gui, Font, % "s11 Bold c" . runningColor, Segoe UI
        Gui, Add, Text, % "x" . stateX . " y" . textY . " w" . stateW . " h" . textH . " Right +0x4000 vState1 BackgroundTrans"
        Gui, Font, s11 Bold c20334E, Segoe UI
    }
    Gui, Add, Text, % "x" . nameX . " y" . textY . " w" . nameW . " h" . textH . " +0x4000 vScriptBlue BackgroundTrans"
    Gui, Font, s11 Bold c3676E8, Segoe UI
    Gui, Add, Text, % "x" . stateX . " y" . textY . " w" . stateW . " h" . textH . " Right +0x4000 vState3 BackgroundTrans"
    Gui, Font, s11 Bold c20334E, Segoe UI
    Gui, Add, Text, % "x" . nameX . " y" . textY . " w" . nameW . " h" . textH . " +0x4000 vScriptRed BackgroundTrans"
    Gui, Font, s11 Bold cEF4444, Segoe UI
    Gui, Add, Text, % "x" . stateX . " y" . textY . " w" . stateW . " h" . textH . " Right +0x4000 vState2 BackgroundTrans"
}

LLARS_GUIRuntimeExit(y)
{
    Gui, Font, s10 Norm c20334E, Segoe UI
    Gui, Add, Button, % "x" . LLARS_GUIRuntimeSize(158) . " y" . LLARS_GUIRuntimeY(y) . " w" . LLARS_GUIRuntimeSize(150) . " h" . LLARS_GUIRuntimeControlHeight(36) . " gExitb", Exit LLARS
}
