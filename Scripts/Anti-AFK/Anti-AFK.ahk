; ================================================================
; |     AHK CONFIG     -     AHK CONFIG     -     AHK CONFIG     |
; ================================================================
#Requires AutoHotkey v1.1.37.02
#SingleInstance Force
#Persistent
#InstallKeybdHook
#InstallMouseHook
SetBatchLines, -1

LLARS_SCRIPT_TYPE := "Timer"

if !LLARS_FrameworkAvailable()
	LLARS_FrameworkError()

LLARS_Initialize()

return

Start:

if (!LLARS_StartTimerRun())
	return

SetTimer, Countdown, 1000

LLARS_DeveloperAntiAFKAction("ANTI-AFK", "Anti-AFK system started")
AntiAFKTimerID := LLARS_TimerOnce("AFK", Func("AntiAFK"))

return

; =====================================================================
; |     TIMER COUNTDOWN     -     TIMER COUNTDOWN     -     TIMER     |
; =====================================================================

Countdown:
RemainingTime := endTime - A_TickCount

if (RemainingTime > 0)
{
	GuiControl,, TimerCount, % LLARS_TimerRemainingText(RemainingTime)
	return
}

GuiControl,, TimerCount, Done
GuiControl,, State3, Done
SetTimer, Countdown, Off

Goto, EndMsg

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

AntiAFK()
{
    global AntiAFKTimerID, LLARS_RunRuneScapeHwnd, scriptname

    if !LLARS_RunActive()
        return

    ; Preserve the old cadence by scheduling the next random activation before carrying out this movement/tooltip cycle.
    AntiAFKTimerID := LLARS_TimerOnce("AFK", Func("AntiAFK"))

    if !LLARS_WaitForRuneScape("Anti-AFK MouseMove")
        return

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
    LLARS_SetStatus("Moving", "Anti-AFK")
    if !AntiAFKNaturalClick(x, y)
        return

    LLARS_DeveloperAntiAFKAction("ANTI-AFK MOVE", "Mouse moved | X=" x " Y=" y)

    Loop, 100
    {
        MouseGetPos, xm, ym
        ToolTip, %scriptname% - Activated Anti-AFK, xm+25, ym+25, 1
        Sleep, 25
    }
    ToolTip
    LLARS_DeveloperAntiAFKAction("ANTI-AFK", "Anti-AFK activation completed")
}

; ================================================================
; SCRIPT_EDIT_END_4C4C415253
; ================================================================

; ==================================================================
; |     >>> END SCRIPT EDITING <<<     >>> END SCRIPT EDITING <<<  |
; ==================================================================

EndMsg:

hours := timeToRunMinutes // 60
minutes := Mod(timeToRunMinutes, 60)
SetTimer, Countdown, Off
LLARS_TimerStopAll()
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
