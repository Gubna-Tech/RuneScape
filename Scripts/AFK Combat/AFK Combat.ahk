; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
SetBatchLines, -1

LLARS_SCRIPT_TYPE := "MultiTimer"

if !LLARS_FrameworkAvailable()
	LLARS_FrameworkError()

LLARS_Initialize()

return

Start:

if (!LLARS_StartTimerRun())
	return

SetTimer, Countdown, 1000
AFKCombatSetup()
return

; =====================================================================
; |     TIMER COUNTDOWN     -     TIMER COUNTDOWN     -     TIMER     |
; =====================================================================

Countdown:
DisableButton()
RemainingTime := endTime - A_TickCount

if (RemainingTime > 0)
{
	GuiControl,, TimerCount, % LLARS_TimerRemainingText(RemainingTime)

	; Avoid using another aggression dose when the run is nearly finished.
	if (RemainingTime <= 360000)
		AFKCombat_StopTimer("Agro")
	return
}

AFKCombat_StopTimers()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done

Goto, EndMsg

; ============================================================================================
; |     MULTI-TIMER SETUP     -     MULTI-TIMER SETUP     -     MULTI-TIMER SETUP           |
; ============================================================================================

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

AFKCombatSetup()
{
    global AFKCombatTimers
    AFKCombatTimers := {}

    AFKCombat_SetupHotkey("Agro", "Activated Agro")
    AFKCombat_SetupMouseMove()
    AFKCombat_SetupHotkey("Prayer", "Activated Prayer")
    AFKCombat_SetupHotkey("Strength", "Activated Strength")
    AFKCombat_SetupHotkey("Attack", "Activated Attack")
    AFKCombat_SetupHotkey("Magic", "Activated Magic")
    AFKCombat_SetupHotkey("Ranged", "Activated Range")
    AFKCombat_SetupHotkey("Overload", "Activated Overload")
    AFKCombat_SetupHotkey("Warmaster", "Activated Warmaster")
    AFKCombat_SetupHotkey("Antifire", "Activated Antifire")
    AFKCombat_SetupHotkey("Antipoison", "Activated Antipoison")
    AFKCombat_SetupHotkey("Weapon Poison", "Activated Weapon Poison")
    AFKCombat_SetupHotkey("Animate Dead", "Activated Animate Dead")
    AFKCombat_SetupHotkey("Vecna Skull", "Activated Vecna Skull")
    AFKCombat_SetupHotkey("Ancient Elven Ritual Shard", "Activated Ancient Elven Ritual Shard")
    AFKCombat_SetupHotkey("Incense Sticks", "Activated Incense Sticks")
    AFKCombat_SetupHotkey("Prayer Powder", "Activated Prayer Powder")
    AFKCombat_SetupHotkey("Summon", "Familiar Summoned")
    AFKCombat_SetupHotkey("Saradomin Brew", "Saradomin Brew Dose Consumed")
    AFKCombat_SetupLoot()
    AFKCombat_SetupCannon()
    AFKCombat_SetupBindingContract()
}

AFKCombat_SetupHotkey(section, tooltipText)
{
    if !LLARS_ConfigReadBool(section)
        return

    AFKCombat_ScheduleHotkey(section, tooltipText)
    LLARS_SetStatus("Fighting", section)
    LLARS_PressHotkey(section)
    AFKCombat_ShowTooltip(tooltipText)
}

AFKCombat_ScheduleHotkey(section, tooltipText)
{
    global AFKCombatTimers
    AFKCombatTimers[section] := LLARS_TimerOnce(section, Func("AFKCombat_HotkeyTimer").Bind(section, tooltipText))
}

AFKCombat_HotkeyTimer(section, tooltipText)
{
    if !LLARS_RunActive()
        return

    ; The original labels randomized and reset the next timer before performing the action.
    AFKCombat_ScheduleHotkey(section, tooltipText)
    DisableButton()
    LLARS_SetStatus("Fighting", section)
    LLARS_PressHotkey(section)
    AFKCombat_ShowTooltip(tooltipText)
}

AFKCombat_SetupMouseMove()
{
    if !LLARS_ConfigReadBool("AFK")
        return

    AFKCombat_ScheduleMouseMove()
    AFKCombat_MouseMoveAction()
}

AFKCombat_ScheduleMouseMove()
{
    global AFKCombatTimers
    AFKCombatTimers["AFK"] := LLARS_TimerOnce("AFK", Func("AFKCombat_MouseMoveTimer"))
}

AFKCombat_MouseMoveTimer()
{
    if !LLARS_RunActive()
        return

    AFKCombat_ScheduleMouseMove()
    AFKCombat_MouseMoveAction()
}

AFKCombat_MouseMoveAction()
{
    global LLARS_RunRuneScapeHwnd

    LLARS_SetStatus("Moving", "Anti-AFK")
    DisableButton()
    if !LLARS_WaitForRuneScape("Anti-AFK MouseMove")
        return

    ; LLARS owns client-coordinate mouse mode.
    VarSetCapacity(clientRect, 16, 0)
    if !DllCall("GetClientRect", "Ptr", LLARS_RunRuneScapeHwnd, "Ptr", &clientRect)
        return
    clientW := NumGet(clientRect, 8, "Int")
    clientH := NumGet(clientRect, 12, "Int")
    if (clientW <= 1 || clientH <= 1)
        return

    maxX := clientW - 1
    maxY := clientH - 1
    Random, x, 0, %maxX%
    Random, y, 0, %maxY%
    Random, RandomSpeed, 25, 100
    if !LLARS_WaitForRuneScape("Anti-AFK MouseMove")
        return
    MouseMove, %x%, %y%, %RandomSpeed%
    AFKCombat_ShowTooltip("Activated Anti-AFK")
}

AFKCombat_SetupLoot()
{
    if !LLARS_ConfigReadBool("Loot")
        return

    AFKCombat_ScheduleLoot()
    LLARS_SetStatus("Looting", "Auto-Loot")
    LLARS_PressKey("Space")
    AFKCombat_ShowTooltip("Auto-Loot Activated")
}

AFKCombat_ScheduleLoot()
{
    global AFKCombatTimers
    AFKCombatTimers["Loot"] := LLARS_TimerOnce("Loot", Func("AFKCombat_LootTimer"))
}

AFKCombat_LootTimer()
{
    if !LLARS_RunActive()
        return

    AFKCombat_ScheduleLoot()
    DisableButton()
    LLARS_SetStatus("Looting", "Auto-Loot")
    LLARS_PressKey("Space")
    AFKCombat_ShowTooltip("Auto-Loot Activated")
}

AFKCombat_SetupCannon()
{
    if !LLARS_ConfigReadBool("Cannon Restock")
        return

    AFKCombat_ScheduleCannon()
    LLARS_SetStatus("Restocking", "Cannon")
    LLARS_Click("Cannon Restock")
    AFKCombat_ShowTooltip("Cannon Restock Activated")
}

AFKCombat_ScheduleCannon()
{
    global AFKCombatTimers
    AFKCombatTimers["Cannon Restock"] := LLARS_TimerOnce("Cannon Restock", Func("AFKCombat_CannonTimer"))
}

AFKCombat_CannonTimer()
{
    if !LLARS_RunActive()
        return

    AFKCombat_ScheduleCannon()
    DisableButton()
    LLARS_SetStatus("Restocking", "Cannon")
    LLARS_Click("Cannon Restock")
    AFKCombat_ShowTooltip("Cannon Restock Activated")
}

AFKCombat_SetupBindingContract()
{
    ; The old script schedules this option at startup but does not immediately consume/notepaper a contract.
    if !LLARS_ConfigReadBool("Binding Contract")
        return

    AFKCombat_ScheduleBindingContract()
}

AFKCombat_ScheduleBindingContract()
{
    global AFKCombatTimers
    AFKCombatTimers["Binding Contract"] := LLARS_TimerOnce("Binding Contract", Func("AFKCombat_BindingContractTimer"))
}

AFKCombat_BindingContractTimer()
{
    if !LLARS_RunActive()
        return

    AFKCombat_ScheduleBindingContract()
    DisableButton()
    LLARS_SetStatus("Noting", "Binding Contract")
    LLARS_Click("Notepaper - Binding Contract")
    LLARS_Sleep("Sleep Brief")
    if !LLARS_RunActive()
        return
    LLARS_Click("Contract - Binding Contract")
    AFKCombat_ShowTooltip("Noted Binding Contract")
}

AFKCombat_ShowTooltip(text)
{
    global scriptname

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, %text%, (xm+25), (ym+25), 1
        Sleep, 25
    }
    ToolTip
}

AFKCombat_StopTimer(section)
{
    global AFKCombatTimers

    if (!IsObject(AFKCombatTimers) || !AFKCombatTimers.HasKey(section))
        return

    timerID := AFKCombatTimers[section]
    if (timerID)
        LLARS_TimerStop(timerID)
    AFKCombatTimers[section] := 0
}

; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================
; Stops every creator timer owned by AFK Combat.
AFKCombat_StopTimers()
{
	global AFKCombatTimers
	SetTimer, Countdown, Off
	LLARS_TimerStopAll()
	AFKCombatTimers := {}
}

EndMsg:

hours := Floor(timeToRunMinutes / 60)
minutes := Mod(timeToRunMinutes, 60)

AFKCombat_StopTimers()
LLARS_EndTimerRun()
Logout()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done


SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nTotal time: %hours%h %minutes%m
return

LLARS_FrameworkAvailable()
{
	dir := A_ScriptDir

	Loop, 12
	{
		if (FileExist(dir . "\Core\LLARS.ahk") && FileExist(dir . "\LLARS Config.ini"))
			return true

		SplitPath, dir,, parentDir

		if (parentDir = "" || parentDir = dir)
			break

		dir := parentDir
	}

	return false
}

LLARS_FrameworkError()
{
	Menu, Tray, NoIcon

	MsgBox, 4112, LLARS Error, The complete LLARS project could not be found.`n`nIf you opened this script from a ZIP, RAR, or 7Z archive, extract the entire LLARS folder before running it.

	ExitApp
}

; Automatically searches upward for the LLARS Core bootstrap.
#Include *i %A_ScriptDir%\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_ScriptBootstrap.ahk
