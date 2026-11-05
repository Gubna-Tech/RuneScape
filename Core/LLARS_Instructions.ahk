; Script-specific, read-only setup instructions.
LLARS_InstructionsGuidePath()
{
    global LLARS_ROOT
    root := RTrim(LLARS_ROOT, "\/") . "\"
    scriptPath := A_ScriptFullPath
    if (SubStr(scriptPath, 1, StrLen(root)) != root)
        return ""
    relative := StrReplace(SubStr(scriptPath, StrLen(root) + 1), "\", "/")
    if (!RegExMatch(relative, "i)^(Scripts|Scripts - Menu Entry Swapper)/[A-Za-z0-9 _./&'()+-]+[.]ahk$"))
        return ""
    return root . "Documentation\Script Instructions\" . StrReplace(RegExReplace(relative, "i)[.]ahk$", ".txt"), "/", "\")
}

LLARS_InstructionsText()
{
    guidePath := LLARS_InstructionsGuidePath()
    if (guidePath != "" && FileExist(guidePath))
    {
        FileRead, guideText, %guidePath%
        if (!ErrorLevel && Trim(guideText) != "")
            return guideText
    }
    return "SCRIPT INSTRUCTIONS`r`n`r`nNo guide is bundled for this custom script yet.`r`n`r`n1. Prepare the required activity and items in RuneScape.`r`n`r`n2. Configure any Hotkeys, Coordinates and Colors using Setup.`r`n`r`n3. Verify the settings and in-game starting position before pressing Start."
}

; Append text in a known style instead of styling character offsets after
; SetWindowText. RichEdit normalizes CRLF internally, making those offsets
; drift by one character per line (and bolding unrelated words).
LLARS_InstructionsAppendRich(textHwnd, part, makeBold)
{
    if (part = "")
        return
    VarSetCapacity(charFormat, 92, 0)
    NumPut(92, charFormat, 0, "UInt")
    NumPut(0x1, charFormat, 4, "UInt")  ; CFM_BOLD
    NumPut(makeBold ? 0x1 : 0, charFormat, 8, "UInt")  ; CFE_BOLD
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x00B1, "Ptr", -1, "Ptr", -1)
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x0444, "Ptr", 1, "Ptr", &charFormat)
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x00C2, "Ptr", 1, "WStr", part)
}

; Emphasize only actionable editor paths and literal [Config Field] labels.
; RichEdit text is appended in segments; positions remain correct after CRLF
; normalization, unlike post-insertion offsets. Do not bold ordinary words.
LLARS_InstructionsAppendKeyDetails(textHwnd, line, emphasizeStart := false)
{
    pos := 1
    ; Start is emphasized only in the final numbered action, not in other prose.
    pattern := "i)(Setup[ \t]*>[ \t]*(?:Colors|Coordinates|Hotkeys|Timer)|\[[^\r\n\]]+\]" . (emphasizeStart ? "|(?<=Press )Start\b" : "") . ")"
    while (foundAt := RegExMatch(line, pattern, detail, pos))
    {
        LLARS_InstructionsAppendRich(textHwnd, SubStr(line, pos, foundAt - pos), false)
        LLARS_InstructionsAppendRich(textHwnd, detail, true)
        pos := foundAt + StrLen(detail)
    }
    LLARS_InstructionsAppendRich(textHwnd, SubStr(line, pos), false)
}

LLARS_InstructionsFormat(textHwnd, guideText)
{
    if (!textHwnd)
        return
    ; EM_REPLACESEL requires a writable control. Restore read-only afterwards.
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x00CF, "Ptr", 0, "Ptr", 0)
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x0435, "Ptr", 0, "Ptr", 500000)
    guideText := StrReplace(guideText, "`r`n", "`n")
    guideText := StrReplace(guideText, "`r", "`n")
    lines := StrSplit(guideText, "`n")
    lastStepIndex := 0
    for index, line in lines
        if (RegExMatch(line, "^\d+\."))
            lastStepIndex := index
    for index, line in lines
    {
        ; Bold STEP numbers plus literal [Setting] names and Setup > editor
        ; paths, never arbitrary uppercase acronyms or unmarked prose.
        if (RegExMatch(line, "^\d+\.", stepNumber))
        {
            LLARS_InstructionsAppendRich(textHwnd, stepNumber, true)
            LLARS_InstructionsAppendKeyDetails(textHwnd, SubStr(line, StrLen(stepNumber) + 1), index = lastStepIndex)
        }
        else
        {
            trimmed := Trim(line, " `t")
            isHeader := (trimmed = "BEFORE YOU START" || trimmed = "STEPS TO RUN" || trimmed = "OPTIONAL SETTINGS" || trimmed = "ADDITIONAL SCRIPT NOTES")
            ; Standalone ALL-CAPS warnings are intentional; mixed-case lines
            ; and individual acronyms never trigger emphasis.
            warning := RegExMatch(trimmed, "^(?:- )?[A-Z][A-Z0-9 /!?()'.,:&+\-]*$") && RegExMatch(trimmed, "[A-Z]{3,}.*[ A-Z]{4,}") && StrLen(trimmed) >= 16
            if (isHeader || warning)
                LLARS_InstructionsAppendRich(textHwnd, line, true)
            else
                LLARS_InstructionsAppendKeyDetails(textHwnd, line)
        }
        if (index < lines.Length())
            LLARS_InstructionsAppendRich(textHwnd, "`r`n", false)
    }
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x00CF, "Ptr", 1, "Ptr", 0)
    ; Clear selection and show the beginning, not the last appended line.
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x00B1, "Ptr", 0, "Ptr", 0)
    DllCall("SendMessageW", "Ptr", textHwnd, "UInt", 0x0115, "Ptr", 6, "Ptr", 0)
}

LLARS_InstructionsShow()
{
    global LLARS_RUNNING, LLARSInstructionsGuiHwnd, LLARSInstructionsBody
    ; Every dynamically assembled vControlName must have global scope in AHK v1.
    global LLARSInstructionsColorsButton, LLARSInstructionsCoordinatesButton
    global LLARSInstructionsHotkeysButton, LLARSInstructionsTimerButton, LLARSInstructionsCloseButton
    global LLARSInstructionsTextHwnd
    if (LLARS_RUNNING)
        return
    LLARS_MainSavePosition()
    guideText := LLARS_InstructionsText()
    scriptTitle := LLARS_DisplayScriptName()
    caps := LLARS_GetScriptCapabilities()
    Gui, Instructions:Destroy
    Gui, Instructions:+LastFound +OwnDialogs +AlwaysOnTop +Owner1 -ToolWindow +E0x40000 +HwndLLARSInstructionsGuiHwnd
    Gui, Instructions:Margin, 0, 0
    LLARS_VisualPrepare("Instructions")
    LLARS_VisualModalHeader("Instructions", 520, "Script Instructions")
    LLARS_VisualCard("Instructions", 14, 84, 492, 522)
    Gui, Instructions:Font, s12 Bold c20334E, Segoe UI
    Gui, Instructions:Add, Text, x27 y94 w466 h27 Center BackgroundTrans, %scriptTitle%
    Gui, Instructions:Font, s9 Norm c526783, Segoe UI
    Gui, Instructions:Add, Text, x32 y126 w456 h19 Center BackgroundTrans, Follow these steps before pressing Start
    Gui, Instructions:Font, s10 Norm c20334E, Segoe UI
    ; RichEdit supports truly bold step numbers and warnings. Load the
    ; Microsoft class explicitly; fallback to an ordinary read-only Edit.
    richModule := DllCall("GetModuleHandleW", "WStr", "Msftedit.dll", "Ptr")
    if (!richModule)
        richModule := DllCall("LoadLibraryW", "WStr", "Msftedit.dll", "Ptr")
    if (richModule)
    {
        Gui, Instructions:Add, Custom, ClassRICHEDIT50W x32 y153 w456 h307 +0x844 +VScroll vLLARSInstructionsBody hwndLLARSInstructionsTextHwnd
        LLARS_InstructionsFormat(LLARSInstructionsTextHwnd, guideText)
    }
    else
    {
        Gui, Instructions:Add, Edit, x32 y153 w456 h307 ReadOnly +VScroll -WantReturn vLLARSInstructionsBody hwndLLARSInstructionsTextHwnd, %guideText%
    }

    ; Every Instructions window exposes the same four configuration categories.
    ; Disabled categories stay visible (matching the Setup menu's capabilities).
    ; Alphabetical 2x2: Colors/Coordinates, Hotkeys/Timer; Close centered below.
    buttonW := 209
    Gui, Instructions:Font, s10 Bold c24324A, Segoe UI
    Gui, Instructions:Add, Button, x41 y473 w209 h34 gInstructionsOpenColors vLLARSInstructionsColorsButton, Colors
    Gui, Instructions:Add, Button, x270 y473 w209 h34 gInstructionsOpenCoordinates vLLARSInstructionsCoordinatesButton, Coordinates
    Gui, Instructions:Add, Button, x41 y515 w209 h34 gInstructionsOpenHotkeys vLLARSInstructionsHotkeysButton, Hotkeys
    Gui, Instructions:Add, Button, x270 y515 w209 h34 gInstructionsOpenTimer vLLARSInstructionsTimerButton, Timer
    Gui, Instructions:Add, Button, x156 y557 w208 h32 gCloseInstructions vLLARSInstructionsCloseButton, Close
    if (!caps.Colors)
        GuiControl, Instructions:Disable, LLARSInstructionsColorsButton
    if (!caps.Coordinates)
        GuiControl, Instructions:Disable, LLARSInstructionsCoordinatesButton
    ; LLARS-wide setup/pause/exit hotkeys remain configurable on all scripts.
    if (!caps.Timer)
        GuiControl, Instructions:Disable, LLARSInstructionsTimerButton
    Gui, Instructions:Show, Center w520 h620, Script Instructions
    LLARS_VisualFinish("Instructions")
    GuiControl, Instructions:Focus, LLARSInstructionsCloseButton
    ; RichEdit may auto-scroll to the caret after the window's first Show/paint.
    ; Reset selection, then scroll explicitly to line zero AFTER that first paint.
    if (LLARSInstructionsTextHwnd)
    {
        DllCall("SendMessageW", "Ptr", LLARSInstructionsTextHwnd, "UInt", 0x00B1, "Ptr", 0, "Ptr", 0)
        DllCall("SendMessageW", "Ptr", LLARSInstructionsTextHwnd, "UInt", 0x00B7, "Ptr", 0, "Ptr", 0) ; EM_SCROLLCARET
        DllCall("SendMessageW", "Ptr", LLARSInstructionsTextHwnd, "UInt", 0x0115, "Ptr", 6, "Ptr", 0) ; SB_TOP
    }
    LLARS_DeveloperUIAction("Instructions")
}

LLARS_InstructionsClose()
{
    global LLARSInstructionsGuiHwnd, LLARSMainGuiHwnd
    Gui, Instructions:Destroy
    LLARSInstructionsGuiHwnd := 0
    LLARS_DeveloperUIAction("Instructions", "Closed")
    if (LLARSMainGuiHwnd && WinExist("ahk_id " . LLARSMainGuiHwnd))
        WinActivate, % "ahk_id " . LLARSMainGuiHwnd
}
