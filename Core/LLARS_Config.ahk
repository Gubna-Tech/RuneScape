; ================================================================
; |     LLARS CONFIGURATION     -     SHARED CONFIGURATION       |
; ================================================================
; Central owner for low-level INI access, normalized snapshots, schema
; validation, capability discovery, migration, backup, and restore.
; Low-level INI access is centralized here so Core, Selector, and Creator API
; consumers share one implementation path. Migration/backup may still use
; whole-file operations where transactional semantics require them.
LLARS_ConfigReadFile(configPath, section, key, default := "ERROR")
{
    if !FileExist(configPath)
        return default

    IniRead, value, %configPath%, %section%, %key%, %default%
    return value
}

LLARS_ConfigReadSection(configPath, section, default := "ERROR")
{
    if !FileExist(configPath)
        return default

    IniRead, sectionData, %configPath%, %section%
    if ErrorLevel
        return default
    return sectionData
}

LLARS_ConfigWriteFile(configPath, section, key, value)
{
    section := Trim(section)
    key := Trim(key)
    if (configPath = "" || section = "" || key = "")
        return false

    IniWrite, %value%, %configPath%, %section%, %key%
    if ErrorLevel
        return false

    LLARS_ConfigInvalidateSnapshot(configPath)
    return true
}

LLARS_ConfigDeleteFile(configPath, section, key := "")
{
    section := Trim(section)
    if (configPath = "" || section = "")
        return false

    if (key = "")
        IniDelete, %configPath%, %section%
    else
        IniDelete, %configPath%, %section%, %key%
    if ErrorLevel
        return false

    LLARS_ConfigInvalidateSnapshot(configPath)
    return true
}

LLARS_ConfigSectionExistsFile(configPath, section)
{
    section := Trim(section)
    if (section = "")
        return false

    sections := LLARS_ConfigSectionList(configPath)
    if (sections = "ERROR")
        return false

    Loop, Parse, sections, `n, `r
    {
        if (Trim(A_LoopField) = section)
            return true
    }
    return false
}

LLARS_ConfigKeysFile(configPath, section, default := "ERROR")
{
    sectionData := LLARS_ConfigReadSection(configPath, section, default)
    if (sectionData = default)
        return default

    keys := ""
    Loop, Parse, sectionData, `n, `r
    {
        line := A_LoopField
        equalsPos := InStr(line, "=")
        if (!equalsPos)
            continue
        key := Trim(SubStr(line, 1, equalsPos - 1))
        if (key = "")
            continue
        if (keys != "")
            keys .= "`n"
        keys .= key
    }
    return (keys = "") ? default : keys
}

LLARS_ConfigKeyExistsFile(configPath, section, key)
{
    key := Trim(key)
    if (key = "" || !LLARS_ConfigSectionExistsFile(configPath, section))
        return false

    keys := LLARS_ConfigKeysFile(configPath, section, "")
    Loop, Parse, keys, `n, `r
    {
        if (Trim(A_LoopField) = key)
            return true
    }
    return false
}

LLARS_ConfigInvalidateSnapshot(configPath := "")
{
    global LLARS_ConfigSnapshotCache
    if !IsObject(LLARS_ConfigSnapshotCache)
        LLARS_ConfigSnapshotCache := {}

    if (configPath = "")
    {
        LLARS_ConfigSnapshotCache := {}
        return true
    }

    if LLARS_ConfigSnapshotCache.HasKey(configPath)
        LLARS_ConfigSnapshotCache.Delete(configPath)
    return true
}

LLARS_ConfigSnapshotLoad(configPath, forceReload := false)
{
    global LLARS_ConfigSnapshotCache
    if !IsObject(LLARS_ConfigSnapshotCache)
        LLARS_ConfigSnapshotCache := {}

    if (!forceReload && LLARS_ConfigSnapshotCache.HasKey(configPath))
        return LLARS_ConfigSnapshotCache[configPath]

    snapshot := {Path: configPath, Sections: {}, Valid: false}
    sections := LLARS_ConfigSectionList(configPath)
    if (sections = "ERROR")
    {
        LLARS_ConfigSnapshotCache[configPath] := snapshot
        return snapshot
    }

    Loop, Parse, sections, `n, `r
    {
        section := Trim(A_LoopField)
        if (section = "")
            continue
        sectionData := LLARS_ConfigReadSection(configPath, section, "")
        values := {}
        Loop, Parse, sectionData, `n, `r
        {
            line := A_LoopField
            equalsPos := InStr(line, "=")
            if (!equalsPos)
                continue
            key := Trim(SubStr(line, 1, equalsPos - 1))
            if (key = "")
                continue
            values[key] := SubStr(line, equalsPos + 1)
        }
        snapshot.Sections[section] := values
    }

    snapshot.Valid := true
    LLARS_ConfigSnapshotCache[configPath] := snapshot
    return snapshot
}

LLARS_ConfigSnapshotReload(configPath)
{
    LLARS_ConfigInvalidateSnapshot(configPath)
    return LLARS_ConfigSnapshotLoad(configPath, true)
}

LLARS_ConfigSnapshotRead(snapshot, section, key, default := "ERROR")
{
    if !IsObject(snapshot) || !snapshot.Valid
        return default
    if !snapshot.Sections.HasKey(section)
        return default
    values := snapshot.Sections[section]
    if !IsObject(values) || !values.HasKey(key)
        return default
    return values[key]
}

LLARS_ConfigSchemaCurrent()
{
    return 1
}

; Reads the schema directly from a root LLARS configuration file. Configs that
; predate config_schema are schema 1 without being rewritten.
LLARS_GetConfigSchemaFromFile(configPath, ByRef schemaExplicit := false, ByRef errorDetail := "")
{
    schemaExplicit := false
    errorDetail := ""
    if !FileExist(configPath)
    {
        errorDetail := "LLARS Config.ini is missing."
        return 0
    }

    FileGetSize, configSize, %configPath%
    if (ErrorLevel || configSize <= 0)
    {
        errorDetail := "LLARS Config.ini is empty or unreadable."
        return 0
    }

    schemaValue := LLARS_ConfigReadFile(configPath, "LLARS", "config_schema", "__LLARS_SCHEMA_MISSING__")
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

; Reads the framework-wide configuration schema from the LLARS project root.
LLARS_GetConfigSchema(root := "", ByRef schemaExplicit := false, ByRef errorDetail := "")
{
    global LLARS_ROOT

    if (root = "")
        root := LLARS_ROOT
    if (root = "")
        root := A_ScriptDir
    return LLARS_GetConfigSchemaFromFile(RTrim(root, "\/") . "\LLARS Config.ini", schemaExplicit, errorDetail)
}

; Returns normalized INI section names without relying on the Windows profile API
; section-list behavior. Reading the headers directly keeps the first section
; visible even when a UTF-8 BOM is present.
LLARS_ConfigSectionList(ConfigPath)
{
	if !FileExist(ConfigPath)
		return "ERROR"

	FileRead, configContents, %ConfigPath%
	if ErrorLevel
		return "ERROR"

	sectionList := ""
	Loop, Parse, configContents, `n, `r
	{
		line := Trim(A_LoopField)
		line := StrReplace(line, Chr(0xFEFF))
		if !RegExMatch(line, "^\[(.*)\]$", sectionMatch)
			continue

		section := Trim(sectionMatch1)
		if (section = "")
			continue

		if (sectionList != "")
			sectionList .= "`n"
		sectionList .= section
	}

	return (sectionList = "") ? "ERROR" : sectionList
}


; Returns the normalized setup capability represented by one script-config section.
; Mechanical setup requirements are derived from Config.ini instead of being
; duplicated in Selector metadata. Legacy [Timer] sections without type=timer
; remain recognized so existing user configurations stay backward compatible.
LLARS_ConfigCapabilitySectionType(configPath, section)
{
    section := Trim(section)
    if (configPath = "" || section = "")
        return ""

    configType := LLARS_ConfigReadFile(configPath, section, "type", "")
    configType := Trim(configType)
    StringLower, configType, configType
    if (configType = "hotkey" || configType = "coordinate" || configType = "color" || configType = "timer")
        return configType

    sectionLower := section
    StringLower, sectionLower, sectionLower
    if (sectionLower = "timer")
    {
        timerMin := LLARS_ConfigReadFile(configPath, section, "min", "__LLARS_MISSING__")
        timerMax := LLARS_ConfigReadFile(configPath, section, "max", "__LLARS_MISSING__")
        if (timerMin != "__LLARS_MISSING__" || timerMax != "__LLARS_MISSING__")
            return "timer"
    }

    return ""
}

; Reads the script-owned opt-out without making Selector maintain another
; RequiresLocalConfig flag. Runtime callers may pass an explicit override.
LLARS_ConfigScriptDisabled(scriptPath)
{
    if (scriptPath = "" || !FileExist(scriptPath))
        return false

    FileRead, scriptContents, %scriptPath%
    if ErrorLevel
        return false

    return RegExMatch(scriptContents, "im)^\s*LLARS_DISABLE_SCRIPT_CONFIG\s*:=\s*true\b") ? true : false
}

; Builds the authoritative mechanical setup-capability object for one script.
; Human metadata (name/category/difficulty/description/launch target) stays in
; the Selector registry; setup requirements come only from the script config.
LLARS_ConfigCapabilityScan(configPath, scriptPath := "", disabledOverride := "")
{
    disabled := (disabledOverride = "") ? LLARS_ConfigScriptDisabled(scriptPath) : (disabledOverride ? true : false)
    caps := {ConfigPath: configPath
        , ScriptPath: scriptPath
        , Disabled: disabled
        , ConfigExists: false
        , RequiresLocalConfig: false
        , Hotkeys: false
        , Coordinates: false
        , Colors: false
        , Timer: false
        , ScriptConfig: false
        , SetupType: "None"
        , SetupText: "None"}

    if (disabled)
        return caps

    if !FileExist(configPath)
        return caps

    caps.ConfigExists := true
    caps.RequiresLocalConfig := true
    caps.ScriptConfig := true

    sections := LLARS_ConfigSectionList(configPath)
    if (sections != "ERROR")
    {
        Loop, Parse, sections, `n, `r
        {
            section := Trim(A_LoopField)
            if (section = "")
                continue

            capabilityType := LLARS_ConfigCapabilitySectionType(configPath, section)
            if (capabilityType = "hotkey")
                caps.Hotkeys := true
            else if (capabilityType = "coordinate")
                caps.Coordinates := true
            else if (capabilityType = "color")
                caps.Colors := true
            else if (capabilityType = "timer")
                caps.Timer := true
        }
    }

    setupText := ""
    if (caps.Hotkeys)
        setupText .= (setupText = "" ? "" : " + ") . "Hotkeys"
    if (caps.Coordinates)
        setupText .= (setupText = "" ? "" : " + ") . "Coordinates"
    if (caps.Colors)
        setupText .= (setupText = "" ? "" : " + ") . "Colors"
    if (caps.Timer)
        setupText .= (setupText = "" ? "" : " + ") . "Timer"
    caps.SetupText := (setupText = "") ? "None" : setupText

    ; Compatibility classification retained for internal diagnostics that still
    ; expect the historical single setup label. It is computed, never authored.
    if (caps.Hotkeys && !caps.Coordinates && !caps.Colors && !caps.Timer)
        caps.SetupType := "Hotkey"
    else if (caps.Coordinates && !caps.Hotkeys && !caps.Colors && !caps.Timer)
        caps.SetupType := "Coordinate"
    else if (caps.Colors && caps.Coordinates && !caps.Hotkeys && !caps.Timer)
        caps.SetupType := "Color+Coordinate"
    else if (caps.Timer && !caps.Hotkeys && !caps.Coordinates && !caps.Colors)
        caps.SetupType := "Timer"
    else if (!caps.Hotkeys && !caps.Coordinates && !caps.Colors && !caps.Timer)
        caps.SetupType := "None"
    else
        caps.SetupType := "Mixed"

    return caps
}

; Lightweight root-config validation used before backup/migration/restore.
; Script-local Config.ini files intentionally do not use this schema contract.
LLARS_ValidateRootConfigFile(configPath, ByRef schema := 0, ByRef errorDetail := "", expectedSchema := 0)
{
    schemaExplicit := false
    schemaError := ""
    schema := LLARS_GetConfigSchemaFromFile(configPath, schemaExplicit, schemaError)
    if (schema < 1)
    {
        errorDetail := schemaError
        return false
    }

    if (expectedSchema > 0 && schema != expectedSchema)
    {
        errorDetail := "Expected config schema " . expectedSchema . " but found " . schema . "."
        return false
    }

    sectionList := LLARS_ConfigSectionList(configPath)
    if (ErrorLevel || sectionList = "ERROR" || sectionList = "")
    {
        errorDetail := "LLARS Config.ini does not contain readable sections."
        return false
    }

    sectionEnvelope := "`n" . StrReplace(sectionList, "`r") . "`n"
    if (!InStr(sectionEnvelope, "`nStart Hotkey`n") || !InStr(sectionEnvelope, "`nExit Hotkey`n"))
    {
        errorDetail := "LLARS Config.ini is missing required root configuration sections."
        return false
    }

    errorDetail := ""
    return true
}

; Migration edges are added only when an actual incompatible root-config
; change requires them. Schema 1 remains current until then.
LLARS_ApplyConfigMigrationStep(configPath, fromSchema, toSchema, ByRef errorDetail := "")
{
    errorDetail := "No LLARS config migration exists from schema " . fromSchema . " to schema " . toSchema . "."
    return false
}

; Transaction-like migration dispatcher. The original config is backed up and a
; temporary copy is migrated/validated before the live file is replaced.
LLARS_MigrateConfig(oldSchema, targetSchema, root := "", ByRef errorDetail := "")
{
    global LLARS_ROOT

    errorDetail := ""
    if (root = "")
        root := LLARS_ROOT
    if (root = "")
        root := A_ScriptDir
    root := RTrim(root, "\/")

    if (oldSchema < 1 || targetSchema < 1 || oldSchema > targetSchema)
    {
        errorDetail := "Invalid LLARS config migration range."
        return false
    }
    if (oldSchema = targetSchema)
        return true

    currentSchema := LLARS_ConfigSchemaCurrent()
    if (targetSchema > currentSchema)
    {
        errorDetail := "The requested migration target is newer than this LLARS build supports."
        return false
    }

    configPath := root . "\LLARS Config.ini"
    sourceSchema := 0
    sourceError := ""
    if !LLARS_ValidateRootConfigFile(configPath, sourceSchema, sourceError, oldSchema)
    {
        errorDetail := sourceError
        return false
    }

    backupError := ""
    if !LLARS_RunConfigBackup(root, true, backupError)
    {
        errorDetail := "Pre-migration backup failed: " . backupError
        return false
    }

    tempPath := configPath . ".migration.tmp"
    rollbackPath := configPath . ".migration.rollback"
    FileDelete, %tempPath%
    FileDelete, %rollbackPath%
    FileCopy, %configPath%, %tempPath%, 1
    if (ErrorLevel || !FileExist(tempPath))
    {
        errorDetail := "Could not create the temporary migration copy."
        return false
    }

    schemaCursor := oldSchema
    while (schemaCursor < targetSchema)
    {
        nextSchema := schemaCursor + 1
        stepError := ""
        if !LLARS_ApplyConfigMigrationStep(tempPath, schemaCursor, nextSchema, stepError)
        {
            FileDelete, %tempPath%
            errorDetail := stepError
            return false
        }
        schemaCursor := nextSchema
    }

    migratedSchema := 0
    migratedError := ""
    if !LLARS_ValidateRootConfigFile(tempPath, migratedSchema, migratedError, targetSchema)
    {
        FileDelete, %tempPath%
        errorDetail := "Migrated config validation failed: " . migratedError
        return false
    }

    FileMove, %configPath%, %rollbackPath%, 1
    if (ErrorLevel)
    {
        FileDelete, %tempPath%
        errorDetail := "Could not stage the original config for replacement."
        return false
    }

    FileMove, %tempPath%, %configPath%, 1
    if (ErrorLevel)
    {
        FileMove, %rollbackPath%, %configPath%, 1
        FileDelete, %tempPath%
        errorDetail := "Could not commit the migrated config; the original was restored."
        return false
    }

    FileDelete, %rollbackPath%
    return true
}

; Refuse malformed/future configuration. When a real older schema exists, run
; the sequential backup-first migration dispatcher before startup continues.
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

    if (configSchema < currentSchema)
    {
        migrationError := ""
        if !LLARS_MigrateConfig(configSchema, currentSchema, root, migrationError)
        {
            MsgBox, 262192, LLARS Configuration, LLARS could not safely migrate the shared configuration.`n`n%migrationError%`n`nThe original configuration was left recoverable and startup has stopped.
            return false
        }
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
    root := RTrim(root, "\/")
    configPath := root . "\LLARS Config.ini"
    schema := 0
    validationError := ""
    if !LLARS_ValidateRootConfigFile(configPath, schema, validationError)
    {
        errorDetail := validationError
        return false
    }
    if (schema > LLARS_ConfigSchemaCurrent())
    {
        errorDetail := "The root config uses unsupported future schema " . schema . "."
        return false
    }
    return LLARS_RunConfigTool(root, "backup", automatic, errorDetail)
}

LLARS_RunConfigRestore(root, automatic := true, ByRef errorDetail := "")
{
    root := RTrim(root, "\/")
    backupConfig := root . "\Backup\Config Backup\LLARS Config.ini"
    schema := 0
    validationError := ""
    if !LLARS_ValidateRootConfigFile(backupConfig, schema, validationError)
    {
        errorDetail := "Latest backup is not restorable: " . validationError
        return false
    }
    if (schema > LLARS_ConfigSchemaCurrent())
    {
        errorDetail := "Latest backup uses unsupported future schema " . schema . "."
        return false
    }
    return LLARS_RunConfigTool(root, "restore", automatic, errorDetail)
}
