; ================================================================
; |     LLARS CREATOR CATALOG     -     LLARS CREATOR CATALOG    |
; ================================================================

; ================================================================
; |     CREATOR API CATALOG     -     CREATOR API CATALOG        |
; ================================================================
; Returns authoritative metadata for creator-facing LLARS functions.
; The Script Generator, creator help, and validation can consume this
; catalog without maintaining a second list of framework behavior.
LLARS_CreatorAPICatalog(includeCompatibility := true)
{
	static catalog := ""

	if !IsObject(catalog)
	{
		catalog := {}
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigRead", "Config Read", "Creator Public", "Configuration", "Reads one configuration value without exposing IniRead boilerplate to scripts.", "section, key, default := ""ERROR"", scope := ""script""", "section=config_section;key=config_key;default=any;scope=scope", "any_or_default", false, false, "config_section", false, false, "value := LLARS_ConfigRead(""Options"", ""value"", """")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigWrite", "Config Write", "Creator Public", "Configuration", "Writes one configuration value through the shared path resolver.", "section, key, value, scope := ""script""", "section=config_section;key=config_key;value=any;scope=scope", "boolean", false, false, "config_section", false, false, "LLARS_ConfigWrite(""Timer"", ""min"", 5000)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigSections", "Config Sections", "Creator Public", "Configuration", "Returns the normalized newline-delimited section list used by LLARS config discovery.", "scope := ""script"", default := ""ERROR""", "scope=scope;default=any", "newline_delimited_string_or_default", false, false, "config_section", false, false, "sections := LLARS_ConfigSections()", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadString", "Config Read String", "Creator Public", "Configuration", "Reads a trimmed text value.", "section, key, default := """", required := false, scope := ""script""", "section=config_section;key=config_key;default=any;required=boolean;scope=scope", "string", false, false, "config_section", false, false, "name := LLARS_ConfigReadString(""Options"", ""name"", ""Default"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadInteger", "Config Read Integer", "Creator Public", "Configuration", "Reads a whole-number setting without silently rounding decimals.", "section, key, default := """", minAllowed := """", maxAllowed := """", scope := ""script""", "section=config_section;key=config_key;default=any;minAllowed=number_or_blank;maxAllowed=number_or_blank;scope=scope", "integer_or_default", false, false, "config_section", false, false, "count := LLARS_ConfigReadInteger(""Options"", ""count"", 1, 1, 100)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadBool", "Config Read Bool", "Creator Public", "Configuration", "Reads a boolean value using creator-facing Read naming.", "section, key := ""option"", default := false, scope := ""script""", "section=config_section;key=config_key;default=boolean;scope=scope", "boolean", false, false, "config_section", false, false, "enabled := LLARS_ConfigReadBool(""Feature"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadNumber", "Config Read Number", "Creator Public", "Configuration", "Reads one numeric value and optionally enforces an allowed minimum/maximum.", "section, key, default := """", minAllowed := """", maxAllowed := """", scope := ""script""", "section=config_section;key=config_key;default=any;minAllowed=number_or_blank;maxAllowed=number_or_blank;scope=scope", "number_or_default", false, false, "config_section", false, false, "threshold := LLARS_ConfigReadNumber(""Options"", ""threshold"", 0.5, 0, 1)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadChoice", "Config Read Choice", "Creator Public", "Configuration", "Reads a value that must match one of the supplied choices.", "section, key, choices, default := """", required := false, scope := ""script""", "section=config_section;key=config_key;choices=string_list;default=any;required=boolean;scope=scope", "string_or_default", false, false, "config_section", false, false, "mode := LLARS_ConfigReadChoice(""Options"", ""mode"", [""Fast"", ""Normal""], ""Normal"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadHotkey", "Config Read Hotkey", "Creator Public", "Configuration", "Reads and validates a configured hotkey.", "section, key := ""hotkey"", scope := ""script""", "section=config_hotkey;key=config_key;scope=scope", "hotkey_or_blank", false, false, "hotkey", false, false, "hotkey := LLARS_ConfigReadHotkey(""Action Hotkey"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadColor", "Config Read Color", "Creator Public", "Configuration", "Reads and validates an RGB color.", "section, key := """", scope := ""script""", "section=config_color;key=config_key;scope=scope", "color_hex_or_blank", false, false, "color", false, false, "color := LLARS_ConfigReadColor(""Target Color"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigEnabled", "Config Enabled", "Creator Public", "Configuration", "Returns whether a typed/optional section is currently enabled.", "section, default := true, scope := ""script""", "section=config_section;default=any;scope=scope", "boolean", false, false, "config_section", true, false, "if LLARS_ConfigEnabled(""Optional Feature"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadRange", "Config Read Range", "Creator Public", "Configuration", "Preferred creator-facing name for reading a configured min/max pair.", "section, ByRef minValue, ByRef maxValue, scope := ""script""", "section=config_timing_range;minValue=out_number;maxValue=out_number;scope=scope", "boolean", false, false, "timing_range", false, false, "LLARS_ConfigReadRange(""Action Delay"", minValue, maxValue)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigReadPoint", "Config Read Point", "Creator Public", "Configuration", "Preferred creator-facing name for resolving a fixed or randomized point.", "section, ByRef x, ByRef y, scope := ""script""", "section=config_coordinate;x=out_number;y=out_number;scope=scope", "boolean", false, false, "coordinate", false, false, "LLARS_ConfigReadPoint(""Action Location"", x, y)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_RunActive", "Run Active", "Creator Public", "Script lifecycle", "Returns true only while a LLARS run is active and not paused.", "requireRuneScape := false", "requireRuneScape=boolean", "boolean", false, false, "none", true, false, "if LLARS_RunActive()", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_RunCount", "Run Count", "Creator Public", "Script lifecycle", "Runs a complete RunCount session around one creator callback and supplies iteration context.", "callback", "callback=callback", "boolean", false, true, "none", false, false, "LLARS_RunCount(Func(""RunTask""))", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_WaitForRuneScape", "Wait For RuneScape", "Creator Public", "Script lifecycle", "Waits for the RuneScape window bound to the active run before specialized game-facing work continues.", "action := ""Automation"", requireRun := true", "action=string;requireRun=boolean", "hwnd_or_false", false, true, "none", false, false, "if !LLARS_WaitForRuneScape(""Target scan"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_StartTimerRun", "Start Timer Run", "Creator Public", "Script lifecycle", "Validates and starts a duration-based script using the user's run time.", "", "", "boolean", false, true, "none", false, false, "if !LLARS_StartTimerRun()", "needs_generator_adapter", "LLARS_RunTiming.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_Sleep", "Sleep", "Creator Public", "Timing", "Reads a configured timer, randomizes it, records the exact framework action, and sleeps.", "section, final := false, scope := ""script""", "section=config_timing_range;final=boolean;scope=scope", "milliseconds", false, true, "timing_range", true, false, "LLARS_Sleep(""Action Delay"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_RandomSleep", "Random Sleep", "Creator Public", "Timing", "Runs the optional shared Random Sleep configured in LLARS Config.ini.", "", "", "milliseconds", false, true, "shared_random_sleep", true, false, "LLARS_RandomSleep()", "good_as_is", "LLARS_RunTiming.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_TimerInterval", "Timer Interval", "Creator Public", "Timing", "Returns one randomized interval for a SetTimer-based script.", "section, scope := ""script""", "section=config_timer;scope=scope", "milliseconds", false, false, "timer", false, false, "interval := LLARS_TimerInterval(""Script Timer"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_TimerOnce", "Timer Once", "Creator Public", "Timing", "Schedules a creator callback once after a randomized interval from the named timer section.", "section, callback, scope := ""script""", "section=config_timer;callback=callback;scope=scope", "timer_handle_or_zero", false, false, "timer", false, false, "timerID := LLARS_TimerOnce(""Startup Delay"", Func(""DoOnce""))", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_TimerRepeat", "Timer Repeat", "Creator Public", "Timing", "Repeats a creator callback using a freshly randomized interval after every callback.", "section, callback, scope := ""script""", "section=config_timer;callback=callback;scope=scope", "timer_handle_or_zero", false, false, "timer", false, false, "timerID := LLARS_TimerRepeat(""Script Timer"", Func(""Tick""))", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_TimerStop", "Timer Stop", "Creator Public", "Timing", "Stops one managed timer.", "timerRef", "timerRef=timer_handle_or_label", "boolean", false, false, "none", false, false, "LLARS_TimerStop(timerID)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_TimerStopAll", "Timer Stop All", "Creator Public", "Timing", "Stops every timer created through the Creator API.", "", "", "void", false, false, "none", false, false, "LLARS_TimerStopAll()", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_Click", "Click", "Creator Public", "Mouse", "Clicks a configured fixed point or randomized coordinate rectangle using the RuneScape-only NaturalClick safety checks.", "section, button := ""left"", scope := ""script""", "section=config_coordinate;button=mouse_button;scope=scope", "boolean", true, true, "coordinate", true, false, "LLARS_Click(""Action Location"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_RedClick", "Red Click", "Creator Public", "Mouse", "Clicks a configured coordinate and requires RuneScape red-click confirmation.", "section, button := ""left"", scope := ""script""", "section=config_coordinate;button=mouse_button;scope=scope", "boolean", true, true, "coordinate", true, false, "LLARS_RedClick(""World Object"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_RedClickRetry", "Red Click Retry", "Creator Public", "Mouse", "Nonfatal RedClick variant.", "section, button := ""left"", scope := ""script""", "section=config_coordinate;button=mouse_button;scope=scope", "boolean", true, true, "coordinate", true, false, "if !LLARS_RedClickRetry(""World Object"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ClickPoint", "Click Point", "Creator Public", "Mouse", "Clicks a runtime client coordinate, retrying the same intended click after a temporary focus loss while the run remains active.", "x, y, button := ""left"", actionName := ""Pixel Target""", "x=number;y=number;button=mouse_button;actionName=string", "boolean", true, true, "none", false, false, "LLARS_ClickPoint(foundX, foundY, ""left"", ""Detected target"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_RedClickPoint", "Red Click Point", "Creator Public", "Mouse", "Runtime-coordinate version of LLARS_RedClick.", "x, y, button := ""left"", actionName := ""Verified Pixel Target""", "x=number;y=number;button=mouse_button;actionName=string", "boolean", true, true, "none", false, false, "LLARS_RedClickPoint(foundX, foundY, ""left"", ""Detected world object"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_RedClickRetryPoint", "Red Click Retry Point", "Creator Public", "Mouse", "Runtime-coordinate nonfatal RedClick.", "x, y, button := ""left"", actionName := ""Retryable Verified Pixel Target""", "x=number;y=number;button=mouse_button;actionName=string", "boolean", true, true, "none", false, false, "if !LLARS_RedClickRetryPoint(foundX, foundY)", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PressKey", "Press Key", "Creator Public", "Keyboard", "Presses one plain key through the shared RuneScape-safe input path.", "keyName", "keyName=key_name", "boolean", true, true, "none", true, false, "LLARS_PressKey(""Space"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PressHotkey", "Press Hotkey", "Creator Public", "Keyboard", "Reads a typed hotkey section and presses that combination in RuneScape.", "section, key := ""hotkey"", scope := ""script""", "section=config_hotkey;key=config_key;scope=scope", "boolean", true, true, "hotkey", true, false, "LLARS_PressHotkey(""Action Hotkey"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_SetStatus", "Set Status", "Creator Public", "Status", "Updates the standard LLARS status row without requiring scripts to know the underlying GUI control names.", "status, activity := """"", "status=string;activity=string", "void", false, false, "none", true, false, "LLARS_SetStatus(""Working"", ""Bank"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		catalog["LLARS_SetStatus"].PreviewKind := "status"
		LLARS_CreatorCatalogAdd(catalog, "LLARS_LogEvent", "Log Event", "Creator Public", "Status", "Records a creator-defined event in the existing Developer Mode/support stream.", "summary, detail := """"", "summary=string;detail=string", "void", false, false, "none", true, false, "LLARS_LogEvent(""Bank cycle"", ""Opened bank"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_Warn", "Warn", "Creator Public", "Status", "Records and optionally shows a structured creator warning.", "title, whatHappened, whatLLARSDid := """", whatUserShouldDo := """", detail := """", showMessage := true", "title=string;whatHappened=string;whatLLARSDid=string;whatUserShouldDo=string;detail=string;showMessage=boolean", "void", false, false, "none", true, false, "LLARS_Warn(""Target not found"", ""No valid target matched."", ""No click was sent."")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_Error", "Error", "Creator Public", "Status", "Records and optionally shows a structured creator error.", "title, whatHappened, whatLLARSDid := """", whatUserShouldDo := """", detail := """", showMessage := true", "title=string;whatHappened=string;whatLLARSDid=string;whatUserShouldDo=string;detail=string;showMessage=boolean", "void", false, false, "none", true, false, "LLARS_Error(""Configuration error"", ""Required setting is invalid."")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_Recovered", "Recovered", "Creator Public", "Status", "Records a successful creator recovery or fallback event.", "summary, detail := """"", "summary=string;detail=string", "void", false, false, "none", true, false, "LLARS_Recovered(""Target reacquired"", ""Nearby scan succeeded"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_SetDetection", "Set Detection", "Creator Public", "Status", "Publishes creator detection state to the existing Live Inspector/support report.", "name, state, confidence := """", threshold := """", detail := """", logChange := true", "name=string;state=string;confidence=number_or_blank;threshold=number_or_blank;detail=string;logChange=boolean", "void", false, false, "none", true, false, "LLARS_SetDetection(""Target"", ""Searching"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PixelColor", "Pixel Color", "Creator Public", "Conditions", "Reads the current RGB color at an exact configured x/y pixel coordinate.", "coordinateSection, scope := ""script""", "coordinateSection=config_coordinate;scope=scope", "color_hex_or_blank", false, false, "coordinate", true, false, "currentColor := LLARS_PixelColor(""Pixel Coordinate"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PixelMatches", "Pixel Matches", "Creator Public", "Conditions", "Returns true when a configured pixel coordinate currently matches a configured RGB color.", "coordinateSection, colorSection, scope := ""script""", "coordinateSection=config_coordinate;colorSection=config_color;scope=scope", "boolean", false, false, "coordinate,color", true, false, "if LLARS_PixelMatches(""Pixel Coordinate"", ""Target Color"")", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PixelMatchesAny", "Pixel Matches Any", "Creator Public", "Conditions", "Compares one configured pixel against several configured color sections while sampling the pixel only once.", "coordinateSection, colorSections, scope := ""script""", "coordinateSection=config_coordinate;colorSections=config_color_list;scope=scope", "section_name_or_blank", false, false, "coordinate,color", true, false, "matched := LLARS_PixelMatchesAny(""Pixel Coordinate"", [""State One"", ""State Two""])", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PixelChangedFrom", "Pixel Changed From", "Creator Public", "Conditions", "Returns true when a configured pixel differs from a supplied baseline color and returns the current color.", "coordinateSection, baselineColor, ByRef currentColor, scope := ""script""", "coordinateSection=config_coordinate;baselineColor=color_hex;currentColor=out_color_hex;scope=scope", "boolean", false, false, "coordinate", false, false, "if LLARS_PixelChangedFrom(""Pixel Coordinate"", baselineColor, currentColor)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PixelMatchesWithinTolerance", "Pixel Matches Within Tolerance", "Creator Public", "Conditions", "Compares a configured pixel and color with per-channel RGB tolerance.", "coordinateSection, colorSection, tolerance := 0, scope := ""script""", "coordinateSection=config_coordinate;colorSection=config_color;tolerance=integer;scope=scope", "boolean", false, false, "coordinate,color", true, false, "if LLARS_PixelMatchesWithinTolerance(""Pixel Coordinate"", ""Target Color"", 3)", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_FindColorCenterOut", "Find Color Center Out", "Creator Public", "Colors", "Searches the visible RuneScape client from the center outward for any enabled configured color section.", "colorSections, ByRef foundX, ByRef foundY, ByRef matchedSection, avoidSection := """", searchName := ""Color"", avoidX := """", avoidY := """", scope := ""script"", tolerance := 0, allowAvoidFallback := false, requireNeighborhood := false", "colorSections=config_color_list;foundX=out_number;foundY=out_number;matchedSection=out_string;avoidSection=config_color_or_blank;searchName=string;avoidX=number_or_blank;avoidY=number_or_blank;scope=scope;tolerance=integer;allowAvoidFallback=boolean;requireNeighborhood=boolean", "boolean", false, false, "color", false, false, "if LLARS_FindColorCenterOut([""Target Color""], foundX, foundY, matchedSection)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_VerifyColorTarget", "Verify Color Target", "Creator Public", "Colors", "Reacquires a configured color near a previously found point on a fresh frame.", "ByRef x, ByRef y, colorSection, actionName := ""Color"", scope := ""script"", radius := 28, tolerance := 0, confirmationDelay := 0, confirmationRadius := """"", "x=out_number;y=out_number;colorSection=config_color;actionName=string;scope=scope;radius=integer;tolerance=integer;confirmationDelay=integer;confirmationRadius=integer_or_blank", "boolean", false, false, "color", false, false, "if LLARS_VerifyColorTarget(foundX, foundY, matchedSection)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigSectionExists", "Config Section Exists", "Creator Advanced", "Configuration", "Returns true when a named section exists in the selected configuration file.", "section, scope := ""script""", "section=config_section;scope=scope", "boolean", false, false, "config_section", false, true, "if LLARS_ConfigSectionExists(""Options"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigKeyExists", "Config Key Exists", "Creator Advanced", "Configuration", "Returns true when a key exists inside a named configuration section.", "section, key, scope := ""script""", "section=config_section;key=config_key;scope=scope", "boolean", false, false, "config_section", false, true, "if LLARS_ConfigKeyExists(""Options"", ""mode"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigDelete", "Config Delete", "Creator Advanced", "Configuration", "Deletes a configuration key (or an entire section when key is blank).", "section, key := """", scope := ""script""", "section=config_section;key=config_key;scope=scope", "boolean", false, false, "config_section", false, true, "LLARS_ConfigDelete(""Temporary"", ""value"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigKeys", "Config Keys", "Creator Advanced", "Configuration", "Returns the normalized key list for one section.", "section, scope := ""script"", default := ""ERROR""", "section=config_section;scope=scope;default=any", "newline_delimited_string_or_default", false, false, "config_section", false, true, "keys := LLARS_ConfigKeys(""Options"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PixelChangedFromRuneScapePrintWindow", "Pixel Changed From RuneScape Print Window", "Creator Advanced", "Conditions", "Reads a configured pixel from the RuneScape client off-screen render and reports whether it changed from a baseline color.", "coordinateSection, baselineColor, ByRef currentColor, scope := ""script""", "coordinateSection=config_coordinate;baselineColor=color_hex;currentColor=out_color_hex;scope=scope", "boolean", false, false, "coordinate", false, true, "if LLARS_PixelChangedFromRuneScapePrintWindow(""Pixel Coordinate"", baselineColor, currentColor)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_PixelMatchesWithinTolerancePrintWindow", "Pixel Matches Within Tolerance Print Window", "Creator Advanced", "Conditions", "Matches a configured pixel and color through the supported off-screen capture path with RGB tolerance.", "coordinateSection, colorSection, tolerance := 0, scope := ""script""", "coordinateSection=config_coordinate;colorSection=config_color;tolerance=integer;scope=scope", "boolean", false, false, "coordinate,color", false, true, "if LLARS_PixelMatchesWithinTolerancePrintWindow(""Pixel Coordinate"", ""Target Color"", 3)", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorResolveMatcher", "Color Resolve Matcher", "Creator Advanced", "Colors", "Resolves a script-supplied RGB matcher so color detection can reuse the same capture, cluster, verification, and tracking machinery for different objects.", "matcher", "matcher=color_matcher", "callable_or_false", false, false, "none", false, true, "matcherFunc := LLARS_ColorResolveMatcher(matcher)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorGetRuneScapeClient", "Color Get RuneScape Client", "Creator Advanced", "Colors", "Returns the active RuneScape client geometry without forcing focus.", "ByRef hWnd, ByRef clientWidth, ByRef clientHeight, requireRun := true", "hWnd=out_hwnd;clientWidth=integer;clientHeight=integer;requireRun=boolean", "boolean", false, false, "none", false, true, "if LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorCaptureVisibleClient", "Color Capture Visible Client", "Creator Advanced", "Colors", "Captures the visible foreground RuneScape client using the normal desktop path.", "hWnd, clientWidth, clientHeight, ByRef captureMethod := """"", "hWnd=hwnd;clientWidth=integer;clientHeight=integer;captureMethod=out_string", "capture_object_or_false", false, false, "none", false, true, "capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorCaptureHasContent", "Color Capture Has Content", "Creator Advanced", "Colors", "Rejects empty/black off-screen captures before any detector trusts the frame.", "bits, width, height", "bits=pixel_buffer;width=integer;height=integer", "boolean", false, false, "none", false, true, "if LLARS_ColorCaptureHasContent(bits, width, height)", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorCaptureBackgroundClient", "Color Capture Background Client", "Creator Advanced", "Colors", "Captures one full client frame through PrintWindow.", "hWnd, clientWidth, clientHeight, ByRef captureMethod := """"", "hWnd=hwnd;clientWidth=integer;clientHeight=integer;captureMethod=out_string", "capture_object_or_false", false, false, "none", false, true, "capture := LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, captureMethod)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorDensity", "Color Density", "Creator Advanced", "Colors", "Counts matcher-qualified pixels around a point using a configurable sample grid.", "capture, matcher, centerX, centerY, radius := 32, sampleStep := 4", "capture=capture_object;matcher=color_matcher;centerX=integer;centerY=integer;radius=integer;sampleStep=integer", "integer", false, false, "none", false, true, "density := LLARS_ColorDensity(capture, matcher, centerX, centerY)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorFindLargeClusterFromCapture", "Color Find Large Cluster From Capture", "Creator Advanced", "Colors", "Finds the large matcher-qualified cluster nearest the client center and chooses a dense interior point rather than an edge/background pixel.", "capture, matcher, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity, minimumClusterSamples := 260, sampleStep := 4, cellSize := 48, minimumPointDensity := 30, pointDensityRadius := 8, pointDensityStep := 2, targetDensityRadius := 32, targetDensityStep := 4, selectionMode := ""spread""", "capture=capture_object;matcher=color_matcher;foundX=out_number;foundY=out_number;targetScore=out_number;targetDensity=out_number;minimumClusterSamples=integer;sampleStep=integer;cellSize=integer;minimumPointDensity=integer;pointDensityRadius=integer;pointDensityStep=integer;targetDensityRadius=integer;targetDensityStep=integer;selectionMode=selection_mode", "boolean", false, false, "none", false, true, "if LLARS_ColorFindLargeClusterFromCapture(capture, matcher, foundX, foundY, targetScore, targetDensity)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorFindRuneScapeLargeCluster", "Color Find RuneScape Large Cluster", "Creator Advanced", "Colors", "Foreground-only convenience wrapper for large-cluster acquisition.", "matcher, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity, minimumClusterSamples := 260, sampleStep := 4, cellSize := 48, minimumPointDensity := 30, pointDensityRadius := 8, pointDensityStep := 2, targetDensityRadius := 32, targetDensityStep := 4, selectionMode := ""spread""", "matcher=color_matcher;foundX=out_number;foundY=out_number;targetScore=out_number;targetDensity=out_number;minimumClusterSamples=integer;sampleStep=integer;cellSize=integer;minimumPointDensity=integer;pointDensityRadius=integer;pointDensityStep=integer;targetDensityRadius=integer;targetDensityStep=integer;selectionMode=selection_mode", "boolean", false, false, "none", false, true, "if LLARS_ColorFindRuneScapeLargeCluster(matcher, foundX, foundY, targetScore, targetDensity)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorReacquireDensePoint", "Color Reacquire Dense Point", "Creator Advanced", "Colors", "Keeps the chosen dense point when it remains safe; otherwise reacquires nearby.", "capture, matcher, ByRef clientX, ByRef clientY, radius := 24, minimumDensity := 20, densityRadius := 6, densityStep := 2", "capture=capture_object;matcher=color_matcher;clientX=out_number;clientY=out_number;radius=integer;minimumDensity=any;densityRadius=any;densityStep=any", "boolean", false, false, "none", false, true, "if LLARS_ColorReacquireDensePoint(capture, matcher, clientX, clientY)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorClickDenseTarget", "Color Click Dense Target", "Creator Advanced", "Colors", "Verifies that a target is still a dense match immediately before clicking it.", "ByRef clientX, ByRef clientY, matcher, actionName := ""Color Target"", button := ""left"", reacquireRadius := 24, minimumReacquireDensity := 20, minimumTargetDensity := 40, targetDensityRadius := 32, targetDensityStep := 4, verifyRedClick := false, retryRedClick := false", "clientX=out_number;clientY=out_number;matcher=color_matcher;actionName=string;button=mouse_button;reacquireRadius=integer;minimumReacquireDensity=integer;minimumTargetDensity=integer;targetDensityRadius=integer;targetDensityStep=integer;verifyRedClick=boolean;retryRedClick=boolean", "boolean", true, true, "none", false, true, "if LLARS_ColorClickDenseTarget(clientX, clientY, matcher, ""Target"")", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorTrackConnectedComponent", "Color Track Connected Component", "Creator Advanced", "Colors", "Tracks only the connected matcher-qualified component attached to the last known target point.", "capture, matcher, ByRef clientX, ByRef clientY, ByRef trackingScore, radius := 118, seedRadius := 34, step := 4, minimumSamples := 78, minimumWidth := 38, minimumHeight := 38", "capture=capture_object;matcher=color_matcher;clientX=out_number;clientY=out_number;trackingScore=out_number;radius=integer;seedRadius=integer;step=integer;minimumSamples=integer;minimumWidth=integer;minimumHeight=integer", "boolean", false, false, "none", false, true, "if LLARS_ColorTrackConnectedComponent(capture, matcher, clientX, clientY, trackingScore)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorBuildComponentSignature", "Color Build Component Signature", "Creator Advanced", "Colors", "Builds a compact, spatially distributed signature from one connected color component.", "capture, matcher, centerX, centerY, radius := 46, seedRadius := 8, componentStep := 2, minimumSamples := 12, minimumWidth := 8, minimumHeight := 8, gridSize := 3", "capture=capture_object;matcher=color_matcher;centerX=integer;centerY=integer;radius=integer;seedRadius=integer;componentStep=integer;minimumSamples=integer;minimumWidth=integer;minimumHeight=integer;gridSize=integer", "signature_object_or_false", false, false, "none", false, true, "signature := LLARS_ColorBuildComponentSignature(capture, matcher, centerX, centerY)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorBuildRuneScapeComponentSignature", "Color Build RuneScape Component Signature", "Creator Advanced", "Colors", "Foreground convenience wrapper for building a component signature immediately after a target is acquired/clicked.", "matcher, centerX, centerY, radius := 46, seedRadius := 8, componentStep := 2, minimumSamples := 12, minimumWidth := 8, minimumHeight := 8, gridSize := 3", "matcher=color_matcher;centerX=integer;centerY=integer;radius=integer;seedRadius=integer;componentStep=integer;minimumSamples=integer;minimumWidth=integer;minimumHeight=integer;gridSize=integer", "signature_object_or_false", false, false, "none", false, true, "signature := LLARS_ColorBuildRuneScapeComponentSignature(matcher, centerX, centerY)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorSignaturePointMatches", "Color Signature Point Matches", "Creator Advanced", "Colors", "Tests whether a signature point still matches near the requested capture coordinate.", "capture, matcherFunc, x, y, radius := 2", "capture=capture_object;matcherFunc=callback;x=number;y=number;radius=integer", "boolean", false, false, "none", false, true, "if LLARS_ColorSignaturePointMatches(capture, matcherFunc, x, y)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorMatchComponentSignature", "Color Match Component Signature", "Creator Advanced", "Colors", "Matches a previously built component signature inside a small translation window.", "capture, signature, matcher, ByRef matchRatio := 0.0, ByRef matchedPoints := 0, searchRadius := 8, searchStep := 2, pointRadius := 2, minimumRatio := 0.45, minimumMatchedPoints := 4, minimumCoverage := 0.0", "capture=capture_object;signature=signature_object;matcher=color_matcher;matchRatio=out_number;matchedPoints=out_integer;searchRadius=integer;searchStep=integer;pointRadius=integer;minimumRatio=number_or_blank;minimumMatchedPoints=integer;minimumCoverage=number_or_blank", "boolean", false, false, "none", false, true, "if LLARS_ColorMatchComponentSignature(capture, signature, matcher, matchRatio, matchedPoints)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorTrackRuneScapeSignature", "Color Track RuneScape Signature", "Creator Advanced", "Colors", "Tracks a DTM-style component signature in foreground or through the throttled PrintWindow(flags=3) background path used by the connected tracker.", "signature, matcher, ByRef matchRatio, ByRef matchedPoints, trackerKey := ""Color Signature"", searchRadius := 8, searchStep := 2, pointRadius := 2, minimumRatio := 0.45, minimumMatchedPoints := 4, backgroundInterval := 2000, useContextMenuGuard := true, minimumCoverage := 0.0", "signature=signature_object;matcher=color_matcher;matchRatio=out_number;matchedPoints=out_integer;trackerKey=string;searchRadius=integer;searchStep=integer;pointRadius=integer;minimumRatio=number_or_blank;minimumMatchedPoints=integer;backgroundInterval=integer;useContextMenuGuard=boolean;minimumCoverage=number_or_blank", "tri_state", false, false, "none", false, true, "state := LLARS_ColorTrackRuneScapeSignature(signature, matcher, matchRatio, matchedPoints)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorContextMenuOverlapsTarget", "Color Context Menu Overlaps Target", "Creator Advanced", "Colors", "RuneScape right-click menus are dark text panels that can visually cover a target.", "capture, centerX, centerY", "capture=capture_object;centerX=integer;centerY=integer", "boolean", false, false, "none", false, true, "if LLARS_ColorContextMenuOverlapsTarget(capture, centerX, centerY)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorBuildStableRegionSignature", "Color Build Stable Region Signature", "Creator Advanced", "Colors", "Builds a reusable signature from stable pixels inside one capture region.", "frameA, frameB, left, top, right, bottom, sampleStep := 3, stabilityThreshold := 14, maximumBrightness := """", maximumChroma := """"", "frameA=capture_object;frameB=capture_object;left=integer;top=integer;right=integer;bottom=integer;sampleStep=integer;stabilityThreshold=integer;maximumBrightness=number_or_blank;maximumChroma=number_or_blank", "signature_object_or_false", false, false, "none", false, true, "signature := LLARS_ColorBuildStableRegionSignature(frameA, frameB, left, top, right, bottom)", "good_as_is", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorRegionSignatureDifference", "Color Region Signature Difference", "Creator Advanced", "Colors", "Compares a live frame against a previously learned stable-region signature.", "capture, signature, differenceThreshold := 38, ByRef changedSamples := 0, ByRef totalSamples := 0", "capture=capture_object;signature=signature_object;differenceThreshold=integer;changedSamples=out_number;totalSamples=out_number", "number_or_false", false, false, "none", false, true, "difference := LLARS_ColorRegionSignatureDifference(capture, signature, 38, changedSamples, totalSamples)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorFrameMovementPercent", "Color Frame Movement Percent", "Creator Advanced", "Colors", "Measures broad frame movement while ignoring pixels accepted by the supplied object matcher so target animation does not look like camera motion.", "frameA, frameB, ignoreMatcher := """", step := 20, differenceThreshold := 85", "frameA=capture_object;frameB=capture_object;ignoreMatcher=color_matcher_or_blank;step=integer;differenceThreshold=integer", "number", false, false, "none", false, true, "movement := LLARS_ColorFrameMovementPercent(frameA, frameB)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ColorTrackRuneScapeTarget", "Color Track RuneScape Target", "Creator Advanced", "Colors", "Returns 1 while the same connected target is present, 0 for a trustworthy absent frame, and -1 when capture, occlusion, throttling, or motion is unsafe.", "ByRef clientX, ByRef clientY, matcher, ByRef trackingScore, ByRef cameraMotion, trackerKey := ""Color Target"", componentRadius := 118, seedRadius := 34, componentStep := 4, minimumSamples := 78, minimumWidth := 38, minimumHeight := 38, backgroundInterval := 2000, motionThreshold := 18.0, confirmationDelay := 110, useContextMenuGuard := true", "clientX=out_number;clientY=out_number;matcher=color_matcher;trackingScore=out_number;cameraMotion=out_number;trackerKey=string;componentRadius=integer;seedRadius=integer;componentStep=integer;minimumSamples=integer;minimumWidth=integer;minimumHeight=integer;backgroundInterval=integer;motionThreshold=number_or_blank;confirmationDelay=integer;useContextMenuGuard=boolean", "tri_state", false, false, "none", false, true, "state := LLARS_ColorTrackRuneScapeTarget(clientX, clientY, matcher, trackingScore, cameraMotion)", "needs_generator_adapter", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigHasSection", "Config Has Section", "Legacy Compatibility", "Configuration", "Compatibility alias for LLARS_ConfigSectionExists.", "section, scope := ""script""", "section=config_section;scope=scope", "boolean", false, false, "config_section", false, false, "if LLARS_ConfigHasSection(""Options"")", "future_compatibility_cleanup", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigHasKey", "Config Has Key", "Legacy Compatibility", "Configuration", "Compatibility alias for LLARS_ConfigKeyExists.", "section, key, scope := ""script""", "section=config_section;key=config_key;scope=scope", "boolean", false, false, "config_section", false, false, "if LLARS_ConfigHasKey(""Options"", ""mode"")", "future_compatibility_cleanup", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigBool", "Config Bool", "Legacy Compatibility", "Configuration", "Reads a true/false setting and returns an actual boolean value.", "section, key, default := false, scope := ""script""", "section=config_section;key=config_key;default=boolean;scope=scope", "boolean", false, false, "config_section", false, false, "enabled := LLARS_ConfigBool(""Feature"", ""option"", false)", "future_compatibility_cleanup", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigRange", "Config Range", "Legacy Compatibility", "Configuration", "Reads and validates a configured min/max range.", "section, ByRef minValue, ByRef maxValue, scope := ""script""", "section=config_timing_range;minValue=out_number;maxValue=out_number;scope=scope", "boolean", false, false, "timing_range", false, false, "LLARS_ConfigRange(""Action Delay"", minValue, maxValue)", "future_compatibility_cleanup", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_ConfigPoint", "Config Point", "Legacy Compatibility", "Configuration", "Resolves either a fixed x/y coordinate or a randomized xmin/xmax/ymin/ymax rectangle from a coordinate section.", "section, ByRef x, ByRef y, scope := ""script""", "section=config_coordinate;x=out_number;y=out_number;scope=scope", "boolean", false, false, "coordinate", false, false, "LLARS_ConfigPoint(""Action Location"", x, y)", "future_compatibility_cleanup", "LLARS_CreatorAPI.ahk")
		LLARS_CreatorCatalogAdd(catalog, "LLARS_TimerSchedule", "Timer Schedule", "Legacy Compatibility", "Timing", "Compatibility scheduler for existing label-based creator timers.", "labelName, section, repeat := false, scope := ""script""", "labelName=label_name;section=config_timer;repeat=boolean;scope=scope", "timer_handle_or_zero", false, false, "timer", false, false, "timerID := LLARS_TimerSchedule(""LegacyTimer"", ""Script Timer"", true)", "future_compatibility_cleanup", "LLARS_CreatorAPI.ahk")
	}

	result := {}
	for name, entry in catalog
	{
		if (includeCompatibility || entry.Classification = "Creator Public" || entry.Classification = "Creator Advanced")
			result[name] := entry
	}
	return result
}

; Returns one catalog record by public function name.
LLARS_CreatorAPIGet(functionName)
{
	catalog := LLARS_CreatorAPICatalog(true)
	functionName := Trim(functionName)
	if (functionName = "" || !catalog.HasKey(functionName))
		return ""
	return catalog[functionName]
}

; Returns Generator-safe catalog entries. Advanced entries stay hidden
; unless the caller explicitly asks for the advanced Creator surface.
LLARS_CreatorAPIActions(includeAdvanced := false)
{
	actions := []
	catalog := LLARS_CreatorAPICatalog(false)
	for _, entry in catalog
	{
		if !entry.GeneratorSafe
			continue
		if (entry.Classification = "Creator Advanced" && !includeAdvanced)
			continue
		actions.Push(entry)
	}
	return actions
}

; Builds one normalized catalog record and derives required/default
; parameter metadata from the authoritative signature stored above.
LLARS_CreatorCatalogAdd(ByRef catalog, name, displayName, classification, category, purpose, signature, typeSpec, returnValue, performsInput, blocks, configDependencies, generatorSafe, advancedOnly, example, stability, definedIn)
{
	entry := {Name:name, DisplayName:displayName, Classification:classification, Category:category, Purpose:purpose, Signature:signature, ReturnValue:returnValue, PerformsInput:performsInput, Blocks:blocks, GeneratorSafe:generatorSafe, AdvancedOnly:advancedOnly, Example:example, Stability:stability, DefinedIn:definedIn}
	entry.Parameters := []
	entry.ConfigDependencies := []
	; Timing semantics are defined here, beside the authoritative signatures.
	; The Generator does not duplicate function-name timing knowledge.
	entry.RuntimeTiming := "none"
	entry.PreviewKind := "none"
	if (name = "LLARS_Sleep")
		entry.RuntimeTiming := "configured_section"
	else if (name = "LLARS_RandomSleep")
		entry.RuntimeTiming := "shared_random_sleep"

	typeByName := {}
	if (Trim(typeSpec) != "")
	{
		for _, typeItem in StrSplit(typeSpec, ";")
		{
			typeItem := Trim(typeItem)
			typePos := InStr(typeItem, "=")
			if (typeItem = "" || !typePos)
				continue
			typeByName[Trim(SubStr(typeItem, 1, typePos - 1))] := Trim(SubStr(typeItem, typePos + 1))
		}
	}

	if (Trim(signature) != "")
	{
		for _, rawParam in StrSplit(signature, ",")
		{
			rawParam := Trim(rawParam)
			byRef := false
			if (SubStr(rawParam, 1, 6) = "ByRef ")
			{
				byRef := true
				rawParam := Trim(SubStr(rawParam, 7))
			}

			defaultPos := InStr(rawParam, ":=")
			if (defaultPos)
			{
				paramName := Trim(SubStr(rawParam, 1, defaultPos - 1))
				defaultExpression := Trim(SubStr(rawParam, defaultPos + 2))
				required := false
			}
			else
			{
				paramName := Trim(rawParam)
				defaultExpression := ""
				required := true
			}

			paramType := typeByName.HasKey(paramName) ? typeByName[paramName] : "any"
			entry.Parameters.Push({Name:paramName, Type:paramType, Required:required, Default:defaultExpression, ByRef:byRef})
		}
	}

	if (Trim(configDependencies) != "" && configDependencies != "none")
	{
		for _, dependency in StrSplit(configDependencies, ",")
		{
			dependency := Trim(dependency)
			if (dependency != "")
				entry.ConfigDependencies.Push(dependency)
		}
	}

	catalog[name] := entry
}


; Creator help is rendered directly from the API catalog used by the Generator.
; Non-Generator-safe and compatibility entries are documentation-only.
LLARS_CreatorHelpParameterType(parameterType)
{
    if (SubStr(parameterType, 1, 7) = "config_")
        return "Configured " . StrReplace(SubStr(parameterType, 8), "_", " ") . " section"
    if (SubStr(parameterType, 1, 4) = "out_")
        return "Output " . StrReplace(SubStr(parameterType, 5), "_", " ") . " variable"
    return StrReplace(parameterType, "_", " ")
}

LLARS_CreatorHelpText(entry, technical := false)
{
    if !IsObject(entry)
        return "Choose a Creator API entry to see its help."
    text := entry.DisplayName . "`r`n" . entry.Purpose . "`r`n`r`n"
    if (entry.Classification = "Legacy Compatibility" || entry.Classification = "Deprecated")
        text .= "Legacy API: existing scripts may use this, but it is not recommended for new generated actions.`r`n"
    else if (entry.GeneratorSafe)
        text .= "Available in Sequence Builder." . (entry.Classification = "Creator Advanced" ? " Enable advanced actions to find it." : "") . "`r`n"
    else
        text .= "Manual AHK use only; this action is not offered in the Generator.`r`n"
    text .= "Category: " . entry.Category . "`r`n"
    if (entry.Parameters.Length())
    {
        text .= "`r`nParameters:`r`n"
        for _, param in entry.Parameters
        {
            text .= "  " . param.Name . " — " . LLARS_CreatorHelpParameterType(param.Type)
            text .= param.Required ? " (required)" : " (optional; default: " . param.Default . ")"
            text .= "`r`n"
        }
    }
    else
        text .= "`r`nParameters: none`r`n"
    if (entry.ConfigDependencies.Length())
    {
        text .= "`r`nConfiguration: "
        for index, dependency in entry.ConfigDependencies
            text .= (index = 1 ? "" : ", ") . StrReplace(dependency, "_", " ")
        text .= "`r`n"
    }
    else
        text .= "`r`nConfiguration: none`r`n"
    text .= "`r`nExample:`r`n" . entry.Example . "`r`n"
    if (technical)
    {
        text .= "`r`nFunction: " . entry.Name . "`r`n"
        text .= "Signature: " . entry.Name . "(" . entry.Signature . ")`r`n"
        text .= "Classification: " . entry.Classification . "`r`n"
        text .= "Return: " . entry.ReturnValue . "`r`n"
        text .= "Performs input: " . (entry.PerformsInput ? "yes" : "no") . "`r`n"
        text .= "Blocking: " . (entry.Blocks ? "yes" : "no") . "`r`n"
        text .= "Generator-safe: " . (entry.GeneratorSafe ? "yes" : "no") . "`r`n"
        text .= "Stability: " . entry.Stability . "`r`n"
        text .= "Defined in: " . entry.DefinedIn . "`r`n"
    }
    return text
}

; ================================================================
; |     CREATOR CONFIG CATALOG     -     CREATOR CONFIG CATALOG  |
; ================================================================
; The Generator uses the same parameter/dependency vocabulary as the Creator
; API catalog above. Config field layouts live here so the GUI does not keep a
; second hard-coded interpretation of LLARS script-local Config.ini sections.
LLARS_CreatorConfigCatalog()
{
	static definitions := ""

	if !IsObject(definitions)
	{
		definitions := {}
		definitions["coordinate"] := {Name:"coordinate", DisplayName:"Coordinate", TypeLine:"coordinate", DefaultMode:"Point", Modes:"Point|Area", Purpose:"A fixed client point or randomized coordinate rectangle used by mouse and pixel actions."}
		definitions["hotkey"] := {Name:"hotkey", DisplayName:"Hotkey", TypeLine:"hotkey", DefaultMode:"", Modes:"", Purpose:"A script-local key or key combination configured through LLARS Setup."}
		definitions["color"] := {Name:"color", DisplayName:"Color", TypeLine:"color", DefaultMode:"", Modes:"", Purpose:"An RGB color value written as 0xRRGGBB and configured through LLARS Setup."}
		definitions["timing_range"] := {Name:"timing_range", DisplayName:"Timing Range", TypeLine:"", DefaultMode:"", Modes:"", Purpose:"A randomized minimum/maximum delay consumed by LLARS_Sleep and related timing helpers."}
		definitions["timer"] := {Name:"timer", DisplayName:"Timer", TypeLine:"timer", DefaultMode:"", Modes:"", Purpose:"An enabled/disabled randomized recurring timer section."}
		definitions["option"] := {Name:"option", DisplayName:"Script Option", TypeLine:"", DefaultMode:"", Modes:"", Purpose:"A simple optional Config.ini section controlled by option=true/false."}
	}

	result := {}
	for name, definition in definitions
		result[name] := definition
	return result
}

; Starter patterns use ordinary catalogued Creator actions. They are not a
; separate runtime, scripting language, or copies of the legacy file templates.
; Each action reference is checked through LLARS_CreatorAPIGet on load.
LLARS_CreatorStarterAction(functionName, values := "", kind := "api")
{
	if !IsObject(values)
		values := {}
	return {Kind:kind, Function:functionName, Values:values}
}

LLARS_CreatorStarterFlow(flowType, count := "")
{
	return {Kind:"flow", FlowType:flowType, Count:count}
}

; Each starter is an editable sequence of normal Creator API actions.
; RunCount handles the outer repetition; never nest an unbounded loop in Run(ctx).
; The Normal/MES examples are starter patterns, not a dedicated banking wizard.
; The specialized Generator banking wizard consumes these patterns.
LLARS_CreatorStarterTemplates()
{
	templates := []

	t := {Id:"basic", DisplayName:"Basic Repeating Script", Difficulty:"Beginner", BankingMode:"None", ExpectedConfigTypes:"coordinate|timing_range", Purpose:"Repeat a clicked action with a configured pause on each RunCount cycle.", BestFor:"Simple one-target automation", Notes:"RunCount owns the outer repeat; edit the target and delay in Config Manager.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Acting", activity:"Target"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Click", {section:"Action Target"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Action Delay"}))
	templates.Push(t)

	t := {Id:"route", DisplayName:"Coordinate Route Script", Difficulty:"Beginner", BankingMode:"None", ExpectedConfigTypes:"coordinate|timing_range", Purpose:"Visit configured coordinates in a fixed order with pauses.", BestFor:"Two or more ordered target points", Notes:"Duplicate or reorder the ordinary Click/Sleep sequence steps to extend the route.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Route", activity:"First point"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Click", {section:"Route Point 1"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Route Delay"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Click", {section:"Route Point 2"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Route Delay"}))
	templates.Push(t)

	t := {Id:"hotkey", DisplayName:"Hotkey Automation Script", Difficulty:"Beginner", BankingMode:"None", ExpectedConfigTypes:"hotkey|timing_range", Purpose:"Perform a user-configured hotkey action followed by a pause.", BestFor:"Keyboard-driven actions", Notes:"Set the action hotkey in Setup before running.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Performing", activity:"Hotkey action"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_PressHotkey", {section:"Action Hotkey"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Action Delay"}))
	templates.Push(t)

	t := {Id:"color", DisplayName:"Color Detection Script", Difficulty:"Intermediate", BankingMode:"None", ExpectedConfigTypes:"coordinate|color|timing_range", Purpose:"Branch on an exact configured pixel/color match.", BestFor:"Simple visual target checks", Notes:"Configure a live pixel and RGB color; adjust action timing for missed detections.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_PixelMatches", {coordinateSection:"Target Pixel", colorSection:"Target Color"}, "condition"))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Target found", activity:"Acting"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Click", {section:"Target Click"}))
	t.Steps.Push(LLARS_CreatorStarterFlow("else"))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Target missing", activity:"Waiting"}))
	t.Steps.Push(LLARS_CreatorStarterFlow("end_block"))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Scan Delay"}))
	templates.Push(t)

	t := {Id:"production", DisplayName:"Production Script", Difficulty:"Intermediate", BankingMode:"None", ExpectedConfigTypes:"coordinate|hotkey|timing_range", Purpose:"Open a configured bank and perform a production hotkey action.", BestFor:"Processing and crafting workflows", Notes:"General production starter only; choose explicit Normal/MES banking below for preset differences.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Banking", activity:"Open bank"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Click", {section:"Bank"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Bank Wait"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Producing", activity:"Action"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_PressHotkey", {section:"Production Hotkey"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Production Wait"}))
	templates.Push(t)

	t := {Id:"normal_bank", DisplayName:"Normal Banking Script", Difficulty:"Intermediate", BankingMode:"Normal", ExpectedConfigTypes:"coordinate|hotkey|timing_range", Purpose:"Open a bank, trigger the configured preset hotkey, then perform an action.", BestFor:"Normal LLARS preset-based banking", Notes:"Includes Bank Preset hotkey and its config; A separate banking wizard can provide richer guidance.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Banking", activity:"Open bank"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Click", {section:"Bank"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Bank Wait"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Loading preset", activity:"Normal banking"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_PressHotkey", {section:"Bank Preset"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Preset Wait"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_PressHotkey", {section:"Production Hotkey"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Production Wait"}))
	templates.Push(t)

	t := {Id:"mes_bank", DisplayName:"Menu Entry Swapper Banking Script", Difficulty:"Intermediate", BankingMode:"MES", ExpectedConfigTypes:"coordinate|hotkey|timing_range", Purpose:"Open a bank, wait briefly, and continue without a preset step.", BestFor:"Menu Entry Swapper banking", Notes:"No Bank Preset hotkey or status. The Generator selects the MES output family for this starter. Set up real coordinates before running.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Banking", activity:"Open bank"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Click", {section:"Bank"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Bank Wait"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Producing", activity:"MES banking"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_PressHotkey", {section:"Production Hotkey"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Production Wait"}))
	templates.Push(t)

	t := {Id:"timed", DisplayName:"Timed / Anti-AFK Script", Difficulty:"Beginner", BankingMode:"None", ExpectedConfigTypes:"timing_range", Purpose:"Repeat a safe configured key action at a chosen RunCount interval.", BestFor:"Periodic actions with configurable pauses", Notes:"This uses RunCount with a pause, not a separate timer-engine script. Configure the interval before running.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Waiting", activity:"Next action"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Action Interval"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_PressKey", {keyName:"Space"}))
	templates.Push(t)

	t := {Id:"advanced", DisplayName:"Advanced Minimal Script", Difficulty:"Advanced", BankingMode:"None", ExpectedConfigTypes:"timing_range", Purpose:"Start from a minimal editable, preflight-valid RunCount callback.", BestFor:"Experienced AHK creators who want to supply their own actions", Notes:"Status and pause are intentionally included so this is preflight-valid; remove or edit them once your real actions are added.", Steps:[]}
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_SetStatus", {status:"Ready", activity:"Customize sequence"}))
	t.Steps.Push(LLARS_CreatorStarterAction("LLARS_Sleep", {section:"Cycle Delay"}))
	templates.Push(t)

	return templates
}

; Returns one script-local config definition and the fields for its selected mode.
LLARS_CreatorConfigGet(configType, mode := "")
{
	catalog := LLARS_CreatorConfigCatalog()
	configType := Trim(configType)
	StringLower, configType, configType
	if (configType = "" || !catalog.HasKey(configType))
		return ""

	definition := {}
	for key, value in catalog[configType]
		definition[key] := value
	if (mode = "")
		mode := definition.DefaultMode
	definition.Mode := mode
	definition.Fields := LLARS_CreatorConfigFields(configType, mode)
	return definition
}

; Friendly type list for the Generator's typed Config editor.
LLARS_CreatorConfigTypes()
{
	types := []
	catalog := LLARS_CreatorConfigCatalog()
	for _, definition in catalog
		types.Push(definition)
	return types
}

; Maps Creator API parameter metadata to the script-local Config.ini section
; type required by that parameter. Blank means no local section is required.
LLARS_CreatorConfigTypeForParameter(parameterType)
{
	parameterType := Trim(parameterType)
	StringLower, parameterType, parameterType
	if (parameterType = "config_coordinate")
		return "coordinate"
	if (parameterType = "config_hotkey")
		return "hotkey"
	if (parameterType = "config_color" || parameterType = "config_color_list")
		return "color"
	if (parameterType = "config_timing_range")
		return "timing_range"
	if (parameterType = "config_timer")
		return "timer"
	if (parameterType = "config_section")
		return "option"
	return ""
}

; Returns the normalized fields and defaults used when the Generator creates a
; new section. Coordinate Point/Area is the only mode-dependent layout.
LLARS_CreatorConfigFields(configType, mode := "")
{
	fields := []
	configType := Trim(configType)
	StringLower, configType, configType
	if (configType = "coordinate")
	{
		if (mode = "")
			mode := "Point"
		modeLower := mode
		StringLower, modeLower, modeLower
		if (modeLower = "area")
		{
			fields.Push({Name:"xmin", DisplayName:"Minimum X", Default:"", ValueType:"integer_or_blank"})
			fields.Push({Name:"xmax", DisplayName:"Maximum X", Default:"", ValueType:"integer_or_blank"})
			fields.Push({Name:"ymin", DisplayName:"Minimum Y", Default:"", ValueType:"integer_or_blank"})
			fields.Push({Name:"ymax", DisplayName:"Maximum Y", Default:"", ValueType:"integer_or_blank"})
		}
		else
		{
			fields.Push({Name:"x", DisplayName:"X", Default:"", ValueType:"integer_or_blank"})
			fields.Push({Name:"y", DisplayName:"Y", Default:"", ValueType:"integer_or_blank"})
		}
	}
	else if (configType = "hotkey")
		fields.Push({Name:"hotkey", DisplayName:"Hotkey", Default:"", ValueType:"string"})
	else if (configType = "color")
		fields.Push({Name:"color", DisplayName:"RGB Color", Default:"0xFFFFFF", ValueType:"color"})
	else if (configType = "timing_range")
	{
		fields.Push({Name:"min", DisplayName:"Minimum ms", Default:"500", ValueType:"number"})
		fields.Push({Name:"max", DisplayName:"Maximum ms", Default:"1000", ValueType:"number"})
	}
	else if (configType = "timer")
	{
		fields.Push({Name:"option", DisplayName:"Enabled", Default:"false", ValueType:"boolean"})
		fields.Push({Name:"min", DisplayName:"Minimum ms", Default:"10000", ValueType:"number"})
		fields.Push({Name:"max", DisplayName:"Maximum ms", Default:"30000", ValueType:"number"})
	}
	else if (configType = "option")
		fields.Push({Name:"option", DisplayName:"Enabled", Default:"true", ValueType:"boolean"})
	return fields
}

