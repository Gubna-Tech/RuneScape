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


LLARS_ConfigSchemaCurrent()
{
    return 1
}

; Reads the framework-wide configuration schema. Existing LLARS configurations
; that predate the schema key are treated as schema 1 without rewriting them.
LLARS_GetConfigSchema(root := "", ByRef schemaExplicit := false, ByRef errorDetail := "")
{
    global LLARS_ROOT

    schemaExplicit := false
    errorDetail := ""
    if (root = "")
        root := LLARS_ROOT
    if (root = "")
        root := A_ScriptDir

    configPath := root . "\LLARS Config.ini"
    if !FileExist(configPath)
    {
        errorDetail := "LLARS Config.ini is missing."
        return 0
    }

    IniRead, schemaValue, %configPath%, LLARS, config_schema, __LLARS_SCHEMA_MISSING__
    if (schemaValue = "__LLARS_SCHEMA_MISSING__")
        return 1

    schemaExplicit := true
    schemaValue := Trim(schemaValue)
    if !RegExMatch(schemaValue, "^\d+$") || (schemaValue + 0) < 1
    {
        errorDetail := "The [LLARS] config_schema value is invalid."
        return 0
    }

    return schemaValue + 0
}

; Refuse configuration written by a newer schema. Configurations without an
; explicit schema are treated as schema 1 for compatibility.
LLARS_CheckConfigCompatibility(root := "")
{
    currentSchema := LLARS_ConfigSchemaCurrent()
    explicitSchema := false
    schemaError := ""
    configSchema := LLARS_GetConfigSchema(root, explicitSchema, schemaError)
    if (configSchema < 1)
    {
        MsgBox, 262192, LLARS Configuration, LLARS could not validate the shared configuration.`n`n%schemaError%`n`nRestore a known-good LLARS Config.ini before continuing.
        return false
    }

    if (configSchema > currentSchema)
    {
        MsgBox, 262192, LLARS Configuration, This LLARS Config.ini was created by a newer configuration schema.`n`nConfig schema: %configSchema%`nSupported schema: %currentSchema%`n`nUse the matching/newer LLARS version or restore an older configuration backup.
        return false
    }

    return true
}

; Runs the existing public configuration tools. Automatic mode is hidden and
; non-interactive so update-time backup can complete before Save As appears.
LLARS_RunConfigTool(root, action, automatic := true, ByRef errorDetail := "")
{
    errorDetail := ""
    root := RTrim(root, "\/")
    if (root = "")
    {
        errorDetail := "LLARS project root is unavailable."
        return false
    }

    if (action = "backup")
        toolName := "Config Backup.bat"
    else if (action = "restore")
        toolName := "Config Restore.bat"
    else
    {
        errorDetail := "Unknown configuration tool action."
        return false
    }

    toolPath := root . "\Backup\" . toolName
    if !FileExist(toolPath)
    {
        errorDetail := toolName . " is missing."
        return false
    }

    quote := Chr(34)
    command := quote . A_ComSpec . quote . " /d /c " . quote . quote . toolPath . quote
    if (automatic)
        command .= " --auto"
    command .= quote
    runOptions := automatic ? "Hide UseErrorLevel" : "UseErrorLevel"
    RunWait, %command%, %root%, %runOptions%
    exitCode := ErrorLevel
    if (exitCode = "ERROR" || exitCode != 0)
    {
        errorDetail := toolName . " returned exit code " . exitCode . "."
        return false
    }

    return true
}

LLARS_RunConfigBackup(root, automatic := true, ByRef errorDetail := "")
{
    return LLARS_RunConfigTool(root, "backup", automatic, errorDetail)
}

LLARS_RunConfigRestore(root, automatic := true, ByRef errorDetail := "")
{
    return LLARS_RunConfigTool(root, "restore", automatic, errorDetail)
}

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

; Updater MsgBox options include MB_TOPMOST (0x40000 / 262144) so they stay above LLARS GUIs.
LLARS_CheckForUpdates(showCurrentMessage := false)
{
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
    if !LLARS_GetLatestReleaseTag(latestTag, updateError)
    {
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
        if (showCurrentMessage)
            MsgBox, 262208, LLARS Update Check, LLARS v%currentVersion% is up to date.
        return false
    }

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
    tag := Trim(tag)
    if !RegExMatch(tag, "i)^v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$")
    {
        MsgBox, 262192, LLARS Update, LLARS could not determine a valid release tag to download.
        return false
    }
    if (SubStr(tag, 1, 1) != "v")
        tag := "v" . tag

    defaultName := A_Desktop . "\LLARS-" . tag . ".zip"

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

    downloadUrl := "https://github.com/Gubna-Tech/RuneScape/archive/refs/tags/" . tag . ".zip"
    partialPath := savePath . ".part"
    FileDelete, %partialPath%

    TrayTip, LLARS Update, Downloading %tag% to the selected location..., 10, 1
    URLDownloadToFile, %downloadUrl%, %partialPath%
    if (ErrorLevel || !FileExist(partialPath))
    {
        FileDelete, %partialPath%
        MsgBox, 262192, LLARS Update, LLARS could not download %tag%.`n`nCheck your internet connection and try again.`n`nRelease page:`nhttps://github.com/Gubna-Tech/RuneScape/releases/latest
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
