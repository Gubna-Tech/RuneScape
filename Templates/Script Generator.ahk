; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
SetBatchLines, -1

SplitPath, A_ScriptDir, , GeneratorRoot
GeneratorScriptsRoot := GeneratorRoot . "\Scripts"
GeneratorOutputParent := GeneratorScriptsRoot
GeneratorTemplateChoice := "RunCount - Basic Loop"
GeneratorMainLLARSHWND := Generator_FindMainLLARS()

if FileExist(A_ScriptDir . "\RunCount\Basic Loop\LLARS Logo.ico")
	Menu, Tray, Icon, % A_ScriptDir . "\RunCount\Basic Loop\LLARS Logo.ico"

Generator_GetTemplate(GeneratorTemplateChoice, GeneratorSourceFolder, GeneratorSourceScript, GeneratorDescription)

Gui, +OwnDialogs +HwndGeneratorGuiHWND
Gui, Font, s13 Bold cBlack
Gui, Add, Text, x5 y8 w530 h28 Center, LLARS
Gui, Font, s11 Bold cBlack
Gui, Add, Text, x5 y38 w530 h24 Center, Script Generator
Gui, Add, Text, x110 y68 w320 h2 0x10

Gui, Font, s11 Bold cBlack
Gui, Add, Text, x20 y86 w135 h24, Script Name
Gui, Font, s10 Norm cBlack
Gui, Add, Edit, x165 y83 w350 h28 vGeneratorScriptName

Gui, Font, s11 Bold cBlack
Gui, Add, Text, x20 y128 w135 h24, Template
Gui, Font, s10 Norm cBlack
Gui, Add, DropDownList, x165 y125 w350 vGeneratorTemplateChoice gGeneratorTemplateChanged Choose1, RunCount - Basic Loop|RunCount - Advanced Loop|Timer|MultiTimer|Color Detection|Multi Color Detection

Gui, Font, s11 Bold cBlack
Gui, Add, Text, x20 y170 w135 h24, Create Inside
Gui, Font, s10 Norm cBlack
Gui, Add, Edit, x165 y167 w260 h28 ReadOnly vGeneratorOutputParent, %GeneratorOutputParent%
Gui, Font, s10 Bold cBlack
Gui, Add, Button, x435 y166 w80 h30 gGeneratorBrowse, Browse

Gui, Font, s10 Bold cBlack
Gui, Add, GroupBox, x20 y210 w500 h40, Template Purpose
Gui, Font, s10 Norm cBlack
Gui, Add, Text, x34 y228 w472 h18 vGeneratorDescription, %GeneratorDescription%

Gui, Font, s11 Norm cBlack
Gui, Add, Text, x25 y260 w490 h44 Center, Generated scripts include the template, Config.ini, and LLARS Logo.ico.`nThey stay inside LLARS\Scripts so the shared Core remains available.

Gui, Font, s11 Bold cBlack
Gui, Add, Button, x92 y314 w165 h34 gGeneratorCreate, Create Script
Gui, Add, Button, x283 y314 w165 h34 gGeneratorClose, Close
Gui, Show, w540 h364, LLARS Script Generator
return

~*Esc::
if (GeneratorGuiHWND && WinActive("ahk_id " . GeneratorGuiHWND))
{
	GoSub, GeneratorClose
}
return

GeneratorTemplateChanged:
Gui, Submit, NoHide
Generator_GetTemplate(GeneratorTemplateChoice, GeneratorSourceFolder, GeneratorSourceScript, GeneratorDescription)
GuiControl,, GeneratorDescription, %GeneratorDescription%
return

GeneratorBrowse:
Gui, Submit, NoHide
FileSelectFolder, GeneratorSelectedFolder, *%GeneratorOutputParent%, 3, Select a folder inside the LLARS Scripts folder
if (ErrorLevel || GeneratorSelectedFolder = "")
	return

if !Generator_IsInsideRoot(GeneratorSelectedFolder, GeneratorScriptsRoot)
{
	MsgBox, 48, LLARS Script Generator, Choose the Scripts folder or one of its subfolders so the shared Core bootstrap can be found.
	return
}

GeneratorOutputParent := RTrim(GeneratorSelectedFolder, "\")
GuiControl,, GeneratorOutputParent, %GeneratorOutputParent%
return

GeneratorCreate:
Gui, Submit, NoHide
GeneratorScriptName := Trim(GeneratorScriptName)
GeneratorOutputParent := RTrim(GeneratorOutputParent, "\")

if (GeneratorScriptName = "")
{
	MsgBox, 48, LLARS Script Generator, Enter a script name first.
	return
}

if RegExMatch(GeneratorScriptName, "[\\/:*?""<>|]")
{
	MsgBox, 48, LLARS Script Generator, The script name contains a character Windows cannot use in a file or folder name.
	return
}

if RegExMatch(GeneratorScriptName, "[\. ]$")
{
	MsgBox, 48, LLARS Script Generator, The script name cannot end with a period or space.
	return
}

GeneratorReservedName := GeneratorScriptName
StringUpper, GeneratorReservedName, GeneratorReservedName
if RegExMatch(GeneratorReservedName, "^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\..*)?$")
{
	MsgBox, 48, LLARS Script Generator, That name is reserved by Windows. Please choose a different script name.
	return
}

if (GeneratorScriptName = "." || GeneratorScriptName = "..")
{
	MsgBox, 48, LLARS Script Generator, Please choose a different script name.
	return
}

if !FileExist(GeneratorOutputParent)
{
	MsgBox, 48, LLARS Script Generator, The selected output folder no longer exists.
	return
}

if !Generator_IsInsideRoot(GeneratorOutputParent, GeneratorScriptsRoot)
{
	MsgBox, 48, LLARS Script Generator, Choose the Scripts folder or one of its subfolders so the shared Core bootstrap can be found.
	return
}

Generator_GetTemplate(GeneratorTemplateChoice, GeneratorSourceFolder, GeneratorSourceScript, GeneratorDescription)
GeneratorSourcePath := A_ScriptDir . "\" . GeneratorSourceFolder
GeneratorSourceAHK := GeneratorSourcePath . "\" . GeneratorSourceScript
GeneratorSourceConfig := GeneratorSourcePath . "\Config.ini"
GeneratorSourceIcon := GeneratorSourcePath . "\LLARS Logo.ico"
GeneratorDestination := GeneratorOutputParent . "\" . GeneratorScriptName
GeneratorDestinationAHK := GeneratorDestination . "\" . GeneratorScriptName . ".ahk"

if !FileExist(GeneratorSourceAHK) || !FileExist(GeneratorSourceConfig)
{
	MsgBox, 16, LLARS Script Generator, The selected template files could not be found.`n`nPlease restore the original Templates folder.
	return
}

if FileExist(GeneratorDestination)
{
	MsgBox, 48, LLARS Script Generator, A folder named "%GeneratorScriptName%" already exists in the selected location.`n`nChoose a different script name or output folder.
	return
}

FileCreateDir, %GeneratorDestination%
if (ErrorLevel)
{
	MsgBox, 16, LLARS Script Generator, The destination folder could not be created.
	return
}

FileCopy, %GeneratorSourceAHK%, %GeneratorDestinationAHK%, 0
if (ErrorLevel)
{
	FileRemoveDir, %GeneratorDestination%, 1
	MsgBox, 16, LLARS Script Generator, The script template could not be copied.
	return
}

FileCopy, %GeneratorSourceConfig%, %GeneratorDestination%\Config.ini, 0
if (ErrorLevel)
{
	FileRemoveDir, %GeneratorDestination%, 1
	MsgBox, 16, LLARS Script Generator, Config.ini could not be copied.
	return
}

if FileExist(GeneratorSourceIcon)
	FileCopy, %GeneratorSourceIcon%, %GeneratorDestination%\LLARS Logo.ico, 0

Gui, Destroy
MsgBox, 68, LLARS Script Generator, Script created successfully.`n`n%GeneratorDestinationAHK%`n`nOpen the generated folder now?
IfMsgBox, Yes
	Run, explorer.exe "%GeneratorDestination%"
Generator_ReturnToLLARS()
ExitApp
return

GeneratorClose:
GeneratorGuiClose:
GuiClose:
GuiEscape:
Generator_ReturnToLLARS()
ExitApp

Generator_GetTemplate(choice, ByRef sourceFolder, ByRef sourceScript, ByRef description)
{
	if (choice = "RunCount - Advanced Loop")
	{
		sourceFolder := "RunCount\Advanced Loop"
		sourceScript := "Advanced Loop Script Template.ahk"
		description := "RunCount: first loop differs from the loops that follow."
	}
	else if (choice = "Timer")
	{
		sourceFolder := "Timer"
		sourceScript := "Timer Script Template.ahk"
		description := "Timer: repeat task logic for a user-selected duration."
	}
	else if (choice = "MultiTimer")
	{
		sourceFolder := "MultiTimer"
		sourceScript := "MultiTimer Script Template.ahk"
		description := "MultiTimer: run several independent recurring timed actions."
	}
	else if (choice = "Color Detection")
	{
		sourceFolder := "Color"
		sourceScript := "Color Detection Script Template.ahk"
		description := "Color Detection: react when a configured RuneScape pixel matches."
	}
	else if (choice = "Multi Color Detection")
	{
		sourceFolder := "MultiColor"
		sourceScript := "Multi Color Detection Script Template.ahk"
		description := "Multi Color: watch several pixels and map each target color to its own action."
	}
	else
	{
		sourceFolder := "RunCount\Basic Loop"
		sourceScript := "Basic Loop Script Template.ahk"
		description := "RunCount: repeat the same automation for a fixed number of loops."
	}
}

Generator_ReturnToLLARS()
{
	global GeneratorMainLLARSHWND

	DetectHiddenWindows, On
	if (GeneratorMainLLARSHWND && WinExist("ahk_id " . GeneratorMainLLARSHWND))
	{
		WinShow, % "ahk_id " . GeneratorMainLLARSHWND
		WinActivate, % "ahk_id " . GeneratorMainLLARSHWND
		return
	}

	GeneratorMainLLARSHWND := Generator_FindMainLLARS()
	if (GeneratorMainLLARSHWND)
	{
		WinShow, % "ahk_id " . GeneratorMainLLARSHWND
		WinActivate, % "ahk_id " . GeneratorMainLLARSHWND
	}
}

Generator_FindMainLLARS()
{
	DetectHiddenWindows, On
	WinGet, GeneratorWindowList, List, ahk_class AutoHotkeyGUI
	Loop, %GeneratorWindowList%
	{
		GeneratorWindowHWND := GeneratorWindowList%A_Index%
		WinGetTitle, GeneratorWindowTitle, ahk_id %GeneratorWindowHWND%
		if (GeneratorWindowTitle = "LLARS")
			return GeneratorWindowHWND
	}

	return 0
}

Generator_IsInsideRoot(path, root)
{
	path := RTrim(path, "\")
	root := RTrim(root, "\")
	StringLower, pathLower, path
	StringLower, rootLower, root

	if (pathLower = rootLower)
		return true

	return (SubStr(pathLower, 1, StrLen(rootLower) + 1) = rootLower . "\")
}
