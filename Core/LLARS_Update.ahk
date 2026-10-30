; ================================================================
; |     LLARS VERSION & UPDATE     -     LLARS VERSION & UPDATE  |
; ================================================================

LLARS_GetVersion(root := "")
{
    global LLARS_ROOT, LLARS_VERSION

    if (LLARS_VERSION != "")
        return LLARS_VERSION

    if (root = "")
        root := LLARS_ROOT
    if (root = "")
        root := A_ScriptDir

    versionFile := root . "\VERSION"
    if FileExist(versionFile)
    {
        FileRead, versionText, %versionFile%
        versionText := Trim(versionText, " `t`r`n")
        versionText := RegExReplace(versionText, "i)^v")
        if RegExMatch(versionText, "^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$")
        {
            LLARS_VERSION := versionText
            return LLARS_VERSION
        }
    }

    LLARS_VERSION := "0.0.0"
    return LLARS_VERSION
}

LLARS_WindowTitle()
{
    return "LLARS - v" . LLARS_GetVersion()
}


; Configuration ownership lives in LLARS_Config.ahk.

; Captures the LLARS-owned window that was active when an update check began.
; Only that window is hidden during an accepted download flow.
LLARS_GetUpdateOwnerHwnd()
{
    ownerHwnd := WinExist("A")
    if (!ownerHwnd)
        return 0

    WinGet, ownerPID, PID, ahk_id %ownerHwnd%
    if (ownerPID != DllCall("GetCurrentProcessId"))
        return 0
    return ownerHwnd
}

LLARS_SetUpdateOwnerVisible(ownerHwnd, visible := true)
{
    if (!ownerHwnd)
        return false

    targetWindow := "ahk_id " . ownerHwnd
    if !WinExist(targetWindow)
        return false

    if (visible)
    {
        WinShow, %targetWindow%
        WinActivate, %targetWindow%
    }
    else
        WinHide, %targetWindow%
    return true
}

LLARS_VersionCompare(leftVersion, rightVersion)
{
    leftVersion := RegExReplace(Trim(leftVersion), "i)^v")
    rightVersion := RegExReplace(Trim(rightVersion), "i)^v")
    leftCore := StrSplit(StrSplit(leftVersion, "-")[1], ".")
    rightCore := StrSplit(StrSplit(rightVersion, "-")[1], ".")

    Loop, 3
    {
        leftPart := (leftCore.Length() >= A_Index) ? (leftCore[A_Index] + 0) : 0
        rightPart := (rightCore.Length() >= A_Index) ? (rightCore[A_Index] + 0) : 0
        if (leftPart > rightPart)
            return 1
        if (leftPart < rightPart)
            return -1
    }

    leftPre := InStr(leftVersion, "-") ? SubStr(leftVersion, InStr(leftVersion, "-") + 1) : ""
    rightPre := InStr(rightVersion, "-") ? SubStr(rightVersion, InStr(rightVersion, "-") + 1) : ""
    if (leftPre = "" && rightPre != "")
        return 1
    if (leftPre != "" && rightPre = "")
        return -1
    if (leftPre = rightPre)
        return 0
    return (leftPre > rightPre) ? 1 : -1
}

LLARS_NormalizeReleaseTag(tag)
{
    tag := Trim(tag)
    if !RegExMatch(tag, "i)^v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$")
        return ""
    if (SubStr(tag, 1, 1) != "v")
        tag := "v" . tag
    return tag
}

LLARS_ReleaseAssetName(tag)
{
    tag := LLARS_NormalizeReleaseTag(tag)
    if (tag = "")
        return ""
    return "RuneScape-" . tag . ".zip"
}

LLARS_ReleaseAssetUrl(tag)
{
    tag := LLARS_NormalizeReleaseTag(tag)
    if (tag = "")
        return ""
    return "https://github.com/Gubna-Tech/RuneScape/archive/refs/tags/" . tag . ".zip"
}

LLARS_ReleaseAssetAvailable(downloadUrl, ByRef errorDetail := "")
{
    errorDetail := ""
    if (downloadUrl = "")
    {
        errorDetail := "The repository archive URL was empty."
        return false
    }

    try
    {
        request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        request.SetTimeouts(600, 1000, 1000, 1500)
        request.Open("HEAD", downloadUrl, false)
        request.Option(6) := false
        request.SetRequestHeader("User-Agent", "LLARS-v" . LLARS_GetVersion())
        request.Send()

        status := request.Status + 0
        if (status = 200 || (status >= 300 && status < 400))
            return true

        errorDetail := "GitHub returned HTTP " . status . " for the tagged repository archive."
        return false
    }
    catch error
    {
        errorDetail := error.Message
        return false
    }
}

LLARS_GetLatestReleaseTag(ByRef latestTag, ByRef errorDetail := "")
{
    latestTag := ""
    errorDetail := ""
    latestUrl := "https://github.com/Gubna-Tech/RuneScape/releases/latest"

    ; The Latest endpoint returns a redirect containing the release tag. Do not
    ; follow that redirect: reading its Location header avoids loading the full
    ; GitHub release page and keeps startup checks as close to instant as possible.
    try
    {
        request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        request.SetTimeouts(350, 500, 500, 650)
        request.Open("HEAD", latestUrl, false)
        request.Option(6) := false
        request.SetRequestHeader("User-Agent", "LLARS-v" . LLARS_GetVersion())
        request.Send()

        redirectUrl := ""
        try redirectUrl := request.GetResponseHeader("Location")
        if RegExMatch(redirectUrl, "i)/tag/(v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)", match)
        {
            latestTag := match1
            return true
        }

        ; Some intermediaries can expose a redirected final URL even when the
        ; Location header is unavailable. Accept that without issuing a second request.
        finalUrl := request.Option(1)
        if RegExMatch(finalUrl, "i)/tag/(v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)", match)
        {
            latestTag := match1
            return true
        }

        throw Exception("Latest release tag was not present in GitHub's redirect response.")
    }
    catch error
    {
        errorDetail := error.Message
        return false
    }
}

; The splash is a separate named GUI.  AutoHotkey v1 changes A_DefaultGui
; when Gui, Name:New runs; preserve it so subsequent unqualified Gui commands
; cannot accidentally build or destroy the Selector inside this splash.
LLARS_ShowUpdateCheckSplash()
{
    global LLARSUpdateSplashHwnd, LLARSUpdateSplashMessage, LLARSUpdateSplashDetail
    previousGui := A_DefaultGui
    if (previousGui = "" || previousGui = "LLARSUpdateSplash")
        previousGui := 1
    version := LLARS_GetVersion()
    Gui, LLARSUpdateSplash:Destroy
    Gui, LLARSUpdateSplash:New, +AlwaysOnTop +ToolWindow -Caption +Border +HwndLLARSUpdateSplashHwnd
    LLARS_VisualPrepare("LLARSUpdateSplash")
    LLARS_VisualBanner("LLARSUpdateSplash", 430, 55)
    Gui, LLARSUpdateSplash:Font, s14 Bold cFFFFFF, Segoe UI
    Gui, LLARSUpdateSplash:Add, Text, x18 y12 w394 h26 Center BackgroundTrans, LLARS v%version%
    Gui, LLARSUpdateSplash:Font, s12 Bold c24324A, Segoe UI
    Gui, LLARSUpdateSplash:Add, Text, x18 y65 w394 h26 Center vLLARSUpdateSplashMessage, Checking for updates...
    Gui, LLARSUpdateSplash:Font, s10 Norm c516B89, Segoe UI
    Gui, LLARSUpdateSplash:Add, Text, x18 y100 w394 h34 Center vLLARSUpdateSplashDetail, Checking the latest release information.
    Gui, LLARSUpdateSplash:Show, w430 h148 Center NoActivate, LLARS Update Check
    LLARS_VisualFinish("LLARSUpdateSplash")
    Gui, %previousGui%:Default
    ; Give the update indicator one chance to paint before synchronous WinHTTP.
    Sleep, 20
    return LLARSUpdateSplashHwnd
}

; Show only real preparation stages. The explanation says what that stage does;
; no timer or fake progress percentage is used. Never steal focus from prompts.
LLARS_ShowInitializationSplash(stage := "Initializing LLARS...", detail := "Preparing your scripts and controls.")
{
    global LLARSUpdateSplashHwnd, LLARSUpdateSplashMessage, LLARSUpdateSplashDetail
    previousGui := A_DefaultGui
    if (previousGui = "" || previousGui = "LLARSUpdateSplash")
        previousGui := 1
    if (LLARSUpdateSplashHwnd && DllCall("IsWindow", "Ptr", LLARSUpdateSplashHwnd))
    {
        GuiControl, LLARSUpdateSplash:, LLARSUpdateSplashMessage, %stage%
        GuiControl, LLARSUpdateSplash:, LLARSUpdateSplashDetail, %detail%
        Gui, LLARSUpdateSplash:-AlwaysOnTop
        Gui, %previousGui%:Default
        ; Yield to paint the current work before synchronous setup resumes.
        Sleep, -1
        return LLARSUpdateSplashHwnd
    }
    version := LLARS_GetVersion()
    Gui, LLARSUpdateSplash:New, +ToolWindow -Caption +Border +HwndLLARSUpdateSplashHwnd
    LLARS_VisualPrepare("LLARSUpdateSplash")
    LLARS_VisualBanner("LLARSUpdateSplash", 430, 55)
    Gui, LLARSUpdateSplash:Font, s14 Bold cFFFFFF, Segoe UI
    Gui, LLARSUpdateSplash:Add, Text, x18 y12 w394 h26 Center BackgroundTrans, LLARS v%version%
    Gui, LLARSUpdateSplash:Font, s12 Bold c24324A, Segoe UI
    Gui, LLARSUpdateSplash:Add, Text, x18 y65 w394 h26 Center vLLARSUpdateSplashMessage, %stage%
    Gui, LLARSUpdateSplash:Font, s10 Norm c516B89, Segoe UI
    Gui, LLARSUpdateSplash:Add, Text, x18 y100 w394 h34 Center vLLARSUpdateSplashDetail, %detail%
    Gui, LLARSUpdateSplash:Show, w430 h148 Center NoActivate, LLARS Initializing
    LLARS_VisualFinish("LLARSUpdateSplash")
    Gui, %previousGui%:Default
    Sleep, 20
    return LLARSUpdateSplashHwnd
}

LLARS_StartupStage(stage, detail := "")
{
    static previousStage := "", previousTick := 0
    now := A_TickCount
    if (previousTick)
        OutputDebug, % "LLARS startup: " . previousStage . " took " . (now - previousTick) . " ms"
    previousStage := stage
    previousTick := now
    if (detail = "")
        detail := "Preparing the next startup step."
    return LLARS_ShowInitializationSplash(stage, detail)
}

; Cleanup is strictly scoped to the splash HWND, never the Selector or main GUI.
LLARS_HideUpdateCheckSplash()
{
    global LLARSUpdateSplashHwnd
    previousGui := A_DefaultGui
    if (previousGui = "" || previousGui = "LLARSUpdateSplash")
        previousGui := 1
    if (LLARSUpdateSplashHwnd && DllCall("IsWindow", "Ptr", LLARSUpdateSplashHwnd))
        Gui, LLARSUpdateSplash:Destroy
    LLARSUpdateSplashHwnd := 0
    Gui, %previousGui%:Default
}

; Updater MsgBox options include MB_TOPMOST (0x40000 / 262144) so they stay above LLARS GUIs.
LLARS_CheckForUpdates(showCurrentMessage := false)
{
    global LLARS_StartupContinuation
    static checkComplete := false
    static checkRunning := false

    ; A script launched by the Script Selector inherits this process-local marker,
    ; so the selector and selected script never perform the same GitHub check twice.
    EnvGet, inheritedCheck, LLARS_UPDATE_CHECKED
    if (inheritedCheck = "1")
    {
        checkComplete := true
        return false
    }

    if (checkComplete || checkRunning)
        return false

    checkRunning := true
    updateOwnerHwnd := LLARS_GetUpdateOwnerHwnd()
    currentVersion := LLARS_GetVersion()
    LLARS_ShowUpdateCheckSplash()
    if !LLARS_GetLatestReleaseTag(latestTag, updateError)
    {
        if (LLARS_StartupContinuation)
            LLARS_ShowInitializationSplash("Initializing LLARS...", "Update check finished. Preparing input and settings.")
        else
            LLARS_HideUpdateCheckSplash()
        checkRunning := false
        checkComplete := true
        EnvSet, LLARS_UPDATE_CHECKED, 1
        return false
    }
    latestVersion := RegExReplace(latestTag, "i)^v")
    checkRunning := false
    checkComplete := true
    EnvSet, LLARS_UPDATE_CHECKED, 1

    if (LLARS_VersionCompare(latestVersion, currentVersion) <= 0)
    {
        if (LLARS_StartupContinuation && !showCurrentMessage)
            LLARS_ShowInitializationSplash("Initializing LLARS...", "Update check finished. Preparing input and settings.")
        else
            LLARS_HideUpdateCheckSplash()
        if (showCurrentMessage)
            MsgBox, 262208, LLARS Update Check, LLARS v%currentVersion% is up to date.
        return false
    }

    ; Don't cover an update decision with a lingering startup indicator.
    LLARS_HideUpdateCheckSplash()
    MsgBox, 262212, LLARS Update Available, A newer LLARS release is available.`n`nCurrent version: v%currentVersion%`nNewest release: %latestTag%`n`nLLARS will automatically back up your current configuration before downloading.`n`nDownload the newest release now?
    IfMsgBox, Yes
        return LLARS_DownloadRelease(latestTag, updateOwnerHwnd)
    return false
}

LLARS_IsZipArchive(filePath)
{
    if !FileExist(filePath)
        return false

    file := FileOpen(filePath, "r")
    if !IsObject(file)
        return false
    if (file.Length < 4)
    {
        file.Close()
        return false
    }

    signature := file.ReadUInt()
    file.Close()
    return (signature = 0x04034B50 || signature = 0x06054B50 || signature = 0x08074B50)
}

LLARS_DownloadRelease(tag, ownerHwnd := 0)
{
    tag := LLARS_NormalizeReleaseTag(tag)
    if (tag = "")
    {
        MsgBox, 262192, LLARS Update, LLARS could not determine a valid release tag to download.
        return false
    }

    archiveName := LLARS_ReleaseAssetName(tag)
    downloadUrl := LLARS_ReleaseAssetUrl(tag)
    if (archiveName = "" || downloadUrl = "")
    {
        MsgBox, 262192, LLARS Update, LLARS could not resolve the RuneScape repository archive for %tag%.
        return false
    }

    defaultName := A_Desktop . "\" . archiveName

    ; Protect both the shared LLARS config and script-local configs before the
    ; update download begins. A failed backup leaves the running copy untouched.
    global LLARS_ROOT
    backupRoot := LLARS_ROOT
    if (backupRoot = "")
        backupRoot := A_ScriptDir
    backupError := ""
    if !LLARS_RunConfigBackup(backupRoot, true, backupError)
    {
        MsgBox, 262192, LLARS Update, LLARS could not back up your configuration, so the update was not started.`n`n%backupError%`n`nYour current LLARS files are unchanged. You can run Backup\Config Backup.bat manually and try again.
        return false
    }

    archiveError := ""
    if !LLARS_ReleaseAssetAvailable(downloadUrl, archiveError)
    {
        MsgBox, 262192, LLARS Update, The tagged RuneScape repository archive for %tag% is not available, so the update was not started.`n`n%archiveError%`n`nYour current LLARS files are unchanged.`n`nRelease page:`nhttps://github.com/Gubna-Tech/RuneScape/releases/latest
        return false
    }

    ; Keep the current LLARS window out of the way while Windows asks where
    ; to save the update. Cancel/failure restores it; success exits LLARS.
    LLARS_SetUpdateOwnerVisible(ownerHwnd, false)
    FileSelectFile, savePath, S16, %defaultName%, Save LLARS Update, ZIP Archives (*.zip)
    if (ErrorLevel || savePath = "")
    {
        LLARS_SetUpdateOwnerVisible(ownerHwnd, true)
        return false
    }
    if !RegExMatch(savePath, "i)\.zip$")
        savePath .= ".zip"

    partialPath := savePath . ".part"
    FileDelete, %partialPath%

    TrayTip, LLARS Update, Downloading %tag% to the selected location..., 10, 1
    URLDownloadToFile, %downloadUrl%, %partialPath%
    if (ErrorLevel || !FileExist(partialPath))
    {
        FileDelete, %partialPath%
        MsgBox, 262192, LLARS Update, LLARS could not download the RuneScape repository archive for %tag%.`n`nThe tagged repository archive may be unavailable, or the network request may have failed.`n`nRelease page:`nhttps://github.com/Gubna-Tech/RuneScape/releases/latest
        LLARS_SetUpdateOwnerVisible(ownerHwnd, true)
        return false
    }

    FileGetSize, downloadedSize, %partialPath%
    if (downloadedSize < 1024)
    {
        FileDelete, %partialPath%
        MsgBox, 262192, LLARS Update, The downloaded release archive was incomplete.`n`nNothing was saved. Please try again.
        LLARS_SetUpdateOwnerVisible(ownerHwnd, true)
        return false
    }

    if !LLARS_IsZipArchive(partialPath)
    {
        FileDelete, %partialPath%
        MsgBox, 262192, LLARS Update, The downloaded file was not a valid ZIP archive.`n`nNothing was saved. Please try again or use the GitHub release page.
        LLARS_SetUpdateOwnerVisible(ownerHwnd, true)
        return false
    }

    FileMove, %partialPath%, %savePath%, 1
    if (ErrorLevel)
    {
        FileDelete, %partialPath%
        MsgBox, 262192, LLARS Update, LLARS downloaded the update but could not save it to:`n%savePath%
        LLARS_SetUpdateOwnerVisible(ownerHwnd, true)
        return false
    }

    ; A successful update download ends the old LLARS process immediately so
    ; users cannot accidentally keep the previous version running beside the new one.
    ExitApp
}

; ===================================================================
; |     INSTALLATION INTEGRITY     -     INSTALLATION INTEGRITY      |
; ===================================================================
; Returns the generated runtime manifest used by installation integrity checks.
LLARS_IntegrityManifestPath(root := "")
{
    global LLARS_ROOT

    if (root = "")
        root := LLARS_ROOT
    if (root = "")
        root := A_ScriptDir
    return RTrim(root, "\/") . "\Core\LLARS_RequiredFiles.manifest"
}

; Computes one file SHA-256 with the Windows certutil utility.
; Only packaged vendor binaries are hash-enforced; user configuration is not.
LLARS_FileSHA256(path, ByRef errorDetail := "")
{
    errorDetail := ""
    if !FileExist(path)
    {
        errorDetail := "File is missing."
        return ""
    }

    processId := DllCall("Kernel32\GetCurrentProcessId", "UInt")
    Random, hashToken, 100000, 999999
    tempPath := A_Temp . "\LLARS-Hash-" . processId . "-" . hashToken . ".txt"
    command := ComSpec . " /C certutil -hashfile """ . path . """ SHA256 > """ . tempPath . """ 2>&1"
    RunWait, %command%,, Hide UseErrorLevel
    exitCode := ErrorLevel

    output := ""
    if FileExist(tempPath)
    {
        FileRead, output, %tempPath%
        FileDelete, %tempPath%
    }

    if (exitCode != 0)
    {
        errorDetail := "Windows could not calculate the SHA-256 hash."
        return ""
    }

    if !RegExMatch(output, "im)^\s*([0-9A-F]{64})\s*$", hashMatch)
    {
        errorDetail := "Windows returned an unreadable SHA-256 result."
        return ""
    }

    hashValue := hashMatch1
    StringLower, hashValue, hashValue
    return hashValue
}

; Checks active LLARS configuration files only. Backup copies are excluded,
; while parseable legacy UTF-8/UTF-16 BOM configs remain supported.
LLARS_IntegrityCheckIniEncoding(root, ByRef badFiles := "", ByRef checkedCount := 0)
{
    badFiles := ""
    checkedCount := 0
    root := RTrim(root, "\/")
    iniFiles := []

    rootConfig := root . "\LLARS Config.ini"
    if FileExist(rootConfig)
        iniFiles.Push(rootConfig)

    for _, configRoot in [root . "\Scripts", root . "\Scripts - Menu Entry Swapper", root . "\Templates"]
    {
        pattern := configRoot . "\*.ini"
        Loop, Files, %pattern%, FR
            iniFiles.Push(A_LoopFileFullPath)
    }

    for _, iniPath in iniFiles
    {
        checkedCount++
        if (LLARS_ConfigSectionList(iniPath) = "ERROR")
        {
            if (badFiles != "")
                badFiles .= "`n"
            badFiles .= iniPath
        }
    }
    return (badFiles = "")
}


; Runs a non-restrictive integrity audit of the installed LLARS package.
; The result is diagnostic: it identifies repairable package damage without
; treating user-editable settings as anti-tamper material.
LLARS_VerifyInstallation(root := "", verifyVendorHashes := true)
{
    global LLARS_ROOT

    if (root = "")
        root := LLARS_ROOT
    if (root = "")
        root := A_ScriptDir
    root := RTrim(root, "\/")

    result := {Status: "PASS"
        , Issues: []
        , IssueCount: 0
        , RequiredChecked: 0
        , SelectorTargetsChecked: 0
        , HashesChecked: 0
        , IniChecked: 0
        , Version: "Unknown"
        , Manifest: LLARS_IntegrityManifestPath(root)}

    for _, folderName in ["Core", "Scripts", "Scripts - Menu Entry Swapper", "Vendor", "Assets", "Templates"]
    {
        if !InStr(FileExist(root . "\" . folderName), "D")
            result.Issues.Push("Required folder is missing: " . folderName . ". Re-extract or redownload the complete LLARS package.")
    }

    versionPath := root . "\VERSION"
    if FileExist(versionPath)
    {
        FileRead, versionText, %versionPath%
        versionText := Trim(versionText, " `t`r`n")
        result.Version := versionText
        if !RegExMatch(versionText, "^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$")
            result.Issues.Push("VERSION is present but malformed. Re-extract or redownload the complete LLARS package.")
    }
    else
        result.Issues.Push("VERSION is missing. Re-extract or redownload the complete LLARS package.")

    manifestPath := result.Manifest
    if !FileExist(manifestPath)
        result.Issues.Push("Core\LLARS_RequiredFiles.manifest is missing. Re-extract or redownload the complete LLARS package.")
    else
    {
        FileRead, manifestText, %manifestPath%
        if ErrorLevel
            result.Issues.Push("Core\LLARS_RequiredFiles.manifest could not be read. Re-extract or redownload LLARS.")
        else
        {
            Loop, Parse, manifestText, `n, `r
            {
                line := Trim(A_LoopField)
                if (line = "" || SubStr(line, 1, 1) = "#")
                    continue
                fields := StrSplit(line, A_Tab)
                kind := Trim(fields[1])
                StringLower, kind, kind
                relativePath := fields.Length() >= 2 ? Trim(fields[2]) : ""
                relativePath := StrReplace(relativePath, "/", "\")
                if (relativePath = "")
                    continue
                fullPath := root . "\" . relativePath

                if (kind = "required")
                {
                    result.RequiredChecked++
                    if (RegExMatch(relativePath, "i)^(?:Scripts|Scripts - Menu Entry Swapper)\\.*\.ahk$"))
                        result.SelectorTargetsChecked++
                    if !FileExist(fullPath)
                        result.Issues.Push(relativePath . " is missing. Re-extract or redownload the complete LLARS package.")
                    continue
                }

                if (kind = "sha256" && verifyVendorHashes)
                {
                    expectedHash := fields.Length() >= 3 ? Trim(fields[3]) : ""
                    StringLower, expectedHash, expectedHash
                    result.HashesChecked++
                    if !FileExist(fullPath)
                        continue
                    hashError := ""
                    actualHash := LLARS_FileSHA256(fullPath, hashError)
                    if (actualHash = "")
                        result.Issues.Push(relativePath . " could not be hash-verified. " . hashError)
                    else if (actualHash != expectedHash)
                        result.Issues.Push(relativePath . " does not match the supported packaged version. Re-extract or redownload LLARS.")
                }
            }
        }
    }

    canonicalIcon := root . "\Assets\Logo\LLARS\LLARS Logo.ico"
    if !FileExist(canonicalIcon)
        result.Issues.Push("The canonical LLARS icon is missing. Re-extract or redownload the complete LLARS package.")

    duplicateIconCount := 0
    iconPattern := root . "\LLARS Logo.ico"
    Loop, Files, %iconPattern%, R
    {
        if (A_LoopFileFullPath != canonicalIcon)
            duplicateIconCount++
    }
    if (duplicateIconCount > 0)
        result.Issues.Push("Deprecated duplicate LLARS icon files were found outside Assets\Logo\LLARS. Use a clean LLARS release folder.")

    badIniFiles := ""
    iniCount := 0
    if !LLARS_IntegrityCheckIniEncoding(root, badIniFiles, iniCount)
    {
        result.Issues.Push("One or more active LLARS config files could not be parsed. Legacy UTF-8/UTF-16 BOM configs are supported; restore only the affected config from a clean release or backup.")
    }
    result.IniChecked := iniCount

    result.IssueCount := result.Issues.Length()
    if (result.IssueCount > 0)
        result.Status := "FAIL"
    return result
}

; Formats the installation audit for Information UI and support bundles.
LLARS_IntegrityResultText(result)
{
    if !IsObject(result)
        return "Installation integrity result is unavailable."

    text := "Status: " . result.Status . "`r`n"
    text .= "Version: v" . result.Version . "`r`n"
    text .= "Required runtime files checked: " . result.RequiredChecked . "`r`n"
    text .= "Selector targets checked: " . result.SelectorTargetsChecked . "`r`n"
    text .= "Vendor hashes checked: " . result.HashesChecked . "`r`n"
    text .= "Active config INIs checked: " . result.IniChecked . "`r`n"
    text .= "Issues: " . result.IssueCount . "`r`n"

    if (result.IssueCount > 0)
    {
        text .= "`r`nRepair guidance:`r`n"
        for index, issue in result.Issues
            text .= index . ". " . issue . "`r`n"
    }
    else
        text .= "`r`nThe required LLARS runtime structure and pinned vendor binaries match this release.`r`n"

    return RTrim(text, "`r`n")
}
