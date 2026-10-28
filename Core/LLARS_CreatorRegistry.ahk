; Shared Creator-generated Selector registry. Existing authored Selector records remain
; the authority for shipped scripts; this file only describes opt-in new entries.
; A generated AHK/Config pair is independently usable without this index.
LLARS_CreatorRegistryPath(root)
{
	return root . "\Scripts\LLARS Creator Registry.ini"
}

LLARS_CreatorRegistryValid(record, ByRef error)
{
	error := ""
	for _, field in ["Name", "InfoTitle", "Difficulty", "Description", "RelativeDirectory", "FileName", "Category", "RootDirectory", "ScriptFamily", "Author"]
	{
		if !record.HasKey(field)
		{
			error := "Missing generated Selector field: " . field
			return false
		}
		if RegExMatch(record[field], "[\r\n\x00-\x1F\[\]]")
		{
			error := "Invalid control or section marker in generated Selector field: " . field
			return false
		}
	}
	if (record.Name = "" || record.InfoTitle = "" || record.Description = "" || record.RelativeDirectory = "" || record.FileName = "" || record.Category = "")
	{
		error := "Generated Selector identity fields cannot be blank."
		return false
	}
	if (record.Difficulty != "Easy" && record.Difficulty != "Intermediate" && record.Difficulty != "Hard")
	{
		error := "Invalid generated Selector difficulty."
		return false
	}
	if (record.ScriptFamily != "Normal" && record.ScriptFamily != "Menu Entry Swapper")
	{
		error := "Invalid generated Selector family."
		return false
	}
	requiredRoot := (record.ScriptFamily = "Normal") ? "Scripts" : "Scripts - Menu Entry Swapper"
	if (record.RootDirectory != requiredRoot)
	{
		error := "Generated Selector family and root disagree."
		return false
	}
	if (InStr(record.RelativeDirectory, "/") || RegExMatch(record.RelativeDirectory, "(^|\\)\.\.?($|\\)") || RegExMatch(record.RelativeDirectory, "^[A-Za-z]:") || SubStr(record.RelativeDirectory, 1, 1) = "\")
	{
		error := "Generated Selector directory must be relative and remain inside its family."
		return false
	}
	if (InStr(record.FileName, "\") || InStr(record.FileName, "/") || RegExMatch(record.FileName, "(^\.|[. ]$|[\\/:*?""<>|])") || !RegExMatch(record.FileName, "i)\.ahk$"))
	{
		error := "Invalid generated Selector script filename."
		return false
	}
	return true
}

LLARS_CreatorRegistryRead(root, ByRef error)
{
	error := ""
	out := []
	path := LLARS_CreatorRegistryPath(root)
	if !FileExist(path)
		return out
	count := LLARS_ConfigReadFile(path, "Registry", "Count", "ERROR")
	if (count = "ERROR" || !RegExMatch(count, "^\d+$") || count > 5000)
	{
		error := "Creator registry header is missing or invalid."
		return false
	}
	seenNames := {}
	seenPaths := {}
	Loop, %count%
	{
		section := "Item" . A_Index
		record := {}
		for _, field in ["Name", "InfoTitle", "Difficulty", "Description", "RelativeDirectory", "FileName", "Category", "RootDirectory", "ScriptFamily", "Author"]
		{
			value := LLARS_ConfigReadFile(path, section, field, "__LLARS_MISSING_FIELD__")
			if (value = "__LLARS_MISSING_FIELD__")
			{
				error := "Missing registry field " . section . "." . field
				return false
			}
			record[field] := value
		}
		if !LLARS_CreatorRegistryValid(record, error)
			return false
		nameKey := record.Name
		pathKey := record.RootDirectory . "\" . record.RelativeDirectory . "\" . record.FileName
		StringLower, nameKey, nameKey
		StringLower, pathKey, pathKey
		if seenNames.HasKey(nameKey) || seenPaths.HasKey(pathKey)
		{
			error := "Duplicate generated Selector name or target."
			return false
		}
		seenNames[nameKey] := true
		seenPaths[pathKey] := true
		out.Push(record)
	}
	return out
}

LLARS_CreatorRegistryWrite(root, records, ByRef error)
{
	error := ""
	path := LLARS_CreatorRegistryPath(root)
	if !IsObject(records)
	{
		error := "Creator registry entries are invalid."
		return false
	}
	seen := {}
	seenPaths := {}
	data := "[Registry]`r`nCount=" . records.Length() . "`r`n"
	for index, record in records
	{
		if !LLARS_CreatorRegistryValid(record, error)
			return false
		key := record.Name
		StringLower, key, key
		if seen.HasKey(key)
		{
			error := "Duplicate generated Selector display name."
			return false
		}
		seen[key] := true
		pathKey := record.RootDirectory . "\" . record.RelativeDirectory . "\" . record.FileName
		StringLower, pathKey, pathKey
		if seenPaths.HasKey(pathKey)
		{
			error := "Duplicate generated Selector script target."
			return false
		}
		seenPaths[pathKey] := true
		data .= "`r`n[Item" . index . "]`r`n"
		for _, field in ["Name", "InfoTitle", "Difficulty", "Description", "RelativeDirectory", "FileName", "Category", "RootDirectory", "ScriptFamily", "Author"]
			data .= field . "=" . record[field] . "`r`n"
	}
	if !FileExist(root . "\Scripts")
	{
		error := "Normal Scripts folder is missing; cannot save Creator registry."
		return false
	}
	staging := path . "." . DllCall("GetCurrentProcessId", "UInt") . "." . A_TickCount . ".new"
	file := FileOpen(staging, "w", "UTF-16")
	if !IsObject(file)
	{
		error := "Cannot stage Creator registry."
		return false
	}
	file.Write(data)
	file.Close()
	FileMove, %staging%, %path%, 1
	if (ErrorLevel)
	{
		FileDelete, %staging%
		error := "Cannot commit Creator registry; existing entries are unchanged."
		return false
	}
	return true
}
