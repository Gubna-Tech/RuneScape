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

IfWinNotActive, RuneScape
{
	WinActivate, RuneScape
}

Log("ANTI-AFK", "Anti-AFK system started")

WinGetPos, RSx, RSy, RSw, RSh, RuneScape
xmin := RSx
xmax := RSw + RSx
ymin := RSy
ymax := RSh + RSy

IniRead, sa1, Config.ini, AFK, min
IniRead, sa2, Config.ini, AFK, max
Random, SleepAmount, %sa1%, %sa2%
SetTimer, AntiAFK, %SleepAmount%

Log("ANTI-AFK TIMER", "Initial AFK delay randomized between " sa1 " and " sa2 " ms | Next activation in " SleepAmount " ms")

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

Log("TIMER COMPLETE", "Timed run reached zero")
Goto, EndMsg

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

AntiAFK:
if (!LLARS_RUNNING)
	return

GuiControl,, ScriptBlue, %scriptname%
GuiControl,, State3, Running

Log("ANTI-AFK", "Anti-AFK activation triggered")

IfWinNotActive, RuneScape
{
	WinActivate, RuneScape
	Log("ANTI-AFK WINDOW", "RuneScape was not active - window activated")
}

WinGetPos, RSx, RSy, RSw, RSh, RuneScape
xmin := RSx
xmax := RSw + RSx
ymin := RSy
ymax := RSh + RSy

IniRead, sa1, Config.ini, AFK, min
IniRead, sa2, Config.ini, AFK, max
Random, SleepAmount, %sa1%, %sa2%
SetTimer, AntiAFK, %SleepAmount%

Log("ANTI-AFK TIMER", "Next AFK activation randomized between " sa1 " and " sa2 " ms | Next activation in " SleepAmount " ms")

Random, x, %xmin%, %xmax%
Random, y, %ymin%, %ymax%

AntiAFKNaturalMove(x, y)
Log("ANTI-AFK MOVE", "Mouse moved | X=" x " Y=" y)

Loop, 100
{
	MouseGetPos, xm, ym
	ToolTip, %scriptname% - Activated Anti-AFK, xm+25, ym+25, 1
	Sleep, 25
}
ToolTip

Log("ANTI-AFK", "Anti-AFK activation completed")

return

AntiAFKNaturalMove(x, y)
{
	MouseGetPos, startX, startY
	dx := x - startX
	dy := y - startY
	distance := Sqrt((dx * dx) + (dy * dy))

	if (distance <= 2)
	{
		Random, pause, 50, 120
		Sleep, %pause%
		MouseMove, %x%, %y%, 0
		return
	}

	Random, speed, 2500, 3500
	duration := (distance / speed) * 1000

	if (duration < 180)
		duration := 180

	if (duration > 900)
		duration := 900
	steps := Round(distance / 6)

	if (steps < 15)
		steps := 15

	if (steps > 100)
		steps := 100
	rawSteps := Round(distance / 3)

	if (rawSteps < 60)
		rawSteps := 60

	if (rawSteps > 300)
		rawSteps := 300
	perpX := -dy / distance
	perpY := dx / distance
	curveLimit := distance * 0.14

	if (curveLimit < 5)
		curveLimit := 5

	if (curveLimit > 85)
		curveLimit := 85
	Random, curveBase, -100, 100
	curveBase := curveBase * curveLimit / 100
	Random, curveVariation1, -25, 25
	Random, curveVariation2, -25, 25
	curveAmount1 := curveBase + (curveLimit * curveVariation1 / 100)
	curveAmount2 := curveBase + (curveLimit * curveVariation2 / 100)

	if (curveAmount1 > curveLimit)
		curveAmount1 := curveLimit

	if (curveAmount1 < -curveLimit)
		curveAmount1 := -curveLimit

	if (curveAmount2 > curveLimit)
		curveAmount2 := curveLimit

	if (curveAmount2 < -curveLimit)
		curveAmount2 := -curveLimit
	Random, cp1Percent, 25, 38
	Random, cp2Percent, 62, 75
	cp1X := startX + (dx * cp1Percent / 100)
	cp1Y := startY + (dy * cp1Percent / 100)
	cp2X := startX + (dx * cp2Percent / 100)
	cp2Y := startY + (dy * cp2Percent / 100)
	cp1X += perpX * curveAmount1
	cp1Y += perpY * curveAmount1
	cp2X += perpX * curveAmount2
	cp2Y += perpY * curveAmount2
	Random, seedX, 1, 100000
	Random, seedY, 1, 100000
	noiseAmount := distance * 0.012

	if (noiseAmount < 0.75)
		noiseAmount := 0.75

	if (noiseAmount > 6)
		noiseAmount := 6
	points := []
	lengths := []
	totalLength := 0
	previousX := startX
	previousY := startY
	points.Push({x:startX, y:startY})
	lengths.Push(0)
	previousNoise := 0

	Loop, %rawSteps%
	{
		t := A_Index / rawSteps
		ease := t
		inv := 1 - ease
		currentX := (inv * inv * inv * startX)
		currentX += (3 * inv * inv * ease * cp1X)
		currentX += (3 * inv * ease * ease * cp2X)
		currentX += (ease * ease * ease * x)
		currentY := (inv * inv * inv * startY)
		currentY += (3 * inv * inv * ease * cp1Y)
		currentY += (3 * inv * ease * ease * cp2Y)
		currentY += (ease * ease * ease * y)
		nx := AntiAFKNaturalNoise(seedX, t)
		ny := AntiAFKNaturalNoise(seedY, t + 13.731)
		noiseFade := Sin(t * 3.14159265)

		if (t > 0.80)
		{
			fade := (1 - t) / 0.20

			if (fade < 0)
				fade := 0
			noiseFade *= fade
		}

		rawNoise := ((nx + ny) * 0.5) * noiseAmount * noiseFade
		smoothedNoise := (previousNoise * 0.70) + (rawNoise * 0.30)
		previousNoise := smoothedNoise
		currentX += perpX * smoothedNoise
		currentY += perpY * smoothedNoise
		segmentDX := currentX - previousX
		segmentDY := currentY - previousY
		segmentLength := Sqrt((segmentDX * segmentDX) + (segmentDY * segmentDY))
		totalLength += segmentLength
		points.Push({x:currentX, y:currentY})
		lengths.Push(totalLength)
		previousX := currentX
		previousY := currentY
	}

	startTime := A_TickCount
	searchIndex := 2
	previousX := startX
	previousY := startY

	Loop, %steps%
	{
		t := A_Index / steps
		timingT := t * t * (3 - (2 * t))
		targetLength := totalLength * timingT
		while (searchIndex < lengths.Length() && lengths[searchIndex] < targetLength)
			searchIndex++

		if (searchIndex > lengths.Length())
			searchIndex := lengths.Length()
		prevIndex := searchIndex - 1

		if (prevIndex < 1)
			prevIndex := 1
		prevLength := lengths[prevIndex]
		nextLength := lengths[searchIndex]
		lengthRange := nextLength - prevLength

		if (lengthRange <= 0)
		{
			blend := 0
		}
		else
		{
			blend := (targetLength - prevLength) / lengthRange
		}

		point1 := points[prevIndex]
		point2 := points[searchIndex]
		currentX := point1.x + ((point2.x - point1.x) * blend)
		currentY := point1.y + ((point2.y - point1.y) * blend)
		currentX := Round(currentX)
		currentY := Round(currentY)

		if (currentX != previousX || currentY != previousY)
		{
			MouseMove, %currentX%, %currentY%, 0
			previousX := currentX
			previousY := currentY
		}

		targetElapsed := Round(duration * t)
		actualElapsed := A_TickCount - startTime
		delay := targetElapsed - actualElapsed

		if (delay < 1)
			delay := 1

		if (delay > 20)
			delay := 20
		Sleep, %delay%
	}

	MouseMove, %x%, %y%, 0
}

AntiAFKNaturalNoise(seed, t)
{
	n1 := AntiAFKNaturalNoiseLayer(seed, t, 1.0)
	n2 := AntiAFKNaturalNoiseLayer(seed + 91.73, t, 2.2) * 0.45
	n3 := AntiAFKNaturalNoiseLayer(seed + 217.41, t, 4.5) * 0.20
	value := n1 + n2 + n3

	if (value > 1)
		value := 1

	if (value < -1)
		value := -1
	return value
}

AntiAFKNaturalNoiseLayer(seed, t, frequency)
{
	position := (seed * 0.01) + (t * frequency * 5)
	segment := Floor(position)
	f := position - segment
	smooth := f * f * (3 - (2 * f))
	v1 := AntiAFKNaturalHash(segment)
	v2 := AntiAFKNaturalHash(segment + 1)
	return v1 + ((v2 - v1) * smooth)
}

AntiAFKNaturalHash(value)
{
	value := Mod(value, 2147483647)

	if (value < 0)
		value += 2147483647
	value := Mod((value * 48271), 2147483647)

	if (value < 0)
		value += 2147483647
	return (value / 1073741823.5) - 1
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
SetTimer, AntiAFK, Off
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
