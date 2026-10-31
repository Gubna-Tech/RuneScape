; Shared Creator-generated Selector registry. Existing authored Selector records remain
; the authority for shipped scripts; this file only describes opt-in new entries.
; A generated AHK/Config pair is independently usable without this index.
LLARS_CreatorRegistryPath(root)
{
	return root . "\Scripts\LLARS Creator Registry.ini"
}

; Multiline descriptions are stored on one INI line using a reversible
; encoding. Existing single-line Creator records stay byte-compatible.
LLARS_CreatorDescriptionEncode(value)
{
    ; A description is user text, not an INI section or list. Keep ordinary
    ; single-line Creator entries compatible while protecting multiline and
    ; punctuation using reversible percent encoding on a single INI line.
    prefix := "LLARS_DESC_V1:"
    original := value
    value := StrReplace(value, "%", "%25")
    Loop, 31
    {
        code := A_Index
        value := StrReplace(value, Chr(code), "%" . Format("{:02X}", code))
    }
    value := StrReplace(value, Chr(127), "%7F")
    value := StrReplace(value, "[", "%5B")
    value := StrReplace(value, "]", "%5D")
    value := StrReplace(value, "|", "%7C")
    if (value = original && SubStr(value, 1, StrLen(prefix)) != prefix)
        return original
    return prefix . value
}

LLARS_CreatorDescriptionDecode(value)
{
    prefix := "LLARS_DESC_V1:"
    if (SubStr(value, 1, StrLen(prefix)) != prefix)
        return value
    value := SubStr(value, StrLen(prefix) + 1)
    value := StrReplace(value, "%5B", "[")
    value := StrReplace(value, "%5D", "]")
    value := StrReplace(value, "%7C", "|")
    value := StrReplace(value, "%7F", Chr(127))
    Loop, 31
    {
        code := A_Index
        value := StrReplace(value, "%" . Format("{:02X}", code), Chr(code))
    }
    ; Decode escaped percent signs LAST, so original literal %0A and other
    ; percent sequences do not accidentally become control characters.
    return StrReplace(value, "%25", "%")
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
        ; Description is serialized through LLARS_CreatorDescriptionEncode,
        ; so line breaks, brackets and pipes are safe. Never run the legacy
        ; character-class validator on user-authored description text.
        if (field != "Description" && RegExMatch(record[field], "[\r\n\x00-\x1F\[\]]"))
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
            record[field] := (field = "Description") ? LLARS_CreatorDescriptionDecode(value) : value
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
        {
            value := (field = "Description") ? LLARS_CreatorDescriptionEncode(record[field]) : record[field]
            data .= field . "=" . value . "`r`n"
        }
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

; Optional user imports share the existing Creator registry. A selected .ahk
; file is never executed during import. Imported copies live in a reserved
; user-owned subtree; unregistering only removes the Selector registration.
LLARS_ImportManagedRoot(root)
{
	return root . "\Scripts\Custom\Imported"
}

LLARS_ImportFolderNameValid(name)
{
    ; Preserve the actual source directory name. Never silently rewrite it into
    ; an entrypoint-derived slug, which breaks relative paths and backup layout.
    if (name = "" || StrLen(name) > 80 || InStr(name, "\") || RegExMatch(name, "[/:*?""<>|\x00-\x1F]")
        || RegExMatch(name, "^[. ]|[. ]$") || RegExMatch(name, "i)^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$"))
        return false
    return true
}

LLARS_ImportIsManaged(record)
{
	return IsObject(record) && record.HasKey("Author") && record.Author = "User import"
		&& record.RootDirectory = "Scripts" && record.ScriptFamily = "Normal"
		&& RegExMatch(record.RelativeDirectory, "i)^Custom\\Imported\\([^\\]+)$")
        && LLARS_ImportFolderNameValid(SubStr(record.RelativeDirectory, StrLen("Custom\Imported\") + 1))
}

LLARS_ImportFullPath(path)
{
	VarSetCapacity(buffer, 65536, 0)
	length := DllCall("Kernel32\GetFullPathNameW", "WStr", path, "UInt", 32768, "Ptr", &buffer, "Ptr", 0, "UInt")
	if (!length || length >= 32768)
		return ""
	resolved := StrGet(&buffer, "UTF-16")
	return RegExMatch(resolved, "i)^[A-Z]:\\") ? RTrim(resolved, "\") : ""
}

LLARS_ImportSafePath(path)
{
	; Refuse UNC/device paths, junctions and symbolic links in every component.
	; No destination outside the dedicated managed subtree is ever removed.
	if !RegExMatch(path, "i)^[A-Z]:\\")
		return false
	current := SubStr(path, 1, 3)
	for _, part in StrSplit(SubStr(path, 4), "\")
	{
		if (part = "")
			continue
		current .= (SubStr(current, 0) = "\" ? "" : "\") . part
		attributes := DllCall("Kernel32\GetFileAttributesW", "WStr", current, "UInt")
		if (attributes = 0xFFFFFFFF || (attributes & 0x400))
			return false
	}
	return true
}

LLARS_ImportInventory(folder, ByRef error)
{
	error := ""
	pending := [folder]
	count := 0
	bytes := 0
	while pending.Length()
	{
		current := pending.Pop()
		Loop, Files, % current . "\*", FD
		{
			item := A_LoopFileFullPath
			count++
			if (count > 300 || StrLen(item) > 240)
			{
				error := "Folder exceeds the 300-item or Windows path limit."
				return false
			}
			attributes := DllCall("Kernel32\GetFileAttributesW", "WStr", item, "UInt")
			if (attributes = 0xFFFFFFFF || (attributes & 0x400))
			{
				error := "Folder contains an unreadable item or a linked directory/file."
				return false
			}
			if (attributes & 0x10)
				pending.Push(item)
			else
			{
				bytes += A_LoopFileSize
				if (bytes > 33554432)
				{
					error := "Import exceeds the 32 MB folder limit."
					return false
				}
			}
		}
	}
	return {Items:count, Bytes:bytes}
}

LLARS_ImportNameAvailable(name, oldName := "")
{
	global LLARS_SelectorRegistry
	lowerName := name
	StringLower, lowerName, lowerName
	for _, entry in LLARS_SelectorRegistry.Entries
	{
		lowerExisting := entry.Name
		StringLower, lowerExisting, lowerExisting
		if (lowerExisting = lowerName && entry.Name != oldName)
			return false
	}
	return true
}

LLARS_ImportMetadata(name, difficulty, description, category, ByRef error)
{
	error := ""
	name := Trim(name)
	category := Trim(category)
	description := Trim(description)
	if (name = "" || category = "" || description = "" || StrLen(name) > 80 || StrLen(category) > 40 || StrLen(description) > 400)
		error := "Enter a name (up to 80 chars), category (up to 40), and description (up to 400)."
    else if RegExMatch(name . category, "[\r\n\x00-\x1F\[\]\|]")
        error := "Names and categories cannot contain newlines, controls, brackets or | characters."
    ; User descriptions are arbitrary readable text, including CR/LF, tabs,
    ; brackets and pipes. The registry writer escapes unsafe INI characters.
    ; Do not block a valid multiline edit with the old RegEx character filter.
	else if (difficulty != "Easy" && difficulty != "Intermediate" && difficulty != "Hard")
		error := "Choose a setup difficulty explicitly."
	return (error = "")
}

LLARS_ImportScript(root, selectedPath, displayName, difficulty, description, category, ByRef error)
{
	error := ""
	if !LLARS_ImportMetadata(displayName, difficulty, description, category, error)
		return false
	if !LLARS_ImportNameAvailable(displayName)
	{
		error := "This display name is already registered. Choose a unique name."
		return false
	}
	path := LLARS_ImportFullPath(selectedPath)
	project := LLARS_ImportFullPath(root)
	if (path = "" || project = "" || !FileExist(path) || InStr(FileExist(path), "D") || !RegExMatch(path, "i)\.ahk$"))
	{
		error := "Choose an existing local .ahk script file."
		return false
	}
	SplitPath, path, fileName, sourceDir,, stem
	if (!LLARS_ImportSafePath(path) || !LLARS_ImportSafePath(project))
	{
		error := "The selected path contains an unavailable path, junction, or symbolic link."
		return false
	}
	managedRoot := LLARS_ImportManagedRoot(project)
	customRoot := project . "\Scripts\Custom"
	lowerPath := path
	lowerProject := project
	lowerCustom := customRoot
	StringLower, lowerPath, lowerPath
	StringLower, lowerProject, lowerProject
	StringLower, lowerCustom, lowerCustom
	; Import from an LLARS folder is supported, except anything under the
	; reserved Scripts\Custom tree. Refuse source/destination overlap.
	if (SubStr(lowerPath, 1, StrLen(lowerCustom) + 1) = lowerCustom . "\")
	{
		error := "Scripts inside LLARS\Scripts\Custom cannot be imported again. Use Edit Details for an existing import."
		return false
	}
	withinProject := SubStr(lowerPath, 1, StrLen(lowerProject) + 1) = lowerProject . "\"
	; A script directly in LLARS, Scripts, or Scripts - Menu Entry Swapper
	; must be staged as ONE file: copying an entire project/root would copy
	; the destination into itself, or sweep unrelated scripts and settings.
	copySingleFile := false
	if withinProject
	{
		lowerSource := sourceDir
		StringLower, lowerSource, lowerSource
		if (lowerSource = lowerProject || lowerSource = lowerProject . "\scripts"
			|| lowerSource = lowerProject . "\scripts - menu entry swapper")
			copySingleFile := true
	}
	if copySingleFile
	{
		folderName := stem
		FileGetSize, singleSize, %path%
		if (ErrorLevel || singleSize > 33554432)
		{
			error := "The selected script cannot be read or exceeds the 32 MB limit."
			return false
		}
	}
	else
	{
		if !LLARS_ImportInventory(sourceDir, error)
			return false
		; Retain an actual folder name for ordinary imports, including
		; folders already under LLARS outside Scripts\Custom.
		SplitPath, sourceDir, folderName
	}
	if !LLARS_ImportFolderNameValid(folderName)
	{
		error := "The selected folder/filename is unsafe for managed importing."
		return false
	}
	destination := managedRoot . "\" . folderName
	if FileExist(destination)
	{
		error := "An imported folder with that original folder name already exists. Rename the source folder explicitly or register the existing copy."
		return false
	}
	if (FileExist(managedRoot) && !LLARS_ImportSafePath(managedRoot))
	{
		error := "The managed import directory contains a junction or symbolic link."
		return false
	}
	record := {Name:Trim(displayName), InfoTitle:Trim(displayName), Difficulty:difficulty
		, Description:Trim(description), RelativeDirectory:"Custom\Imported\" . folderName
		, FileName:fileName, Category:Trim(category), RootDirectory:"Scripts"
		, ScriptFamily:"Normal", Author:"User import"}
	if !LLARS_CreatorRegistryValid(record, error)
		return false
	items := LLARS_CreatorRegistryRead(project, error)
	if (error != "")
		return false
	candidateKey := record.RootDirectory . "\" . record.RelativeDirectory . "\" . fileName
	StringLower, candidateKey, candidateKey
	for _, old in items
	{
		oldKey := old.RootDirectory . "\" . old.RelativeDirectory . "\" . old.FileName
		StringLower, oldKey, oldKey
		if (oldKey = candidateKey)
		{
			error := "This script is already registered."
			return false
		}
	}
	created := false
	{
		FileCreateDir, %managedRoot%
		if (ErrorLevel || !LLARS_ImportSafePath(managedRoot))
		{
			error := "Cannot create a safe managed import directory."
			return false
		}
		staging := managedRoot . "\.__import_" . DllCall("GetCurrentProcessId", "UInt") . "_" . A_TickCount
		if FileExist(staging)
		{
			error := "Temporary import folder already exists; retry later."
			return false
		}
		if copySingleFile
		{
			FileCreateDir, %staging%
            if (ErrorLevel)
            {
                error := "Could not create a temporary import directory."
                return false
            }
			FileCopy, %path%, % staging . "\" . fileName
		}
		else
			FileCopyDir, %sourceDir%, %staging%
		if ErrorLevel
		{
			FileRemoveDir, %staging%, 1
			error := "Could not stage the selected script/folder; nothing was registered."
			return false
		}
		stagedInventory := LLARS_ImportInventory(staging, checkError)
		if copySingleFile
			originalInventory := {Items:1, Bytes:singleSize}
		else
			originalInventory := LLARS_ImportInventory(sourceDir, sourceError)
		if (!IsObject(stagedInventory) || !IsObject(originalInventory) || stagedInventory.Items != originalInventory.Items || stagedInventory.Bytes != originalInventory.Bytes)
		{
			FileRemoveDir, %staging%, 1
			error := "Import source changed or staged files failed validation; nothing was registered."
			return false
		}
		FileMoveDir, %staging%, %destination%
		if ErrorLevel
		{
			FileRemoveDir, %staging%, 1
			error := "Could not commit the copied folder; nothing was registered."
			return false
		}
		created := true
	}
	items.Push(record)
	if !LLARS_CreatorRegistryWrite(project, items, error)
	{
		if created
			FileRemoveDir, %destination%, 1
		return false
	}
	confirmed := LLARS_CreatorRegistryRead(project, verifyError)
	if (verifyError != "" || confirmed.Length() != items.Length() || confirmed[confirmed.Length()].Name != record.Name)
	{
		items.Pop()
		if (LLARS_CreatorRegistryWrite(project, items, rollbackError))
		{
			if created
				FileRemoveDir, %destination%, 1
			error := "Registry verification failed; the import was rolled back."
		}
		else
			error := "Registry verification failed and rollback was not confirmed. Preserve the copied folder and registry for recovery. " . rollbackError
		return false
	}
	return true
}

LLARS_ImportUpdateMetadata(root, record, name, difficulty, description, category, ByRef error)
{
	error := ""
	if !LLARS_ImportIsManaged(record)
	{
		error := "Only managed imports can be edited here."
		return false
	}
	if !LLARS_ImportMetadata(name, difficulty, description, category, error)
		return false
	if !LLARS_ImportNameAvailable(name, record.Name)
	{
		error := "That Selector display name is already in use."
		return false
	}
	items := LLARS_CreatorRegistryRead(root, error)
	if (error != "")
		return false
	found := 0
	for index, item in items
	{
		if (item.Name = record.Name && item.RelativeDirectory = record.RelativeDirectory && item.FileName = record.FileName && item.RootDirectory = "Scripts" && item.Author = "User import")
		{
			found := index
			break
		}
	}
	if !found
	{
		error := "Managed import registration is missing or changed."
		return false
	}
	items[found].Name := Trim(name)
	items[found].InfoTitle := Trim(name)
	items[found].Difficulty := difficulty
	items[found].Description := Trim(description)
	items[found].Category := Trim(category)
	return LLARS_CreatorRegistryWrite(root, items, error)
}

LLARS_ImportUnregister(root, record, ByRef error)
{
	error := ""
	if !LLARS_ImportIsManaged(record)
	{
		error := "Only managed imports can be unregistered here."
		return false
	}
	items := LLARS_CreatorRegistryRead(root, error)
	if (error != "")
		return false
	found := 0
	for index, item in items
	{
		if (item.Name = record.Name && item.RelativeDirectory = record.RelativeDirectory && item.FileName = record.FileName && item.RootDirectory = "Scripts" && item.Author = "User import")
		{
			found := index
			break
		}
	}
	if !found
	{
		error := "Managed import registration was not found."
		return false
	}
	items.RemoveAt(found)
	return LLARS_CreatorRegistryWrite(root, items, error)
}
