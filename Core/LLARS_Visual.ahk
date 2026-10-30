LLARS_VisualConfigPath()
{
    global LLARS_CONFIG_FILE, LLARS_ROOT
    configPath := ""
    if (LLARS_CONFIG_FILE != "" && FileExist(LLARS_CONFIG_FILE))
        return LLARS_CONFIG_FILE
    if (LLARS_ROOT != "")
    {
        configPath := LLARS_ROOT . "\LLARS Config.ini"
        if FileExist(configPath)
            return configPath
    }
    configPath := A_ScriptDir . "\LLARS Config.ini"
    if FileExist(configPath)
        return configPath
    configPath := A_ScriptDir . "\..\LLARS Config.ini"
    if FileExist(configPath)
        return configPath
    return ""
}

LLARS_VisualHeaderVariantName()
{
    global LLARS_VisualHeaderVariantSelected
    if (LLARS_VisualHeaderVariantSelected != "")
        return LLARS_VisualHeaderVariantSelected

    ; A script launched from the Selector retains its selected session theme.
    EnvGet, inheritedHeaderTheme, LLARS_HEADER_THEME
    if (inheritedHeaderTheme = "ribbon" || inheritedHeaderTheme = "terrain"
        || inheritedHeaderTheme = "topographic" || inheritedHeaderTheme = "honeycomb"
        || inheritedHeaderTheme = "mosaic" || inheritedHeaderTheme = "spiral")
    {
        LLARS_VisualHeaderVariantSelected := inheritedHeaderTheme
        return LLARS_VisualHeaderVariantSelected
    }

    configPath := LLARS_VisualConfigPath()
    lastVariant := LLARS_ConfigReadFile(configPath, "GUI Header", "last_variant", "0")
    if lastVariant is not integer
        lastVariant := 0
    if (lastVariant < 0 || lastVariant > 6)
        lastVariant := 0
    nextVariant := Mod(lastVariant, 6) + 1
    if (nextVariant = 1)
        LLARS_VisualHeaderVariantSelected := "ribbon"
    else if (nextVariant = 2)
        LLARS_VisualHeaderVariantSelected := "terrain"
    else if (nextVariant = 3)
        LLARS_VisualHeaderVariantSelected := "topographic"
    else if (nextVariant = 4)
        LLARS_VisualHeaderVariantSelected := "honeycomb"
    else if (nextVariant = 5)
        LLARS_VisualHeaderVariantSelected := "mosaic"
    else
        LLARS_VisualHeaderVariantSelected := "spiral"
    if (configPath != "")
        LLARS_ConfigWriteFile(configPath, "GUI Header", "last_variant", nextVariant)
    return LLARS_VisualHeaderVariantSelected
}

LLARS_VisualHeaderAsset(kind, mode := "")
{
    variant := LLARS_VisualHeaderVariantName()
    if (kind = "banner")
    {
        themedName := "header_" . variant . ".png"
        assetFile := LLARS_VisualAsset(themedName)
        return (assetFile != "") ? assetFile : LLARS_VisualAsset("banner.png")
    }
    return LLARS_VisualAsset("dashboard_" . mode . ".png")
}

; LLARS visual system for AutoHotkey v1.1.
; Original LLARS visual surfaces and native Win32 controls; no external GUI libraries.
; Styling never alters script execution, keyboard hooks, or window positioning.

LLARS_VisualAsset(name)
{
    global LLARS_ROOT
    ; A distinct local name avoids legacy AHK v1 environment-variable fallback.
    assetFile := ""
    if (LLARS_ROOT != "")
    {
        assetFile := LLARS_ROOT . "\Assets\UI\" . name
        if (FileExist(assetFile))
            return assetFile
    }
    assetFile := A_ScriptDir . "\Assets\UI\" . name
    if (FileExist(assetFile))
        return assetFile
    assetFile := A_ScriptDir . "\..\Assets\UI\" . name
    if (FileExist(assetFile))
        return assetFile
    return ""
}

LLARS_VisualDashboard(guiName, mode := "setup")
{
    ; Runtime-composed dashboard: one rotating header asset plus one shared body asset.
    ; This avoids storing repeated full-window themed composites while preserving the same UI.
    dashboardAssetPath := LLARS_VisualHeaderAsset("dashboard", mode)
    w := (mode = "setup") ? 432 : 417
    h := (mode = "setup") ? 633 : (mode = "running") ? 499 : (mode = "timer") ? 422 : 336
    headerH := 105
    bodyH := h - headerH
    if (dashboardAssetPath = "")
    {
        LLARS_VisualBanner(guiName, w, headerH)
        return false
    }
    LLARS_VisualBanner(guiName, w, headerH)
    Gui, %guiName%:Add, Picture, % "x0 y" . headerH . " w" . w . " h" . bodyH, %dashboardAssetPath%
    return true
}

LLARS_VisualPrepare(guiName := "1", textSize := 10)
{
    global LLARS_VisualButtons, LLARS_VisualHookInstalled, LLARS_VisualHoverHwnd
    if (!IsObject(LLARS_VisualButtons))
        LLARS_VisualButtons := {}
    if (!LLARS_VisualHookInstalled)
    {
        OnMessage(0x2B, "LLARS_VisualDrawButton") ; WM_DRAWITEM
        OnMessage(0x200, "LLARS_VisualMouseMove") ; WM_MOUSEMOVE
        OnMessage(0x2A3, "LLARS_VisualMouseLeave") ; WM_MOUSELEAVE
        LLARS_VisualHookInstalled := true
    }
    Gui, %guiName%:Color, F3F6FB, FFFFFF
    Gui, %guiName%:Font, % "s" . textSize . " Norm c24324A", Segoe UI
}

; Shared modal geometry. All measurements are in AHK GUI logical pixels.
; Render decorations first; add native focusable controls afterwards.
LLARS_VisualStackLayout(rows, width := 300)
{
    if (rows < 1)
        rows := 1
    bodyY := 88
    buttonTop := bodyY + 20
    buttonHeight := 36
    buttonStep := 46
    lastBottom := buttonTop + (rows-1)*buttonStep + buttonHeight
    bodyH := lastBottom + 20 - bodyY
    footerCardY := bodyY + bodyH + 14
    return {width:width, rows:rows, cardX:14, cardW:width-28, buttonX:36
        , buttonW:width-72, buttonY:buttonTop, buttonH:buttonHeight
        , step:buttonStep, bodyY:bodyY, bodyH:bodyH
        , footerCardY:footerCardY, footerButtonY:footerCardY+15
        , height:footerCardY+80}
}

; Small read-only confirmation for successful config edits and resets.
; One native LLARS-styled GUI replaces the former stacked green/white overlays.
; Saving, capture timing, window focus and callers' return paths are unchanged.
LLARS_VisualConfigNotice(title, detail, context := "", duration := 1500)
{
    ; AHK v1 GUI v-variables created in functions must be global or static.
    global LLARSNoticeMeasure
    width := 444
    innerWidth := width - 24
    textWidth := width - 84

    ; Measure wrapped detail with the real Segoe UI font before making the card.
    ; This prevents long color-match lists or section names from clipping.
    Gui, 19:Destroy
    Gui, 19:+ToolWindow -Caption
    Gui, 19:Margin, 0, 0
    Gui, 19:Font, s13 Bold c173A61, Segoe UI
    Gui, 19:Add, Text, % "x0 y0 w" . textWidth . " vLLARSNoticeMeasure Center", %detail%
    Gui, 19:Show, Hide AutoSize, LLARSNoticeMeasure
    GuiControlGet, textPos, 19:Pos, LLARSNoticeMeasure
    Gui, 19:Destroy
    textHeight := textPosH
    if (textHeight < 27)
        textHeight := 27

    detailY := 104
    contextY := detailY + textHeight + 10
    contentBottom := (context != "") ? (contextY + 23) : (detailY + textHeight)
    height := contentBottom + 19
    cardHeight := height - 62

    Gui, 13u:Destroy
    Gui, 13:Destroy
    Gui, 13:+LastFound +AlwaysOnTop +ToolWindow -Caption +Disabled
    Gui, 13:Margin, 0, 0
    LLARS_VisualPrepare("13")
    LLARS_VisualBanner("13", width, 44)
    LLARS_VisualCard("13", 12, 52, innerWidth, cardHeight)
    Gui, 13:Font, s10 Bold cFFFFFF, Segoe UI
    Gui, 13:Add, Text, % "x14 y9 w" . (width-28) . " h25 Center BackgroundTrans", LLARS  |  SETTINGS SAVED
    Gui, 13:Font, s11 Bold c173A61, Segoe UI
    Gui, 13:Add, Text, % "x25 y64 w" . (width-50) . " h25 Center BackgroundTrans", %title%
    LLARS_VisualDivider("13", 30, 94, width - 60)
    Gui, 13:Font, s13 Bold c173A61, Segoe UI
    Gui, 13:Add, Text, % "x42 y" . detailY . " w" . textWidth . " h" . textHeight . " Center BackgroundTrans", %detail%
    if (context != "")
    {
        Gui, 13:Font, s10 Bold c526783, Segoe UI
        Gui, 13:Add, Text, % "x30 y" . contextY . " w" . (width-60) . " h23 Center BackgroundTrans", %context%
    }
    Gui, 13:Show, % "NoActivate xCenter y24 w" . width . " h" . height, LLARS Settings Confirmation
    Sleep, %duration%
    Gui, 13:Destroy
}

LLARS_VisualCapturePrompt(guiName, title, detail, width := 540)
{
    global LLARSCapturePromptDetail, LLARSCapturePromptMeasure
    textWidth := width - 56

    Gui, 18:Destroy
    Gui, 18:+ToolWindow -Caption
    Gui, 18:Margin, 0, 0
    Gui, 18:Font, s11 Bold c173A61, Segoe UI
    Gui, 18:Add, Text, % "x0 y0 w" . textWidth . " vLLARSCapturePromptMeasure Center", %detail%
    Gui, 18:Show, Hide AutoSize, LLARSCapturePromptMeasure
    GuiControlGet, capturePos, 18:Pos, LLARSCapturePromptMeasure
    Gui, 18:Destroy
    textHeight := capturePosH
    if (textHeight < 24)
        textHeight := 24

    headerHeight := 64
    cardY := 74
    cardX := 10
    cardW := width - 20
    cardH := textHeight + 26
    textY := cardY + Floor((cardH - textHeight) / 2)
    height := cardY + cardH + 10

    Gui, %guiName%:Destroy
    Gui, %guiName%:+LastFound +AlwaysOnTop +ToolWindow -Caption +Disabled
    Gui, %guiName%:Margin, 0, 0
    LLARS_VisualPrepare(guiName)
    LLARS_VisualBanner(guiName, width, headerHeight)
    Gui, %guiName%:Font, s14 Bold cFFFFFF, Segoe UI
    Gui, %guiName%:Add, Text, % "x12 y8 w" . (width-24) . " h24 Center BackgroundTrans", LLARS
    Gui, %guiName%:Font, s10 Bold cDCE7F4, Segoe UI
    Gui, %guiName%:Add, Text, % "x12 y34 w" . (width-24) . " h18 Center BackgroundTrans", %title%
    LLARS_VisualCard(guiName, cardX, cardY, cardW, cardH)
    Gui, %guiName%:Font, s11 Bold c173A61, Segoe UI
    Gui, %guiName%:Add, Text, % "x28 y" . textY . " w" . textWidth . " h" . textHeight . " Center +0x200 BackgroundTrans vLLARSCapturePromptDetail", %detail%
    Gui, %guiName%:Show, % "NoActivate xCenter y0 w" . width . " h" . height, LLARS Capture Prompt
}

LLARS_VisualCapturePromptUpdate(guiName, detail)
{
    GuiControl, %guiName%:, LLARSCapturePromptDetail, %detail%
}

LLARS_VisualModalHeader(guiName, width, title)
{
    LLARS_VisualBanner(guiName, width, 73)
    Gui, %guiName%:Font, s14 Bold cFFFFFF, Segoe UI
    Gui, %guiName%:Add, Text, % "x12 y9 w" . (width-24) . " h27 Center BackgroundTrans", LLARS
    Gui, %guiName%:Font, s10 Bold cDCE7F4, Segoe UI
    Gui, %guiName%:Add, Text, % "x12 y38 w" . (width-24) . " h21 Center BackgroundTrans", %title%
    Gui, %guiName%:Font, s10 Bold c24324A, Segoe UI
}

LLARS_VisualModalCards(guiName, layout)
{
    LLARS_VisualCard(guiName, layout.cardX, layout.bodyY, layout.cardW, layout.bodyH)
    LLARS_VisualCard(guiName, layout.cardX, layout.footerCardY, layout.cardW, 68)
}

; Solid-color native surfaces avoid the disabled/themed progress-bar treatment.
; Decorations are created before content, so controls retain their hit targets.
LLARS_VisualCard(guiName, x, y, width, height, kind := "white")
{
    if (width < 4 || height < 4)
        return
    asset := "panel.png"
    exact := "panel_" . width . "x" . height . ".png"
    panelAssetPath := LLARS_VisualAsset(exact)
    if (panelAssetPath = "")
        panelAssetPath := LLARS_VisualAsset(asset)
    if (panelAssetPath != "")
        Gui, %guiName%:Add, Picture, % "x" . x . " y" . y . " w" . width . " h" . height, %panelAssetPath%
}

LLARS_VisualDivider(guiName, x, y, width)
{
    Gui, %guiName%:Add, Text, % "x" . x . " y" . y . " w" . width . " h1 Disabled BackgroundE6ECF3"
}

LLARS_VisualAccent(guiName, width)
{
    ; The accent is already built into the shared banner/surface artwork.
    return
}

LLARS_VisualBanner(guiName, width, height)
{
    bannerAssetPath := LLARS_VisualHeaderAsset("banner")
    if (bannerAssetPath != "" && FileExist(bannerAssetPath))
        Gui, %guiName%:Add, Picture, % "x0 y0 w" . width . " h" . height, %bannerAssetPath%
}

; Finish the first GUI paint before synchronous input initialization. This does
; not introduce a timer or claim input readiness; it only flushes native painting.
; A hidden dashboard can miss an owner-draw button or transparent text paint
; when setup/capture windows are destroyed. Restore the existing GUI rather
; than rebuilding it: preserve every control handle, label, and current value.
LLARS_VisualRestoreMain()
{
    global LLARSMainGuiHwnd
    hwnd := LLARSMainGuiHwnd
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd))
        return false
    Gui, 1:Show
    ; Reconcile owner-draw controls, then synchronously redraw all children.
    ; The same full paint is used after the original dashboard creation.
    LLARS_VisualStyleControls(hwnd)
    return LLARS_VisualPaintReady(hwnd)
}

LLARS_VisualPaintReady(hwnd)
{
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd))
        return false
    ; RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN | RDW_UPDATENOW.
    DllCall("user32\RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x185)
    Sleep, -1
    return true
}

LLARS_VisualFinish(guiName)
{
    Gui, %guiName%:+LastFound
    hwnd := WinExist()
    if (hwnd)
        LLARS_VisualWindow(hwnd)
}

LLARS_VisualWindow(hwnd)
{
    if (!hwnd)
        return
    caption := 0x00FBF6F3
    ink := 0x004A3224
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 35, "UInt*", caption, "UInt", 4, "Int")
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 36, "UInt*", ink, "UInt", 4, "Int")
    corner := 2
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 33, "UInt*", corner, "UInt", 4, "Int")
    LLARS_VisualStyleControls(hwnd)
}

; Turn ordinary push buttons into original LLARS-drawn rounded controls.
; Keep the real HWND/button class, accelerator, g-label, tab order, and clicks.
; Skip radio buttons, checkboxes, group boxes, and graphical/icon buttons.
LLARS_VisualStyleControls(hwnd)
{
    global LLARS_VisualButtons
    WinGet, controls, ControlListHwnd, ahk_id %hwnd%
    Loop, Parse, controls, `n, `r
    {
        control := A_LoopField
        if (!control)
            continue
        VarSetCapacity(className, 96, 0)
        DllCall("user32\GetClassNameW", "Ptr", control, "Ptr", &className, "Int", 48)
        class := StrGet(&className, "UTF-16")
        if (class = "Button")
        {
            style := DllCall("user32\GetWindowLong" . (A_PtrSize = 8 ? "PtrW" : "W"), "Ptr", control, "Int", -16, "Ptr")
            buttonType := style & 0xF
            if ((buttonType != 0 && buttonType != 0xB) || (style & 0xC0))
                continue
            WinGetTitle, caption, ahk_id %control%
            if (caption = "")
                continue
            LLARS_VisualButtons[control] := LLARS_VisualButtonRole(caption)
            if (buttonType != 0xB)
            {
                newStyle := (style & ~0xF) | 0xB ; BS_OWNERDRAW
                DllCall("user32\SetWindowLong" . (A_PtrSize = 8 ? "PtrW" : "W"), "Ptr", control, "Int", -16, "Ptr", newStyle, "Ptr")
            }
            DllCall("user32\InvalidateRect", "Ptr", control, "Ptr", 0, "Int", 1)
        }
        else if (class = "SysListView32" || class = "SysTreeView32" || class = "Edit" || class = "ComboBox" || class = "ListBox")
            DllCall("uxtheme\SetWindowTheme", "Ptr", control, "WStr", "Explorer", "Ptr", 0)
    }
}

LLARS_VisualButtonRole(caption)
{
    if (RegExMatch(caption, "i)^(Start|Run|Select Script|Open Guided Builder|Save( Changes)?|Create|Confirm|OK|Apply|Next|Finish|Continue|Add Step|Generate|Open Project)$"))
        return "primary"
    if (RegExMatch(caption, "i)^(Exit LLARS|Close Selector|Close Setup|Close Config Settings|Close Coordinates|Close Colors|Close Hotkeys|Close Input Settings|Close Information|Close Error|Close|Cancel|Delete|Remove|Stop)$"))
        return "danger"
    return "secondary"
}

; Native owner-drawn buttons retain Windows mouse and click routing.
; Hover tracking changes paint state only; it never intercepts user input.
LLARS_VisualMouseMove(wParam, lParam, msg, hwnd)
{
    global LLARS_VisualButtons, LLARS_VisualHoverHwnd
    if (!IsObject(LLARS_VisualButtons))
        return
    if (!LLARS_VisualButtons.HasKey(hwnd))
    {
        MouseGetPos, , , , childHwnd, 2
        if (!LLARS_VisualButtons.HasKey(childHwnd))
            return
        hwnd := childHwnd
    }
    if (!DllCall("user32\IsWindowEnabled", "Ptr", hwnd))
        return
    if (LLARS_VisualHoverHwnd = hwnd)
        return
    prior := LLARS_VisualHoverHwnd
    LLARS_VisualHoverHwnd := hwnd
    if (prior && DllCall("user32\IsWindow", "Ptr", prior))
        DllCall("user32\InvalidateRect", "Ptr", prior, "Ptr", 0, "Int", 0)
    DllCall("user32\InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", 0)
    size := (A_PtrSize = 8 ? 24 : 16)
    VarSetCapacity(tme, size, 0)
    NumPut(size, tme, 0, "UInt")
    NumPut(0x2, tme, 4, "UInt")
    NumPut(hwnd, tme, 8, "Ptr")
    DllCall("user32\TrackMouseEvent", "Ptr", &tme)
}

LLARS_VisualMouseLeave(wParam, lParam, msg, hwnd)
{
    global LLARS_VisualHoverHwnd
    if (LLARS_VisualHoverHwnd != hwnd)
        return
    LLARS_VisualHoverHwnd := 0
    DllCall("user32\InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", 0)
}

; Native owner-drawn buttons retain Windows mouse and click routing.
; Hover tracking changes paint state only; it never intercepts user input.




; WM_DRAWITEM is scoped to only the button HWNDs registered above.
LLARS_VisualDrawButton(wParam, lParam, msg, parentHwnd)
{
    global LLARS_VisualButtons, LLARS_VisualHoverHwnd
    if (!IsObject(LLARS_VisualButtons) || !lParam)
        return
    if (NumGet(lParam + 0, 0, "UInt") != 4) ; ODT_BUTTON
        return
    ptrOffset := (A_PtrSize = 8 ? 24 : 20)
    control := NumGet(lParam + 0, ptrOffset, "Ptr")
    if (!LLARS_VisualButtons.HasKey(control))
        return

    state := NumGet(lParam + 0, 16, "UInt")
    hdc := NumGet(lParam + 0, ptrOffset + A_PtrSize, "Ptr")
    rect := lParam + ptrOffset + 2 * A_PtrSize
    left := NumGet(rect + 0, 0, "Int")
    top := NumGet(rect + 0, 4, "Int")
    right := NumGet(rect + 0, 8, "Int")
    bottom := NumGet(rect + 0, 12, "Int")
    role := LLARS_VisualButtons[control]
    selected := (state & 0x1) != 0
    hovered := (LLARS_VisualHoverHwnd = control)
    disabled := (state & 0x4) != 0
    focused := (state & 0x10) != 0

    ; These RGB values are original LLARS theme tokens.
    ; GDI COLORREF is BGR, not HTML RGB. Use one intentional palette.
    if (role = "primary")
    {
        fill := selected ? 0xD84E1D : (hovered ? 0xEB6325 : 0xE87636) ; blue
        border := focused ? 0xA4471A : (hovered ? 0xC55A23 : 0xB65420)
        ink := 0xFFFFFF
    }
    else if (role = "danger")
    {
        fill := selected ? 0xE5E5FF : (hovered ? 0xF1F1FF : 0xFFFFFF) ; pale red
        border := (focused || hovered) ? 0x2626DC : 0x4444EF ; only bright red
        ink := 0x4444EF
    }
    else
    {
        fill := selected ? 0xF6EEE4 : (hovered ? 0xFFF7EF : 0xFFFFFF)
        border := focused ? 0xD69448 : (hovered ? 0xDDB494 : 0xE6D9CE)
        ink := 0x4A3224
    }
    if (disabled)
    {
        fill := 0xF1F1F1
        border := 0xDEDEDE
        ink := 0xA0A0A0
    }
    brush := DllCall("gdi32\CreateSolidBrush", "UInt", fill, "Ptr")
    pen := DllCall("gdi32\CreatePen", "Int", 0, "Int", (focused || hovered) ? 3 : 2, "UInt", border, "Ptr")
    oldBrush := DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", brush, "Ptr")
    oldPen := DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", pen, "Ptr")
    DllCall("gdi32\RoundRect", "Ptr", hdc, "Int", left+1, "Int", top+1, "Int", right-1, "Int", bottom-1, "Int", 12, "Int", 12)
    DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", oldPen, "Ptr")
    DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", oldBrush, "Ptr")
    DllCall("gdi32\DeleteObject", "Ptr", pen)
    DllCall("gdi32\DeleteObject", "Ptr", brush)

    WinGetTitle, caption, ahk_id %control%
    if (caption != "")
    {
        DllCall("gdi32\SetBkMode", "Ptr", hdc, "Int", 1)
        DllCall("gdi32\SetTextColor", "Ptr", hdc, "UInt", ink)
        ; Preserve each native button's face and size, but render every caption bold.
        ; The temporary GDI font is released after drawing; no per-window font leak.
        controlFont := DllCall("user32\SendMessageW", "Ptr", control, "UInt", 0x31, "Ptr", 0, "Ptr", 0, "Ptr")
        if (!controlFont)
            controlFont := DllCall("gdi32\GetStockObject", "Int", 17, "Ptr") ; DEFAULT_GUI_FONT
        boldFont := 0
        if (controlFont)
        {
            VarSetCapacity(logFont, 92, 0) ; LOGFONTW, including its 32 WCHAR face.
            if (DllCall("gdi32\GetObjectW", "Ptr", controlFont, "Int", 92, "Ptr", &logFont, "Int") = 92)
            {
                NumPut(700, logFont, 16, "Int") ; FW_BOLD; keep face, size, charset.
                boldFont := DllCall("gdi32\CreateFontIndirectW", "Ptr", &logFont, "Ptr")
            }
        }
        drawFont := boldFont ? boldFont : controlFont
        oldFont := drawFont ? DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", drawFont, "Ptr") : 0
        VarSetCapacity(textRect, 16, 0)
        NumPut(left+5, textRect, 0, "Int")
        NumPut(top+(selected ? 1 : 0), textRect, 4, "Int")
        NumPut(right-5, textRect, 8, "Int")
        NumPut(bottom+(selected ? 1 : 0), textRect, 12, "Int")
        ; Center, vertically center, single line, ellipsize at narrow widths.
        textFlags := InStr(caption, "`n") ? 0x8011 : 0x8025
        DllCall("user32\DrawTextW", "Ptr", hdc, "WStr", caption, "Int", -1, "Ptr", &textRect, "UInt", textFlags)
        if (oldFont)
            DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", oldFont, "Ptr")
        if (boldFont)
            DllCall("gdi32\DeleteObject", "Ptr", boldFont)
    }
    return 1
}

; Runtime status remains in the activity sections; the header no longer duplicates it.
LLARS_VisualSetHeaderStatus(status)
{
    return
}

; Keep one selected state pair visible. All status controls remain addressable by scripts.
LLARS_VisualShowStatus(mode := "red")
{
    global LLARS_CONFIG_READY, LLARS_PAUSED
    for _, group in ["ScriptGreen|State1", "ScriptBlue|State3", "ScriptRed|State2"]
    {
        current := (InStr(group, "Green") ? "green" : InStr(group, "Blue") ? "blue" : "red")
        action := current = mode ? "Show" : "Hide"
        Loop, Parse, group, |
        {
            target := A_LoopField
            controlHwnd := 0
            GuiControlGet, controlHwnd, 1:Hwnd, %target%
            if (controlHwnd)
                GuiControl, 1:%action%, %target%
        }
    }
}

LLARS_VisualMainIcon(hwnd, root)
{
    path := root . "\Assets\Logo\LLARS\LLARS Logo.ico"
    if (!FileExist(path))
        return
    hIcon := DllCall("user32\LoadImageW", "Ptr", 0, "WStr", path
        , "UInt", 1, "Int", 0, "Int", 0, "UInt", 0x10, "Ptr")
    if (hIcon)
    {
        DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", 0x80, "Ptr", 0, "Ptr", hIcon)
        DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", 0x80, "Ptr", 1, "Ptr", hIcon)
    }
}
