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

LLARS_VisualHeaderFolder()
{
    global LLARS_ROOT
    for _, root in [LLARS_ROOT, A_ScriptDir, A_ScriptDir . "\.."]
    {
        if (root != "" && FileExist(root . "\Assets\UI\banner.png"))
            return root . "\Assets\UI"
    }
    return ""
}

; The catalog is discovered once per process and shared by rotation and preview.
; Bundled themes are pinned first; user-added header_*.png files follow.
LLARS_VisualHeaderCatalog()
{
    global LLARS_VisualHeaderCatalogCache, LLARS_VisualHeaderCatalogIssues
    if IsObject(LLARS_VisualHeaderCatalogCache)
        return LLARS_VisualHeaderCatalogCache
    items := []
    seen := {}
    LLARS_VisualHeaderCatalogIssues := ""
    uiDir := LLARS_VisualHeaderFolder()
    for _, id in ["ribbon", "terrain", "topographic", "honeycomb", "mosaic", "spiral"
        , "digital_wave", "polygon_grid", "nebula_cloud", "shadow_botanica"
        , "wild_horses", "owl", "lotus", "mushrooms", "forest_naturescape"]
    {
        path := LLARS_VisualAsset("header_" . id . ".png")
        reason := ""
        if LLARS_VisualHeaderValidateAsset(path, reason, w, h)
        {
            displayName := StrReplace(id, "_", " ")
            if InStr(id, "_")
                StringUpper, displayName, displayName, T
            items.Push({Id:id, Name:displayName, Path:path, Width:w, Height:h, Shipped:true})
            seen[id] := true
        }
        else
            LLARS_VisualHeaderCatalogIssues .= "Bundled header " . id . ": " . reason . "`n"
    }
    if (uiDir != "")
    {
        files := ""
        pattern := uiDir . "\header_*.png"
        Loop, Files, %pattern%, F
            files .= A_LoopFileName . "`n"
        Sort, files
        counts := {}
        Loop, Parse, files, `n, `r
        {
            if RegExMatch(A_LoopField, "i)^header_([a-z0-9][a-z0-9_-]{0,63})\.png$", candidate)
            {
                candidateId := candidate1
                StringLower, candidateId, candidateId
                counts[candidateId] := counts.HasKey(candidateId) ? counts[candidateId]+1 : 1
            }
        }
        Loop, Parse, files, `n, `r
        {
            fileName := A_LoopField
            if (fileName = "")
                continue
            if !RegExMatch(fileName, "i)^header_([a-z0-9][a-z0-9_-]{0,63})\.png$", match)
            {
                LLARS_VisualHeaderCatalogIssues .= "Skipped invalid header filename: " . fileName . "`n"
                continue
            }
            id := match1
            StringLower, id, id
            if (counts[id] > 1 && !seen.HasKey(id))
            {
                LLARS_VisualHeaderCatalogIssues .= "Skipped ambiguous case-colliding header: " . fileName . "`n"
                continue
            }
            if seen.HasKey(id)
            {
                ; Bundled header names are already registered; case-only duplicates
                ; and collisions cannot shadow a previously accepted entry.
                continue
            }
            path := uiDir . "\" . fileName
            attrs := DllCall("GetFileAttributesW", "WStr", path, "UInt")
            if (attrs = 0xFFFFFFFF || (attrs & 0x400) || (attrs & 0x10))
            {
                LLARS_VisualHeaderCatalogIssues .= "Skipped unsafe header file: " . fileName . "`n"
                continue
            }
            reason := ""
            if !LLARS_VisualHeaderValidateAsset(path, reason, w, h)
            {
                LLARS_VisualHeaderCatalogIssues .= "Skipped " . fileName . ": " . reason . "`n"
                continue
            }
            items.Push({Id:id, Name:StrReplace(SubStr(fileName, 8, StrLen(fileName)-11), "_", " ")
                , Path:path, Width:w, Height:h, Shipped:false})
            seen[id] := true
        }
    }
    LLARS_VisualHeaderCatalogCache := items
    return items
}

LLARS_VisualHeaderValidateAsset(path, ByRef reason, ByRef width := 0, ByRef height := 0)
{
    reason := ""
    width := 0
    height := 0
    if (path = "" || !FileExist(path))
    {
        reason := "file is missing"
        return false
    }
    FileGetSize, bytes, %path%
    if (ErrorLevel || bytes < 48 || bytes > 20000000)
    {
        reason := "file size is outside supported limits"
        return false
    }
    file := FileOpen(path, "r")
    if !IsObject(file)
    {
        reason := "cannot read the image"
        return false
    }
    VarSetCapacity(signature, 8, 0)
    count := file.RawRead(signature, 8)
    file.Close()
    if (count != 8 || NumGet(signature, 0, "UInt") != 0x474E5089
        || NumGet(signature, 4, "UInt") != 0x0A1A0A0D)
    {
        reason := "file is not a PNG"
        return false
    }
    ; LoadPicture checks the actual decoded bitmap, not only the .png suffix.
    handle := LoadPicture(path, "", bitmapType)
    if (!handle || bitmapType != 0)
    {
        if (handle)
            DllCall("DeleteObject", "Ptr", handle)
        reason := "not a decodable PNG bitmap"
        return false
    }
    bitmapSize := (A_PtrSize = 8) ? 32 : 24
    VarSetCapacity(bitmap, bitmapSize, 0)
    result := DllCall("GetObjectW", "Ptr", handle, "Int", bitmapSize, "Ptr", &bitmap, "Int")
    if (result)
    {
        width := NumGet(bitmap, 4, "Int")
        height := NumGet(bitmap, 8, "Int")
    }
    DllCall("DeleteObject", "Ptr", handle)
    if (!result || width < 400 || width > 4096 || height < 60 || height > 1024
        || width < height*4 || width > height*12 || width*height > 6000000)
    {
        reason := "header dimensions or aspect ratio are unsupported"
        return false
    }
    return true
}

LLARS_VisualHeaderIndex(items, id)
{
    if (id = "")
        return 0
    StringLower, id, id
    for index, item in items
    {
        if (item.Id = id)
            return index
    }
    return 0
}

LLARS_VisualHeaderVariantName()
{
    global LLARS_VisualHeaderVariantSelected, LLARS_VisualHeaderLastIssue
    if (LLARS_VisualHeaderVariantSelected != "")
        return LLARS_VisualHeaderVariantSelected
    items := LLARS_VisualHeaderCatalog()
    total := items.Length()
    if (!total)
        return ""

    ; Selector -> child sessions use the same valid discovered theme. An
    ; inherited theme must never advance the next-launch rotation cursor.
    EnvGet, inheritedHeaderTheme, LLARS_HEADER_THEME
    index := LLARS_VisualHeaderIndex(items, inheritedHeaderTheme)
    if (index)
    {
        LLARS_VisualHeaderVariantSelected := items[index].Id
        return LLARS_VisualHeaderVariantSelected
    }

    configPath := LLARS_VisualConfigPath()
    mode := LLARS_ConfigReadFile(configPath, "GUI Header", "mode", "sequential")
    StringLower, mode, mode
    lastVariant := LLARS_ConfigReadFile(configPath, "GUI Header", "last_variant", "0")
    if !RegExMatch(lastVariant, "^\d+$")
        lastVariant := 0
    if (lastVariant > total)
        lastVariant := 0
    lastName := LLARS_ConfigReadFile(configPath, "GUI Header", "last_name", "")
    previous := LLARS_VisualHeaderIndex(items, lastName)
    if (!previous)
        previous := lastVariant

    if (mode = "fixed")
    {
        fixedName := LLARS_ConfigReadFile(configPath, "GUI Header", "fixed_theme", "")
        index := LLARS_VisualHeaderIndex(items, fixedName)
        if (!index)
        {
            LLARS_VisualHeaderLastIssue := "Fixed header is unavailable; showing the first valid header."
            index := 1
        }
    }
    else if (mode = "random" && total > 1)
    {
        if (previous >= 1 && previous <= total)
        {
            maxChoice := total - 1
            Random, index, 1, %maxChoice%
            if (index >= previous)
                index += 1
        }
        else
            Random, index, 1, %total%
    }
    else
        index := Mod(previous, total) + 1

    LLARS_VisualHeaderVariantSelected := items[index].Id
    if (mode != "fixed" && configPath != "")
    {
        LLARS_ConfigWriteFile(configPath, "GUI Header", "last_variant", index)
        LLARS_ConfigWriteFile(configPath, "GUI Header", "last_name", LLARS_VisualHeaderVariantSelected)
    }
    return LLARS_VisualHeaderVariantSelected
}

LLARS_VisualHeaderSavePreferences(mode, fixedTheme, ByRef error)
{
    global LLARS_VisualHeaderVariantSelected
    error := ""
    if (mode != "sequential" && mode != "random" && mode != "fixed")
    {
        error := "Unsupported header selection mode."
        return false
    }
    items := LLARS_VisualHeaderCatalog()
    if (mode = "fixed" && !LLARS_VisualHeaderIndex(items, fixedTheme))
    {
        error := "Select a valid fixed header before saving."
        return false
    }
    configPath := LLARS_VisualConfigPath()
    if (configPath = "")
    {
        error := "The shared LLARS Config.ini was not found."
        return false
    }
    previousMode := LLARS_ConfigReadFile(configPath, "GUI Header", "mode", "sequential")
    previousFixed := LLARS_ConfigReadFile(configPath, "GUI Header", "fixed_theme", "")
    ; Protect the existing INI from partial writes or failed read-back.
    ; Cancel never calls this function.
    rollback := configPath . ".headerprefs.rollback"
    FileCopy, %configPath%, %rollback%, 1
    if ErrorLevel
    {
        error := "Could not prepare a configuration rollback."
        return false
    }
    ok := LLARS_ConfigWriteFile(configPath, "GUI Header", "mode", mode)
    if (ok && mode = "fixed")
        ok := LLARS_ConfigWriteFile(configPath, "GUI Header", "fixed_theme", fixedTheme)
    ; A successful API call alone is not proof that the new setting persisted.
    if (ok)
    {
        savedMode := LLARS_ConfigReadFile(configPath, "GUI Header", "mode", "")
        savedFixed := LLARS_ConfigReadFile(configPath, "GUI Header", "fixed_theme", "")
        ok := (savedMode = mode && (mode != "fixed" || savedFixed = fixedTheme))
    }
    if (!ok)
    {
        FileCopy, %rollback%, %configPath%, 1
        restoreFailed := ErrorLevel
        LLARS_ConfigInvalidateSnapshot(configPath)
        if (restoreFailed)
            error := "Preference save failed. Restore the original from " . rollback
        else
        {
            error := "Could not save the header preference; original configuration was restored."
            FileDelete, %rollback%
        }
        return false
    }
    FileDelete, %rollback%
    ; A saved change applies when a new script is launched from Selector.
    ; The already-created GUI keeps its current image.
    if (previousMode != mode || (mode = "fixed" && previousFixed != fixedTheme))
        LLARS_VisualHeaderVariantSelected := ""
    return true
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
    h := (mode = "setup") ? 450 : (mode = "running") ? 472 : (mode = "timer") ? 395 : 309
    headerH := 96
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
    global LLARS_VisualButtons, LLARS_VisualButtonCaptions, LLARS_VisualHookInstalled, LLARS_VisualHoverHwnd, LLARS_VisualShowHookInstalled
    if (!IsObject(LLARS_VisualButtons))
        LLARS_VisualButtons := {}
    ; A button's HWND can outlive changes in GUI focus/default GUI. Store its
    ; native caption when styling; never depend on WinGetTitle inside WM_DRAWITEM.
    if (!IsObject(LLARS_VisualButtonCaptions))
        LLARS_VisualButtonCaptions := {}
    if (!LLARS_VisualHookInstalled)
    {
        OnMessage(0x2B, "LLARS_VisualDrawButton") ; WM_DRAWITEM
        OnMessage(0x200, "LLARS_VisualMouseMove") ; WM_MOUSEMOVE
        OnMessage(0x2A3, "LLARS_VisualMouseLeave") ; WM_MOUSELEAVE
        LLARS_VisualHookInstalled := true
    }
    if (!LLARS_VisualShowHookInstalled)
    {
        OnMessage(0x18, "LLARS_VisualOnShowWindow")
        LLARS_VisualShowHookInstalled := true
    }
    LLARS_VisualEnsureIcon()
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

; Compact stacked setup/config dialogs: the Close action is the final row
; inside one panel. Other dialogs continue to use the original two-card layout.
LLARS_VisualCompactStackLayout(rows, width := 300)
{
    if (rows < 1)
        rows := 1
    bodyY := 88
    buttonTop := bodyY + 20
    buttonHeight := 36
    buttonStep := 46
    lastBottom := buttonTop + (rows-1)*buttonStep + buttonHeight
    return {width:width, rows:rows, cardX:14, cardW:width-28, buttonX:36
        , buttonW:width-72, buttonY:buttonTop, buttonH:buttonHeight
        , step:buttonStep, bodyY:bodyY, bodyH:lastBottom+18-bodyY
        , footerButtonY:buttonTop+(rows-1)*buttonStep
        , height:lastBottom+32}
}

LLARS_VisualCompactStackCard(guiName, layout)
{
    LLARS_VisualCard(guiName, layout.cardX, layout.bodyY, layout.cardW, layout.bodyH)
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

LLARS_VisualColorNotice(sectionName, rgb, matches, context := "", duration := 1800)
{
    if (!RegExMatch(rgb, "i)^0x[0-9a-f]{6}$"))
    {
        LLARS_VisualConfigNotice("COLOR UPDATED", sectionName . " = " . rgb, context, duration)
        return
    }
    StringUpper, rgb, rgb
    width := 444
    sectionHeight := LLARS_VisualNoticeTextHeight(sectionName, 13, width - 84)
    matchesText := (matches = "") ? "Unique" : "Matches: " . matches
    matchesHeight := LLARS_VisualNoticeTextHeight(matchesText, 10, width - 70)
    sectionY := 104
    rgbY := sectionY + sectionHeight + 7
    matchesY := rgbY + 32
    contextY := matchesY + matchesHeight + 9
    height := contextY + (context != "" ? 23 : 0) + 19

    Gui, 13u:Destroy
    Gui, 13:Destroy
    Gui, 13:+LastFound +AlwaysOnTop +ToolWindow -Caption +Disabled
    Gui, 13:Margin, 0, 0
    LLARS_VisualPrepare("13")
    LLARS_VisualBanner("13", width, 44)
    LLARS_VisualCard("13", 12, 52, width - 24, height - 62)
    Gui, 13:Font, s10 Bold cFFFFFF, Segoe UI
    Gui, 13:Add, Text, % "x14 y9 w" . (width - 28) . " h25 Center BackgroundTrans", LLARS  |  SETTINGS SAVED
    Gui, 13:Font, s11 Bold c173A61, Segoe UI
    Gui, 13:Add, Text, % "x25 y64 w" . (width - 50) . " h25 Center BackgroundTrans", COLOR UPDATED
    LLARS_VisualDivider("13", 30, 94, width - 60)
    Gui, 13:Font, s13 Bold c173A61, Segoe UI
    Gui, 13:Add, Text, % "x42 y" . sectionY . " w" . (width - 84) . " h" . sectionHeight . " Center BackgroundTrans", %sectionName%
    Gui, 13:Add, Text, % "x147 y" . rgbY . " w124 h27 Center BackgroundTrans", %rgb%
    swatchColor := SubStr(rgb, 3)
    Gui, 13:Add, Progress, % "x276 y" . (rgbY + 1) . " w24 h24 +Border -Theme c" . swatchColor . " BackgroundE1E7EF Range0-100", 100
    Gui, 13:Font, s10 Bold c526783, Segoe UI
    Gui, 13:Add, Text, % "x35 y" . matchesY . " w" . (width - 70) . " h" . matchesHeight . " Center BackgroundTrans", %matchesText%
    if (context != "")
        Gui, 13:Add, Text, % "x30 y" . contextY . " w" . (width - 60) . " h23 Center BackgroundTrans", %context%
    Gui, 13:Show, % "NoActivate xCenter y24 w" . width . " h" . height, LLARS Settings Confirmation
    Sleep, %duration%
    Gui, 13:Destroy
}

LLARS_VisualNoticeTextHeight(text, size, width)
{
    global LLARSNoticeMeasure
    Gui, 19:Destroy
    Gui, 19:+ToolWindow -Caption
    Gui, 19:Margin, 0, 0
    Gui, 19:Font, % "s" . size . " Bold c173A61", Segoe UI
    Gui, 19:Add, Text, % "x0 y0 w" . width . " vLLARSNoticeMeasure Center", %text%
    Gui, 19:Show, Hide AutoSize, LLARSNoticeMeasure
    GuiControlGet, textPos, 19:Pos, LLARSNoticeMeasure
    Gui, 19:Destroy
    return (textPosH > 27) ? textPosH : 27
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
    LLARS_VisualMainIcon(hwnd)
    LLARS_VisualStyleControls(hwnd)
    ; Updating a control to BS_OWNERDRAW after creation only invalidates it.
    ; Force a full synchronous first paint so no caption, icon or control can
    ; be left blank until hover, focus or a later window activation.
    LLARS_VisualPaintReady(hwnd)
}

; Read child-button captions using the native HWND instead of window-title
; matching, which can return no text for a child during nested GUI/MsgBox paint.
LLARS_VisualControlCaption(hwnd)
{
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd))
        return ""
    length := DllCall("user32\GetWindowTextLengthW", "Ptr", hwnd, "Int")
    if (length <= 0 || length > 1024)
        return ""
    VarSetCapacity(buffer, (length + 1) * 2, 0)
    written := DllCall("user32\GetWindowTextW", "Ptr", hwnd, "Ptr", &buffer, "Int", length + 1, "Int")
    return written > 0 ? StrGet(&buffer, written, "UTF-16") : ""
}

; Turn ordinary push buttons into original LLARS-drawn rounded controls.
; Keep the real HWND/button class, accelerator, g-label, tab order, and clicks.
; Skip radio buttons, checkboxes, group boxes, and graphical/icon buttons.
; Drop captions and roles for controls whose Win32 handles were destroyed.
; A long-running LLARS session opens and closes many modal dialogs. The
; retained caption fallback must not accumulate dead entries indefinitely.
LLARS_VisualPruneButtonRegistry()
{
    global LLARS_VisualButtons, LLARS_VisualButtonCaptions, LLARS_VisualHoverHwnd
    if !IsObject(LLARS_VisualButtons)
        return
    stale := []
    for controlHwnd, role in LLARS_VisualButtons
    {
        if !DllCall("user32\IsWindow", "Ptr", controlHwnd)
            stale.Push(controlHwnd)
    }
    for _, controlHwnd in stale
    {
        LLARS_VisualButtons.Delete(controlHwnd)
        if (IsObject(LLARS_VisualButtonCaptions) && LLARS_VisualButtonCaptions.HasKey(controlHwnd))
            LLARS_VisualButtonCaptions.Delete(controlHwnd)
        if (LLARS_VisualHoverHwnd = controlHwnd)
            LLARS_VisualHoverHwnd := 0
    }
}

LLARS_VisualRegisterButton(hwnd, caption)
{
    global LLARS_VisualButtons, LLARS_VisualButtonCaptions
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd))
        return false
    VarSetCapacity(className, 64, 0)
    DllCall("user32\GetClassNameW", "Ptr", hwnd, "Ptr", &className, "Int", 32)
    if (StrGet(&className, "UTF-16") != "Button")
        return false
    style := DllCall("user32\GetWindowLong" . (A_PtrSize = 8 ? "PtrW" : "W"), "Ptr", hwnd, "Int", -16, "Ptr")
    buttonType := style & 0xF
    if (buttonType != 0xB)
    {
        if ((buttonType != 0 && buttonType != 1) || (style & 0xC0))
            return false
        newStyle := (style & ~0xF) | 0xB
        DllCall("user32\SetWindowLong" . (A_PtrSize = 8 ? "PtrW" : "W"), "Ptr", hwnd, "Int", -16, "Ptr", newStyle, "Ptr")
        style := DllCall("user32\GetWindowLong" . (A_PtrSize = 8 ? "PtrW" : "W"), "Ptr", hwnd, "Int", -16, "Ptr")
        if ((style & 0xF) != 0xB)
            return false
    }
    if (!IsObject(LLARS_VisualButtons))
        LLARS_VisualButtons := {}
    if (!IsObject(LLARS_VisualButtonCaptions))
        LLARS_VisualButtonCaptions := {}
    actualCaption := LLARS_VisualControlCaption(hwnd)
    if (actualCaption != "")
        caption := actualCaption
    LLARS_VisualButtonCaptions[hwnd] := caption
    LLARS_VisualButtons[hwnd] := LLARS_VisualButtonRole(caption)
    DllCall("user32\InvalidateRect", "Ptr", hwnd, "Ptr", 0, "Int", 1)
    return true
}

LLARS_VisualStyleControls(hwnd)
{
    global LLARS_VisualButtons, LLARS_VisualButtonCaptions
    LLARS_VisualPruneButtonRegistry()
    ; Pre-show control lookup must also discover buttons on hidden GUIs.
    wasDetectHidden := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGet, controls, ControlListHwnd, ahk_id %hwnd%
    DetectHiddenWindows, %wasDetectHidden%
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
            caption := LLARS_VisualControlCaption(control)
            if (caption = "")
                continue
            LLARS_VisualButtonCaptions[control] := caption
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

LLARS_VisualIsGuiWindow(hwnd)
{
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd))
        return false
    VarSetCapacity(className, 64, 0)
    DllCall("user32\GetClassNameW", "Ptr", hwnd, "Ptr", &className, "Int", 32)
    return StrGet(&className, "UTF-16") = "AutoHotkeyGUI"
}

LLARS_VisualOnShowWindow(isShowing, lParam, msg, hwnd)
{
    global LLARS_VisualButtons, LLARS_VisualPostShowPending
    if (!isShowing || !LLARS_VisualIsGuiWindow(hwnd))
        return
    ; Apply the process icon before the first visible GUI paint.
    LLARS_VisualMainIcon(hwnd)
    LLARS_VisualStyleControls(hwnd)
    if (!IsObject(LLARS_VisualButtons))
        return
    hasButtons := false
    for buttonHwnd, role in LLARS_VisualButtons
    {
        if (DllCall("user32\GetParent", "Ptr", buttonHwnd, "Ptr") = hwnd)
        {
            hasButtons := true
            break
        }
    }
    if (!hasButtons)
        return
    if (!IsObject(LLARS_VisualPostShowPending))
        LLARS_VisualPostShowPending := {}
    if (LLARS_VisualPostShowPending.HasKey(hwnd))
        return
    LLARS_VisualPostShowPending[hwnd] := true
    paintCallback := Func("LLARS_VisualPostShowPaint").Bind(hwnd)
    SetTimer, % paintCallback, -80
}

LLARS_VisualPostShowPaint(hwnd)
{
    global LLARS_VisualButtons, LLARS_VisualPostShowPending
    if (IsObject(LLARS_VisualPostShowPending))
        LLARS_VisualPostShowPending.Delete(hwnd)
    if (!LLARS_VisualIsGuiWindow(hwnd) || !DllCall("user32\IsWindowVisible", "Ptr", hwnd))
        return
    LLARS_VisualStyleControls(hwnd)
    for buttonHwnd, role in LLARS_VisualButtons
    {
        if (DllCall("user32\GetParent", "Ptr", buttonHwnd, "Ptr") = hwnd
            && DllCall("user32\IsWindowVisible", "Ptr", buttonHwnd))
            DllCall("user32\RedrawWindow", "Ptr", buttonHwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x105)
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
    global LLARS_VisualButtons, LLARS_VisualButtonCaptions, LLARS_VisualHoverHwnd
    if (!IsObject(LLARS_VisualButtons) || !lParam)
        return
    if (NumGet(lParam + 0, 0, "UInt") != 4) ; ODT_BUTTON
        return
    ptrOffset := (A_PtrSize = 8 ? 24 : 20)
    control := NumGet(lParam + 0, ptrOffset, "Ptr")
    if (!LLARS_VisualButtons.HasKey(control) || !DllCall("user32\IsWindow", "Ptr", control))
        return
    VarSetCapacity(buttonClass, 64, 0)
    DllCall("user32\GetClassNameW", "Ptr", control, "Ptr", &buttonClass, "Int", 32)
    if (StrGet(&buttonClass, "UTF-16") != "Button")
        return

    state := NumGet(lParam + 0, 16, "UInt")
    hdc := NumGet(lParam + 0, ptrOffset + A_PtrSize, "Ptr")
    if (!hdc)
        return
    rect := lParam + ptrOffset + 2 * A_PtrSize
    left := NumGet(rect + 0, 0, "Int")
    top := NumGet(rect + 0, 4, "Int")
    right := NumGet(rect + 0, 8, "Int")
    bottom := NumGet(rect + 0, 12, "Int")
    ; AHK controls can update their text (e.g. Add/Remove Favorite). Refresh
    ; a valid caption, but preserve the last known caption during a transient
    ; empty Win32 read so the button never paints as an unlabelled rectangle.
    caption := LLARS_VisualControlCaption(control)
    if (caption != "")
    {
        LLARS_VisualButtonCaptions[control] := caption
        LLARS_VisualButtons[control] := LLARS_VisualButtonRole(caption)
    }
    else if (IsObject(LLARS_VisualButtonCaptions) && LLARS_VisualButtonCaptions.HasKey(control))
        caption := LLARS_VisualButtonCaptions[control]
    role := LLARS_VisualButtons[control]
    selected := (state & 0x1) != 0
    hovered := (LLARS_VisualHoverHwnd = control)
    disabled := ((state & 0x4) != 0 || !DllCall("user32\IsWindowEnabled", "Ptr", control))
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
    if (disabled && caption = "Start")
    {
        ; Erase the entire former button outline, including stale focus edges.
        ; Disabled Start is muted text on the card, not an interactive border.
        backgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", 0xFFFFFF, "Ptr")
        DllCall("user32\FillRect", "Ptr", hdc, "Ptr", rect, "Ptr", backgroundBrush)
        DllCall("gdi32\DeleteObject", "Ptr", backgroundBrush)
    }
    else
    {
        brush := DllCall("gdi32\CreateSolidBrush", "UInt", fill, "Ptr")
        pen := DllCall("gdi32\CreatePen", "Int", 0, "Int", (focused || hovered) ? 3 : 2, "UInt", border, "Ptr")
        oldBrush := DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", brush, "Ptr")
        oldPen := DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", pen, "Ptr")
        DllCall("gdi32\RoundRect", "Ptr", hdc, "Int", left+1, "Int", top+1, "Int", right-1, "Int", bottom-1, "Int", 12, "Int", 12)
        DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", oldPen, "Ptr")
        DllCall("gdi32\SelectObject", "Ptr", hdc, "Ptr", oldBrush, "Ptr")
        DllCall("gdi32\DeleteObject", "Ptr", pen)
        DllCall("gdi32\DeleteObject", "Ptr", brush)
    }

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
LLARS_VisualSetStatusText(controlName, value)
{
    GuiControlGet, existing, 1:, %controlName%
    if (existing != value)
        GuiControl, 1:, %controlName%, %value%
}

LLARS_VisualShowStatus(mode := "red")
{
    global LLARS_CONFIG_READY, LLARS_PAUSED
    global LLARS_VisualCurrentStatusMode, LLARS_VisualCurrentStatusHwnd
    Gui, 1:+LastFoundExist
    currentHwnd := WinExist()
    if (currentHwnd && LLARS_VisualCurrentStatusHwnd = currentHwnd && LLARS_VisualCurrentStatusMode = mode)
        return
    LLARS_VisualCurrentStatusHwnd := currentHwnd
    LLARS_VisualCurrentStatusMode := mode
    for _, group in ["ScriptGreen|State1", "ScriptBlue|State3", "ScriptRed|State2"]
    {
        current := (InStr(group, "Green") ? "green" : InStr(group, "Blue") ? "blue" : "red")
        action := current = mode ? "Show" : "Hide"
        Loop, Parse, group, |
        {
            target := A_LoopField
            controlHwnd := 0
            try
            {
                GuiControlGet, controlHwnd, 1:Hwnd, %target%
                if (controlHwnd)
                    GuiControl, 1:%action%, %target%
            }
            catch error
            {
                if (error.Message != 1)
                    throw error
            }
        }
    }
}

LLARS_VisualIconPath(root := "")
{
    global LLARS_ROOT
    if (root != "" && FileExist(root . "\Assets\Logo\LLARS\LLARS Logo.ico"))
        return root . "\Assets\Logo\LLARS\LLARS Logo.ico"
    if (LLARS_ROOT != "" && FileExist(LLARS_ROOT . "\Assets\Logo\LLARS\LLARS Logo.ico"))
        return LLARS_ROOT . "\Assets\Logo\LLARS\LLARS Logo.ico"
    candidate := A_ScriptDir
    Loop, 9
    {
        path := candidate . "\Assets\Logo\LLARS\LLARS Logo.ico"
        if FileExist(path)
            return path
        SplitPath, candidate, , parent
        if (parent = "" || parent = candidate)
            break
        candidate := parent
    }
    return ""
}

LLARS_VisualEnsureIcon(root := "")
{
    global LLARS_VisualCurrentIconPath, LLARS_VisualIconTimerStarted, LLARS_VisualIconTimerCallback
    path := LLARS_VisualIconPath(root)
    if (path = "")
        return false
    if (LLARS_VisualCurrentIconPath != path || A_IconFile != path)
    {
        Menu, Tray, Icon, %path%,, 1
        LLARS_VisualCurrentIconPath := path
    }
    ; Cache the exact same icon for ordinary GUIs and native Windows dialogs.
    ; Message boxes can open before the first LLARS GUI is shown.
    LLARS_VisualLoadIconHandles(path)
    LLARS_VisualEnsureDialogIconHook()
    if (!LLARS_VisualIconTimerStarted)
    {
        LLARS_VisualIconTimerCallback := Func("LLARS_VisualSyncProcessIcons")
        SetTimer, % LLARS_VisualIconTimerCallback, 500
        LLARS_VisualIconTimerStarted := true
    }
    return true
}

LLARS_VisualLoadIconHandles(path)
{
    global LLARS_VisualIconSmall, LLARS_VisualIconLarge, LLARS_VisualIconHandlePath
    if (LLARS_VisualIconHandlePath = path && LLARS_VisualIconSmall && LLARS_VisualIconLarge)
        return
    LLARS_VisualIconSmall := DllCall("user32\LoadImageW", "Ptr", 0, "WStr", path
        , "UInt", 1, "Int", 16, "Int", 16, "UInt", 0x10, "Ptr")
    LLARS_VisualIconLarge := DllCall("user32\LoadImageW", "Ptr", 0, "WStr", path
        , "UInt", 1, "Int", 32, "Int", 32, "UInt", 0x10, "Ptr")
    LLARS_VisualIconHandlePath := path
}

LLARS_VisualApplyIconHandles(hwnd)
{
    global LLARS_VisualIconSmall, LLARS_VisualIconLarge
    if (LLARS_VisualIconSmall)
    {
        currentSmall := DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", 0x7F, "Ptr", 0, "Ptr", 0, "Ptr")
        if (currentSmall != LLARS_VisualIconSmall)
            DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", 0x80, "Ptr", 0, "Ptr", LLARS_VisualIconSmall)
    }
    if (LLARS_VisualIconLarge)
    {
        currentLarge := DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", 0x7F, "Ptr", 1, "Ptr", 0, "Ptr")
        if (currentLarge != LLARS_VisualIconLarge)
            DllCall("user32\SendMessageW", "Ptr", hwnd, "UInt", 0x80, "Ptr", 1, "Ptr", LLARS_VisualIconLarge)
    }
}

LLARS_VisualEnsureDialogIconHook()
{
    global LLARS_VisualIconCbtCallback, LLARS_VisualIconCbtHook, LLARS_VisualIconCbtAttempted
    if (LLARS_VisualIconCbtAttempted)
        return
    LLARS_VisualIconCbtAttempted := true
    ; A thread-local CBT activation hook reaches native #32770 message boxes
    ; before they appear. The periodic process-window pass remains a fallback.
    LLARS_VisualIconCbtCallback := RegisterCallback("LLARS_VisualIconCbt", "Fast", 3)
    if (LLARS_VisualIconCbtCallback)
    {
        threadId := DllCall("kernel32\GetCurrentThreadId", "UInt")
        LLARS_VisualIconCbtHook := DllCall("user32\SetWindowsHookExW", "Int", 5
            , "Ptr", LLARS_VisualIconCbtCallback, "Ptr", 0, "UInt", threadId, "Ptr")
    }
}

LLARS_VisualIconCbt(code, hwnd, eventInfo)
{
    global LLARS_VisualIconCbtHook
    if (code = 5 && hwnd)
    {
        VarSetCapacity(className, 96, 0)
        if DllCall("user32\GetClassNameW", "Ptr", hwnd, "Ptr", &className, "Int", 48)
        {
            className := StrGet(&className, "UTF-16")
            if (className = "#32770" || className = "AutoHotkeyGUI")
                LLARS_VisualApplyIconHandles(hwnd)
        }
    }
    return DllCall("user32\CallNextHookEx", "Ptr", LLARS_VisualIconCbtHook
        , "Int", code, "Ptr", hwnd, "Ptr", eventInfo, "Ptr")
}

LLARS_VisualMainIcon(hwnd, root := "")
{
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd))
        return false
    if !LLARS_VisualEnsureIcon(root)
        return false
    LLARS_VisualApplyIconHandles(hwnd)
    return true
}

LLARS_VisualSyncProcessIcons()
{
    global LLARS_VisualIconEnumCallback
    if (!LLARS_VisualIconEnumCallback)
        LLARS_VisualIconEnumCallback := RegisterCallback("LLARS_VisualIconEnumWindow", "", 2)
    if (LLARS_VisualIconEnumCallback)
        DllCall("user32\EnumWindows", "Ptr", LLARS_VisualIconEnumCallback, "Ptr", 0)
}

LLARS_VisualIconEnumWindow(hwnd, unused)
{
    ownerPid := 0
    DllCall("user32\GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", ownerPid)
    if (ownerPid != DllCall("kernel32\GetCurrentProcessId", "UInt"))
        return true
    VarSetCapacity(className, 128, 0)
    if (!DllCall("user32\GetClassNameW", "Ptr", hwnd, "Ptr", &className, "Int", 64, "Int"))
        return true
    className := StrGet(&className, "UTF-16")
    if (className = "AutoHotkeyGUI" || className = "#32770")
        LLARS_VisualMainIcon(hwnd)
    return true
}

; Shared Header Appearance modal is available from Selector and a running
; script's Setup window. It previews only; active artwork stays unchanged.
LLARS_HeaderPrefsShow(ownerGui := "1")
{
    global LLARSHeaderPrefsIndex, LLARSHeaderPrefsMode, LLARSHeaderPrefsPicture
    global LLARSHeaderPrefsName, LLARSHeaderPrefsHwnd, LLARS_VisualHeaderCatalogIssues
    items := LLARS_VisualHeaderCatalog()
    if (!items.Length())
    {
        MsgBox, 262192, Header Appearance, No valid header images are available. Restore the bundled Assets\UI headers.
        return
    }
    mode := LLARS_ConfigReadFile(LLARS_VisualConfigPath(), "GUI Header", "mode", "sequential")
    StringLower, mode, mode
    if (mode != "random" && mode != "fixed")
        mode := "sequential"
    selected := LLARS_VisualHeaderVariantName()
    if (mode = "fixed")
    {
        savedFixed := LLARS_ConfigReadFile(LLARS_VisualConfigPath(), "GUI Header", "fixed_theme", "")
        if LLARS_VisualHeaderIndex(items, savedFixed)
            selected := savedFixed
    }
    LLARSHeaderPrefsIndex := LLARS_VisualHeaderIndex(items, selected)
    if (!LLARSHeaderPrefsIndex)
        LLARSHeaderPrefsIndex := 1

    Gui, HeaderPrefs:Destroy
    Gui, HeaderPrefs:New, % "+Owner" . ownerGui . " +OwnDialogs +AlwaysOnTop +ToolWindow +HwndLLARSHeaderPrefsHwnd", Header Appearance
    Gui, HeaderPrefs:Margin, 0, 0
    LLARS_VisualPrepare("HeaderPrefs")
    LLARS_VisualModalHeader("HeaderPrefs", 440, "HEADER APPEARANCE")
    LLARS_VisualCard("HeaderPrefs", 10, 82, 420, 220)
    Gui, HeaderPrefs:Font, s10 Bold c173A61, Segoe UI
    Gui, HeaderPrefs:Add, Text, x22 y94 w390 h21 BackgroundTrans, Header rotation
    Gui, HeaderPrefs:Font, s10 Norm c24324A, Segoe UI
    Gui, HeaderPrefs:Add, DropDownList, x22 y117 w390 h120 vLLARSHeaderPrefsMode, Sequential|Random|Fixed
    modeTitle := (mode = "random") ? "Random" : (mode = "fixed") ? "Fixed" : "Sequential"
    GuiControl, HeaderPrefs:ChooseString, LLARSHeaderPrefsMode, %modeTitle%
    Gui, HeaderPrefs:Font, s9 Norm c526783, Segoe UI
    Gui, HeaderPrefs:Add, Text, x22 y151 w390 h36 BackgroundTrans, Previous/Next selects Fixed. Changes take effect on the next launch.
    Gui, HeaderPrefs:Add, Picture, x22 y190 w396 h53 vLLARSHeaderPrefsPicture
    Gui, HeaderPrefs:Font, s11 Bold cFFFFFF, Segoe UI
    Gui, HeaderPrefs:Add, Text, x32 y195 w376 h24 Center BackgroundTrans, LLARS
    Gui, HeaderPrefs:Font, s9 Bold c173A61, Segoe UI
    Gui, HeaderPrefs:Add, Text, x22 y253 w396 h20 Center BackgroundTrans vLLARSHeaderPrefsName
    Gui, HeaderPrefs:Add, Button, x99 y311 w114 h35 gHeaderPrefsPrevious, Previous
    Gui, HeaderPrefs:Add, Button, x227 y311 w114 h35 gHeaderPrefsNext, Next
    Gui, HeaderPrefs:Add, Button, x23 y361 w190 h36 gHeaderPrefsSave, Save preference
    Gui, HeaderPrefs:Add, Button, x227 y361 w190 h36 gHeaderPrefsCancel, Cancel
    Gui, HeaderPrefs:Show, w440 h412 Center, Header Appearance
    LLARS_VisualFinish("HeaderPrefs")
    LLARS_HeaderPrefsRedraw()
    if (LLARS_VisualHeaderCatalogIssues != "")
        MsgBox, 262192, Header Appearance, % "Some images were skipped:`n" . SubStr(LLARS_VisualHeaderCatalogIssues, 1, 600)
}

LLARS_HeaderPrefsPreviewChosen()
{
    ; Browsing an image is a request to select that image. The mode control
    ; visibly switches to Fixed; users may still choose Sequential or Random.
    GuiControl, HeaderPrefs:ChooseString, LLARSHeaderPrefsMode, Fixed
    LLARS_HeaderPrefsRedraw()
}

LLARS_HeaderPrefsRedraw()
{
    global LLARSHeaderPrefsIndex
    items := LLARS_VisualHeaderCatalog()
    if (!items.Length())
        return
    if (LLARSHeaderPrefsIndex < 1 || LLARSHeaderPrefsIndex > items.Length())
        LLARSHeaderPrefsIndex := 1
    item := items[LLARSHeaderPrefsIndex]
    imagePath := item.Path
    GuiControl, HeaderPrefs:, LLARSHeaderPrefsPicture, % "*w396 *h53 " . imagePath
    titleText := item.Name . "  (" . LLARSHeaderPrefsIndex . " of " . items.Length() . ")"
    GuiControl, HeaderPrefs:, LLARSHeaderPrefsName, %titleText%
}

