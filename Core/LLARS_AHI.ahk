; ================================================================
; |     LLARS AUTOHOTINTERCEPTION     -     INPUT BACKEND           |
; ================================================================
;
; LLARS uses AutoHotInterception only for input synthesis. It does not
; subscribe to, filter, or block the user's physical keyboard or mouse.

LLARS_AHI_LibraryReady(projectRoot := "")
{
    ; LLARS_AHI.ahk is included before LLARS_Core.ahk, so this layer must not
    ; call Core helpers while AutoHotkey v1 is parsing includes.
    if (projectRoot = "")
        return false

    lib := projectRoot . "\Vendor\AutoHotInterception\Lib"
    required := ["AutoHotInterception.ahk", "CLR.ahk", "AutoHotInterception.dll", "x86\interception.dll", "x64\interception.dll"]
    for _, relativePath in required
    {
        if !FileExist(lib . "\" . relativePath)
            return false
    }
    return true
}

LLARS_AHI_BundledPayloadFiles(projectRoot := "")
{
    vendor := projectRoot . "\Vendor\AutoHotInterception"
    return [vendor . "\Lib\AutoHotInterception.ahk"
        , vendor . "\Lib\CLR.ahk"
        , vendor . "\Lib\AutoHotInterception.dll"
        , vendor . "\Lib\x86\interception.dll"
        , vendor . "\Lib\x64\interception.dll"
        , vendor . "\install-interception.exe"]
}

; Browser-downloaded ZIPs can propagate Mark-of-the-Web (Zone.Identifier)
; to extracted files. Strip that metadata from LLARS's pinned AHI payload so
; AutoHotInterception can load its managed/native DLLs without asking users
; to manually use Properties > Unblock. This changes only the alternate data
; stream; the verified file bytes/hashes remain unchanged.
LLARS_AHI_PrepareBundledFileSecurity(projectRoot := "", ByRef statusReason := "")
{
    statusReason := ""
    if (projectRoot = "")
    {
        statusReason := "LLARS project root is unavailable"
        return false
    }

    failures := []
    for _, filePath in LLARS_AHI_BundledPayloadFiles(projectRoot)
    {
        if !FileExist(filePath)
            continue

        streamPath := filePath . ":Zone.Identifier"
        if DllCall("Kernel32\DeleteFileW", "WStr", streamPath, "Int")
            continue

        errorCode := DllCall("Kernel32\GetLastError", "UInt")
        ; 2/3 = stream/path absent. 50/87/123 cover filesystems that do not
        ; support named streams or reject ADS syntax; there is nothing to clear.
        if (errorCode = 2 || errorCode = 3 || errorCode = 50 || errorCode = 87 || errorCode = 123)
            continue

        failures.Push(filePath)
    }

    if (failures.Length())
    {
        statusReason := "Windows file security could not be prepared for the bundled AutoHotInterception runtime"
        return false
    }

    statusReason := "Ready"
    return true
}

; Functional readiness test used for post-reboot detection. Interception's
; keyboard/mouse kernel filters are not ordinary user-mode services, so their
; QueryServiceStatusEx state is not a reliable "installed and usable" gate.
; Instead call the official Interception C API directly. A non-zero context
; proves the user-mode DLL can open the kernel device interfaces on this boot.
LLARS_AHI_FunctionalReady(projectRoot := "", ByRef statusReason := "")
{
    statusReason := ""

    if !LLARS_AHI_LibraryReady(projectRoot)
    {
        statusReason := "AHI runtime files are missing"
        return false
    }

    bitness := (A_PtrSize = 8) ? "x64" : "x86"
    dllFile := projectRoot . "\Vendor\AutoHotInterception\Lib\" . bitness . "\interception.dll"
    if !FileExist(dllFile)
    {
        statusReason := "Interception runtime DLL is missing"
        return false
    }

    hModule := DllCall("Kernel32\LoadLibraryW", "WStr", dllFile, "Ptr")
    if (!hModule)
    {
        statusReason := "Interception runtime DLL could not be loaded"
        return false
    }

    createProc := DllCall("Kernel32\GetProcAddress", "Ptr", hModule, "AStr", "interception_create_context", "Ptr")
    destroyProc := DllCall("Kernel32\GetProcAddress", "Ptr", hModule, "AStr", "interception_destroy_context", "Ptr")
    if (!createProc || !destroyProc)
    {
        DllCall("Kernel32\FreeLibrary", "Ptr", hModule)
        statusReason := "Interception runtime entry points are unavailable"
        return false
    }

    context := DllCall(createProc, "CDecl Ptr")
    if (!context)
    {
        DllCall("Kernel32\FreeLibrary", "Ptr", hModule)
        statusReason := "Interception driver interface is not active on this Windows boot"
        return false
    }

    DllCall(destroyProc, "Ptr", context, "CDecl")
    DllCall("Kernel32\FreeLibrary", "Ptr", hModule)
    statusReason := "Ready"
    return true
}

; Returns 0 when the service is missing/unavailable, otherwise its Windows
; SERVICE_* current-state value (4 = running).
LLARS_AHI_ServiceState(serviceName)
{
    static SC_MANAGER_CONNECT := 0x0001
    static SERVICE_QUERY_STATUS := 0x0004
    static SC_STATUS_PROCESS_INFO := 0

    hSCM := DllCall("Advapi32\OpenSCManagerW", "Ptr", 0, "Ptr", 0, "UInt", SC_MANAGER_CONNECT, "Ptr")
    if (!hSCM)
        return 0

    hService := DllCall("Advapi32\OpenServiceW", "Ptr", hSCM, "WStr", serviceName, "UInt", SERVICE_QUERY_STATUS, "Ptr")
    if (!hService)
    {
        DllCall("Advapi32\CloseServiceHandle", "Ptr", hSCM)
        return 0
    }

    VarSetCapacity(status, 36, 0)
    bytesNeeded := 0
    ok := DllCall("Advapi32\QueryServiceStatusEx", "Ptr", hService, "Int", SC_STATUS_PROCESS_INFO, "Ptr", &status, "UInt", 36, "UInt*", bytesNeeded)
    state := ok ? NumGet(status, 4, "UInt") : 0

    DllCall("Advapi32\CloseServiceHandle", "Ptr", hService)
    DllCall("Advapi32\CloseServiceHandle", "Ptr", hSCM)
    return state
}

LLARS_AHI_RegistryFilterPresent(classGuid, filterName)
{
    keyPath := "SYSTEM\CurrentControlSet\Control\Class\" . classGuid
    RegRead, filters, HKEY_LOCAL_MACHINE, %keyPath%, UpperFilters
    if (ErrorLevel)
        return false

    ; REG_MULTI_SZ values are returned as line-separated text by AHK v1.
    filters := StrReplace(filters, "`r", "")
    Loop, Parse, filters, `n
    {
        entry := Trim(A_LoopField, " `t")
        if (entry = filterName)
            return true
    }
    return false
}

LLARS_AHI_RegistryServicePresent(serviceName)
{
    keyPath := "SYSTEM\CurrentControlSet\Services\" . serviceName
    RegRead, serviceStart, HKEY_LOCAL_MACHINE, %keyPath%, Start
    return ErrorLevel ? false : true
}

LLARS_AHI_DriverRegistered()
{
    ; File presence is not enough: Interception can leave keyboard.sys/mouse.sys
    ; behind after uninstall. Require the class UpperFilters registrations and
    ; both service keys, which are the actual install state used by Windows.
    keyboardClass := "{4D36E96B-E325-11CE-BFC1-08002BE10318}"
    mouseClass := "{4D36E96F-E325-11CE-BFC1-08002BE10318}"
    driverRoot := A_WinDir . "\System32\drivers\"
    return (LLARS_AHI_RegistryFilterPresent(keyboardClass, "keyboard")
        && LLARS_AHI_RegistryFilterPresent(mouseClass, "mouse")
        && LLARS_AHI_RegistryServicePresent("keyboard")
        && LLARS_AHI_RegistryServicePresent("mouse")
        && FileExist(driverRoot . "keyboard.sys")
        && FileExist(driverRoot . "mouse.sys")) ? true : false
}

LLARS_AHI_DriverReady()
{
    return (LLARS_AHI_ServiceState("keyboard") = 4 && LLARS_AHI_ServiceState("mouse") = 4)
}

LLARS_AHI_SetupScript(projectRoot)
{
    return projectRoot . "\Core\LLARS_AHI_Setup.ps1"
}

LLARS_AHI_SetupResultPath(projectRoot)
{
    return projectRoot . "\Vendor\AutoHotInterception\.setup-result"
}

LLARS_AHI_ClearSetupResult(projectRoot)
{
    resultPath := LLARS_AHI_SetupResultPath(projectRoot)
    if FileExist(resultPath)
        FileDelete, %resultPath%
}

LLARS_AHI_LogDir(projectRoot)
{
    return projectRoot . "\Vendor\AutoHotInterception\Logs"
}

LLARS_AHI_CleanupLegacyLogs(projectRoot)
{
    if (projectRoot = "")
        return

    legacyDir := projectRoot . "\Logs"
    if !FileExist(legacyDir)
        return

    logDir := LLARS_AHI_LogDir(projectRoot)
    if !FileExist(logDir)
        FileCreateDir, %logDir%

    legacyPattern := legacyDir . "\AutoHotInterception-*"
    Loop, Files, %legacyPattern%, F
        FileMove, %A_LoopFileFullPath%, % logDir . "\" . A_LoopFileName, 1

    ; Remove the old top-level Logs directory after AHI logs are migrated, if it is empty.
    FileRemoveDir, %legacyDir%
}

LLARS_AHI_Trace(projectRoot, message)
{
    if (projectRoot = "")
        return

    LLARS_AHI_CleanupLegacyLogs(projectRoot)
    logDir := LLARS_AHI_LogDir(projectRoot)
    if !FileExist(logDir)
        FileCreateDir, %logDir%
    logPath := logDir . "\AutoHotInterception-Setup.log"
    processId := DllCall("Kernel32\GetCurrentProcessId", "UInt")
    FileAppend, % "AHK[" . processId . "][" . A_ScriptName . "] | " . message . "`r`n", %logPath%
}

LLARS_AHI_SupportReportPath(projectRoot)
{
    return LLARS_AHI_LogDir(projectRoot) . "\AutoHotInterception-Support.txt"
}

LLARS_AHI_SanitizeSupportText(text, projectRoot := "")
{
    if (text = "")
        return ""

    if (projectRoot != "")
        text := StrReplace(text, projectRoot, "<LLARS_ROOT>")

    EnvGet, userProfile, USERPROFILE
    if (userProfile != "")
        text := StrReplace(text, userProfile, "<USERPROFILE>")

    EnvGet, tempPath, TEMP
    if (tempPath != "")
        text := StrReplace(text, tempPath, "<TEMP>")

    if (A_UserName != "")
        text := StrReplace(text, A_UserName, "<USER>")

    ; Hardware instance paths can contain device-specific serial or instance data.
    text := RegExReplace(text, "i)(?:HID|USB|ACPI)\\[^|`r`n]+", "<DEVICE_HANDLE>")

    return text
}

LLARS_AHI_ReadTextTail(path, maxLines := 40)
{
    if !FileExist(path)
        return ""

    FileRead, content, %path%
    if (ErrorLevel || content = "")
        return ""

    content := StrReplace(content, "`r", "")
    lines := StrSplit(content, "`n")
    total := lines.MaxIndex()
    if (!total)
        return ""

    start := total - maxLines + 1
    if (start < 1)
        start := 1

    output := ""
    Loop, % total - start + 1
    {
        index := start + A_Index - 1
        line := lines[index]
        if (index = total && line = "")
            continue
        output .= line . "`r`n"
    }
    return RTrim(output, "`r`n")
}

LLARS_AHI_RuntimeFileReport(projectRoot)
{
    lib := projectRoot . "\Vendor\AutoHotInterception\Lib"
    required := ["AutoHotInterception.ahk", "CLR.ahk", "AutoHotInterception.dll", "x86\interception.dll", "x64\interception.dll"]
    text := ""
    for _, relativePath in required
    {
        fullPath := lib . "\" . relativePath
        if FileExist(fullPath)
        {
            fileSize := 0
            fileTime := ""
            FileGetSize, fileSize, %fullPath%, B
            FileGetTime, fileTime, %fullPath%, M
            text .= "  " . relativePath . " = Present | " . fileSize . " bytes | " . fileTime . "`r`n"
        }
        else
            text .= "  " . relativePath . " = MISSING`r`n"
    }

    installer := projectRoot . "\Vendor\AutoHotInterception\install-interception.exe"
    if FileExist(installer)
    {
        installerSize := 0
        FileGetSize, installerSize, %installer%, B
        text .= "  install-interception.exe = Present | " . installerSize . " bytes`r`n"
    }
    else
        text .= "  install-interception.exe = Not cached`r`n"

    return RTrim(text, "`r`n")
}

LLARS_AHI_PeekSetupResult(projectRoot)
{
    resultPath := LLARS_AHI_SetupResultPath(projectRoot)
    if !FileExist(resultPath)
        return "<none>"
    FileRead, resultText, %resultPath%
    if ErrorLevel
        return "<unreadable>"
    return Trim(resultText, " `t`r`n")
}

LLARS_AHI_BuildSupportReport(projectRoot, trigger := "Manual")
{
    global LLARS_AHI_Object, LLARS_AHI_READY
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_INFO, LLARS_AHI_KEYBOARD_INFO
    global LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL
    global LLARS_AHI_DRIVER_READY, LLARS_AHI_RUNTIME_READY
    global LLARS_AHI_LAST_MOUSE_TRANSPORT, LLARS_AHI_LAST_KEYBOARD_TRANSPORT
    global LLARS_DeveloperActions

    FormatTime, reportTime,, yyyy-MM-dd HH:mm:ss
    RegRead, windowsBuild, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentBuildNumber
    if ErrorLevel
        windowsBuild := "Unknown"
    RegRead, windowsDisplay, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion, DisplayVersion
    if ErrorLevel
        windowsDisplay := "Unknown"

    libraryReady := LLARS_AHI_LibraryReady(projectRoot)
    if (LLARS_AHI_DRIVER_READY)
    {
        functionalReady := true
        functionalReason := "Ready (current LLARS process)"
    }
    else if (libraryReady)
        functionalReady := LLARS_AHI_FunctionalReady(projectRoot, functionalReason)
    else
    {
        functionalReady := false
        functionalReason := "AHI runtime files are missing"
    }

    keyboardState := LLARS_AHI_ServiceStateText(LLARS_AHI_ServiceState("keyboard"))
    mouseState := LLARS_AHI_ServiceStateText(LLARS_AHI_ServiceState("mouse"))
    registeredState := LLARS_AHI_DriverRegistered() ? "Yes" : "No"
    pendingState := LLARS_AHI_PendingRestart(projectRoot) ? "Yes" : "No"
    runtimeState := libraryReady ? "Ready" : "Missing"
    objectState := IsObject(LLARS_AHI_Object) ? "Initialized" : "Not initialized"
    engineState := (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY) ? "AutoHotInterception" : "Standard AutoHotkey / fallback"

    report := "LLARS AutoHotInterception Support Report`r`n"
    report .= "Report Version: 1`r`n"
    report .= "Generated: " . reportTime . "`r`n"
    report .= "Trigger: " . trigger . "`r`n"
    report .= "Entry Point: " . A_ScriptName . "`r`n"
    report .= "`r`n[Environment]`r`n"
    report .= "AutoHotkey: " . A_AhkVersion . " | " . (A_PtrSize = 8 ? "64-bit" : "32-bit") . " | Unicode=" . (A_IsUnicode ? "Yes" : "No") . "`r`n"
    report .= "Windows: " . A_OSVersion . " | DisplayVersion=" . windowsDisplay . " | Build=" . windowsBuild . " | OS=" . (A_Is64bitOS ? "64-bit" : "32-bit") . "`r`n"
    report .= "LLARS process elevated: " . (A_IsAdmin ? "Yes" : "No") . "`r`n"

    report .= "`r`n[AHI Status]`r`n"
    report .= "Input Engine: " . engineState . "`r`n"
    report .= "Mouse behavior: LLARS keeps its original NaturalClick movement and timing while sending supported mouse input through AutoHotInterception.`r`n"
    report .= "AHI Runtime: " . runtimeState . "`r`n"
    report .= "Interception Functional: " . (functionalReady ? "Ready" : "Not ready") . "`r`n"
    report .= "Functional Detail: " . (functionalReason = "" ? "<none>" : functionalReason) . "`r`n"
    report .= "AHI Object: " . objectState . "`r`n"
    report .= "Status: " . (LLARS_AHI_STATUS_REASON = "" ? "<none>" : LLARS_AHI_STATUS_REASON) . "`r`n"
    report .= "Status Detail: " . (LLARS_AHI_STATUS_DETAIL = "" ? "<none>" : LLARS_AHI_STATUS_DETAIL) . "`r`n"
    report .= "Driver registered diagnostic: " . registeredState . "`r`n"
    report .= "Service diagnostics: keyboard=" . keyboardState . " | mouse=" . mouseState . "`r`n"
    report .= "Pending restart marker: " . pendingState . "`r`n"
    report .= "Setup result marker: " . LLARS_AHI_PeekSetupResult(projectRoot) . "`r`n"

    report .= "`r`n[Selected Devices]`r`n"
    report .= LLARS_AHI_DeviceLogText("Mouse", LLARS_AHI_MOUSE_INFO) . " | Ready=" . (LLARS_AHI_MOUSE_READY ? "Yes" : "No") . "`r`n"
    report .= LLARS_AHI_DeviceLogText("Keyboard", LLARS_AHI_KEYBOARD_INFO) . " | Ready=" . (LLARS_AHI_KEYBOARD_READY ? "Yes" : "No") . "`r`n"
    report .= "Last Mouse Transport: " . (LLARS_AHI_LAST_MOUSE_TRANSPORT = "" ? "<none>" : LLARS_AHI_LAST_MOUSE_TRANSPORT) . "`r`n"
    report .= "Last Keyboard Transport: " . (LLARS_AHI_LAST_KEYBOARD_TRANSPORT = "" ? "<none>" : LLARS_AHI_LAST_KEYBOARD_TRANSPORT) . "`r`n"

    report .= "`r`n[Runtime Files]`r`n" . LLARS_AHI_RuntimeFileReport(projectRoot) . "`r`n"

    logDir := LLARS_AHI_LogDir(projectRoot)
    setupTail := LLARS_AHI_ReadTextTail(logDir . "\AutoHotInterception-Setup.log", 45)
    errorTail := LLARS_AHI_ReadTextTail(logDir . "\AutoHotInterception-Setup-Error.txt", 35)
    if (setupTail != "")
        report .= "`r`n[Setup Log - Last 45 Lines]`r`n" . setupTail . "`r`n"
    if (errorTail != "")
        report .= "`r`n[Last Setup Error - Last 35 Lines]`r`n" . errorTail . "`r`n"

    if (LLARS_DeveloperActions != "")
        report .= "`r`n[Recent Developer Actions - Tail]`r`n" . LLARS_AHI_ReadDeveloperTail(LLARS_DeveloperActions, 25) . "`r`n"

    report .= "`r`n[Privacy]`r`nUser/profile/temp/LLARS-root paths and hardware instance handles are redacted where detected.`r`n"
    return LLARS_AHI_SanitizeSupportText(report, projectRoot)
}

LLARS_AHI_ReadDeveloperTail(text, maxLines := 25)
{
    if (text = "")
        return ""
    clean := StrReplace(text, "`r", "")
    lines := StrSplit(clean, "`n")
    total := lines.MaxIndex()
    if (!total)
        return ""
    start := total - maxLines + 1
    if (start < 1)
        start := 1
    output := ""
    Loop, % total - start + 1
    {
        index := start + A_Index - 1
        output .= lines[index] . "`r`n"
    }
    return RTrim(output, "`r`n")
}

LLARS_AHI_WriteSupportReport(projectRoot, trigger := "Manual")
{
    if (projectRoot = "")
        return ""
    LLARS_AHI_CleanupLegacyLogs(projectRoot)
    logDir := LLARS_AHI_LogDir(projectRoot)
    if !FileExist(logDir)
        FileCreateDir, %logDir%
    reportPath := LLARS_AHI_SupportReportPath(projectRoot)
    reportText := LLARS_AHI_BuildSupportReport(projectRoot, trigger)
    FileDelete, %reportPath%
    FileAppend, %reportText%, %reportPath%, UTF-8
    return reportPath
}

LLARS_AHI_CopySupportReport(projectRoot, trigger := "Manual Developer Mode copy")
{
    reportPath := LLARS_AHI_WriteSupportReport(projectRoot, trigger)
    if (reportPath = "")
        return ""
    FileRead, reportText, %reportPath%
    if ErrorLevel
        return ""
    Clipboard := reportText
    ClipWait, 1
    return reportPath
}

LLARS_AHI_SupportHint(projectRoot, trigger := "Failure")
{
    LLARS_AHI_WriteSupportReport(projectRoot, trigger)
    return "Vendor\AutoHotInterception\Logs\AutoHotInterception-Support.txt"
}

LLARS_AHI_ShowRuntimeProblem(projectRoot)
{
    static shown := false
    global LLARS_AHI_STATUS_REASON
    if (shown || projectRoot = "")
        return
    shown := true

    LLARS_AHI_WriteSupportReport(projectRoot, "Runtime initialization unavailable")
    reason := (LLARS_AHI_STATUS_REASON = "") ? "Unknown AutoHotInterception initialization error" : LLARS_AHI_STATUS_REASON
    MsgBox, 48, LLARS Recommended Input Issue, LLARS recommends AutoHotInterception for its mouse and keyboard input.`n`nAutoHotInterception is not fully available, so LLARS is using Standard AutoHotkey fallback for the affected input this run.`n`nStatus: %reason%`n`nA support report was saved automatically at:`nVendor\AutoHotInterception\Logs\AutoHotInterception-Support.txt`n`nIf this continues after restarting LLARS/Windows, open Developer Mode > Copy AHI Report and paste it to Gubna.
}

LLARS_AHI_ReadSetupResult(projectRoot)
{
    resultPath := LLARS_AHI_SetupResultPath(projectRoot)
    if !FileExist(resultPath)
        return ""

    FileRead, resultText, %resultPath%
    FileDelete, %resultPath%
    return Trim(resultText, " `t`r`n")
}

LLARS_AHI_PendingRestart(projectRoot)
{
    return FileExist(projectRoot . "\Vendor\AutoHotInterception\.driver-restart-required") ? true : false
}

LLARS_AHI_UninstallPending(projectRoot)
{
    return FileExist(projectRoot . "\Vendor\AutoHotInterception\.uninstall-reboot-required") ? true : false
}

LLARS_AHI_UninstallStillPending(projectRoot)
{
    marker := projectRoot . "\Vendor\AutoHotInterception\.uninstall-reboot-required"
    if !FileExist(marker)
        return false

    currentBoot := LLARS_AHI_CurrentBootStamp()
    if (currentBoot = "")
        return true

    FileRead, markerText, %marker%
    markerStamp := Trim(markerText, " `t`r`n")

    ; New one-pass uninstall markers store the boot in which /uninstall ran.
    ; The same boot must remain blocked until the one required restart occurs.
    if RegExMatch(markerStamp, "^\d{14}$")
    {
        if (markerStamp = currentBoot)
            return true
        FileDelete, %marker%
        return false
    }

    ; Accept uninstall markers created before the current Windows boot.
    FileGetTime, markerTime, %marker%, M
    if (markerTime != "" && currentBoot > markerTime)
    {
        FileDelete, %marker%
        return false
    }

    return true
}

LLARS_AHI_CurrentBootStamp()
{
    ; A restart requirement must survive every LLARS relaunch in the same Windows
    ; boot. Compare the Windows boot timestamp instead of trusting service state:
    ; Interception can appear registered/running before the reboot that completes
    ; filter activation. WMI is queried only while a restart marker exists.
    try
    {
        wmi := ComObjGet("winmgmts:\\.\root\cimv2")
        for os in wmi.ExecQuery("Select LastBootUpTime from Win32_OperatingSystem")
            return SubStr(os.LastBootUpTime, 1, 14)
    }
    catch e
    {
    }
    return ""
}

LLARS_AHI_MarkPendingRestart(projectRoot)
{
    marker := projectRoot . "\Vendor\AutoHotInterception\.driver-restart-required"
    SplitPath, marker, , markerDir
    if !FileExist(markerDir)
        FileCreateDir, %markerDir%

    bootStamp := LLARS_AHI_CurrentBootStamp()
    FileDelete, %marker%
    FileAppend, %bootStamp%, %marker%
    return true
}

LLARS_AHI_RestartStillPending(projectRoot)
{
    marker := projectRoot . "\Vendor\AutoHotInterception\.driver-restart-required"
    if !FileExist(marker)
        return false

    currentBoot := LLARS_AHI_CurrentBootStamp()
    if (currentBoot = "")
        return true

    FileRead, markerText, %marker%
    markerStamp := Trim(markerText, " `t`r`n")

    ; New markers store the exact boot in which setup completed. A different
    ; boot stamp proves Windows really restarted, so the reminder can clear.
    if RegExMatch(markerStamp, "^\d{14}$")
    {
        if (markerStamp = currentBoot)
            return true
        LLARS_AHI_ClearPendingRestart(projectRoot)
        return false
    }

    ; Accept restart markers created before the current Windows boot.
    FileGetTime, markerTime, %marker%, M
    if (markerTime != "" && currentBoot > markerTime)
    {
        LLARS_AHI_ClearPendingRestart(projectRoot)
        return false
    }

    return true
}

LLARS_AHI_ClearPendingRestart(projectRoot)
{
    marker := projectRoot . "\Vendor\AutoHotInterception\.driver-restart-required"
    if FileExist(marker)
        FileDelete, %marker%
}


LLARS_AHI_RunSetup(projectRoot)
{
    setupPath := LLARS_AHI_SetupScript(projectRoot)
    if !FileExist(setupPath)
        return "MISSING"

    ; Discard any stale handshake left by an interrupted previous setup.
    LLARS_AHI_ClearSetupResult(projectRoot)

    ; IMPORTANT: Do not use AHK's *RunAs as the process we wait on. The
    ; PowerShell bootstrap self-elevates and waits for its elevated child, while
    ; this ordinary PowerShell process remains a reliable synchronization point
    ; for the LLARS process that must show the post-setup restart prompt.
    powershell := A_WinDir . "\System32\WindowsPowerShell\v1.0\powershell.exe"
    command := Chr(34) . powershell . Chr(34)
        . " -NoProfile -ExecutionPolicy Bypass -File " . Chr(34) . setupPath . Chr(34)
        . " -ProjectRoot " . Chr(34) . projectRoot . Chr(34)
    LLARS_AHI_Trace(projectRoot, "Launching bundled input setup")
    RunWait, %command%, %projectRoot%, Hide UseErrorLevel
    setupExitCode := ErrorLevel
    setupLastError := A_LastError
    if (setupExitCode = "ERROR")
    {
        LLARS_AHI_Trace(projectRoot, "Setup bootstrap launch failed; Win32=" . setupLastError)
        return setupLastError
    }
    LLARS_AHI_Trace(projectRoot, "Setup bootstrap exited with code " . setupExitCode)
    return setupExitCode
}


LLARS_AHI_ShowRestartMessage(isReminder := false)
{
    ; 262144 = WS_EX_TOPMOST. Keep both the first prompt and later reminders
    ; visible above LLARS windows.
    if (isReminder)
    {
        restartTitle := "LLARS Restart Still Required"
        restartText := "AutoHotInterception setup is complete, but Windows has not restarted yet."
            . "`n`nRestart Windows now so LLARS can use the recommended input driver?"
            . "`n`nChoose No to restart later. LLARS will keep reminding you until Windows has actually restarted."
    }
    else
    {
        restartTitle := "LLARS Input Setup Complete"
        restartText := "AutoHotInterception was installed successfully."
            . "`n`nWindows must restart once before LLARS can use the recommended input driver."
            . "`n`nRestart Windows now?"
            . "`n`nChoose No to restart later. LLARS will remind you the next time LLARS starts."
    }

    MsgBox, 262180, %restartTitle%, %restartText%
    IfMsgBox, Yes
        Shutdown, 2
}

LLARS_AHI_ShowUninstallRestartMessage()
{
    MsgBox, 0x40024, LLARS AHI Uninstall - Restart Required, AutoHotInterception / Interception was removed successfully.`n`nWindows must restart once to finish unloading the driver.`n`nThere is no second uninstall pass after restart.`n`nRestart Windows now?
    IfMsgBox, Yes
        Shutdown, 2
}

; First-run gate shared by Script Selector and scripts launched directly.
; The only unavoidable user interaction on a fresh PC is Windows elevation for
; the Interception driver and the one reboot required by that driver.
LLARS_AHI_StartupGate(projectRoot, interactive := true)
{
    static gateRan := false
    static gateResult := false

    if (gateRan)
        return gateResult
    gateRan := true

    if (projectRoot = "")
        return false

    ; A successful one-pass uninstall blocks AHI setup only for the remainder
    ; of the current Windows boot. After one real reboot the marker clears.
    if LLARS_AHI_UninstallPending(projectRoot)
    {
        if LLARS_AHI_UninstallStillPending(projectRoot)
        {
            LLARS_AHI_Trace(projectRoot, "Interception uninstall completed; one Windows restart is still required")
            if (interactive)
                LLARS_AHI_ShowUninstallRestartMessage()
            return false
        }
        LLARS_AHI_Trace(projectRoot, "Windows reboot detected after uninstall; uninstall marker cleared")
    }

    ; A full uninstall removes the bundled AHI payload from this LLARS copy.
    ; Treat that as an intentional Standard-AHK configuration, not corruption.
    if FileExist(projectRoot . "\Vendor\AutoHotInterception\.ahi-uninstalled")
        return false

    pendingRestart := LLARS_AHI_PendingRestart(projectRoot)
    if (pendingRestart)
    {
        if LLARS_AHI_RestartStillPending(projectRoot)
        {
            LLARS_AHI_Trace(projectRoot, "Restart reminder active for current Windows boot")
            if (interactive)
                LLARS_AHI_ShowRestartMessage(true)
            return false
        }
        LLARS_AHI_Trace(projectRoot, "Windows reboot detected; restart marker cleared")
    }

    ; The AHI runtime is bundled with LLARS; missing files indicate an incomplete package.
    if !LLARS_AHI_LibraryReady(projectRoot)
    {
        LLARS_AHI_Trace(projectRoot, "Bundled AHI runtime is incomplete; refusing driver changes")
        LLARS_AHI_SupportHint(projectRoot, "Bundled AHI runtime missing")
        if (interactive)
            MsgBox, 48, LLARS Input Files Missing, LLARS is missing one or more bundled AutoHotInterception runtime files.`n`nRe-extract or redownload the complete LLARS package. The Windows driver was not changed.`n`nLLARS will use standard AutoHotkey input for this run.`n`nSupport report: Vendor\AutoHotInterception\Logs\AutoHotInterception-Support.txt
        return false
    }

    ; Remove Windows Mark-of-the-Web from the pinned bundled payload before
    ; any AHI/.NET/native DLL initialization occurs. No elevation is required
    ; for files in a normal extracted LLARS folder.
    fileSecurityReason := ""
    if !LLARS_AHI_PrepareBundledFileSecurity(projectRoot, fileSecurityReason)
    {
        LLARS_AHI_Trace(projectRoot, "Bundled AHI file security preparation failed: " . fileSecurityReason)
        LLARS_AHI_SupportHint(projectRoot, "Bundled AHI file security preparation failed")
        if (interactive)
            MsgBox, 48, LLARS Input Files, LLARS could not prepare the bundled AutoHotInterception files for Windows.`n`nMove or re-extract LLARS to a folder you can write to, then try again.`n`nLLARS will use standard AutoHotkey input for this run.`n`nSupport report: Vendor\AutoHotInterception\Logs\AutoHotInterception-Support.txt
        return false
    }

    ; Fast healthy path. A functional Interception context proves the bundled
    ; runtime can communicate with the installed kernel driver on this boot.
    functionalReason := ""
    if LLARS_AHI_FunctionalReady(projectRoot, functionalReason)
    {
        gateResult := true
        return true
    }

    ; If Windows still has Interception registered but the device interface is
    ; not active, reinstalling the driver is the wrong first response. A reboot
    ; (or support diagnostics if that persists) is safer and preserves state.
    if LLARS_AHI_DriverRegistered()
    {
        LLARS_AHI_Trace(projectRoot, "Interception is registered but not functional: " . functionalReason)
        LLARS_AHI_SupportHint(projectRoot, "Driver registered but not functional: " . functionalReason)
        if (interactive)
            MsgBox, 48, LLARS Input Driver, Interception is installed but is not active on this Windows boot.`n`nRestart Windows once and try LLARS again. If it still does not initialize, open Developer Mode and use Copy AHI Report for Gubna.`n`nLLARS will use standard AutoHotkey input for this run.
        return false
    }

    if (!interactive)
        return false

    setupText := "LLARS strongly recommends AutoHotInterception for reliable mouse and keyboard input."
        . "`n`nRecommended and trusted by Gubna for LLARS."
        . "`nEverything required is already included with LLARS."
        . "`nSetup only installs the Windows Interception driver and needs one Administrator prompt."
        . "`nAfter setup, LLARS will ask you to restart Windows once."
        . "`n`nOK = Install Recommended Input"
        . "`nCancel = Use Standard AutoHotkey Input"
    MsgBox, 49, LLARS Input Setup, %setupText%
    IfMsgBox, Cancel
        return false

    setupResult := LLARS_AHI_RunSetup(projectRoot)
    LLARS_AHI_Trace(projectRoot, "RunSetup returned: " . setupResult)
    if (setupResult = "MISSING")
    {
        LLARS_AHI_SupportHint(projectRoot, "Setup failure: setup tool missing")
        MsgBox, 48, LLARS Input Setup, The LLARS AutoHotInterception setup tool is missing.`n`nRe-extract or redownload LLARS. The Windows driver was not changed.
        return false
    }
    if (setupResult = 1223)
        return false

    pendingRestartAfter := LLARS_AHI_PendingRestart(projectRoot)
    setupState := LLARS_AHI_ReadSetupResult(projectRoot)
    driverRegisteredAfter := LLARS_AHI_DriverRegistered()
    serviceDiagnosticAfter := LLARS_AHI_DriverReady()

    LLARS_AHI_Trace(projectRoot, "Setup state: " . (setupState = "" ? "<empty>" : setupState))
    LLARS_AHI_Trace(projectRoot, "Post-setup: pendingRestart=" . pendingRestartAfter
        . "; registeredDiagnostic=" . driverRegisteredAfter . "; serviceDiagnostic=" . serviceDiagnosticAfter)

    if (setupState = "BUNDLE_ERROR")
    {
        LLARS_AHI_SupportHint(projectRoot, "Setup failure: bundled payload missing/corrupt")
        MsgBox, 48, LLARS Input Setup, LLARS could not verify its bundled AutoHotInterception files.`n`nRe-extract or redownload the complete LLARS package. Nothing was downloaded and the Windows driver was not changed.`n`nSupport report: Vendor\AutoHotInterception\Logs\AutoHotInterception-Support.txt
        return false
    }

    setupFailed := (setupState = "FAILED")
        || (setupResult != 0 && setupResult != 3010 && setupState != "READY" && setupState != "RESTART_REQUIRED")
    setupLooksSuccessful := (setupState = "READY" || setupState = "RESTART_REQUIRED"
        || setupResult = 0 || setupResult = 3010)

    if (setupFailed || !setupLooksSuccessful)
    {
        LLARS_AHI_Trace(projectRoot, "Setup did not report success; no restart prompt")
        LLARS_AHI_SupportHint(projectRoot, "Setup failure: state=" . setupState . "; exit=" . setupResult)
        MsgBox, 48, LLARS Input Setup, AutoHotInterception setup did not complete successfully.`n`nLLARS will use standard AutoHotkey input for this run.`n`nSupport report: Vendor\AutoHotInterception\Logs\AutoHotInterception-Support.txt`nUse Developer Mode > Copy AHI Report to paste the details to Gubna.
        return false
    }

    if (!LLARS_AHI_LibraryReady(projectRoot))
    {
        LLARS_AHI_Trace(projectRoot, "Setup reported success but bundled runtime verification failed")
        LLARS_AHI_SupportHint(projectRoot, "Setup failure: runtime verification")
        MsgBox, 48, LLARS Input Setup, LLARS setup completed, but the bundled AutoHotInterception runtime is incomplete.`n`nRe-extract or redownload LLARS. LLARS will use standard AutoHotkey input for this run.
        return false
    }

    restartRequired := (setupState = "RESTART_REQUIRED" || setupResult = 3010 || pendingRestartAfter)
    if (restartRequired)
    {
        LLARS_AHI_Trace(projectRoot, "Successful driver setup confirmed; restart prompt is mandatory")
        LLARS_AHI_MarkPendingRestart(projectRoot)
        LLARS_AHI_ShowRestartMessage()
        LLARS_AHI_Trace(projectRoot, "Restart prompt returned (user chose restart later or shutdown command returned)")
        return false
    }

    ; No new driver install occurred (eg another process completed it first).
    ; The bundled runtime was already parsed at script startup, so no relaunch is needed.
    gateResult := true
    return true
}

LLARS_AHI_Initialize(projectRoot := "")
{
    global LLARS_AHI_Object, LLARS_AHI_READY
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_INFO, LLARS_AHI_KEYBOARD_INFO, LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL
    global LLARS_AHI_DRIVER_READY, LLARS_AHI_RUNTIME_READY
    global LLARS_AHI_LAST_MOUSE_TRANSPORT, LLARS_AHI_LAST_KEYBOARD_TRANSPORT

    LLARS_AHI_Object := ""
    LLARS_AHI_READY := false
    LLARS_AHI_MOUSE_ID := 0
    LLARS_AHI_KEYBOARD_ID := 0
    LLARS_AHI_MOUSE_READY := false
    LLARS_AHI_KEYBOARD_READY := false
    LLARS_AHI_MOUSE_INFO := ""
    LLARS_AHI_KEYBOARD_INFO := ""
    LLARS_AHI_STATUS_REASON := "Not initialized"
    LLARS_AHI_STATUS_DETAIL := ""
    LLARS_AHI_RUNTIME_READY := LLARS_AHI_LibraryReady(projectRoot)
    LLARS_AHI_DRIVER_READY := false
    LLARS_AHI_LAST_MOUSE_TRANSPORT := "No mouse action yet"
    LLARS_AHI_LAST_KEYBOARD_TRANSPORT := "No keyboard action yet"

    if !LLARS_AHI_RUNTIME_READY
    {
        LLARS_AHI_STATUS_REASON := "AHI runtime files are not installed"
        LLARS_AHI_WriteSupportReport(projectRoot, "Initialization failure: runtime missing")
        return false
    }

    fileSecurityReason := ""
    if !LLARS_AHI_PrepareBundledFileSecurity(projectRoot, fileSecurityReason)
    {
        LLARS_AHI_STATUS_REASON := fileSecurityReason
        LLARS_AHI_WriteSupportReport(projectRoot, "Initialization failure: Windows file security")
        return false
    }

    driverReason := ""
    LLARS_AHI_DRIVER_READY := LLARS_AHI_FunctionalReady(projectRoot, driverReason)
    if !LLARS_AHI_DRIVER_READY
    {
        LLARS_AHI_STATUS_REASON := driverReason
        LLARS_AHI_WriteSupportReport(projectRoot, "Initialization failure: driver interface")
        return false
    }

    try
        LLARS_AHI_Object := new AutoHotInterception()
    catch e
    {
        LLARS_AHI_STATUS_REASON := "AutoHotInterception could not initialize in this LLARS process"
        LLARS_AHI_STATUS_DETAIL := e.Message
        LLARS_AHI_WriteSupportReport(projectRoot, "Initialization failure: AHI constructor")
        return false
    }

    if !IsObject(LLARS_AHI_Object)
    {
        LLARS_AHI_STATUS_REASON := "AutoHotInterception object was not created"
        LLARS_AHI_WriteSupportReport(projectRoot, "Initialization failure: AHI object missing")
        return false
    }

    try
        deviceList := LLARS_AHI_Object.GetDeviceList()
    catch e
    {
        LLARS_AHI_STATUS_REASON := "AutoHotInterception could not read the device list"
        LLARS_AHI_STATUS_DETAIL := e.Message
        LLARS_AHI_WriteSupportReport(projectRoot, "Initialization failure: device enumeration")
        return false
    }

    ; GetDeviceList confirms the higher-level AHI wrapper is also operational.
    LLARS_AHI_DRIVER_READY := true

    ; Choose the first currently connected keyboard and mouse. LLARS only
    ; synthesizes output, so users do not need to run Monitor.ahk or configure
    ; VID/PID/device IDs manually.
    for id, info in deviceList
    {
        if (Trim(info.Handle) = "")
            continue
        numericId := id + 0
        if (info.IsMouse && !LLARS_AHI_MOUSE_ID && numericId >= 11 && numericId <= 20)
        {
            LLARS_AHI_MOUSE_ID := numericId
            LLARS_AHI_MOUSE_INFO := {ID: numericId, VID: info.VID + 0, PID: info.PID + 0, Handle: info.Handle}
        }
        else if (!info.IsMouse && !LLARS_AHI_KEYBOARD_ID && numericId >= 1 && numericId <= 10)
        {
            LLARS_AHI_KEYBOARD_ID := numericId
            LLARS_AHI_KEYBOARD_INFO := {ID: numericId, VID: info.VID + 0, PID: info.PID + 0, Handle: info.Handle}
        }
    }

    LLARS_AHI_MOUSE_READY := (LLARS_AHI_MOUSE_ID >= 11 && LLARS_AHI_MOUSE_ID <= 20)
    LLARS_AHI_KEYBOARD_READY := (LLARS_AHI_KEYBOARD_ID >= 1 && LLARS_AHI_KEYBOARD_ID <= 10)
    LLARS_AHI_READY := (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY)

    if (LLARS_AHI_MOUSE_READY && LLARS_AHI_KEYBOARD_READY)
        LLARS_AHI_STATUS_REASON := "Ready"
    else if (LLARS_AHI_MOUSE_READY)
        LLARS_AHI_STATUS_REASON := "Mouse ready; no Interception keyboard detected"
    else if (LLARS_AHI_KEYBOARD_READY)
        LLARS_AHI_STATUS_REASON := "Keyboard ready; no Interception mouse detected"
    else
        LLARS_AHI_STATUS_REASON := "No connected Interception keyboard or mouse detected"

    ; Healthy startup stays disk-light. Full support reports are generated only
    ; on failures/fallbacks or when the user presses Copy AHI Report.
    if (!LLARS_AHI_READY)
        LLARS_AHI_WriteSupportReport(projectRoot, "Initialization incomplete: no usable devices")
    return LLARS_AHI_READY
}

LLARS_AHI_IsReady(kind := "")
{
    global LLARS_AHI_READY, LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    StringLower, kind, kind
    if (kind = "mouse")
        return LLARS_AHI_MOUSE_READY
    if (kind = "keyboard")
        return LLARS_AHI_KEYBOARD_READY
    return LLARS_AHI_READY
}


LLARS_AHI_ServiceStateText(state)
{
    if (state = 4)
        return "Running"
    if (state = 1)
        return "Stopped"
    if (state = 2)
        return "Starting"
    if (state = 3)
        return "Stopping"
    if (state = 5)
        return "Continuing"
    if (state = 6)
        return "Pausing"
    if (state = 7)
        return "Paused"
    return "Not available"
}

LLARS_AHI_DeviceLogText(kind, info)
{
    if !IsObject(info)
        return kind . "=Not detected"

    text := kind . "=ID " . info.ID
    if (info.VID || info.PID)
        text .= " || VID=" . Format("0x{:04X}", info.VID) . " || PID=" . Format("0x{:04X}", info.PID)
    else if (Trim(info.Handle) != "")
        text .= " || Device=Connected HID"
    return text
}

LLARS_AHI_DeveloperSnapshot(projectRoot := "")
{
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_INFO, LLARS_AHI_KEYBOARD_INFO, LLARS_AHI_STATUS_REASON
    global LLARS_AHI_DRIVER_READY, LLARS_AHI_RUNTIME_READY
    global LLARS_AHI_LAST_MOUSE_TRANSPORT, LLARS_AHI_LAST_KEYBOARD_TRANSPORT

    if (LLARS_AHI_DRIVER_READY)
        driverText := "Interception Running"
    else if (projectRoot != "" && LLARS_AHI_PendingRestart(projectRoot))
        driverText := "Interception Restart Required"
    else
        driverText := "Interception Not Running"

    runtimeText := LLARS_AHI_RUNTIME_READY ? "AHI Runtime Ready" : "AHI Runtime Missing"

    if (LLARS_AHI_MOUSE_READY)
        mouseRoute := "AHI Device " . LLARS_AHI_MOUSE_ID
    else
        mouseRoute := "Standard AutoHotkey"

    if (LLARS_AHI_KEYBOARD_READY)
        keyboardRoute := "AHI Device " . LLARS_AHI_KEYBOARD_ID
    else
        keyboardRoute := "Standard AutoHotkey"

    if (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY)
        engineText := "AutoHotInterception"
    else
        engineText := "Standard AutoHotkey"

    if (LLARS_AHI_STATUS_REASON != "" && LLARS_AHI_STATUS_REASON != "Ready")
        statusText := LLARS_AHI_STATUS_REASON
    else
        statusText := "Ready"

    signature := engineText . "`n" . driverText . "`n" . runtimeText . "`n"
        . mouseRoute . "`n" . keyboardRoute . "`n"
        . LLARS_AHI_LAST_MOUSE_TRANSPORT . "`n" . LLARS_AHI_LAST_KEYBOARD_TRANSPORT . "`n" . statusText

    return {Engine:engineText
        , Driver:driverText
        , Runtime:runtimeText
        , MouseRoute:mouseRoute
        , KeyboardRoute:keyboardRoute
        , MouseLast:LLARS_AHI_LAST_MOUSE_TRANSPORT
        , KeyboardLast:LLARS_AHI_LAST_KEYBOARD_TRANSPORT
        , Status:statusText
        , Signature:signature}
}

LLARS_AHI_DeveloperDisplay(projectRoot := "")
{
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY

    status := LLARS_AHI_DeveloperSnapshot(projectRoot)
    if (status.Driver = "Interception Running")
        driverDisplay := "Driver Running"
    else if (status.Driver = "Interception Restart Required")
        driverDisplay := "Restart Required"
    else
        driverDisplay := "Driver Not Running"

    text := status.Engine . " | " . driverDisplay
    if (LLARS_AHI_MOUSE_READY)
        text .= " | Mouse " . LLARS_AHI_MOUSE_ID
    if (LLARS_AHI_KEYBOARD_READY)
        text .= " | Keyboard " . LLARS_AHI_KEYBOARD_ID
    if (status.Runtime != "AHI Runtime Ready")
        text .= " | Runtime Missing"
    return text
}

LLARS_AHI_RecordTransport(kind, text)
{
    global LLARS_AHI_LAST_MOUSE_TRANSPORT, LLARS_AHI_LAST_KEYBOARD_TRANSPORT
    StringLower, kind, kind
    if (kind = "mouse")
        LLARS_AHI_LAST_MOUSE_TRANSPORT := text
    else if (kind = "keyboard")
        LLARS_AHI_LAST_KEYBOARD_TRANSPORT := text
}

; Sends an optional diagnostic to LLARS Developer Mode without creating a
; hard parse-time dependency. Entry points such as Script Selector load AHI
; without loading LLARS_Core.ahk, so direct calls to LLARS_DeveloperAction()
; are intentionally avoided here.
LLARS_AHI_DeveloperAction(text)
{
    if !IsFunc("LLARS_DeveloperAction")
        return false

    developerAction := Func("LLARS_DeveloperAction")
    developerAction.Call(text)
    return true
}

; Writes the selected LLARS input backend into the existing Developer log.
; Called after LLARS initializes its Developer Action history so the startup
; diagnostic remains visible instead of being cleared immediately afterward.
LLARS_AHI_LogDeveloperStatus(projectRoot)
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_INFO, LLARS_AHI_KEYBOARD_INFO, LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL
    global LLARS_AHI_DRIVER_READY

    mouseBackend := LLARS_AHI_MOUSE_READY ? "AutoHotInterception (ID " . LLARS_AHI_MOUSE_ID . ")" : "Standard AutoHotkey"
    keyboardBackend := LLARS_AHI_KEYBOARD_READY ? "AutoHotInterception (ID " . LLARS_AHI_KEYBOARD_ID . ")" : "Standard AutoHotkey"
    LLARS_AHI_DeveloperAction("Input Backend || Mouse=" . mouseBackend . " || Keyboard=" . keyboardBackend)
    LLARS_AHI_DeveloperAction("Mouse Behavior || Original LLARS NaturalClick movement and timing preserved || Sent through AutoHotInterception")

    keyboardState := LLARS_AHI_ServiceStateText(LLARS_AHI_ServiceState("keyboard"))
    mouseState := LLARS_AHI_ServiceStateText(LLARS_AHI_ServiceState("mouse"))
    libraryState := LLARS_AHI_LibraryReady(projectRoot) ? "Ready" : "Missing"
    ahiState := IsObject(LLARS_AHI_Object) ? "Initialized" : "Not initialized"
    LLARS_AHI_DeveloperAction("Interception || Functional=" . (LLARS_AHI_DRIVER_READY ? "Ready" : "Not ready")
        . " || AHI Runtime=" . libraryState . " || AHI=" . ahiState
        . " || Service diag K=" . keyboardState . " M=" . mouseState)

    if (LLARS_AHI_MOUSE_READY)
        LLARS_AHI_DeveloperAction("AHI Device || " . LLARS_AHI_DeviceLogText("Mouse", LLARS_AHI_MOUSE_INFO))
    if (LLARS_AHI_KEYBOARD_READY)
        LLARS_AHI_DeveloperAction("AHI Device || " . LLARS_AHI_DeviceLogText("Keyboard", LLARS_AHI_KEYBOARD_INFO))

    if (LLARS_AHI_STATUS_REASON != "" && LLARS_AHI_STATUS_REASON != "Ready")
        LLARS_AHI_DeveloperAction("AHI Status || " . LLARS_AHI_STATUS_REASON)
    if (LLARS_AHI_STATUS_DETAIL != "")
        LLARS_AHI_DeveloperAction("AHI Detail || " . LLARS_AHI_STATUS_DETAIL)

    ; Do not generate the full support report on a healthy normal launch.
    ; Copy AHI Report regenerates it live; failures still write it automatically.
}

LLARS_AHI_LogRuntimeFallback(kind, reason, detail := "")
{
    static logged := {}
    global LLARS_AHI_READY, LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL, LLARS_ROOT

    LLARS_AHI_READY := (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY)
    LLARS_AHI_STATUS_REASON := kind . " AHI transport failed; using Standard AutoHotkey fallback"
    LLARS_AHI_STATUS_DETAIL := detail
    LLARS_AHI_RecordTransport(kind, "Fallback AHK | " . reason)
    key := kind . "|" . reason
    if logged.HasKey(key)
        return
    logged[key] := true

    LLARS_AHI_DeveloperAction("Input Backend || " . kind . " AHI failed || Fallback=Standard AutoHotkey || " . reason)
    if (LLARS_ROOT != "")
    {
        LLARS_AHI_WriteSupportReport(LLARS_ROOT, "Runtime fallback: " . kind . " - " . reason)
        LLARS_AHI_DeveloperAction("AHI Support || Report updated || Vendor\AutoHotInterception\Logs\AutoHotInterception-Support.txt")
    }
}

; Converts the active window's client coordinate to an Interception absolute
; coordinate on the primary display. NaturalClick already owns the trajectory
; and cadence, so AHI must only transport each point -- never generate a second
; movement path of its own.
LLARS_AHI_ClientPointToAbsolute(x, y, ByRef absoluteX, ByRef absoluteY)
{
    hwnd := DllCall("GetForegroundWindow", "Ptr")
    if (!hwnd)
        return false

    VarSetCapacity(point, 8, 0)
    NumPut(Round(x), point, 0, "Int")
    NumPut(Round(y), point, 4, "Int")
    if !DllCall("ClientToScreen", "Ptr", hwnd, "Ptr", &point)
        return false

    screenX := NumGet(point, 0, "Int")
    screenY := NumGet(point, 4, "Int")
    screenWidth := A_ScreenWidth + 0
    screenHeight := A_ScreenHeight + 0
    if (screenWidth <= 1 || screenHeight <= 1)
        return false

    ; AHI's SendMouseMoveAbsolute uses the normal Interception absolute range
    ; (0..65535) for the primary display. If the active client is on another
    ; monitor, preserve the original LLARS MouseMove instead of mis-targeting.
    if (screenX < 0 || screenY < 0 || screenX >= screenWidth || screenY >= screenHeight)
        return false

    ; Windows absolute mouse input uses a 0..65535 normalized space. Using
    ; 65536/size with an upward round matches the pixel mapping used by mature
    ; Windows input implementations and avoids the common one-pixel drift.
    absoluteX := Ceil(screenX * (65536.0 / screenWidth))
    absoluteY := Ceil(screenY * (65536.0 / screenHeight))
    if (absoluteX < 1)
        absoluteX := 1
    else if (absoluteX > 65535)
        absoluteX := 65535
    if (absoluteY < 1)
        absoluteY := 1
    else if (absoluteY > 65535)
        absoluteY := 65535
    return true
}

; Shared mouse movement backend.
;
; Fidelity rule:
;   * speed=0 is LLARS' own NaturalClick/curve transport. Send exactly one AHI
;     absolute stroke for each point LLARS already calculated.
;   * omitted/nonzero speed keeps AutoHotkey's native MouseMove speed behavior.
;     Keep that original behavior exactly rather than silently changing its
;     speed/profile while adding AHI.
LLARS_InputMouseMove(x, y, speed := "")
{
    static absoluteTransportFailed := false
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_MOUSE_READY
    global LLARS_AHI_STATUS_DETAIL

    if (speed = "" || speed != 0)
    {
        if (speed = "")
            MouseMove, %x%, %y%
        else
            MouseMove, %x%, %y%, %speed%
        LLARS_AHI_RecordTransport("mouse", "Original AHK Move | " . (speed = "" ? "Default speed" : "Speed=" . speed))
        return true
    }

    if (!absoluteTransportFailed && LLARS_AHI_MOUSE_READY && IsObject(LLARS_AHI_Object))
    {
        if LLARS_AHI_ClientPointToAbsolute(x, y, absoluteX, absoluteY)
        {
            try
            {
                ; Send one absolute stroke for each point already calculated by LLARS.
                LLARS_AHI_Object.SendMouseMoveAbsolute(LLARS_AHI_MOUSE_ID, absoluteX, absoluteY)
                LLARS_AHI_RecordTransport("mouse", "AHI Absolute Move | #" . LLARS_AHI_MOUSE_ID)
                return true
            }
            catch e
            {
                ; A movement failure falls back without disabling AHI mouse buttons.
                absoluteTransportFailed := true
                LLARS_AHI_STATUS_DETAIL := e.Message
                LLARS_AHI_DeveloperAction("Input Backend || AHI absolute movement failed || Fallback=Original LLARS MouseMove")
            }
        }
        else
        {
            ; AHI absolute synthesis is primary-monitor based. Preserve the
            ; original LLARS movement on secondary-monitor/client layouts.
            LLARS_AHI_RecordTransport("mouse", "Original AHK Move | AHI absolute unavailable for this display")
        }
    }

    MouseMove, %x%, %y%, 0
    LLARS_AHI_RecordTransport("mouse", "Original AHK Move | Speed=0 fallback")
    return true
}

LLARS_InputMouseButton(button := "left", state := 1)
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_MOUSE_READY

    button := Trim(button)
    StringLower, button, button
    if (button = "left")
        code := 0
    else if (button = "right")
        code := 1
    else if (button = "middle")
        code := 2
    else if (button = "xbutton1")
        code := 3
    else if (button = "xbutton2")
        code := 4
    else
        return false

    if (LLARS_AHI_MOUSE_READY && IsObject(LLARS_AHI_Object))
    {
        try
        {
            LLARS_AHI_Object.SendMouseButtonEvent(LLARS_AHI_MOUSE_ID, code, state ? 1 : 0)
            LLARS_AHI_RecordTransport("mouse", "AHI " . button . (state ? " down" : " up") . " | #" . LLARS_AHI_MOUSE_ID)
            return true
        }
        catch e
        {
            LLARS_AHI_MOUSE_READY := false
            LLARS_AHI_LogRuntimeFallback("Mouse", "Button transport error", e.Message)
        }
    }

    if (button = "right")
    {
        if (state)
            Click, Right Down
        else
            Click, Right Up
    }
    else if (button = "middle")
    {
        if (state)
            Click, Middle Down
        else
            Click, Middle Up
    }
    else if (button = "xbutton1")
    {
        if (state)
            Click, X1 Down
        else
            Click, X1 Up
    }
    else if (button = "xbutton2")
    {
        if (state)
            Click, X2 Down
        else
            Click, X2 Up
    }
    else
    {
        if (state)
            Click, Down
        else
            Click, Up
    }
    LLARS_AHI_RecordTransport("mouse", "Standard AHK " . button . (state ? " down" : " up"))
    return true
}

LLARS_AHI_SendWheel(keyName)
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_MOUSE_READY
    if (!LLARS_AHI_MOUSE_READY || !IsObject(LLARS_AHI_Object))
        return false

    keyName := Trim(keyName)
    StringLower, keyName, keyName
    if (keyName = "wheelup")
        code := 5, state := 1
    else if (keyName = "wheeldown")
        code := 5, state := -1
    else if (keyName = "wheelright")
        code := 6, state := 1
    else if (keyName = "wheelleft")
        code := 6, state := -1
    else
        return false

    try
    {
        LLARS_AHI_Object.SendMouseButtonEvent(LLARS_AHI_MOUSE_ID, code, state)
        LLARS_AHI_RecordTransport("mouse", "AHI " . keyName . " | #" . LLARS_AHI_MOUSE_ID)
        return true
    }
    catch e
    {
        LLARS_AHI_MOUSE_READY := false
        LLARS_AHI_LogRuntimeFallback("Mouse", "Wheel transport error", e.Message)
        return false
    }
}

LLARS_AHI_ModifierKey(symbol, side := "")
{
    if (symbol = "^")
        return (side = ">") ? "RControl" : "LControl"
    if (symbol = "!")
        return (side = ">") ? "RAlt" : "LAlt"
    if (symbol = "+")
        return (side = ">") ? "RShift" : "LShift"
    if (symbol = "#")
        return (side = ">") ? "RWin" : "LWin"
    return ""
}

LLARS_AHI_ParseModifiers(prefix, ByRef modifierKeys)
{
    modifierKeys := []
    pos := 1
    length := StrLen(prefix)
    while (pos <= length)
    {
        side := ""
        ch := SubStr(prefix, pos, 1)
        if (ch = "<" || ch = ">")
        {
            side := ch
            pos++
            if (pos > length)
                return false
            ch := SubStr(prefix, pos, 1)
        }

        keyName := LLARS_AHI_ModifierKey(ch, side)
        if (keyName = "")
            return false
        modifierKeys.Push(keyName)
        pos++
    }
    return true
}

LLARS_AHI_KeyScanCode(keyName)
{
    scanCode := GetKeySC(keyName)
    if (!scanCode)
        return 0
    return scanCode
}

LLARS_AHI_SendKeyState(keyName, state)
{
    global LLARS_AHI_Object, LLARS_AHI_KEYBOARD_ID, LLARS_AHI_KEYBOARD_READY
    if (!LLARS_AHI_KEYBOARD_READY || !IsObject(LLARS_AHI_Object))
        return false

    scanCode := LLARS_AHI_KeyScanCode(keyName)
    if (!scanCode)
        return false

    try
    {
        LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, scanCode, state ? 1 : 0)
        LLARS_AHI_RecordTransport("keyboard", "AHI " . keyName . (state ? " down" : " up") . " | #" . LLARS_AHI_KEYBOARD_ID)
        return true
    }
    catch e
    {
        LLARS_AHI_KEYBOARD_READY := false
        LLARS_AHI_LogRuntimeFallback("Keyboard", "Key transport error", e.Message)
        return false
    }
}

; Handles the exact send forms emitted by the public creator API:
;   {Space}, {Esc}, {Key down}, {Key up}, ^+{Key}, etc.
; Raw text and any unfamiliar send form intentionally return false so the
; existing SendEvent path remains a safe compatibility fallback.
LLARS_AHI_SendSequence(sendSequence, keyHold := 60, keyDelay := 20)
{
    global LLARS_AHI_Object, LLARS_AHI_KEYBOARD_ID, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_LAST_KEY_HOLD_MS

    LLARS_AHI_LAST_KEY_HOLD_MS := ""

    if (SubStr(sendSequence, 1, 5) = "{Raw}")
        return false

    if RegExMatch(sendSequence, "i)^\{([^{}]+)\s+(down|up)\}$", stateMatch)
    {
        stateKey := Trim(stateMatch1)
        stateDirection := stateMatch2
        StringLower, stateDirection, stateDirection
        return LLARS_AHI_SendKeyState(stateKey, stateDirection = "down")
    }

    if !RegExMatch(sendSequence, "^([^{}]*)\{([^{}]+)\}$", match)
        return false

    prefix := match1
    keyName := Trim(match2)
    if (keyName = "")
        return false

    if keyName in WheelUp,WheelDown,WheelLeft,WheelRight
        return LLARS_AHI_SendWheel(keyName)

    if (!LLARS_AHI_KEYBOARD_READY || !IsObject(LLARS_AHI_Object))
        return false

    if !LLARS_AHI_ParseModifiers(prefix, modifierKeys)
        return false

    baseScan := LLARS_AHI_KeyScanCode(keyName)
    if (!baseScan)
        return false

    modifierScans := []
    for _, modifierKey in modifierKeys
    {
        modifierScan := LLARS_AHI_KeyScanCode(modifierKey)
        if (!modifierScan)
            return false
        modifierScans.Push(modifierScan)
    }

    try
    {
        for _, modifierScan in modifierScans
        {
            LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, modifierScan, 1)
            if (keyDelay > 0)
                Sleep, %keyDelay%
        }

        DllCall("QueryPerformanceFrequency", "Int64*", keyHoldPerformanceFrequency)
        DllCall("QueryPerformanceCounter", "Int64*", keyHoldStartCounter)
        LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, baseScan, 1)
        if (keyHold > 0)
            Sleep, %keyHold%
        LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, baseScan, 0)
        DllCall("QueryPerformanceCounter", "Int64*", keyHoldEndCounter)
        if (keyHoldPerformanceFrequency > 0)
            LLARS_AHI_LAST_KEY_HOLD_MS := Round(((keyHoldEndCounter - keyHoldStartCounter) * 1000.0) / keyHoldPerformanceFrequency)
        else
            LLARS_AHI_LAST_KEY_HOLD_MS := keyHold

        index := modifierScans.MaxIndex()
        while (index >= 1)
        {
            if (keyDelay > 0)
                Sleep, %keyDelay%
            LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, modifierScans[index], 0)
            index--
        }
        LLARS_AHI_RecordTransport("keyboard", "AHI " . sendSequence . " | #" . LLARS_AHI_KEYBOARD_ID)
        return true
    }
    catch e
    {
        ; Release the base key and any modifiers that may have gone down before
        ; falling back, so a transport failure cannot leave a key held.
        try LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, baseScan, 0)
        index := modifierScans.MaxIndex()
        while (index >= 1)
        {
            try LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, modifierScans[index], 0)
            index--
        }
        LLARS_AHI_KEYBOARD_READY := false
        LLARS_AHI_LogRuntimeFallback("Keyboard", "Sequence transport error", e.Message)
        return false
    }
}
