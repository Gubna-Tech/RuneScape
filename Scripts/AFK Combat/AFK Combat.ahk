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

IfWinNotActive, RuneScape
{
	WinActivate, RuneScape
}

Gosub, AFKCombatSetup
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
		SetTimer, Agro, Off
	return
}

AFKCombat_StopTimers()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done

Log("TIMER COMPLETE", "Timed run reached zero")
Goto, EndMsg

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ============================================================================================
; |     MULTI-TIMER SETUP     -     MULTI-TIMER SETUP     -     MULTI-TIMER SETUP           |
; ============================================================================================

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

AFKCombatSetup:

IniRead, option, Config.ini, Agro, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    IniRead, sa1, Config.ini, Agro, min
    IniRead, sa2, Config.ini, Agro, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Agro, %SleepAmount%
    Log("AGRO TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Agro, hotkey
    Send, {%hk%}
    Log("AGRO HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Agro, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("AGRO ACTIVATED", "Agro timer activated")
}

IniRead, option, Config.ini, AFK, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()
    WinGetPos, RSx, RSy, RSw, RSh, RuneScape
    xmin := RSx
    xmax := RSw + RSx
    ymin := RSy
    ymax := RSh + RSy
    Log("ANTI-AFK WINDOW", "X=" xmin "-" xmax " | Y=" ymin "-" ymax)

    IniRead, sa1, Config.ini, AFK, min
    IniRead, sa2, Config.ini, AFK, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, AFK, %SleepAmount%
    Log("ANTI-AFK TIMER", "Timer=" SleepAmount " ms")

    Random, x, %xmin%, %xmax%
    Random, y, %ymin%, %ymax%
    Random, RandomSpeed, 25, 100
    MouseMove, %x%, %y%, %RandomSpeed%
    Log("ANTI-AFK MOVE", "X=" x " Y=" y " | Speed=" RandomSpeed)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Anti-AFK, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANTI-AFK ACTIVATED", "Anti-AFK timer activated")
}

IniRead, option, Config.ini, Prayer, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Prayer, min
    IniRead, sa2, Config.ini, Prayer, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Prayer, %SleepAmount%
    Log("PRAYER TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Prayer, hotkey
    Send, {%hk%}
    Log("PRAYER HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Prayer, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("PRAYER ACTIVATED", "Prayer timer activated")
}

IniRead, option, Config.ini, Strength, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Strength, min
    IniRead, sa2, Config.ini, Strength, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Strength, %SleepAmount%
    Log("STRENGTH TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Strength, hotkey
    Send, {%hk%}
    Log("STRENGTH HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Strength, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("STRENGTH ACTIVATED", "Strength timer activated")
}

IniRead, option, Config.ini, Attack, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Attack, min
    IniRead, sa2, Config.ini, Attack, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Attack, %SleepAmount%
    Log("ATTACK TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Attack, hotkey
    Send, {%hk%}
    Log("ATTACK HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Attack, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ATTACK ACTIVATED", "Attack timer activated")
}

IniRead, option, Config.ini, Magic, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Magic, min
    IniRead, sa2, Config.ini, Magic, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Magic, %SleepAmount%
    Log("MAGIC TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Magic, hotkey
    Send, {%hk%}
    Log("MAGIC HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Magic, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("MAGIC ACTIVATED", "Magic timer activated")
}

IniRead, option, Config.ini, Ranged, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Ranged, min
    IniRead, sa2, Config.ini, Ranged, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Ranged, %SleepAmount%
    Log("RANGED TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Ranged, hotkey
    Send, {%hk%}
    Log("RANGED HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Range, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("RANGED ACTIVATED", "Ranged timer activated")
}

IniRead, option, Config.ini, Overload, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Overload, min
    IniRead, sa2, Config.ini, Overload, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Overload, %SleepAmount%
    Log("OVERLOAD TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Overload, hotkey
    Send, {%hk%}
    Log("OVERLOAD HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Overload, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("OVERLOAD ACTIVATED", "Overload timer activated")
}

IniRead, option, Config.ini, Warmaster, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Warmaster, min
    IniRead, sa2, Config.ini, Warmaster, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Warmaster, %SleepAmount%
    Log("WARMASTER TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Warmaster, hotkey
    Send, {%hk%}
    Log("WARMASTER HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Warmaster, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("WARMASTER ACTIVATED", "Warmaster timer activated")
}

IniRead, option, Config.ini, Antifire, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Antifire, min
    IniRead, sa2, Config.ini, Antifire, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Antifire, %SleepAmount%
    Log("ANTIFIRE TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Antifire, hotkey
    Send, {%hk%}
    Log("ANTIFIRE HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Antifire, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANTIFIRE ACTIVATED", "Antifire timer activated")
}

IniRead, option, Config.ini, Antipoison, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Antipoison, min
    IniRead, sa2, Config.ini, Antipoison, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Antipoison, %SleepAmount%
    Log("ANTIPOISON TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Antipoison, hotkey
    Send, {%hk%}
    Log("ANTIPOISON HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Antipoison, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANTIPOISON ACTIVATED", "Antipoison timer activated")
}

IniRead, option, Config.ini, Weapon Poison, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Weapon Poison, min
    IniRead, sa2, Config.ini, Weapon Poison, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, WeaponPoison, %SleepAmount%
    Log("WEAPON POISON TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Weapon Poison, hotkey
    Send, {%hk%}
    Log("WEAPON POISON HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Weapon Poison, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("WEAPON POISON ACTIVATED", "Weapon Poison timer activated")
}

IniRead, option, Config.ini, Animate Dead, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Animate Dead, min
    IniRead, sa2, Config.ini, Animate Dead, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, AnimateDead, %SleepAmount%
    Log("ANIMATE DEAD TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Animate Dead, hotkey
    Send, {%hk%}
    Log("ANIMATE DEAD HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Animate Dead, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANIMATE DEAD ACTIVATED", "Animate Dead timer activated")
}

IniRead, option, Config.ini, Vecna Skull, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Vecna Skull, min
    IniRead, sa2, Config.ini, Vecna Skull, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Vecna, %SleepAmount%
    Log("VECNA TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Vecna Skull, hotkey
    Send, {%hk%}
    Log("VECNA HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Vecna Skull, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("VECNA ACTIVATED", "Vecna Skull timer activated")
}

IniRead, option, Config.ini, Ancient Elven Ritual Shard, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Ancient Elven Ritual Shard, min
    IniRead, sa2, Config.ini, Ancient Elven Ritual Shard, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Shard, %SleepAmount%
    Log("SHARD TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Ancient Elven Ritual Shard, hotkey
    Send, {%hk%}
    Log("SHARD HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Ancient Elven Ritual Shard, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("SHARD ACTIVATED", "Ancient Elven Ritual Shard timer activated")
}

IniRead, option, Config.ini, Incense Sticks, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Incense Sticks, min
    IniRead, sa2, Config.ini, Incense Sticks, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, IncenseSticks, %SleepAmount%
    Log("INCENSE STICKS TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Incense Sticks, hotkey
    Send, {%hk%}
    Log("INCENSE STICKS HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Incense Sticks, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("INCENSE STICKS ACTIVATED", "Incense Sticks timer activated")
}

IniRead, option, Config.ini, Prayer Powder, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Prayer Powder, min
    IniRead, sa2, Config.ini, Prayer Powder, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, PrayerP, %SleepAmount%
    Log("PRAYER POWDER TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Prayer Powder, hotkey
    Send, {%hk%}
    Log("PRAYER POWDER HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Prayer Powder, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("PRAYER POWDER ACTIVATED", "Prayer Powder timer activated")
}

IniRead, option, Config.ini, Summon, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Summon, min
    IniRead, sa2, Config.ini, Summon, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Summon, %SleepAmount%
    Log("SUMMON TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Summon, hotkey
    Send, {%hk%}
    Log("SUMMON HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Familiar Summoned, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("SUMMON ACTIVATED", "Summon timer activated")
}

IniRead, option, Config.ini, Saradomin Brew, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Saradomin Brew, min
    IniRead, sa2, Config.ini, Saradomin Brew, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, SaraBrew, %SleepAmount%
    Log("SARA BREW TIMER", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Saradomin Brew, hotkey
    Send, {%hk%}
    Log("SARA BREW HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Saradomin Brew Dose Consumed, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("SARA BREW ACTIVATED", "Saradomin Brew timer activated")
}

IniRead, option, Config.ini, Loot, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Loot, min
    IniRead, sa2, Config.ini, Loot, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Loot, %SleepAmount%
    Log("LOOT TIMER", "Timer=" SleepAmount " ms")

    Send, {Space}
    Log("LOOT SPACE", "Sent {Space}")

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Auto-Loot Activated, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("LOOT ACTIVATED", "Auto-Loot timer activated")
}

IniRead, option, Config.ini, Cannon Restock, option
StringLower, option, option

If (option = "true")
{
	IfWinNotActive, RuneScape
	{
		WinActivate, RuneScape
		Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
	}

	DisableButton()

	IniRead, sa1, Config.ini, Cannon Restock, min
	IniRead, sa2, Config.ini, Cannon Restock, max
	Random, SleepAmount, %sa1%, %sa2%
	SetTimer, CannonRestock, %SleepAmount%
	Log("CANNON RESTOCK TIMER", "Timer=" SleepAmount " ms")

	IniRead, x1, Config.ini, Cannon Restock, xmin
	IniRead, x2, Config.ini, Cannon Restock, xmax
	IniRead, y1, Config.ini, Cannon Restock, ymin
	IniRead, y2, Config.ini, Cannon Restock, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CANNON RESTOCK", "X=" x " Y=" y)

	Loop, 100
	{
		MouseGetPos, xm, ym
		ToolTip, Cannon Restock Activated, (xm+25), (ym+25), 1
		Sleep, 25
	}

	ToolTip
	Log("CANNON RESTOCK ACTIVATED", "Cannon Restock timer activated")
}

IniRead, option, Config.ini, Binding Contract, option
StringLower, option, option

If (option = "true")
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Binding Contract, min
    IniRead, sa2, Config.ini, Binding Contract, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, BindingContract, %SleepAmount%
    Log("BINDING CONTRACT TIMER", "Timer=" SleepAmount " ms")
}

return

; ============================================================================================
; |     MULTI-TIMER ACTIONS     -     MULTI-TIMER ACTIONS     -     MULTI-TIMER ACTIONS     |
; ============================================================================================

Agro:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Agro, min
    IniRead, sa2, Config.ini, Agro, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Agro, %SleepAmount%
    Log("AGRO TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Agro, hotkey
    Send, {%hk%}
    Log("AGRO HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Agro, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("AGRO ACTIVATED", "Agro action completed")
}
return

AFK:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()
    WinGetPos, RSx, RSy, RSw, RSh, RuneScape
    xmin := RSx
    xmax := RSw + RSx
    ymin := RSy
    ymax := RSh + RSy
    Log("ANTI-AFK WINDOW", "X=" xmin "-" xmax " | Y=" ymin "-" ymax)

    IniRead, sa1, Config.ini, AFK, min
    IniRead, sa2, Config.ini, AFK, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, AFK, %SleepAmount%
    Log("ANTI-AFK TIMER RESET", "Timer=" SleepAmount " ms")

    Random, x, %xmin%, %xmax%
    Random, y, %ymin%, %ymax%
    Random, RandomSpeed, 25, 100
    MouseMove, %x%, %y%, %RandomSpeed%
    Log("ANTI-AFK MOVE", "X=" x " Y=" y " | Speed=" RandomSpeed)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Anti-AFK, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANTI-AFK ACTIVATED", "Anti-AFK action completed")
}
return

Strength:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Strength, min
    IniRead, sa2, Config.ini, Strength, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Strength, %SleepAmount%
    Log("STRENGTH TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Strength, hotkey
    Send, {%hk%}
    Log("STRENGTH HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Strength, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("STRENGTH ACTIVATED", "Strength action completed")
}
return

Attack:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Attack, min
    IniRead, sa2, Config.ini, Attack, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Attack, %SleepAmount%
    Log("ATTACK TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Attack, hotkey
    Send, {%hk%}
    Log("ATTACK HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Attack, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ATTACK ACTIVATED", "Attack action completed")
}
return

Magic:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Magic, min
    IniRead, sa2, Config.ini, Magic, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Magic, %SleepAmount%
    Log("MAGIC TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Magic, hotkey
    Send, {%hk%}
    Log("MAGIC HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Magic, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("MAGIC ACTIVATED", "Magic action completed")
}
return

Ranged:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Ranged, min
    IniRead, sa2, Config.ini, Ranged, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Ranged, %SleepAmount%
    Log("RANGED TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Ranged, hotkey
    Send, {%hk%}
    Log("RANGED HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Range, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("RANGED ACTIVATED", "Ranged action completed")
}
return

Overload:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Overload, min
    IniRead, sa2, Config.ini, Overload, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Overload, %SleepAmount%
    Log("OVERLOAD TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Overload, hotkey
    Send, {%hk%}
    Log("OVERLOAD HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Overload, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("OVERLOAD ACTIVATED", "Overload action completed")
}
return

Warmaster:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Warmaster, min
    IniRead, sa2, Config.ini, Warmaster, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Warmaster, %SleepAmount%
    Log("WARMASTER TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Warmaster, hotkey
    Send, {%hk%}
    Log("WARMASTER HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Warmaster, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("WARMASTER ACTIVATED", "Warmaster action completed")
}
return

Antifire:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Antifire, min
    IniRead, sa2, Config.ini, Antifire, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Antifire, %SleepAmount%
    Log("ANTIFIRE TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Antifire, hotkey
    Send, {%hk%}
    Log("ANTIFIRE HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Antifire, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANTIFIRE ACTIVATED", "Antifire action completed")
}
return

Antipoison:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Antipoison, min
    IniRead, sa2, Config.ini, Antipoison, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Antipoison, %SleepAmount%
    Log("ANTIPOISON TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Antipoison, hotkey
    Send, {%hk%}
    Log("ANTIPOISON HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Antipoison, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANTIPOISON ACTIVATED", "Antipoison action completed")
}
return

Prayer:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Prayer, min
    IniRead, sa2, Config.ini, Prayer, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Prayer, %SleepAmount%
    Log("PRAYER TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Prayer, hotkey
    Send, {%hk%}
    Log("PRAYER HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Prayer, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("PRAYER ACTIVATED", "Prayer action completed")
}
return

WeaponPoison:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Weapon Poison, min
    IniRead, sa2, Config.ini, Weapon Poison, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, WeaponPoison, %SleepAmount%
    Log("WEAPON POISON TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Weapon Poison, hotkey
    Send, {%hk%}
    Log("WEAPON POISON HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Weapon Poison, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("WEAPON POISON ACTIVATED", "Weapon Poison action completed")
}
return

AnimateDead:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Animate Dead, min
    IniRead, sa2, Config.ini, Animate Dead, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, AnimateDead, %SleepAmount%
    Log("ANIMATE DEAD TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Animate Dead, hotkey
    Send, {%hk%}
    Log("ANIMATE DEAD HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Animate Dead, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("ANIMATE DEAD ACTIVATED", "Animate Dead action completed")
}
return

Vecna:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Vecna Skull, min
    IniRead, sa2, Config.ini, Vecna Skull, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Vecna, %SleepAmount%
    Log("VECNA TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Vecna Skull, hotkey
    Send, {%hk%}
    Log("VECNA HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Vecna Skull, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("VECNA ACTIVATED", "Vecna Skull action completed")
}
return

Shard:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Ancient Elven Ritual Shard, min
    IniRead, sa2, Config.ini, Ancient Elven Ritual Shard, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Shard, %SleepAmount%
    Log("SHARD TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Ancient Elven Ritual Shard, hotkey
    Send, {%hk%}
    Log("SHARD HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Ancient Elven Ritual Shard, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("SHARD ACTIVATED", "Ancient Elven Ritual Shard action completed")
}
return

IncenseSticks:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Incense Sticks, min
    IniRead, sa2, Config.ini, Incense Sticks, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, IncenseSticks, %SleepAmount%
    Log("INCENSE STICKS TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Incense Sticks, hotkey
    Send, {%hk%}
    Log("INCENSE STICKS HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Incense Sticks, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("INCENSE STICKS ACTIVATED", "Incense Sticks action completed")
}
return

PrayerP:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Prayer Powder, min
    IniRead, sa2, Config.ini, Prayer Powder, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, PrayerP, %SleepAmount%
    Log("PRAYER POWDER TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Prayer Powder, hotkey
    Send, {%hk%}
    Log("PRAYER POWDER HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Activated Prayer Powder, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("PRAYER POWDER ACTIVATED", "Prayer Powder action completed")
}
return

Summon:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Summon, min
    IniRead, sa2, Config.ini, Summon, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Summon, %SleepAmount%
    Log("SUMMON TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Summon, hotkey
    Send, {%hk%}
    Log("SUMMON HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Familiar Summoned, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("SUMMON ACTIVATED", "Summon action completed")
}
return

SaraBrew:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Saradomin Brew, min
    IniRead, sa2, Config.ini, Saradomin Brew, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, SaraBrew, %SleepAmount%
    Log("SARA BREW TIMER RESET", "Timer=" SleepAmount " ms")

    IniRead, hk, Config.ini, Saradomin Brew, hotkey
    Send, {%hk%}
    Log("SARA BREW HOTKEY", "Hotkey=" hk)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Saradomin Brew Dose Consumed, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("SARA BREW ACTIVATED", "Saradomin Brew action completed")
}
return

Loot:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
    IfWinNotActive, RuneScape
    {
        WinActivate, RuneScape
        Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
    }

    DisableButton()

    IniRead, sa1, Config.ini, Loot, min
    IniRead, sa2, Config.ini, Loot, max
    Random, SleepAmount, %sa1%, %sa2%
    SetTimer, Loot, %SleepAmount%
    Log("LOOT TIMER RESET", "Timer=" SleepAmount " ms")

    Send, {Space}
    Log("LOOT SPACE", "Sent {Space}")

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, Auto-Loot Activated, (xm+25), (ym+25), 1
        Sleep, 25
    }

    ToolTip
    Log("LOOT ACTIVATED", "Auto-Loot action completed")
}
return

CannonRestock:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
	IfWinNotActive, RuneScape
	{
		WinActivate, RuneScape
		Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
	}

	DisableButton()

	IniRead, sa1, Config.ini, Cannon Restock, min
	IniRead, sa2, Config.ini, Cannon Restock, max
	Random, SleepAmount, %sa1%, %sa2%
	SetTimer, CannonRestock, %SleepAmount%
	Log("CANNON RESTOCK TIMER RESET", "Timer=" SleepAmount " ms")

	IniRead, x1, Config.ini, Cannon Restock, xmin
	IniRead, x2, Config.ini, Cannon Restock, xmax
	IniRead, y1, Config.ini, Cannon Restock, ymin
	IniRead, y2, Config.ini, Cannon Restock, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CANNON RESTOCK", "X=" x " Y=" y)

	Loop, 100
	{
		MouseGetPos, xm, ym
		ToolTip, Cannon Restock Activated, (xm+25), (ym+25), 1
		Sleep, 25
	}

	ToolTip
	Log("CANNON RESTOCK ACTIVATED", "Cannon Restock action completed")
}
return

BindingContract:
GuiControl,,ScriptBlue, %scriptname%
GuiControl,,State3, Running
{
	IfWinNotActive, RuneScape
	{
		WinActivate, RuneScape
		Log("WINDOW ACTIVATION", "RuneScape was not active and was activated")
	}

	DisableButton()

	IniRead, sa1, Config.ini, Binding Contract, min
	IniRead, sa2, Config.ini, Binding Contract, max
	Random, SleepAmount, %sa1%, %sa2%
	SetTimer, BindingContract, %SleepAmount%
	Log("BINDING CONTRACT TIMER RESET", "Timer=" SleepAmount " ms")

	IniRead, x1, Config.ini, Notepaper - Binding Contract, xmin
	IniRead, x2, Config.ini, Notepaper - Binding Contract, xmax
	IniRead, y1, Config.ini, Notepaper - Binding Contract, ymin
	IniRead, y2, Config.ini, Notepaper - Binding Contract, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("NOTE PAPER - BINDING CONTRACT", "X=" x " Y=" y)

	IniRead, sa1, Config.ini, Sleep Brief, min
	IniRead, sa2, Config.ini, Sleep Brief, max
	Random, SleepAmount, %sa1%, %sa2%
	Sleep, %SleepAmount%
	Log("SLEEP BRIEF WAIT", "Sleep completed: " SleepAmount " ms")

	IniRead, x1, Config.ini, Contract - Binding Contract, xmin
	IniRead, x2, Config.ini, Contract - Binding Contract, xmax
	IniRead, y1, Config.ini, Contract - Binding Contract, ymin
	IniRead, y2, Config.ini, Contract - Binding Contract, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	NaturalClick(x, y)
	Log("CONTRACT - BINDING CONTRACT", "X=" x " Y=" y)

	Loop, 100
	{
		MouseGetPos, xm, ym
		ToolTip, Noted Binding Contract, (xm+25), (ym+25), 1
		Sleep, 25
	}

	ToolTip
	Log("BINDING CONTRACT", "Binding Contract action completed")
}
return

; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================
; Stops every timer owned by AFK Combat. Core never references these
; script-specific timer labels.
AFKCombat_StopTimers()
{
	SetTimer, Countdown, Off
	SetTimer, Agro, Off
	SetTimer, AFK, Off
	SetTimer, AnimateDead, Off
	SetTimer, Antifire, Off
	SetTimer, Antipoison, Off
	SetTimer, Attack, Off
	SetTimer, Magic, Off
	SetTimer, Overload, Off
	SetTimer, Prayer, Off
	SetTimer, PrayerP, Off
	SetTimer, Ranged, Off
	SetTimer, Strength, Off
	SetTimer, Warmaster, Off
	SetTimer, WeaponPoison, Off
	SetTimer, Vecna, Off
	SetTimer, Shard, Off
	SetTimer, IncenseSticks, Off
	SetTimer, SaraBrew, Off
	SetTimer, Summon, Off
	SetTimer, Loot, Off
	SetTimer, CannonRestock, Off
	SetTimer, BindingContract, Off
}

EndMsg:

hours := Floor(timeToRunMinutes / 60)
minutes := Mod(timeToRunMinutes, 60)

AFKCombat_StopTimers()
LLARS_EndTimerRun()
Logout()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done

Log("COMPLETE", "Script completed normally | Total time: " hours "h " minutes "m")

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

; Automatically searches upward for the LLARS Core folder.
#Include *i %A_ScriptDir%\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS.ahk

; Automatically searches upward for the LLARS label library.
#Include *i %A_ScriptDir%\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
#Include *i %A_ScriptDir%\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\..\Core\LLARS_Labels.ahk
