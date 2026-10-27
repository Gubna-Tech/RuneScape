; ================================================================
; |     LLARS SUPPORT     -     DIAGNOSTICS & SUPPORT EXPORT     |
; ================================================================
; Owns bounded framework diagnostics, support-event history, privacy-safe
; support bundle generation, detection snapshots, and issue reporting.

; Records framework warning/error/recovery state in the existing Developer Action stream.
; This is intentionally lightweight: no additional log file or persistent telemetry store is created.
LLARS_DiagnosticRecord(kind, summary, detail := "")
{
	global LLARS_DiagnosticWarnings, LLARS_DiagnosticErrors, LLARS_DiagnosticRecoveries, LLARS_LastDiagnostic

	kind := Trim(kind)
	summary := Trim(summary)
	detail := Trim(detail)
	if (kind = "")
		kind := "Info"
	if (summary = "")
		summary := "Framework diagnostic"

	kindLower := kind
	StringLower, kindLower, kindLower
	if (kindLower = "warning" || kindLower = "blocked")
		LLARS_DiagnosticWarnings++
	else if (kindLower = "error")
		LLARS_DiagnosticErrors++
	else if (kindLower = "recovery" || kindLower = "recovered")
		LLARS_DiagnosticRecoveries++

	LLARS_LastDiagnostic := kind . ": " . summary
	LLARS_SupportEvent("Diagnostic " . kind, summary)
	action := "Diagnostic || " . kind . " || " . summary
	if (detail != "")
		action .= " || " . detail
	LLARS_DeveloperAction(action)
	return true
}

; Returns the compact diagnostic state consumed by Developer/support reporting.
LLARS_DiagnosticSnapshot()
{
	global LLARS_DiagnosticWarnings, LLARS_DiagnosticErrors, LLARS_DiagnosticRecoveries, LLARS_LastDiagnostic
	return {Warnings:(LLARS_DiagnosticWarnings + 0)
		, Errors:(LLARS_DiagnosticErrors + 0)
		, Recoveries:(LLARS_DiagnosticRecoveries + 0)
		, Last:(LLARS_LastDiagnostic = "" ? "None" : LLARS_LastDiagnostic)}
}

; Keeps a bounded, privacy-safe framework event history for support bundles.
; This intentionally records lifecycle/diagnostic events rather than mouse
; coordinates, hotkey values, or arbitrary configuration contents.
LLARS_SupportEvent(eventName, detail := "")
{
	global LLARS_SupportEvents, LLARS_SupportEventMax, LLARS_SupportEventSerial

	if !IsObject(LLARS_SupportEvents)
		LLARS_SupportEvents := []
	if (LLARS_SupportEventMax < 1)
		LLARS_SupportEventMax := 150

	eventName := LLARS_SupportSanitizeText(Trim(eventName))
	detail := LLARS_SupportSanitizeText(Trim(detail))
	if (eventName = "")
		eventName := "Framework event"

	FormatTime, eventTime,, HH:mm:ss
	LLARS_SupportEventSerial++
	line := eventTime . " | " . eventName
	if (detail != "")
		line .= " | " . detail
	LLARS_SupportEvents.Push(line)
	while (LLARS_SupportEvents.Length() > LLARS_SupportEventMax)
		LLARS_SupportEvents.RemoveAt(1)
	return true
}

; Removes workstation-specific paths and configuration-shaped secrets from
; support text before it can be written to disk.
LLARS_SupportSanitizeText(text)
{
	global LLARS_ROOT

	if (text = "")
		return ""
	if IsFunc("LLARS_AHI_SanitizeSupportText")
		text := Func("LLARS_AHI_SanitizeSupportText").Call(text, LLARS_ROOT)
	else
	{
		if (LLARS_ROOT != "")
			text := StrReplace(text, LLARS_ROOT, "<LLARS_ROOT>")
		EnvGet, userProfile, USERPROFILE
		if (userProfile != "")
			text := StrReplace(text, userProfile, "<USERPROFILE>")
		if (A_UserName != "")
			text := StrReplace(text, A_UserName, "<USER>")
	}

	; Event/support text must never carry configured coordinate values.
	text := RegExReplace(text, "i)\b(x|y|xmin|xmax|ymin|ymax)\s*=\s*-?\d+", "$1=<redacted>")
	return text
}

; Returns the bounded support-event history as plain text.
LLARS_SupportEventSnapshot()
{
	global LLARS_SupportEvents

	if !IsObject(LLARS_SupportEvents) || LLARS_SupportEvents.Length() = 0
		return "No framework events have been recorded for this run."

	text := ""
	for _, line in LLARS_SupportEvents
		text .= line . "`r`n"
	return RTrim(text, "`r`n")
}

LLARS_SupportRelativePath(root, path)
{
	root := RTrim(root, "\/")
	if (root != "" && InStr(path, root . "\") = 1)
		return SubStr(path, StrLen(root) + 2)
	return A_ScriptName
}

; Formats only structural setup states; configured values are never exported.
LLARS_SupportSetupSummary()
{
	preflight := LLARS_BuildSetupPreflight(true)
	if !IsObject(preflight) || !IsObject(preflight.Items)
		return "Unavailable"

	text := ""
	for _, itemName in ["Hotkeys", "Coordinates", "Colors", "Timer", "Script Config", "Input Backend"]
	{
		item := preflight.Items[itemName]
		if (text != "")
			text .= " | "
		text .= itemName . "=" . item.State
	}
	return text
}

; Builds the allowlisted high-level environment summary for support export.
LLARS_SupportSummaryText()
{
	global LLARS_ROOT, LLARS_RUNNING, LLARS_PAUSED, LLARS_RUN_TYPE

	FormatTime, generated,, yyyy-MM-dd HH:mm:ss
	version := LLARS_GetVersion(LLARS_ROOT)
	entryPoint := LLARS_SupportRelativePath(LLARS_ROOT, A_ScriptFullPath)
	inputMode := LLARS_AHI_Mode(LLARS_ROOT)
	if (inputMode = "standard")
		inputState := "Standard AutoHotkey"
	else if (LLARS_AHI_IsReady("mouse") && LLARS_AHI_IsReady("keyboard"))
		inputState := "AutoHotInterception ready"
	else
		inputState := "AutoHotInterception unavailable/fallback"

	schemaExplicit := false
	schemaError := ""
	configSchema := LLARS_GetConfigSchema(LLARS_ROOT, schemaExplicit, schemaError)
	if (configSchema < 1)
		configSchema := "Unavailable"

	runState := LLARS_RUNNING ? (LLARS_PAUSED ? "Paused" : "Running") : "Idle"
	runType := (LLARS_RUN_TYPE = "" ? "Not Started" : LLARS_RUN_TYPE)
	clientText := "Not detected"
	clientHwnd := LLARS_FindRuneScapeWindow()
	if (clientHwnd)
	{
		WinGetPos, , , clientWidth, clientHeight, ahk_id %clientHwnd%
		clientText := clientWidth . "x" . clientHeight
	}

	text := "LLARS Support Summary`r`n"
	text .= "Generated: " . generated . "`r`n"
	text .= "LLARS Version: v" . version . "`r`n"
	text .= "AutoHotkey: " . A_AhkVersion . " | " . (A_PtrSize = 8 ? "64-bit" : "32-bit") . "`r`n"
	text .= "Windows: " . A_OSVersion . " | " . (A_Is64bitOS ? "64-bit" : "32-bit") . "`r`n"
	text .= "Entry Point: " . entryPoint . "`r`n"
	text .= "Input Backend: " . inputMode . " | " . inputState . "`r`n"
	text .= "Config Schema: " . configSchema . "`r`n"
	text .= "Setup: " . LLARS_SupportSetupSummary() . "`r`n"
	text .= "Run State: " . runState . " | Type=" . runType . "`r`n"
	text .= "RuneScape Client Size: " . clientText . "`r`n"
	return LLARS_SupportSanitizeText(text)
}

; Builds framework diagnostics without exporting configured values or paths.
LLARS_SupportDiagnosticsText()
{
	global LLARS_RUNTIME_ESTIMATE_SOURCE, LLARS_RUNTIME_ESTIMATE_CONFIDENCE
	global LLARS_RuntimeEstimateSource, LLARS_RuntimeEstimateConfidence
	global LLARS_AHI_STATUS_REASON, LLARS_AHI_STATUS_DETAIL

	diagnostic := LLARS_DiagnosticSnapshot()
	estimateSource := LLARS_RuntimeEstimateSource
	estimateConfidence := LLARS_RuntimeEstimateConfidence
	if (estimateSource = "")
		estimateSource := "Not calculated"
	if (estimateConfidence = "")
		estimateConfidence := "Not calculated"

	text := "LLARS Framework Diagnostics`r`n"
	text .= "Warnings: " . diagnostic.Warnings . "`r`n"
	text .= "Errors: " . diagnostic.Errors . "`r`n"
	text .= "Recoveries: " . diagnostic.Recoveries . "`r`n"
	text .= "Last Diagnostic: " . diagnostic.Last . "`r`n"
	text .= "Runtime Estimate Source: " . estimateSource . "`r`n"
	text .= "Runtime Estimate Confidence: " . estimateConfidence . "`r`n"
	text .= "AHI Status: " . (LLARS_AHI_STATUS_REASON = "" ? "None" : LLARS_AHI_STATUS_REASON) . "`r`n"
	if (LLARS_AHI_STATUS_DETAIL != "")
		text .= "AHI Detail: " . LLARS_AHI_STATUS_DETAIL . "`r`n"
	return LLARS_SupportSanitizeText(text)
}

LLARS_SupportWriteText(path, text)
{
	file := FileOpen(path, "w", "UTF-8-RAW")
	if !IsObject(file)
		return false
	file.Write(text)
	file.Close()
	return true
}

; Exports one privacy-safe four-file support ZIP. Exported categories are
; allowlisted; full configs, configured coordinates/hotkeys, usernames,
; screenshots, credentials, and arbitrary user files are never included.
LLARS_CreateSupportBundle(root := "", showPreview := true)
{
	global LLARS_ROOT

	if (root = "")
		root := LLARS_ROOT
	root := RTrim(root, "\/")
	if (root = "")
		return false

	if (showPreview)
	{
		preview := "Create a privacy-safe LLARS support bundle?`n`nIncluded:`n- LLARS/Windows/AutoHotkey version and selected script`n- Input/AHI health and setup status states`n- Framework diagnostic counters/state`n- Installation integrity results`n- Up to 150 recent framework lifecycle/diagnostic events`n`nExcluded:`n- Windows username and absolute user-profile paths`n- Exact coordinates and hotkey bindings`n- Full Config.ini files`n- Tokens, credentials, screenshots, and unrelated files"
		MsgBox, 0x40024, LLARS Support Bundle, %preview%
		IfMsgBox, No
			return false
	}

	LLARS_SupportEvent("Support bundle requested")
	logsDir := root . "\Logs"
	if !FileExist(logsDir)
		FileCreateDir, %logsDir%
	if !FileExist(logsDir)
	{
		LLARS_ReportError("LLARS Support Bundle", "LLARS could not create its Logs folder.", "No support bundle was created.", "Move LLARS to a writable folder and try again.")
		return false
	}

	FormatTime, bundleStamp,, yyyyMMdd-HHmmss
	processId := DllCall("Kernel32\GetCurrentProcessId", "UInt")
	tempDir := logsDir . "\LLARS-Support-Temp-" . processId
	bundlePath := logsDir . "\LLARS-Support-" . bundleStamp . "-" . processId . ".zip"
	FileRemoveDir, %tempDir%, 1
	FileDelete, %bundlePath%
	FileCreateDir, %tempDir%
	if !FileExist(tempDir)
	{
		LLARS_ReportError("LLARS Support Bundle", "LLARS could not create the temporary support folder.", "No support bundle was created.", "Move LLARS to a writable folder and try again.")
		return false
	}

	integrity := LLARS_VerifyInstallation(root, true)
	summaryText := LLARS_SupportSummaryText()
	diagnosticsText := LLARS_SupportDiagnosticsText()
	integrityText := LLARS_SupportSanitizeText(LLARS_IntegrityResultText(integrity))
	eventsText := LLARS_SupportEventSnapshot()

	writeOk := LLARS_SupportWriteText(tempDir . "\summary.txt", summaryText)
	writeOk := LLARS_SupportWriteText(tempDir . "\diagnostics.txt", diagnosticsText) && writeOk
	writeOk := LLARS_SupportWriteText(tempDir . "\integrity.txt", integrityText) && writeOk
	writeOk := LLARS_SupportWriteText(tempDir . "\recent-events.txt", eventsText) && writeOk
	if (!writeOk)
	{
		FileRemoveDir, %tempDir%, 1
		LLARS_ReportError("LLARS Support Bundle", "LLARS could not write all support files.", "No incomplete ZIP was kept.", "Move LLARS to a writable folder and try again.")
		return false
	}

	psSource := StrReplace(tempDir . "\*", "'", "''")
	psBundle := StrReplace(bundlePath, "'", "''")
	command := "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ""Compress-Archive -Path '" . psSource . "' -DestinationPath '" . psBundle . "' -Force"""
	RunWait, %command%,, Hide UseErrorLevel
	zipExitCode := ErrorLevel
	FileRemoveDir, %tempDir%, 1

	if (zipExitCode != 0 || !FileExist(bundlePath))
	{
		FileDelete, %bundlePath%
		LLARS_ReportError("LLARS Support Bundle", "Windows could not create the support ZIP.", "No incomplete ZIP was kept.", "Confirm Windows PowerShell is available, then try again.")
		return false
	}

	LLARS_SupportEvent("Support bundle created", "Logs\\" . RegExReplace(bundlePath, "^.*\\"))
	MsgBox, 0x40040, LLARS Support Bundle, % "Support bundle created successfully.`n`n" . LLARS_SupportRelativePath(root, bundlePath) . "`n`nYou can review the four text files inside before sharing it."
	return bundlePath
}

; Tracks the latest shared detection state for Developer Mode and support reporting.
; This is process-local diagnostic state only; scripts keep their own gameplay state machines.
LLARS_DetectionRecord(name, state, confidence := "", threshold := "", detail := "", logChange := true)
{
	global LLARS_DetectionName, LLARS_DetectionState, LLARS_DetectionConfidence, LLARS_DetectionThreshold
	global LLARS_DetectionDetail, LLARS_DetectionTick, LLARS_DetectionSignature

	name := Trim(name)
	state := Trim(state)
	detail := Trim(detail)
	if (name = "")
		name := "Detection"
	if (state = "")
		state := "Unknown"

	LLARS_DetectionName := name
	LLARS_DetectionState := state
	LLARS_DetectionConfidence := confidence
	LLARS_DetectionThreshold := threshold
	LLARS_DetectionDetail := detail
	LLARS_DetectionTick := LLARS_NowMS()

	signature := name . "|" . state . "|" . confidence . "|" . threshold . "|" . detail
	if (logChange && signature != LLARS_DetectionSignature)
	{
		action := "Detection || " . name . " || " . state
		if (confidence != "")
			action .= " || Confidence=" . confidence
		if (threshold != "")
			action .= " || Threshold=" . threshold
		if (detail != "")
			action .= " || " . detail
		LLARS_DeveloperAction(action)
	}
	LLARS_DetectionSignature := signature
	return true
}

LLARS_DetectionSnapshot()
{
	global LLARS_DetectionName, LLARS_DetectionState, LLARS_DetectionConfidence, LLARS_DetectionThreshold
	global LLARS_DetectionDetail, LLARS_DetectionTick
	return {Name:(LLARS_DetectionName = "" ? "None" : LLARS_DetectionName)
		, State:(LLARS_DetectionState = "" ? "Idle" : LLARS_DetectionState)
		, Confidence:LLARS_DetectionConfidence
		, Threshold:LLARS_DetectionThreshold
		, Detail:LLARS_DetectionDetail
		, Tick:(LLARS_DetectionTick + 0)}
}

LLARS_DetectionDisplay(short := false)
{
	state := LLARS_DetectionSnapshot()
	if !IsObject(state)
		return "None"
	text := short ? state.State : (state.Name . " " . state.State)
	if (state.Confidence != "")
	{
		text .= " " . state.Confidence
		if (state.Threshold != "")
			text .= "/" . state.Threshold
	}
	if (!short && state.Detail != "")
		text .= " | " . state.Detail
	return text
}

; Standard user-facing issue format: what happened, what LLARS did, and what to do next.
LLARS_ReportIssue(severity, title, whatHappened, whatLLARSDid := "", whatUserShouldDo := "", detail := "", showMessage := true)
{
	severity := Trim(severity)
	title := Trim(title)
	whatHappened := Trim(whatHappened)
	whatLLARSDid := Trim(whatLLARSDid)
	whatUserShouldDo := Trim(whatUserShouldDo)
	if (title = "")
		title := "LLARS"
	if (whatHappened = "")
		whatHappened := "An unexpected framework condition occurred."

	LLARS_DiagnosticRecord(severity, whatHappened, detail)
	if (!showMessage)
		return false

	message := "What happened:`n" . whatHappened
	if (whatLLARSDid != "")
		message .= "`n`nWhat LLARS did:`n" . whatLLARSDid
	if (whatUserShouldDo != "")
		message .= "`n`nWhat you should do:`n" . whatUserShouldDo

	severityLower := severity
	StringLower, severityLower, severityLower
	if (severityLower = "error")
		options := 0x40010
	else if (severityLower = "warning" || severityLower = "blocked")
		options := 0x40030
	else
		options := 0x40040
	MsgBox, %options%, %title%, %message%
	return false
}

LLARS_ReportWarning(title, whatHappened, whatLLARSDid := "", whatUserShouldDo := "", detail := "", showMessage := true)
{
	return LLARS_ReportIssue("Warning", title, whatHappened, whatLLARSDid, whatUserShouldDo, detail, showMessage)
}

LLARS_ReportError(title, whatHappened, whatLLARSDid := "", whatUserShouldDo := "", detail := "", showMessage := true)
{
	return LLARS_ReportIssue("Error", title, whatHappened, whatLLARSDid, whatUserShouldDo, detail, showMessage)
}

; Recovery events stay non-modal and flow into the same existing Developer/support stream.
LLARS_ReportRecovery(summary, detail := "")
{
	return LLARS_DiagnosticRecord("Recovery", summary, detail)
}
