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
LLARS_DISABLE_SCRIPT_CONFIG := true

if !LLARS_FrameworkAvailable()
	LLARS_FrameworkError()

LLARS_Initialize()

return

Start:

if (!LLARS_StartTimerRun())
	return

EternalTreeState := "Find Tree"
EternalTreeTargetX := ""
EternalTreeTargetY := ""
EternalTreeTargetScore := 0
EternalTreeColorMode := ""
EternalTreeAcquireMatcher := ""
EternalTreeTrackMatcher := ""
EternalTreeClickTick := 0
EternalTreeTrackingEstablished := false
EternalTreeMovementTracked := false
EternalTreeAbsentChecks := 0
EternalTreePresentChecks := 0
EternalTreePresentEvidenceTick := 0
EternalTreeAbsentStartTick := 0
EternalTreeLastTrackState := ""
EternalTreeSignature := ""
EternalTreeSignatureAbsentChecks := 0
EternalTreeSignatureAbsentStartTick := 0
EternalTreeCutCount := 0
EternalTreeSearchLogged := false

SetTimer, Countdown, 1000
SetTimer, EternalTreeTick, 250
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

; ========================================================================================
; |     ETERNAL TREE LOGIC     -     ETERNAL TREE LOGIC     -     ETERNAL TREE LOGIC     |
; ========================================================================================

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

EternalTreeTick:
if (!LLARS_RUNNING)
	return

SetTimer, EternalTreeTick, Off

if (EternalTreeState = "Find Tree")
{
	LLARS_SetStatus("Searching", "Eternal Tree")
	if !LLARS_WaitForRuneScape("Eternal Tree target search")
	{
		if (LLARS_RUNNING)
			SetTimer, EternalTreeTick, 250
		return
	}
	if (!EternalTreeSearchLogged)
	{
		LLARS_DeveloperAction("Eternal Tree || Searching || Normal + High Contrast")
		EternalTreeSearchLogged := true
	}

	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0
	EternalTreeColorMode := ""
	EternalTreeAcquireMatcher := ""
	EternalTreeTrackMatcher := ""

	; Normal mode is checked first because its magenta canopy is unique to the tree.
	if LLARS_ColorFindRuneScapeLargeCluster("EternalTree_IsNormalTreeColor", foundX, foundY, targetScore, targetDensity, 220, 4, 48, 30, 8, 2, 32, 4)
	{
		EternalTreeColorMode := "Normal"
		EternalTreeAcquireMatcher := "EternalTree_IsNormalTreeColor"
		EternalTreeTrackMatcher := "EternalTree_IsNormalTrackingColor"
	}
	else if LLARS_ColorFindRuneScapeLargeCluster("EternalTree_IsHighContrastTreeColor", foundX, foundY, targetScore, targetDensity, 260, 4, 48, 30, 8, 2, 32, 4)
	{
		EternalTreeColorMode := "High Contrast"
		EternalTreeAcquireMatcher := "EternalTree_IsHighContrastTreeColor"
		EternalTreeTrackMatcher := "EternalTree_IsHighContrastTrackingColor"
	}

	if (EternalTreeAcquireMatcher != "")
	{
		LLARS_SetStatus("Clicking", "Eternal Tree")
		LLARS_DeveloperAction("Eternal Tree || Target found || " . EternalTreeColorMode . " || (" . foundX . ", " . foundY . ") || Score=" . targetScore)
		if LLARS_ColorClickDenseTarget(foundX, foundY, EternalTreeAcquireMatcher, "Eternal Tree", "left", 24, 20, 40, 32, 4)
		{
			EternalTreeTargetX := foundX
			EternalTreeTargetY := foundY
			EternalTreeTargetScore := targetScore
			EternalTreeClickTick := A_TickCount
			EternalTreeTrackingEstablished := false
			EternalTreeMovementTracked := false
			EternalTreeAbsentChecks := 0
			EternalTreePresentChecks := 0
			EternalTreePresentEvidenceTick := 0
			EternalTreeAbsentStartTick := 0
			EternalTreeLastTrackState := ""
			EternalTreeSignature := ""
			EternalTreeSignatureAbsentChecks := 0
			EternalTreeSignatureAbsentStartTick := 0
			EternalTreeCutCount++
			EternalTreeSearchLogged := false
			EternalTreeState := "Wait Tree Gone"
			LLARS_DeveloperAction("Eternal Tree || Clicked || " . EternalTreeColorMode . " || Tracking same tree")
		}
	}
}
else if (EternalTreeState = "Wait Tree Gone")
{
	LLARS_SetStatus("Cutting", "Eternal Tree")

	; Follow the clicked tree while the character/camera moves. Absence is ignored
	; during this grace period, so movement cannot be mistaken for depletion.
	if ((A_TickCount - EternalTreeClickTick) < 2500)
	{
		movementTrackingScore := 0
		movementCameraMotion := 0
		movementTrackState := LLARS_ColorTrackRuneScapeTarget(EternalTreeTargetX, EternalTreeTargetY, EternalTreeTrackMatcher, movementTrackingScore, movementCameraMotion, "Eternal Tree Movement", 170, 96, 4, 60, 30, 30, 2000, 100.0, 40, true)
		if (movementTrackState > 0)
		{
			EternalTreeTargetScore := movementTrackingScore
			EternalTreeMovementTracked := true
		}
	}
	else
	{
		if (!EternalTreeTrackingEstablished)
		{
			oldX := EternalTreeTargetX
			oldY := EternalTreeTargetY

			if (EternalTreeMovementTracked)
			{
				; One final generous local follow keeps identity tied to the clicked tree.
				finalMovementScore := 0
				finalMovementCameraMotion := 0
				finalMovementState := LLARS_ColorTrackRuneScapeTarget(EternalTreeTargetX, EternalTreeTargetY, EternalTreeTrackMatcher, finalMovementScore, finalMovementCameraMotion, "Eternal Tree Movement", 170, 96, 4, 60, 30, 30, 2000, 100.0, 40, true)
				if (finalMovementState > 0)
					EternalTreeTargetScore := finalMovementScore

				EternalTreeTrackingEstablished := true
				LLARS_DeveloperAction("Eternal Tree || Tracking established after movement || Followed clicked tree || (" . oldX . ", " . oldY . ") > (" . EternalTreeTargetX . ", " . EternalTreeTargetY . ")")
			}
			else
			{
				reacquiredX := ""
				reacquiredY := ""
				reacquiredScore := 0
				reacquiredDensity := 0
				reacquired := false

				; Fallback only when the clicked tree could not be followed during movement.
				if (EternalTreeColorMode = "Normal")
					reacquired := LLARS_ColorFindRuneScapeLargeCluster(EternalTreeAcquireMatcher, reacquiredX, reacquiredY, reacquiredScore, reacquiredDensity, 220, 4, 48, 30, 8, 2, 32, 4)
				else if (EternalTreeColorMode = "High Contrast")
					reacquired := LLARS_ColorFindRuneScapeLargeCluster(EternalTreeAcquireMatcher, reacquiredX, reacquiredY, reacquiredScore, reacquiredDensity, 260, 4, 48, 30, 8, 2, 32, 4)

				if (reacquired)
				{
					EternalTreeTargetX := reacquiredX
					EternalTreeTargetY := reacquiredY
					EternalTreeTargetScore := reacquiredScore
					EternalTreeTrackingEstablished := true
					LLARS_DeveloperAction("Eternal Tree || Tracking established after movement || Global fallback || (" . oldX . ", " . oldY . ") > (" . EternalTreeTargetX . ", " . EternalTreeTargetY . ")")
				}
			}

			if (EternalTreeTrackingEstablished)
			{
				EternalTreeSignature := LLARS_ColorBuildRuneScapeComponentSignature(EternalTreeAcquireMatcher, EternalTreeTargetX, EternalTreeTargetY, 78, 18, 2, 20, 18, 18, 3)
				EternalTreeSignatureAbsentChecks := 0
				EternalTreeSignatureAbsentStartTick := 0
				if IsObject(EternalTreeSignature)
					LLARS_DeveloperAction("Eternal Tree || Canopy signature established || Points=" . EternalTreeSignature.PointCount)
				else
					LLARS_DeveloperAction("Eternal Tree || Canopy signature unavailable || Connected tracking only")
			}
		}

		if (!EternalTreeTrackingEstablished)
		{
			if (LLARS_RUNNING)
				SetTimer, EternalTreeTick, 250
			return
		}

		trackingScore := 0
		cameraMotion := 0
		trackState := LLARS_ColorTrackRuneScapeTarget(EternalTreeTargetX, EternalTreeTargetY, EternalTreeTrackMatcher, trackingScore, cameraMotion, "Eternal Tree", 118, 34, 4, 78, 38, 38, 2000, 18.0, 110, true)

		confirmGone := false
		signatureState := -1
		signatureRatio := 0.0
		signaturePoints := 0
		if (trackState != -1 && IsObject(EternalTreeSignature))
			signatureState := LLARS_ColorTrackRuneScapeSignature(EternalTreeSignature, EternalTreeAcquireMatcher, signatureRatio, signaturePoints, "Eternal Tree Signature", 18, 2, 3, 0.34, 3, 2000, true, 0.25)

		if (signatureState > 0)
		{
			if (EternalTreeSignatureAbsentChecks > 0)
				LLARS_DeveloperAction("Eternal Tree || Canopy signature seen again || Absence canceled")
			EternalTreeSignatureAbsentChecks := 0
			EternalTreeSignatureAbsentStartTick := 0
		}
		else if (signatureState = 0)
		{
			if (EternalTreeSignatureAbsentChecks = 0)
				EternalTreeSignatureAbsentStartTick := A_TickCount
			EternalTreeSignatureAbsentChecks++
			if (EternalTreeSignatureAbsentChecks = 1)
				LLARS_DeveloperAction("Eternal Tree || Canopy signature absent || Confirming")

			; The broad tracker can occasionally attach to leftover tree-like colors after
			; the canopy disappears. A sustained loss of the original canopy pattern is
			; therefore accepted as depletion even if those residual colors remain.
			if (EternalTreeSignatureAbsentChecks >= 6
				&& EternalTreeSignatureAbsentStartTick
				&& (A_TickCount - EternalTreeSignatureAbsentStartTick) >= 1250)
			{
				LLARS_DeveloperAction("Eternal Tree || Canopy signature absence confirmed || Ratio=" . Round(signatureRatio, 2) . " || Points=" . signaturePoints)
				confirmGone := true
			}
		}
		if (trackState > 0)
		{
			EternalTreeTargetScore := trackingScore
			if (EternalTreeAbsentChecks > 0)
			{
				EternalTreePresentChecks++
				EternalTreePresentEvidenceTick := A_TickCount
				if (EternalTreePresentChecks = 1)
					LLARS_DeveloperAction("Eternal Tree || Target seen again || Verifying")

				; One noisy reacquisition cannot erase disappearance progress.
				if (EternalTreePresentChecks >= 3)
				{
					EternalTreeAbsentChecks := 0
					EternalTreePresentChecks := 0
					EternalTreePresentEvidenceTick := 0
					EternalTreeAbsentStartTick := 0
					LLARS_DeveloperAction("Eternal Tree || Target present confirmed || Absence canceled")
				}
			}
			else
			{
				EternalTreePresentChecks := 0
				EternalTreePresentEvidenceTick := 0
				EternalTreeAbsentStartTick := 0
			}
		}
		else if (trackState = 0)
		{
			EternalTreePresentChecks := 0
			EternalTreePresentEvidenceTick := 0
			if (EternalTreeAbsentChecks = 0)
				EternalTreeAbsentStartTick := A_TickCount
			EternalTreeAbsentChecks++
			LLARS_DeveloperAction("Eternal Tree || Target absent || Confirming " . EternalTreeAbsentChecks . "/4")

			if (EternalTreeAbsentChecks >= 4)
				confirmGone := true
		}
		else if (EternalTreeAbsentChecks > 0)
		{
			if (EternalTreeLastTrackState != -1)
				LLARS_DeveloperAction("Eternal Tree || Target confirmation paused || Frame uncertain")

			; A single noisy present frame cannot hold disappearance forever.
			if (EternalTreePresentChecks > 0
				&& EternalTreePresentEvidenceTick
				&& (A_TickCount - EternalTreePresentEvidenceTick) >= 2500)
			{
				EternalTreePresentChecks := 0
				EternalTreePresentEvidenceTick := 0
			}

			; Three trustworthy absent frames are strong evidence.
			if (EternalTreeAbsentChecks >= 3
				&& EternalTreePresentChecks = 0
				&& EternalTreeAbsentStartTick
				&& (A_TickCount - EternalTreeAbsentStartTick) >= 1800)
			{
				LLARS_DeveloperAction("Eternal Tree || Target uncertain || Accepting 3/4 confirmed absence")
				confirmGone := true
			}
		}

		if (confirmGone)
		{
			LLARS_DeveloperAction("Eternal Tree || Target absence confirmed")
			LLARS_DeveloperAction("Eternal Tree || Tree gone || Find next tree")
			EternalTreeTargetX := ""
			EternalTreeTargetY := ""
			EternalTreeTargetScore := 0
			EternalTreeColorMode := ""
			EternalTreeAcquireMatcher := ""
			EternalTreeTrackMatcher := ""
			EternalTreeClickTick := 0
			EternalTreeTrackingEstablished := false
			EternalTreeMovementTracked := false
			EternalTreeAbsentChecks := 0
			EternalTreePresentChecks := 0
			EternalTreePresentEvidenceTick := 0
			EternalTreeAbsentStartTick := 0
			EternalTreeLastTrackState := ""
			EternalTreeSignature := ""
			EternalTreeSignatureAbsentChecks := 0
			EternalTreeSignatureAbsentStartTick := 0
			EternalTreeState := "Find Tree"
		}
		else
			EternalTreeLastTrackState := trackState

		; Capture failure, context-menu occlusion, or camera movement pauses the decision.
	}
}

if (LLARS_RUNNING)
	SetTimer, EternalTreeTick, 250
return

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
SetTimer, EternalTreeTick, Off
LLARS_EndTimerRun()
Logout()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done


SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nTrees clicked: %EternalTreeCutCount%`nTotal time: %hours%h %minutes%m
return

; ================================================================
; |     ETERNAL TREE COLORS     -     ETERNAL TREE COLORS        |
; ================================================================

; Normal RuneScape mode uses the large magenta canopy.
EternalTree_IsNormalTreeColor(rgb)
{
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 155 && red <= 255
		&& green >= 35 && green <= 150
		&& blue >= 105 && blue <= 225
		&& red - green >= 45
		&& blue - green >= 20
		&& red - blue >= 5)
}

; Tracking allows normal canopy lighting/animation variation while keeping red
; dominant enough that the surrounding blue terrain cannot become the target.
EternalTree_IsNormalTrackingColor(rgb)
{
	if EternalTree_IsNormalTreeColor(rgb)
		return true

	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 135 && red <= 255
		&& green >= 25 && green <= 175
		&& blue >= 90 && blue <= 235
		&& red - green >= 30
		&& blue - green >= 10
		&& red - blue >= -10)
}

; High Contrast mode keeps the proven cyan rules from the original detector.
EternalTree_IsHighContrastTreeColor(rgb)
{
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 25 && red <= 145
		&& green >= 115 && green <= 235
		&& blue >= 125 && blue <= 245
		&& green - red >= 40
		&& blue - red >= 45
		&& Abs(blue - green) <= 45)
}

EternalTree_IsHighContrastTrackingColor(rgb)
{
	if EternalTree_IsHighContrastTreeColor(rgb)
		return true

	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 85 && red <= 190
		&& green >= 135 && green <= 225
		&& blue >= 140 && blue <= 235
		&& green - red >= 15
		&& blue - red >= 20
		&& Abs(blue - green) <= 40)
}

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
