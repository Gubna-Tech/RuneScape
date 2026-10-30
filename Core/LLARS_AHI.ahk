; ================================================================
; |     LLARS AUTOHOTINTERCEPTION     -     INPUT BACKEND           |
; ================================================================
;
; LLARS uses AutoHotInterception for input synthesis and non-blocking device
; lifecycle subscriptions. Physical keyboard/mouse input is observed only for
; lifecycle awareness; LLARS independently chooses the most reliable connected
; AHI transport carriers and never blocks physical input.

; Shared timing ownership lives in LLARS_Timing.ahk.

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

LLARS_AHI_ConfigPath(projectRoot := "")
{
    if (projectRoot = "")
        return ""
    return projectRoot . "\LLARS Config.ini"
}

LLARS_AHI_Mode(projectRoot := "")
{
    configPath := LLARS_AHI_ConfigPath(projectRoot)
    if (configPath = "" || !FileExist(configPath))
        return "ahi"

    mode := LLARS_ConfigReadFile(configPath, "Input Backend", "mode", "ahi")
    mode := Trim(mode)
    StringLower, mode, mode
    return (mode = "standard") ? "standard" : "ahi"
}

LLARS_AHI_SetMode(projectRoot, mode)
{
    configPath := LLARS_AHI_ConfigPath(projectRoot)
    if (configPath = "")
        return false

    StringLower, mode, mode
    mode := (mode = "ahi") ? "ahi" : "standard"
    return LLARS_ConfigWriteFile(configPath, "Input Backend", "mode", mode)
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

LLARS_AHI_DriverPresent()
{
    keyboardClass := "{4D36E96B-E325-11CE-BFC1-08002BE10318}"
    mouseClass := "{4D36E96F-E325-11CE-BFC1-08002BE10318}"
    return (LLARS_AHI_RegistryFilterPresent(keyboardClass, "keyboard")
        || LLARS_AHI_RegistryFilterPresent(mouseClass, "mouse")
        || LLARS_AHI_RegistryServicePresent("keyboard")
        || LLARS_AHI_RegistryServicePresent("mouse"))
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
    return projectRoot . "\Logs"
}

LLARS_AHI_CleanupLegacyLogs(projectRoot)
{
    if (projectRoot = "")
        return

    ; Runtime/support output belongs under the LLARS root Logs directory.
    ; Move legacy AHI-specific Vendor logs there on first use.
    legacyDir := projectRoot . "\Vendor\AutoHotInterception\Logs"
    if !FileExist(legacyDir)
        return

    logDir := LLARS_AHI_LogDir(projectRoot)
    if !FileExist(logDir)
        FileCreateDir, %logDir%

    legacyPattern := legacyDir . "\*"
    Loop, Files, %legacyPattern%, F
        FileMove, %A_LoopFileFullPath%, % logDir . "\" . A_LoopFileName, 1

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
    return LLARS_AHI_LogDir(projectRoot) . "\LLARS-Support.txt"
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
    global LLARS_AHI_HELD_KEYS, LLARS_AHI_HELD_MOUSE, LLARS_AHI_EXIT_REGISTERED
    global LLARS_AHI_MOUSE_SUBSCRIBED_ID, LLARS_AHI_KEYBOARD_SUBSCRIBED_ID
    global LLARS_AHI_MOUSE_ACTIVITY_ID, LLARS_AHI_MOUSE_ROUTE_VERIFIED
    global LLARS_AHI_MOUSE_PREFERRED_ID, LLARS_AHI_MOUSE_PREFERRED_INFO, LLARS_AHI_MOUSE_ALTERNATE_ACTIVE
    global LLARS_AHI_MOUSE_LAST_SEEN, LLARS_AHI_KEYBOARD_LAST_SEEN
    global LLARS_AHI_MOUSE_EVENT_COUNT, LLARS_AHI_KEYBOARD_EVENT_COUNT
    global LLARS_AHI_REBIND_COUNT, LLARS_AHI_LAST_REBIND
    global LLARS_DeveloperActions
    global LLARS_RUNNING, LLARS_PAUSED, LLARS_RUN_TYPE, LLARS_RunStartTick
    global LLARS_CONFIG_READY, LLARS_CONFIG_MISSING_COUNT, LLARS_DISABLE_SCRIPT_CONFIG

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
    mode := LLARS_AHI_Mode(projectRoot)
    if (mode = "ahi")
        engineState := (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY) ? "AutoHotInterception" : "AutoHotInterception (route unavailable)"
    else
        engineState := "Standard AutoHotkey"

    llarsVersion := LLARS_GetVersion(projectRoot)
    runState := LLARS_RUNNING ? (LLARS_PAUSED ? "Paused" : "Running") : "Idle"
    runType := (LLARS_RUN_TYPE = "" ? "Not Started" : LLARS_RUN_TYPE)
    if (LLARS_RUNNING && LLARS_RunStartTick > 0)
        runElapsed := Round((LLARS_NowMS() - LLARS_RunStartTick) / 1000) . " s"
    else
        runElapsed := "--"
    if (LLARS_DISABLE_SCRIPT_CONFIG)
        configState := "Not Required"
    else if (LLARS_CONFIG_READY = "")
        configState := "Unknown"
    else
        configState := LLARS_CONFIG_READY ? "Ready" : "Needs configuration"

    diagnosticText := "Warnings=0 | Errors=0 | Recoveries=0 | Last=None"
    if IsFunc("LLARS_DiagnosticSnapshot")
    {
        diagnosticFn := Func("LLARS_DiagnosticSnapshot")
        diagnosticState := diagnosticFn.Call()
        if IsObject(diagnosticState)
            diagnosticText := "Warnings=" . diagnosticState.Warnings . " | Errors=" . diagnosticState.Errors . " | Recoveries=" . diagnosticState.Recoveries . " | Last=" . diagnosticState.Last
    }

    report := "LLARS Support Report`r`n"
    report .= "Report Version: 2`r`n"
    report .= "Generated: " . reportTime . "`r`n"
    report .= "Trigger: " . trigger . "`r`n"
    report .= "Entry Point: " . A_ScriptName . "`r`n"
    report .= "`r`n[LLARS State]`r`n"
    report .= "Version: v" . llarsVersion . "`r`n"
    report .= "Run State: " . runState . " | Type=" . runType . " | Elapsed=" . runElapsed . "`r`n"
    report .= "Configuration: " . configState . " | Missing=" . (LLARS_CONFIG_MISSING_COUNT + 0) . "`r`n"
    report .= "Diagnostics: " . diagnosticText . "`r`n"
    detectionText := "None"
    if IsFunc("LLARS_DetectionDisplay")
        detectionText := Func("LLARS_DetectionDisplay").Call(false)
    report .= "Detection: " . detectionText . "`r`n"
    report .= "`r`n[Environment]`r`n"
    report .= "AutoHotkey: " . A_AhkVersion . " | " . (A_PtrSize = 8 ? "64-bit" : "32-bit") . " | Unicode=" . (A_IsUnicode ? "Yes" : "No") . "`r`n"
    report .= "Windows: " . A_OSVersion . " | DisplayVersion=" . windowsDisplay . " | Build=" . windowsBuild . " | OS=" . (A_Is64bitOS ? "64-bit" : "32-bit") . "`r`n"
    report .= "LLARS process elevated: " . (A_IsAdmin ? "Yes" : "No") . "`r`n"

    report .= "`r`n[Input / AHI Status]`r`n"
    report .= "Input Engine: " . engineState . "`r`n"
    report .= "Mouse behavior: LLARS keeps its original NaturalClick movement and timing; AHI mode keeps mouse transport on AutoHotInterception across the Windows virtual desktop.`r`n"
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
    report .= "Subscriptions: Mouse buttons=" . LLARS_AHI_MouseSubscriptionText()
        . " | Keyboard=" . (LLARS_AHI_KEYBOARD_SUBSCRIBED_ID ? "AHI #" . LLARS_AHI_KEYBOARD_SUBSCRIBED_ID : "Off") . " | Blocking=No`r`n"
    activeMouseRole := LLARS_AHI_MOUSE_ALTERNATE_ACTIVE ? "Stable transport (separate physical pointer)" : "Stable AHI transport"
    report .= "Active mouse route: " . (LLARS_AHI_MOUSE_ID ? "AHI #" . LLARS_AHI_MOUSE_ID : "Unavailable") . " | Role=" . activeMouseRole . "`r`n"
    report .= "Transport reliability: Mouse=" . LLARS_AHI_DeviceReliabilityText(LLARS_AHI_MOUSE_INFO, true)
        . " | Keyboard=" . LLARS_AHI_DeviceReliabilityText(LLARS_AHI_KEYBOARD_INFO, false) . "`r`n"
    if LLARS_AHI_MOUSE_ROUTE_VERIFIED
        physicalMouseRoute := "Learned AHI #" . LLARS_AHI_MOUSE_PREFERRED_ID
    else if LLARS_AHI_MOUSE_ID
        physicalMouseRoute := "Awaiting physical click; output AHI #" . LLARS_AHI_MOUSE_ID
    else
        physicalMouseRoute := "No mouse route"
    if (LLARS_AHI_MOUSE_ACTIVITY_ID)
        physicalMouseRoute .= " | Last event AHI #" . LLARS_AHI_MOUSE_ACTIVITY_ID
    report .= "Physical mouse route: " . physicalMouseRoute . "`r`n"
    report .= "Physical events observed: Mouse=" . (LLARS_AHI_MOUSE_EVENT_COUNT + 0) . " | Keyboard=" . (LLARS_AHI_KEYBOARD_EVENT_COUNT + 0) . "`r`n"
    report .= "Last physical activity: Mouse=" . LLARS_AHI_TickAgeText(LLARS_AHI_MOUSE_LAST_SEEN)
        . " | Keyboard=" . LLARS_AHI_TickAgeText(LLARS_AHI_KEYBOARD_LAST_SEEN) . "`r`n"
    report .= "AHI route rebinds: " . (LLARS_AHI_REBIND_COUNT + 0) . " | Last=" . (LLARS_AHI_LAST_REBIND = "" ? "None" : LLARS_AHI_LAST_REBIND) . "`r`n"

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
    return "Logs\LLARS-Support.txt"
}

LLARS_AHI_ShowRuntimeProblem(projectRoot)
{
    static shown := false
    global LLARS_AHI_STATUS_REASON
    if (shown || projectRoot = "")
        return
    shown := true

    reason := (LLARS_AHI_STATUS_REASON = "") ? "Unknown AutoHotInterception initialization error" : LLARS_AHI_STATUS_REASON
    if IsFunc("LLARS_DiagnosticRecord")
    {
        diagnosticFn := Func("LLARS_DiagnosticRecord")
        diagnosticFn.Call("Warning", "AHI fallback active", reason)
    }
    LLARS_AHI_WriteSupportReport(projectRoot, "Runtime initialization unavailable")
    MsgBox, 0x40030, LLARS AHI Issue, AutoHotInterception is selected as the recommended input backend, but it is not fully available.`n`nLLARS is using Standard AutoHotkey fallback for the affected input this run.`n`nStatus: %reason%`n`nA support report was saved automatically at:`nLogs\LLARS-Support.txt`n`nIf this continues after restarting LLARS/Windows, open Developer Mode > Copy Support Report and paste it to Gubna.
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


LLARS_AHI_RunUninstall(projectRoot)
{
    setupPath := LLARS_AHI_SetupScript(projectRoot)
    if !FileExist(setupPath)
        return "MISSING"

    powershell := A_WinDir . "\System32\WindowsPowerShell\v1.0\powershell.exe"
    command := Chr(34) . powershell . Chr(34)
        . " -NoProfile -ExecutionPolicy Bypass -File " . Chr(34) . setupPath . Chr(34)
        . " -ProjectRoot " . Chr(34) . projectRoot . Chr(34)
        . " -Uninstall"
    LLARS_AHI_Trace(projectRoot, "Launching bundled input-driver uninstall")
    RunWait, %command%, %projectRoot%, Hide UseErrorLevel
    uninstallExitCode := ErrorLevel
    uninstallLastError := A_LastError
    if (uninstallExitCode = "ERROR")
    {
        LLARS_AHI_Trace(projectRoot, "Uninstall bootstrap launch failed; Win32=" . uninstallLastError)
        return uninstallLastError
    }
    LLARS_AHI_Trace(projectRoot, "Uninstall bootstrap exited with code " . uninstallExitCode)
    return uninstallExitCode
}

LLARS_AHI_DisableForProcess(reason := "Standard AutoHotkey fallback selected")
{
    global LLARS_AHI_Object, LLARS_AHI_READY, LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY, LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL
    global LLARS_AHI_DRIVER_READY, LLARS_AHI_LAST_MOUSE_TRANSPORT, LLARS_AHI_LAST_KEYBOARD_TRANSPORT

    if IsFunc("LLARS_AHI_ReleaseAllInput")
        LLARS_AHI_ReleaseAllInput()
    if IsFunc("LLARS_AHI_StopDeviceWatchdog")
        LLARS_AHI_StopDeviceWatchdog()
    if IsFunc("LLARS_AHI_UnsubscribeLifecycle")
        LLARS_AHI_UnsubscribeLifecycle()
    if (IsObject(LLARS_AHI_Object))
    {
        try LLARS_AHI_Object.Instance.Dispose()
    }
    if IsFunc("LLARS_AHI_NativeTransportDispose")
        LLARS_AHI_NativeTransportDispose()

    LLARS_AHI_Object := ""
    LLARS_AHI_READY := false
    LLARS_AHI_MOUSE_ID := 0
    LLARS_AHI_KEYBOARD_ID := 0
    LLARS_AHI_MOUSE_READY := false
    LLARS_AHI_KEYBOARD_READY := false
    LLARS_AHI_DRIVER_READY := false
    LLARS_AHI_STATUS_REASON := reason
    LLARS_AHI_STATUS_DETAIL := ""
    LLARS_AHI_LAST_MOUSE_TRANSPORT := "Standard AutoHotkey fallback"
    LLARS_AHI_LAST_KEYBOARD_TRANSPORT := "Standard AutoHotkey fallback"
    return true
}

LLARS_AHI_RequestUninstall(projectRoot, interactive := true, reinstallAfter := false)
{
    previousMode := LLARS_AHI_Mode(projectRoot)
    LLARS_AHI_DisableForProcess("AHI uninstall requested")

    result := LLARS_AHI_RunUninstall(projectRoot)
    if (result = "MISSING")
    {
        LLARS_AHI_SetMode(projectRoot, previousMode)
        if (interactive)
            MsgBox, 0x40030, LLARS Input Driver, The LLARS Interception uninstall tool is missing.`n`nRe-extract the complete LLARS package before trying again.
        return false
    }
    if (result = 1223)
    {
        LLARS_AHI_SetMode(projectRoot, previousMode)
        return false
    }
    if (result = 0 || result = 3010)
    {
        LLARS_AHI_SetMode(projectRoot, reinstallAfter ? "ahi" : "standard")
        if (interactive)
            LLARS_AHI_ShowUninstallRestartMessage(reinstallAfter)
        return true
    }

    LLARS_AHI_SetMode(projectRoot, previousMode)
    LLARS_AHI_SupportHint(projectRoot, "Interception uninstall failed; exit=" . result)
    if (interactive)
        MsgBox, 0x40030, LLARS Input Driver, LLARS could not verify that Interception was removed.`n`nDo not manually delete keyboard.sys or mouse.sys.`n`nUse Developer Mode > Copy Support Report for troubleshooting.
    return false
}

LLARS_AHI_FallbackModeCheck(projectRoot, interactive := true)
{
    if (projectRoot = "")
        return false

    ; Standard AutoHotkey is retained as a fallback choice. The only startup
    ; action required here is completing an uninstall that already succeeded.
    if LLARS_AHI_UninstallPending(projectRoot)
    {
        if LLARS_AHI_UninstallStillPending(projectRoot)
        {
            if (interactive)
                LLARS_AHI_ShowUninstallRestartMessage(false)
            return false
        }
    }
    return true
}

LLARS_AHI_Enable(projectRoot, interactive := true)
{
    global LLARS_AHI_GateStartTick, LLARS_AHI_GateReady, LLARS_AHI_GateElapsed
    global LLARS_AHI_InitStartTick, LLARS_AHI_InitElapsed, LLARS_AHI_FullyReady

    if (projectRoot = "")
        return false

    if LLARS_AHI_UninstallPending(projectRoot)
    {
        if LLARS_AHI_UninstallStillPending(projectRoot)
        {
            if (interactive)
                LLARS_AHI_ShowUninstallRestartMessage(true)
            return false
        }
    }

    LLARS_AHI_SetMode(projectRoot, "ahi")
    LLARS_AHI_GateStartTick := LLARS_NowMS()
    LLARS_AHI_GateReady := LLARS_AHI_StartupGate(projectRoot, interactive, true, false)
    LLARS_AHI_GateElapsed := LLARS_NowMS() - LLARS_AHI_GateStartTick
    if !LLARS_AHI_GateReady
        return false

    ; Standard mode intentionally disposes the live AHI object. Re-enabling AHI
    ; in the same process must rebuild the object, device routes, subscriptions,
    ; and watchdog before Input Settings can report the backend as ready.
    LLARS_AHI_InitStartTick := LLARS_NowMS()
    LLARS_AHI_Initialize(projectRoot)
    LLARS_AHI_InitElapsed := LLARS_NowMS() - LLARS_AHI_InitStartTick
    LLARS_AHI_FullyReady := (LLARS_AHI_IsReady("mouse") && LLARS_AHI_IsReady("keyboard"))
    return LLARS_AHI_FullyReady
}

LLARS_AHI_ShowRestartMessage(isReminder := false)
{
    ; 262144 = WS_EX_TOPMOST. Keep restart prompts above LLARS windows.
    if (isReminder)
    {
        restartTitle := "LLARS AHI Restart Required"
        restartText := "AutoHotInterception setup is complete, but Windows has not restarted yet."
            . "`n`nRestart Windows now so LLARS can use its recommended AHI input backend?"
            . "`n`nChoose No to restart later. LLARS will remind you the next time it starts."
    }
    else
    {
        restartTitle := "LLARS AHI Setup Complete"
        restartText := "AutoHotInterception was installed successfully."
            . "`n`nWindows must restart once before LLARS can use its recommended AHI input backend."
            . "`n`nRestart Windows now?"
            . "`n`nChoose No to restart later. LLARS will remind you the next time it starts."
    }

    MsgBox, 262180, %restartTitle%, %restartText%
    IfMsgBox, Yes
        Shutdown, 2
}

LLARS_AHI_ShowUninstallRestartMessage(reinstallAfter := false)
{
    if (reinstallAfter)
        uninstallText := "The existing AutoHotInterception / Interception driver was removed successfully.`n`nRestart Windows once to finish the AHI repair. On the next LLARS launch, the bundled AHI installer will be offered automatically.`n`nRestart Windows now?"
    else
        uninstallText := "AutoHotInterception / Interception was removed successfully.`n`nWindows must restart once to finish unloading the driver.`n`nRestart Windows now?"

    MsgBox, 0x40024, LLARS AHI - Restart Required, %uninstallText%
    IfMsgBox, Yes
        Shutdown, 2
}

; Startup gate shared by Script Selector and scripts launched directly.
; AutoHotInterception is the recommended LLARS backend; Standard AutoHotkey
; remains available as a fallback when AHI is declined or unavailable.
LLARS_AHI_StartupGate(projectRoot, interactive := true, force := false, setupConfirmed := false)
{
    static gateRan := false
    static gateResult := false

    if (gateRan && !force)
        return gateResult
    gateRan := true

    if (projectRoot = "")
        return false

    if (!force && LLARS_AHI_Mode(projectRoot) != "ahi")
    {
        gateResult := false
        LLARS_AHI_FallbackModeCheck(projectRoot, interactive)
        return false
    }

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
            MsgBox, 0x40030, LLARS Input Files Missing, LLARS is missing one or more bundled AutoHotInterception runtime files.`n`nRe-extract or redownload the complete LLARS package. The Windows driver was not changed.`n`nLLARS will use standard AutoHotkey input for this run.`n`nSupport report: Logs\LLARS-Support.txt
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
            MsgBox, 0x40030, LLARS Input Files, LLARS could not prepare the bundled AutoHotInterception files for Windows.`n`nMove or re-extract LLARS to a folder you can write to, then try again.`n`nLLARS will use standard AutoHotkey input for this run.`n`nSupport report: Logs\LLARS-Support.txt
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
            MsgBox, 0x40030, LLARS Input Driver, Interception is installed but is not active on this Windows boot.`n`nRestart Windows once and try LLARS again. If it still does not initialize, open Developer Mode and use Copy Support Report for Gubna.`n`nLLARS will use standard AutoHotkey input for this run.
        return false
    }

    ; A partial Interception registration needs a clean repair instead of an
    ; install-over. Remove the incomplete driver, reboot once, then reinstall
    ; LLARS's bundled AHI copy on the next launch.
    if LLARS_AHI_DriverPresent()
    {
        LLARS_AHI_Trace(projectRoot, "Partial Interception registration detected; repair required")
        LLARS_AHI_SupportHint(projectRoot, "Partial Interception registration detected")
        if (!interactive)
            return false

        repairText := "LLARS detected an incomplete AutoHotInterception / Interception driver installation."
            . "`n`nLLARS recommends repairing AHI by removing the incomplete driver, restarting Windows once, then reinstalling the bundled LLARS copy."
            . "`n`nRepair AHI now?"
            . "`n`nYes = Start AHI repair"
            . "`nNo = Use Standard AutoHotkey fallback"
        MsgBox, 0x40034, LLARS AHI Repair, %repairText%
        IfMsgBox, Yes
            return LLARS_AHI_RequestUninstall(projectRoot, true, true)

        LLARS_AHI_SetMode(projectRoot, "standard")
        return false
    }

    if (!interactive)
        return false

    if (!setupConfirmed)
    {
        setupText := "LLARS recommends AutoHotInterception (AHI) for mouse and keyboard input."
            . "`n`nEverything required is already included with LLARS."
            . "`nSetup installs the Windows Interception keyboard/mouse driver and needs one Administrator prompt."
            . "`nAfter setup, LLARS will ask you to restart Windows once."
            . "`n`nOK = Install AHI (Recommended)"
            . "`nCancel = Use Standard AutoHotkey (Fallback)"
        MsgBox, 0x40031, LLARS AHI Setup, %setupText%
        IfMsgBox, Cancel
        {
            LLARS_AHI_SetMode(projectRoot, "standard")
            return false
        }
    }

    setupResult := LLARS_AHI_RunSetup(projectRoot)
    LLARS_AHI_Trace(projectRoot, "RunSetup returned: " . setupResult)
    if (setupResult = "MISSING")
    {
        LLARS_AHI_SupportHint(projectRoot, "Setup failure: setup tool missing")
        MsgBox, 0x40030, LLARS Input Setup, The LLARS AutoHotInterception setup tool is missing.`n`nRe-extract or redownload LLARS. The Windows driver was not changed.
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
        MsgBox, 0x40030, LLARS Input Setup, LLARS could not verify its bundled AutoHotInterception files.`n`nRe-extract or redownload the complete LLARS package. Nothing was downloaded and the Windows driver was not changed.`n`nSupport report: Logs\LLARS-Support.txt
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
        MsgBox, 0x40030, LLARS Input Setup, AutoHotInterception setup did not complete successfully.`n`nLLARS will use standard AutoHotkey input for this run.`n`nSupport report: Logs\LLARS-Support.txt`nUse Developer Mode > Copy Support Report to paste the details to Gubna.
        return false
    }

    if (!LLARS_AHI_LibraryReady(projectRoot))
    {
        LLARS_AHI_Trace(projectRoot, "Setup reported success but bundled runtime verification failed")
        LLARS_AHI_SupportHint(projectRoot, "Setup failure: runtime verification")
        MsgBox, 0x40030, LLARS Input Setup, LLARS setup completed, but the bundled AutoHotInterception runtime is incomplete.`n`nRe-extract or redownload LLARS. LLARS will use standard AutoHotkey input for this run.
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
    global LLARS_AHI_PROJECT_ROOT, LLARS_AHI_MOUSE_SUBSCRIBED_ID, LLARS_AHI_KEYBOARD_SUBSCRIBED_ID
    global LLARS_AHI_MOUSE_SUBSCRIPTIONS, LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS
    global LLARS_AHI_MOUSE_ACTIVITY_ID, LLARS_AHI_MOUSE_ACTIVITY_TICK, LLARS_AHI_MOUSE_ACTIVITY_APPLIED_TICK
    global LLARS_AHI_MOUSE_ACTIVITY_BY_ID, LLARS_AHI_MOUSE_ROUTE_VERIFIED
    global LLARS_AHI_MOUSE_PREFERRED_ID, LLARS_AHI_MOUSE_PREFERRED_INFO, LLARS_AHI_MOUSE_ALTERNATE_ACTIVE
    global LLARS_AHI_DEVICE_HISTORY_MOUSE, LLARS_AHI_DEVICE_HISTORY_KEYBOARD
    global LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING, LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC
    global LLARS_AHI_FAST_RECOVERY_FUNC, LLARS_AHI_FAST_RECOVERY_ACTIVE, LLARS_AHI_FAST_RECOVERY_UNTIL
    global LLARS_AHI_MOUSE_LAST_SEEN, LLARS_AHI_KEYBOARD_LAST_SEEN
    global LLARS_AHI_MOUSE_EVENT_COUNT, LLARS_AHI_KEYBOARD_EVENT_COUNT
    global LLARS_AHI_REBIND_COUNT, LLARS_AHI_LAST_REBIND, LLARS_AHI_RECOVERY_ACTIVE
    global LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED

    LLARS_AHI_StopDeviceWatchdog()
    LLARS_AHI_UnsubscribeLifecycle()
    if IsObject(LLARS_AHI_Object)
    {
        try LLARS_AHI_Object.Instance.Dispose()
    }
    LLARS_AHI_NativeTransportDispose()

    LLARS_AHI_PROJECT_ROOT := projectRoot
    LLARS_AHI_MOUSE_SUBSCRIBED_ID := 0
    LLARS_AHI_KEYBOARD_SUBSCRIBED_ID := 0
    LLARS_AHI_MOUSE_SUBSCRIPTIONS := {}
    LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS := {}
    LLARS_AHI_MOUSE_ACTIVITY_ID := 0
    LLARS_AHI_MOUSE_ACTIVITY_TICK := 0
    LLARS_AHI_MOUSE_ACTIVITY_APPLIED_TICK := 0
    LLARS_AHI_MOUSE_ACTIVITY_BY_ID := {}
    LLARS_AHI_MOUSE_ROUTE_VERIFIED := false
    LLARS_AHI_MOUSE_PREFERRED_ID := 0
    LLARS_AHI_MOUSE_PREFERRED_INFO := ""
    LLARS_AHI_MOUSE_ALTERNATE_ACTIVE := false
    LLARS_AHI_DEVICE_HISTORY_MOUSE := {}
    LLARS_AHI_DEVICE_HISTORY_KEYBOARD := {}
    LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING := false
    LLARS_AHI_FAST_RECOVERY_ACTIVE := false
    LLARS_AHI_FAST_RECOVERY_UNTIL := 0
    if !IsObject(LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC)
        LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC := Func("LLARS_AHI_ProcessPendingMouseActivity")
    LLARS_AHI_MOUSE_LAST_SEEN := 0
    LLARS_AHI_KEYBOARD_LAST_SEEN := 0
    LLARS_AHI_MOUSE_EVENT_COUNT := 0
    LLARS_AHI_KEYBOARD_EVENT_COUNT := 0
    LLARS_AHI_REBIND_COUNT := 0
    LLARS_AHI_LAST_REBIND := ""
    LLARS_AHI_RECOVERY_ACTIVE := false
    LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED := false

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
    LLARS_AHI_HELD_KEYS := {}
    LLARS_AHI_HELD_MOUSE := {}
    if (!LLARS_AHI_EXIT_REGISTERED)
    {
        OnExit("LLARS_AHI_OnExit")
        LLARS_AHI_EXIT_REGISTERED := true
    }

    if (LLARS_AHI_Mode(projectRoot) != "ahi")
    {
        LLARS_AHI_STATUS_REASON := "Standard AutoHotkey fallback selected"
        LLARS_AHI_LAST_MOUSE_TRANSPORT := "Standard AutoHotkey fallback"
        LLARS_AHI_LAST_KEYBOARD_TRANSPORT := "Standard AutoHotkey fallback"
        return false
    }

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

    ; Choose stable AHI transport carriers independently of the physical devices
    ; the user happens to be touching. Built-in/internal routes are preferred;
    ; stable low-ID USB/HID routes outrank devices that demonstrate reconnect
    ; churn. Physical mouse observation below remains separate from this choice.
    mouseTransport := LLARS_AHI_SelectStableTransport(deviceList, true)
    if IsObject(mouseTransport)
    {
        LLARS_AHI_MOUSE_ID := mouseTransport.ID
        LLARS_AHI_MOUSE_INFO := mouseTransport
    }
    keyboardTransport := LLARS_AHI_SelectStableTransport(deviceList, false)
    if IsObject(keyboardTransport)
    {
        LLARS_AHI_KEYBOARD_ID := keyboardTransport.ID
        LLARS_AHI_KEYBOARD_INFO := keyboardTransport
    }

    LLARS_AHI_MOUSE_READY := (LLARS_AHI_MOUSE_ID >= 11 && LLARS_AHI_MOUSE_ID <= 20)
    LLARS_AHI_KEYBOARD_READY := (LLARS_AHI_KEYBOARD_ID >= 1 && LLARS_AHI_KEYBOARD_ID <= 10)
    LLARS_AHI_READY := (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY)
    if (LLARS_AHI_MOUSE_READY)
        LLARS_AHI_NativeTransportInitialize(projectRoot)

    ; Observe every connected mouse-button route non-blockingly so the physical
    ; mouse can be learned instead of assuming the first enumerated mouse ID.
    ; Keyboard observation remains on the selected keyboard route.
    LLARS_AHI_SubscribeLifecycle(deviceList)
    LLARS_AHI_StartDeviceWatchdog(projectRoot)

    if (LLARS_AHI_MOUSE_READY && LLARS_AHI_KEYBOARD_READY)
        LLARS_AHI_STATUS_REASON := "Ready"
    else if (LLARS_AHI_MOUSE_READY)
        LLARS_AHI_STATUS_REASON := "Mouse ready; no Interception keyboard detected"
    else if (LLARS_AHI_KEYBOARD_READY)
        LLARS_AHI_STATUS_REASON := "Keyboard ready; no Interception mouse detected"
    else
        LLARS_AHI_STATUS_REASON := "No connected Interception keyboard or mouse detected"

    ; Healthy startup stays disk-light. Full support reports are generated only
    ; on failures/fallbacks or when the user presses Copy Support Report.
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


LLARS_AHI_TickAgeText(tick)
{
    if (!tick)
        return "Not observed"
    elapsed := LLARS_NowMS() - tick
    if (elapsed < 0)
        elapsed := 0
    if (elapsed < 1000)
        return elapsed . " ms ago"
    return Round(elapsed / 1000) . " s ago"
}

; Subscription callbacks intentionally do almost no work. AHI's receive thread
; should never be burdened with GUI updates, logging, enumeration, or recovery.
LLARS_AHI_OnPhysicalKeyboard(code, state)
{
    global LLARS_AHI_KEYBOARD_LAST_SEEN, LLARS_AHI_KEYBOARD_EVENT_COUNT
    LLARS_AHI_KEYBOARD_LAST_SEEN := LLARS_NowMS()
    LLARS_AHI_KEYBOARD_EVENT_COUNT++
}

LLARS_AHI_OnPhysicalMouseButton(deviceId, code, state)
{
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_MOUSE_ROUTE_VERIFIED, LLARS_AHI_MOUSE_PREFERRED_ID
    global LLARS_AHI_MOUSE_LAST_SEEN, LLARS_AHI_MOUSE_EVENT_COUNT
    global LLARS_AHI_MOUSE_ACTIVITY_ID, LLARS_AHI_MOUSE_ACTIVITY_TICK, LLARS_AHI_MOUSE_ACTIVITY_BY_ID
    global LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING, LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC
    LLARS_AHI_MOUSE_LAST_SEEN := LLARS_NowMS()
    LLARS_AHI_MOUSE_EVENT_COUNT++
    LLARS_AHI_MOUSE_ACTIVITY_ID := deviceId + 0
    LLARS_AHI_MOUSE_ACTIVITY_TICK := LLARS_NowMS()
    if !IsObject(LLARS_AHI_MOUSE_ACTIVITY_BY_ID)
        LLARS_AHI_MOUSE_ACTIVITY_BY_ID := {}
    LLARS_AHI_MOUSE_ACTIVITY_BY_ID[LLARS_AHI_MOUSE_ACTIVITY_ID] := LLARS_NowMS()
    if (LLARS_AHI_MOUSE_ACTIVITY_ID = LLARS_AHI_MOUSE_ID)
    {
        LLARS_AHI_MOUSE_ROUTE_VERIFIED := true
        ; The first physical event on the current output route still needs a
        ; normal-thread refresh so LLARS records that device as preferred.
        if (LLARS_AHI_MOUSE_PREFERRED_ID = LLARS_AHI_MOUSE_ACTIVITY_ID)
            return
    }

    ; A physical event on a different subscribed AHI ID, or the first event
    ; that establishes the preferred identity, is authoritative route
    ; signal. Schedule recovery onto the normal AHK timer thread instead of
    ; waiting up to five seconds for the lifecycle watchdog. The callback still
    ; does no enumeration, logging, GUI work, or transport itself.
    LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING := true
    if !IsObject(LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC)
        LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC := Func("LLARS_AHI_ProcessPendingMouseActivity")
    SetTimer, % LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC, -10
}

LLARS_AHI_ProcessPendingMouseActivity()
{
    global LLARS_AHI_PROJECT_ROOT, LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING
    if !LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING
        return
    LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING := false
    if (LLARS_AHI_PROJECT_ROOT = "" || LLARS_AHI_Mode(LLARS_AHI_PROJECT_ROOT) != "ahi")
        return
    LLARS_AHI_RefreshDeviceRoutes(LLARS_AHI_PROJECT_ROOT, "Physical mouse activity", "mouse")
}

LLARS_AHI_MouseSubscriptionText()
{
    global LLARS_AHI_MOUSE_SUBSCRIPTIONS
    if !IsObject(LLARS_AHI_MOUSE_SUBSCRIPTIONS)
        return "Off"

    text := ""
    Loop, 10
    {
        id := A_Index + 10
        if LLARS_AHI_MOUSE_SUBSCRIPTIONS.HasKey(id)
            text .= (text = "" ? "" : ",") . "AHI #" . id
    }
    return (text = "" ? "Off" : text)
}

LLARS_AHI_DeviceFromId(deviceList, id, isMouse)
{
    if !IsObject(deviceList)
        return ""
    numericId := id + 0
    if !deviceList.HasKey(numericId)
        return ""
    return LLARS_AHI_DeviceCandidate(deviceList[numericId], numericId, isMouse)
}

LLARS_AHI_UnsubscribeLifecycle()
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_SUBSCRIBED_ID, LLARS_AHI_KEYBOARD_SUBSCRIBED_ID
    global LLARS_AHI_MOUSE_SUBSCRIPTIONS, LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS

    if IsObject(LLARS_AHI_Object)
    {
        if IsObject(LLARS_AHI_MOUSE_SUBSCRIPTIONS)
        {
            for id, subscribed in LLARS_AHI_MOUSE_SUBSCRIPTIONS
            {
                if subscribed
                {
                    try LLARS_AHI_Object.UnsubscribeMouseButtons(id + 0)
                }
            }
        }
        if (LLARS_AHI_KEYBOARD_SUBSCRIBED_ID)
        {
            try LLARS_AHI_Object.UnsubscribeKeyboard(LLARS_AHI_KEYBOARD_SUBSCRIBED_ID)
        }
    }
    LLARS_AHI_MOUSE_SUBSCRIPTIONS := {}
    LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS := {}
    LLARS_AHI_MOUSE_SUBSCRIBED_ID := 0
    LLARS_AHI_KEYBOARD_SUBSCRIBED_ID := 0
    return true
}

LLARS_AHI_SubscribeLifecycle(deviceList := "")
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_SUBSCRIBED_ID, LLARS_AHI_KEYBOARD_SUBSCRIBED_ID
    global LLARS_AHI_MOUSE_SUBSCRIPTIONS, LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS
    global LLARS_AHI_STATUS_DETAIL

    if !IsObject(LLARS_AHI_Object)
        return false

    if !IsObject(LLARS_AHI_MOUSE_SUBSCRIPTIONS)
        LLARS_AHI_MOUSE_SUBSCRIPTIONS := {}
    if !IsObject(LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS)
        LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS := {}

    if !IsObject(deviceList)
    {
        try
            deviceList := LLARS_AHI_Object.GetDeviceList()
        catch e
        {
            LLARS_AHI_STATUS_DETAIL := "Mouse lifecycle enumeration failed: " . e.Message
            return false
        }
    }

    subscriptionOk := true
    currentMouseIds := {}

    ; Subscribe to buttons/wheel on every connected Interception mouse. Each
    ; callback is bound to its source ID, allowing LLARS to learn the physical
    ; mouse without using the high-volume mouse-movement subscription path.
    for id, info in deviceList
    {
        candidate := LLARS_AHI_DeviceCandidate(info, id, true)
        if !IsObject(candidate)
            continue

        numericId := candidate.ID + 0
        currentMouseIds[numericId] := true
        if !LLARS_AHI_MOUSE_SUBSCRIPTIONS.HasKey(numericId)
        {
            callback := Func("LLARS_AHI_OnPhysicalMouseButton").Bind(numericId)
            try
            {
                LLARS_AHI_Object.SubscribeMouseButtons(numericId, false, callback, false)
                LLARS_AHI_MOUSE_SUBSCRIPTIONS[numericId] := true
                LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS[numericId] := callback
            }
            catch e
            {
                subscriptionOk := false
                LLARS_AHI_STATUS_DETAIL := "Mouse lifecycle subscription failed for AHI #" . numericId . ": " . e.Message
            }
        }
    }

    ; Retire subscriptions for device IDs no longer exposed by AHI.
    staleMouseIds := []
    for id, subscribed in LLARS_AHI_MOUSE_SUBSCRIPTIONS
    {
        if (subscribed && !currentMouseIds.HasKey(id + 0))
            staleMouseIds.Push(id + 0)
    }
    for _, id in staleMouseIds
    {
        try LLARS_AHI_Object.UnsubscribeMouseButtons(id)
        LLARS_AHI_MOUSE_SUBSCRIPTIONS.Delete(id)
        if LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS.HasKey(id)
            LLARS_AHI_MOUSE_SUBSCRIPTION_CALLBACKS.Delete(id)
    }

    LLARS_AHI_MOUSE_SUBSCRIBED_ID := (LLARS_AHI_MOUSE_ID && LLARS_AHI_MOUSE_SUBSCRIPTIONS.HasKey(LLARS_AHI_MOUSE_ID)) ? LLARS_AHI_MOUSE_ID : 0

    if (LLARS_AHI_KEYBOARD_SUBSCRIBED_ID && LLARS_AHI_KEYBOARD_SUBSCRIBED_ID != LLARS_AHI_KEYBOARD_ID)
    {
        try LLARS_AHI_Object.UnsubscribeKeyboard(LLARS_AHI_KEYBOARD_SUBSCRIBED_ID)
        LLARS_AHI_KEYBOARD_SUBSCRIBED_ID := 0
    }

    if (LLARS_AHI_KEYBOARD_READY && LLARS_AHI_KEYBOARD_ID && LLARS_AHI_KEYBOARD_SUBSCRIBED_ID != LLARS_AHI_KEYBOARD_ID)
    {
        try
        {
            LLARS_AHI_Object.SubscribeKeyboard(LLARS_AHI_KEYBOARD_ID, false, Func("LLARS_AHI_OnPhysicalKeyboard"), false)
            LLARS_AHI_KEYBOARD_SUBSCRIBED_ID := LLARS_AHI_KEYBOARD_ID
        }
        catch e
        {
            subscriptionOk := false
            LLARS_AHI_STATUS_DETAIL := "Keyboard lifecycle subscription failed: " . e.Message
        }
    }
    return subscriptionOk
}

LLARS_AHI_DeviceCandidate(info, id, isMouse)
{
    if !IsObject(info)
        return ""
    numericId := id + 0
    if (isMouse)
    {
        if (!info.IsMouse || numericId < 11 || numericId > 20)
            return ""
    }
    else
    {
        if (info.IsMouse || numericId < 1 || numericId > 10)
            return ""
    }
    if (Trim(info.Handle) = "")
        return ""
    return {ID:numericId, VID:info.VID + 0, PID:info.PID + 0, Handle:info.Handle}
}


LLARS_AHI_SameDeviceIdentity(leftInfo, rightInfo)
{
    if (!IsObject(leftInfo) || !IsObject(rightInfo))
        return false
    leftHandle := Trim(leftInfo.Handle)
    rightHandle := Trim(rightInfo.Handle)
    StringLower, leftHandle, leftHandle
    StringLower, rightHandle, rightHandle
    if (leftHandle != "" && rightHandle != "")
        return (leftHandle = rightHandle)
    return ((leftInfo.VID + 0) = (rightInfo.VID + 0) && (leftInfo.PID + 0) = (rightInfo.PID + 0))
}

LLARS_AHI_DeviceIdentityKey(candidate)
{
    if !IsObject(candidate)
        return ""
    handle := Trim(candidate.Handle)
    StringLower, handle, handle
    if (handle != "")
        return handle
    return (candidate.VID + 0) . ":" . (candidate.PID + 0)
}

LLARS_AHI_DeviceReliabilityClass(candidate, isMouse)
{
    if !IsObject(candidate)
        return "Unavailable"

    handle := Trim(candidate.Handle)
    StringUpper, handle, handle
    ; These markers describe buses/device families commonly used by built-in
    ; laptop keyboards and precision/I2C/legacy touchpads. They are hints only;
    ; the dynamic ID/churn score remains authoritative when metadata is vague.
    if (InStr(handle, "I2C") || InStr(handle, "ACPI") || InStr(handle, "PNP0F")
        || InStr(handle, "PNP0303") || InStr(handle, "ELAN") || InStr(handle, "SYNAPT")
        || InStr(handle, "ALPS") || InStr(handle, "TOUCHPAD") || InStr(handle, "PRECISION")
        || InStr(handle, "PS/2") || InStr(handle, "PS2"))
        return "Built-in/internal"

    if (InStr(handle, "BTH") || InStr(handle, "WIRELESS")
        || InStr(handle, "RECEIVER") || InStr(handle, "UNIFY") || InStr(handle, "LIGHTSPEED")
        || InStr(handle, "LOGI_BOLT") || InStr(handle, "BOLT"))
        return "Wireless/receiver"

    if (InStr(handle, "USB") || InStr(handle, "HID"))
        return "USB/HID"
    return "Connected AHI device"
}

LLARS_AHI_IsNewestIdentityCandidate(deviceList, candidate, isMouse)
{
    if (!IsObject(deviceList) || !IsObject(candidate))
        return false
    for otherId, otherInfo in deviceList
    {
        other := LLARS_AHI_DeviceCandidate(otherInfo, otherId, isMouse)
        if !IsObject(other)
            continue
        if (other.ID > candidate.ID && LLARS_AHI_SameDeviceIdentity(other, candidate))
            return false
    }
    return true
}

LLARS_AHI_UpdateDeviceHistory(deviceList, isMouse)
{
    global LLARS_AHI_DEVICE_HISTORY_MOUSE, LLARS_AHI_DEVICE_HISTORY_KEYBOARD
    if !IsObject(deviceList)
        return false
    if (isMouse)
    {
        if !IsObject(LLARS_AHI_DEVICE_HISTORY_MOUSE)
            LLARS_AHI_DEVICE_HISTORY_MOUSE := {}
        history := LLARS_AHI_DEVICE_HISTORY_MOUSE
    }
    else
    {
        if !IsObject(LLARS_AHI_DEVICE_HISTORY_KEYBOARD)
            LLARS_AHI_DEVICE_HISTORY_KEYBOARD := {}
        history := LLARS_AHI_DEVICE_HISTORY_KEYBOARD
    }

    for id, info in deviceList
    {
        candidate := LLARS_AHI_DeviceCandidate(info, id, isMouse)
        if !IsObject(candidate)
            continue
        if !LLARS_AHI_IsNewestIdentityCandidate(deviceList, candidate, isMouse)
            continue
        key := LLARS_AHI_DeviceIdentityKey(candidate)
        if (key = "")
            continue
        if !history.HasKey(key)
            history[key] := {LastID:candidate.ID, Churn:0, FirstSeen:LLARS_NowMS(), LastSeen:LLARS_NowMS()}
        else
        {
            entry := history[key]
            if (entry.LastID && entry.LastID != candidate.ID)
                entry.Churn++
            entry.LastID := candidate.ID
            entry.LastSeen := LLARS_NowMS()
            history[key] := entry
        }
    }
    return true
}

LLARS_AHI_DeviceReliabilityScore(candidate, isMouse, currentInfo := "")
{
    global LLARS_AHI_DEVICE_HISTORY_MOUSE, LLARS_AHI_DEVICE_HISTORY_KEYBOARD
    if !IsObject(candidate)
        return -999999

    class := LLARS_AHI_DeviceReliabilityClass(candidate, isMouse)
    score := 1000
    if (class = "Built-in/internal")
        score += 500
    else if (class = "USB/HID")
        score += 150
    else if (class = "Wireless/receiver")
        score -= 250

    ; Lower Interception IDs are normally older, continuously-present slots.
    ; A multi-host/sleeping wireless device that repeatedly reconnects naturally
    ; loses this bonus as its ID climbs toward the driver's fixed ceiling.
    maxId := isMouse ? 20 : 10
    score += (maxId - candidate.ID) * 15

    key := LLARS_AHI_DeviceIdentityKey(candidate)
    history := isMouse ? LLARS_AHI_DEVICE_HISTORY_MOUSE : LLARS_AHI_DEVICE_HISTORY_KEYBOARD
    if (IsObject(history) && key != "" && history.HasKey(key))
    {
        entry := history[key]
        score -= (entry.Churn + 0) * 300
        age := LLARS_NowMS() - (entry.FirstSeen + 0)
        if (age > 0)
        {
            ageBonus := Floor(age / 5000)
            if (ageBonus > 60)
                ageBonus := 60
            score += ageBonus
        }
    }

    ; Small stickiness avoids unnecessary carrier hopping when two stable
    ; devices score nearly the same. It cannot outweigh built-in/churn evidence.
    if (IsObject(currentInfo) && LLARS_AHI_SameDeviceIdentity(candidate, currentInfo))
        score += 40
    return score
}

LLARS_AHI_SelectStableTransport(deviceList, isMouse, currentInfo := "")
{
    if !IsObject(deviceList)
        return ""
    LLARS_AHI_UpdateDeviceHistory(deviceList, isMouse)

    best := ""
    bestScore := -999999
    for id, info in deviceList
    {
        candidate := LLARS_AHI_DeviceCandidate(info, id, isMouse)
        if !IsObject(candidate)
            continue
        ; Interception can leave older IDs for the same physical handle visible
        ; after reconnect. Only the highest ID for that identity is considered
        ; live; reliability ranking then compares distinct physical devices.
        if !LLARS_AHI_IsNewestIdentityCandidate(deviceList, candidate, isMouse)
            continue
        score := LLARS_AHI_DeviceReliabilityScore(candidate, isMouse, currentInfo)
        if (!IsObject(best) || score > bestScore
            || (score = bestScore && IsObject(currentInfo) && LLARS_AHI_SameDeviceIdentity(candidate, currentInfo))
            || (score = bestScore && candidate.ID < best.ID))
        {
            best := candidate
            bestScore := score
        }
    }
    if IsObject(best)
    {
        best.ReliabilityScore := bestScore
        best.ReliabilityClass := LLARS_AHI_DeviceReliabilityClass(best, isMouse)
    }
    return best
}

LLARS_AHI_DeviceReliabilityText(info, isMouse)
{
    global LLARS_AHI_DEVICE_HISTORY_MOUSE, LLARS_AHI_DEVICE_HISTORY_KEYBOARD
    if !IsObject(info)
        return "Unavailable"
    class := LLARS_AHI_DeviceReliabilityClass(info, isMouse)
    score := LLARS_AHI_DeviceReliabilityScore(info, isMouse, info)
    churn := 0
    key := LLARS_AHI_DeviceIdentityKey(info)
    history := isMouse ? LLARS_AHI_DEVICE_HISTORY_MOUSE : LLARS_AHI_DEVICE_HISTORY_KEYBOARD
    if (IsObject(history) && key != "" && history.HasKey(key))
        churn := history[key].Churn + 0
    return class . " | Score=" . score . " | ID changes=" . churn
}

LLARS_AHI_StopFastMouseRecovery()
{
    global LLARS_AHI_FAST_RECOVERY_FUNC, LLARS_AHI_FAST_RECOVERY_ACTIVE, LLARS_AHI_FAST_RECOVERY_UNTIL
    if IsObject(LLARS_AHI_FAST_RECOVERY_FUNC)
        SetTimer, % LLARS_AHI_FAST_RECOVERY_FUNC, Off
    LLARS_AHI_FAST_RECOVERY_ACTIVE := false
    LLARS_AHI_FAST_RECOVERY_UNTIL := 0
    return true
}

LLARS_AHI_StartFastMouseRecovery(projectRoot := "", durationMs := 10000)
{
    global LLARS_AHI_PROJECT_ROOT, LLARS_AHI_FAST_RECOVERY_FUNC, LLARS_AHI_FAST_RECOVERY_ACTIVE, LLARS_AHI_FAST_RECOVERY_UNTIL
    if (projectRoot != "")
        LLARS_AHI_PROJECT_ROOT := projectRoot
    if (LLARS_AHI_PROJECT_ROOT = "" || LLARS_AHI_Mode(LLARS_AHI_PROJECT_ROOT) != "ahi")
        return false
    if !IsObject(LLARS_AHI_FAST_RECOVERY_FUNC)
        LLARS_AHI_FAST_RECOVERY_FUNC := Func("LLARS_AHI_FastMouseRecoveryTick")
    if !LLARS_AHI_FAST_RECOVERY_ACTIVE
    {
        LLARS_AHI_FAST_RECOVERY_ACTIVE := true
        LLARS_AHI_FAST_RECOVERY_UNTIL := LLARS_NowMS() + durationMs
        SetTimer, % LLARS_AHI_FAST_RECOVERY_FUNC, 200
    }
    return true
}

LLARS_AHI_FastMouseRecoveryTick()
{
    global LLARS_AHI_PROJECT_ROOT, LLARS_AHI_FAST_RECOVERY_ACTIVE, LLARS_AHI_FAST_RECOVERY_UNTIL
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_MOUSE_ALTERNATE_ACTIVE
    if !LLARS_AHI_FAST_RECOVERY_ACTIVE
        return
    if (LLARS_AHI_PROJECT_ROOT = "" || LLARS_AHI_Mode(LLARS_AHI_PROJECT_ROOT) != "ahi")
    {
        LLARS_AHI_StopFastMouseRecovery()
        return
    }
    if (LLARS_NowMS() >= LLARS_AHI_FAST_RECOVERY_UNTIL)
    {
        LLARS_AHI_StopFastMouseRecovery()
        return
    }

    LLARS_AHI_RefreshDeviceRoutes(LLARS_AHI_PROJECT_ROOT, "Fast mouse recovery", "mouse")
    ; Once any stable AHI transport route is available, normal operation can
    ; resume. The 5-second watchdog continues observing physical-device changes.
    if LLARS_AHI_MOUSE_READY
        LLARS_AHI_StopFastMouseRecovery()
}

LLARS_AHI_RefreshDeviceRoutes(projectRoot := "", reason := "Device watchdog", kind := "")
{
    global LLARS_AHI_Object, LLARS_AHI_READY
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_INFO, LLARS_AHI_KEYBOARD_INFO
    global LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL
    global LLARS_AHI_MOUSE_ACTIVITY_ID, LLARS_AHI_MOUSE_ACTIVITY_TICK, LLARS_AHI_MOUSE_ACTIVITY_APPLIED_TICK
    global LLARS_AHI_MOUSE_ROUTE_VERIFIED, LLARS_AHI_MOUSE_PREFERRED_ID, LLARS_AHI_MOUSE_PREFERRED_INFO
    global LLARS_AHI_MOUSE_ALTERNATE_ACTIVE
    global LLARS_AHI_REBIND_COUNT, LLARS_AHI_LAST_REBIND, LLARS_AHI_RECOVERY_ACTIVE
    global LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED

    if (LLARS_AHI_RECOVERY_ACTIVE || !IsObject(LLARS_AHI_Object))
        return false

    LLARS_AHI_RECOVERY_ACTIVE := true
    changed := false
    restored := false
    lost := false
    learnedPhysicalRoute := false
    detail := ""
    StringLower, kind, kind

    try
        deviceList := LLARS_AHI_Object.GetDeviceList()
    catch e
    {
        LLARS_AHI_STATUS_DETAIL := "AHI device re-enumeration failed: " . e.Message
        LLARS_AHI_RECOVERY_ACTIVE := false
        return false
    }

    if (kind = "" || kind = "mouse")
    {
        oldMouseId := LLARS_AHI_MOUSE_ID
        wasMouseReady := LLARS_AHI_MOUSE_READY
        oldAlternate := LLARS_AHI_MOUSE_ALTERNATE_ACTIVE
        oldPreferredId := LLARS_AHI_MOUSE_PREFERRED_ID
        mouseMatch := ""
        newAlternate := false

        ; Physical observation and LLARS transport selection are intentionally
        ; separate. A real button event identifies what the user is touching,
        ; but it does not force synthetic output onto a reconnect-prone device.
        if (LLARS_AHI_MOUSE_ACTIVITY_ID && LLARS_AHI_MOUSE_ACTIVITY_TICK > LLARS_AHI_MOUSE_ACTIVITY_APPLIED_TICK)
        {
            activityMatch := LLARS_AHI_DeviceFromId(deviceList, LLARS_AHI_MOUSE_ACTIVITY_ID, true)
            if IsObject(activityMatch)
            {
                LLARS_AHI_MOUSE_ACTIVITY_APPLIED_TICK := LLARS_AHI_MOUSE_ACTIVITY_TICK
                learnedPhysicalRoute := (!LLARS_AHI_MOUSE_ROUTE_VERIFIED
                    || !IsObject(LLARS_AHI_MOUSE_PREFERRED_INFO)
                    || !LLARS_AHI_SameDeviceIdentity(activityMatch, LLARS_AHI_MOUSE_PREFERRED_INFO)
                    || oldPreferredId != activityMatch.ID)
                LLARS_AHI_MOUSE_ROUTE_VERIFIED := true
                LLARS_AHI_MOUSE_PREFERRED_ID := activityMatch.ID
                LLARS_AHI_MOUSE_PREFERRED_INFO := activityMatch
            }
        }

        ; Select the most reliable AHI carrier independently of the physical
        ; mouse. Built-in/internal and continuously-present low-ID routes win;
        ; reconnect churn and high IDs reduce a route's score. The current
        ; carrier receives only a small tie-breaking bonus to avoid flapping.
        mouseMatch := LLARS_AHI_SelectStableTransport(deviceList, true, LLARS_AHI_MOUSE_INFO)
        if IsObject(mouseMatch)
        {
            if (IsObject(LLARS_AHI_MOUSE_PREFERRED_INFO))
                newAlternate := !LLARS_AHI_SameDeviceIdentity(mouseMatch, LLARS_AHI_MOUSE_PREFERRED_INFO)
            else
                newAlternate := false
        }

        if IsObject(mouseMatch)
        {
            LLARS_AHI_MOUSE_ID := mouseMatch.ID
            LLARS_AHI_MOUSE_INFO := mouseMatch
            LLARS_AHI_MOUSE_READY := true
            LLARS_AHI_MOUSE_ALTERNATE_ACTIVE := newAlternate

            routeChanged := (mouseMatch.ID != oldMouseId || !wasMouseReady)
            roleChanged := (oldAlternate != newAlternate)
            if routeChanged
            {
                restored := true
                changed := true
                if (newAlternate)
                    detail .= (detail = "" ? "" : " | ") . "Stable transport M" . oldMouseId . "->M" . mouseMatch.ID . " (separate physical pointer)"
                else
                    detail .= (detail = "" ? "" : " | ") . "Stable transport M" . oldMouseId . "->M" . mouseMatch.ID
                LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED := false
                LLARS_AHI_NativeTransportInitialize(projectRoot)
            }
            else if (learnedPhysicalRoute)
            {
                detail .= (detail = "" ? "" : " | ") . "Physical mouse observed M" . LLARS_AHI_MOUSE_PREFERRED_ID
                if (roleChanged)
                    detail .= " | Transport role updated"
            }
        }
        else
        {
            if (wasMouseReady)
            {
                lost := true
                detail .= (detail = "" ? "" : " | ") . "Mouse M" . oldMouseId . "->Unavailable"
            }
            LLARS_AHI_MOUSE_READY := false
            LLARS_AHI_MOUSE_ALTERNATE_ACTIVE := false
        }
    }

    if (kind = "" || kind = "keyboard")
    {
        oldKeyboardId := LLARS_AHI_KEYBOARD_ID
        wasKeyboardReady := LLARS_AHI_KEYBOARD_READY
        keyboardMatch := LLARS_AHI_SelectStableTransport(deviceList, false, LLARS_AHI_KEYBOARD_INFO)
        if IsObject(keyboardMatch)
        {
            LLARS_AHI_KEYBOARD_ID := keyboardMatch.ID
            LLARS_AHI_KEYBOARD_INFO := keyboardMatch
            LLARS_AHI_KEYBOARD_READY := true
            if (keyboardMatch.ID != oldKeyboardId || !wasKeyboardReady)
            {
                changed := true
                restored := true
                detail .= (detail = "" ? "" : " | ") . "Keyboard K" . oldKeyboardId . "->K" . keyboardMatch.ID
            }
        }
        else
        {
            if (wasKeyboardReady)
            {
                lost := true
                detail .= (detail = "" ? "" : " | ") . "Keyboard K" . oldKeyboardId . "->Unavailable"
            }
            LLARS_AHI_KEYBOARD_READY := false
        }
    }

    LLARS_AHI_READY := (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY)
    LLARS_AHI_SubscribeLifecycle(deviceList)

    if (LLARS_AHI_MOUSE_READY && LLARS_AHI_KEYBOARD_READY)
        LLARS_AHI_STATUS_REASON := "Ready"
    else if (LLARS_AHI_MOUSE_READY)
        LLARS_AHI_STATUS_REASON := "Mouse ready; waiting for Interception keyboard route"
    else if (LLARS_AHI_KEYBOARD_READY)
        LLARS_AHI_STATUS_REASON := "Keyboard ready; waiting for Interception mouse route"
    else
        LLARS_AHI_STATUS_REASON := "Waiting for connected Interception keyboard and mouse routes"

    if (learnedPhysicalRoute && detail != "" && !changed)
    {
        LLARS_AHI_STATUS_DETAIL := reason . " | " . detail
        LLARS_AHI_DeveloperAction("AHI Device Discovery || " . LLARS_AHI_STATUS_DETAIL)
    }

    if (changed)
    {
        LLARS_AHI_REBIND_COUNT++
        LLARS_AHI_LAST_REBIND := reason . (detail = "" ? "" : " | " . detail)
        LLARS_AHI_STATUS_DETAIL := LLARS_AHI_LAST_REBIND
        LLARS_AHI_DeveloperAction("AHI Device Recovery || " . LLARS_AHI_LAST_REBIND)
    }
    else if (lost)
    {
        LLARS_AHI_STATUS_DETAIL := "AHI lifecycle route unavailable" . (detail = "" ? "" : " | " . detail)
        LLARS_AHI_DeveloperAction("AHI Device Recovery || " . LLARS_AHI_STATUS_DETAIL)
    }

    LLARS_AHI_RECOVERY_ACTIVE := false

    ; Only total loss of a usable AHI pointer enters the short 200 ms scan.
    ; Physical wireless devices can come and go without destabilizing a healthy
    ; built-in/wired transport carrier.
    if ((kind = "" || kind = "mouse"))
    {
        if !LLARS_AHI_MOUSE_READY
            LLARS_AHI_StartFastMouseRecovery(projectRoot)
        else
            LLARS_AHI_StopFastMouseRecovery()
    }

    ; Route transitions are rare and important during wireless reconnect handling.
    ; Refresh the existing support snapshot so troubleshooting state survives a later reboot.
    if ((changed || lost || learnedPhysicalRoute) && projectRoot != "")
    {
        if learnedPhysicalRoute
            supportTrigger := "AHI physical mouse route learned"
        else
            supportTrigger := changed ? "AHI lifecycle route rebound" : "AHI lifecycle route unavailable"
        LLARS_AHI_WriteSupportReport(projectRoot, supportTrigger)
    }

    return restored || LLARS_AHI_READY
}

LLARS_AHI_AttemptTransportRecovery(kind, reason, detail := "")
{
    global LLARS_AHI_PROJECT_ROOT, LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED

    recoveryReason := reason
    if (detail != "")
        recoveryReason .= " | " . detail
    LLARS_AHI_RefreshDeviceRoutes(LLARS_AHI_PROJECT_ROOT, recoveryReason, kind)

    StringLower, kind, kind
    if (kind = "mouse")
    {
        if (LLARS_AHI_MOUSE_READY)
        {
            ; A route can remain on the same Interception ID while the native
            ; user-mode context becomes stale. Refresh that context before the
            ; one allowed AHI retry on a transport failure.
            LLARS_AHI_NativeTransportInitialize(LLARS_AHI_PROJECT_ROOT)
            LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED := false
        }
        if !LLARS_AHI_MOUSE_READY
            LLARS_AHI_StartFastMouseRecovery(LLARS_AHI_PROJECT_ROOT)
        return LLARS_AHI_MOUSE_READY
    }
    if (kind = "keyboard")
        return LLARS_AHI_KEYBOARD_READY
    return false
}

LLARS_AHI_DeviceWatchdogTick()
{
    global LLARS_AHI_PROJECT_ROOT
    if (LLARS_AHI_PROJECT_ROOT = "" || LLARS_AHI_Mode(LLARS_AHI_PROJECT_ROOT) != "ahi")
        return
    LLARS_AHI_RefreshDeviceRoutes(LLARS_AHI_PROJECT_ROOT, "Device watchdog")
}

LLARS_AHI_StartDeviceWatchdog(projectRoot := "")
{
    global LLARS_AHI_PROJECT_ROOT, LLARS_AHI_WATCHDOG_FUNC
    if (projectRoot != "")
        LLARS_AHI_PROJECT_ROOT := projectRoot
    if (LLARS_AHI_PROJECT_ROOT = "")
        return false
    if !IsObject(LLARS_AHI_WATCHDOG_FUNC)
        LLARS_AHI_WATCHDOG_FUNC := Func("LLARS_AHI_DeviceWatchdogTick")
    SetTimer, % LLARS_AHI_WATCHDOG_FUNC, 5000
    return true
}

LLARS_AHI_StopDeviceWatchdog()
{
    global LLARS_AHI_WATCHDOG_FUNC, LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC
    global LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING
    if IsObject(LLARS_AHI_WATCHDOG_FUNC)
        SetTimer, % LLARS_AHI_WATCHDOG_FUNC, Off
    if IsObject(LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC)
        SetTimer, % LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_FUNC, Off
    LLARS_AHI_MOUSE_ACTIVITY_RECOVERY_PENDING := false
    LLARS_AHI_StopFastMouseRecovery()
    return true
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

LLARS_AHI_StatusSnapshot(projectRoot := "")
{
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_INFO, LLARS_AHI_KEYBOARD_INFO
    global LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL
    global LLARS_AHI_LAST_MOUSE_TRANSPORT, LLARS_AHI_LAST_KEYBOARD_TRANSPORT
    global LLARS_AHI_GateElapsed, LLARS_AHI_InitElapsed

    mode := LLARS_AHI_Mode(projectRoot)
    configured := (mode = "ahi") ? "AutoHotInterception (Recommended)" : "Standard AutoHotkey (Fallback)"

    mouseReady := LLARS_AHI_MOUSE_READY ? true : false
    keyboardReady := LLARS_AHI_KEYBOARD_READY ? true : false

    if (mode != "ahi")
        active := "Standard AutoHotkey"
    else if (mouseReady && keyboardReady)
        active := "AutoHotInterception"
    else if (mouseReady || keyboardReady)
        active := "AutoHotInterception (partial route)"
    else
        active := "AutoHotInterception (route unavailable)"

    driverPresent := LLARS_AHI_DriverPresent()
    driverRegistered := LLARS_AHI_DriverRegistered()
    restartPending := LLARS_AHI_UninstallPending(projectRoot) && LLARS_AHI_UninstallStillPending(projectRoot)
    if (restartPending)
        driver := "Restart required"
    else if (driverRegistered)
        driver := "Installed"
    else if (driverPresent)
        driver := "Repair required"
    else
        driver := "Not installed"

    if (mouseReady)
    {
        mouseRoute := "AHI #" . LLARS_AHI_MOUSE_ID
        if IsObject(LLARS_AHI_MOUSE_INFO)
        {
            if (LLARS_AHI_MOUSE_INFO.VID || LLARS_AHI_MOUSE_INFO.PID)
                mouseRoute .= " | " . Format("{:04X}:{:04X}", LLARS_AHI_MOUSE_INFO.VID, LLARS_AHI_MOUSE_INFO.PID)
            else if (Trim(LLARS_AHI_MOUSE_INFO.Handle) != "")
                mouseRoute .= " | Connected HID"
        }
    }
    else
        mouseRoute := (mode = "ahi") ? "AHI route unavailable" : "Standard AutoHotkey"

    if (keyboardReady)
    {
        keyboardRoute := "AHI #" . LLARS_AHI_KEYBOARD_ID
        if IsObject(LLARS_AHI_KEYBOARD_INFO)
        {
            if (LLARS_AHI_KEYBOARD_INFO.VID || LLARS_AHI_KEYBOARD_INFO.PID)
                keyboardRoute .= " | " . Format("{:04X}:{:04X}", LLARS_AHI_KEYBOARD_INFO.VID, LLARS_AHI_KEYBOARD_INFO.PID)
            else if (Trim(LLARS_AHI_KEYBOARD_INFO.Handle) != "")
                keyboardRoute .= " | Connected HID"
        }
    }
    else
        keyboardRoute := (mode = "ahi") ? "AHI route unavailable" : "Standard AutoHotkey"

    if (mode != "ahi")
        fallback := "Standard mode selected"
    else if (mouseReady && keyboardReady)
        fallback := "None"
    else
        fallback := "Disabled in AHI mode; unavailable routes fail closed"

    gateText := (LLARS_AHI_GateElapsed = "") ? "n/a" : (LLARS_AHI_GateElapsed . " ms")
    initText := (LLARS_AHI_InitElapsed = "") ? "n/a" : (LLARS_AHI_InitElapsed . " ms")
    startup := "Gate " . gateText . " | Initialize " . initText

    if (mode != "ahi")
        compact := "Standard mode"
    else if (mouseReady && keyboardReady)
        compact := "AHI M" . LLARS_AHI_MOUSE_ID . " K" . LLARS_AHI_KEYBOARD_ID
    else if (mouseReady)
        compact := "AHI M" . LLARS_AHI_MOUSE_ID . " | K unavailable"
    else if (keyboardReady)
        compact := "AHI K" . LLARS_AHI_KEYBOARD_ID . " | M unavailable"
    else
        compact := "AHI unavailable"

    return {Configured: configured
        , Active: active
        , Driver: driver
        , MouseRoute: mouseRoute
        , KeyboardRoute: keyboardRoute
        , MouseLast: (LLARS_AHI_LAST_MOUSE_TRANSPORT = "" ? "<none>" : LLARS_AHI_LAST_MOUSE_TRANSPORT)
        , KeyboardLast: (LLARS_AHI_LAST_KEYBOARD_TRANSPORT = "" ? "<none>" : LLARS_AHI_LAST_KEYBOARD_TRANSPORT)
        , Startup: startup
        , Fallback: fallback
        , Compact: compact
        , StatusReason: LLARS_AHI_STATUS_REASON
        , StatusDetail: LLARS_AHI_STATUS_DETAIL}
}

; Non-invasive health test used by Input Settings. It does not send input or
; change subscription state; normal AHI initialization owns the non-blocking
; lifecycle subscriptions.
LLARS_AHI_SelfTest(projectRoot := "", ByRef summary := "")
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_MOUSE_SUBSCRIBED_ID, LLARS_AHI_KEYBOARD_SUBSCRIBED_ID
    global LLARS_AHI_MOUSE_ACTIVITY_ID, LLARS_AHI_MOUSE_ROUTE_VERIFIED
    global LLARS_AHI_MOUSE_PREFERRED_ID, LLARS_AHI_MOUSE_ALTERNATE_ACTIVE
    global LLARS_AHI_MOUSE_INFO, LLARS_AHI_KEYBOARD_INFO

    summary := ""
    if !LLARS_AHI_LibraryReady(projectRoot)
    {
        summary := "Bundled AHI runtime files are missing."
        return false
    }

    functionalReason := ""
    if !LLARS_AHI_FunctionalReady(projectRoot, functionalReason)
    {
        summary := "Interception is not ready on this Windows session.`n`n" . functionalReason
        return false
    }

    if (LLARS_AHI_Mode(projectRoot) != "ahi")
    {
        summary := "AHI runtime and driver checks passed.`n`nStandard AutoHotkey fallback is currently selected."
        return true
    }

    if !IsObject(LLARS_AHI_Object)
    {
        summary := "The AHI driver is available, but the LLARS AHI object is not initialized in this process."
        return false
    }

    if (!LLARS_AHI_MOUSE_READY || !LLARS_AHI_KEYBOARD_READY)
    {
        missing := ""
        if !LLARS_AHI_MOUSE_READY
            missing .= "mouse"
        if !LLARS_AHI_KEYBOARD_READY
            missing .= (missing = "" ? "" : " and ") . "keyboard"
        summary := "AHI is running, but LLARS could not resolve the " . missing . " route."
        return false
    }

    mousePhysical := LLARS_AHI_MOUSE_ROUTE_VERIFIED ? "Learned AHI #" . LLARS_AHI_MOUSE_PREFERRED_ID : "Awaiting a physical mouse click"
    if (LLARS_AHI_MOUSE_ACTIVITY_ID)
        mousePhysical .= " | Last event AHI #" . LLARS_AHI_MOUSE_ACTIVITY_ID
    routeRole := LLARS_AHI_MOUSE_ALTERNATE_ACTIVE ? "Stable transport (separate physical pointer)" : "Stable AHI transport"
    summary := "AHI health check passed.`n`nMouse output route: AHI #" . LLARS_AHI_MOUSE_ID . " | " . routeRole
        . "`nMouse transport reliability: " . LLARS_AHI_DeviceReliabilityText(LLARS_AHI_MOUSE_INFO, true)
        . "`nPhysical mouse route: " . mousePhysical
        . "`nMouse button discovery subscriptions: " . LLARS_AHI_MouseSubscriptionText()
        . "`nKeyboard route: AHI #" . LLARS_AHI_KEYBOARD_ID
        . " | " . LLARS_AHI_DeviceReliabilityText(LLARS_AHI_KEYBOARD_INFO, false)
        . "`nKeyboard lifecycle subscription: " . (LLARS_AHI_KEYBOARD_SUBSCRIBED_ID ? "AHI #" . LLARS_AHI_KEYBOARD_SUBSCRIBED_ID : "Not active")
        . "`n`nSubscriptions are non-blocking. No input was sent during this test."
    return true
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

    mode := LLARS_AHI_Mode(projectRoot)
    if (LLARS_AHI_MOUSE_READY)
        mouseRoute := "AHI Device " . LLARS_AHI_MOUSE_ID
    else
        mouseRoute := (mode = "ahi") ? "AHI Route Unavailable" : "Standard AutoHotkey"

    if (LLARS_AHI_KEYBOARD_READY)
        keyboardRoute := "AHI Device " . LLARS_AHI_KEYBOARD_ID
    else
        keyboardRoute := (mode = "ahi") ? "AHI Route Unavailable" : "Standard AutoHotkey"

    if (mode = "ahi")
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

    mode := LLARS_AHI_Mode(projectRoot)
    mouseBackend := LLARS_AHI_MOUSE_READY ? "AutoHotInterception (ID " . LLARS_AHI_MOUSE_ID . ")" : ((mode = "ahi") ? "AutoHotInterception (route unavailable)" : "Standard AutoHotkey")
    keyboardBackend := LLARS_AHI_KEYBOARD_READY ? "AutoHotInterception (ID " . LLARS_AHI_KEYBOARD_ID . ")" : ((mode = "ahi") ? "AutoHotInterception (route unavailable)" : "Standard AutoHotkey")
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
    ; Copy Support Report regenerates it live; failures still write it automatically.
}

LLARS_AHI_LogTransportFailure(kind, reason, detail := "")
{
    static logged := {}
    global LLARS_AHI_READY, LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL, LLARS_ROOT

    LLARS_AHI_READY := (LLARS_AHI_MOUSE_READY || LLARS_AHI_KEYBOARD_READY)
    LLARS_AHI_STATUS_REASON := kind . " AHI transport unavailable"
    LLARS_AHI_STATUS_DETAIL := detail
    LLARS_AHI_RecordTransport(kind, "AHI unavailable | " . reason)
    key := kind . "|" . reason
    if logged.HasKey(key)
        return
    logged[key] := true

    LLARS_AHI_DeveloperAction("Input Backend || " . kind . " AHI unavailable || " . reason)
    if (LLARS_ROOT != "")
    {
        LLARS_AHI_WriteSupportReport(LLARS_ROOT, "AHI transport unavailable: " . kind . " - " . reason)
        LLARS_AHI_DeveloperAction("Support || Report updated || Logs\LLARS-Support.txt")
    }
}


; Keeps LLARS-generated input transitions ordered and provides a virtual-desktop
; Interception transport for NaturalClick points without changing the trajectory.
LLARS_AHI_NativeTransportInitialize(projectRoot := "")
{
    global LLARS_AHI_NATIVE_MODULE, LLARS_AHI_NATIVE_CONTEXT
    global LLARS_AHI_NATIVE_SEND, LLARS_AHI_NATIVE_DESTROY

    LLARS_AHI_NativeTransportDispose()
    if (projectRoot = "")
        return false

    bitness := (A_PtrSize = 8) ? "x64" : "x86"
    dllFile := projectRoot . "\Vendor\AutoHotInterception\Lib\" . bitness . "\interception.dll"
    if !FileExist(dllFile)
        return false

    LLARS_AHI_NATIVE_MODULE := DllCall("Kernel32\LoadLibraryW", "WStr", dllFile, "Ptr")
    if (!LLARS_AHI_NATIVE_MODULE)
        return false

    createProc := DllCall("Kernel32\GetProcAddress", "Ptr", LLARS_AHI_NATIVE_MODULE, "AStr", "interception_create_context", "Ptr")
    LLARS_AHI_NATIVE_SEND := DllCall("Kernel32\GetProcAddress", "Ptr", LLARS_AHI_NATIVE_MODULE, "AStr", "interception_send", "Ptr")
    LLARS_AHI_NATIVE_DESTROY := DllCall("Kernel32\GetProcAddress", "Ptr", LLARS_AHI_NATIVE_MODULE, "AStr", "interception_destroy_context", "Ptr")
    if (!createProc || !LLARS_AHI_NATIVE_SEND || !LLARS_AHI_NATIVE_DESTROY)
    {
        LLARS_AHI_NativeTransportDispose()
        return false
    }

    LLARS_AHI_NATIVE_CONTEXT := DllCall(createProc, "CDecl Ptr")
    if (!LLARS_AHI_NATIVE_CONTEXT)
    {
        LLARS_AHI_NativeTransportDispose()
        return false
    }
    return true
}

LLARS_AHI_NativeTransportDispose()
{
    global LLARS_AHI_NATIVE_MODULE, LLARS_AHI_NATIVE_CONTEXT
    global LLARS_AHI_NATIVE_SEND, LLARS_AHI_NATIVE_DESTROY

    if (LLARS_AHI_NATIVE_CONTEXT && LLARS_AHI_NATIVE_DESTROY)
    {
        try DllCall(LLARS_AHI_NATIVE_DESTROY, "Ptr", LLARS_AHI_NATIVE_CONTEXT, "CDecl")
    }
    LLARS_AHI_NATIVE_CONTEXT := 0
    LLARS_AHI_NATIVE_SEND := 0
    LLARS_AHI_NATIVE_DESTROY := 0

    if (LLARS_AHI_NATIVE_MODULE)
        DllCall("Kernel32\FreeLibrary", "Ptr", LLARS_AHI_NATIVE_MODULE)
    LLARS_AHI_NATIVE_MODULE := 0
}

LLARS_AHI_SendVirtualAbsolute(mouseId, absoluteX, absoluteY)
{
    global LLARS_AHI_NATIVE_CONTEXT, LLARS_AHI_NATIVE_SEND
    if (!LLARS_AHI_NATIVE_CONTEXT || !LLARS_AHI_NATIVE_SEND)
        return false

    ; InterceptionMouseStroke: state(ushort), flags(ushort), rolling(short),
    ; alignment(2), x(int), y(int), information(uint).  VIRTUAL_DESKTOP and
    ; MOVE_NOCOALESCE preserve LLARS' point stream across multi-monitor layouts.
    VarSetCapacity(stroke, 20, 0)
    NumPut(0, stroke, 0, "UShort")
    NumPut(0x001 | 0x002 | 0x008, stroke, 2, "UShort")
    NumPut(0, stroke, 4, "Short")
    NumPut(Round(absoluteX), stroke, 8, "Int")
    NumPut(Round(absoluteY), stroke, 12, "Int")
    NumPut(0, stroke, 16, "UInt")
    sent := DllCall(LLARS_AHI_NATIVE_SEND, "Ptr", LLARS_AHI_NATIVE_CONTEXT, "Int", mouseId, "Ptr", &stroke, "UInt", 1, "CDecl Int")
    return (sent = 1)
}


LLARS_AHI_SendAbsolutePoint(absoluteX, absoluteY, ByRef transportText, ByRef errorDetail)
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_MOUSE_READY

    transportText := ""
    errorDetail := ""
    if (!LLARS_AHI_MOUSE_READY || !IsObject(LLARS_AHI_Object))
    {
        errorDetail := "AHI mouse route is not ready"
        return false
    }

    try
    {
        if LLARS_AHI_SendVirtualAbsolute(LLARS_AHI_MOUSE_ID, absoluteX, absoluteY)
        {
            transportText := "AHI Virtual Desktop Move | #" . LLARS_AHI_MOUSE_ID
            return true
        }

        ; The AHI wrapper's absolute path is valid when the Windows virtual
        ; desktop is exactly the primary display.
        SysGet, virtualLeft, 76
        SysGet, virtualTop, 77
        SysGet, virtualWidth, 78
        SysGet, virtualHeight, 79
        if (virtualLeft = 0 && virtualTop = 0 && virtualWidth = A_ScreenWidth && virtualHeight = A_ScreenHeight)
        {
            LLARS_AHI_Object.SendMouseMoveAbsolute(LLARS_AHI_MOUSE_ID, absoluteX, absoluteY)
            transportText := "AHI Absolute Move | #" . LLARS_AHI_MOUSE_ID
            return true
        }
        errorDetail := "Virtual-desktop Interception transport is unavailable"
    }
    catch e
    {
        errorDetail := e.Message
    }
    return false
}

LLARS_AHI_TransportName(kind := "")
{
    global LLARS_AHI_MOUSE_READY, LLARS_AHI_KEYBOARD_READY
    global LLARS_AHI_LAST_MOUSE_TRANSPORT, LLARS_AHI_LAST_KEYBOARD_TRANSPORT
    global LLARS_AHI_PROJECT_ROOT

    mode := (LLARS_AHI_PROJECT_ROOT = "") ? "ahi" : LLARS_AHI_Mode(LLARS_AHI_PROJECT_ROOT)
    if (mode = "ahi")
        return "AutoHotInterception"

    return "Standard AutoHotkey"
}

LLARS_AHI_KeyHeld(keyName)
{
    global LLARS_AHI_HELD_KEYS
    if !IsObject(LLARS_AHI_HELD_KEYS)
        return false
    keyId := Trim(keyName)
    StringLower, keyId, keyId
    return LLARS_AHI_HELD_KEYS.HasKey(keyId)
}

LLARS_AHI_ReleaseAllInput()
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_KEYBOARD_ID
    global LLARS_AHI_HELD_KEYS, LLARS_AHI_HELD_MOUSE, LLARS_CreatorExplicitKeyHolds

    wasCritical := A_IsCritical
    if (!wasCritical)
        Critical, On

    if !IsObject(LLARS_AHI_HELD_KEYS)
        LLARS_AHI_HELD_KEYS := {}
    if !IsObject(LLARS_AHI_HELD_MOUSE)
        LLARS_AHI_HELD_MOUSE := {}

    for keyId, heldInfo in LLARS_AHI_HELD_KEYS
    {
        released := false
        if (IsObject(LLARS_AHI_Object) && LLARS_AHI_KEYBOARD_ID)
        {
            try
            {
                LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, heldInfo.Scan, 0)
                released := true
            }
        }
        if (!released && heldInfo.Name != "")
        {
            keyUp := "{" . heldInfo.Name . " up}"
            SendEvent, %keyUp%
        }
    }
    LLARS_AHI_HELD_KEYS := {}

    ; Explicit creator holds can use either AHI or the compatibility backend.
    ; Clear any creator-side bookkeeping when a run is paused/stopped so a
    ; later key-up cannot inherit stale state from the previous run.
    if IsObject(LLARS_CreatorExplicitKeyHolds)
    {
        for explicitId, explicitInfo in LLARS_CreatorExplicitKeyHolds
        {
            if (explicitInfo.Transport != "AHI" && explicitInfo.Name != "")
            {
                keyUp := "{" . explicitInfo.Name . " up}"
                SendEvent, %keyUp%
            }
        }
        LLARS_CreatorExplicitKeyHolds := {}
    }

    for buttonName, heldInfo in LLARS_AHI_HELD_MOUSE
    {
        released := false
        if (IsObject(LLARS_AHI_Object) && LLARS_AHI_MOUSE_ID)
        {
            try
            {
                LLARS_AHI_Object.SendMouseButtonEvent(LLARS_AHI_MOUSE_ID, heldInfo.Code, 0)
                released := true
            }
        }
        if (!released)
        {
            if (buttonName = "right")
                Click, Right Up
            else if (buttonName = "middle")
                Click, Middle Up
            else if (buttonName = "xbutton1")
                Click, X1 Up
            else if (buttonName = "xbutton2")
                Click, X2 Up
            else
                Click, Up
        }
    }
    LLARS_AHI_HELD_MOUSE := {}

    if (!wasCritical)
        Critical, Off
    return true
}

LLARS_AHI_OnExit(exitReason := "", exitCode := 0)
{
    global LLARS_AHI_Object
    LLARS_AHI_ReleaseAllInput()
    LLARS_AHI_StopDeviceWatchdog()
    LLARS_AHI_UnsubscribeLifecycle()
    if IsObject(LLARS_AHI_Object)
    {
        try LLARS_AHI_Object.Instance.Dispose()
    }
    LLARS_AHI_NativeTransportDispose()
}

; Canonical RuneScape client-coordinate conversion for both AHI and native moves.
; This never uses an unrelated foreground window as a coordinate origin.
; The Selector includes the AHI transport without Core. Resolve the optional
; RuneScape validator dynamically so Selector entrypoints stay independent.
LLARS_AHI_IsValidRuneScapeTarget(hwnd)
{
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd) || !IsFunc("LLARS_IsRuneScapeWindow"))
        return false
    return Func("LLARS_IsRuneScapeWindow").Call(hwnd)
}

LLARS_AHI_ResolveMouseWindow(requestedHwnd := "")
{
    global LLARS_RunRuneScapeHwnd, LLARS_RUNNING
    hwnd := requestedHwnd
    if (hwnd = "" && LLARS_RUNNING && LLARS_RunRuneScapeHwnd)
        hwnd := LLARS_RunRuneScapeHwnd
    if (hwnd = "")
        hwnd := DllCall("user32\GetForegroundWindow", "Ptr")
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd) || !LLARS_AHI_IsValidRuneScapeTarget(hwnd))
        return 0
    ; LLARS' run guard may reclaim the game and retry. Never inject a point
    ; while another HWND owns focus (including during a focus transition).
    if (DllCall("user32\GetForegroundWindow", "Ptr") != hwnd)
        return 0
    return hwnd
}

LLARS_AHI_ClientPointToScreen(x, y, hwnd, ByRef screenX, ByRef screenY)
{
    screenX := "", screenY := ""
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd) || !LLARS_AHI_IsValidRuneScapeTarget(hwnd))
        return false
    VarSetCapacity(point, 8, 0)
    NumPut(Round(x), point, 0, "Int")
    NumPut(Round(y), point, 4, "Int")
    if !DllCall("user32\ClientToScreen", "Ptr", hwnd, "Ptr", &point)
        return false
    screenX := NumGet(point, 0, "Int")
    screenY := NumGet(point, 4, "Int")
    return true
}

; GetCursorPos always returns physical screen coordinates. ScreenToClient
; maps those coordinates back through the SAME RuneScape window, regardless
; of current AutoHotkey CoordMode or another window's client origin.
LLARS_AHI_CursorClientPoint(hwnd, ByRef clientX, ByRef clientY, ByRef screenX := "", ByRef screenY := "")
{
    clientX := "", clientY := "", screenX := "", screenY := ""
    if (!hwnd || !DllCall("user32\IsWindow", "Ptr", hwnd) || !LLARS_AHI_IsValidRuneScapeTarget(hwnd))
        return false
    VarSetCapacity(point, 8, 0)
    if !DllCall("user32\GetCursorPos", "Ptr", &point)
        return false
    screenX := NumGet(point, 0, "Int")
    screenY := NumGet(point, 4, "Int")
    if !DllCall("user32\ScreenToClient", "Ptr", hwnd, "Ptr", &point)
        return false
    clientX := NumGet(point, 0, "Int")
    clientY := NumGet(point, 4, "Int")
    return true
}

; Verify the physical pointer BEFORE a button event. AHI movement acceptance
; does not by itself prove that Windows moved the pointer to the requested cell.
LLARS_AHI_VerifyCursorClientPoint(hwnd, x, y, tolerance := 2)
{
    if !LLARS_AHI_ClientPointToScreen(x, y, hwnd, expectedScreenX, expectedScreenY)
        return false
    if !LLARS_AHI_CursorClientPoint(hwnd, currentX, currentY, cursorScreenX, cursorScreenY)
        return false
    if (Abs(currentX-x) > tolerance || Abs(currentY-y) > tolerance
        || Abs(cursorScreenX-expectedScreenX) > tolerance || Abs(cursorScreenY-expectedScreenY) > tolerance)
    {
        LLARS_AHI_DeveloperAction("Coordinate Mismatch || Hwnd=" . hwnd . " || TargetClient=(" . x . ", " . y . ") || TargetScreen=(" . expectedScreenX . ", " . expectedScreenY . ") || CursorClient=(" . currentX . ", " . currentY . ") || CursorScreen=(" . cursorScreenX . ", " . cursorScreenY . ")")
        return false
    }
    return true
}

; Client -> physical screen -> virtual-desktop absolute; the supplied HWND is
; fixed by the caller for the entire NaturalClick trajectory.
LLARS_AHI_ClientPointToAbsolute(x, y, ByRef absoluteX, ByRef absoluteY, runeScapeHwnd := "")
{
    hwnd := LLARS_AHI_ResolveMouseWindow(runeScapeHwnd)
    if (!hwnd || !LLARS_AHI_ClientPointToScreen(x, y, hwnd, screenX, screenY))
        return false
    SysGet, virtualLeft, 76
    SysGet, virtualTop, 77
    SysGet, virtualWidth, 78
    SysGet, virtualHeight, 79
    if (virtualWidth <= 1 || virtualHeight <= 1)
        return false
    if (screenX < virtualLeft || screenY < virtualTop || screenX >= (virtualLeft + virtualWidth) || screenY >= (virtualTop + virtualHeight))
        return false
    absoluteX := Round(((screenX - virtualLeft) * 65535.0) / (virtualWidth - 1))
    absoluteY := Round(((screenY - virtualTop) * 65535.0) / (virtualHeight - 1))
    absoluteX := Max(0, Min(65535, absoluteX))
    absoluteY := Max(0, Min(65535, absoluteY))
    return true
}

; Shared mouse movement backend.
;
; Fidelity rule:
;   * NaturalClick/curve points remain exactly the points LLARS already calculated.
;   * When AHI is active, every requested endpoint is transported through AHI.
;     The legacy speed argument is retained for caller compatibility/diagnostics;
;     LLARS never falls through to native MouseMove while AHI mode is active.
LLARS_InputMouseMove(x, y, speed := "", runeScapeHwnd := "")
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_MOUSE_READY
    global LLARS_AHI_STATUS_DETAIL, LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED
    global LLARS_AHI_PROJECT_ROOT

    hwnd := LLARS_AHI_ResolveMouseWindow(runeScapeHwnd)
    if (!hwnd)
    {
        LLARS_AHI_LogTransportFailure("Mouse", "RuneScape window unavailable or lost focus during movement")
        return false
    }

    ; Standard mode also uses the SAME locked client origin. For the explicit
    ; NaturalClick points, SetCursorPos avoids active-window CoordMode drift.
    if (LLARS_AHI_PROJECT_ROOT != "" && LLARS_AHI_Mode(LLARS_AHI_PROJECT_ROOT) != "ahi")
    {
        if !LLARS_AHI_ClientPointToScreen(x, y, hwnd, screenX, screenY)
        {
            LLARS_AHI_LogTransportFailure("Mouse", "Client-to-screen conversion failed")
            return false
        }
        if (speed = 0 || speed = "")
        {
            if !DllCall("user32\SetCursorPos", "Int", screenX, "Int", screenY)
                return false
        }
        else
        {
            ; The native compatibility speed applies in physical screen space.
            CoordMode, Mouse, Screen
            MouseMove, %screenX%, %screenY%, %speed%
            CoordMode, Mouse, Client
        }
        LLARS_AHI_RecordTransport("mouse", "Standard AHK compatibility move | " . (speed = "" ? "Default speed" : "Speed=" . speed))
        return true
    }

    if (!LLARS_AHI_MOUSE_READY || !IsObject(LLARS_AHI_Object))
    {
        if !LLARS_AHI_AttemptTransportRecovery("mouse", "Movement route recovery")
        {
            LLARS_AHI_LogTransportFailure("Mouse", "Movement route unavailable")
            return false
        }
    }

    if !LLARS_AHI_ClientPointToAbsolute(x, y, absoluteX, absoluteY, hwnd)
    {
        LLARS_AHI_LogTransportFailure("Mouse", "Movement coordinate conversion failed")
        return false
    }

    errorDetail := ""
    if LLARS_AHI_SendAbsolutePoint(absoluteX, absoluteY, transportText, errorDetail)
    {
        if (speed != "" && speed != 0)
            transportText .= " | Requested speed=" . speed
        LLARS_AHI_RecordTransport("mouse", transportText)
        return true
    }

    if LLARS_AHI_AttemptTransportRecovery("mouse", "Movement transport recovery", errorDetail)
    {
        retryDetail := ""
        if LLARS_AHI_SendAbsolutePoint(absoluteX, absoluteY, retryTransport, retryDetail)
        {
            if (speed != "" && speed != 0)
                retryTransport .= " | Requested speed=" . speed
            LLARS_AHI_RecordTransport("mouse", retryTransport . " | Rebound")
            return true
        }
        if (retryDetail != "")
            errorDetail .= (errorDetail = "" ? "" : " | ") . "Retry=" . retryDetail
    }

    LLARS_AHI_ABSOLUTE_TRANSPORT_FAILED := true
    LLARS_AHI_STATUS_DETAIL := errorDetail
    LLARS_AHI_MOUSE_READY := false
    LLARS_AHI_LogTransportFailure("Mouse", "Movement transport error", errorDetail)
    return false
}

LLARS_InputMouseButton(button := "left", state := 1)
{
    global LLARS_AHI_Object, LLARS_AHI_MOUSE_ID, LLARS_AHI_MOUSE_READY
    global LLARS_AHI_HELD_MOUSE, LLARS_AHI_PROJECT_ROOT

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

    if !IsObject(LLARS_AHI_HELD_MOUSE)
        LLARS_AHI_HELD_MOUSE := {}

    state := state ? 1 : 0
    if (state && LLARS_AHI_HELD_MOUSE.HasKey(button))
        return true
    if (!state && !LLARS_AHI_HELD_MOUSE.HasKey(button))
        return true

    if (LLARS_AHI_PROJECT_ROOT != "" && LLARS_AHI_Mode(LLARS_AHI_PROJECT_ROOT) != "ahi")
    {
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
        if (state)
            LLARS_AHI_HELD_MOUSE[button] := {Code:code}
        else
            LLARS_AHI_HELD_MOUSE.Delete(button)
        LLARS_AHI_RecordTransport("mouse", "Standard AHK " . button . (state ? " down" : " up"))
        return true
    }

    if (!LLARS_AHI_MOUSE_READY || !IsObject(LLARS_AHI_Object))
    {
        if !LLARS_AHI_AttemptTransportRecovery("mouse", "Button route recovery")
        {
            LLARS_AHI_LogTransportFailure("Mouse", "Button route unavailable")
            return false
        }
    }

    try
    {
        LLARS_AHI_Object.SendMouseButtonEvent(LLARS_AHI_MOUSE_ID, code, state)
        if (state)
            LLARS_AHI_HELD_MOUSE[button] := {Code:code}
        else
            LLARS_AHI_HELD_MOUSE.Delete(button)
        LLARS_AHI_RecordTransport("mouse", "AHI " . button . (state ? " down" : " up") . " | #" . LLARS_AHI_MOUSE_ID)
        return true
    }
    catch e
    {
        firstError := e.Message
        if LLARS_AHI_AttemptTransportRecovery("mouse", "Button transport recovery", firstError)
        {
            try
            {
                LLARS_AHI_Object.SendMouseButtonEvent(LLARS_AHI_MOUSE_ID, code, state)
                if (state)
                    LLARS_AHI_HELD_MOUSE[button] := {Code:code}
                else
                    LLARS_AHI_HELD_MOUSE.Delete(button)
                LLARS_AHI_RecordTransport("mouse", "AHI " . button . (state ? " down" : " up") . " | #" . LLARS_AHI_MOUSE_ID . " | Rebound")
                return true
            }
            catch retryError
            {
                firstError .= " | Retry=" . retryError.Message
            }
        }

        if (state)
        {
            try LLARS_AHI_Object.SendMouseButtonEvent(LLARS_AHI_MOUSE_ID, code, 0)
        }
        LLARS_AHI_HELD_MOUSE.Delete(button)
        LLARS_AHI_MOUSE_READY := false
        LLARS_AHI_LogTransportFailure("Mouse", "Button transport error", firstError)
        return false
    }
}

; Centralized drag transport for future LLARS drag actions. It uses the same
; movement and held-button helpers as NaturalClick so the selected backend stays consistent.
LLARS_InputMouseDrag(startX, startY, endX, endY, button := "left", speed := 0)
{
    hwnd := LLARS_AHI_ResolveMouseWindow()
    if (!hwnd)
        return false
    if !LLARS_InputMouseMove(startX, startY, 0, hwnd)
        return false
    if !LLARS_InputMouseButton(button, 1)
        return false

    moved := LLARS_InputMouseMove(endX, endY, speed, hwnd)
    released := LLARS_InputMouseButton(button, 0)
    transportName := LLARS_AHI_TransportName("mouse")
    LLARS_AHI_DeveloperAction("Mouse Drag || " . button . " || (" . startX . ", " . startY . ") -> (" . endX . ", " . endY . ") || " . transportName)
    return (moved && released)
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
        firstError := e.Message
        if LLARS_AHI_AttemptTransportRecovery("mouse", "Wheel transport recovery", firstError)
        {
            try
            {
                LLARS_AHI_Object.SendMouseButtonEvent(LLARS_AHI_MOUSE_ID, code, state)
                LLARS_AHI_RecordTransport("mouse", "AHI " . keyName . " | #" . LLARS_AHI_MOUSE_ID . " | Rebound")
                return true
            }
            catch retryError
            {
                firstError .= " | Retry=" . retryError.Message
            }
        }
        LLARS_AHI_MOUSE_READY := false
        LLARS_AHI_LogTransportFailure("Mouse", "Wheel transport error", firstError)
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
    global LLARS_AHI_HELD_KEYS
    if (!LLARS_AHI_KEYBOARD_READY || !IsObject(LLARS_AHI_Object))
        return false

    scanCode := LLARS_AHI_KeyScanCode(keyName)
    if (!scanCode)
        return false

    if !IsObject(LLARS_AHI_HELD_KEYS)
        LLARS_AHI_HELD_KEYS := {}
    keyId := Trim(keyName)
    StringLower, keyId, keyId
    state := state ? 1 : 0
    if (state && LLARS_AHI_HELD_KEYS.HasKey(keyId))
        return true
    if (!state && !LLARS_AHI_HELD_KEYS.HasKey(keyId))
        return true

    try
    {
        LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, scanCode, state)
        if (state)
            LLARS_AHI_HELD_KEYS[keyId] := {Name:keyName, Scan:scanCode}
        else
            LLARS_AHI_HELD_KEYS.Delete(keyId)
        LLARS_AHI_RecordTransport("keyboard", "AHI " . keyName . (state ? " down" : " up") . " | #" . LLARS_AHI_KEYBOARD_ID)
        return true
    }
    catch e
    {
        firstError := e.Message
        if LLARS_AHI_AttemptTransportRecovery("keyboard", "Key transport recovery", firstError)
        {
            try
            {
                LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, scanCode, state)
                if (state)
                    LLARS_AHI_HELD_KEYS[keyId] := {Name:keyName, Scan:scanCode}
                else
                    LLARS_AHI_HELD_KEYS.Delete(keyId)
                LLARS_AHI_RecordTransport("keyboard", "AHI " . keyName . (state ? " down" : " up") . " | #" . LLARS_AHI_KEYBOARD_ID . " | Rebound")
                return true
            }
            catch retryError
            {
                firstError .= " | Retry=" . retryError.Message
            }
        }

        if (state)
        {
            try LLARS_AHI_Object.SendKeyEvent(LLARS_AHI_KEYBOARD_ID, scanCode, 0)
        }
        LLARS_AHI_HELD_KEYS.Delete(keyId)
        LLARS_AHI_KEYBOARD_READY := false
        LLARS_AHI_LogTransportFailure("Keyboard", "Key transport error", firstError)
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

    if !IsObject(LLARS_AHI_Object)
        return false
    ; The keyboard can reconnect after startup or change its Interception ID.
    ; Give the existing bounded route-recovery mechanism one opportunity to
    ; rebind before refusing a Creator keyboard action.
    if (!LLARS_AHI_KEYBOARD_READY)
    {
        if !LLARS_AHI_AttemptTransportRecovery("keyboard", "Creator keyboard route unavailable")
            return false
        if (!LLARS_AHI_KEYBOARD_READY || !IsObject(LLARS_AHI_Object))
            return false
    }

    if !LLARS_AHI_ParseModifiers(prefix, modifierKeys)
        return false

    if (LLARS_AHI_KeyScanCode(keyName) = 0)
        return false
    for _, modifierKey in modifierKeys
    {
        if (LLARS_AHI_KeyScanCode(modifierKey) = 0)
            return false
    }

    ; A timed press cannot claim success when a separate action already owns
    ; the key in the held-key tracker. Report a rejected send to the caller;
    ; otherwise generated scripts silently skip the user's saved key action.
    if LLARS_AHI_KeyHeld(keyName)
    {
        LLARS_AHI_DeveloperAction("Keyboard Safety || Press rejected because " . keyName . " is already held")
        return false
    }

    wasCritical := A_IsCritical
    if (!wasCritical)
        Critical, On

    ownedModifiers := []
    baseDown := false
    try
    {
        for _, modifierKey in modifierKeys
        {
            if !LLARS_AHI_KeyHeld(modifierKey)
            {
                if !LLARS_AHI_SendKeyState(modifierKey, 1)
                    throw Exception("Modifier down failed: " . modifierKey)
                ownedModifiers.Push(modifierKey)
            }
            if (keyDelay > 0)
                Sleep, %keyDelay%
        }

        DllCall("QueryPerformanceFrequency", "Int64*", keyHoldPerformanceFrequency)
        if !LLARS_AHI_SendKeyState(keyName, 1)
            throw Exception("Key down failed: " . keyName)
        baseDown := true
        DllCall("QueryPerformanceCounter", "Int64*", keyHoldStartCounter)
        if (keyHold > 0)
            Sleep, %keyHold%
        DllCall("QueryPerformanceCounter", "Int64*", keyHoldEndCounter)
        if !LLARS_AHI_SendKeyState(keyName, 0)
            throw Exception("Key up failed: " . keyName)
        baseDown := false

        if (keyHoldPerformanceFrequency > 0)
            LLARS_AHI_LAST_KEY_HOLD_MS := Round(((keyHoldEndCounter - keyHoldStartCounter) * 1000.0) / keyHoldPerformanceFrequency)
        else
            LLARS_AHI_LAST_KEY_HOLD_MS := keyHold

        index := ownedModifiers.MaxIndex()
        while (index >= 1)
        {
            if (keyDelay > 0)
                Sleep, %keyDelay%
            if !LLARS_AHI_SendKeyState(ownedModifiers[index], 0)
                throw Exception("Modifier up failed: " . ownedModifiers[index])
            index--
        }
        LLARS_AHI_RecordTransport("keyboard", "AHI " . sendSequence . " | #" . LLARS_AHI_KEYBOARD_ID)
        if (!wasCritical)
            Critical, Off
        return true
    }
    catch e
    {
        if (baseDown)
            LLARS_AHI_SendKeyState(keyName, 0)
        index := ownedModifiers.MaxIndex()
        while (index >= 1)
        {
            LLARS_AHI_SendKeyState(ownedModifiers[index], 0)
            index--
        }
        if (!wasCritical)
            Critical, Off
        LLARS_AHI_KEYBOARD_READY := false
        LLARS_AHI_LogTransportFailure("Keyboard", "Sequence transport error", e.Message)
        return false
    }
}
