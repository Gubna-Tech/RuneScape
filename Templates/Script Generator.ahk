; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
SetBatchLines, -1

EnvGet, LLARSValidationMode, LLARS_VALIDATION_MODE
if (LLARSValidationMode = "1")
	ExitApp

SplitPath, A_ScriptDir, , GeneratorRoot
GeneratorScriptsRoot := GeneratorRoot . "\Scripts"
GeneratorOutputParent := GeneratorScriptsRoot
GeneratorMESRoot := GeneratorRoot . "\Scripts - Menu Entry Swapper"
GeneratorSequenceFamily := "Normal"
GeneratorSequenceBankingMethod := "Standard banking (Bank Preset)"
GeneratorMainBankingMethod := "Standard banking (Bank Preset)"
GeneratorKeyPickerHWND := 0
GeneratorKeyPickerSearch := ""
GeneratorKeyPickerCategory := "All keys"
GeneratorKeyPickerList := ""
GeneratorSequencePage := 1
GeneratorSequenceFamilyParents := {Normal:GeneratorScriptsRoot, MES:GeneratorMESRoot}
GeneratorSequenceOutputParent := GeneratorScriptsRoot
GeneratorBankingHWND := 0
GeneratorBankingChoice := "Normal LLARS"
GeneratorTemplateChoice := "RunCount - Basic Loop"
GeneratorMainLLARSHWND := Generator_FindMainLLARS()
GeneratorSequence := []
GeneratorActionCatalog := {}
GeneratorActionLookup := {}
GeneratorSequenceHWND := 0
GeneratorActionEditorHWND := 0
GeneratorFlowEditorHWND := 0
GeneratorCustomEditorHWND := 0
GeneratorEditingIndex := 0
GeneratorEditingFunction := ""
GeneratorEditingMode := ""
GeneratorEditingParameterCount := 0
GeneratorEditingFlowIndex := 0
GeneratorEditingCustomIndex := 0
GeneratorConfigSections := {}
GeneratorConfigRequirements := {}
GeneratorConfigHWND := 0
GeneratorConfigEditorHWND := 0
GeneratorConfigEditingKey := ""
GeneratorConfigEditingFieldCount := 0
GeneratorConfigEditorTimingExact := {}
GeneratorConfigTypeLookup := {}
GeneratorConfigImportedCount := 0
GeneratorCapabilitySnapshot := ""
GeneratorCapabilityError := ""
GeneratorPreflightReport := ""
GeneratorStarterCatalog := []
GeneratorStarterLookup := {}
GeneratorStarterHWND := 0
GeneratorStarterChoice := ""
GeneratorRuntimePreview := ""
GeneratorCreatorCategory := "Utility"
GeneratorCreatorDifficulty := "Easy"
GeneratorCreatorDescription := "Created with LLARS Script Generator."
GeneratorCreatorAuthor := ""
GeneratorRegisterSelector := 1
GeneratorCreatedAHK := ""
GeneratorCreatedFolder := ""
GeneratorOpenProjectPath := ""
GeneratorOpenProjectSource := ""
GeneratorOpenProjectConfig := ""
GeneratorOpenProjectHash := ""
GeneratorOpenConfigHash := ""
GeneratorOpenProjectRegister := -1
GeneratorOpenProjectFileHash := ""
GeneratorOpenConfigDisk := ""
GeneratorOpenConfigOriginal := {}
GeneratorSyncingScriptName := false

GeneratorIconPath := GeneratorRoot . "\Assets\Logo\LLARS\LLARS Logo.ico"
if FileExist(GeneratorIconPath)
	Menu, Tray, Icon, %GeneratorIconPath%

Generator_GetTemplate(GeneratorTemplateChoice, GeneratorSourceFolder, GeneratorSourceScript, GeneratorDescription)

Gui, +OwnDialogs +HwndGeneratorGuiHWND
Gui, Font, s14 Bold cBlack
Gui, Add, Text, x25 y12 w680 h30 Center, LLARS Script Generator
Gui, Font, s11 Norm cBlack
Gui, Add, Text, x30 y53 w670 h40 +Wrap Center, Create your own automation without writing code. Start with a guided example or build the steps yourself.
Gui, Font, s11 Bold cBlack
Gui, Add, Text, x30 y112 w145 h27, Name your script
Gui, Font, s11 Norm cBlack
Gui, Add, Edit, x183 y108 w515 h31 vGeneratorScriptName hwndGeneratorScriptNameHwnd gGeneratorScriptIdentityChanged

Gui, Font, s11 Bold cBlack
Gui, Add, Text, x30 y150 w145 h27, Banking method
Gui, Font, s11 Norm cBlack
Gui, Add, DropDownList, x183 y145 w515 vGeneratorMainBankingMethod gGeneratorMainBankingChanged Choose1, Standard banking (Bank Preset)|Menu Entry Swapper (no preset)
Gui, Font, s10 Norm cBlack
Gui, Add, Text, x183 y177 w515 h45 +Wrap, % "Standard: LLARS presses your Bank Preset key.`nMenu Entry Swapper: bank click selects preset. No bank? Standard."
Gui, Font, s11 Bold cBlack
Gui, Add, GroupBox, x22 y230 w688 h142, Recommended: guided script builder
Gui, Font, s11 Norm cBlack
Gui, Add, Text, x40 y264 w448 h75 +Wrap, Choose an example, add actions in the order they happen, and check what the script needs before saving. You can reopen and edit scripts made with the guided builder.
Gui, Font, s11 Bold cBlack
Gui, Add, Button, x507 y269 w185 h53 gGeneratorOpenSequenceBuilder Default, Open Guided Builder
Gui, Font, s10 Norm cBlack
Gui, Add, Text, x40 y345 w648 h22, No programming experience needed. The builder explains each step as you go.

Gui, Font, s11 Bold cBlack
Gui, Add, GroupBox, x22 y388 w688 h170, Experienced users: copy an AutoHotkey code template
Gui, Font, s10 Norm cBlack
Gui, Add, Text, x40 y419 w132 h25, Code template
Gui, Add, DropDownList, x181 y415 w327 vGeneratorTemplateChoice gGeneratorTemplateChanged Choose1, RunCount - Basic Loop|RunCount - Advanced Loop|Timer|MultiTimer|Color Detection|Multi Color Detection
Gui, Font, s10 Bold cBlack
Gui, Add, Button, x520 y411 w170 h42 gGeneratorCreate, Copy Code Template
Gui, Font, s10 Norm cBlack
Gui, Add, Text, x40 y460 w648 h38 +Wrap vGeneratorDescription, %GeneratorDescription%
Gui, Add, Text, x40 y514 w118 h25, Save to folder
Gui, Add, Edit, x164 y509 w426 h28 ReadOnly vGeneratorOutputParent, %GeneratorOutputParent%
Gui, Add, Button, x601 y507 w89 h32 gGeneratorBrowse, Browse
Gui, Font, s10 Norm cBlack
Gui, Add, Text, x35 y571 w575 h32 +Wrap, Code templates are copies for editing in AutoHotkey. Use the guided builder above if you prefer not to write code.
Gui, Add, Button, x611 y567 w97 h35 gGeneratorClose, Close
Gui, Show, w730 h628, LLARS Script Generator
GuiControl, Focus, GeneratorScriptName
SendMessage, 0xB1, -1, -1,, % "ahk_id " . GeneratorScriptNameHwnd
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

GeneratorOpenSequenceBuilder:
Generator_ShowSequenceBuilder()
return

GeneratorMainBankingChanged:
GuiControlGet, selectedBanking, 1:, GeneratorMainBankingMethod
Generator_ApplyUserBankingChoice(Generator_BankingModeFromLabel(selectedBanking))
return

GeneratorScriptIdentityChanged:
; Read only the edited field. Full GUI Submit and project preflight are too
; expensive for a keystroke and can make the edit control appear frozen.
if (GeneratorSyncingScriptName)
    return
GuiControlGet, GeneratorScriptName, 1:, GeneratorScriptName
if (GeneratorSequenceHWND && WinExist("ahk_id " . GeneratorSequenceHWND))
{
    GeneratorSyncingScriptName := true
    GuiControl, Sequence:, GeneratorSequenceScriptName, %GeneratorScriptName%
    GeneratorSyncingScriptName := false
}
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
if (GeneratorSequenceHWND && WinExist("ahk_id " . GeneratorSequenceHWND))
	Generator_UpdatePreview()
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
		if (GeneratorWindowTitle = "LLARS" || InStr(GeneratorWindowTitle, "LLARS - v") = 1)
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

; ================================================================
; |     SEQUENCE BUILDER     -     SEQUENCE BUILDER              |
; ================================================================

GeneratorSequenceCategoryChanged:
Gui, Sequence:Submit, NoHide
Generator_RefreshActionChoices(GeneratorActionCategory)
return

GeneratorSequenceActionChanged:
Gui, Sequence:Submit, NoHide
Generator_UpdateActionHelp(GeneratorActionCategory, GeneratorActionChoice)
return

GeneratorSequenceAdvancedChanged:
Gui, Sequence:Submit, NoHide
Generator_RefreshActionLibrary(GeneratorSequenceAdvanced)
if (GeneratorSequenceAdvanced)
    GuiControl, Sequence:Show, GeneratorSequenceCustomCode
else
    GuiControl, Sequence:Hide, GeneratorSequenceCustomCode
return

GeneratorSequenceAddAction:
Gui, Sequence:Submit, NoHide
GeneratorKey := GeneratorActionCategory . "|" . GeneratorActionChoice
if !GeneratorActionLookup.HasKey(GeneratorKey)
{
	MsgBox, 48, LLARS Sequence Builder, Choose a step from the list first, then click Set Up This Step.
	return
}
Generator_OpenActionEditor(0, GeneratorActionLookup[GeneratorKey])
return

GeneratorCreatorHelpOpen:
Gui, Sequence:Submit, NoHide
key := GeneratorActionCategory . "|" . GeneratorActionChoice
chosen := GeneratorActionLookup.HasKey(key) ? GeneratorActionLookup[key] : ""
Generator_ShowCreatorHelp(chosen)
return

GeneratorSequenceAddFlow:
Generator_OpenFlowEditor(0)
return

GeneratorSequenceAddCustom:
Generator_OpenCustomEditor(0)
return

GeneratorCreatorHelpFilter:
Gui, APIHelp:Submit, NoHide
Generator_RefreshCreatorHelp()
return

GeneratorCreatorHelpSelected:
if (A_GuiEvent = "I" || A_GuiEvent = "Normal" || A_GuiEvent = "DoubleClick")
    Generator_UpdateCreatorHelpSelection()
return

GeneratorCreatorHelpClose:
GeneratorCreatorHelpEscape:
Gui, APIHelp:Destroy
GeneratorCreatorHelpHWND := 0
return

GeneratorActionEditorHelp:
Generator_ShowCreatorHelp(GeneratorEditingFunction)
return

GeneratorActionEditorPreviewChanged:
Generator_UpdateStatusEditorPreview()
return

GeneratorActionKeyCategoryChanged:
Generator_ActionKeyCategoryChanged()
return

GeneratorActionChooseKey:
Generator_ShowKeyPicker()
return

GeneratorKeyPickerFilterChanged:
Generator_RefreshKeyPicker()
return

GeneratorKeyPickerListEvent:
if (A_GuiEvent = "I" || A_GuiEvent = "Normal")
    Generator_UpdateKeyDeliveryHint()
if (A_GuiEvent = "DoubleClick")
    Generator_UseKeyPickerSelection()
return

GeneratorKeyPickerUse:
Generator_UseKeyPickerSelection()
return

GeneratorKeyPickerCancel:
GeneratorKeyPickerClose:
GeneratorKeyPickerEscape:
Gui, KeyPick:Destroy
GeneratorKeyPickerHWND := 0
return

GeneratorKeyPickerAdvanced:
Generator_ActionCustomKey()
return

GeneratorActionCustomKey:
Generator_ActionCustomKey()
return

GeneratorActionEditorProgressChanged:
Generator_UpdateStepProgressPreview()
return

GeneratorSequenceListEvent:
if (A_GuiEvent = "DoubleClick")
    Generator_EditSelectedSequence()
return

GeneratorSequenceEdit:
Generator_EditSelectedSequence()
return

GeneratorSequenceDuplicate:
Generator_DuplicateSelectedSequence()
return

GeneratorSequenceDelete:
Generator_DeleteSelectedSequence()
return

GeneratorSequenceMoveUp:
Generator_MoveSelectedSequence(-1)
return

GeneratorSequenceMoveDown:
Generator_MoveSelectedSequence(1)
return

GeneratorSequenceCreate:
Generator_CreateSequenceScript()
return

GeneratorSequenceOpenProject:
Generator_OpenExistingCreatorProject()
return

GeneratorSequenceSaveProject:
Generator_SaveLoadedCreatorProject()
return

GeneratorSequenceBeginnerHelp:
Generator_ShowBeginnerGuide()
return

GeneratorGuideBack:
if (GeneratorGuidePage > 1)
    GeneratorGuidePage--
Generator_UpdateGuidePage()
GuiControl, Guide:Focus, % (GeneratorGuidePage > 1 ? "GeneratorGuideBackButton" : "GeneratorGuideNextButton")
return

GeneratorGuideNext:
if (GeneratorGuidePage < Generator_GuidePageCount())
    GeneratorGuidePage++
Generator_UpdateGuidePage()
GuiControl, Guide:Focus, % (GeneratorGuidePage < Generator_GuidePageCount() ? "GeneratorGuideNextButton" : "GeneratorGuideBackButton")
return

GeneratorGuideClose:
GeneratorGuideEscape:
Gui, Guide:Destroy
return

GeneratorSequenceIdentity:
Generator_ShowScriptDetails()
return

GeneratorIdentitySave:
Generator_SaveScriptDetails()
return

GeneratorIdentityCancel:
GeneratorIdentityClose:
GeneratorIdentityEscape:
Gui, Identity:Destroy
return

GeneratorCreatedOpenSource:
Run, notepad.exe "%GeneratorCreatedAHK%"
return

GeneratorCreatedOpenFolder:
Run, explorer.exe "%GeneratorCreatedFolder%"
return

GeneratorCreatedOpenSelector:
; Selector takes its authoritative Creator registry snapshot on startup.
; Launching it anew ensures newly registered scripts are visible immediately.
Run, "%A_AhkPath%" "%GeneratorRoot%\Script Selector.ahk", %GeneratorRoot%, UseErrorLevel
if (ErrorLevel)
    MsgBox, 48, LLARS Script Selector, Could not open Script Selector. Close an existing Selector and launch it from the LLARS folder.
return

GeneratorCreatedTest:
MsgBox, 52, LLARS Script Test, Testing executes real input automation. Configure Setup first and only proceed on a safe test screen. Launch this generated script now?
IfMsgBox, No
	return
Run, "%A_AhkPath%" "%GeneratorCreatedAHK%", %GeneratorCreatedFolder%, UseErrorLevel
if (ErrorLevel)
	MsgBox, 16, LLARS Script Test, AutoHotkey could not launch the generated script. Review its path and setup.
return

GeneratorCreatedClose:
GeneratorCreatedEscape:
Gui, Created:Destroy
return

GeneratorSequenceClear:
if !IsObject(GeneratorSequence) || GeneratorSequence.Length() = 0
	return
MsgBox, 52, LLARS Sequence Builder, Clear every action from the current sequence?
IfMsgBox, No
	return
GeneratorSequence := []
Generator_ReconcileConfigRequirements(true)
Generator_RefreshSequence()
return

GeneratorSequenceSize:
if (A_EventInfo != 1)
    Generator_ResizeBuilder(A_GuiHeight)
return

GeneratorSequenceClose:
GeneratorSequenceEscape:
Generator_SyncScriptNameToMain()
Gui, Sequence:Destroy
GeneratorSequenceHWND := 0
return

GeneratorActionEditorSave:
Generator_SaveActionEditor()
return

GeneratorActionEditorCancel:
GeneratorActionEditorClose:
GeneratorActionEditorEscape:
Gui, ActionEdit:Destroy
GeneratorActionEditorHWND := 0
return

GeneratorFlowTypeChanged:
Gui, FlowEdit:Submit, NoHide
Generator_UpdateFlowCountVisibility(GeneratorFlowType)
return

GeneratorFlowEditorSave:
Generator_SaveFlowEditor()
return

GeneratorFlowEditorCancel:
GeneratorFlowEditorClose:
GeneratorFlowEditorEscape:
Gui, FlowEdit:Destroy
GeneratorFlowEditorHWND := 0
return

GeneratorCustomEditorSave:
Generator_SaveCustomEditor()
return

GeneratorCustomEditorCancel:
GeneratorCustomEditorClose:
GeneratorCustomEditorEscape:
Gui, CustomEdit:Destroy
GeneratorCustomEditorHWND := 0
return

GeneratorSequenceSetupPreview:
Generator_ShowSetupRequirements()
return

GeneratorSequenceRunOrder:
Generator_ShowRunOrder()
return

GeneratorSequencePreflightDetails:
Generator_ShowPreflightDetails()
return

GeneratorSequenceRuntimeDetails:
Generator_ShowRuntimeEstimate()
return

GeneratorRunOrderClose:
RunOrderGuiClose:
RunOrderGuiEscape:
Gui, RunOrder:Destroy
return

GeneratorSequenceFamilyChanged:
GuiControlGet, selectedBanking, Sequence:, GeneratorSequenceBankingMethod
Generator_ApplyUserBankingChoice(Generator_BankingModeFromLabel(selectedBanking))
return

GeneratorSequenceScriptNameChanged:
if (GeneratorSyncingScriptName)
    return
; This label fires for EVERY typed character. Do not submit the whole Builder,
; write back into either Edit, or run disk/Selector/scaffold validation here.
; Keep the model current; synchronize the hidden main GUI on review/close/save.
GuiControlGet, GeneratorSequenceScriptName, Sequence:, GeneratorSequenceScriptName
GeneratorScriptName := GeneratorSequenceScriptName
return

GeneratorSequencePageChanged:
; Selecting Review & Save (including by clicking its tab) is a deliberate
; validation boundary, not a text-edit event.
GuiControlGet, generatorPageNow, Sequence:, GeneratorSequencePage
if (generatorPageNow = 2)
{
    Generator_SyncScriptNameToMain()
    Generator_RefreshCreatorPreflight()
}
return

GeneratorSequenceReviewPage:
GuiControl, Sequence:Choose, GeneratorSequencePage, 2
Generator_SyncScriptNameToMain()
Generator_RefreshCreatorPreflight()
return

GeneratorSequenceBuildPage:
GuiControl, Sequence:Choose, GeneratorSequencePage, 1
return

GeneratorSequenceFamilyBrowse:
Generator_BrowseSequenceFamily()
return

GeneratorSequenceBankingWorkflow:
Generator_ShowBankingWorkflow()
return

GeneratorBankingChoiceChanged:
Gui, Banking:Submit, NoHide
Generator_UpdateBankingPreview()
return

GeneratorBankingAdd:
Generator_ApplyBankingWorkflow(false)
return

GeneratorBankingConvert:
GeneratorBankingChoice := GeneratorSequenceFamily = "MES" ? "Standard (Bank Preset)" : "Menu Entry Swapper"
Generator_ApplyBankingWorkflow(true)
return

GeneratorBankingCancel:
GeneratorBankingClose:
GeneratorBankingEscape:
Gui, Banking:Destroy
GeneratorBankingHWND := 0
return

GeneratorSequenceStarterTemplates:
Generator_ShowStarterTemplates()
return

GeneratorStarterChoiceChanged:
Gui, Starter:Submit, NoHide
Generator_UpdateStarterPreview()
return

GeneratorStarterLoad:
Generator_LoadSelectedStarter()
return

GeneratorStarterCancel:
GeneratorStarterClose:
GeneratorStarterEscape:
Gui, Starter:Destroy
GeneratorStarterHWND := 0
return

GeneratorSequenceConfigManager:
Generator_ShowConfigManager()
return

GeneratorConfigAdd:
Generator_OpenConfigEditor()
return

GeneratorConfigEdit:
Generator_EditSelectedConfig()
return

GeneratorConfigRename:
Generator_RenameSelectedConfig()
return

GeneratorConfigRemove:
Generator_RemoveSelectedConfig()
return

GeneratorConfigCreateMissing:
Generator_CreateMissingConfigSections()
return

GeneratorConfigImport:
Generator_ImportExistingConfig()
return

GeneratorConfigClose:
GeneratorConfigEscape:
Gui, ConfigMgr:Destroy
GeneratorConfigHWND := 0
return

GeneratorConfigEditorTypeChanged:
Generator_ConfigEditorTypeChanged()
return

GeneratorConfigEditorModeChanged:
	Generator_ConfigEditorModeChanged()
return

GeneratorConfigUnitsChanged:
    Generator_ConfigTimingUnitsChanged()
return

GeneratorConfigEditorSave:
Generator_SaveConfigEditor()
return

GeneratorConfigEditorCancel:
GeneratorConfigEditorClose:
GeneratorConfigEditorEscape:
Gui, ConfigEdit:Destroy
GeneratorConfigEditorHWND := 0
return

Generator_ShowScriptDetails()
{
	global GeneratorCreatorCategory, GeneratorCreatorDifficulty, GeneratorCreatorDescription, GeneratorCreatorAuthor, GeneratorRegisterSelector
	Gui, Identity:Destroy
	Gui, Identity:New, +OwnDialogs +LabelGeneratorIdentity
	Gui, Identity:Font, s10 Bold
	Gui, Identity:Add, Text, x16 y15 w430, About Your Script
	Gui, Identity:Font, s10 Norm
	Gui, Identity:Add, Text, x16 y50 w100, Category
	Gui, Identity:Add, Edit, x130 y47 w315 h24 vGeneratorCreatorCategory, %GeneratorCreatorCategory%
	Gui, Identity:Add, Text, x16 y87 w100, Difficulty
	Gui, Identity:Add, DropDownList, x130 y82 w210 vGeneratorCreatorDifficulty Choose1, Easy|Intermediate|Hard
	GuiControl, Identity:ChooseString, GeneratorCreatorDifficulty, %GeneratorCreatorDifficulty%
	Gui, Identity:Add, Text, x16 y124 w100, Description
	Gui, Identity:Add, Edit, x130 y119 w315 h55 vGeneratorCreatorDescription, %GeneratorCreatorDescription%
	Gui, Identity:Add, Text, x16 y191 w100, Author (optional)
	Gui, Identity:Add, Edit, x130 y186 w315 h24 vGeneratorCreatorAuthor, %GeneratorCreatorAuthor%
	Gui, Identity:Add, CheckBox, x20 y225 w410 h25 vGeneratorRegisterSelector Checked%GeneratorRegisterSelector%, Show this script in LLARS Selector
	Gui, Identity:Add, Text, x20 y255 w425 h56, Choose a category and describe what your script does. Adding it to Selector makes it easier to launch later. Existing scripts stay safe.
	Gui, Identity:Add, Button, x128 y315 w130 h32 gGeneratorIdentitySave Default, Save Information
	Gui, Identity:Add, Button, x270 y315 w115 h32 gGeneratorIdentityCancel, Cancel
	Gui, Identity:Show, w465 h363, LLARS Script Details
}

Generator_SaveScriptDetails()
{
	global GeneratorCreatorCategory, GeneratorCreatorDifficulty, GeneratorCreatorDescription, GeneratorCreatorAuthor, GeneratorRegisterSelector
	Gui, Identity:Submit, NoHide
	GeneratorCreatorCategory := Trim(GeneratorCreatorCategory)
	GeneratorCreatorDescription := Trim(GeneratorCreatorDescription)
	GeneratorCreatorAuthor := Trim(GeneratorCreatorAuthor)
	if !Generator_ValidateCreatorDetails(detailError)
	{
		MsgBox, 48, LLARS Script Details, %detailError%
		return
	}
	Gui, Identity:Destroy
	Generator_RefreshCreatorPreflight()
}

Generator_ValidateCreatorDetails(ByRef error)
{
	global GeneratorCreatorCategory, GeneratorCreatorDifficulty, GeneratorCreatorDescription, GeneratorCreatorAuthor
	error := ""
	if (GeneratorCreatorCategory = "" || StrLen(GeneratorCreatorCategory) > 50 || !RegExMatch(GeneratorCreatorCategory, "^[A-Za-z0-9][A-Za-z0-9 &+_-]*$"))
		error := "Category must be 1-50 ordinary letters, numbers, spaces or simple punctuation."
	else if (GeneratorCreatorDifficulty != "Easy" && GeneratorCreatorDifficulty != "Intermediate" && GeneratorCreatorDifficulty != "Hard")
		error := "Difficulty must be Easy, Intermediate, or Hard."
	else if (GeneratorCreatorDescription = "" || StrLen(GeneratorCreatorDescription) > 240 || RegExMatch(GeneratorCreatorDescription, "[\r\n\[\]]"))
		error := "Description must be 1-240 characters on one line without section markers."
	else if (StrLen(GeneratorCreatorAuthor) > 90 || RegExMatch(GeneratorCreatorAuthor, "[\r\n\[\]]"))
		error := "Author must be at most 90 characters on one line."
	return (error = "")
}

Generator_SelectorDisplayName(scriptName, family)
{
	return "Creator - " . scriptName . (family = "MES" ? " - MES" : "")
}

Generator_CreateRegistryRecord(destination, scriptName)
{
	global GeneratorRoot, GeneratorSequenceFamily, GeneratorCreatorCategory, GeneratorCreatorDescription, GeneratorCreatorDifficulty, GeneratorCreatorAuthor
	rootName := (GeneratorSequenceFamily = "MES") ? "Scripts - Menu Entry Swapper" : "Scripts"
	family := (GeneratorSequenceFamily = "MES") ? "Menu Entry Swapper" : "Normal"
	familyRoot := GeneratorRoot . "\" . rootName
	relative := SubStr(destination, StrLen(familyRoot) + 2)
	display := Generator_SelectorDisplayName(scriptName, GeneratorSequenceFamily)
	return {Name:display, InfoTitle:display, Difficulty:GeneratorCreatorDifficulty
		, Description:GeneratorCreatorDescription, RelativeDirectory:relative
		, FileName:scriptName . ".ahk", Category:GeneratorCreatorCategory
		, RootDirectory:rootName, ScriptFamily:family, Author:GeneratorCreatorAuthor}
}

Generator_ValidateRegistryTarget(destination, scriptName, ByRef error)
{
	global GeneratorRoot, GeneratorSequenceFamily, GeneratorRegisterSelector
	error := ""
	if !GeneratorRegisterSelector
		return true
	entries := LLARS_CreatorRegistryRead(GeneratorRoot, error)
	if (error != "")
		return false
	item := Generator_CreateRegistryRecord(destination, scriptName)
	if !LLARS_CreatorRegistryValid(item, error)
		return false
	key := item.Name
	StringLower, key, key
	for _, old in entries
	{
		previous := old.Name
		StringLower, previous, previous
		if (previous = key || (old.RootDirectory . "\" . old.RelativeDirectory . "\" . old.FileName) = (item.RootDirectory . "\" . item.RelativeDirectory . "\" . item.FileName))
		{
			error := "A generated Selector entry already uses this identity or destination. Choose another name."
			return false
		}
	}
	; Compare against the authored Selector, not a parallel hard-coded list.
	selector := GeneratorRoot . "\Script Selector.ahk"
	FileRead, authored, %selector%
	if ErrorLevel
	{
		error := "Cannot validate the authoritative Script Selector registry."
		return false
	}
	Loop, Parse, authored, `n, `r
	{
		if RegExMatch(A_LoopField, "^\s*LLARS_SelectorRegistryAdd\(registry,\s*""([^""]+)""", match)
		{
			original := match1
			StringLower, original, original
			if (original = key)
			{
				error := "The authored Script Selector already contains this display name."
				return false
			}
		}
	}
	return true
}

Generator_RegisterCreatedScript(destination, scriptName, ByRef error)
{
	global GeneratorRoot, GeneratorRegisterSelector
	error := ""
	if !GeneratorRegisterSelector
		return true
	old := LLARS_CreatorRegistryRead(GeneratorRoot, error)
	if (error != "")
		return false
	if !Generator_ValidateRegistryTarget(destination, scriptName, error)
		return false
	record := Generator_CreateRegistryRecord(destination, scriptName)
	old.Push(record)
	if !LLARS_CreatorRegistryWrite(GeneratorRoot, old, error)
		return false
	confirm := LLARS_CreatorRegistryRead(GeneratorRoot, checkError)
	if (checkError != "" || confirm.Length() != old.Length() || confirm[confirm.Length()].Name != record.Name)
	{
		old.Pop()
		LLARS_CreatorRegistryWrite(GeneratorRoot, old, restoreError)
		error := "Saved Creator registry failed verification. " . checkError . " " . restoreError
		return false
	}
	return true
}

Generator_ShowCreatedOptions(destination, scriptFile)
{
	global GeneratorCreatedAHK, GeneratorCreatedFolder, GeneratorRegisterSelector
	GeneratorCreatedAHK := scriptFile
	GeneratorCreatedFolder := destination
	Gui, Created:Destroy
	Gui, Created:New, +OwnDialogs +LabelGeneratorCreated
	Gui, Created:Font, s11 Bold
	Gui, Created:Add, Text, x16 y14 w530 h30, Script created and verified
	Gui, Created:Font, s10 Norm
	Gui, Created:Add, Text, x16 y53 w525 h63 +Wrap, % scriptFile . "`nScript Selector: " . (GeneratorRegisterSelector ? "Registered. Choose Open Selector to refresh the list." : "Not registered. You can change this in Script Details next time.")
	Gui, Created:Add, Text, x16 y122 w525 h45, Test Script executes real automation. Review Setup and the generated AHK first; no automatic launch occurs.
	Gui, Created:Add, Button, x15 y181 w126 h32 gGeneratorCreatedOpenSource, View Script File
	Gui, Created:Add, Button, x149 y181 w126 h32 gGeneratorCreatedOpenFolder, Open Folder
	if (GeneratorRegisterSelector)
        Gui, Created:Add, Button, x283 y181 w125 h32 gGeneratorCreatedOpenSelector, Open Selector
    else
        Gui, Created:Add, Button, x283 y181 w125 h32 gGeneratorCreatedTest, Test Script
    Gui, Created:Add, Button, x416 y181 w124 h32 gGeneratorCreatedClose, Close
	Gui, Created:Show, w555 h232, LLARS Script Created
}


; Saved projects are an optional editor snapshot only. The AHK and Config.ini remain
; independently runnable. A loaded project is editable only when the generated files
; still match their saved fingerprints; arbitrary hand-written AHK is never rewritten.
Generator_ProjectHex(value)
{
    out := ""
    Loop, Parse, value
        out .= Format("{:06X}", Ord(A_LoopField))
    return out
}

Generator_ProjectUnhex(value, ByRef error)
{
    if (value = "~")
        return ""
    if (Mod(StrLen(value), 6) || (value != "" && !RegExMatch(value, "i)^[0-9A-F]+$")))
    {
        error := "Invalid encoded Creator project field."
        return ""
    }
    out := ""
    Loop, % StrLen(value) // 6
        out .= Chr("0x" . SubStr(value, (A_Index - 1) * 6 + 1, 6))
    return out
}

Generator_ProjectHash(text)
{
    a := 1729, b := 7919
    Loop, Parse, text
    {
        n := Ord(A_LoopField)
        a := Mod(a * 131 + n, 2147483647)
        b := Mod(b * 137 + n, 2147483629)
    }
    return StrLen(text) . ":" . a . ":" . b
}

Generator_ProjectFileHash(path)
{
    if !FileExist(path)
        return "NONE"
    FileRead, text, %path%
    if ErrorLevel
        return "ERROR"
    return Generator_ProjectHash(text)
}

Generator_ProjectLine(kind, a, b := "", c := "")
{
    ; Keep four explicit fields, including empty values, for reliable AHK StrSplit.
    if (kind = "SECTION" && b = "")
        b := "-"
    if (c = "")
        c := "~"
    return kind . "|" . a . "|" . b . "|" . c . "`r`n"
}

Generator_WriteCreatorProject(projectPath, scriptPath, configPath, ByRef error)
{
    global GeneratorSequence, GeneratorConfigSections, GeneratorScriptName, GeneratorSequenceFamily
    global GeneratorCreatorCategory, GeneratorCreatorDifficulty, GeneratorCreatorDescription, GeneratorCreatorAuthor, GeneratorRegisterSelector
    error := ""
    text := "LLARS_CREATOR_PROJECT_V1`r`n"
    details := {ScriptName:GeneratorScriptName, Family:GeneratorSequenceFamily
        , Category:GeneratorCreatorCategory, Difficulty:GeneratorCreatorDifficulty
        , Description:GeneratorCreatorDescription, Author:GeneratorCreatorAuthor
        , RegisterSelector:GeneratorRegisterSelector, SourceHash:Generator_ProjectFileHash(scriptPath)
        , ConfigHash:Generator_ProjectFileHash(configPath)}
    if (details.SourceHash = "ERROR" || details.ConfigHash = "ERROR")
    {
        error := "Unable to fingerprint the generated files."
        return false
    }
    for key, val in details
        text .= Generator_ProjectLine("META", key, Generator_ProjectHex(val))
    text .= Generator_ProjectLine("COUNT", GeneratorSequence.Length(), GeneratorConfigSections.Count())
    for index, node in GeneratorSequence
    {
        if !IsObject(node)
        {
            error := "An action could not be serialized."
            return false
        }
        text .= Generator_ProjectLine("NODE", index, Generator_ProjectHex(node.Kind))
        for key, value in node
        {
            if (key = "Values")
            {
                for field, fieldValue in value
                    text .= Generator_ProjectLine("ARG", index, field, Generator_ProjectHex(fieldValue))
            }
            else
                text .= Generator_ProjectLine("PROP", index, key, Generator_ProjectHex(value))
        }
    }
    for key, section in GeneratorConfigSections
    {
        text .= Generator_ProjectLine("SECTION", Generator_ProjectHex(key))
        for prop, val in section
        {
            ; PreserveKey is an editor-only link to the original INI section.
            if (prop = "PreserveKey")
                continue
            if (prop = "Values")
            {
                for field, fieldVal in val
                    text .= Generator_ProjectLine("FIELD", Generator_ProjectHex(key), field, Generator_ProjectHex(fieldVal))
            }
            else
                text .= Generator_ProjectLine("SETTING", Generator_ProjectHex(key), prop, Generator_ProjectHex(val))
        }
    }
    text .= "END|LLARS`r`n"
    file := FileOpen(projectPath, "w", "UTF-16")
    if !IsObject(file)
    {
        error := "Creator project file could not be written."
        return false
    }
    file.Write(text)
    file.Close()
    return FileExist(projectPath) ? true : false
}

Generator_ParseCreatorProject(projectPath, ByRef project, ByRef error)
{
    error := ""
    FileRead, contents, %projectPath%
    if (ErrorLevel || SubStr(contents, 1, 24) != "LLARS_CREATOR_PROJECT_V1")
    {
        error := "This is not a supported LLARS Creator project."
        return false
    }
    project := {Meta:{}, Sequence:[], Config:{}}
    countNodes := -1, countConfig := -1, endSeen := false
    for _, line in StrSplit(contents, "`n", "`r")
    {
        if (line = "" || line = "LLARS_CREATOR_PROJECT_V1")
            continue
        fields := StrSplit(line, "|")
        kind := fields[1]
        if (kind = "META" && fields.Length() = 4)
            project.Meta[fields[2]] := Generator_ProjectUnhex(fields[3], error)
        else if (kind = "COUNT" && fields.Length() = 4)
            countNodes := fields[2], countConfig := fields[3]
        else if (kind = "NODE" && fields.Length() = 4)
        {
            index := fields[2]
            if (index != project.Sequence.Length() + 1 || index > 5000)
                error := "Creator project action ordering is invalid."
            else
                project.Sequence.Push({Kind:Generator_ProjectUnhex(fields[3], error), Values:{}})
        }
        else if (kind = "PROP" && fields.Length() = 4)
        {
            index := fields[2]
            if (index < 1 || index > project.Sequence.Length())
                error := "Unexpected action property index."
            else if (fields[3] != "Values")
                project.Sequence[index][fields[3]] := Generator_ProjectUnhex(fields[4], error)
        }
        else if (kind = "ARG" && fields.Length() = 4)
        {
            index := fields[2]
            if (index < 1 || index > project.Sequence.Length())
                error := "Unexpected action argument index."
            else
                project.Sequence[index].Values[fields[3]] := Generator_ProjectUnhex(fields[4], error)
        }
        else if (kind = "SECTION" && fields.Length() = 4)
        {
            key := Generator_ProjectUnhex(fields[2], error)
            if (project.Config.HasKey(key) || key = "")
                error := "Duplicate or empty project section."
            else
                project.Config[key] := {Values:{}}
        }
        else if ((kind = "SETTING" || kind = "FIELD") && fields.Length() = 4)
        {
            key := Generator_ProjectUnhex(fields[2], error)
            if !project.Config.HasKey(key)
                error := "Unexpected project config field."
            else if (kind = "SETTING" && fields[3] != "Values")
                project.Config[key][fields[3]] := Generator_ProjectUnhex(fields[4], error)
            else if (kind = "FIELD")
                project.Config[key].Values[fields[3]] := Generator_ProjectUnhex(fields[4], error)
        }
        else if (kind = "END" && fields[2] = "LLARS")
            endSeen := true
        else
            error := "Unknown Creator project record."
        if (error != "")
            return false
    }
    if (!endSeen || !RegExMatch(countNodes, "^\d+$") || countNodes > 5000 || !RegExMatch(countConfig, "^\d+$") || countConfig > 1000
        || countNodes != project.Sequence.Length() || countConfig != project.Config.Count())
    {
        error := "Creator project records are incomplete."
        return false
    }
    for _, key in ["ScriptName", "Family", "Category", "Difficulty", "Description", "Author", "RegisterSelector", "SourceHash", "ConfigHash"]
        if !project.Meta.HasKey(key)
        {
            error := "Missing Creator project field: " . key
            return false
        }
    return true
}

; Read an editable Creator Config.ini as typed sections. Never reconstruct a
; hand-edited file from generated defaults: its values, comments and extra keys
; are authoritative, while its section identity/type must remain unambiguous.
Generator_LoadExistingConfig(configFile, projectConfig, ByRef merged, ByRef disk, ByRef error)
{
    error := ""
    merged := {}
    disk := {Blocks:[], ByKey:{}, Preamble:"", Exists:false}
    if !FileExist(configFile)
    {
        if (projectConfig.Count())
            error := "Config.ini was deleted. Restore it before editing this project."
        return (error = "")
    }
    FileRead, raw, %configFile%
    if ErrorLevel
    {
        error := "Cannot read Config.ini."
        return false
    }
    disk.Exists := true
    ; All edited sections are written with CRLF; unedited files are copied byte for byte.
    normalized := StrReplace(StrReplace(raw, "`r`n", "`n"), "`r", "`n")
    current := ""
    lines := StrSplit(normalized, "`n")
    for lineNumber, line in lines
    {
        ; The trailing element of a terminated file is not an extra line.
        if (lineNumber = lines.Length() && line = "")
            break
        trimmed := Trim(line)
        if RegExMatch(trimmed, "^\[([^\[\]]+)\]$", match)
        {
            name := Trim(match1)
            key := Generator_NormalizeConfigName(name)
            if (key = "" || disk.ByKey.HasKey(key))
            {
                error := "Config.ini has an empty or repeated section name: " . name
                return false
            }
            current := {Key:key, Name:name, Lines:[], Values:{}, Seen:{}, Raw:""}
            disk.ByKey[key] := current
            disk.Blocks.Push(current)
        }
        else if (SubStr(trimmed, 1, 1) = "[")
        {
            error := "Invalid Config.ini section header: " . trimmed
            return false
        }
        if !IsObject(current)
        {
            disk.Preamble .= line . "`r`n"
            continue
        }
        current.Lines.Push(line)
        current.Raw .= line . "`r`n"
        if (trimmed = "" || SubStr(trimmed, 1, 1) = ";" || SubStr(trimmed, 1, 1) = "#" || SubStr(trimmed, 1, 1) = "[")
            continue
        eq := InStr(line, "=")
        if !eq
            continue
        field := Trim(SubStr(line, 1, eq - 1))
        StringLower, field, field
        if (field = "")
            continue
        if current.Seen.HasKey(field)
        {
            error := "Config.ini has a repeated field in [" . current.Name . "]: " . field
            return false
        }
        current.Seen[field] := true
        current.Values[field] := Trim(SubStr(line, eq + 1))
    }
    for key, section in projectConfig
    {
        if !disk.ByKey.HasKey(key)
        {
            error := "Saved Config.ini section is missing: [" . section.Name . "]."
            return false
        }
        block := disk.ByKey[key]
        if (section.ReadOnly)
        {
            section.RawText := block.Raw
            section.Values := block.Values
        }
        else
        {
            definition := LLARS_CreatorConfigGet(section.Type, section.Mode)
            if !IsObject(definition)
            {
                error := "Unknown Creator section type in [" . section.Name . "]."
                return false
            }
            if (definition.TypeLine != "")
            {
                if (!block.Values.HasKey("type") || block.Values.type != definition.TypeLine)
                {
                    error := "Section [" . section.Name . "] has a missing or changed type."
                    return false
                }
            }
            else if (block.Values.HasKey("type"))
            {
                error := "Unexpected type conversion in section [" . section.Name . "]."
                return false
            }
            ; A Point/Area conversion drops data; reject instead of guessing.
            if (section.Type = "coordinate")
            {
                if (section.Mode = "Point" && (block.Values.HasKey("xmin") || block.Values.HasKey("xmax") || block.Values.HasKey("ymin") || block.Values.HasKey("ymax")))
                {
                    error := "Coordinate [" . section.Name . "] was changed from Point to Area outside Creator."
                    return false
                }
                if (section.Mode = "Area" && (block.Values.HasKey("x") || block.Values.HasKey("y")))
                {
                    error := "Coordinate [" . section.Name . "] was changed from Area to Point outside Creator."
                    return false
                }
            }
            for _, field in definition.Fields
            {
                if !block.Values.HasKey(field.Name)
                {
                    error := "Missing managed field in [" . section.Name . "]: " . field.Name
                    return false
                }
                value := block.Values[field.Name]
                if !Generator_ValidateConfigField(field, value, fieldError)
                {
                    error := section.Name . ": " . fieldError
                    return false
                }
                section.Values[field.Name] := value
            }
            if ((section.Type = "timer" || section.Type = "timing_range") && (section.Values.min + 0) > (section.Values.max + 0))
            {
                error := "Minimum exceeds maximum in [" . section.Name . "]."
                return false
            }
        }
        section.PreserveKey := key
        merged[key] := section
    }
    ; Additional user-owned sections are never dropped or rewritten.
    for _, block in disk.Blocks
    {
        if merged.HasKey(block.Key)
            continue
        merged[block.Key] := {Name:block.Name, Type:Generator_InferImportedConfigType(block.Name, block.Values), Mode:"", Values:block.Values
            , Description:"", Source:"external", ReadOnly:true, Required:false, Orphan:false, RawText:block.Raw, PreserveKey:block.Key}
    }
    return true
}

Generator_RecordConfigBaseline()
{
    global GeneratorConfigSections, GeneratorOpenConfigOriginal
    GeneratorOpenConfigOriginal := {}
    for key, section in GeneratorConfigSections
    {
        if !section.HasKey("PreserveKey")
            continue
        values := {}
        for field, val in section.Values
            values[field] := val
        GeneratorOpenConfigOriginal[section.PreserveKey] := {Name:section.Name, Type:section.Type, Mode:section.Mode, Values:values}
    }
}

Generator_ConfigSectionEdited(section, original)
{
    if (section.Name != original.Name || section.Type != original.Type || section.Mode != original.Mode)
        return true
    for field, val in section.Values
        if (!original.Values.HasKey(field) || original.Values[field] != val)
            return true
    for field, val in original.Values
        if !section.Values.HasKey(field)
            return true
    return false
}

; Safely patch managed fields in the original file, preserving every untouched
; section, comment, header, extra field and user-authored value. Unchanged files
; use FileCopy so their original encoding/BOM/line endings are also retained.
Generator_BuildPreservedConfig(ByRef text, ByRef copyOriginal, ByRef error)
{
    global GeneratorOpenConfigDisk, GeneratorOpenConfigOriginal, GeneratorConfigSections
    error := "", text := "", copyOriginal := false
    disk := GeneratorOpenConfigDisk
    if !IsObject(disk)
    {
        text := Generator_BuildConfigPreview()
        return true
    }
    byOriginal := {}
    changed := false
    for key, section in GeneratorConfigSections
    {
        if !section.HasKey("PreserveKey")
        {
            changed := true
            continue
        }
        originalKey := section.PreserveKey
        if (!GeneratorOpenConfigOriginal.HasKey(originalKey) || byOriginal.HasKey(originalKey))
        {
            error := "Ambiguous or unsaved Config.ini section identity."
            return false
        }
        byOriginal[originalKey] := section
        original := GeneratorOpenConfigOriginal[originalKey]
        if Generator_ConfigSectionEdited(section, original)
            changed := true
    }
    for _, block in disk.Blocks
        if !byOriginal.HasKey(block.Key)
            changed := true
    if (!changed && disk.Exists)
    {
        copyOriginal := true
        return true
    }
    text := disk.Preamble
    for _, block in disk.Blocks
    {
        if !byOriginal.HasKey(block.Key)
            continue  ; removed explicitly in Creator
        section := byOriginal[block.Key]
        original := GeneratorOpenConfigOriginal[block.Key]
        if section.ReadOnly
        {
            if Generator_ConfigSectionEdited(section, original)
            {
                error := "An imported/read-only Config.ini section was changed."
                return false
            }
            text .= block.Raw
            continue
        }
        if (section.Type != original.Type || section.Mode != original.Mode)
        {
            error := "Changing the type or Point/Area mode of an existing Config.ini section could discard values. Create a new section instead."
            return false
        }
        definition := LLARS_CreatorConfigGet(section.Type, section.Mode)
        if !IsObject(definition)
        {
            error := "Unsupported Config.ini section type."
            return false
        }
        first := true
        for _, line in block.Lines
        {
            if (first)
            {
                text .= "[" . section.Name . "]`r`n"
                first := false
                continue
            }
            if RegExMatch(line, "^([ \t]*[^=\r\n]+?[ \t]*=[ \t]*)(.*)$", match)
            {
                fieldKey := Trim(SubStr(match1, 1, InStr(match1, "=") - 1))
                StringLower, fieldKey, fieldKey
                if (section.Values.HasKey(fieldKey) && original.Values.HasKey(fieldKey)
                    && section.Values[fieldKey] != original.Values[fieldKey])
                {
                    text .= match1 . section.Values[fieldKey] . "`r`n"
                    continue
                }
            }
            text .= line . "`r`n"
        }
    }
    for key, section in GeneratorConfigSections
    {
        if section.HasKey("PreserveKey")
            continue
        if section.ReadOnly
        {
            if (section.RawText = "")
            {
                error := "Imported Config.ini section has no raw text to preserve."
                return false
            }
            if (text != "" && SubStr(text, 0) != "`n")
                text .= "`r`n"
            text .= RTrim(section.RawText, "`r`n") . "`r`n`r`n"
            continue
        }
        definition := LLARS_CreatorConfigGet(section.Type, section.Mode)
        if !IsObject(definition)
        {
            error := "New Config.ini section has an unsupported type."
            return false
        }
        if (text != "" && SubStr(text, 0) != "`n")
            text .= "`r`n"
        text .= "[" . section.Name . "]`r`n"
        if (definition.TypeLine != "")
            text .= "type=" . definition.TypeLine . "`r`n"
        for _, field in definition.Fields
            text .= field.Name . "=" . section.Values[field.Name] . "`r`n"
        text .= "`r`n"
    }
    return true
}

Generator_OpenExistingCreatorProject()
{
    global GeneratorSequence, GeneratorConfigSections, GeneratorSequenceFamily, GeneratorSequenceOutputParent
    global GeneratorScriptName, GeneratorCreatorCategory, GeneratorCreatorDifficulty, GeneratorCreatorDescription, GeneratorCreatorAuthor, GeneratorRegisterSelector
    global GeneratorOpenProjectPath, GeneratorOpenProjectSource, GeneratorOpenProjectConfig, GeneratorOpenProjectHash, GeneratorOpenConfigHash, GeneratorOpenProjectRegister
    global GeneratorScriptsRoot, GeneratorMESRoot, GeneratorOpenProjectFileHash, GeneratorOpenConfigDisk
    FileSelectFile, scriptFile, 1, %GeneratorScriptsRoot%, Open a script created by LLARS Sequence Builder, AutoHotkey scripts (*.ahk)
    if (ErrorLevel || scriptFile = "")
        return
    SplitPath, scriptFile, selectedName, folder, extension, stem
    projectFile := folder . "\Creator Project.llars"
    if !FileExist(projectFile)
    {
        MsgBox, 52, LLARS Open Script, This script has no editable Creator project record. Existing hand-written scripts cannot safely be reconstructed from arbitrary AHK.`n`nOpen the source in Notepad instead?
        IfMsgBox, Yes
            Run, notepad.exe "%scriptFile%"
        return
    }
    if !Generator_ParseCreatorProject(projectFile, project, error)
    {
        MsgBox, 16, LLARS Open Script, %error%
        return
    }
    family := project.Meta.Family
    root := family = "MES" ? GeneratorMESRoot : GeneratorScriptsRoot
    if ((family != "Normal" && family != "MES") || !Generator_IsInsideRoot(folder, root)
        || stem != project.Meta.ScriptName || selectedName != project.Meta.ScriptName . ".ahk")
    {
        MsgBox, 16, LLARS Open Script, The script name or family does not match the saved Creator project.
        return
    }
    configFile := folder . "\Config.ini"
    if (Generator_ProjectFileHash(scriptFile) != project.Meta.SourceHash)
    {
        MsgBox, 52, LLARS Open Script, The generated AHK was edited outside Sequence Builder. It cannot safely be overwritten.`n`nOpen the AHK in Notepad?
        IfMsgBox, Yes
            Run, notepad.exe "%scriptFile%"
        return
    }
    configChanged := (Generator_ProjectFileHash(configFile) != project.Meta.ConfigHash)
    if !Generator_LoadExistingConfig(configFile, project.Config, mergedConfig, disk, configError)
    {
        MsgBox, 16, LLARS Open Script, % "Config.ini could not be imported safely: " . configError . "`n`nYour files were not changed."
        return
    }
    if configChanged
    {
        MsgBox, 36, LLARS Open Script, Your Config.ini has been edited since the last Creator save.`n`nImport the current hotkeys and settings and preserve the external comments and extra fields when saving?`n`nThe generated AHK will still be protected from outside edits.
        IfMsgBox, No
            return
    }
    if (GeneratorSequence.Length() > 0)
    {
        MsgBox, 52, LLARS Open Script, Opening another project replaces the current unsaved sequence and config. Continue?
        IfMsgBox, No
            return
    }
    GeneratorSequence := project.Sequence
    GeneratorConfigSections := mergedConfig
    GeneratorOpenConfigDisk := disk
    Generator_RecordConfigBaseline()
    GeneratorScriptName := project.Meta.ScriptName
    GeneratorCreatorCategory := project.Meta.Category
    GeneratorCreatorDifficulty := project.Meta.Difficulty
    GeneratorCreatorDescription := project.Meta.Description
    GeneratorCreatorAuthor := project.Meta.Author
    GeneratorRegisterSelector := project.Meta.RegisterSelector
    GeneratorOpenProjectRegister := project.Meta.RegisterSelector
    GeneratorSequenceFamily := family
    SplitPath, folder, , parentFolder
    GeneratorSequenceOutputParent := parentFolder  ; the saved destination stays fixed separately
    GeneratorOpenProjectPath := projectFile
    GeneratorOpenProjectSource := scriptFile
    GeneratorOpenProjectConfig := configFile
    GeneratorOpenProjectHash := project.Meta.SourceHash
    GeneratorOpenConfigHash := Generator_ProjectFileHash(configFile)
    GeneratorOpenProjectFileHash := Generator_ProjectFileHash(projectFile)
    GuiControl, 1:, GeneratorScriptName, %GeneratorScriptName%
    GuiControl, Sequence:, GeneratorSequenceScriptName, %GeneratorScriptName%
    GuiControl, Sequence:Disable, GeneratorSequenceScriptName
    GuiControl, Sequence:ChooseString, GeneratorSequenceBankingMethod, % Generator_BankingLabel(family)
    GuiControl, Sequence:Disable, GeneratorSequenceBankingMethod
    GuiControl, 1:Disable, GeneratorMainBankingMethod
    GuiControl, Sequence:Disable, GeneratorSequenceFamilyBrowse
    GuiControl, Sequence:, GeneratorSequenceOutputParent, %parentFolder%
    Generator_ReconcileConfigRequirements(false)
    Generator_RefreshSequence()
    GuiControl, Sequence:, GeneratorProjectStatus, % "Editing: " . GeneratorScriptName . " (AHK protected; Config.ini values preserved)"
    GuiControl, Sequence:Disable, GeneratorSequenceCreate
    GuiControl, Sequence:Enable, GeneratorSequenceSaveProject
    GuiControl, Sequence:Choose, GeneratorSequencePage, 1
    MsgBox, 64, LLARS Open Script, Project loaded. You can edit actions without losing the current Config.ini hotkeys or setup values. Save Changes retains external comments and extra fields, with backup/rollback.
}

; Remove only this save attempt's staged outputs on a cancelled or failed
; pre-commit path. Leftover .llars-pending files would otherwise make the
; next Save Changes attempt refuse to run, even though no user file changed.
Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
{
    FileDelete, %tmpAHK%
    FileDelete, %tmpINI%
    FileDelete, %tmpProject%
}

Generator_SaveLoadedCreatorProject()
{
    global GeneratorOpenProjectPath, GeneratorOpenProjectSource, GeneratorOpenProjectConfig, GeneratorOpenProjectHash, GeneratorOpenConfigHash, GeneratorOpenProjectRegister
    global GeneratorScriptName, GeneratorSequence, GeneratorCreatorCategory, GeneratorCreatorDifficulty, GeneratorCreatorDescription, GeneratorCreatorAuthor, GeneratorRegisterSelector
    global GeneratorRoot, GeneratorOpenProjectFileHash, GeneratorOpenConfigDisk, GeneratorConfigSections
    if (GeneratorOpenProjectPath = "")
    {
        MsgBox, 48, LLARS Save Changes, Open an existing Creator project first. Use Create from Sequence for new projects.
        return
    }
    Gui, 1:Submit, NoHide
    if (Generator_ProjectFileHash(GeneratorOpenProjectSource) != GeneratorOpenProjectHash || Generator_ProjectFileHash(GeneratorOpenProjectConfig) != GeneratorOpenConfigHash || Generator_ProjectFileHash(GeneratorOpenProjectPath) != GeneratorOpenProjectFileHash)
    {
        MsgBox, 16, LLARS Save Changes, Files changed since this project was opened. Save was cancelled. Reopen the project to safely import new Config.ini edits; external AHK changes are never overwritten.
        return
    }
    if (GeneratorRegisterSelector != GeneratorOpenProjectRegister)
    {
        MsgBox, 48, LLARS Save Changes, Selector registration cannot be changed while editing an existing script. Restore its original selection in Script Details.
        return
    }
    p := Generator_RunCreatorPreflight(false)
    Generator_DisplayCreatorPreflight(p)
    if (p.Errors)
    {
        MsgBox, 48, LLARS Save Changes, % "Fix the " . p.Errors . " preflight error(s) before saving."
        return
    }
    SplitPath, GeneratorOpenProjectSource, , dir, , stem
    if (stem != GeneratorScriptName)
    {
        MsgBox, 16, LLARS Save Changes, Changing the script name of an existing project is not supported. Create a new project instead.
        return
    }
    source := A_ScriptDir . "\RunCount\Basic Loop\Basic Loop Script Template.ahk"
    FileRead, scaffold, %source%
    if ErrorLevel
        return
    block := Generator_BuildEditableBlock()
    fresh := Generator_InjectEditableBlock(scaffold, block, injectError)
    if (fresh = "")
    {
        MsgBox, 16, LLARS Save Changes, %injectError%
        return
    }
    fresh := "; Creator: " . GeneratorScriptName . " | " . GeneratorCreatorCategory . " | " . GeneratorCreatorDifficulty . "`r`n; Description: " . GeneratorCreatorDescription . "`r`n" . fresh
    if (GeneratorCreatorAuthor != "")
        fresh := "; Author: " . GeneratorCreatorAuthor . "`r`n" . fresh
    suffix := ".llars-pending-" . DllCall("GetCurrentProcessId", "UInt")
    tmpAHK := GeneratorOpenProjectSource . suffix
    tmpINI := GeneratorOpenProjectConfig . suffix
    tmpProject := GeneratorOpenProjectPath . suffix
    bakAHK := GeneratorOpenProjectSource . ".llars-backup"
    bakINI := GeneratorOpenProjectConfig . ".llars-backup"
    bakProject := GeneratorOpenProjectPath . ".llars-backup"
    if FileExist(tmpAHK) || FileExist(tmpINI) || FileExist(tmpProject) || FileExist(bakAHK) || FileExist(bakINI) || FileExist(bakProject)
    {
        MsgBox, 16, LLARS Save Changes, Pending or backup files already exist. Inspect them before saving.
        return
    }
    FileAppend, %fresh%, %tmpAHK%, UTF-8
    if ErrorLevel
    {
        Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
        MsgBox, 16, LLARS Save Changes, AHK staging failed. Original files are unchanged.
        return
    }
    if (Generator_ConfigHasSections() || FileExist(GeneratorOpenProjectConfig))
    {
        if !Generator_BuildPreservedConfig(configText, copyOriginal, configError)
        {
            Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
            MsgBox, 16, LLARS Save Changes, %configError%
            return
        }
        if (copyOriginal)
            FileCopy, %GeneratorOpenProjectConfig%, %tmpINI%, 0
        else
            FileAppend, %configText%, %tmpINI%, UTF-16
        if ErrorLevel
        {
            Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
            MsgBox, 16, LLARS Save Changes, Config.ini staging failed. Existing files are untouched.
            return
        }
    }
    expected := Generator_ScanGeneratedCapabilities(scanError)
    actual := LLARS_ConfigCapabilityScan(tmpINI, tmpAHK)
    if (scanError != "" || !Generator_CapabilityParity(expected, actual, parityError))
    {
        Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
        MsgBox, 16, LLARS Save Changes, Generated config failed capability validation. Original files are unchanged.
        return
    }
    if !Generator_WriteCreatorProject(tmpProject, tmpAHK, tmpINI, projectError)
    {
        Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
        MsgBox, 16, LLARS Save Changes, %projectError%
        return
    }
    MsgBox, 36, LLARS Save Changes, Save the Creator changes? The AHK will be updated, while existing Config.ini hotkeys and other user values will be preserved. Original files will be backed up until verification completes.
    IfMsgBox, No
    {
        Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
        return
    }
    if (Generator_ProjectFileHash(GeneratorOpenProjectSource) != GeneratorOpenProjectHash || Generator_ProjectFileHash(GeneratorOpenProjectConfig) != GeneratorOpenConfigHash || Generator_ProjectFileHash(GeneratorOpenProjectPath) != GeneratorOpenProjectFileHash)
    {
        Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
        MsgBox, 16, LLARS Save Changes, Files changed during review. Existing files were not overwritten.
        return
    }
    FileCopy, %GeneratorOpenProjectSource%, %bakAHK%, 0
    if (ErrorLevel)
    {
        FileDelete, %bakAHK%
        Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
        return
    }
    FileCopy, %GeneratorOpenProjectPath%, %bakProject%, 0
    if (ErrorLevel)
    {
        FileDelete, %bakAHK%
        Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
        return
    }
    hadINI := FileExist(GeneratorOpenProjectConfig) ? true : false
    if hadINI
    {
        FileCopy, %GeneratorOpenProjectConfig%, %bakINI%, 0
        if ErrorLevel
        {
            FileDelete, %bakAHK%
            FileDelete, %bakProject%
            Generator_CleanupStagedCreatorSave(tmpAHK, tmpINI, tmpProject)
            return
        }
    }
    committed := true
    FileMove, %tmpAHK%, %GeneratorOpenProjectSource%, 1
    if ErrorLevel
        committed := false
    if (committed && FileExist(tmpINI))
    {
        FileMove, %tmpINI%, %GeneratorOpenProjectConfig%, 1
        if ErrorLevel
            committed := false
    }
    else if (committed && hadINI)
        FileDelete, %GeneratorOpenProjectConfig%
    if committed
    {
        FileMove, %tmpProject%, %GeneratorOpenProjectPath%, 1
        if ErrorLevel
            committed := false
    }
    if committed
        committed := Generator_UpdateCreatorRegistryOnEdit(dir, registryError)
    if !committed
    {
        rollbackOK := true
        FileCopy, %bakAHK%, %GeneratorOpenProjectSource%, 1
        if ErrorLevel
            rollbackOK := false
        FileCopy, %bakProject%, %GeneratorOpenProjectPath%, 1
        if ErrorLevel
            rollbackOK := false
        if hadINI
        {
            FileCopy, %bakINI%, %GeneratorOpenProjectConfig%, 1
            if ErrorLevel
                rollbackOK := false
        }
        else
        {
            FileDelete, %GeneratorOpenProjectConfig%
            if FileExist(GeneratorOpenProjectConfig)
                rollbackOK := false
        }
        if rollbackOK
            MsgBox, 16, LLARS Save Changes, % "Update failed. Original files were restored. " . registryError
        else
        {
            MsgBox, 16, LLARS Save Changes, Rollback needs attention. Backup files have been retained beside the script. Do not run the edited files until originals are restored.
            return
        }
    }
    else
    {
        GeneratorOpenProjectHash := Generator_ProjectFileHash(GeneratorOpenProjectSource)
        GeneratorOpenConfigHash := Generator_ProjectFileHash(GeneratorOpenProjectConfig)
        GeneratorOpenProjectFileHash := Generator_ProjectFileHash(GeneratorOpenProjectPath)
        if Generator_LoadExistingConfig(GeneratorOpenProjectConfig, GeneratorConfigSections, refreshedConfig, refreshedDisk, refreshedError)
        {
            GeneratorConfigSections := refreshedConfig
            GeneratorOpenConfigDisk := refreshedDisk
            Generator_RecordConfigBaseline()
        }
        MsgBox, 64, LLARS Save Changes, Updated script and project saved successfully. Restart Selector if its displayed details changed.
    }
    FileDelete, %tmpAHK%
    FileDelete, %tmpINI%
    FileDelete, %tmpProject%
    FileDelete, %bakAHK%
    FileDelete, %bakINI%
    FileDelete, %bakProject%
}

Generator_UpdateCreatorRegistryOnEdit(folder, ByRef error)
{
    global GeneratorRoot, GeneratorOpenProjectRegister, GeneratorScriptName
    error := ""
    if !GeneratorOpenProjectRegister
        return true
    items := LLARS_CreatorRegistryRead(GeneratorRoot, error)
    if (error != "")
        return false
    target := Generator_CreateRegistryRecord(folder, GeneratorScriptName)
    found := false
    for index, record in items
    {
        if (record.RootDirectory = target.RootDirectory && record.RelativeDirectory = target.RelativeDirectory && record.FileName = target.FileName)
        {
            if found
            {
                error := "Duplicate Creator Selector records."
                return false
            }
            items[index] := target
            found := true
        }
    }
    if !found
    {
        error := "The registered Selector entry is missing; saved source cannot be confirmed against its metadata."
        return false
    }
    return LLARS_CreatorRegistryWrite(GeneratorRoot, items, error)
}

Generator_ShowBeginnerGuide()
{
    global GeneratorGuidePage, GeneratorGuideBody, GeneratorGuidePageLabel
    global GeneratorGuideBackButton, GeneratorGuideNextButton, GeneratorGuideCloseButton, GeneratorGuideTitle
    GeneratorGuidePage := 1
    Gui, Guide:Destroy
    Gui, Guide:New, +OwnDialogs +LabelGeneratorGuide
    Gui, Guide:Font, s12 Bold cBlack
    Gui, Guide:Add, Text, x20 y14 w660 h30 Center vGeneratorGuideTitle, % Generator_GuidePageHeading(1)
    Gui, Guide:Font, s10 Norm cBlack
    ; Static Text deliberately avoids the automatic selection of a focused Edit control.
    Gui, Guide:Add, Text, x24 y57 w652 h385 +Wrap vGeneratorGuideBody, % Generator_GuidePageText(1)
    Gui, Guide:Add, Text, x25 y445 w175 h20 vGeneratorGuidePageLabel, % "Page 1 of " . Generator_GuidePageCount()
    Gui, Guide:Font, s10 Bold cBlack
    Gui, Guide:Add, Button, x176 y467 w114 h34 vGeneratorGuideBackButton gGeneratorGuideBack Disabled, Previous
    Gui, Guide:Add, Button, x298 y467 w114 h34 vGeneratorGuideNextButton gGeneratorGuideNext, Next
    Gui, Guide:Add, Button, x420 y467 w114 h34 gGeneratorGuideClose Default vGeneratorGuideCloseButton, Close Guide
    Gui, Guide:Show, w700 h516, LLARS Script Builder Help
    GuiControl, Guide:Focus, GeneratorGuideNextButton
}

Generator_GuidePageCount()
{
    return 5
}

Generator_GuidePageHeading(page)
{
    if (page = 1)
        return "1 of 5 - Start with your first steps"
    if (page = 2)
        return "2 of 5 - Add and organize actions"
    if (page = 3)
        return "3 of 5 - Fill in Setup Values"
    if (page = 4)
        return "4 of 5 - Review and create"
    return "5 of 5 - Reopen and improve your script"
}

Generator_UpdateGuidePage()
{
    global GeneratorGuidePage
    GuiControl, Guide:Text, GeneratorGuideTitle, % Generator_GuidePageHeading(GeneratorGuidePage)
    GuiControl, Guide:Text, GeneratorGuideBody, % Generator_GuidePageText(GeneratorGuidePage)
    GuiControl, Guide:Text, GeneratorGuidePageLabel, % "Page " . GeneratorGuidePage . " of " . Generator_GuidePageCount()
    if (GeneratorGuidePage = 1)
        GuiControl, Guide:Disable, GeneratorGuideBackButton
    else
        GuiControl, Guide:Enable, GeneratorGuideBackButton
    if (GeneratorGuidePage = Generator_GuidePageCount())
        GuiControl, Guide:Disable, GeneratorGuideNextButton
    else
        GuiControl, Guide:Enable, GeneratorGuideNextButton
}

; You are already inside Guided Builder when this help is opened. Teach the
; next useful action, not the steps that were required to open this window.
; Keep each page small enough for static text at Windows DPI scaling.
Generator_GuidePageText(page)
{
    if (page = 1)
    {
        text := "You are already in Guided Builder. Nothing will click or type while you are building your script.`n`n"
        text .= "An example is the easiest start: close this guide and click Start From Example at the top of Build Actions. Choose Basic Repeating (or another example that fits your task).`n`n"
        text .= "The example fills in a starting list of steps. You can edit or remove them. You do not need to type any code.`n`n"
        text .= "Want to build from scratch instead? Skip the example and choose a Step type and Do this, then click Set Up This Step."
    }
    else if (page = 2)
    {
        text := "On Build Actions, pick a Step type (such as Mouse, Keyboard, or Timing). Choose Do this and read What this step does and When your script runs.`n`n"
        text .= "Click Set Up This Step. Answer the questions in the editor, then Save Step. For a key press, use Choose a Key from the List; for a click, choose a saved location.`n`n"
        text .= "Your numbered list shows execution order, top to bottom. Double-click a step to edit it. Use Move Up and Move Down to reorder it. Click Run Order to read exactly when each wait and key press happens.`n`n"
        text .= "Optional progress messages tell you what is happening; they do not perform the action themselves."
    }
    else if (page = 3)
    {
        text := "Some steps need values you set once and reuse: a mouse location, hotkey, color, or delay.`n`n"
        text .= "Click Review & Save, then Edit Setup Values. Fill in the named entries required by your steps. A click location may use a small area so LLARS can vary the exact click point.`n`n"
        text .= "Timing values are entered in seconds by default: 2 means 2 seconds. LLARS saves milliseconds in Config.ini automatically (2 seconds = 2000 ms). Read Run Order to see which action each wait delays.`n`n"
        text .= "Only adding banking? Use Add Banking Steps on Build Actions. It uses the banking method already selected when you started."
    }
    else if (page = 4)
    {
        text := "Open Review & Save. Read the result under Check your script for missing information.`n`n"
        text .= "If Errors are greater than zero, click Explain Issues. Fix the named step or Setup Value and check again. Warnings can be reviewed without blocking creation.`n`n"
        text .= "Enter your Script name at the bottom. Click Script Details to add a description and category.`n`n"
        text .= "Click Read Run Order to see the actual steps, including every delay in seconds and whether Space comes BEFORE or AFTER a wait.`n`nWhen there are no blocking errors, click Create My Script. Review the destination and confirm."
    }
    else
    {
        text := "A script made here can be edited later. Open Guided Builder and choose Open Saved Script. Select a script that has its saved Creator project record.`n`n"
        text .= "The steps and Setup Values will reappear. Make changes, review the errors again, and choose Save Changes.`n`n"
        text .= "The generated script and setup previews on Review & Save are for checking the output, not for typing code. Edit steps or Setup Values instead.`n`n"
        text .= "Hand-written scripts and scripts changed outside the Builder are protected from automatic rewriting."
    }
    return text
}

; The on-screen banking wording describes what users do; the internal values
; stay Normal/MES for script directories and runtime compatibility.
Generator_BankingLabel(family)
{
    return family = "MES" ? "Menu Entry Swapper (no preset)" : "Standard banking (Bank Preset)"
}

Generator_BankingModeFromLabel(label)
{
    return InStr(label, "Menu Entry Swapper") ? "MES" : "Normal"
}

Generator_ShowSequenceBuilder()
{
    global GeneratorActionCategory, GeneratorActionChoice, GeneratorSequenceAdvanced
    global GeneratorActionHelp, GeneratorActionOutcome, GeneratorSequenceList, GeneratorSequencePreview, GeneratorConfigPreview
    global GeneratorRuntimeEstimateSummary, GeneratorPreflightSummary, GeneratorPreflightDetails
    global GeneratorSequence, GeneratorSequenceHWND, GeneratorSequenceFamily, GeneratorSequenceOutputParent
    global GeneratorSequenceSaveProject, GeneratorProjectStatus, GeneratorSequenceBankingMethod, GeneratorSequenceCapabilitySummary
    global GeneratorSequenceScriptName, GeneratorScriptName, GeneratorSequencePage, GeneratorSequenceScriptNameHwnd, GeneratorSequenceCustomCode
    global GeneratorSequenceTabs, GeneratorSequenceEditButton, GeneratorSequenceDuplicateButton
    global GeneratorSequenceRemoveButton, GeneratorSequenceUpButton, GeneratorSequenceDownButton
    global GeneratorSequenceClearButton, GeneratorSequenceReviewButton, GeneratorSequenceRuntimeButton
    global GeneratorSequenceBackButton, GeneratorSequenceOpenButton, GeneratorSequenceCreateButton
    global GeneratorSequenceHelpNote, GeneratorSequenceCloseButton, GeneratorSequenceScriptNameLabel
    global GeneratorSequenceIdentityButton, GeneratorSequenceBankingNote, GeneratorSequenceSaveLabel
    global GeneratorSequenceFolderButton

    if !IsObject(GeneratorSequence)
        GeneratorSequence := []
    if (GeneratorSequenceHWND && WinExist("ahk_id " . GeneratorSequenceHWND))
    {
        WinShow, % "ahk_id " . GeneratorSequenceHWND
        WinActivate, % "ahk_id " . GeneratorSequenceHWND
        return
    }

    GeneratorSequenceBankingMethod := Generator_BankingLabel(GeneratorSequenceFamily)
    GeneratorSequenceScriptName := GeneratorScriptName
    Gui, Sequence:New, +OwnDialogs +Resize +MinSize1250x667 +HwndGeneratorSequenceHWND +LabelGeneratorSequence
    Gui, Sequence:Font, s13 Bold cBlack
    Gui, Sequence:Add, Text, x18 y9 w1214 h29 Center, LLARS Guided Script Builder
    Gui, Sequence:Font, s11 Norm cBlack
    Gui, Sequence:Add, Text, x22 y43 w404 h31, Choose banking type first. No bank? Use Standard.
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Text, x443 y50 w117 h25, Banking type
    Gui, Sequence:Add, DropDownList, x562 y42 w400 vGeneratorSequenceBankingMethod gGeneratorSequenceFamilyChanged, Standard banking (Bank Preset)|Menu Entry Swapper (no preset)
    GuiControl, Sequence:ChooseString, GeneratorSequenceBankingMethod, %GeneratorSequenceBankingMethod%
    Gui, Sequence:Font, s10 Bold cBlack
    Gui, Sequence:Add, Button, x988 y42 w242 h34 gGeneratorSequenceBeginnerHelp, Step-by-Step Help

    Gui, Sequence:Font, s11 Bold cBlack
    Gui, Sequence:Add, Tab2, x20 y79 w1210 h441 vGeneratorSequencePage gGeneratorSequencePageChanged, Build Actions|Review && Save
    Gui, Sequence:Tab, 1
    Gui, Sequence:Font, s11 Bold cBlack
    Gui, Sequence:Add, Button, x34 y116 w200 h33 gGeneratorSequenceStarterTemplates, Start From Example
    Gui, Sequence:Add, Button, x245 y116 w200 h33 gGeneratorSequenceBankingWorkflow, Add Banking Steps
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Text, x471 y119 w727 h27, Start with an example, or choose a step below. Then arrange your steps in order.
    Gui, Sequence:Font, s11 Bold cBlack
    Gui, Sequence:Add, Text, x34 y158 w1150 h25, 1. What would you like the script to do next?
    Gui, Sequence:Font, s11 Norm cBlack
    Gui, Sequence:Add, Text, x54 y186 w105 h26, Step type
    Gui, Sequence:Add, DropDownList, x165 y182 w232 vGeneratorActionCategory gGeneratorSequenceCategoryChanged
    Gui, Sequence:Add, Text, x416 y186 w65 h25, Do this
    Gui, Sequence:Add, DropDownList, x483 y182 w425 vGeneratorActionChoice gGeneratorSequenceActionChanged
    Gui, Sequence:Add, CheckBox, x929 y184 w267 h26 vGeneratorSequenceAdvanced gGeneratorSequenceAdvancedChanged, Show advanced choices
    Gui, Sequence:Font, s10 Bold cBlack
    Gui, Sequence:Add, Text, x54 y218 w740 h21, What this step does
    Gui, Sequence:Add, Text, x828 y218 w360 h21, When your script runs
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Edit, x54 y242 w753 h52 vGeneratorActionHelp ReadOnly +Wrap +VScroll, Choose a step to read what it does.
    Gui, Sequence:Add, Edit, x828 y242 w366 h52 vGeneratorActionOutcome ReadOnly +Wrap +VScroll, You are planning your script; nothing runs while you edit.
    Gui, Sequence:Font, s10 Bold cBlack
    Gui, Sequence:Add, Button, x54 y299 w173 h32 gGeneratorSequenceAddAction, Set Up This Step
    Gui, Sequence:Add, Button, x238 y299 w146 h32 gGeneratorSequenceAddFlow, Repeat / Decide
    Gui, Sequence:Add, Button, x394 y299 w174 h32 gGeneratorSequenceAddCustom vGeneratorSequenceCustomCode, Custom Code (Advanced)
    Gui, Sequence:Add, Button, x579 y299 w134 h32 gGeneratorCreatorHelpOpen, More Details
    Gui, Sequence:Font, s11 Bold cBlack
    Gui, Sequence:Add, Text, x34 y338 w1160 h26, 2. Arrange the steps in the order they will run (double-click one to edit it)
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, ListView, x34 y366 w1180 h106 vGeneratorSequenceList Grid -Multi gGeneratorSequenceListEvent, #|Action|Details
    Gui, Sequence:Font, s10 Bold cBlack
    Gui, Sequence:Add, Button, x34 y480 w142 h31 vGeneratorSequenceEditButton gGeneratorSequenceEdit, Edit Step
    Gui, Sequence:Add, Button, x184 y480 w142 h31 vGeneratorSequenceDuplicateButton gGeneratorSequenceDuplicate, Duplicate
    Gui, Sequence:Add, Button, x334 y480 w142 h31 vGeneratorSequenceRemoveButton gGeneratorSequenceDelete, Remove
    Gui, Sequence:Add, Button, x484 y480 w125 h31 vGeneratorSequenceUpButton gGeneratorSequenceMoveUp, Move Up
    Gui, Sequence:Add, Button, x617 y480 w125 h31 vGeneratorSequenceDownButton gGeneratorSequenceMoveDown, Move Down
    Gui, Sequence:Add, Button, x750 y480 w135 h31 vGeneratorSequenceClearButton gGeneratorSequenceClear, Remove All Steps
    Gui, Sequence:Add, Button, x893 y480 w101 h31 gGeneratorSequenceRunOrder, Run Order
    Gui, Sequence:Add, Button, x1003 y479 w211 h32 vGeneratorSequenceReviewButton gGeneratorSequenceReviewPage, Next: Check My Script

    GuiControl, Sequence:Hide, GeneratorSequenceCustomCode
    Gui, Sequence:Tab, 2
    Gui, Sequence:Font, s11 Bold cBlack
    Gui, Sequence:Add, Text, x34 y120 w1120 h25, 3. Setup values your script will need
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Text, x55 y151 w833 h47 +Wrap vGeneratorSequenceCapabilitySummary, This updates automatically as you add steps and configure their values.
    Gui, Sequence:Add, Button, x897 y153 w146 h33 gGeneratorSequenceConfigManager, Edit Setup Values
    Gui, Sequence:Add, Button, x1050 y153 w147 h33 gGeneratorSequenceSetupPreview, What Do I Need?
    Gui, Sequence:Font, s11 Bold cBlack
    Gui, Sequence:Add, Text, x34 y211 w1120 h25, 4. Check your script for missing information
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Text, x55 y243 w955 h25 vGeneratorPreflightSummary, This check updates as you change your steps.
    Gui, Sequence:Add, Button, x1048 y240 w149 h32 gGeneratorSequencePreflightDetails, Explain Issues
    Gui, Sequence:Add, Edit, x55 y275 w1140 h38 vGeneratorPreflightDetails ReadOnly +Wrap
    Gui, Sequence:Font, s11 Bold cBlack
    Gui, Sequence:Add, Text, x34 y324 w550 h24, Generated script (advanced preview)
    Gui, Sequence:Add, Text, x634 y324 w570 h24, Generated setup file (advanced preview)
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Edit, x34 y353 w568 h116 vGeneratorSequencePreview ReadOnly +Wrap
    Gui, Sequence:Add, Edit, x634 y353 w580 h116 vGeneratorConfigPreview ReadOnly +Wrap
    Gui, Sequence:Add, Text, x34 y475 w800 h24 vGeneratorRuntimeEstimateSummary, An estimated duration appears here when LLARS can calculate one.
    Gui, Sequence:Add, Button, x707 y475 w150 h30 gGeneratorSequenceRunOrder, Read Run Order
    Gui, Sequence:Add, Button, x867 y475 w155 h30 vGeneratorSequenceRuntimeButton gGeneratorSequenceRuntimeDetails, Time Estimate
    Gui, Sequence:Add, Button, x1034 y475 w180 h30 vGeneratorSequenceBackButton gGeneratorSequenceBuildPage, Back to My Steps

    ; These always-visible controls remain outside the tabs, so opening/saving
    ; does not require hunting for controls on a different page.
    Gui, Sequence:Tab
    Gui, Sequence:Font, s10 Bold cBlack
    Gui, Sequence:Add, Button, x20 y529 w174 h34 vGeneratorSequenceOpenButton gGeneratorSequenceOpenProject, Open Saved Script
    Gui, Sequence:Add, Button, x205 y529 w158 h34 gGeneratorSequenceSaveProject vGeneratorSequenceSaveProject Disabled, Save Changes
    Gui, Sequence:Add, Button, x374 y529 w200 h34 vGeneratorSequenceCreateButton gGeneratorSequenceCreate, Create My Script
    Gui, Sequence:Add, Text, x598 y534 w452 h25 vGeneratorSequenceHelpNote, Need help? The Step-by-Step Help button explains the process.
    Gui, Sequence:Add, Button, x1122 y529 w108 h34 vGeneratorSequenceCloseButton gGeneratorSequenceClose, Close

    Gui, Sequence:Font, s11 Norm cBlack
    Gui, Sequence:Add, Text, x22 y578 w107 h25 vGeneratorSequenceScriptNameLabel, Script name
    Gui, Sequence:Add, Edit, x130 y573 w262 h29 vGeneratorSequenceScriptName hwndGeneratorSequenceScriptNameHwnd gGeneratorSequenceScriptNameChanged, %GeneratorSequenceScriptName%
    Gui, Sequence:Add, Button, x402 y570 w130 h34 vGeneratorSequenceIdentityButton gGeneratorSequenceIdentity, Script Details
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Text, x552 y578 w675 h27 vGeneratorSequenceBankingNote, Banking type is selected at the top, before your steps.
    Gui, Sequence:Font, s11 Norm cBlack
    Gui, Sequence:Add, Text, x22 y614 w96 h25 vGeneratorSequenceSaveLabel, Save to
    Gui, Sequence:Add, Edit, x130 y609 w937 h28 vGeneratorSequenceOutputParent ReadOnly, %GeneratorSequenceOutputParent%
    Gui, Sequence:Add, Button, x1077 y608 w153 h32 vGeneratorSequenceFolderButton gGeneratorSequenceFamilyBrowse, Choose Folder
    Gui, Sequence:Font, s10 Norm cBlack
    Gui, Sequence:Add, Text, x22 y643 w1208 h21 vGeneratorProjectStatus, New script: choose Start From Example, or add your first step above.

    if (GeneratorOpenProjectPath != "")
    {
        GuiControl, Sequence:Disable, GeneratorSequenceBankingMethod
        GuiControl, Sequence:Disable, GeneratorSequenceScriptName
        GuiControl, Sequence:Disable, GeneratorSequenceFamilyBrowse
        GuiControl, Sequence:Disable, GeneratorSequenceCreate
        GuiControl, Sequence:Enable, GeneratorSequenceSaveProject
        GuiControl, Sequence:, GeneratorProjectStatus, % "Editing: " . GeneratorScriptName
    }
    Generator_RefreshActionLibrary(false)
    Generator_ReconcileConfigRequirements(false)
    Generator_RefreshSequence()
    ; A taller starting window shows more actions; maximize it to reveal the
    ; entire sequence without shrinking the action explanations.
    Gui, Sequence:Show, w1250 h700, LLARS Guided Script Builder
    GuiControl, Sequence:Focus, GeneratorSequenceScriptName
    ; Focus the name, with no text highlighted and the caret at the end.
    SendMessage, 0xB1, -1, -1,, % "ahk_id " . GeneratorSequenceScriptNameHwnd
}

; Size changes are confined to the step list / review previews and controls
; below them. Every baseline bound remains inside the 667px minimum client.
Generator_ResizeBuilder(height)
{
    extra := height - 667
    if (extra < 0)
        extra := 0
    GuiControl, Sequence:Move, GeneratorSequencePage, % "h" . (441 + extra)
    GuiControl, Sequence:Move, GeneratorSequenceList, % "h" . (106 + extra)
    GuiControl, Sequence:Move, GeneratorSequencePreview, % "h" . (116 + extra)
    GuiControl, Sequence:Move, GeneratorConfigPreview, % "h" . (116 + extra)
    for control, y in {GeneratorSequenceEditButton:480, GeneratorSequenceDuplicateButton:480
        , GeneratorSequenceRemoveButton:480, GeneratorSequenceUpButton:480
        , GeneratorSequenceDownButton:480, GeneratorSequenceClearButton:480
        , GeneratorSequenceReviewButton:479, GeneratorRuntimeEstimateSummary:475
        , GeneratorSequenceRuntimeButton:475, GeneratorSequenceBackButton:475
        , GeneratorSequenceOpenButton:529, GeneratorSequenceSaveProject:529
        , GeneratorSequenceCreateButton:529, GeneratorSequenceHelpNote:534
        , GeneratorSequenceCloseButton:529, GeneratorSequenceScriptNameLabel:578
        , GeneratorSequenceScriptName:573, GeneratorSequenceIdentityButton:570
        , GeneratorSequenceBankingNote:578, GeneratorSequenceSaveLabel:614
        , GeneratorSequenceOutputParent:609, GeneratorSequenceFolderButton:608
        , GeneratorProjectStatus:643}
        GuiControl, Sequence:Move, %control%, % "y" . (y + extra)
}

; The starter picker consumes the catalog-defined patterns; no Creator API
; signatures or config types are independently maintained in this GUI.
Generator_SyncScriptNameToMain()
{
    global GeneratorSequenceHWND, GeneratorSyncingScriptName
    global GeneratorSequenceScriptName, GeneratorScriptName
    if !(GeneratorSequenceHWND && WinExist("ahk_id " . GeneratorSequenceHWND))
        return
    ; Synchronize only when the user leaves the active edit path. Avoid
    ; changing the focused control/caret or launching preflight from here.
    GuiControlGet, currentName, Sequence:, GeneratorSequenceScriptName
    GeneratorSequenceScriptName := currentName
    GeneratorScriptName := currentName
    GuiControlGet, mainName, 1:, GeneratorScriptName
    if (mainName != currentName)
    {
        GeneratorSyncingScriptName := true
        GuiControl, 1:, GeneratorScriptName, %currentName%
        GeneratorSyncingScriptName := false
    }
}

; The banking method is chosen before creating steps; editing a managed banking
; workflow uses the explicit conversion path, never a silent dropdown change.
Generator_ApplyUserBankingChoice(family)
{
    global GeneratorSequence, GeneratorSequenceFamily
    if (family = GeneratorSequenceFamily)
        return true
    for _, node in GeneratorSequence
    {
        if (IsObject(node) && node.HasKey("BankingWorkflow"))
        {
            Generator_RevertBankingChoice()
            MsgBox, 48, LLARS Banking Type, This script already contains banking steps. Use Add Banking Steps, then Change Banking Method, to convert those steps safely.
            return false
        }
    }
    if !Generator_SetSequenceFamily(family)
    {
        Generator_RevertBankingChoice()
        return false
    }
    return true
}

Generator_RevertBankingChoice()
{
    global GeneratorSequenceFamily
    label := Generator_BankingLabel(GeneratorSequenceFamily)
    GuiControl, Sequence:ChooseString, GeneratorSequenceBankingMethod, %label%
    GuiControl, 1:ChooseString, GeneratorMainBankingMethod, %label%
}

Generator_SetSequenceFamily(family)
{
    global GeneratorOpenProjectPath, GeneratorSequenceFamily, GeneratorSequenceFamilyParents, GeneratorSequenceOutputParent
    if (GeneratorOpenProjectPath != "" && family != GeneratorSequenceFamily)
    {
        GuiControl, Sequence:ChooseString, GeneratorSequenceBankingMethod, % Generator_BankingLabel(GeneratorSequenceFamily)
        MsgBox, 48, LLARS Guided Script Builder, The banking method cannot be changed while editing an existing script. Create a new script for the other method.
        return false
    }
	if (family != "Normal" && family != "MES")
		return false
	GeneratorSequenceFamily := family
	GeneratorSequenceOutputParent := GeneratorSequenceFamilyParents[family]
	GuiControl, Sequence:ChooseString, GeneratorSequenceBankingMethod, % Generator_BankingLabel(family)
	GuiControl, 1:ChooseString, GeneratorMainBankingMethod, % Generator_BankingLabel(family)
	GuiControl, Sequence:, GeneratorSequenceOutputParent, %GeneratorSequenceOutputParent%
	Generator_RefreshCreatorPreflight()
	return true
}

Generator_BrowseSequenceFamily()
{
	global GeneratorSequenceFamily, GeneratorSequenceFamilyParents, GeneratorSequenceOutputParent
	global GeneratorScriptsRoot, GeneratorMESRoot
	root := (GeneratorSequenceFamily = "MES") ? GeneratorMESRoot : GeneratorScriptsRoot
	FileSelectFolder, chosen, *%GeneratorSequenceOutputParent%, 3, Select an output folder within the selected script family
	if (ErrorLevel || chosen = "")
		return
	if !Generator_IsInsideRoot(chosen, root)
	{
		MsgBox, 48, LLARS Sequence Builder, Choose a folder inside the selected script family; Normal and MES output must remain separate.
		return
	}
	GeneratorSequenceOutputParent := RTrim(chosen, "\")
	GeneratorSequenceFamilyParents[GeneratorSequenceFamily] := GeneratorSequenceOutputParent
	GuiControl, Sequence:, GeneratorSequenceOutputParent, %GeneratorSequenceOutputParent%
	Generator_RefreshCreatorPreflight()
}

; Banking steps reuse the existing catalog starter sequences, never a separate
; implementation of LLARS_Click/LLARS_PressHotkey parameter contracts.
Generator_BuildBankingSequence(mode, ByRef error)
{
	error := ""
	if (mode != "Normal" && mode != "MES")
	{
		error := "Unknown banking method."
		return ""
	}
	targetId := mode = "Normal" ? "normal_bank" : "mes_bank"
	for _, candidate in LLARS_CreatorStarterTemplates()
	{
		if (candidate.Id != targetId)
			continue
		whole := Generator_BuildStarterSequence(candidate, error)
		if !IsObject(whole)
			return ""
		result := []
		length := (mode = "Normal" ? 6 : 3)
		Loop, %length%
		{
			node := whole[A_Index]
			node.BankingWorkflow := mode
			node.BankingStep := A_Index
			result.Push(node)
		}
		return result
	}
	error := "Banking starter pattern is missing."
	return ""
}

; Starter projects can be safely converted only while their banking prefix is
; still the unmodified catalog pattern. User-edited steps are never rewritten.
Generator_TagBankingPrefix(ByRef sequence, mode)
{
	limit := mode = "Normal" ? 6 : 3
	Loop, %limit%
	{
		sequence[A_Index].BankingWorkflow := mode
		sequence[A_Index].BankingStep := A_Index
	}
}

Generator_BankingWorkflowRange(ByRef mode, ByRef startIndex, ByRef count)
{
	global GeneratorSequence
	mode := "", startIndex := 0, count := 0
	for index, node in GeneratorSequence
	{
		if !IsObject(node) || !node.HasKey("BankingWorkflow")
			continue
		if (node.BankingStep != 1 || startIndex)
			return false
		mode := node.BankingWorkflow
		startIndex := index
		count := mode = "Normal" ? 6 : (mode = "MES" ? 3 : 0)
		if !count || (index + count - 1 > GeneratorSequence.Length())
			return false
		Loop, %count%
		{
			item := GeneratorSequence[index + A_Index - 1]
			if !IsObject(item) || !item.HasKey("BankingWorkflow") || (item.BankingWorkflow != mode) || (item.BankingStep != A_Index)
				return false
		}
		for checkIndex, extra in GeneratorSequence
			if ((checkIndex < index || checkIndex >= index + count) && IsObject(extra) && extra.HasKey("BankingWorkflow"))
				return false
		return true
	}
	return false
}

Generator_BankingIsUnmodified(mode, startIndex, count)
{
	global GeneratorSequence
	reference := Generator_BuildBankingSequence(mode, error)
	if !IsObject(reference) || reference.Length() != count
		return false
	Loop, %count%
	{
		a := GeneratorSequence[startIndex + A_Index - 1], b := reference[A_Index]
		if (a.Kind != b.Kind || a.Function != b.Function || a.Negate != b.Negate)
			return false
		for key, value in b.Values
			if !a.Values.HasKey(key) || (a.Values[key] != value)
				return false
        for key, value in a.Values
            if !b.Values.HasKey(key)
                return false
        for _, property in ["ShowProgress", "ProgressStatus", "ProgressActivity"]
        {
            if (a.HasKey(property) != b.HasKey(property))
                return false
            if (a.HasKey(property) && a[property] != b[property])
                return false
        }
    }
    return true
}

Generator_ShowBankingWorkflow()
{
	global GeneratorBankingPreview
	global GeneratorBankingHWND, GeneratorBankingChoice, GeneratorSequenceFamily, GeneratorBankingConvertButton
	if (GeneratorBankingHWND && WinExist("ahk_id " . GeneratorBankingHWND))
	{
		WinActivate, % "ahk_id " . GeneratorBankingHWND
		return
	}
	GeneratorBankingChoice := GeneratorSequenceFamily = "MES" ? "Menu Entry Swapper" : "Standard (Bank Preset)"
	Gui, Banking:New, +OwnDialogs +HwndGeneratorBankingHWND +LabelGeneratorBanking
	Gui, Banking:Font, s11 Bold cBlack
	Gui, Banking:Add, Text, x18 y15 w540 h24, Add Banking Steps
	Gui, Banking:Font, s10 Norm cBlack
    Gui, Banking:Add, Text, x18 y48 w535 h28, % "Banking type: " . Generator_BankingLabel(GeneratorSequenceFamily)
	Gui, Banking:Add, Edit, x18 y82 w540 h132 ReadOnly +Wrap vGeneratorBankingPreview
	Gui, Banking:Add, Button, x18 y234 w145 h32 gGeneratorBankingAdd, Add Bank Steps
	Gui, Banking:Add, Button, x174 y234 w169 h32 vGeneratorBankingConvertButton gGeneratorBankingConvert, Change Banking Method
	Gui, Banking:Add, Button, x355 y234 w110 h32 gGeneratorBankingCancel, Cancel
	Gui, Banking:Show, w576 h283, LLARS Add Banking Steps
    if !Generator_BankingWorkflowRange(existingMode, existingStart, existingCount)
        GuiControl, Banking:Disable, GeneratorBankingConvertButton
    Generator_UpdateBankingPreview()
}

Generator_UpdateBankingPreview()
{
	global GeneratorBankingChoice
	isMes := (GeneratorBankingChoice = "Menu Entry Swapper")
	text := isMes ? "Menu Entry Swapper: open bank, wait briefly, then continue. No Bank Preset hotkey or config required." : "Standard banking: open bank, wait, press your configured Bank Preset hotkey, then wait for the preset."
	text .= "`r`n`r`nAdds editable banking steps that use the banking type selected before building."
    text .= "`r`n`r`nChange Banking Method converts only complete, unmodified banking steps. To switch a brand-new script, use the choice at the top of the Builder."
	GuiControl, Banking:, GeneratorBankingPreview, %text%
}

; Isolate prospective edits so conversion failure never mutates the old config.
Generator_BankingCopySections(sections)
{
	copy := {}
	for key, source in sections
	{
		section := {}
		for name, val in source
		{
			if (name = "Values" && IsObject(val))
			{
				values := {}
				for field, content in val
					values[field] := content
				section[name] := values
			}
			else
				section[name] := val
		}
		copy[key] := section
	}
	return copy
}

Generator_BankingFillMissingConfig()
{
	global GeneratorConfigSections
	requirements := Generator_DiscoverConfigRequirements()
	for key, req in requirements
	{
		if (req.Conflict != "" || GeneratorConfigSections.HasKey(key))
			continue
		section := Generator_CreateRequirementConfigSection(req, "generated")
		if IsObject(section)
			GeneratorConfigSections[key] := section
	}
	Generator_ReconcileConfigRequirements(false)
}

Generator_ApplyBankingWorkflow(convert := false)
{
	global GeneratorBankingChoice, GeneratorBankingHWND, GeneratorSequence
	global GeneratorConfigSections, GeneratorConfigRequirements, GeneratorSequenceFamily
	mode := GeneratorBankingChoice = "Menu Entry Swapper" ? "MES" : "Normal"
	steps := Generator_BuildBankingSequence(mode, error)
	if !IsObject(steps)
	{
		MsgBox, 16, LLARS Banking, %error%
		return
	}
	oldFamily := GeneratorSequenceFamily
	oldSequence := GeneratorSequence
	oldSections := GeneratorConfigSections
	oldRequirements := GeneratorConfigRequirements
	if (convert)
	{
		if !Generator_BankingWorkflowRange(currentMode, start, count) || !Generator_BankingIsUnmodified(currentMode, start, count)
		{
			MsgBox, 48, LLARS Banking, Only a complete, unmodified Generator-created banking workflow can be converted. Edited steps must be handled manually.
			return
		}
		if (currentMode = mode)
		{
			MsgBox, 64, LLARS Banking, This workflow already uses that banking method.
			return
		}
		MsgBox, 36, LLARS Banking, % "Convert the " . currentMode . " banking steps to " . mode . "?`n`nUnused Generator-owned Bank Preset and Preset Wait configuration will be removed if converting to MES. Other actions are preserved."
		IfMsgBox, No
			return
		updated := []
		for index, node in GeneratorSequence
		{
			if (index = start)
				for _, step in steps
					updated.Push(step)
			if (index < start || index >= start + count)
				updated.Push(node)
		}
	}
	else
	{
		for _, node in GeneratorSequence
			if IsObject(node) && node.HasKey("BankingWorkflow")
			{
				MsgBox, 48, LLARS Banking, A managed banking workflow already exists. Use Convert Workflow rather than adding another one.
				return
			}
		MsgBox, 36, LLARS Banking, % "Append " . mode . " banking steps to this Sequence Builder project and select the corresponding output family?"
		IfMsgBox, No
			return
		updated := []
		for _, node in GeneratorSequence
			updated.Push(node)
		for _, step in steps
			updated.Push(step)
	}
	GeneratorSequence := updated
	GeneratorConfigSections := Generator_BankingCopySections(oldSections)
	Generator_SetSequenceFamily(mode)
	Generator_ReconcileConfigRequirements(false)
	Generator_BankingFillMissingConfig()
	if (convert && mode = "MES")
	{
		newRequirements := Generator_DiscoverConfigRequirements()
		for _, name in ["Bank Preset", "Preset Wait"]
		{
			key := Generator_NormalizeConfigName(name)
			if (!newRequirements.HasKey(key) && GeneratorConfigSections.HasKey(key) && !GeneratorConfigSections[key].ReadOnly)
				GeneratorConfigSections.Delete(key)
		}
		Generator_ReconcileConfigRequirements(false)
	}
	report := Generator_RunCreatorPreflight(false)
	if (report.Errors)
	{
		GeneratorSequence := oldSequence
		GeneratorConfigSections := oldSections
		GeneratorConfigRequirements := oldRequirements
		Generator_SetSequenceFamily(oldFamily)
		MsgBox, 48, LLARS Banking, % "Cannot apply workflow; original work preserved.`n`n" . Generator_PreflightFormat(report, 8)
		return
	}
	Generator_RefreshSequence()
	Gui, Banking:Destroy
	GeneratorBankingHWND := 0
}

Generator_ValidateBankingFamily(ByRef report)
{
	global GeneratorSequenceFamily, GeneratorSequence, GeneratorConfigSections
	if (GeneratorSequenceFamily != "Normal" && GeneratorSequenceFamily != "MES")
	{
		Generator_PreflightAdd(report, "Error", "BANK_FAMILY", "Choose Normal or MES family.")
		return
	}
	preset := false, presetStatus := false, managedMode := ""
	for _, node in GeneratorSequence
	{
		if !IsObject(node)
			continue
		if node.HasKey("BankingWorkflow")
		{
			if (managedMode != "" && managedMode != node.BankingWorkflow)
				Generator_PreflightAdd(report, "Error", "BANK_MIXED", "Conflicting managed Normal/MES banking steps.")
			managedMode := node.BankingWorkflow
		}
		if (node.Kind = "api" || node.Kind = "value") && IsObject(node.Values)
		{
			entry := LLARS_CreatorAPIGet(node.Function)
			if IsObject(entry)
			{
				if (entry.Category = "Keyboard" && node.Values.HasKey("section") && Generator_NormalizeConfigName(node.Values.section) = "bank preset")
				{
					for _, dep in entry.ConfigDependencies
						if (dep = "hotkey")
							preset := true
				}
				if (entry.Category = "Status" && node.Values.HasKey("status") && InStr(node.Values.status, "Loading preset"))
					presetStatus := true
			}
		}
	}
	if (managedMode != "")
	{
		if (GeneratorSequenceFamily != managedMode)
			Generator_PreflightAdd(report, "Error", "BANK_FAMILY", "Managed banking mode " . managedMode . " does not match selected " . GeneratorSequenceFamily . " output family.")
		if !Generator_BankingWorkflowRange(foundMode, bankStart, bankCount)
			Generator_PreflightAdd(report, "Error", "BANK_STRUCTURE", "Banking steps were separated or removed. The bank workflow must stay together. Load the banking example again, or restore the missing step before creating.")
		if (managedMode = "Normal" && !preset)
			Generator_PreflightAdd(report, "Error", "BANK_NORMAL_PRESET", "Normal banking requires the configured Bank Preset hotkey.")
	}
	if (GeneratorSequenceFamily = "MES")
	{
		if (preset || presetStatus)
			Generator_PreflightAdd(report, "Error", "BANK_MES_PRESET", "MES banking must not call Bank Preset or show Loading preset.")
		key := Generator_NormalizeConfigName("Bank Preset")
		if GeneratorConfigSections.HasKey(key)
			Generator_PreflightAdd(report, "Error", "BANK_MES_CONFIG", "MES projects must not contain a Bank Preset configuration section, including retained orphans.")
	}
}

Generator_ShowStarterTemplates()
{
	global GeneratorStarterChoice, GeneratorStarterPreview
	global GeneratorStarterCatalog, GeneratorStarterLookup, GeneratorStarterHWND
	if (GeneratorStarterHWND && WinExist("ahk_id " . GeneratorStarterHWND))
	{
		WinActivate, % "ahk_id " . GeneratorStarterHWND
		return
	}
	GeneratorStarterCatalog := LLARS_CreatorStarterTemplates()
	GeneratorStarterLookup := {}
	names := ""
	for index, entry in GeneratorStarterCatalog
	{
		GeneratorStarterLookup[entry.DisplayName] := index
		names .= (names = "" ? "" : "|") . entry.DisplayName
	}
	Gui, Starter:New, +OwnDialogs +HwndGeneratorStarterHWND +LabelGeneratorStarter
	Gui, Starter:Font, s12 Bold cBlack
	Gui, Starter:Add, Text, x20 y15 w660 h28 Center, Choose a Starting Example
	Gui, Starter:Font, s10 Norm cBlack
	Gui, Starter:Add, Text, x20 y51 w645 h52 +Wrap, Choose an example close to what you want to automate. You can change, reorder or remove every step after loading it.
	Gui, Starter:Add, DropDownList, x20 y112 w640 vGeneratorStarterChoice gGeneratorStarterChoiceChanged Choose1, %names%
	Gui, Starter:Add, Edit, x20 y151 w640 h280 vGeneratorStarterPreview ReadOnly +Wrap
	Gui, Starter:Add, Button, x180 y448 w155 h33 gGeneratorStarterLoad, Use This Example
	Gui, Starter:Add, Button, x360 y448 w155 h33 gGeneratorStarterCancel, Cancel
	Gui, Starter:Show, w680 h499, LLARS Starting Examples
	Gui, Starter:Submit, NoHide
	Generator_UpdateStarterPreview()
}

Generator_StarterCurrent()
{
	global GeneratorStarterLookup, GeneratorStarterCatalog, GeneratorStarterChoice
	if !GeneratorStarterLookup.HasKey(GeneratorStarterChoice)
		return ""
	index := GeneratorStarterLookup[GeneratorStarterChoice]
	return GeneratorStarterCatalog[index]
}

Generator_UpdateStarterPreview()
{
	template := Generator_StarterCurrent()
	if !IsObject(template)
		return
	text := template.DisplayName . "`r`nDifficulty: " . template.Difficulty . " | Banking: " . Generator_BankingLabel(template.BankingMode)
	text .= "`r`n`r`nBest for: " . template.BestFor . "`r`n" . template.Purpose
	text .= "`r`n`r`nSetup values this example uses: " . template.ExpectedConfigTypes
	text .= "`r`n`r`nStarting actions:`r`n"
	for index, spec in template.Steps
	{
		if (spec.Kind = "flow")
			label := Generator_FlowTypeLabel(spec.FlowType)
		else
		{
			entry := LLARS_CreatorAPIGet(spec.Function)
			label := IsObject(entry) ? entry.DisplayName : "Unrecognized action"
			if (spec.Kind = "condition")
				label := "If " . label
		}
		text .= index . ". " . label . "`r`n"
	}
	text .= "`r`n" . template.Notes
	text .= "`r`n`r`nNext: edit these steps, fill in any required Setup Values, then check Review & Save before running."
	GuiControl, Starter:, GeneratorStarterPreview, %text%
}

; Resolve the source-of-truth parameter schema for each starter action.
; Never accept an unknown/unsafe API or unknown parameter from template data.
Generator_BuildStarterSequence(template, ByRef error)
{
	error := ""
	sequence := []
	for index, spec in template.Steps
	{
		if (spec.Kind = "flow")
		{
			if (spec.FlowType != "repeat_n" && spec.FlowType != "repeat_forever" && spec.FlowType != "else" && spec.FlowType != "end_block" && spec.FlowType != "break" && spec.FlowType != "continue")
			{
				error := "Unknown flow in starter item " . index
				return ""
			}
			sequence.Push({Kind:"flow", FlowType:spec.FlowType, Count:spec.Count})
			continue
		}
		entry := LLARS_CreatorAPIGet(spec.Function)
		if !IsObject(entry) || !entry.GeneratorSafe || entry.Classification = "Framework Internal"
		{
			error := "Starter references an unsupported Creator API at item " . index
			return ""
		}
		mode := Generator_ActionMode(entry)
		if ((spec.Kind = "condition" && mode != "condition") || (spec.Kind = "api" && mode != "statement"))
		{
			error := "Starter action result mode does not match the Creator catalog at item " . index
			return ""
		}
		values := {}
		for _, param in entry.Parameters
		{
			value := spec.Values.HasKey(param.Name) ? spec.Values[param.Name] : Generator_SuggestParamValue(param)
			if ((param.Required && Trim(value) = "") || !Generator_ValidateParamValue(param, value, paramError))
			{
				error := "Invalid template parameter at item " . index . ": " . param.Name
				return ""
			}
			values[param.Name] := value
		}
		for key, _ in spec.Values
		{
			seen := false
			for _, param in entry.Parameters
				if (param.Name = key)
					seen := true
			if !seen
			{
				error := "Unknown starter parameter " . key . " at item " . index
				return ""
			}
		}
        node := {Kind:spec.Kind, Function:entry.Name, Values:values, Negate:false}
        ; Every input step gets a descriptive, editable progress message.
        ; Existing explicit Status steps are kept for familiar template behavior.
        if (entry.PreviewKind != "status" && spec.Kind != "flow")
        {
            node.ShowProgress := 1
            node.ProgressStatus := entry.Category = "Timing" ? "Waiting" : entry.DisplayName
            node.ProgressActivity := values.HasKey("section") ? values.section : (values.HasKey("keyName") ? values.keyName : "")
            ; Older starters already place some explicit Status steps. Do not
            ; immediately overwrite one with a second status on the next action.
            if (sequence.Length() > 0)
            {
                previous := sequence[sequence.Length()]
                if (previous.Kind = "api")
                {
                    previousEntry := LLARS_CreatorAPIGet(previous.Function)
                    if IsObject(previousEntry) && (previousEntry.PreviewKind = "status")
                        node.ShowProgress := 0
                }
            }
        }
        sequence.Push(node)
	}
	return sequence
}

Generator_LoadSelectedStarter()
{
	global GeneratorSequence, GeneratorConfigSections, GeneratorConfigRequirements
	global GeneratorStarterHWND, GeneratorConfigHWND, GeneratorSequenceFamily
	template := Generator_StarterCurrent()
	if !IsObject(template)
		return
	candidate := Generator_BuildStarterSequence(template, templateError)
	if !IsObject(candidate)
	{
		MsgBox, 16, LLARS Creator Templates, % "Cannot load this template: " . templateError
		return
	}
	if (GeneratorSequence.Length() > 0 || Generator_ConfigHasSections())
	{
		MsgBox, 36, LLARS Creator Templates, Replace the current Sequence Builder actions AND project-owned Config.ini sections with this starter template?`n`nChoose No to preserve your existing work.
		IfMsgBox, No
			return
	}
    if ((template.BankingMode = "Normal" || template.BankingMode = "MES") && template.BankingMode != GeneratorSequenceFamily)
    {
        label := Generator_BankingLabel(template.BankingMode)
        MsgBox, 36, LLARS Banking Type, % "This example uses " . label . ".`n`nSwitch your banking type to match it? No keeps your current script unchanged."
        IfMsgBox, No
            return
    }
    oldSequence := GeneratorSequence
    oldSections := GeneratorConfigSections
    oldRequirements := GeneratorConfigRequirements
    oldFamily := GeneratorSequenceFamily
    GeneratorSequence := candidate
	if (template.BankingMode = "Normal" || template.BankingMode = "MES")
	{
		Generator_TagBankingPrefix(GeneratorSequence, template.BankingMode)
		Generator_SetSequenceFamily(template.BankingMode)
	}
	GeneratorConfigSections := {}
	GeneratorConfigRequirements := {}
	requirements := Generator_DiscoverConfigRequirements()
	for key, req in requirements
	{
		if (req.Conflict != "")
			continue
		section := Generator_CreateRequirementConfigSection(req, "starter")
		if IsObject(section)
			GeneratorConfigSections[key] := section
	}
	Generator_ReconcileConfigRequirements(false)
	result := Generator_RunCreatorPreflight(false)
	if (result.Errors > 0)
	{
		GeneratorSequence := oldSequence
		GeneratorConfigSections := oldSections
		GeneratorConfigRequirements := oldRequirements
		Generator_SetSequenceFamily(oldFamily)
		MsgBox, 16, LLARS Creator Templates, % "This template failed Creator Preflight and was not loaded:`n`n" . Generator_PreflightFormat(result, 10)
		return
	}
	if (GeneratorConfigHWND && WinExist("ahk_id " . GeneratorConfigHWND))
		Generator_RefreshConfigManager()
	Generator_RefreshSequence()
	GuiControl, Sequence:Choose, GeneratorSequencePage, 1
	Gui, Starter:Destroy
	GeneratorStarterHWND := 0
	MsgBox, 64, LLARS Creator Templates, % template.DisplayName . " loaded. Double-click the actions to edit them. Use Setup Values to configure required settings, then Review & Save to check for errors."
}

Generator_RefreshActionLibrary(showAdvanced := false)
{
	global GeneratorActionCatalog, GeneratorActionLookup, GeneratorActionCategory, GeneratorActionChoice

	GeneratorActionCatalog := {}
	GeneratorActionLookup := {}
	categoryMap := {}
	actions := LLARS_CreatorAPIActions(showAdvanced)
	for _, entry in actions
	{
		GeneratorActionCatalog[entry.Name] := entry
		categoryMap[entry.Category] := true
	}

	categoryList := ""
	for category, _ in categoryMap
		categoryList .= (categoryList = "" ? "" : "|") . category
	Sort, categoryList, D|

	previousCategory := GeneratorActionCategory
	GuiControl, Sequence:, GeneratorActionCategory, % "|" . categoryList
	if (previousCategory != "" && categoryMap.HasKey(previousCategory))
		GuiControl, Sequence:ChooseString, GeneratorActionCategory, %previousCategory%
	else if categoryMap.HasKey("Mouse")
        GuiControl, Sequence:ChooseString, GeneratorActionCategory, Mouse
	else
		GuiControl, Sequence:Choose, GeneratorActionCategory, 1
	Gui, Sequence:Submit, NoHide
	Generator_RefreshActionChoices(GeneratorActionCategory)
}

Generator_RefreshActionChoices(category)
{
	global GeneratorActionCatalog, GeneratorActionLookup, GeneratorActionChoice

	displayList := ""
	for name, entry in GeneratorActionCatalog
	{
		if (entry.Category != category)
			continue
		GeneratorActionLookup[category . "|" . entry.DisplayName] := name
		displayList .= (displayList = "" ? "" : "|") . entry.DisplayName
	}
	Sort, displayList, D|
	previousAction := GeneratorActionChoice
	GuiControl, Sequence:, GeneratorActionChoice, % "|" . displayList
	if (GeneratorActionLookup.HasKey(category . "|" . previousAction))
		GuiControl, Sequence:ChooseString, GeneratorActionChoice, %previousAction%
	else if (category = "Status" && GeneratorActionLookup.HasKey("Status|Set Status"))
		GuiControl, Sequence:ChooseString, GeneratorActionChoice, Set Status
	else
		GuiControl, Sequence:Choose, GeneratorActionChoice, 1
	Gui, Sequence:Submit, NoHide
	Generator_UpdateActionHelp(category, GeneratorActionChoice)
}

Generator_UpdateActionHelp(category, displayName)
{
	global GeneratorActionLookup, GeneratorActionCatalog
	key := category . "|" . displayName
	if !GeneratorActionLookup.HasKey(key)
	{
		GuiControl, Sequence:, GeneratorActionHelp, Choose a step to see its explanation.
		GuiControl, Sequence:, GeneratorActionOutcome, Nothing runs while you are choosing steps.
		return
	}
	name := GeneratorActionLookup[key]
	entry := GeneratorActionCatalog[name]
    help := Generator_BeginnerActionPurpose(entry)
    if (entry.Purpose != "")
        help .= "`r`n`r`nMore detail: " . entry.Purpose
	if (IsObject(entry.ConfigDependencies) && entry.ConfigDependencies.Length())
	{
		dependencies := ""
		for _, dependency in entry.ConfigDependencies
			dependencies .= (dependencies = "" ? "" : ", ") . dependency
		help .= "`r`nSaved values needed: " . dependencies
	}
	GuiControl, Sequence:, GeneratorActionHelp, %help%
	outcome := Generator_ActionOutcomeText(entry)
	GuiControl, Sequence:, GeneratorActionOutcome, %outcome%
}

; Beginner-facing behavior comes from catalog properties, not a duplicate API list.
Generator_BeginnerActionPurpose(entry)
{
    if (entry.PreviewKind = "status")
        return "Shows what the script is currently doing. These words are displayed to you; they do not click or open anything."
    if (entry.Category = "Timing")
        return "Adds a pause between steps. You can adjust saved delays in Edit Setup Values."
    if (entry.PerformsInput)
        return "Performs a mouse or keyboard action. When you set up this step, you can also choose a progress message shown just before it runs."
    if (entry.Category = "Conditions")
        return "Checks something during the script. You can use the result to decide what steps happen next."
    if (entry.Category = "Status")
        return "Shows a message or records information. This does not make your character perform an action."
    return "Adds this action to your script. Open its editor to see which values it needs."
}

; A plain-language, read-only consequence preview. It does not run an action.
Generator_ActionOutcomeText(entry)
{
	if (entry.PreviewKind = "status")
		return "Sample status display (not live gameplay):`nActivity: Bank`nStatus: Working"
	if entry.PerformsInput
		return "Sends mouse/keyboard input when the script runs. No input is sent by this preview."
	if (entry.ReturnValue != "void")
		return "Checks a value when your script runs. For a yes/no check, add the steps to run when it matches and finish with End Block."
	if (entry.Category = "Status")
		return "Updates LLARS messages or diagnostics. It does not perform the described task."
	return "This happens when your script reaches the step. Nothing runs while you are editing."
}

; Read-only Creator API browser: data, examples and parameter help come from
; LLARS_CreatorAPICatalog, never from a second Generator-specific API table.
Generator_ShowCreatorHelp(selectedFunction := "")
{
	global GeneratorCreatorHelpList, GeneratorCreatorHelpDetails
    global GeneratorCreatorHelpHWND, GeneratorCreatorHelpSearch, GeneratorCreatorHelpAdvanced
    global GeneratorCreatorHelpTechnical, GeneratorCreatorHelpSelection
    if (GeneratorCreatorHelpHWND && WinExist("ahk_id " . GeneratorCreatorHelpHWND))
    {
        GeneratorCreatorHelpSelection := selectedFunction
        Generator_RefreshCreatorHelp()
        WinActivate, % "ahk_id " . GeneratorCreatorHelpHWND
        return
    }
    GeneratorCreatorHelpSelection := selectedFunction
    GeneratorCreatorHelpSearch := ""
    GeneratorCreatorHelpAdvanced := 0
    GeneratorCreatorHelpTechnical := 0
    if (selectedFunction != "")
    {
        entry := LLARS_CreatorAPIGet(selectedFunction)
        if IsObject(entry) && entry.Classification != "Creator Public"
            GeneratorCreatorHelpAdvanced := 1
    }
    Gui, APIHelp:New, +OwnDialogs +HwndGeneratorCreatorHelpHWND +LabelGeneratorCreatorHelp
    Gui, APIHelp:Font, s11 Bold cBlack
    Gui, APIHelp:Add, Text, x18 y12 w980 h26 Center, Detailed Action Reference
    Gui, APIHelp:Font, s10 Norm cBlack
    Gui, APIHelp:Add, Text, x18 y52 w62 h22, Search
    Gui, APIHelp:Add, Edit, x80 y48 w325 h25 vGeneratorCreatorHelpSearch gGeneratorCreatorHelpFilter
    Gui, APIHelp:Add, CheckBox, % "x421 y50 w215 h24 vGeneratorCreatorHelpAdvanced gGeneratorCreatorHelpFilter Checked" . GeneratorCreatorHelpAdvanced, Include advanced and legacy
    Gui, APIHelp:Add, CheckBox, x662 y50 w230 h24 vGeneratorCreatorHelpTechnical gGeneratorCreatorHelpFilter, Show technical signatures
    Gui, APIHelp:Add, ListView, x18 y90 w405 h485 vGeneratorCreatorHelpList Grid -Multi gGeneratorCreatorHelpSelected, Function|Category|Access
    Gui, APIHelp:Add, Edit, x438 y90 w567 h485 vGeneratorCreatorHelpDetails ReadOnly -Wrap HScroll
    Gui, APIHelp:Add, Text, x18 y588 w845 h35, Search purpose, name, category and parameter names. Advanced reference: some functions require manual code. The ordinary Builder offers only supported actions.
    Gui, APIHelp:Add, Button, x885 y585 w120 h30 gGeneratorCreatorHelpClose, Close
    Generator_RefreshCreatorHelp()
    Gui, APIHelp:Show, w1025 h632, LLARS Creator API Help
}

Generator_RefreshCreatorHelp()
{
    global GeneratorCreatorHelpSearch, GeneratorCreatorHelpAdvanced, GeneratorCreatorHelpSelection
    if !IsObject(LLARS_CreatorAPICatalog())
        return
    catalog := LLARS_CreatorAPICatalog(true)
    Gui, APIHelp:Default
    LV_Delete()
    search := Trim(GeneratorCreatorHelpSearch)
    selectedRow := 0
    for name, entry in catalog
    {
        if (!GeneratorCreatorHelpAdvanced && entry.Classification != "Creator Public")
            continue
        haystack := entry.Name . " " . entry.DisplayName . " " . entry.Purpose . " " . entry.Category
        for _, param in entry.Parameters
            haystack .= " " . param.Name . " " . param.Type
        if (search != "" && !InStr(haystack, search, false))
            continue
        access := entry.GeneratorSafe ? "Generator action" : "AHK reference only"
        if (entry.Classification = "Legacy Compatibility" || entry.Classification = "Deprecated")
            access := "Legacy reference"
        row := LV_Add("", name, entry.Category, access)
        if (name = GeneratorCreatorHelpSelection)
            selectedRow := row
    }
    LV_ModifyCol(1, 230)
    LV_ModifyCol(2, 90)
    LV_ModifyCol(3, 110)
    if (!selectedRow && LV_GetCount() > 0)
        selectedRow := 1
    if (selectedRow)
        LV_Modify(selectedRow, "Select Focus Vis")
    Generator_UpdateCreatorHelpSelection()
}

Generator_UpdateCreatorHelpSelection()
{
    global GeneratorCreatorHelpSelection, GeneratorCreatorHelpTechnical
    Gui, APIHelp:Default
    row := LV_GetNext(0, "F")
    if (!row)
        row := LV_GetNext()
    if (!row)
    {
        GeneratorCreatorHelpSelection := ""
        GuiControl, APIHelp:, GeneratorCreatorHelpDetails, No matching Creator APIs.
        return
    }
    LV_GetText(functionName, row, 1)
    GeneratorCreatorHelpSelection := functionName
    entry := LLARS_CreatorAPIGet(functionName)
    help := LLARS_CreatorHelpText(entry, GeneratorCreatorHelpTechnical)
    GuiControl, APIHelp:, GeneratorCreatorHelpDetails, %help%
}

Generator_ActionMode(entry)
{
	if (entry.ReturnValue = "boolean" && !entry.PerformsInput && !entry.Blocks)
		return "condition"
	if (entry.Category = "Conditions" && entry.ReturnValue != "void")
		return "value"
	return "statement"
}

; Explain catalog-provided parameter names and types in everyday language.
; This is display-only: generated call signatures and saved values are unchanged.
Generator_BeginnerFieldLabel(param)
{
    if (param.Name = "status")
        return "Status (what is happening)"
    if (param.Name = "activity")
        return "Activity (task or target)"
    name := RegExReplace(param.Name, "([a-z])([A-Z])", "$1 $2")
    if (SubStr(param.Type, 1, 7) = "config_")
    {
        if (param.Type = "config_coordinate")
            name := "Saved location name"
        else if (param.Type = "config_hotkey")
            name := "Saved hotkey name"
        else if (param.Type = "config_color")
            name := "Saved color name"
        else if (param.Type = "config_color_list")
            name := "Saved color names"
        else if (param.Type = "config_timing_range")
            name := "Saved delay name"
    }
    return name
}

; Based on AutoHotkey v1 KeyList. LLARS_PressKey safely sends ONE key.
; Mouse-click buttons belong to the Mouse action; Ctrl+key combinations use Press Hotkey.
Generator_KeyCategories()
{
    return "Letters (A-Z)|Numbers (0-9)|Everyday keys|Navigation|Function keys (F1-F24)|Number pad|Modifiers and locks|Media and browser|Other supported keys"
}

Generator_KeysForCategory(category, original := "")
{
    if (category = "Letters (A-Z)")
        return "A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z"
    if (category = "Numbers (0-9)")
        return "0|1|2|3|4|5|6|7|8|9"
    if (category = "Everyday keys")
        return "Space|Enter|Tab|Escape|Backspace|Delete|Insert|AppsKey|PrintScreen|Pause"
    if (category = "Navigation")
        return "Up|Down|Left|Right|Home|End|PgUp|PgDn"
    if (category = "Function keys (F1-F24)")
    {
        result := ""
        Loop, 24
            result .= (A_Index = 1 ? "" : "|") . "F" . A_Index
        return result
    }
    if (category = "Number pad")
        return "Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9|NumpadDot|NumpadDiv|NumpadMult|NumpadAdd|NumpadSub|NumpadEnter|NumpadIns|NumpadEnd|NumpadDown|NumpadPgDn|NumpadLeft|NumpadClear|NumpadRight|NumpadHome|NumpadUp|NumpadPgUp|NumpadDel"
    if (category = "Modifiers and locks")
        return "Shift|LShift|RShift|Ctrl|LCtrl|RCtrl|Alt|LAlt|RAlt|LWin|RWin|CapsLock|NumLock|ScrollLock"
    if (category = "Media and browser")
        return "Volume_Mute|Volume_Down|Volume_Up|Media_Next|Media_Prev|Media_Stop|Media_Play_Pause|Browser_Back|Browser_Forward|Browser_Refresh|Browser_Stop|Browser_Search|Browser_Favorites|Browser_Home|Launch_Mail|Launch_Media|Launch_App1|Launch_App2"
    ; Wheel keys are supported by LLARS_PressKey; direct clicks are deliberately not.
    result := "WheelUp|WheelDown|WheelLeft|WheelRight|CtrlBreak|Help|Sleep"
    if (original != "" && !InStr("|" . result . "|", "|" . original . "|"))
        result .= "|" . original
    return result
}

Generator_ActionKeyCategoryChanged()
{
    global GeneratorActionKeyCategory, GeneratorEditingKeyParamIndex, GeneratorEditingKeyOriginal
    if !GeneratorEditingKeyParamIndex
        return
    Gui, ActionEdit:Submit, NoHide
    keyField := "GeneratorActionParam" . GeneratorEditingKeyParamIndex
    choices := Generator_KeysForCategory(GeneratorActionKeyCategory, GeneratorEditingKeyOriginal)
    GuiControl, ActionEdit:, %keyField%, % "|" . choices
    GuiControl, ActionEdit:Choose, %keyField%, 1
}

; Accommodates unusual keys from AutoHotkey v1 KeyList without exposing syntax
; to everyone. AHK's own GetKeyVK/GetKeySC confirms recognized key names.
Generator_ActionCustomKey()
{
    global GeneratorEditingKeyParamIndex, GeneratorEditingKeyOriginal, GeneratorActionKeyCategory, GeneratorKeyPickerHWND
    InputBox, chosen, Other keyboard key, Enter one key name from AutoHotkey v1 KeyList (for example vkBA or sc029). No Ctrl+key combinations here.,, 510, 185
    if ErrorLevel
        return
    chosen := Trim(chosen)
    if (chosen = "" || RegExMatch(chosen, "[{}^!+#]"))
    {
        MsgBox, 48, LLARS Keyboard Step, Enter one valid key, not a combination or Send syntax. Use a saved Hotkey for combinations.
        return
    }
    if !(GetKeyVK(chosen) || GetKeySC(chosen))
    {
        MsgBox, 48, LLARS Keyboard Step, Windows/AutoHotkey does not recognize that key name. Check the AutoHotkey v1 key list.
        return
    }
    GeneratorEditingKeyOriginal := chosen
    keyField := "GeneratorActionParam" . GeneratorEditingKeyParamIndex
    GuiControl, ActionEdit:, %keyField%, %chosen%
    if (GeneratorKeyPickerHWND && WinExist("ahk_id " . GeneratorKeyPickerHWND))
    {
        Gui, KeyPick:Destroy
        GeneratorKeyPickerHWND := 0
    }
}

; One searchable, scrollable collection of the supported AHK v1 key names.
; A plain-language description is shown alongside each AHK token. The user
; never needs to type raw Send syntax in the everyday keyboard workflow.
Generator_KeyHumanName(key)
{
    names := {Space:"Space bar", Enter:"Enter / Return", Escape:"Escape (Esc)", Backspace:"Backspace", Tab:"Tab", Up:"Up arrow", Down:"Down arrow", Left:"Left arrow", Right:"Right arrow", PgUp:"Page Up", PgDn:"Page Down", CapsLock:"Caps Lock", NumpadEnter:"Number pad Enter", PrintScreen:"Print Screen", AppsKey:"Menu key", Volume_Mute:"Mute volume", Volume_Up:"Volume up", Volume_Down:"Volume down", Media_Play_Pause:"Play / pause media", Media_Next:"Next media track", Media_Prev:"Previous media track", Browser_Back:"Browser back", Browser_Forward:"Browser forward", WheelUp:"Scroll wheel up", WheelDown:"Scroll wheel down", WheelLeft:"Scroll wheel left", WheelRight:"Scroll wheel right"}
    return names.HasKey(key) ? names[key] : key
}

Generator_KeyLibrary()
{
    global GeneratorEditingKeyOriginal
    entries := []
    groups := ["Everyday keys", "Letters (A-Z)", "Numbers (0-9)", "Navigation", "Function keys (F1-F24)", "Number pad", "Modifiers and locks", "Media and browser", "Other supported keys"]
    seen := {}
    for _, group in groups
    {
        for _, key in StrSplit(Generator_KeysForCategory(group), "|")
        {
            if (key = "" || seen.HasKey(key))
                continue
            seen[key] := true
            entries.Push({Name:Generator_KeyHumanName(key), Group:group, Key:key})
        }
    }
    if (GeneratorEditingKeyOriginal != "" && !seen.HasKey(GeneratorEditingKeyOriginal))
        entries.Push({Name:"Saved custom key", Group:"Other supported keys", Key:GeneratorEditingKeyOriginal})
    return entries
}

Generator_ShowKeyPicker()
{
    global GeneratorKeyPickerHWND, GeneratorKeyPickerSearch, GeneratorKeyPickerCategory, GeneratorKeyPickerList, GeneratorKeyPickerAdvancedButton, GeneratorKeyPickerDeliveryHint
    global GeneratorEditingKeyParamIndex, GeneratorSequenceAdvanced
    if !GeneratorEditingKeyParamIndex
        return
    if (GeneratorKeyPickerHWND && WinExist("ahk_id " . GeneratorKeyPickerHWND))
    {
        WinActivate, % "ahk_id " . GeneratorKeyPickerHWND
        return
    }
    GeneratorKeyPickerSearch := ""
    GeneratorKeyPickerCategory := "All keys"
    Gui, KeyPick:New, +OwnDialogs +HwndGeneratorKeyPickerHWND +LabelGeneratorKeyPicker
    Gui, KeyPick:Font, s13 Bold cBlack
    Gui, KeyPick:Add, Text, x20 y14 w760 h28, Choose the keyboard key to press
    Gui, KeyPick:Font, s10 Norm cBlack
    Gui, KeyPick:Add, Text, x20 y49 w760 h45 +Wrap, Search by key name (for example Space, Enter, A, F5 or Volume). Double-click a result, or select one and choose Use This Key.
    Gui, KeyPick:Add, Text, x20 y103 w75 h25, Search keys
    Gui, KeyPick:Add, Edit, x100 y100 w356 h30 vGeneratorKeyPickerSearch gGeneratorKeyPickerFilterChanged
    Gui, KeyPick:Add, Text, x471 y103 w55 h25, Show
    Gui, KeyPick:Add, DropDownList, x528 y100 w250 vGeneratorKeyPickerCategory gGeneratorKeyPickerFilterChanged Choose1, All keys|Everyday keys|Letters (A-Z)|Numbers (0-9)|Navigation|Function keys (F1-F24)|Number pad|Modifiers and locks|Media and browser|Other supported keys
    Gui, KeyPick:Add, ListView, x20 y145 w758 h340 vGeneratorKeyPickerList gGeneratorKeyPickerListEvent Grid -Multi, Key to press|Group|AHK v1 key name
    Gui, KeyPick:Add, Text, x20 y495 w758 h38 +Wrap vGeneratorKeyPickerDeliveryHint, Select a key to check its generated command and scan-code compatibility. For combinations use Press Hotkey; for clicks use Mouse.
    Gui, KeyPick:Font, s10 Bold cBlack
    Gui, KeyPick:Add, Button, x20 y542 w190 h38 gGeneratorKeyPickerUse Default, Use This Key
    Gui, KeyPick:Add, Button, x226 y542 w195 h38 vGeneratorKeyPickerAdvancedButton gGeneratorKeyPickerAdvanced, Unusual Key (Advanced)
    Gui, KeyPick:Add, Button, x640 y542 w138 h38 gGeneratorKeyPickerCancel, Cancel
    Gui, KeyPick:Show, w800 h595, LLARS - Choose Keyboard Key
    if !GeneratorSequenceAdvanced
        GuiControl, KeyPick:Hide, GeneratorKeyPickerAdvancedButton
    Generator_RefreshKeyPicker()
}

Generator_RefreshKeyPicker()
{
    global GeneratorKeyPickerSearch, GeneratorKeyPickerCategory, GeneratorEditingKeyOriginal
    GuiControlGet, query, KeyPick:, GeneratorKeyPickerSearch
    GuiControlGet, group, KeyPick:, GeneratorKeyPickerCategory
    if (group = "")
        group := "All keys"
    Gui, KeyPick:Default
    LV_Delete()
    for _, item in Generator_KeyLibrary()
    {
        if (group != "All keys" && item.Group != group)
            continue
        if (query != "" && !InStr(item.Name, query, false) && !InStr(item.Group, query, false) && !InStr(item.Key, query, false))
            continue
        LV_Add("", item.Name, item.Group, item.Key)
    }
    LV_ModifyCol(1, 232)
    LV_ModifyCol(2, 270)
    LV_ModifyCol(3, 220)
    if (LV_GetCount() > 0)
        LV_Modify(1, "Select Focus Vis")
    Generator_UpdateKeyDeliveryHint()
}

; This is a transport-readiness check, not a synthetic press into a game.
; Keys without a scan code cannot use the AHI keyboard route.
Generator_UpdateKeyDeliveryHint()
{
    Gui, KeyPick:Default
    row := LV_GetNext(0)
    if !row
    {
        GuiControl, KeyPick:, GeneratorKeyPickerDeliveryHint, Select a key above. A Press Key step is sent only while the RuneScape input safety gate passes.
        return
    }
    LV_GetText(key, row, 3)
    command := "LLARS_PressKey(" . Chr(34) . key . Chr(34) . ")"
    if key in WheelUp,WheelDown,WheelLeft,WheelRight
        hint := command . " sends a mouse wheel event through the configured input route."
    else if (GetKeySC(key))
        hint := command . " sends {" . key . "}. AHI scan code available; real game delivery depends on the selected keyboard/device."
    else
        hint := command . " is known to AHK but has no AHI scan code. It may require Standard input mode; verify on Windows."
    GuiControl, KeyPick:, GeneratorKeyPickerDeliveryHint, %hint%
}

Generator_UseKeyPickerSelection()
{
    global GeneratorEditingKeyParamIndex, GeneratorEditingKeyOriginal, GeneratorKeyPickerHWND
    Gui, KeyPick:Default
    row := LV_GetNext(0)
    if !row
    {
        MsgBox, 48, LLARS Keyboard Step, Choose a key from the list first.
        return
    }
    LV_GetText(key, row, 3)
    if (key = "")
        return
    GeneratorEditingKeyOriginal := key
    field := "GeneratorActionParam" . GeneratorEditingKeyParamIndex
    GuiControl, ActionEdit:, %field%, %key%
    Gui, KeyPick:Destroy
    GeneratorKeyPickerHWND := 0
}

Generator_BeginnerFieldAdvice(param)
{
    if (param.Name = "status")
        return "Example: Banking or Waiting. This changes displayed text, not gameplay."
    if (param.Name = "activity")
        return "Example: Opening bank. Leave blank to show the script name."
    kind := param.Type
    if (kind = "config_coordinate")
        return "Type the name of a location in Setup Values, such as Bank. Create it there if missing."
    if (kind = "config_hotkey")
        return "Type the name of a saved key combination in Setup Values."
    if (kind = "config_color")
        return "Type the name of a color saved under Setup Values."
    if (kind = "config_color_list")
        return "Enter saved color names separated by commas. Create them in Setup Values."
    if (kind = "config_timing_range" || kind = "config_timer")
        return "Enter a saved delay name. A delay pauses RIGHT HERE, before the next action. Edit its minimum and maximum in seconds under Edit Setup Values; inspect Run Order before generating."
    if (kind = "config_section")
        return "Enter the name of a saved section from Setup Values."
    if (kind = "mouse_button")
        return "Choose Left, Right, or Middle from the menu. Left is the usual click."
    if (kind = "key_name")
        return "Click Choose a Key from the List. Search or browse A-Z, numbers, arrows, function keys, numpad and media keys. No key syntax required. Use a Hotkey action for combinations."
    if (kind = "boolean")
        return "Choose Yes or No. The Builder converts that choice automatically."
    if (kind = "scope")
        return "Use script for this script's values. Advanced: shared selects common LLARS values."
    if (kind = "integer")
        return "Enter a whole number such as 3 (no decimal point)."
    if (kind = "number" || kind = "number_or_blank")
        return "Enter a number, such as 5 or 0.5."
    if (kind = "string")
        return "Enter the words you want the script to use."
    return "Enter the value for this step. More Details explains advanced parameters."
}

Generator_ActionFieldGuide(entry)
{
    text := "Fill in the fields to tell LLARS exactly what to do. A * means required.`r`n"
    if (!entry.Parameters.Length())
        return "There are no fields to fill in. Save Step to add this action to your list."
    for _, param in entry.Parameters
    {
        text .= "`r`n" . Generator_BeginnerFieldLabel(param) . (param.Required ? " *" : " (optional)") . "`r`n"
        text .= Generator_BeginnerFieldAdvice(param) . "`r`n"
    }
    text .= "`r`nNeed a new saved value? Save the step, then open Edit Setup Values."
    return text
}

Generator_OpenActionEditor(editIndex, functionName)
{
	global GeneratorActionNegate, GeneratorActionResultVariable
	global GeneratorActionParam1, GeneratorActionParam2, GeneratorActionParam3, GeneratorActionParam4
	global GeneratorActionParam5, GeneratorActionParam6, GeneratorActionParam7, GeneratorActionParam8
	global GeneratorActionEditorHWND, GeneratorEditingIndex, GeneratorEditingFunction, GeneratorEditingMode
	global GeneratorEditingParameterCount, GeneratorSequence, GeneratorActionEditorStatusPreview
    global GeneratorActionKeyCategory, GeneratorEditingKeyParamIndex, GeneratorEditingKeyOriginal
    global GeneratorStepShowProgress, GeneratorStepProgressStatus, GeneratorStepProgressActivity, GeneratorStepPreview

	entry := LLARS_CreatorAPIGet(functionName)
	if !IsObject(entry) || !entry.GeneratorSafe
	{
		MsgBox, 16, LLARS Sequence Builder, The selected Creator action is not available to the Generator.
		return
	}
	if (entry.Parameters.Length() > 8)
	{
		MsgBox, 16, LLARS Sequence Builder, This Creator action has more parameters than the current action editor can safely display.
		return
	}

	GeneratorEditingIndex := editIndex
	GeneratorEditingFunction := functionName
	GeneratorEditingMode := Generator_ActionMode(entry)
	GeneratorEditingParameterCount := entry.Parameters.Length()
	oldNode := ""
	if (editIndex > 0 && IsObject(GeneratorSequence) && editIndex <= GeneratorSequence.Length())
		oldNode := GeneratorSequence[editIndex]

	Gui, ActionEdit:New, +OwnDialogs +HwndGeneratorActionEditorHWND +LabelGeneratorActionEditor
	Gui, ActionEdit:Font, s11 Bold cBlack
	Gui, ActionEdit:Add, Text, x15 y12 w845 h28 Center, % entry.DisplayName
	Gui, ActionEdit:Font, s10 Norm cBlack
	Gui, ActionEdit:Add, Text, x20 y47 w540 h65 +Wrap, % entry.Purpose

    GeneratorEditingKeyParamIndex := 0
    GeneratorEditingKeyOriginal := ""
    y := 115
    for index, param in entry.Parameters
	{
		label := Generator_BeginnerFieldLabel(param)
		if param.Required
			label .= " *"
		initial := Generator_SuggestParamValue(param)
		if IsObject(oldNode) && IsObject(oldNode.Values) && oldNode.Values.HasKey(param.Name)
			initial := oldNode.Values[param.Name]
		if (entry.PreviewKind = "status")
		{
			if (param.Name = "status")
				label := "Status * (what is happening)"
			else if (param.Name = "activity")
				label := "Activity (task or target)"
		}
        if (param.Type = "key_name")
        {
            GeneratorEditingKeyParamIndex := index
            GeneratorEditingKeyOriginal := initial
            label := "Key to press *"
        }
        Gui, ActionEdit:Add, Text, % "x20 y" . y . " w223 h34 +Wrap", %label%
        editOptions := "x246 y" . (y - 3) . " w314 h29 vGeneratorActionParam" . index
		if (entry.PreviewKind = "status")
			editOptions .= " gGeneratorActionEditorPreviewChanged"
        if (param.Type = "boolean")
        {
            ; A yes/no selector is clearer than asking beginners to type AHK booleans.
            displayValue := (initial = "true" || initial = "1") ? "Yes" : "No"
            Gui, ActionEdit:Add, DropDownList, %editOptions%, Yes|No
            GuiControl, ActionEdit:ChooseString, % "GeneratorActionParam" . index, %displayValue%
        }
        else if (param.Type = "mouse_button")
        {
            Gui, ActionEdit:Add, DropDownList, %editOptions%, Left|Right|Middle
            GuiControl, ActionEdit:ChooseString, % "GeneratorActionParam" . index, %initial%
        }
        else if (param.Type = "key_name")
        {
            ; Only the chosen key is shown here. The full scrollable AHK v1 list
            ; is in Choose a Key, rather than nested dropdowns with one item.
            Gui, ActionEdit:Add, Edit, %editOptions% ReadOnly, %initial%
            Gui, ActionEdit:Add, Button, % "x246 y" . (y + 32) . " w314 h34 gGeneratorActionChooseKey", Choose a Key from the List...
            y += 43
        }
        else
            Gui, ActionEdit:Add, Edit, %editOptions%, %initial%
        y += 39
	}

	if (GeneratorEditingMode = "condition")
	{
		negate := (IsObject(oldNode) && oldNode.HasKey("Negate") && oldNode.Negate) ? 1 : 0
		Gui, ActionEdit:Add, CheckBox, % "x20 y" . y . " w300 h24 vGeneratorActionNegate Checked" . negate, Run when NOT matched
		Gui, ActionEdit:Add, Text, % "x330 y" . y . " w230 h34", Finish the yes-steps with End Block; use Else for no-steps.
		y += 42
	}
	else if (GeneratorEditingMode = "value")
	{
		resultVar := (IsObject(oldNode) && oldNode.HasKey("ResultVariable")) ? oldNode.ResultVariable : "result"
		Gui, ActionEdit:Add, Text, % "x20 y" . y . " w180 h22", Advanced result name *
		Gui, ActionEdit:Add, Edit, % "x210 y" . (y - 3) . " w350 h25 vGeneratorActionResultVariable", %resultVar%
		y += 34
	}

    if (entry.PreviewKind != "status")
    {
        defaultShow := entry.PerformsInput ? 1 : 0
        if IsObject(oldNode) && oldNode.HasKey("ShowProgress")
            defaultShow := oldNode.ShowProgress ? 1 : 0
        defaultStatus := entry.DisplayName
        defaultActivity := ""
        if IsObject(oldNode) && oldNode.HasKey("ProgressStatus")
            defaultStatus := oldNode.ProgressStatus
        if IsObject(oldNode) && oldNode.HasKey("ProgressActivity")
            defaultActivity := oldNode.ProgressActivity
        Gui, ActionEdit:Font, s10 Bold cBlack
        Gui, ActionEdit:Add, Text, % "x20 y" . y . " w540 h25", Progress shown before this step (optional)
        y += 29
        Gui, ActionEdit:Font, s10 Norm cBlack
        Gui, ActionEdit:Add, CheckBox, % "x20 y" . y . " w540 h28 vGeneratorStepShowProgress gGeneratorActionEditorProgressChanged Checked" . defaultShow, Show a status message when this step runs
        y += 32
        Gui, ActionEdit:Add, Text, % "x20 y" . y . " w170 h25", What is happening?
        Gui, ActionEdit:Add, Edit, % "x195 y" . (y - 3) . " w365 h28 vGeneratorStepProgressStatus gGeneratorActionEditorProgressChanged", %defaultStatus%
        y += 35
        Gui, ActionEdit:Add, Text, % "x20 y" . y . " w170 h25", Task or target (optional)
        Gui, ActionEdit:Add, Edit, % "x195 y" . (y - 3) . " w365 h28 vGeneratorStepProgressActivity gGeneratorActionEditorProgressChanged", %defaultActivity%
        y += 40
        Gui, ActionEdit:Add, Edit, % "x20 y" . y . " w540 h47 vGeneratorStepPreview ReadOnly +Wrap -VScroll"
        y += 52
    }
    if (entry.PreviewKind = "status")
    {
        Gui, ActionEdit:Font, s10 Bold cBlack
		Gui, ActionEdit:Add, Text, % "x20 y" . y . " w540 h23", Status display preview (updates as you type)
		y += 24
		Gui, ActionEdit:Font, s10 Norm cBlack
		Gui, ActionEdit:Add, Edit, % "x20 y" . y . " w540 h88 vGeneratorActionEditorStatusPreview ReadOnly +Wrap -VScroll"
		y += 93
	}
	Gui, ActionEdit:Add, Edit, % "x20 y" . y . " w540 h47 ReadOnly +Wrap", Step saved as an editable action. No code is needed here.
	y += 53
	Gui, ActionEdit:Font, s10 Bold cBlack
	Gui, ActionEdit:Add, Button, % "x155 y" . y . " w120 h32 gGeneratorActionEditorSave", Save Step
	Gui, ActionEdit:Add, Button, % "x305 y" . y . " w120 h32 gGeneratorActionEditorCancel", Cancel
	Gui, ActionEdit:Add, Button, % "x435 y" . y . " w125 h32 gGeneratorActionEditorHelp", More Details
	y += 48
	Gui, ActionEdit:Font, s10 Bold cBlack
    Gui, ActionEdit:Add, Text, x585 y54 w270 h25, What should I enter?
    Gui, ActionEdit:Font, s10 Norm cBlack
    guide := Generator_ActionFieldGuide(entry)
    dialogHeight := y
    if (dialogHeight < 350)
        dialogHeight := 350
    guideHeight := dialogHeight - 116
    Gui, ActionEdit:Add, Edit, % "x585 y84 w275 h" . guideHeight . " ReadOnly +Wrap +VScroll", %guide%
    Gui, ActionEdit:Show, % "w880 h" . dialogHeight, LLARS - Edit Step
    if (entry.PreviewKind = "status")
        Generator_UpdateStatusEditorPreview()
    else
        Generator_UpdateStepProgressPreview()
}

Generator_UpdateStepProgressPreview()
{
    global GeneratorEditingFunction
    entry := LLARS_CreatorAPIGet(GeneratorEditingFunction)
    if !IsObject(entry) || (entry.PreviewKind = "status")
        return
    GuiControlGet, enabled, ActionEdit:, GeneratorStepShowProgress
    GuiControlGet, statusText, ActionEdit:, GeneratorStepProgressStatus
    GuiControlGet, activityText, ActionEdit:, GeneratorStepProgressActivity
    if (!enabled)
        description := "No progress message before this step. The action will still run normally."
    else
    {
        description := "When this action runs, LLARS will first display:`r`nStatus: " . (Trim(statusText) = "" ? "(enter a message)" : Trim(statusText))
        description .= "`r`nActivity: " . (Trim(activityText) = "" ? "(script name)" : Trim(activityText))
    }
    GuiControl, ActionEdit:, GeneratorStepPreview, %description%
}

; Shows what the standard LLARS status controls would display. This is a
; non-executing visualization; editing here never updates the running GUI.
Generator_UpdateStatusEditorPreview()
{
	global GeneratorEditingFunction
	entry := LLARS_CreatorAPIGet(GeneratorEditingFunction)
	if !IsObject(entry) || (entry.PreviewKind != "status")
		return
	GuiControlGet, statusText, ActionEdit:, GeneratorActionParam1
	GuiControlGet, activityText, ActionEdit:, GeneratorActionParam2
	statusText := Trim(statusText)
	activityText := Trim(activityText)
	if (statusText = "")
		statusText := "(enter a status)"
	if (activityText = "")
		activityText := "(script name, if left blank)"
	lowerStatus := statusText
	StringLower, lowerStatus, lowerStatus
	color := (lowerStatus = "error") ? "red" : "blue"
	preview := "Activity (" . color . "): " . activityText . "`r`nStatus (" . color . "): " . statusText
	preview .= "`r`n`r`nThese are labels, not commands. Typing Banking here does not open a bank."
	GuiControl, ActionEdit:, GeneratorActionEditorStatusPreview, %preview%
}

Generator_SaveActionEditor()
{
	global GeneratorEditingIndex, GeneratorEditingFunction, GeneratorEditingMode, GeneratorEditingParameterCount
	global GeneratorActionNegate, GeneratorActionResultVariable, GeneratorSequence, GeneratorActionEditorHWND
    global GeneratorStepShowProgress, GeneratorStepProgressStatus, GeneratorStepProgressActivity

    Gui, ActionEdit:Submit, NoHide
	entry := LLARS_CreatorAPIGet(GeneratorEditingFunction)
	if !IsObject(entry)
		return

	values := {}
	for index, param in entry.Parameters
	{
        value := Generator_GetActionParamValue(index)
        value := Trim(value)
        if (param.Type = "boolean")
            value := (value = "Yes") ? "true" : "false"
        if (param.Required && value = "")
		{
			MsgBox, 48, LLARS Action Editor, % param.Name . " is required."
			return
		}
		if !Generator_ValidateParamValue(param, value, paramError)
		{
			MsgBox, 48, LLARS Action Editor, %paramError%
			return
		}
		values[param.Name] := value
	}

	if (GeneratorEditingMode = "condition")
		node := {Kind:"condition", Function:GeneratorEditingFunction, Values:values, Negate:(GeneratorActionNegate ? true : false)}
	else if (GeneratorEditingMode = "value")
	{
		resultVariable := Trim(GeneratorActionResultVariable)
		if !RegExMatch(resultVariable, "^[A-Za-z_][A-Za-z0-9_]*$")
		{
			MsgBox, 48, LLARS Action Editor, Result variable must be a valid AutoHotkey variable name.
			return
		}
		node := {Kind:"value", Function:GeneratorEditingFunction, Values:values, ResultVariable:resultVariable}
	}
	else
		node := {Kind:"api", Function:GeneratorEditingFunction, Values:values}

    if (entry.PreviewKind != "status")
    {
        ; Status is per-action metadata, not a new LLARS runtime action format.
        node.ShowProgress := GeneratorStepShowProgress ? 1 : 0
        node.ProgressStatus := Trim(GeneratorStepProgressStatus)
        node.ProgressActivity := Trim(GeneratorStepProgressActivity)
        if (node.ShowProgress && node.ProgressStatus = "")
        {
            MsgBox, 48, LLARS Action Editor, Please enter the message to show before this step, or uncheck Show a status message.
            return
        }
    }

    if (GeneratorEditingIndex > 0 && GeneratorEditingIndex <= GeneratorSequence.Length())
    {
        ; Editing a bank coordinate, timing or progress label must not sever
        ; the existing managed workflow. Converting remains guarded separately
        ; by Generator_BankingIsUnmodified against the canonical starter.
        previous := GeneratorSequence[GeneratorEditingIndex]
        if (IsObject(previous) && previous.HasKey("BankingWorkflow"))
        {
            node.BankingWorkflow := previous.BankingWorkflow
            node.BankingStep := previous.BankingStep
        }
        GeneratorSequence[GeneratorEditingIndex] := node
    }
    else
        GeneratorSequence.Push(node)

	Gui, ActionEdit:Destroy
	GeneratorActionEditorHWND := 0
	Generator_ReconcileConfigRequirements(true)
	Generator_RefreshSequence(GeneratorEditingIndex > 0 ? GeneratorEditingIndex : GeneratorSequence.Length())
}

Generator_GetActionParamValue(index)
{
	global GeneratorActionParam1, GeneratorActionParam2, GeneratorActionParam3, GeneratorActionParam4
	global GeneratorActionParam5, GeneratorActionParam6, GeneratorActionParam7, GeneratorActionParam8
	if (index = 1)
		return GeneratorActionParam1
	if (index = 2)
		return GeneratorActionParam2
	if (index = 3)
		return GeneratorActionParam3
	if (index = 4)
		return GeneratorActionParam4
	if (index = 5)
		return GeneratorActionParam5
	if (index = 6)
		return GeneratorActionParam6
	if (index = 7)
		return GeneratorActionParam7
	if (index = 8)
		return GeneratorActionParam8
	return ""
}

; Every new Wait starts with its own setup section so editing one delay does
; not accidentally change the duration of unrelated steps. Existing projects
; and curated starter names are not renamed.
Generator_SuggestUniqueTimingName()
{
    global GeneratorSequence, GeneratorConfigSections
    Loop, 1000
    {
        candidate := "Wait Before Next Action " . A_Index
        key := Generator_NormalizeConfigName(candidate)
        if (IsObject(GeneratorConfigSections) && GeneratorConfigSections.HasKey(key))
            continue
        used := false
        if IsObject(GeneratorSequence)
        {
            for _, node in GeneratorSequence
            {
                if (!IsObject(node) || !node.HasKey("Values") || !IsObject(node.Values) || !node.Values.HasKey("section"))
                    continue
                if (Generator_NormalizeConfigName(node.Values.section) = key)
                {
                    used := true
                    break
                }
            }
        }
        if !used
            return candidate
    }
    return "Wait Before Next Action (rename me)"
}

Generator_SuggestParamValue(param)
{
	if (param.Default != "")
		return Generator_DefaultExpressionToValue(param.Default)
	if (param.Type = "config_coordinate")
		return "Example Coordinate"
	if (param.Type = "config_hotkey")
		return "Example Hotkey"
    if (param.Type = "config_timing_range")
        return Generator_SuggestUniqueTimingName()
	if (param.Type = "config_color")
		return "Target Color"
	if (param.Type = "config_color_list")
		return "Target Color"
	if (param.Type = "key_name")
		return "Space"
	return ""
}

Generator_DefaultExpressionToValue(expression)
{
	expression := Trim(expression)
	quote := Chr(34)
	if (StrLen(expression) >= 2 && SubStr(expression, 1, 1) = quote && SubStr(expression, 0) = quote)
	{
		value := SubStr(expression, 2, StrLen(expression) - 2)
		return StrReplace(value, quote . quote, quote)
	}
	return expression
}

Generator_ValidateParamValue(param, value, ByRef error)
{
	error := ""
	type := param.Type
	if (value = "" && !param.Required)
		return true
	if (type = "boolean")
	{
		lower := value
		StringLower, lower, lower
		if lower not in true,false
		{
			error := param.Name . " must be true or false."
			return false
		}
	}
    else if (type = "key_name")
    {
        if (RegExMatch(value, "[{}^!+#]"))
        {
            error := "Choose a single key, not a key combination or AHK Send expression. Use Press Hotkey for combinations."
            return false
        }
        if value in LButton,RButton,MButton,XButton1,XButton2
        {
            error := "Use the Mouse action for clicks, so LLARS can keep its click safety checks."
            return false
        }
        if (value = "" || InStr(value, "`n") || InStr(value, "`r"))
        {
            error := "Choose a valid key from the AutoHotkey v1 key list."
            return false
        }
        if value not in WheelUp,WheelDown,WheelLeft,WheelRight
        {
            if !(GetKeyVK(value) || GetKeySC(value))
            {
                error := "AutoHotkey does not recognize this single key. Choose one from the key picker."
                return false
            }
        }
    }
    else if (type = "mouse_button")
	{
		lower := value
		StringLower, lower, lower
		if lower not in left,right,middle
		{
			error := param.Name . " must be left, right, or middle."
			return false
		}
	}
	else if (type = "scope")
	{
		lower := value
		StringLower, lower, lower
		if lower not in script,shared,llars,root
		{
			error := param.Name . " must be script or a shared LLARS scope."
			return false
		}
	}
	else if (type = "integer")
	{
		if !RegExMatch(value, "^-?\d+$")
		{
			error := param.Name . " must be a whole number."
			return false
		}
	}
	else if (type = "number" || type = "number_or_blank")
	{
		if (value != "" && !RegExMatch(value, "^-?(?:\d+(?:\.\d+)?|\.\d+)$"))
		{
			error := param.Name . " must be numeric."
			return false
		}
	}
	else if (type = "config_color_list" || type = "string_list")
	{
		if (Trim(StrReplace(value, "|", ","), " ,") = "")
		{
			error := param.Name . " must contain at least one item."
			return false
		}
	}
	return true
}

Generator_OpenFlowEditor(editIndex)
{
	global GeneratorFlowCountLabel, GeneratorFlowExplanation
	global GeneratorFlowEditorHWND, GeneratorEditingFlowIndex, GeneratorSequence
	global GeneratorFlowType, GeneratorFlowCount

	GeneratorEditingFlowIndex := editIndex
	flowType := "Repeat N Times"
	flowCount := "3"
	if (editIndex > 0 && editIndex <= GeneratorSequence.Length())
	{
		node := GeneratorSequence[editIndex]
		flowType := Generator_FlowTypeLabel(node.FlowType)
		flowCount := node.HasKey("Count") ? node.Count : "3"
	}

	Gui, FlowEdit:New, +OwnDialogs +HwndGeneratorFlowEditorHWND +LabelGeneratorFlowEditor
	Gui, FlowEdit:Font, s11 Bold cBlack
	Gui, FlowEdit:Add, Text, x15 y12 w390 h28 Center, Repeat Steps or Make a Decision
	Gui, FlowEdit:Font, s10 Norm cBlack
	Gui, FlowEdit:Add, Text, x25 y58 w105 h22, Choose a rule
	Gui, FlowEdit:Add, DropDownList, x135 y54 w245 vGeneratorFlowType gGeneratorFlowTypeChanged, Repeat N Times|Repeat Forever|Else|End Block|Break|Continue
	Gui, FlowEdit:Add, Text, x25 y96 w105 h22 vGeneratorFlowCountLabel, How many times?
	Gui, FlowEdit:Add, Edit, x135 y92 w245 h25 vGeneratorFlowCount, %flowCount%
	Gui, FlowEdit:Add, Text, x25 y130 w355 h60 +Wrap vGeneratorFlowExplanation, Choose a rule to see where it belongs in your list of steps.
	Gui, FlowEdit:Font, s10 Bold cBlack
	Gui, FlowEdit:Add, Button, x82 y194 w110 h30 gGeneratorFlowEditorSave, Add Rule
	Gui, FlowEdit:Add, Button, x215 y194 w110 h30 gGeneratorFlowEditorCancel, Cancel
	GuiControl, FlowEdit:ChooseString, GeneratorFlowType, %flowType%
	Generator_UpdateFlowCountVisibility(flowType)
	Gui, FlowEdit:Show, w420 h240, LLARS Flow Control
}

Generator_UpdateFlowCountVisibility(flowType)
{
	if (flowType = "Repeat N Times")
	{
		GuiControl, FlowEdit:Show, GeneratorFlowCountLabel
		GuiControl, FlowEdit:Show, GeneratorFlowCount
	}
	else
	{
		GuiControl, FlowEdit:Hide, GeneratorFlowCountLabel
		GuiControl, FlowEdit:Hide, GeneratorFlowCount
	}
	hint := Generator_FlowPlainLanguage(flowType)
	GuiControl, FlowEdit:, GeneratorFlowExplanation, %hint%
}

Generator_FlowPlainLanguage(flowType)
{
	if (flowType = "Repeat N Times")
		return "Repeats the following steps exactly N times. Add End Block after the last repeated step."
	if (flowType = "Repeat Forever")
		return "Repeats following steps until the run stops. Include a delay and finish with End Block."
	if (flowType = "Else")
		return "Runs alternative steps when the preceding If condition is false. Place after an If branch."
	if (flowType = "End Block")
		return "Finishes a Repeat or If section. Each opened section needs one End Block."
	if (flowType = "Break")
		return "Exits the current Repeat loop immediately; only use inside a loop."
	if (flowType = "Continue")
		return "Skips the remaining steps in this Repeat iteration; only use inside a loop."
	return "Choose a flow step to see what it does."
}

Generator_SaveFlowEditor()
{
	global GeneratorFlowType, GeneratorFlowCount, GeneratorEditingFlowIndex, GeneratorSequence, GeneratorFlowEditorHWND
	Gui, FlowEdit:Submit, NoHide
	flowKey := Generator_FlowTypeKey(GeneratorFlowType)
	if (flowKey = "")
		return
	if (flowKey = "repeat_n")
	{
		count := Trim(GeneratorFlowCount)
		if !RegExMatch(count, "^\d+$") || count < 1
		{
			MsgBox, 48, LLARS Flow Control, Repeat count must be a whole number greater than zero.
			return
		}
		node := {Kind:"flow", FlowType:flowKey, Count:count}
	}
	else
		node := {Kind:"flow", FlowType:flowKey}

	if (GeneratorEditingFlowIndex > 0 && GeneratorEditingFlowIndex <= GeneratorSequence.Length())
		GeneratorSequence[GeneratorEditingFlowIndex] := node
	else
		GeneratorSequence.Push(node)

	Gui, FlowEdit:Destroy
	GeneratorFlowEditorHWND := 0
	Generator_RefreshSequence(GeneratorEditingFlowIndex > 0 ? GeneratorEditingFlowIndex : GeneratorSequence.Length())
}

Generator_FlowTypeKey(label)
{
	if (label = "Repeat N Times")
		return "repeat_n"
	if (label = "Repeat Forever")
		return "repeat_forever"
	if (label = "Else")
		return "else"
	if (label = "End Block")
		return "end_block"
	if (label = "Break")
		return "break"
	if (label = "Continue")
		return "continue"
	return ""
}

Generator_FlowTypeLabel(key)
{
	if (key = "repeat_n")
		return "Repeat N Times"
	if (key = "repeat_forever")
		return "Repeat Forever"
	if (key = "else")
		return "Else"
	if (key = "end_block")
		return "End Block"
	if (key = "break")
		return "Break"
	if (key = "continue")
		return "Continue"
	return key
}

Generator_OpenCustomEditor(editIndex)
{
	global GeneratorCustomEditorHWND, GeneratorEditingCustomIndex, GeneratorSequence, GeneratorCustomCode
	GeneratorEditingCustomIndex := editIndex
	code := ""
	if (editIndex > 0 && editIndex <= GeneratorSequence.Length())
		code := GeneratorSequence[editIndex].Code

	Gui, CustomEdit:New, +OwnDialogs +HwndGeneratorCustomEditorHWND +LabelGeneratorCustomEditor
	Gui, CustomEdit:Font, s11 Bold cBlack
	Gui, CustomEdit:Add, Text, x15 y12 w570 h28 Center, Custom AHK Block
	Gui, CustomEdit:Font, s10 Norm cBlack
	Gui, CustomEdit:Add, Text, x20 y48 w560 h42, Advanced escape hatch: this code is inserted verbatim. LLARS cannot fully validate arbitrary AutoHotkey, so review the generated preview before creating the script.
	Gui, CustomEdit:Add, Edit, x20 y96 w560 h280 vGeneratorCustomCode WantTab -Wrap, %code%
	Gui, CustomEdit:Font, s10 Bold cBlack
	Gui, CustomEdit:Add, Button, x172 y392 w110 h32 gGeneratorCustomEditorSave, Save
	Gui, CustomEdit:Add, Button, x312 y392 w110 h32 gGeneratorCustomEditorCancel, Cancel
	Gui, CustomEdit:Show, w600 h442, LLARS Custom AHK
}

Generator_SaveCustomEditor()
{
	global GeneratorCustomCode, GeneratorEditingCustomIndex, GeneratorSequence, GeneratorCustomEditorHWND
	Gui, CustomEdit:Submit, NoHide
	code := Trim(GeneratorCustomCode, " `t`r`n")
	if (code = "")
	{
		MsgBox, 48, LLARS Custom AHK, Enter AutoHotkey code or cancel this block.
		return
	}
	node := {Kind:"custom", Code:code}
	if (GeneratorEditingCustomIndex > 0 && GeneratorEditingCustomIndex <= GeneratorSequence.Length())
		GeneratorSequence[GeneratorEditingCustomIndex] := node
	else
		GeneratorSequence.Push(node)
	Gui, CustomEdit:Destroy
	GeneratorCustomEditorHWND := 0
	Generator_RefreshSequence(GeneratorEditingCustomIndex > 0 ? GeneratorEditingCustomIndex : GeneratorSequence.Length())
}

Generator_EditSelectedSequence()
{
	global GeneratorSequence
	Gui, Sequence:Default
	index := LV_GetNext()
	if !index
	{
		MsgBox, 48, LLARS Sequence Builder, Select a sequence item first.
		return
	}
	node := GeneratorSequence[index]
	if (node.Kind = "api" || node.Kind = "condition" || node.Kind = "value")
		Generator_OpenActionEditor(index, node.Function)
	else if (node.Kind = "flow")
		Generator_OpenFlowEditor(index)
	else if (node.Kind = "custom")
		Generator_OpenCustomEditor(index)
}

Generator_DeleteSelectedSequence()
{
	global GeneratorSequence
	Gui, Sequence:Default
	index := LV_GetNext()
	if !index
	{
		MsgBox, 48, LLARS Sequence Builder, Select a sequence item first.
		return
	}
    if (IsObject(GeneratorSequence[index]) && GeneratorSequence[index].HasKey("BankingWorkflow"))
    {
        MsgBox, 48, LLARS Banking Steps, This is part of a linked banking workflow. Edit its values instead of removing one banking step. To change the banking method, use Add Banking Steps then Change Banking Method.
        return
    }
    GeneratorSequence.RemoveAt(index)
    Generator_ReconcileConfigRequirements(true)
	newIndex := index
	if (newIndex > GeneratorSequence.Length())
		newIndex := GeneratorSequence.Length()
	Generator_RefreshSequence(newIndex)
}

Generator_DuplicateSelectedSequence()
{
	global GeneratorSequence
	Gui, Sequence:Default
	index := LV_GetNext()
	if !index
	{
		MsgBox, 48, LLARS Sequence Builder, Select a sequence item first.
		return
	}
    if (IsObject(GeneratorSequence[index]) && GeneratorSequence[index].HasKey("BankingWorkflow"))
    {
        MsgBox, 48, LLARS Banking Steps, Banking steps work together. Duplicate other actions outside the linked banking workflow instead.
        return
    }
    copy := Generator_CloneSequenceNode(GeneratorSequence[index])
    GeneratorSequence.InsertAt(index + 1, copy)
	Generator_RefreshSequence(index + 1)
}

Generator_CloneSequenceNode(node)
{
	copy := {}
	for key, value in node
	{
		if IsObject(value)
		{
			child := {}
			for childKey, childValue in value
				child[childKey] := childValue
			copy[key] := child
		}
		else
			copy[key] := value
	}
	return copy
}

Generator_MoveSelectedSequence(delta)
{
	global GeneratorSequence
	Gui, Sequence:Default
	index := LV_GetNext()
	if !index
	{
		MsgBox, 48, LLARS Sequence Builder, Select a sequence item first.
		return
	}
    target := index + delta
    if (target < 1 || target > GeneratorSequence.Length())
        return
    if ((IsObject(GeneratorSequence[index]) && GeneratorSequence[index].HasKey("BankingWorkflow"))
        || (IsObject(GeneratorSequence[target]) && GeneratorSequence[target].HasKey("BankingWorkflow")))
    {
        MsgBox, 48, LLARS Banking Steps, The banking steps must stay together. Edit their values in place, or add new actions before or after the banking group.
        return
    }
    temp := GeneratorSequence[index]
	GeneratorSequence[index] := GeneratorSequence[target]
	GeneratorSequence[target] := temp
	Generator_RefreshSequence(target)
}

Generator_RefreshSequence(selectIndex := 0)
{
	global GeneratorSequence
	Gui, Sequence:Default
	LV_Delete()
	for index, node in GeneratorSequence
	{
		Generator_SequenceRow(node, actionText, detailText)
		LV_Add("", index, actionText, detailText)
	}
	LV_ModifyCol(1, 48)
	LV_ModifyCol(2, 265)
	LV_ModifyCol(3, 855)
	if (selectIndex > 0 && selectIndex <= GeneratorSequence.Length())
		LV_Modify(selectIndex, "Select Focus Vis")
	Generator_UpdatePreview()
}

Generator_SequenceRow(node, ByRef actionText, ByRef detailText)
{
	actionText := ""
	detailText := ""
	if (node.Kind = "flow")
	{
		actionText := Generator_FlowTypeLabel(node.FlowType)
		if (node.FlowType = "repeat_n")
			detailText := node.Count . " times"
		return
	}
	if (node.Kind = "custom")
	{
		actionText := "Custom AHK"
		codeLines := StrSplit(node.Code, "`n", "`r")
		firstLine := codeLines.Length() ? codeLines[1] : ""
		detailText := StrLen(firstLine) > 54 ? SubStr(firstLine, 1, 51) . "..." : firstLine
		return
	}

	entry := LLARS_CreatorAPIGet(node.Function)
	if !IsObject(entry)
	{
		actionText := node.Function
		detailText := "Unknown Creator action"
		return
	}
	if (node.Kind = "condition")
		actionText := "If " . (node.Negate ? "NOT " : "") . entry.DisplayName
	else if (node.Kind = "value")
		actionText := entry.DisplayName . " -> " . node.ResultVariable
	else
		actionText := entry.DisplayName

	parts := []
	for _, param in entry.Parameters
	{
		if !node.Values.HasKey(param.Name)
			continue
		value := node.Values[param.Name]
		if (value = "" || param.Name = "scope")
			continue
		parts.Push(param.Name . "=" . value)
		if (parts.Length() >= 2)
			break
	}
    for index, part in parts
        detailText .= (index = 1 ? "" : ", ") . part
    if (entry.RuntimeTiming = "configured_section" && node.Values.HasKey("section"))
    {
        actionText := "Wait / Pause"
        detailText := Generator_TimingRangeLabel(node.Values.section) . " | Saved as [" . node.Values.section . "]"
    }
    if (node.HasKey("ShowProgress") && node.ShowProgress && node.HasKey("ProgressStatus"))
        detailText .= (detailText = "" ? "" : " | ") . "Shows: " . node.ProgressStatus
}

; Explain execution order without requiring users to read AHK code or
; guess whether a wait occurs before or after the next keypress.
; Human-facing seconds: show whole seconds when possible, otherwise the
; shortest decimal form up to hundredths (e.g. 2, 1.2, 1.25).
Generator_FormatTime(value)
{
    if (Abs(value + 0) < 0.005)
        return "0"
    formatted := Format("{:.2f}", value + 0)
    return RTrim(RTrim(formatted, "0"), ".")
}

; Config.ini values are stored in milliseconds. Keep the older conversion
; precision separate from the two-decimal display formatter.
Generator_FormatTimingStorage(value)
{
    rounded := Round(value + 0, 6)
    if (Abs(rounded) < 0.0000005)
        return "0"
    return RTrim(RTrim(Format("{:.6f}", rounded), "0"), ".")
}

Generator_TimingRangeLabel(name)
{
    global GeneratorConfigSections
    key := Generator_NormalizeConfigName(name)
    if !GeneratorConfigSections.HasKey(key)
        return "Timing NOT SET UP"
    section := GeneratorConfigSections[key]
    if (!IsObject(section.Values) || !section.Values.HasKey("min") || !section.Values.HasKey("max"))
        return "Timing NOT SET UP"
    minValue := section.Values.min, maxValue := section.Values.max
    if (!RegExMatch(minValue, "^-?(?:\d+(?:\.\d+)?|\.\d+)$") || !RegExMatch(maxValue, "^-?(?:\d+(?:\.\d+)?|\.\d+)$"))
        return "Timing NOT SET UP"
    lower := Generator_FormatTime(minValue / 1000)
    upper := Generator_FormatTime(maxValue / 1000)
    return lower . (lower = upper ? "" : " to " . upper) . " seconds"
}

Generator_IsConfiguredWait(node)
{
    if !IsObject(node) || !node.HasKey("Function")
        return false
    entry := LLARS_CreatorAPIGet(node.Function)
    return IsObject(entry) && entry.RuntimeTiming = "configured_section"
}

Generator_RunOrderActionLabel(node)
{
    global GeneratorConfigSections
    if !IsObject(node)
        return "End of run"
    if (node.Kind = "flow")
        return Generator_FlowTypeLabel(node.FlowType)
    if (node.Kind = "custom")
        return "Custom AHK action"
    entry := LLARS_CreatorAPIGet(node.Function)
    if !IsObject(entry)
        return node.Function
    if (entry.PreviewKind = "status")
        return "Show progress text (does NOT perform an action)"
    if (entry.RuntimeTiming = "configured_section")
        return "Wait " . Generator_TimingRangeLabel(node.Values.HasKey("section") ? node.Values.section : "")
    if (entry.Category = "Keyboard" && entry.PerformsInput)
    {
        for _, param in entry.Parameters
        {
            if (param.Type = "key_name")
                return "Press key " . (node.Values.HasKey(param.Name) ? node.Values[param.Name] : "(not set)")
            if (param.Type = "config_hotkey")
            {
                sectionName := node.Values.HasKey(param.Name) ? node.Values[param.Name] : "(not set)"
                key := Generator_NormalizeConfigName(sectionName)
                hotkey := ""
                if GeneratorConfigSections.HasKey(key)
                    hotkey := GeneratorConfigSections[key].Values.HasKey("hotkey") ? GeneratorConfigSections[key].Values.hotkey : ""
                return "Press saved hotkey [" . sectionName . "]" . (hotkey = "" ? " (key not set)" : " = " . hotkey)
            }
        }
    }
    if (entry.Category = "Mouse" && entry.PerformsInput && node.Values.HasKey("section"))
        return entry.DisplayName . " saved target [" . node.Values.section . "]"
    return entry.DisplayName
}

Generator_RunOrderNextAction(index)
{
    global GeneratorSequence
    for later, node in GeneratorSequence
    {
        if (later <= index)
            continue
        if (node.Kind = "api")
        {
            entry := LLARS_CreatorAPIGet(node.Function)
            if (IsObject(entry) && entry.PreviewKind = "status")
                continue
        }
        return Generator_RunOrderActionLabel(node)
    }
    return "End of this run"
}

Generator_RunOrderText()
{
    global GeneratorSequence, GeneratorConfigSections
    text := "READ BEFORE RUNNING: Each WAIT happens at its numbered position. The NEXT action does not start until that wait ends.`r`n"
    text .= "Timing is shown in seconds. The generated Config.ini uses milliseconds (1 second = 1000 ms).`r`n`r`n"
    if (!IsObject(GeneratorSequence) || !GeneratorSequence.Length())
        return text . "No actions added yet."
    for index, node in GeneratorSequence
    {
        label := Generator_RunOrderActionLabel(node)
        text .= index . ". " . label
        if (node.Kind = "api" && Generator_IsConfiguredWait(node))
        {
            name := node.Values.HasKey("section") ? node.Values.section : ""
            text .= " [" . name . "]`r`n"
            text .= "      THEN: " . Generator_RunOrderNextAction(index) . "`r`n"
            key := Generator_NormalizeConfigName(name)
            if (GeneratorConfigSections.HasKey(key))
            {
                section := GeneratorConfigSections[key]
                maxValue := section.Values.HasKey("max") ? section.Values.max : 0
                if (InStr(name, "short", false) && maxValue >= 5000)
                    text .= "      CHECK NAME: This is called 'short' but lasts up to " . Generator_FormatTime(maxValue/1000) . " seconds!`r`n"
            }
        }
        else
            text .= "`r`n"
    }
    text .= "`r`nTo change a wait, click Edit Setup Values, choose its saved name and Edit. The steps and Config.ini are saved separately so your custom values remain intact."
    return text
}

Generator_ShowRunOrder()
{
    explanation := Generator_RunOrderText()
    Gui, RunOrder:Destroy
    Gui, RunOrder:New, +OwnDialogs +Resize +MinSize700x420
    Gui, RunOrder:Font, s12 Bold cBlack
    Gui, RunOrder:Add, Text, x20 y15 w855 h30, Your Script - What Happens, in Order
    Gui, RunOrder:Font, s10 Norm cBlack
    Gui, RunOrder:Add, Edit, x20 y52 w855 h460 ReadOnly +Wrap +VScroll, %explanation%
    Gui, RunOrder:Add, Button, x380 y522 w135 h32 gGeneratorRunOrderClose, Close
    Gui, RunOrder:Show, w895 h567, LLARS - Run Order & Waits
}

Generator_UpdatePreview()
{
	global GeneratorSequence
	preview := Generator_BuildEditableBlock()
	if !Generator_ValidateSequenceStructure(structureError)
		preview := "; Generator warning: " . structureError . "`r`n`r`n" . preview
	else if !Generator_SequenceHasTiming()
		preview := "; Generator warning: RunCount output needs at least one Timing action.`r`n`r`n" . preview
	GuiControl, Sequence:, GeneratorSequencePreview, %preview%

	configPreview := Generator_BuildConfigPreview()
	if !Generator_ValidateConfigRequirements(configError)
		configPreview := "# Generator warning: " . configError . "`r`n`r`n" . configPreview
	GuiControl, Sequence:, GeneratorConfigPreview, %configPreview%
	Generator_RefreshSetupRequirements()
	Generator_RefreshCreatorPreflight()
	runtime := Generator_BuildRuntimeModel()
	GeneratorRuntimePreview := Generator_RuntimeDetails(runtime)
	GuiControl, Sequence:, GeneratorRuntimeEstimateSummary, % "RunCount estimate: " . (runtime.Emit ? "modeled metadata" : "partial - parser fallback")
}

Generator_BuildEditableBlock()
{
	global GeneratorSequence
	out := "Run(ctx)`r`n{`r`n"
	indent := 1
    for _, node in GeneratorSequence
    {
        ; Each action can explain its own progress immediately before execution.
        ; Older Creator Project.llars records without these properties still work.
        if (node.HasKey("ShowProgress") && node.ShowProgress && node.HasKey("ProgressStatus") && Trim(node.ProgressStatus) != "")
        {
            progressCall := Generator_BuildProgressCall(node)
            if (progressCall != "")
                out .= Generator_Indent(indent) . progressCall . "`r`n"
        }
        if (node.Kind = "api")
			out .= Generator_Indent(indent) . Generator_BuildApiCall(node) . "`r`n"
		else if (node.Kind = "value")
			out .= Generator_Indent(indent) . node.ResultVariable . " := " . Generator_BuildApiCall(node) . "`r`n"
		else if (node.Kind = "condition")
		{
			out .= Generator_Indent(indent) . "if " . (node.Negate ? "!" : "") . Generator_BuildApiCall(node) . "`r`n"
			out .= Generator_Indent(indent) . "{`r`n"
			indent += 1
		}
		else if (node.Kind = "flow")
		{
			if (node.FlowType = "repeat_n")
			{
				out .= Generator_Indent(indent) . "Loop, " . node.Count . "`r`n"
				out .= Generator_Indent(indent) . "{`r`n"
				indent += 1
			}
			else if (node.FlowType = "repeat_forever")
			{
				out .= Generator_Indent(indent) . "Loop`r`n"
				out .= Generator_Indent(indent) . "{`r`n"
				indent += 1
			}
			else if (node.FlowType = "else")
			{
				indent := indent > 1 ? indent - 1 : 1
				out .= Generator_Indent(indent) . "}`r`n"
				out .= Generator_Indent(indent) . "else`r`n"
				out .= Generator_Indent(indent) . "{`r`n"
				indent += 1
			}
			else if (node.FlowType = "end_block")
			{
				indent := indent > 1 ? indent - 1 : 1
				out .= Generator_Indent(indent) . "}`r`n"
			}
			else if (node.FlowType = "break" || node.FlowType = "continue")
				out .= Generator_Indent(indent) . node.FlowType . "`r`n"
		}
		else if (node.Kind = "custom")
		{
			customCode := node.Code
			Loop, Parse, customCode, `n, `r
				out .= Generator_Indent(indent) . A_LoopField . "`r`n"
		}
	}
	out .= "}`r`n"
	model := Generator_BuildRuntimeModel()
	if (model.Emit)
		out .= "`r`n" . Generator_GenerateRuntimeMetadata(model)
	return out
}

; Find the public Status action by its catalog semantics (not a second
; hard-coded API map) and generate it with the same argument encoder.
Generator_BuildProgressCall(node)
{
    for _, entry in LLARS_CreatorAPIActions()
    {
        if (entry.PreviewKind = "status" && entry.GeneratorSafe)
        {
            activity := node.HasKey("ProgressActivity") ? node.ProgressActivity : ""
            actionEntry := LLARS_CreatorAPIGet(node.Function)
            if (Trim(activity) = "" && IsObject(actionEntry) && actionEntry.Category = "Keyboard" && IsObject(node.Values) && node.Values.HasKey("keyName"))
                activity := node.Values.keyName
            return Generator_BuildApiCall({Function:entry.Name, Values:{status:node.ProgressStatus, activity:activity}})
        }
    }
    return ""
}

Generator_BuildApiCall(node)
{
	entry := LLARS_CreatorAPIGet(node.Function)
	if !IsObject(entry)
		return node.Function . "()"
	args := ""
	for index, param in entry.Parameters
	{
		value := node.Values.HasKey(param.Name) ? node.Values[param.Name] : Generator_SuggestParamValue(param)
		encoded := Generator_EncodeParamValue(param.Type, value)
		args .= (index = 1 ? "" : ", ") . encoded
	}
	return entry.Name . "(" . args . ")"
}

Generator_EncodeParamValue(type, value)
{
	value := Trim(value)
	if (type = "boolean")
	{
		StringLower, value, value
		return value
	}
	if (type = "integer" || type = "number")
		return value
	if (type = "number_or_blank")
		return value = "" ? Generator_QuoteAHK("") : value
	if (type = "config_color_list" || type = "string_list")
	{
		value := StrReplace(value, "|", ",")
		items := ""
		Loop, Parse, value, `,
		{
			item := Trim(A_LoopField)
			if (item = "")
				continue
			items .= (items = "" ? "" : ", ") . Generator_QuoteAHK(item)
		}
		return "[" . items . "]"
	}
	if (type = "any")
	{
		lower := value
		StringLower, lower, lower
		if lower in true,false
			return lower
		if RegExMatch(value, "^-?(?:\d+(?:\.\d+)?|\.\d+)$")
			return value
	}
	return Generator_QuoteAHK(value)
}

Generator_QuoteAHK(value)
{
	quote := Chr(34)
	value := StrReplace(value, quote, quote . quote)
	return quote . value . quote
}

Generator_Indent(level)
{
	out := ""
	Loop, %level%
		out .= "`t"
	return out
}

Generator_ValidateSequenceStructure(ByRef error)
{
	global GeneratorSequence
	error := ""
	if !IsObject(GeneratorSequence) || GeneratorSequence.Length() = 0
	{
		error := "Add at least one action."
		return false
	}

	stack := []
	for index, node in GeneratorSequence
	{
		if (node.Kind = "condition")
			stack.Push({Type:"if", Index:index})
		else if (node.Kind = "flow")
		{
			if (node.FlowType = "repeat_n" || node.FlowType = "repeat_forever")
				stack.Push({Type:"loop", Index:index})
			else if (node.FlowType = "else")
			{
				if (stack.Length() = 0 || stack[stack.Length()].Type != "if")
				{
					error := "Else at item " . index . " must follow an open condition block."
					return false
				}
				stack[stack.Length()].Type := "else"
			}
			else if (node.FlowType = "end_block")
			{
				if (stack.Length() = 0)
				{
					error := "End Block at item " . index . " has no open block."
					return false
				}
				stack.Pop()
			}
			else if (node.FlowType = "break" || node.FlowType = "continue")
			{
				insideLoop := false
				for _, opened in stack
				{
					if (opened.Type = "loop")
					{
						insideLoop := true
						break
					}
				}
				if !insideLoop
				{
					error := Generator_FlowTypeLabel(node.FlowType) . " at item " . index . " must be inside a repeat block."
					return false
				}
			}
		}
	}
	if (stack.Length() > 0)
	{
		error := "Add End Block for every open condition or repeat block."
		return false
	}
	return true
}

Generator_SequenceHasTiming()
{
	global GeneratorSequence
	timingActions := []
	for _, entry in LLARS_CreatorAPIActions(true)
	{
		if (entry.Category = "Timing")
			timingActions.Push(entry.Name)
	}

	for _, node in GeneratorSequence
	{
		if (node.Kind = "api")
		{
			entry := LLARS_CreatorAPIGet(node.Function)
			if IsObject(entry) && entry.Category = "Timing"
				return true
		}
		else if (node.Kind = "custom")
		{
			for _, functionName in timingActions
			{
				if InStr(node.Code, functionName . "(")
					return true
			}
		}
	}
	return false
}

; ================================================================
; |     AUTOMATIC CONFIG GENERATION     -     CONFIG GENERATION  |
; ================================================================
Generator_NormalizeConfigName(name)
{
	name := Trim(name)
	StringLower, name, name
	return name
}

Generator_IsScriptScope(node)
{
	if !IsObject(node) || !IsObject(node.Values) || !node.Values.HasKey("scope")
		return true
	scope := Trim(node.Values["scope"])
	if (scope = "")
		return true
	StringLower, scope, scope
	return (scope = "script")
}

Generator_ParseConfigList(value)
{
	items := []
	value := StrReplace(value, "|", ",")
	Loop, Parse, value, `,
	{
		item := Trim(A_LoopField)
		if (item != "")
			items.Push(item)
	}
	return items
}

Generator_DiscoverConfigRequirements()
{
	global GeneratorSequence, GeneratorConfigSections
	requirements := {}
	for index, node in GeneratorSequence
	{
		if (node.Kind != "api" && node.Kind != "condition" && node.Kind != "value")
			continue
		if !Generator_IsScriptScope(node)
			continue
		entry := LLARS_CreatorAPIGet(node.Function)
		if !IsObject(entry)
			continue

		for _, param in entry.Parameters
		{
			configType := LLARS_CreatorConfigTypeForParameter(param.Type)
			if (configType = "")
				continue
			value := node.Values.HasKey(param.Name) ? Trim(node.Values[param.Name]) : Trim(Generator_SuggestParamValue(param))
			if (value = "")
				continue

			if (param.Type = "config_color_list")
				names := Generator_ParseConfigList(value)
			else
				names := [value]

			for _, sectionName in names
			{
				key := Generator_NormalizeConfigName(sectionName)
				if (key = "")
					continue
				isGeneric := (param.Type = "config_section")
				expectedType := configType
				if (isGeneric)
				{
					if requirements.HasKey(key)
						expectedType := requirements[key].Type
					else if GeneratorConfigSections.HasKey(key)
						expectedType := GeneratorConfigSections[key].Type
				}

				if !requirements.HasKey(key)
					requirements[key] := {Name:sectionName, Type:expectedType, Generic:isGeneric, RefCount:0, References:"", Conflict:"", ClickCoordinate:false, PixelCoordinate:false}
				req := requirements[key]
				if (!isGeneric && req.Generic)
				{
					req.Type := expectedType
					req.Generic := false
				}
				else if (!isGeneric && !req.Generic && req.Type != expectedType)
					req.Conflict := req.Type . " vs " . expectedType
				if (expectedType = "coordinate")
                {
                    if (entry.PerformsInput)
                        req.ClickCoordinate := true
                    else
                        req.PixelCoordinate := true
                }
                req.RefCount += 1
                refText := index . ". " . entry.DisplayName . " / " . param.Name
				req.References .= (req.References = "" ? "" : "`n") . refText
				requirements[key] := req
			}
		}
	}
	return requirements
}

; A click target should default to an area (xmin/xmax/ymin/ymax) so
; the user can configure a safe randomized region. Pixel sampling needs a
; precise point (x/y). Existing saved sections retain their chosen mode.
Generator_CreateRequirementConfigSection(req, source := "generated")
{
    section := Generator_CreateDefaultConfigSection(req.Name, req.Type, source)
    if IsObject(section) && req.Type = "coordinate" && req.ClickCoordinate && !req.PixelCoordinate
    {
        definition := LLARS_CreatorConfigGet("coordinate", "Area")
        section.Mode := "Area"
        section.Values := {}
        for _, field in definition.Fields
            section.Values[field.Name] := field.Default
    }
    return section
}

Generator_CreateDefaultConfigSection(name, configType, source := "generated")
{
	definition := LLARS_CreatorConfigGet(configType)
	if !IsObject(definition)
		return ""
	values := {}
	for _, field in definition.Fields
		values[field.Name] := field.Default
	return {Name:name, Type:definition.Name, Mode:definition.DefaultMode, Values:values, Description:"", Source:source, ReadOnly:false, Required:false, Orphan:false, RawText:""}
}

Generator_ReconcileConfigRequirements(promptChanges := false)
{
	global GeneratorConfigSections, GeneratorConfigRequirements, GeneratorConfigHWND
	requirements := Generator_DiscoverConfigRequirements()
	wasRequired := {}
	for key, section in GeneratorConfigSections
	{
		wasRequired[key] := section.Required ? true : false
		section.Required := false
		GeneratorConfigSections[key] := section
	}

	missing := []
	for key, req in requirements
	{
		if (req.Conflict != "")
			continue
		if !GeneratorConfigSections.HasKey(key)
			missing.Push(key)
	}

	if (promptChanges && missing.Length() > 0)
	{
		message := "The sequence now references Config.ini sections that do not exist in this Generator project:`n`n"
		for _, key in missing
		{
			req := requirements[key]
			definition := LLARS_CreatorConfigGet(req.Type)
			displayType := IsObject(definition) ? definition.DisplayName : req.Type
			message .= req.Name . "  -  " . displayType . "`n"
		}
		message .= "`nCreate these required sections now?"
		MsgBox, 36, LLARS Config Generator, %message%
		IfMsgBox, Yes
		{
			for _, key in missing
			{
				req := requirements[key]
				section := Generator_CreateRequirementConfigSection(req, "generated")
				if IsObject(section)
					GeneratorConfigSections[key] := section
			}
		}
	}

	for key, req in requirements
	{
		if GeneratorConfigSections.HasKey(key)
		{
			section := GeneratorConfigSections[key]
			section.Required := true
			section.Orphan := false
			GeneratorConfigSections[key] := section
		}
	}

	orphanKeys := []
	for key, section in GeneratorConfigSections
	{
		if (wasRequired.HasKey(key) && wasRequired[key] && !section.Required && !section.ReadOnly)
		{
			section.Orphan := true
			GeneratorConfigSections[key] := section
			orphanKeys.Push(key)
		}
	}

	if (promptChanges && orphanKeys.Length() > 0)
	{
		message := "These Config.ini sections are no longer referenced by the generated sequence:`n`n"
		for _, key in orphanKeys
			message .= GeneratorConfigSections[key].Name . "`n"
		message .= "`nRemove them from the generated Config.ini? Choosing No keeps them as unreferenced sections."
		MsgBox, 36, LLARS Config Generator, %message%
		IfMsgBox, Yes
		{
			for _, key in orphanKeys
				GeneratorConfigSections.Delete(key)
		}
	}

	GeneratorConfigRequirements := requirements
	if (GeneratorConfigHWND && WinExist("ahk_id " . GeneratorConfigHWND))
		Generator_RefreshConfigManager()
}

Generator_CreateMissingConfigSections()
{
	global GeneratorConfigSections
	requirements := Generator_DiscoverConfigRequirements()
	created := 0
	for key, req in requirements
	{
		if (req.Conflict != "" || GeneratorConfigSections.HasKey(key))
			continue
		section := Generator_CreateRequirementConfigSection(req, "generated")
		if IsObject(section)
		{
			GeneratorConfigSections[key] := section
			created += 1
		}
	}
	Generator_ReconcileConfigRequirements(false)
	Generator_RefreshConfigManager()
	Generator_UpdatePreview()
	if (created = 0)
		MsgBox, 64, LLARS Config Generator, No missing generated Config.ini sections were found.
	else
		MsgBox, 64, LLARS Config Generator, %created% required Config.ini section(s) created.
}

Generator_ConfigDisplayType(configType)
{
	definition := LLARS_CreatorConfigGet(configType)
	if IsObject(definition)
		return definition.DisplayName
	if (configType = "other")
		return "Imported / Other"
	return configType
}

Generator_ShowConfigManager()
{
	global GeneratorConfigList
	global GeneratorConfigHWND
	if (GeneratorConfigHWND && WinExist("ahk_id " . GeneratorConfigHWND))
	{
		WinShow, % "ahk_id " . GeneratorConfigHWND
		WinActivate, % "ahk_id " . GeneratorConfigHWND
		return
	}

	Gui, ConfigMgr:New, +OwnDialogs +HwndGeneratorConfigHWND +LabelGeneratorConfig
	Gui, ConfigMgr:Font, s12 Bold cBlack
	Gui, ConfigMgr:Add, Text, x10 y10 w760 h28 Center, Setup Values for My Script
	Gui, ConfigMgr:Font, s10 Norm cBlack
	Gui, ConfigMgr:Add, Text, x20 y46 w740 h42, Edit saved locations, keys and waits here. Enter wait times in SECONDS (for example 2 = 2 seconds); Config.ini stores milliseconds automatically. Imported extra sections stay read-only.
	Gui, ConfigMgr:Add, ListView, x20 y96 w740 h310 vGeneratorConfigList Grid -Multi, Section|Type|Source|State|References
	Gui, ConfigMgr:Add, Button, x20 y422 w105 h30 gGeneratorConfigAdd, Add Value
	Gui, ConfigMgr:Add, Button, x135 y422 w80 h30 gGeneratorConfigEdit, Edit
	Gui, ConfigMgr:Add, Button, x225 y422 w80 h30 gGeneratorConfigRename, Rename
	Gui, ConfigMgr:Add, Button, x315 y422 w80 h30 gGeneratorConfigRemove, Remove
	Gui, ConfigMgr:Add, Button, x405 y422 w115 h30 gGeneratorConfigCreateMissing, Add Missing Values
	Gui, ConfigMgr:Add, Button, x530 y422 w145 h30 gGeneratorConfigImport, Import Existing File
	Gui, ConfigMgr:Add, Button, x685 y422 w75 h30 gGeneratorConfigClose, Close
	Gui, ConfigMgr:Add, Text, x20 y468 w740 h42 Center, Renaming a saved value updates steps created here. Code that you write manually will not be changed.
	Generator_RefreshConfigManager()
	Gui, ConfigMgr:Show, w780 h526, LLARS Config.ini Manager
}

Generator_RefreshConfigManager()
{
	global GeneratorConfigSections, GeneratorConfigRequirements, GeneratorConfigHWND
	if !(GeneratorConfigHWND && WinExist("ahk_id " . GeneratorConfigHWND))
		return
	Gui, ConfigMgr:Default
	LV_Delete()
	keyList := Generator_SortedConfigKeys()
	Loop, Parse, keyList, `n, `r
	{
		key := Trim(A_LoopField)
		if (key = "" || !GeneratorConfigSections.HasKey(key))
			continue
		section := GeneratorConfigSections[key]
		typeText := Generator_ConfigDisplayType(section.Type)
		sourceText := section.ReadOnly ? "Imported (read-only)" : (section.Source = "generated" ? "Generated" : "Creator")
		stateText := section.Required ? "Required" : (section.Orphan ? "Unreferenced" : "Extra")
		refText := ""
		if GeneratorConfigRequirements.HasKey(key)
			refText := GeneratorConfigRequirements[key].RefCount . " action reference(s)"
		LV_Add("", section.Name, typeText, sourceText, stateText, refText)
	}
	LV_ModifyCol(1, 180)
	LV_ModifyCol(2, 120)
	LV_ModifyCol(3, 140)
	LV_ModifyCol(4, 100)
	LV_ModifyCol(5, 180)
}

Generator_SortedConfigKeys()
{
	global GeneratorConfigSections
	list := ""
	for key, _ in GeneratorConfigSections
		list .= (list = "" ? "" : "`n") . key
	Sort, list
	return list
}

Generator_ConfigSelectedKey()
{
	global GeneratorConfigSections
	Gui, ConfigMgr:Default
	row := LV_GetNext()
	if !row
		return ""
	LV_GetText(name, row, 1)
	key := Generator_NormalizeConfigName(name)
	return GeneratorConfigSections.HasKey(key) ? key : ""
}

Generator_EditSelectedConfig()
{
	global GeneratorConfigSections
	key := Generator_ConfigSelectedKey()
	if (key = "")
	{
		MsgBox, 48, LLARS Config Generator, Select a saved Setup Value in the list first.
		return
	}
	section := GeneratorConfigSections[key]
	if section.ReadOnly
	{
		MsgBox, 48, LLARS Config Generator, This value was imported from another file and is protected. Choose Add Value to create a new editable value instead.
		return
	}
	Generator_OpenConfigEditor(key)
}

Generator_RenameSelectedConfig()
{
	global GeneratorConfigSections
	key := Generator_ConfigSelectedKey()
	if (key = "")
	{
		MsgBox, 48, LLARS Config Generator, Select a saved Setup Value in the list first.
		return
	}
	section := GeneratorConfigSections[key]
	if section.ReadOnly
	{
		MsgBox, 48, LLARS Config Generator, Imported existing sections are read-only and cannot be renamed by the Generator.
		return
	}
	InputBox, newName, Rename Config.ini Section, Enter the new section name. Every Generator-managed action reference will be updated., , 430, 155, , , , , % section.Name
	if ErrorLevel
		return
	newName := Trim(newName)
	if !Generator_ValidateConfigSectionName(newName, nameError)
	{
		MsgBox, 48, LLARS Config Generator, %nameError%
		return
	}
	newKey := Generator_NormalizeConfigName(newName)
	if (newKey != key && GeneratorConfigSections.HasKey(newKey))
	{
		MsgBox, 48, LLARS Config Generator, A section with that name already exists. Reuse the existing section or choose another name.
		return
	}
	Generator_RenameConfigSection(key, newName)
}

Generator_RenameConfigSection(oldKey, newName)
{
	global GeneratorConfigSections, GeneratorSequence
	oldKey := Generator_NormalizeConfigName(oldKey)
	if !GeneratorConfigSections.HasKey(oldKey)
		return false
	section := GeneratorConfigSections[oldKey]
	oldName := section.Name
	newKey := Generator_NormalizeConfigName(newName)
	if (newKey != oldKey && GeneratorConfigSections.HasKey(newKey))
		return false

	customWarning := false
	for _, node in GeneratorSequence
	{
		if (node.Kind = "custom")
		{
			if InStr(node.Code, oldName)
				customWarning := true
			continue
		}
		if (node.Kind != "api" && node.Kind != "condition" && node.Kind != "value")
			continue
		entry := LLARS_CreatorAPIGet(node.Function)
		if !IsObject(entry)
			continue
		for _, param in entry.Parameters
		{
			if (LLARS_CreatorConfigTypeForParameter(param.Type) = "" || !node.Values.HasKey(param.Name))
				continue
			value := node.Values[param.Name]
			if (param.Type = "config_color_list")
			{
				items := Generator_ParseConfigList(value)
				changed := false
				out := ""
				for _, item in items
				{
					if (Generator_NormalizeConfigName(item) = oldKey)
					{
						item := newName
						changed := true
					}
					out .= (out = "" ? "" : ", ") . item
				}
				if changed
					node.Values[param.Name] := out
			}
			else if (Generator_NormalizeConfigName(value) = oldKey)
				node.Values[param.Name] := newName
		}
	}

	GeneratorConfigSections.Delete(oldKey)
	section.Name := newName
	GeneratorConfigSections[newKey] := section
	Generator_ReconcileConfigRequirements(false)
	Generator_RefreshConfigManager()
	Generator_RefreshSequence()
	if customWarning
		MsgBox, 48, LLARS Config Generator, The managed references were renamed. A Custom AHK block also contains the old section text; review that raw code manually because the Generator will not rewrite arbitrary AHK.
	return true
}

Generator_RemoveSelectedConfig()
{
	global GeneratorConfigSections
	key := Generator_ConfigSelectedKey()
	if (key = "")
	{
		MsgBox, 48, LLARS Config Generator, Select a saved Setup Value in the list first.
		return
	}
	section := GeneratorConfigSections[key]
	if section.ReadOnly
	{
		MsgBox, 48, LLARS Config Generator, Imported existing sections are read-only in this phase.
		return
	}
	if section.Required
	{
		MsgBox, 48, LLARS Config Generator, This section is still referenced by the generated action sequence. Rename it or remove/change those action references first.
		return
	}
	MsgBox, 52, LLARS Config Generator, % "Remove [" . section.Name . "] from the generated Config.ini?"
	IfMsgBox, No
		return
	GeneratorConfigSections.Delete(key)
	Generator_RefreshConfigManager()
	Generator_UpdatePreview()
}

Generator_ValidateConfigSectionName(name, ByRef error)
{
	error := ""
	name := Trim(name)
	if (name = "")
	{
		error := "Enter a Config.ini section name."
		return false
	}
	if RegExMatch(name, "[\[\]`r`n]")
	{
		error := "Config.ini section names cannot contain brackets or line breaks."
		return false
	}
	return true
}

Generator_OpenConfigEditor(configKey := "")
{
	global GeneratorConfigModeLabel, GeneratorConfigPurpose
	global GeneratorConfigField1, GeneratorConfigField2, GeneratorConfigField3, GeneratorConfigField4
	global GeneratorConfigFieldLabel1, GeneratorConfigFieldLabel2, GeneratorConfigFieldLabel3, GeneratorConfigFieldLabel4
	global GeneratorConfigSections, GeneratorConfigEditorHWND, GeneratorConfigEditingKey, GeneratorConfigTypeLookup
	global GeneratorConfigSectionName, GeneratorConfigTypeChoice, GeneratorConfigModeChoice, GeneratorConfigDescription
    global GeneratorConfigTimingUnits, GeneratorConfigUnitsChoice, GeneratorConfigTimingHint, GeneratorConfigUnitsLabel
    global GeneratorConfigEditorTimingExact

    GeneratorConfigEditorTimingExact := {}
	GeneratorConfigEditingKey := configKey
	section := ""
	if (configKey != "" && GeneratorConfigSections.HasKey(configKey))
		section := GeneratorConfigSections[configKey]

	GeneratorConfigTypeLookup := {}
	typeList := ""
	for _, definition in LLARS_CreatorConfigTypes()
	{
		GeneratorConfigTypeLookup[definition.DisplayName] := definition.Name
		typeList .= (typeList = "" ? "" : "|") . definition.DisplayName
	}
	Sort, typeList, D|

	if IsObject(section)
	{
		sectionName := section.Name
		configType := section.Type
		description := section.Description
		mode := section.Mode
	}
	else
	{
		sectionName := ""
		configType := "coordinate"
		description := ""
		mode := "Point"
	}
	definition := LLARS_CreatorConfigGet(configType, mode)
	typeDisplay := IsObject(definition) ? definition.DisplayName : "Coordinate"

	Gui, ConfigEdit:New, +OwnDialogs +HwndGeneratorConfigEditorHWND +LabelGeneratorConfigEditor
	Gui, ConfigEdit:Font, s11 Bold cBlack
	Gui, ConfigEdit:Add, Text, x15 y12 w520 h28 Center, Edit a Saved Setup Value
	Gui, ConfigEdit:Font, s10 Norm cBlack
	Gui, ConfigEdit:Add, Text, x20 y54 w130 h22, Value name
	nameOptions := IsObject(section) ? "ReadOnly" : ""
	Gui, ConfigEdit:Add, Edit, % "x160 y50 w360 h25 vGeneratorConfigSectionName " . nameOptions, %sectionName%
	Gui, ConfigEdit:Add, Text, x20 y90 w130 h22, Value type
	typeOptions := IsObject(section) ? "Disabled" : ""
	Gui, ConfigEdit:Add, DropDownList, % "x160 y86 w360 vGeneratorConfigTypeChoice gGeneratorConfigEditorTypeChanged " . typeOptions, %typeList%
	GuiControl, ConfigEdit:ChooseString, GeneratorConfigTypeChoice, %typeDisplay%
	Gui, ConfigEdit:Add, Text, x20 y126 w130 h22 vGeneratorConfigModeLabel, Location kind
	Gui, ConfigEdit:Add, DropDownList, x160 y122 w360 vGeneratorConfigModeChoice gGeneratorConfigEditorModeChanged, Point|Area
	GuiControl, ConfigEdit:ChooseString, GeneratorConfigModeChoice, %mode%
	Gui, ConfigEdit:Add, Text, x20 y162 w130 h22, Description
	Gui, ConfigEdit:Add, Edit, x160 y158 w360 h42 vGeneratorConfigDescription, %description%

	Loop, 4
	{
		y := 218 + ((A_Index - 1) * 36)
		Gui, ConfigEdit:Add, Text, % "x20 y" . y . " w130 h22 vGeneratorConfigFieldLabel" . A_Index,
		Gui, ConfigEdit:Add, Edit, % "x160 y" . (y - 4) . " w360 h25 vGeneratorConfigField" . A_Index,
	}
	Gui, ConfigEdit:Add, Text, x20 y365 w130 h24 vGeneratorConfigUnitsLabel, Time units
    Gui, ConfigEdit:Add, DropDownList, x160 y361 w360 vGeneratorConfigUnitsChoice gGeneratorConfigUnitsChanged, Seconds (recommended)|Milliseconds (advanced)
    GeneratorConfigTimingUnits := "Seconds"
    GuiControl, ConfigEdit:Choose, GeneratorConfigUnitsChoice, 1
    Gui, ConfigEdit:Add, Text, x20 y400 w500 h60 +Wrap vGeneratorConfigTimingHint,
    Gui, ConfigEdit:Add, Text, x20 y467 w500 h40 +Wrap vGeneratorConfigPurpose,
	Gui, ConfigEdit:Font, s10 Bold cBlack
	Gui, ConfigEdit:Add, Button, x150 y516 w110 h32 gGeneratorConfigEditorSave, Save Value
	Gui, ConfigEdit:Add, Button, x290 y516 w110 h32 gGeneratorConfigEditorCancel, Cancel
	values := IsObject(section) ? section.Values : ""
	Generator_RenderConfigEditorFields(configType, mode, values)
	Gui, ConfigEdit:Show, w550 h566, LLARS Config.ini Section
}

Generator_ConfigEditorTypeChanged()
{
	global GeneratorConfigTypeChoice, GeneratorConfigTypeLookup
	Gui, ConfigEdit:Submit, NoHide
	if !GeneratorConfigTypeLookup.HasKey(GeneratorConfigTypeChoice)
		return
	configType := GeneratorConfigTypeLookup[GeneratorConfigTypeChoice]
	definition := LLARS_CreatorConfigGet(configType)
	mode := IsObject(definition) ? definition.DefaultMode : ""
	Generator_RenderConfigEditorFields(configType, mode)
}

Generator_ConfigEditorModeChanged()
{
	global GeneratorConfigTypeChoice, GeneratorConfigTypeLookup, GeneratorConfigModeChoice
	Gui, ConfigEdit:Submit, NoHide
	if !GeneratorConfigTypeLookup.HasKey(GeneratorConfigTypeChoice)
		return
	configType := GeneratorConfigTypeLookup[GeneratorConfigTypeChoice]
	Generator_RenderConfigEditorFields(configType, GeneratorConfigModeChoice)
}

Generator_RenderConfigEditorFields(configType, mode := "", existingValues := "")
{
    global GeneratorConfigEditingFieldCount, GeneratorConfigTimingUnits, GeneratorConfigEditorTimingExact
    GeneratorConfigEditorTimingExact := {}
	definition := LLARS_CreatorConfigGet(configType, mode)
	if !IsObject(definition)
		return
	if (definition.Modes != "")
	{
		GuiControl, ConfigEdit:Show, GeneratorConfigModeLabel
		GuiControl, ConfigEdit:Show, GeneratorConfigModeChoice
		GuiControl, ConfigEdit:ChooseString, GeneratorConfigModeChoice, % definition.Mode
	}
	else
	{
		GuiControl, ConfigEdit:Hide, GeneratorConfigModeLabel
		GuiControl, ConfigEdit:Hide, GeneratorConfigModeChoice
	}
	GuiControl, ConfigEdit:, GeneratorConfigPurpose, % definition.Purpose
    isTiming := (configType = "timing_range" || configType = "timer")
    if (isTiming)
    {
        GuiControl, ConfigEdit:Show, GeneratorConfigUnitsLabel
        GuiControl, ConfigEdit:Show, GeneratorConfigUnitsChoice
        GeneratorConfigTimingUnits := "Seconds"
        GuiControl, ConfigEdit:Choose, GeneratorConfigUnitsChoice, 1
        GuiControl, ConfigEdit:, GeneratorConfigTimingHint, Waits happen BEFORE the next step. Enter seconds (19 means 19 seconds); LLARS saves milliseconds automatically. Use Run Order to check placement.
    }
    else
    {
        GuiControl, ConfigEdit:Hide, GeneratorConfigUnitsLabel
        GuiControl, ConfigEdit:Hide, GeneratorConfigUnitsChoice
        GuiControl, ConfigEdit:, GeneratorConfigTimingHint, These settings are used by the named action. Return to Run Order to check when each action happens.
    }
	GeneratorConfigEditingFieldCount := definition.Fields.Length()
	Loop, 4
	{
		if (A_Index <= definition.Fields.Length())
		{
			field := definition.Fields[A_Index]
			value := field.Default
			if IsObject(existingValues) && existingValues.HasKey(field.Name)
				value := existingValues[field.Name]
			fieldLabel := field.DisplayName
            if (isTiming && (field.Name = "min" || field.Name = "max"))
            {
                fieldLabel := (field.Name = "min" ? "Minimum (seconds)" : "Maximum (seconds)")
                if (RegExMatch(value, "^-?(?:\d+(?:\.\d+)?|\.\d+)$"))
                {
                    displayed := Generator_FormatTime(value / 1000)
                    if (IsObject(existingValues) && existingValues.HasKey(field.Name))
                        GeneratorConfigEditorTimingExact[field.Name] := {Stored:value, Display:displayed}
                    value := displayed
                }
            }
			GuiControl, ConfigEdit:, % "GeneratorConfigFieldLabel" . A_Index, %fieldLabel%
			GuiControl, ConfigEdit:, % "GeneratorConfigField" . A_Index, %value%
			GuiControl, ConfigEdit:Show, % "GeneratorConfigFieldLabel" . A_Index
			GuiControl, ConfigEdit:Show, % "GeneratorConfigField" . A_Index
		}
		else
		{
			GuiControl, ConfigEdit:Hide, % "GeneratorConfigFieldLabel" . A_Index
			GuiControl, ConfigEdit:Hide, % "GeneratorConfigField" . A_Index
		}
	}
}

Generator_ConfigTimingUnitsChanged()
{
    global GeneratorConfigTypeChoice, GeneratorConfigTypeLookup, GeneratorConfigTimingUnits, GeneratorConfigEditorTimingExact
    GuiControlGet, requested, ConfigEdit:, GeneratorConfigUnitsChoice
    requested := InStr(requested, "Milliseconds") ? "Milliseconds" : "Seconds"
    if (requested = GeneratorConfigTimingUnits)
        return
    GuiControlGet, typeDisplay, ConfigEdit:, GeneratorConfigTypeChoice
    if !GeneratorConfigTypeLookup.HasKey(typeDisplay)
        return
    configType := GeneratorConfigTypeLookup[typeDisplay]
    if (configType != "timing_range" && configType != "timer")
        return
    definition := LLARS_CreatorConfigGet(configType)
    for index, field in definition.Fields
    {
        if (field.Name != "min" && field.Name != "max")
            continue
        controlName := "GeneratorConfigField" . index
        GuiControlGet, value, ConfigEdit:, %controlName%
        if (RegExMatch(value, "^-?(?:\d+(?:\.\d+)?|\.\d+)$"))
        {
            exact := GeneratorConfigEditorTimingExact.HasKey(field.Name) ? GeneratorConfigEditorTimingExact[field.Name] : ""
            unchanged := IsObject(exact) && (value = exact.Display)
            if (unchanged)
                converted := (requested = "Seconds") ? Generator_FormatTime(exact.Stored / 1000) : exact.Stored
            else
            {
                converted := (requested = "Seconds") ? Generator_FormatTime(value / 1000) : Generator_FormatTimingStorage(value * 1000)
                GeneratorConfigEditorTimingExact.Delete(field.Name)
            }
            GuiControl, ConfigEdit:, %controlName%, %converted%
            if (unchanged)
                GeneratorConfigEditorTimingExact[field.Name].Display := converted
        }
        fieldLabel := (field.Name = "min" ? "Minimum" : "Maximum") . (requested = "Seconds" ? " (seconds)" : " (milliseconds)")
        GuiControl, ConfigEdit:, % "GeneratorConfigFieldLabel" . index, %fieldLabel%
    }
    GeneratorConfigTimingUnits := requested
    hint := (requested = "Seconds") ? "Waits happen BEFORE the next step. Enter seconds (19 means 19 seconds); saved Config.ini uses milliseconds automatically." : "Advanced milliseconds: 1000 ms = 1 second; 19000 ms = 19 seconds. Check Run Order before generating."
    GuiControl, ConfigEdit:, GeneratorConfigTimingHint, %hint%
}

Generator_GetConfigEditorFieldValue(index)
{
	global GeneratorConfigField1, GeneratorConfigField2, GeneratorConfigField3, GeneratorConfigField4
	if (index = 1)
		return GeneratorConfigField1
	if (index = 2)
		return GeneratorConfigField2
	if (index = 3)
		return GeneratorConfigField3
	if (index = 4)
		return GeneratorConfigField4
	return ""
}

Generator_ValidateConfigField(field, value, ByRef error)
{
	error := ""
	value := Trim(value)
	if (field.ValueType = "boolean")
	{
		lower := value
		StringLower, lower, lower
		if lower not in true,false
		{
			error := field.DisplayName . " must be true or false."
			return false
		}
	}
	else if (field.ValueType = "number")
	{
		if !RegExMatch(value, "^-?(?:\d+(?:\.\d+)?|\.\d+)$")
		{
			error := field.DisplayName . " must be numeric."
			return false
		}
	}
	else if (field.ValueType = "integer_or_blank")
	{
		if (value != "" && !RegExMatch(value, "^-?\d+$"))
		{
			error := field.DisplayName . " must be a whole number or blank."
			return false
		}
	}
	else if (field.ValueType = "color")
	{
		if !RegExMatch(value, "i)^0x[0-9A-F]{6}$")
		{
			error := field.DisplayName . " must use 0xRRGGBB format."
			return false
		}
	}
	return true
}

Generator_SaveConfigEditor()
{
	global GeneratorConfigSections, GeneratorConfigEditingKey, GeneratorConfigTypeChoice, GeneratorConfigTypeLookup
	global GeneratorConfigSectionName, GeneratorConfigModeChoice, GeneratorConfigDescription, GeneratorConfigEditorHWND
    global GeneratorConfigTimingUnits, GeneratorConfigEditorTimingExact
	Gui, ConfigEdit:Submit, NoHide
	name := Trim(GeneratorConfigSectionName)
	if !Generator_ValidateConfigSectionName(name, nameError)
	{
		MsgBox, 48, LLARS Config Generator, %nameError%
		return
	}
	if !GeneratorConfigTypeLookup.HasKey(GeneratorConfigTypeChoice)
		return
	configType := GeneratorConfigTypeLookup[GeneratorConfigTypeChoice]
	mode := (configType = "coordinate") ? GeneratorConfigModeChoice : ""
	definition := LLARS_CreatorConfigGet(configType, mode)
	if !IsObject(definition)
		return

	key := Generator_NormalizeConfigName(name)
	if (GeneratorConfigEditingKey = "" && GeneratorConfigSections.HasKey(key))
	{
		MsgBox, 48, LLARS Config Generator, A section with that name already exists. Reuse it instead of creating a duplicate.
		return
	}

	values := {}
	for index, field in definition.Fields
	{
		value := Trim(Generator_GetConfigEditorFieldValue(index))
        if ((configType = "timing_range" || configType = "timer") && (field.Name = "min" || field.Name = "max"))
        {
            exact := GeneratorConfigEditorTimingExact.HasKey(field.Name) ? GeneratorConfigEditorTimingExact[field.Name] : ""
            if (IsObject(exact) && value = exact.Display)
                value := exact.Stored
            else if (GeneratorConfigTimingUnits = "Seconds" && RegExMatch(value, "^-?(?:\d+(?:\.\d+)?|\.\d+)$"))
                value := Generator_FormatTimingStorage(value * 1000)
        }
		if !Generator_ValidateConfigField(field, value, fieldError)
		{
			MsgBox, 48, LLARS Config Generator, %fieldError%
			return
		}
		values[field.Name] := value
	}
	if ((configType = "timing_range" || configType = "timer") && values.HasKey("min") && values.HasKey("max") && (values.min + 0) > (values.max + 0))
	{
		MsgBox, 48, LLARS Config Generator, Minimum timing value cannot be greater than maximum timing value.
		return
	}

	if (GeneratorConfigEditingKey != "" && GeneratorConfigSections.HasKey(GeneratorConfigEditingKey))
	{
		old := GeneratorConfigSections[GeneratorConfigEditingKey]
		if (old.HasKey("PreserveKey") && (old.Type != configType || old.Mode != definition.Mode))
		{
			MsgBox, 48, LLARS Config Generator, The saved section's type and Point/Area mode cannot be changed in place because existing values could be lost. Create a new section instead.
			return
		}
		section := {Name:old.Name, Type:configType, Mode:definition.Mode, Values:values, Description:Trim(GeneratorConfigDescription), Source:old.Source, ReadOnly:false, Required:old.Required, Orphan:old.Orphan, RawText:""}
		if old.HasKey("PreserveKey")
			section.PreserveKey := old.PreserveKey
		GeneratorConfigSections[GeneratorConfigEditingKey] := section
	}
	else
	{
		section := {Name:name, Type:configType, Mode:definition.Mode, Values:values, Description:Trim(GeneratorConfigDescription), Source:"manual", ReadOnly:false, Required:false, Orphan:false, RawText:""}
		GeneratorConfigSections[key] := section
	}
	Gui, ConfigEdit:Destroy
	GeneratorConfigEditorHWND := 0
	Generator_ReconcileConfigRequirements(false)
	Generator_RefreshConfigManager()
	Generator_UpdatePreview()
}

Generator_ImportExistingConfig()
{
	global GeneratorConfigSections, GeneratorConfigImportedCount
	FileSelectFile, configPath, 3, , Select an existing Config.ini to import read-only, Config files (*.ini)
	if (ErrorLevel || configPath = "")
		return
	FileRead, contents, %configPath%
	if ErrorLevel
	{
		MsgBox, 16, LLARS Config Generator, The selected Config.ini could not be read.
		return
	}
	contents := StrReplace(contents, Chr(0xFEFF))
	currentName := ""
	currentRaw := ""
	currentValues := {}
	imported := 0
	skipped := 0
	Loop, Parse, contents, `n, `r
	{
		line := A_LoopField
		trimmed := Trim(line)
		if RegExMatch(trimmed, "^\[(.*)\]$", match)
		{
			if (currentName != "")
			{
				if Generator_StoreImportedConfigSection(currentName, currentRaw, currentValues)
					imported += 1
				else
					skipped += 1
			}
			currentName := Trim(match1)
			currentRaw := "[" . currentName . "]`r`n"
			currentValues := {}
			continue
		}
		if (currentName = "")
			continue
		currentRaw .= line . "`r`n"
		if (trimmed = "" || SubStr(trimmed, 1, 1) = "#" || SubStr(trimmed, 1, 1) = ";")
			continue
		eq := InStr(line, "=")
		if !eq
			continue
		key := Trim(SubStr(line, 1, eq - 1))
		value := Trim(SubStr(line, eq + 1))
		StringLower, key, key
		if (key != "")
			currentValues[key] := value
	}
	if (currentName != "")
	{
		if Generator_StoreImportedConfigSection(currentName, currentRaw, currentValues)
			imported += 1
		else
			skipped += 1
	}
	GeneratorConfigImportedCount += imported
	Generator_ReconcileConfigRequirements(false)
	Generator_RefreshConfigManager()
	Generator_UpdatePreview()
	MsgBox, 64, LLARS Config Generator, % "Imported " . imported . " section(s) read-only. Existing Generator sections skipped: " . skipped . "."
}

Generator_StoreImportedConfigSection(name, rawText, values)
{
	global GeneratorConfigSections
	key := Generator_NormalizeConfigName(name)
	if (key = "" || GeneratorConfigSections.HasKey(key))
		return false
	configType := Generator_InferImportedConfigType(name, values)
	mode := ""
	if (configType = "coordinate")
		mode := (values.HasKey("xmin") || values.HasKey("xmax") || values.HasKey("ymin") || values.HasKey("ymax")) ? "Area" : "Point"
	GeneratorConfigSections[key] := {Name:name, Type:configType, Mode:mode, Values:values, Description:"", Source:"imported", ReadOnly:true, Required:false, Orphan:false, RawText:rawText}
	return true
}

Generator_InferImportedConfigType(name, values)
{
	if values.HasKey("type")
	{
		type := Trim(values["type"])
		StringLower, type, type
		if type in coordinate,hotkey,color,timer
			return type
	}
	if (values.HasKey("min") || values.HasKey("max"))
	{
		lowerName := name
		StringLower, lowerName, lowerName
		if (lowerName = "timer")
			return "timer"
		return "timing_range"
	}
	if values.HasKey("option")
		return "option"
	return "other"
}

Generator_BuildConfigPreview()
{
	global GeneratorConfigSections
	if !Generator_ConfigHasSections()
		return "# No setup file needed for these actions.`r`n# Add an action that needs setup values to create Config.ini.`r`n"

	out := "# Generated by LLARS Script Generator.`r`n# Creator action requirements and section types come from the LLARS Creator catalog.`r`n"
    out .= "# Timing min/max values use MILLISECONDS (1000 = 1 second). A Wait runs BEFORE the next action.`r`n`r`n"
	keyList := Generator_SortedConfigKeys()
	Loop, Parse, keyList, `n, `r
	{
		key := Trim(A_LoopField)
		if (key = "" || !GeneratorConfigSections.HasKey(key))
			continue
		section := GeneratorConfigSections[key]
		if section.ReadOnly
		{
			out .= RTrim(section.RawText, "`r`n") . "`r`n`r`n"
			continue
		}
		if (section.Orphan)
			out .= "# Unreferenced section retained by creator.`r`n"
		if (Trim(section.Description) != "")
		{
			descriptionText := section.Description
			Loop, Parse, descriptionText, `n, `r
				out .= "# " . A_LoopField . "`r`n"
		}
		out .= "[" . section.Name . "]`r`n"
		definition := LLARS_CreatorConfigGet(section.Type, section.Mode)
		if !IsObject(definition)
		{
			out .= "# Unknown managed section type: " . section.Type . "`r`n`r`n"
			continue
		}
		if (definition.TypeLine != "")
			out .= "type=" . definition.TypeLine . "`r`n"
		for _, field in definition.Fields
		{
			value := section.Values.HasKey(field.Name) ? section.Values[field.Name] : field.Default
			out .= field.Name . "=" . value . "`r`n"
		}
		out .= "`r`n"
	}
	return RTrim(out, "`r`n") . "`r`n"
}

Generator_ConfigHasSections()
{
	global GeneratorConfigSections
	for key, section in GeneratorConfigSections
		return true
	return false
}

Generator_ValidateConfigRequirements(ByRef error)
{
	global GeneratorConfigSections
	error := ""
	requirements := Generator_DiscoverConfigRequirements()
	for key, req in requirements
	{
		if (req.Conflict != "")
		{
			error := "Config section " . req.Name . " is referenced as incompatible types (" . req.Conflict . ")."
			return false
		}
		if !GeneratorConfigSections.HasKey(key)
		{
			error := "Required Config.ini section is missing: " . req.Name . "."
			return false
		}
		section := GeneratorConfigSections[key]
		if (!req.Generic && section.Type != req.Type)
		{
			error := "Config section " . req.Name . " must be " . Generator_ConfigDisplayType(req.Type) . ", not " . Generator_ConfigDisplayType(section.Type) . "."
			return false
		}
	}

	for _, section in GeneratorConfigSections
	{
		if section.ReadOnly
			continue
		definition := LLARS_CreatorConfigGet(section.Type, section.Mode)
		if !IsObject(definition)
		{
			error := "Unknown managed Config.ini section type: " . section.Type . "."
			return false
		}
		for _, field in definition.Fields
		{
			value := section.Values.HasKey(field.Name) ? section.Values[field.Name] : field.Default
			if !Generator_ValidateConfigField(field, value, fieldError)
			{
				error := section.Name . ": " . fieldError
				return false
			}
		}
		if ((section.Type = "timing_range" || section.Type = "timer") && section.Values.HasKey("min") && section.Values.HasKey("max") && (section.Values.min + 0) > (section.Values.max + 0))
		{
			error := section.Name . ": minimum timing value cannot be greater than maximum timing value."
			return false
		}
	}
	return true
}


; Uses the exact runtime capability scanner on a transient, fully-rendered Config.ini.
; This is a shared Config API include, not a second Generator capability model.
; A private temporary INI is necessary because the runtime scanner accepts file paths.
Generator_ScanGeneratedCapabilities(ByRef error)
{
	error := ""
	if !Generator_ConfigHasSections()
		return LLARS_ConfigCapabilityScan("", "", false)

	tempPath := A_Temp . "\LLARS_Generator_Capabilities_" . DllCall("GetCurrentProcessId", "UInt") . ".ini"
	if FileExist(tempPath)
	{
		error := "A previous capability preview file is still present; no file was overwritten."
		return ""
	}

	; Windows IniRead recognizes UTF-16 BOM. UTF-8 BOM can mask the first section.
	file := FileOpen(tempPath, "w", "UTF-16")
	if !IsObject(file)
	{
		error := "Unable to create the temporary capability preview file."
		return ""
	}
	file.Write(Generator_BuildConfigPreview())
	file.Close()
	if !FileExist(tempPath)
	{
		error := "Unable to materialize the Config.ini capability preview."
		return ""
	}
	caps := LLARS_ConfigCapabilityScan(tempPath, "", false)
	FileDelete, %tempPath%
	if FileExist(tempPath)
	{
		error := "Unable to remove the temporary capability preview file."
		return ""
	}
	return caps
}

Generator_CapabilityFlagText(required)
{
	return required ? "Required" : "Not Required"
}

Generator_CapabilitySummary(caps)
{
	if !IsObject(caps)
		return "Setup preview unavailable"
	return "Hotkeys: " . Generator_CapabilityFlagText(caps.Hotkeys) . " | Coordinates: " . Generator_CapabilityFlagText(caps.Coordinates)
		. "`nColors: " . Generator_CapabilityFlagText(caps.Colors) . " | Timer: " . Generator_CapabilityFlagText(caps.Timer)
		. "`nScript Config: " . Generator_CapabilityFlagText(caps.ScriptConfig)
}

Generator_CapabilityDetail(caps)
{
	if !IsObject(caps)
		return "Setup preview unavailable."
	out := "Hotkeys: " . Generator_CapabilityFlagText(caps.Hotkeys)
	out .= "`nCoordinates: " . Generator_CapabilityFlagText(caps.Coordinates)
	out .= "`nColors: " . Generator_CapabilityFlagText(caps.Colors)
	out .= "`nTimer: " . Generator_CapabilityFlagText(caps.Timer)
	out .= "`nScript Config: " . Generator_CapabilityFlagText(caps.ScriptConfig)
	return out
}

Generator_CapabilityParity(expected, actual, ByRef error)
{
	error := ""
	if !IsObject(expected) || !IsObject(actual)
	{
		error := "A capability scan was unavailable."
		return false
	}
	fields := ["Disabled", "ConfigExists", "RequiresLocalConfig", "Hotkeys", "Coordinates", "Colors", "Timer", "ScriptConfig", "SetupType", "SetupText"]
	for _, field in fields
	{
		if (expected[field] != actual[field])
		{
			error := field . " differs between the Generator preview and runtime config scan."
			return false
		}
	}
	return true
}

Generator_RefreshSetupRequirements()
{
	global GeneratorCapabilitySnapshot, GeneratorCapabilityError
	GeneratorCapabilitySnapshot := Generator_ScanGeneratedCapabilities(GeneratorCapabilityError)
	summary := (GeneratorCapabilityError != "") ? "Setup preview unavailable: " . GeneratorCapabilityError : Generator_CapabilitySummary(GeneratorCapabilitySnapshot)
	GuiControl, Sequence:, GeneratorSequenceCapabilitySummary, %summary%
}

Generator_ShowSetupRequirements()
{
	global GeneratorCapabilitySnapshot, GeneratorCapabilityError
	Generator_RefreshSetupRequirements()
	if (GeneratorCapabilityError != "")
	{
		MsgBox, 48, LLARS Setup Requirements, %GeneratorCapabilityError%
		return
	}
	text := "Requirements derived by the same Config.ini scanner used by Selector and LLARS runtime:`n`n"
	text .= Generator_CapabilityDetail(GeneratorCapabilitySnapshot)
	text .= "`n`nSetup Status and Check Setup will show the required categories."
	text .= "`nOpen the generated script in LLARS and use Setup to configure or verify required values."
	text .= "`n`nThis previews required categories, not configuration readiness or runtime input availability."
	MsgBox, 64, LLARS Setup Requirements, %text%
}

; ================================================================
; |     CREATOR PREFLIGHT     -     CREATOR PREFLIGHT            |
; ================================================================
; This is a pre-write validation of the Generator-owned model, not a parser
; for arbitrary Custom AHK. Shared validators and the authoritative Creator
; catalog remain the contracts for API, config, and capability correctness.
Generator_PreflightAdd(ByRef report, severity, code, message)
{
	report.Issues.Push({Severity:severity, Code:code, Text:message})
	if (severity = "Error")
		report.Errors += 1
	else if (severity = "Warning")
		report.Warnings += 1
	else
		report.Info += 1
}

Generator_RunCreatorPreflight(checkDestination := true)
{
	global GeneratorSequence, GeneratorConfigSections, GeneratorScriptName, GeneratorSequenceOutputParent, GeneratorSequenceFamily
	global GeneratorCapabilitySnapshot, GeneratorCapabilityError
    global GeneratorOpenProjectPath, GeneratorOpenProjectSource, GeneratorOpenProjectHash, GeneratorOpenConfigHash
	report := {Errors:0, Warnings:0, Info:0, Issues:[]}
    if (GeneratorOpenProjectPath != "" && checkDestination)
    {
        checkDestination := false
        if (Generator_ProjectFileHash(GeneratorOpenProjectSource) != GeneratorOpenProjectHash)
            Generator_PreflightAdd(report, "Error", "EXTERNAL_SOURCE", "The saved AHK changed outside Sequence Builder. Reopen after reviewing manual edits.")
    }

	if (checkDestination && !Generator_ValidateSequenceDestination(GeneratorScriptName, GeneratorSequenceOutputParent, dest, destAHK, identityError))
		Generator_PreflightAdd(report, "Error", "IDENTITY", identityError)

	if !IsObject(GeneratorSequence) || GeneratorSequence.Length() = 0
		Generator_PreflightAdd(report, "Error", "EMPTY_SEQUENCE", "Add at least one Creator action before generating.")
	else
	{
		Generator_PreflightValidateActions(report)
        Generator_PreflightTimingClarity(report)
		Generator_PreflightValidateFlow(report)
		if !Generator_SequenceHasTiming()
			Generator_PreflightAdd(report, "Error", "MISSING_TIMING", "The RunCount scaffold needs at least one LLARS timing action.")
		runtimeModel := Generator_BuildRuntimeModel()
		if (!runtimeModel.Emit)
			Generator_PreflightAdd(report, "Warning", "PARTIAL_RUNTIME_ESTIMATE", "Runtime estimate will use the existing source parser. " . runtimeModel.Reason)
	}

	Generator_ValidateBankingFamily(report)
	if !Generator_ValidateCreatorDetails(detailError)
		Generator_PreflightAdd(report, "Error", "SCRIPT_METADATA", detailError)
	if (checkDestination && IsObject(GeneratorSequence) && GeneratorSequence.Length() && Generator_ValidateSequenceDestination(GeneratorScriptName, GeneratorSequenceOutputParent, proposedDest, proposedAHK, proposedError))
	{
		if !Generator_ValidateRegistryTarget(proposedDest, GeneratorScriptName, registryError)
			Generator_PreflightAdd(report, "Error", "SELECTOR_REGISTRY", registryError)
	}
	if !Generator_ValidateConfigRequirements(configError)
		Generator_PreflightAdd(report, "Error", "CONFIG", configError)
	for key, section in GeneratorConfigSections
	{
		if (Generator_NormalizeConfigName(section.Name) != key)
			Generator_PreflightAdd(report, "Error", "CONFIG_NAME", "Config section " . section.Name . " has a mismatched normalized key.")
		if !Generator_ValidateConfigSectionName(section.Name, sectionError)
			Generator_PreflightAdd(report, "Error", "CONFIG_NAME", sectionError)
		if section.ReadOnly
			Generator_PreflightAdd(report, "Info", "IMPORTED_CONFIG", "Imported [" . section.Name . "] is preserved read-only; its arbitrary legacy values are not fully validated.")
		if section.Orphan
			Generator_PreflightAdd(report, "Info", "ORPHAN_CONFIG", "Unreferenced [" . section.Name . "] is retained by choice.")
	}
	if (report.Errors = 0)
	{
		caps := Generator_ScanGeneratedCapabilities(scanError)
		if (scanError != "" || !IsObject(caps))
			Generator_PreflightAdd(report, "Error", "CAPABILITY_SCAN", "Shared Setup scanner could not validate the generated config: " . scanError)
	}

	; Match the actual source scaffold rather than reimplementing its include chain.
	scaffold := A_ScriptDir . "\RunCount\Basic Loop\Basic Loop Script Template.ahk"
	if !FileExist(scaffold)
		Generator_PreflightAdd(report, "Error", "SCAFFOLD", "Basic Loop template is missing.")
	else
	{
		FileRead, sourceText, %scaffold%
		if (ErrorLevel || Generator_InjectEditableBlock(sourceText, "Run(ctx)`r`n{`r`n}`r`n", injectError) = "")
			Generator_PreflightAdd(report, "Error", "DEPENDENCY_CLOSURE", "The required editable scaffold markers are unavailable: " . injectError)
	}
	return report
}

Generator_PreflightTimingClarity(ByRef report)
{
    global GeneratorSequence, GeneratorConfigSections
    for index, node in GeneratorSequence
    {
        if (node.Kind != "api" || !Generator_IsConfiguredWait(node) || !node.Values.HasKey("section"))
            continue
        name := node.Values.section
        key := Generator_NormalizeConfigName(name)
        if !GeneratorConfigSections.HasKey(key)
            continue
        section := GeneratorConfigSections[key]
        if !IsObject(section.Values) || !section.Values.HasKey("max")
            continue
        upper := section.Values.max
        if !RegExMatch(upper, "^-?(?:\d+(?:\.\d+)?|\.\d+)$")
            continue
        if (InStr(name, "short", false) && upper >= 5000)
            Generator_PreflightAdd(report, "Warning", "MISLEADING_WAIT_NAME", "Item " . index . ": [" . name . "] says short but lasts up to " . Generator_FormatTime(upper/1000) . " seconds. Review its position before the next action.")
        nextLabel := Generator_RunOrderNextAction(index)
        if (upper >= 15000 && InStr(nextLabel, "Press key ") = 1)
            Generator_PreflightAdd(report, "Warning", "WAIT_BEFORE_KEY", "Item " . index . ": " . Generator_TimingRangeLabel(name) . " passes BEFORE " . nextLabel . ". Read Run Order to confirm this is intended.")
    }
}

Generator_PreflightValidateActions(ByRef report)
{
	global GeneratorSequence
	hasStatus := false
	hasInput := false
	hasCustom := false
	for index, node in GeneratorSequence
	{
		if !IsObject(node) || !node.HasKey("Kind")
		{
			Generator_PreflightAdd(report, "Error", "ACTION_MODEL", "Item " . index . " is not a recognized action model.")
			continue
		}
		if (node.Kind = "custom")
		{
			hasCustom := true
			if !node.HasKey("Code") || Trim(node.Code) = ""
				Generator_PreflightAdd(report, "Error", "EMPTY_CUSTOM", "Custom AHK item " . index . " contains no code.")
			Generator_PreflightAdd(report, "Warning", "CUSTOM_UNVERIFIED", "Custom AHK item " . index . " cannot be checked for API signatures, dependencies, pause safety, or syntax.")
			continue
		}
		if (node.Kind = "flow")
			continue
		if (node.Kind != "api" && node.Kind != "condition" && node.Kind != "value")
		{
			Generator_PreflightAdd(report, "Error", "UNKNOWN_ACTION", "Item " . index . " has unknown kind " . node.Kind . ".")
			continue
		}
		entry := LLARS_CreatorAPIGet(node.Function)
		if !IsObject(entry) || !entry.GeneratorSafe || entry.Classification = "Framework Internal"
		{
			Generator_PreflightAdd(report, "Error", "UNKNOWN_API", "Item " . index . " references an unknown or non-Generator Creator API: " . node.Function . ".")
			continue
		}
		mode := Generator_ActionMode(entry)
		if ((node.Kind = "api" && mode != "statement") || (node.Kind != "api" && node.Kind != mode))
			Generator_PreflightAdd(report, "Error", "API_MODE", "Item " . index . " has a result/condition mode incompatible with " . entry.Name . ".")
		if !IsObject(node.Values)
		{
			Generator_PreflightAdd(report, "Error", "API_ARGUMENTS", "Item " . index . " is missing its argument values.")
			continue
		}
		if (entry.Parameters.Length() > 8)
			Generator_PreflightAdd(report, "Error", "API_ARITY", "Item " . index . " exceeds the supported editor argument count.")
		paramNames := {}
		for _, param in entry.Parameters
		{
			paramNames[param.Name] := true
			value := node.Values.HasKey(param.Name) ? Trim(node.Values[param.Name]) : (param.Required ? "" : Generator_SuggestParamValue(param))
			if (param.Required && value = "")
				Generator_PreflightAdd(report, "Error", "API_REQUIRED", "Item " . index . ": " . param.Name . " is required.")
			else if !Generator_ValidateParamValue(param, value, paramError)
				Generator_PreflightAdd(report, "Error", "API_TYPE", "Item " . index . ": " . paramError)
		}
		for paramName, value in node.Values
		{
			if !paramNames.HasKey(paramName)
				Generator_PreflightAdd(report, "Error", "API_ARITY", "Item " . index . " has an unknown argument " . paramName . ".")
		}
		if (node.Kind = "value")
		{
			if !RegExMatch(node.ResultVariable, "^[A-Za-z_][A-Za-z0-9_]*$")
				Generator_PreflightAdd(report, "Error", "RESULT_VARIABLE", "Item " . index . " needs a valid result variable.")
		}
        if (entry.Category = "Status" || (node.HasKey("ShowProgress") && node.ShowProgress))
            hasStatus := true
		if entry.PerformsInput
			hasInput := true
	}
	if !hasStatus
		Generator_PreflightAdd(report, "Info", "NO_STATUS", "No Creator Status action is present; consider adding a status message.")
	if !hasInput
		Generator_PreflightAdd(report, "Warning", "NO_INPUT", "No catalogued pause-aware input action is present; inspect any Custom AHK for safe input behavior.")
}

Generator_PreflightValidateFlow(ByRef report)
{
	global GeneratorSequence
	stack := []
	for index, node in GeneratorSequence
	{
		if !IsObject(node) || !node.HasKey("Kind")
			continue
		if (node.Kind = "api" || node.Kind = "value" || node.Kind = "condition" || node.Kind = "custom")
		{
			for level, frame in stack
			{
				frame.Items += 1
				if (node.Kind = "api" || node.Kind = "condition" || node.Kind = "value")
				{
					entry := LLARS_CreatorAPIGet(node.Function)
					if IsObject(entry) && entry.Category = "Timing"
						frame.Timing += 1
				}
				stack[level] := frame
			}
		}
		if (node.Kind = "condition")
			stack.Push({Type:"if", Index:index, Items:0, Timing:0})
		else if (node.Kind = "flow")
		{
			if (node.FlowType = "repeat_n" || node.FlowType = "repeat_forever")
			{
				if (node.FlowType = "repeat_n" && (!RegExMatch(node.Count, "^\d+$") || node.Count < 1))
					Generator_PreflightAdd(report, "Error", "LOOP_COUNT", "Repeat count at item " . index . " must be a positive integer.")
				stack.Push({Type:"loop", Index:index, Items:0, Timing:0})
			}
			else if (node.FlowType = "else")
			{
				if (stack.Length() = 0 || stack[stack.Length()].Type != "if")
					Generator_PreflightAdd(report, "Error", "ELSE", "Else at item " . index . " has no unmatched condition.")
				else
				{
					frame := stack[stack.Length()]
					if (frame.Items = 0)
						Generator_PreflightAdd(report, "Error", "EMPTY_BRANCH", "If at item " . frame.Index . " has an empty branch before Else.")
					frame.Type := "else"
					frame.Items := 0
					stack[stack.Length()] := frame
				}
			}
			else if (node.FlowType = "end_block")
			{
				if (stack.Length() = 0)
					Generator_PreflightAdd(report, "Error", "END_BLOCK", "End Block at item " . index . " has no matching opener.")
				else
				{
					frame := stack.Pop()
					if (frame.Items = 0)
						Generator_PreflightAdd(report, "Error", "EMPTY_BRANCH", "Block starting at item " . frame.Index . " has no action in its " . frame.Type . " branch.")
					if (frame.Type = "loop" && frame.Timing = 0)
						Generator_PreflightAdd(report, "Warning", "LOOP_NO_DELAY", "Repeat block at item " . frame.Index . " has no catalogued Timing action.")
				}
			}
			else if (node.FlowType = "break" || node.FlowType = "continue")
			{
				insideLoop := false
				for _, frame in stack
				{
					if (frame.Type = "loop")
						insideLoop := true
				}
				if !insideLoop
					Generator_PreflightAdd(report, "Error", "LOOP_CONTROL", "Item " . index . " uses " . node.FlowType . " outside a loop.")
				if (index < GeneratorSequence.Length())
				{
					nextNode := GeneratorSequence[index + 1]
					if IsObject(nextNode) && (nextNode.Kind != "flow" || (nextNode.FlowType != "end_block" && nextNode.FlowType != "else"))
						Generator_PreflightAdd(report, "Warning", "UNREACHABLE", "An action following unconditional " . node.FlowType . " at item " . index . " may be unreachable.")
				}
			}
			else
					Generator_PreflightAdd(report, "Error", "UNKNOWN_FLOW", "Unknown flow control at item " . index . ".")
		}
	}
	for _, frame in stack
		Generator_PreflightAdd(report, "Error", "UNCLOSED_BLOCK", "Block opened at item " . frame.Index . " has no End Block.")
}

Generator_PreflightFormat(report, maxLines := 0)
{
	out := ""
	shown := 0
	for _, severity in ["Error", "Warning", "Info"]
	{
		for _, item in report.Issues
		{
			if (item.Severity != severity)
				continue
			if (maxLines > 0 && shown >= maxLines)
				return out . "... additional issues are available in View Details."
			out .= item.Severity . ": " . item.Text . "`r`n"
			shown += 1
		}
	}
	return (out = "") ? "Your steps are ready for the next check. No problems found." : RTrim(out, "`r`n")
}

Generator_DisplayCreatorPreflight(report)
{
	global GeneratorPreflightReport, GeneratorSequenceHWND
	GeneratorPreflightReport := report
	if !(GeneratorSequenceHWND && WinExist("ahk_id " . GeneratorSequenceHWND))
		return
	state := report.Errors ? "Please fix the errors below before saving" : (report.Warnings ? "Review suggested - you can still save" : "Ready")
	summary := state . "  |  Errors: " . report.Errors . "  Warnings: " . report.Warnings . "  Info: " . report.Info
	GuiControl, Sequence:, GeneratorPreflightSummary, %summary%
	text := Generator_PreflightFormat(report, 7)
	GuiControl, Sequence:, GeneratorPreflightDetails, %text%
}

Generator_RefreshCreatorPreflight()
{
	Generator_DisplayCreatorPreflight(Generator_RunCreatorPreflight(true))
}

Generator_ShowPreflightDetails()
{
	global GeneratorPreflightReport
	report := Generator_RunCreatorPreflight(true)
	Generator_DisplayCreatorPreflight(report)
	text := Generator_PreflightFormat(report)
	MsgBox, 64, LLARS Script Check, % "Errors: " . report.Errors . " | Warnings: " . report.Warnings . " | Info: " . report.Info . "`n`n" . text
}

Generator_CreateSequenceScript()
{
	global GeneratorScriptName, GeneratorSequenceOutputParent, GeneratorSequence
	global GeneratorCreatorCategory, GeneratorCreatorDifficulty, GeneratorCreatorAuthor, GeneratorRegisterSelector

    ; The Builder name is authoritative while it is open. Commit it BEFORE
    ; submitting the main GUI, whose Edit may still contain an older name.
    Generator_SyncScriptNameToMain()
	Gui, 1:Submit, NoHide
	Generator_ReconcileConfigRequirements(false)
	preflight := Generator_RunCreatorPreflight(true)
	Generator_DisplayCreatorPreflight(preflight)
	if (preflight.Errors > 0)
	{
        GuiControl, Sequence:Choose, GeneratorSequencePage, 2
		MsgBox, 48, LLARS Script Check, % "Creation blocked: " . preflight.Errors . " error(s).`n`n" . Generator_PreflightFormat(preflight, 14) . "`n`nOpen Review & Save and fix the errors shown there."
		return
	}
	; Pre-save preview must be a successful invocation of the runtime scanner.
	expectedCapabilities := Generator_ScanGeneratedCapabilities(capabilityError)
	if (capabilityError != "")
	{
		MsgBox, 48, LLARS Sequence Builder, % "Cannot verify Setup requirements: " . capabilityError
		return
	}
	if !Generator_ValidateSequenceDestination(GeneratorScriptName, GeneratorSequenceOutputParent, destination, destinationAHK, validationError)
	{
		MsgBox, 48, LLARS Sequence Builder, %validationError%
		return
	}

	; Final summary uses the same preflight, derived capabilities, timing model and
	; target identity as the actual file writer. No destination exists yet.
	summary := "Script: " . GeneratorScriptName . "`nFamily: " . GeneratorSequenceFamily
	summary .= "`nCategory: " . GeneratorCreatorCategory . "`nDifficulty: " . GeneratorCreatorDifficulty . "`nDescription: " . GeneratorCreatorDescription . "`nAuthor: " . (GeneratorCreatorAuthor = "" ? "Not specified" : GeneratorCreatorAuthor)
	summary .= "`nActions: " . GeneratorSequence.Length() . "`n" . Generator_CapabilitySummary(expectedCapabilities)
	summary .= "`nPreflight: " . preflight.Warnings . " warning(s), " . preflight.Info . " info item(s)`n`nFiles to create:`n" . destinationAHK
	summary .= Generator_ConfigHasSections() ? "`n" . destination . "\Config.ini" : "`n(No local Config.ini required)"
	summary .= "`nEditable Creator project record: " . destination . "\Creator Project.llars"
	summary .= "`nShow in Script Selector: " . (GeneratorRegisterSelector ? "Yes (reopen Selector after creation)" : "No (change in Script Details)")
	summary .= "`nRuntime metadata: " . (Generator_BuildRuntimeModel().Emit ? "Modeled" : "Parser fallback")
	summary .= "`n`nCreate these files now? Existing destinations will not be overwritten."
	MsgBox, 36, LLARS Pre-Generation Summary, %summary%
	IfMsgBox, No
		return

	sourceFolder := A_ScriptDir . "\RunCount\Basic Loop"
	sourceAHK := sourceFolder . "\Basic Loop Script Template.ahk"
	if !FileExist(sourceAHK)
	{
		MsgBox, 16, LLARS Sequence Builder, The Basic Loop scaffold is missing from the Templates folder.
		return
	}

	FileRead, templateText, %sourceAHK%
	if (ErrorLevel)
	{
		MsgBox, 16, LLARS Sequence Builder, The Basic Loop scaffold could not be read.
		return
	}
	block := Generator_BuildEditableBlock()
	generatedText := Generator_InjectEditableBlock(templateText, block, injectError)
	if (generatedText = "")
	{
		MsgBox, 16, LLARS Sequence Builder, %injectError%
		return
	}

	; Creator identity is readable in ordinary AHK without requiring the GUI.
	generatedText := "; Creator: " . GeneratorScriptName . " | " . GeneratorCreatorCategory . " | " . GeneratorCreatorDifficulty . "`r`n; Description: " . GeneratorCreatorDescription . "`r`n" . generatedText
	if (GeneratorCreatorAuthor != "")
		generatedText := "; Author: " . GeneratorCreatorAuthor . "`r`n" . generatedText

	; Atomic Windows CreateDirectoryW fails if another creator wins a race.
	; Never adopt or delete a directory that this creation did not own.
	if !DllCall("CreateDirectoryW", "WStr", destination, "Ptr", 0)
	{
		MsgBox, 16, LLARS Sequence Builder, The destination already exists or could not be created. No existing files were changed.
		return
	}
	FileAppend, %generatedText%, %destinationAHK%, UTF-8
	if (ErrorLevel)
	{
		FileRemoveDir, %destination%, 1
		MsgBox, 16, LLARS Sequence Builder, The generated script could not be written.
		return
	}
	configPath := destination . "\Config.ini"
	if Generator_ConfigHasSections()
	{
		configText := Generator_BuildConfigPreview()
		FileAppend, %configText%, %configPath%, UTF-16
		if (ErrorLevel)
		{
			FileRemoveDir, %destination%, 1
			MsgBox, 16, LLARS Sequence Builder, The generated Config.ini could not be written.
			return
		}
		configResult := "Generated Config.ini: " . configPath
	}
	else
		configResult := "No script-local Config.ini is required by this sequence."

	; Verify the actual saved script/config pair, including Config.ini presence,
	; against the preview before reporting creation as successful.
	actualCapabilities := LLARS_ConfigCapabilityScan(configPath, destinationAHK)
	if !Generator_CapabilityParity(expectedCapabilities, actualCapabilities, parityError)
	{
		FileRemoveDir, %destination%, 1
		MsgBox, 16, LLARS Sequence Builder, % "Generated Setup requirements did not match the preview; created files were rolled back.`n`n" . parityError
		return
	}

	; The saved source must still have the editable RunCount scaffold and
	; matching generated runtime metadata before being announced or registered.
	FileRead, verifiedText, %destinationAHK%
	if (ErrorLevel || !InStr(verifiedText, "; SCRIPT_EDIT_BEGIN_4C4C415253") || !InStr(verifiedText, "; SCRIPT_EDIT_END_4C4C415253") || !InStr(verifiedText, block))
	{
		FileRemoveDir, %destination%, 1
		MsgBox, 16, LLARS Sequence Builder, Post-generation AHK scaffold verification failed. Created files were rolled back.
		return
	}
	projectPath := destination . "\Creator Project.llars"
	if !Generator_WriteCreatorProject(projectPath, destinationAHK, configPath, projectError)
	{
		FileRemoveDir, %destination%, 1
		MsgBox, 16, LLARS Sequence Builder, % "Could not save editable Creator project; new script was rolled back. " . projectError
		return
	}
	if !Generator_RegisterCreatedScript(destination, GeneratorScriptName, registryError)
	{
		FileRemoveDir, %destination%, 1
		MsgBox, 16, LLARS Sequence Builder, % "Selector registration failed; generated files were rolled back.`n`n" . registryError
		return
	}
	Generator_ShowCreatedOptions(destination, destinationAHK)
}

Generator_ValidateSequenceDestination(ByRef scriptName, ByRef outputParent, ByRef destination, ByRef destinationAHK, ByRef error)
{
	global GeneratorScriptsRoot, GeneratorMESRoot, GeneratorSequenceFamily
	error := ""
	root := GeneratorSequenceFamily = "MES" ? GeneratorMESRoot : GeneratorScriptsRoot
	if (GeneratorSequenceFamily != "Normal" && GeneratorSequenceFamily != "MES")
	{
		error := "Select the Normal or MES script family."
		return false
	}
	scriptName := Trim(scriptName)
	outputParent := RTrim(outputParent, "\")
	if (scriptName = "")
	{
		error := "Enter a script name in the main Script Generator window first."
		return false
	}
	if RegExMatch(scriptName, "[\\/:*?""<>|]")
	{
		error := "The script name contains a character Windows cannot use in a file or folder name."
		return false
	}
	if RegExMatch(scriptName, "[\. ]$")
	{
		error := "The script name cannot end with a period or space."
		return false
	}
	reservedName := scriptName
	StringUpper, reservedName, reservedName
	if RegExMatch(reservedName, "^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\..*)?$") || scriptName = "." || scriptName = ".."
	{
		error := "Choose a different script name."
		return false
	}
	if !FileExist(outputParent)
	{
		error := "The selected output folder no longer exists."
		return false
	}
	if !Generator_IsInsideRoot(outputParent, root)
	{
		error := "Choose an output folder inside the selected " . GeneratorSequenceFamily . " script family."
		return false
	}
	destination := outputParent . "\" . scriptName
	destinationAHK := destination . "\" . scriptName . ".ahk"
	if FileExist(destination)
	{
		error := "A folder with that script name already exists in the selected location."
		return false
	}
	return true
}

Generator_InjectEditableBlock(templateText, block, ByRef error)
{
	error := ""
	beginMarker := "; SCRIPT_EDIT_BEGIN_4C4C415253"
	endMarker := "; SCRIPT_EDIT_END_4C4C415253"
	beginPos := InStr(templateText, beginMarker)
	endPos := InStr(templateText, endMarker, false, beginPos + StrLen(beginMarker))
	if (!beginPos || !endPos || endPos <= beginPos)
	{
		error := "The Basic Loop scaffold does not contain the expected editable markers."
		return ""
	}
	prefix := SubStr(templateText, 1, beginPos - 1)
	suffix := SubStr(templateText, endPos + StrLen(endMarker))
	replacement := beginMarker . "`r`n; ================================================================`r`n`r`n" . block . "`r`n; ================================================================`r`n" . endMarker
	return prefix . replacement . suffix
}

; Loads the shared Config scanner and authoritative Creator metadata only.
; Gameplay runtime/input modules are not loaded into this standalone tool.
#Include %A_ScriptDir%\..\Core\LLARS_Config.ahk
#Include %A_ScriptDir%\..\Core\LLARS_CreatorCatalog.ahk



; ================================================================
; |     GENERATED RUNTIME METADATA     -     RUNCOUNT MODEL      |
; ================================================================
; Models only deterministic timing contributions. Unknown custom branches,
; unbounded loops, and unknown probabilities deliberately use the unchanged
; LLARS source parser rather than creating a misleading metadata total.
Generator_RuntimeEmpty()
{
	return {Entries:[], Fallback:false, Reason:""}
}

Generator_RuntimeAdd(ByRef model, kind, section, scope, final, count)
{
	for index, item in model.Entries
	{
		if (item.Kind = kind && item.Section = section && item.Scope = scope && item.Final = final)
		{
			model.Entries[index].Count += count
			return
		}
	}
	model.Entries.Push({Kind:kind, Section:section, Scope:scope, Final:final, Count:count})
}

Generator_RuntimeMerge(ByRef destination, source, multiplier := 1)
{
	for _, item in source.Entries
		Generator_RuntimeAdd(destination, item.Kind, item.Section, item.Scope, item.Final, item.Count * multiplier)
}

Generator_RuntimeEqual(left, right)
{
	if (left.Entries.Length() != right.Entries.Length())
		return false
	for _, a in left.Entries
	{
		found := false
		for _, b in right.Entries
		{
			if (a.Kind = b.Kind && a.Section = b.Section && a.Scope = b.Scope && a.Final = b.Final && a.Count = b.Count)
				found := true
		}
		if !found
			return false
	}
	return true
}

; Locates the matching End Block and optional Else, respecting nested blocks.
Generator_RuntimeFindBlock(start, last, ByRef closing, ByRef alternative)
{
	global GeneratorSequence
	closing := 0
	alternative := 0
	depth := 0
	i := start + 1
	while (i <= last)
	{
		node := GeneratorSequence[i]
		if (node.Kind = "condition" || (node.Kind = "flow" && (node.FlowType = "repeat_n" || node.FlowType = "repeat_forever")))
			depth += 1
		else if (node.Kind = "flow" && node.FlowType = "end_block")
		{
			if (depth = 0)
			{
				closing := i
				return true
			}
			depth -= 1
		}
		else if (node.Kind = "flow" && node.FlowType = "else" && depth = 0)
			alternative := i
		i += 1
	}
	return false
}

Generator_RuntimeAnalyze(first, last)
{
	global GeneratorSequence
	result := Generator_RuntimeEmpty()
	i := first
	while (i <= last)
	{
		node := GeneratorSequence[i]
		if (node.Kind = "custom")
		{
			result.Fallback := true
			result.Reason := "Custom AHK cannot be fully validated or timed."
			return result
		}
		if (node.Kind = "condition" || (node.Kind = "flow" && (node.FlowType = "repeat_n" || node.FlowType = "repeat_forever")))
		{
			if !Generator_RuntimeFindBlock(i, last, closing, alternative)
			{
				result.Fallback := true
				result.Reason := "An incomplete flow block cannot be timed."
				return result
			}
			if (node.Kind = "condition")
			{
				thenLast := alternative ? alternative - 1 : closing - 1
				thenModel := Generator_RuntimeAnalyze(i + 1, thenLast)
				elseModel := alternative ? Generator_RuntimeAnalyze(alternative + 1, closing - 1) : Generator_RuntimeEmpty()
				if (thenModel.Fallback || elseModel.Fallback || !Generator_RuntimeEqual(thenModel, elseModel))
				{
					result.Fallback := true
					result.Reason := "Conditional timing paths differ or depend on unknown branch probability."
					return result
				}
				; Identical branch timing is unconditional regardless of branch probability.
				Generator_RuntimeMerge(result, thenModel)
			}
			else
			{
				if (node.FlowType = "repeat_forever")
				{
					result.Fallback := true
					result.Reason := "Unbounded Repeat Forever has no finite per-loop timing model."
					return result
				}
				if !RegExMatch(node.Count, "^\d+$") || (node.Count + 0 < 1)
				{
					result.Fallback := true
					result.Reason := "Repeat count must be a positive integer."
					return result
				}
				child := Generator_RuntimeAnalyze(i + 1, closing - 1)
				if child.Fallback
					return child
				Generator_RuntimeMerge(result, child, node.Count + 0)
			}
			i := closing + 1
			continue
		}
		if (node.Kind = "flow")
		{
			; Break/Continue make the execution count of later actions dynamic.
			result.Fallback := true
			result.Reason := "Break/Continue or unexpected flow control changes timing dynamically."
			return result
		}
		if (node.Kind = "api" || node.Kind = "value")
		{
			entry := LLARS_CreatorAPIGet(node.Function)
			if !IsObject(entry)
			{
				result.Fallback := true
				result.Reason := "An unknown Creator action cannot be timed."
				return result
			}
			if (entry.RuntimeTiming = "configured_section")
			{
				section := node.Values.HasKey("section") ? Trim(node.Values.section) : ""
				scope := node.Values.HasKey("scope") ? Trim(node.Values.scope) : "script"
				isFinal := node.Values.HasKey("final") ? Trim(node.Values.final) : "false"
				StringLower, isFinal, isFinal
				if (section = "" || (scope != "script" && scope != "global") || (isFinal != "true" && isFinal != "false"))
				{
					result.Fallback := true
					result.Reason := "A configured sleep has unresolved parameters."
					return result
				}
				Generator_RuntimeAdd(result, "section", section, scope, isFinal, 1)
			}
			else if (entry.RuntimeTiming = "shared_random_sleep")
				Generator_RuntimeAdd(result, "random-sleep", "", "", "false", 1)
			else if (entry.Category = "Timing")
			{
				result.Fallback := true
				result.Reason := "The timing catalog does not describe this operation's contribution."
				return result
			}
		}
		i += 1
	}
	return result
}

Generator_BuildRuntimeModel()
{
	global GeneratorSequence
	if !IsObject(GeneratorSequence) || GeneratorSequence.Length() = 0
		return {Emit:false, Entries:[], Reason:"Add timing actions to estimate a RunCount cycle."}
	model := Generator_RuntimeAnalyze(1, GeneratorSequence.Length())
	model.Emit := !model.Fallback && model.Entries.Length() > 0
	if (!model.Emit && model.Reason = "")
		model.Reason := "No modeled timing contribution; use the existing source parser."
	if (model.Emit)
	{
		for _, item in model.Entries
		{
			; The unchanged runtime RandomSleep helper adds one occurrence at a time.
			; Avoid an enormous metadata-building loop at runtime.
			if (item.Kind = "random-sleep" && item.Count > 100)
			{
				model.Emit := false
				model.Reason := "More than 100 optional Random Sleep occurrences; parser fallback avoids an expensive metadata build."
				break
			}
		}
	}
	return model
}

Generator_GenerateRuntimeMetadata(model)
{
	out := "LLARS_RuntimeEstimateMetadata()`r`n{`r`n"
	out .= "`tmodel := LLARS_RuntimeMetadataCreate(" . Generator_QuoteAHK("modeled") . ")`r`n"
	for _, item in model.Entries
	{
		if (item.Kind = "section")
		{
			out .= "`tLLARS_RuntimeMetadataAddSection(model, " . Generator_QuoteAHK(item.Section)
			out .= ", " . item.Count . ", " . Generator_QuoteAHK("both") . ", 1.0, " . Generator_QuoteAHK(item.Scope) . ", " . item.Final . ")`r`n"
		}
		else if (item.Kind = "random-sleep")
		{
			if (item.Count = 1)
				out .= "`tLLARS_RuntimeMetadataAddRandomSleep(model)`r`n"
			else
				out .= "`tLoop, " . item.Count . "`r`n`t`tLLARS_RuntimeMetadataAddRandomSleep(model)`r`n"
		}
	}
	out .= "`treturn model`r`n}`r`n"
	return out
}

Generator_RuntimeDetails(model)
{
	out := "RunCount runtime estimate (per Run(ctx) invocation)`r`n"
	if !model.Emit
		return out . "Confidence: Partial; existing source-parser fallback`r`nReason: " . model.Reason . "`r`nCustom code/unknown conditional branches are not assigned invented probabilities."
	out .= "Source: generated LLARS_RuntimeEstimateMetadata()`r`nConfidence: Modeled (not exact wall-clock execution)`r`n"
	for _, item in model.Entries
	{
		if (item.Kind = "section")
			out .= item.Section . " x" . item.Count . " (" . item.Scope . (item.Final = "true" ? ", final" : "") . ")`r`n"
		else
			out .= "Optional Random Sleep x" . item.Count . " (shared LLARS chance/range)`r`n"
	}
	return out . "Sleep ranges are resolved by RunCount from live configuration. Input and OS scheduling time are not included."
}

Generator_ShowRuntimeEstimate()
{
	model := Generator_BuildRuntimeModel()
	message := Generator_RuntimeDetails(model)
	MsgBox, 64, LLARS Runtime Estimate, %message%
}

#Include %A_ScriptDir%\..\Core\LLARS_CreatorRegistry.ahk
