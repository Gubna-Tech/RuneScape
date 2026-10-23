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

DivinationState := "Find Resource"
DivinationTargetX := ""
DivinationTargetY := ""
DivinationTargetScore := 0
DivinationTargetType := ""
DivinationResourceClickTick := 0
DivinationResourceAbsentChecks := 0
DivinationResourcePresentChecks := 0
DivinationResourceAbsentStartTick := 0
DivinationResourceAbsenceLogged := false
DivinationNoYellowStartTick := 0
DivinationResourceStartDensity := 0
DivinationResourceTrackingEstablished := false
DivinationResourceSignature := ""
DivinationResourceSignatureAbsentChecks := 0
DivinationResourceSignatureAbsentStartTick := 0
DivinationEnrichedScanTick := 0
DivinationEnrichedConfirmX := ""
DivinationEnrichedConfirmY := ""
DivinationEnrichedConfirmCount := 0
DivinationDepositClickTick := 0
DivinationDepositWaitMs := 0
DivinationFullDialogScanTick := 0
DivinationFullDialogVisible := false
DivinationResourceCount := 0
DivinationDepositCount := 0
DivinationResourceSearchLogged := false
DivinationDepositSearchLogged := false
DivinationPostDepositEnrichedUntil := A_TickCount + 1250
DivinationEnrichedPriorityMisses := 0

SetTimer, Countdown, 1000
SetTimer, DivinationTick, 250
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
; |     DIVINATION LOGIC     -     DIVINATION LOGIC     -     DIVINATION LOGIC           |
; ========================================================================================

; =========================================================================
; |     >>> BEGIN SCRIPT EDITING <<<     >>> BEGIN SCRIPT EDITING <<<     |
; =========================================================================

; ================================================================
; SCRIPT_EDIT_BEGIN_4C4C415253
; ================================================================

DivinationTick:
if (!LLARS_RUNNING)
	return

SetTimer, DivinationTick, Off

; The RuneScape "You do not have any inventory space." dialog is the only inventory-full signal used here.
if (!DivinationFullDialogScanTick || (A_TickCount - DivinationFullDialogScanTick) >= 250)
{
	DivinationFullDialogScanTick := A_TickCount
	DivinationFullDialogVisible := Divination_FullInventoryDialogVisible()

	if (DivinationFullDialogVisible
		&& DivinationState != "Find Deposit"
		&& DivinationState != "Deposit Grace")
	{
		LLARS_DeveloperAction("Divination || Full inventory dialog detected || Find deposit")
		Divination_ClearResourceTarget()
		DivinationResourceSearchLogged := false
		DivinationDepositSearchLogged := false
		DivinationState := "Find Deposit"
	}
}

if (DivinationState = "Find Resource")
{
	LLARS_SetStatus("Searching", "Divination Resource")
	if !LLARS_WaitForRuneScape("Divination resource search")
	{
		if (LLARS_RUNNING)
			SetTimer, DivinationTick, 250
		return
	}

	if (!DivinationResourceSearchLogged)
	{
		LLARS_DeveloperAction("Divination || Searching || Enriched priority / Yellow resource")
		LLARS_SetDetection("Divination Resource", "Searching", "", "", "Enriched priority")
		DivinationResourceSearchLogged := true
	}

	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0

	; Enriched resources are dramatically larger than ordinary yellow nodes.
	; Check several independent yellow bodies before allowing a normal fallback.
	; This preserves the existing size-based detector, but prevents the nearest
	; normal wisp from hiding a larger enriched wisp elsewhere on screen.
	DivinationTargetType := ""
	enrichedBodySamples := 0
	enrichedBodyWidth := 0
	enrichedBodyHeight := 0
	if Divination_FindEnrichedCandidate(foundX, foundY, targetScore, targetDensity, enrichedBodyWidth, enrichedBodyHeight, enrichedBodySamples)
	{
		DivinationTargetType := "Enriched"
		DivinationEnrichedPriorityMisses := 0
		LLARS_DeveloperAction("Divination || Enriched body verified || Samples=" . enrichedBodySamples . " || Spread=" . enrichedBodyWidth . "x" . enrichedBodyHeight)
	}
	else
	{
		DivinationEnrichedPriorityMisses++
	}

	; Enriched is authoritative. Do not allow a normal fallback until the
	; enriched detector has completed several independent scans with no hit.
	; This is scan-count based rather than only wall-clock based, so slow image
	; captures cannot collapse the priority window into one or two real checks.
	normalWispFallback := false
	if (DivinationTargetType = ""
		&& DivinationEnrichedPriorityMisses >= 4
		&& (!DivinationPostDepositEnrichedUntil || A_TickCount >= DivinationPostDepositEnrichedUntil)
		&& LLARS_ColorGetRuneScapeClient(searchHwnd, searchWidth, searchHeight))
	{
		searchCaptureMethod := ""
		searchCapture := LLARS_ColorCaptureVisibleClient(searchHwnd, searchWidth, searchHeight, searchCaptureMethod)
		if IsObject(searchCapture)
		{
			if LLARS_ColorFindLargeClusterFromCapture(searchCapture, "Divination_IsResourceColor", foundX, foundY, targetScore, targetDensity, 10, 4, 48, 8, 8, 2, 20, 4, "center-biased")
				DivinationTargetType := "Normal"
			else if Divination_FindSmallNormalWispFromCapture(searchCapture, foundX, foundY, targetScore, targetDensity)
			{
				DivinationTargetType := "Normal"
				normalWispFallback := true
				LLARS_DeveloperAction("Divination || Small normal wisp verified || (" . foundX . ", " . foundY . ") || Score=" . targetScore)
			}
			LLARS_CreatorReleaseCapture(searchCapture)
		}
	}

	; A normal candidate is only a fallback. Before committing to it, give the
	; enriched detector one final fresh capture so a visible enriched wisp can
	; never lose merely because the normal scan ran later in the same search.
	if (DivinationTargetType = "Normal")
	{
		priorityX := ""
		priorityY := ""
		priorityScore := 0
		priorityDensity := 0
		priorityBodyWidth := 0
		priorityBodyHeight := 0
		priorityBodySamples := 0
		if Divination_FindEnrichedCandidate(priorityX, priorityY, priorityScore, priorityDensity, priorityBodyWidth, priorityBodyHeight, priorityBodySamples)
		{
			DivinationEnrichedPriorityMisses := 0
			foundX := priorityX
			foundY := priorityY
			targetScore := priorityScore
			targetDensity := priorityDensity
			enrichedBodyWidth := priorityBodyWidth
			enrichedBodyHeight := priorityBodyHeight
			enrichedBodySamples := priorityBodySamples
			DivinationTargetType := "Enriched"
			normalWispFallback := false
			LLARS_DeveloperAction("Divination || Enriched won final priority check || Samples=" . enrichedBodySamples . " || Spread=" . enrichedBodyWidth . "x" . enrichedBodyHeight)
		}
	}

	if (DivinationTargetType != "")
	{
		LLARS_SetStatus("Clicking", "Divination Resource")
		LLARS_DeveloperAction("Divination || " . DivinationTargetType . " resource found || (" . foundX . ", " . foundY . ") || Score=" . targetScore)
		LLARS_SetDetection("Divination Resource", DivinationTargetType, targetScore, "", "(" . foundX . ", " . foundY . ")", false)

		resourceClickOk := false
		if (DivinationTargetType = "Normal" && normalWispFallback)
			resourceClickOk := LLARS_ColorClickDenseTarget(foundX, foundY, "Divination_IsWispSearchColor", "Divination Normal Wisp", "left", 20, 2, 3, 12, 2, true, true)
		else
			resourceClickOk := LLARS_ColorClickDenseTarget(foundX, foundY, "Divination_IsResourceColor", "Divination " . DivinationTargetType . " Resource", "left", 30, 6, 6, 20, 4, true, true)

		if (resourceClickOk)
		{
			DivinationTargetX := foundX
			DivinationTargetY := foundY
			DivinationTargetScore := targetScore
			DivinationResourceClickTick := A_TickCount
			DivinationResourceAbsentChecks := 0
			DivinationResourcePresentChecks := 0
			DivinationResourceAbsentStartTick := 0
			DivinationResourceTrackingEstablished := false
			DivinationEnrichedScanTick := A_TickCount
			DivinationResourceCount++
			DivinationResourceSearchLogged := false
			DivinationPostDepositEnrichedUntil := 0
			DivinationEnrichedPriorityMisses := 0

			if (DivinationTargetType = "Normal" && normalWispFallback)
			{
				DivinationResourceStartDensity := 0
				DivinationState := "Wait Wisp Activate"
				LLARS_DeveloperAction("Divination || Small wisp clicked || Waiting for active spring")
			}
			else
			{
				DivinationResourceStartDensity := Divination_ReadResourceDensity(DivinationTargetX, DivinationTargetY, DivinationTargetType)
				DivinationState := "Wait Resource Gone"
				LLARS_DeveloperAction("Divination || " . DivinationTargetType . " resource clicked || Tracking exact resource")
			}

			Divination_MoveMouseOffResource(DivinationTargetX, DivinationTargetY)
		}
		else
		{
			DivinationResourceSearchLogged := false
			DivinationState := "Find Resource"
			LLARS_DeveloperAction("Divination || RedClick not confirmed || Reacquire resource")
		}
	}
}
else if (DivinationState = "Wait Wisp Activate")
{
	LLARS_SetStatus("Activating", "Divination Resource")
	wispAge := A_TickCount - DivinationResourceClickTick

	if (wispAge >= 250
		&& (!DivinationEnrichedScanTick || (A_TickCount - DivinationEnrichedScanTick) >= 250))
	{
		DivinationEnrichedScanTick := A_TickCount
		enrichedX := ""
		enrichedY := ""
		enrichedScore := 0
		enrichedDensity := 0
		enrichedBodyWidth := 0
		enrichedBodyHeight := 0
		if Divination_FindEnrichedCandidate(enrichedX, enrichedY, enrichedScore, enrichedDensity, enrichedBodyWidth, enrichedBodyHeight)
		{
			if LLARS_ColorClickDenseTarget(enrichedX, enrichedY, "Divination_IsResourceColor", "Divination Enriched Resource", "left", 30, 6, 6, 20, 4, true, true)
			{
				DivinationTargetX := enrichedX
				DivinationTargetY := enrichedY
				DivinationTargetScore := enrichedScore
				DivinationTargetType := "Enriched"
				DivinationResourceClickTick := A_TickCount
				DivinationResourceAbsentChecks := 0
				DivinationResourcePresentChecks := 0
				DivinationResourceAbsentStartTick := 0
				DivinationResourceAbsenceLogged := false
				DivinationNoYellowStartTick := 0
				DivinationResourceStartDensity := Divination_ReadResourceDensity(DivinationTargetX, DivinationTargetY, DivinationTargetType)
				DivinationResourceTrackingEstablished := false
				DivinationState := "Wait Resource Gone"
				LLARS_DeveloperAction("Divination || Enriched appeared during wisp activation || Switching immediately")
				Divination_MoveMouseOffResource(DivinationTargetX, DivinationTargetY)
			}
			else
			{
				DivinationResourceSearchLogged := false
				DivinationState := "Find Resource"
				LLARS_DeveloperAction("Divination || Enriched RedClick not confirmed || Reacquire resource")
			}
		}
	}

	if (DivinationState = "Wait Wisp Activate" && wispAge >= 500
		&& LLARS_ColorGetRuneScapeClient(activateHwnd, activateWidth, activateHeight)
		&& DllCall("GetForegroundWindow", "Ptr") = activateHwnd)
	{
		activateMethod := ""
		activateCapture := LLARS_ColorCaptureVisibleClient(activateHwnd, activateWidth, activateHeight, activateMethod)
		if IsObject(activateCapture)
		{
			activeX := ""
			activeY := ""
			activeScore := 0
			activeDensity := 0
			if Divination_FindActivatedNormalFromCapture(activateCapture, DivinationTargetX, DivinationTargetY, activeX, activeY, activeScore, activeDensity)
			{
				DivinationTargetX := activeX
				DivinationTargetY := activeY
				DivinationTargetScore := activeScore
				DivinationTargetType := "Normal"
				DivinationResourceStartDensity := Max(1, activeScore)
				DivinationResourceTrackingEstablished := true
				DivinationResourceSignature := LLARS_ColorBuildComponentSignature(activateCapture, "Divination_IsResourceTrackingColor", activeX, activeY, 58, 16, 2, 12, 6, 6, 3)
				DivinationResourceSignatureAbsentChecks := 0
				DivinationResourceSignatureAbsentStartTick := 0
				if IsObject(DivinationResourceSignature)
					LLARS_DeveloperAction("Divination || Active spring signature established || Points=" . DivinationResourceSignature.PointCount)
				DivinationResourceAbsentChecks := 0
				DivinationResourcePresentChecks := 0
				DivinationResourceAbsentStartTick := 0
				DivinationResourceAbsenceLogged := false
				DivinationNoYellowStartTick := 0
				DivinationResourceClickTick := A_TickCount - 3000
				DivinationState := "Wait Resource Gone"
				LLARS_DeveloperAction("Divination || Small wisp became active spring || Original depletion tracker engaged || (" . activeX . ", " . activeY . ") || Score=" . activeScore)
			}
			LLARS_CreatorReleaseCapture(activateCapture)
		}
	}

	if (DivinationState = "Wait Wisp Activate" && wispAge >= 10000)
	{
		LLARS_DeveloperAction("Divination || Wisp activation not confirmed within 10 sec || Search again")
		Divination_ClearResourceTarget()
		DivinationResourceSearchLogged := false
		DivinationPostDepositEnrichedUntil := A_TickCount + 1250
		DivinationEnrichedPriorityMisses := 0
		DivinationState := "Find Resource"
	}
}
else if (DivinationState = "Wait Resource Gone")
{
	LLARS_SetStatus("Harvesting", "Divination Resource")
	resourceGone := false

	; Track only the node that was actually clicked.
	if ((A_TickCount - DivinationResourceClickTick) >= 3000)
	{
		currentDensity := 0
		trackSource := ""
		anyYellowVisible := true
		trackState := Divination_ResourcePresentAtClick(DivinationTargetX, DivinationTargetY, DivinationTargetType, DivinationResourceStartDensity, currentDensity, trackSource, anyYellowVisible, !DivinationResourceTrackingEstablished)

		if (trackState > 0)
		{
			DivinationTargetScore := currentDensity

			if (!DivinationResourceTrackingEstablished)
			{
				DivinationResourceTrackingEstablished := true
				if (DivinationTargetType != "Enriched")
				{
					DivinationResourceSignature := LLARS_ColorBuildRuneScapeComponentSignature("Divination_IsResourceTrackingColor", DivinationTargetX, DivinationTargetY, 58, 16, 2, 12, 6, 6, 3)
					DivinationResourceSignatureAbsentChecks := 0
					DivinationResourceSignatureAbsentStartTick := 0
					if IsObject(DivinationResourceSignature)
						LLARS_DeveloperAction("Divination || Resource signature established || Points=" . DivinationResourceSignature.PointCount)
				}
				if (DivinationResourceStartDensity <= 0 && currentDensity > 0)
					DivinationResourceStartDensity := currentDensity
				LLARS_DeveloperAction("Divination || Resource tracking established after movement || (" . DivinationTargetX . ", " . DivinationTargetY . ") || Density=" . currentDensity)

				DivinationResourceAbsentChecks := 0
				DivinationResourcePresentChecks := 0
				DivinationResourceAbsentStartTick := 0
				DivinationResourceAbsenceLogged := false
				DivinationNoYellowStartTick := 0
			}
			else if (DivinationResourceAbsentChecks > 0)
			{
				; Small Eternal Tree safeguard: one noisy present frame cannot erase
				; depletion progress. Require only two consecutive present frames here.
				DivinationResourcePresentChecks++
				if (DivinationResourcePresentChecks = 1 && DivinationResourceAbsenceLogged)
					LLARS_DeveloperAction("Divination || Resource visible again || Verifying 1/2 || Density=" . currentDensity . "/" . DivinationResourceStartDensity)

				if (DivinationResourcePresentChecks >= 2)
				{
					if (DivinationResourceAbsenceLogged)
						LLARS_DeveloperAction("Divination || Resource presence confirmed || Absence cancelled || Density=" . currentDensity . "/" . DivinationResourceStartDensity)
					DivinationResourceAbsentChecks := 0
					DivinationResourcePresentChecks := 0
					DivinationResourceAbsentStartTick := 0
					DivinationResourceAbsenceLogged := false
					DivinationNoYellowStartTick := 0
				}
			}
			else
			{
				DivinationResourcePresentChecks := 0
				DivinationResourceAbsentStartTick := 0
				DivinationResourceAbsenceLogged := false
				DivinationNoYellowStartTick := 0
			}
		}
		else if (trackState = 0 && !DivinationResourceTrackingEstablished)
		{
			; Still walking / camera still settling.
			DivinationResourceAbsentChecks := 0
			DivinationResourcePresentChecks := 0
			DivinationResourceAbsentStartTick := 0
			DivinationResourceAbsenceLogged := false
			DivinationNoYellowStartTick := 0
		}
		else if (trackState = 0)
		{
			DivinationResourcePresentChecks := 0
			if (DivinationResourceAbsentChecks = 0)
			{
				DivinationResourceAbsentStartTick := A_TickCount
				DivinationResourceAbsenceLogged := false
				DivinationNoYellowStartTick := 0
			}

			; A busy/full world can unload every entity for a moment.
			if (anyYellowVisible)
			{
				DivinationNoYellowStartTick := 0

				if (!DivinationResourceAbsenceLogged)
				{
					LLARS_DeveloperAction("Divination || Resource missing || Starting depletion confirmation || Density=" . currentDensity . "/" . DivinationResourceStartDensity)
					DivinationResourceAbsenceLogged := true
				}
			}
			else
			{
				if (!DivinationNoYellowStartTick)
					DivinationNoYellowStartTick := A_TickCount

				noYellowDuration := A_TickCount - DivinationNoYellowStartTick
				if (!DivinationResourceAbsenceLogged && noYellowDuration >= 3000)
				{
					LLARS_DeveloperAction("Divination || Resource missing || No yellow visible for " . noYellowDuration . " ms || Continuing depletion confirmation")
					DivinationResourceAbsenceLogged := true
				}
			}

			DivinationResourceAbsentChecks++
			absenceDuration := A_TickCount - DivinationResourceAbsentStartTick

			if (DivinationResourceAbsentChecks >= 6 && absenceDuration >= 1250)
			{
				LLARS_DeveloperAction("Divination || Resource depleted || Missing " . absenceDuration . " ms || Find another resource")
				LLARS_SetDetection("Divination Resource", "Depleted", "", "", "Missing " . absenceDuration . " ms", false)
				Divination_ClearResourceTarget()
				DivinationResourceSearchLogged := false
				DivinationPostDepositEnrichedUntil := A_TickCount + 1250
				DivinationEnrichedPriorityMisses := 0
				DivinationState := "Find Resource"
				resourceGone := true
			}
		}
		else if (trackState < 0 && DivinationResourceAbsentChecks > 0)
		{
			DivinationResourcePresentChecks := 0
		}
	}

	; Preserve a spatial signature of the exact established normal resource. The
	; broad yellow tracker can see nearby wisps and used to adopt one after the
	; tracked node vanished at far zoom. Sustained loss of this tracked pattern
	; Confirm depletion independently using the same completion check as Eternal Tree.
	if (!resourceGone && DivinationTargetType != "Enriched" && DivinationResourceTrackingEstablished)
	{
		if !IsObject(DivinationResourceSignature)
		{
			DivinationResourceSignature := LLARS_ColorBuildRuneScapeComponentSignature("Divination_IsResourceTrackingColor", DivinationTargetX, DivinationTargetY, 58, 16, 2, 12, 6, 6, 3)
			DivinationResourceSignatureAbsentChecks := 0
			DivinationResourceSignatureAbsentStartTick := 0
		}

		if IsObject(DivinationResourceSignature)
		{
			signatureRatio := 0.0
			signaturePoints := 0
			signatureState := LLARS_ColorTrackRuneScapeSignature(DivinationResourceSignature, "Divination_IsResourceTrackingColor", signatureRatio, signaturePoints, "Divination Resource Signature", 22, 2, 2, 0.34, 3, 2000, true, 0.20)
			if (signatureState > 0)
			{
				DivinationResourceSignatureAbsentChecks := 0
				DivinationResourceSignatureAbsentStartTick := 0
			}
			else if (signatureState = 0)
			{
				if (DivinationResourceSignatureAbsentChecks = 0)
				{
					DivinationResourceSignatureAbsentStartTick := A_TickCount
					LLARS_DeveloperAction("Divination || Original resource signature absent || Confirming depletion")
				}
				DivinationResourceSignatureAbsentChecks++
				signatureAbsentDuration := A_TickCount - DivinationResourceSignatureAbsentStartTick
				if (DivinationResourceSignatureAbsentChecks >= 6 && signatureAbsentDuration >= 1250)
				{
					LLARS_DeveloperAction("Divination || Original resource signature depleted || Missing " . signatureAbsentDuration . " ms || Ratio=" . Round(signatureRatio, 2) . " || Find another resource")
					Divination_ClearResourceTarget()
					DivinationResourceSearchLogged := false
					DivinationPostDepositEnrichedUntil := A_TickCount + 1250
					DivinationEnrichedPriorityMisses := 0
					DivinationState := "Find Resource"
					resourceGone := true
				}
			}
		}
	}

	; Enriched is always watched for, even while already harvesting enriched.
	if (!resourceGone
		&& DivinationResourceAbsentChecks = 0
		&& (A_TickCount - DivinationResourceClickTick) >= 250
		&& (!DivinationEnrichedScanTick || (A_TickCount - DivinationEnrichedScanTick) >= 250))
	{
		DivinationEnrichedScanTick := A_TickCount
		enrichedX := ""
		enrichedY := ""
		enrichedScore := 0
		enrichedDensity := 0

		enrichedBodyWidth := 0
		enrichedBodyHeight := 0

		if Divination_FindEnrichedCandidate(enrichedX, enrichedY, enrichedScore, enrichedDensity, enrichedBodyWidth, enrichedBodyHeight)
		{
			; The live candidate has already passed the stronger scale-relative connected-body verifier.
			if (DivinationTargetType != "Enriched")
			{
				LLARS_DeveloperAction("Divination || Enriched body verified live || Switching immediately || Score=" . enrichedScore
					. " || Spread=" . enrichedBodyWidth . "x" . enrichedBodyHeight)
				LLARS_SetDetection("Divination Resource", "Enriched live", enrichedScore, "", "Spread=" . enrichedBodyWidth . "x" . enrichedBodyHeight, false)

				if LLARS_ColorClickDenseTarget(enrichedX, enrichedY, "Divination_IsResourceColor", "Divination Enriched Resource", "left", 30, 6, 6, 20, 4, true, true)
				{
					DivinationTargetX := enrichedX
					DivinationTargetY := enrichedY
					DivinationTargetScore := enrichedScore
					DivinationTargetType := "Enriched"
					DivinationResourceClickTick := A_TickCount
					DivinationResourceAbsentChecks := 0
					DivinationResourcePresentChecks := 0
					DivinationResourceAbsentStartTick := 0
					DivinationResourceAbsenceLogged := false
					DivinationNoYellowStartTick := 0
					DivinationResourceStartDensity := Divination_ReadResourceDensity(DivinationTargetX, DivinationTargetY, DivinationTargetType)
					DivinationResourceTrackingEstablished := false
					DivinationEnrichedScanTick := A_TickCount
					DivinationEnrichedConfirmX := ""
					DivinationEnrichedConfirmY := ""
					DivinationEnrichedConfirmCount := 0
					DivinationResourceCount++
					LLARS_DeveloperAction("Divination || Enriched resource clicked || Continuous enriched watch remains active")
					Divination_MoveMouseOffResource(DivinationTargetX, DivinationTargetY)
				}
				else
				{
					DivinationResourceSearchLogged := false
					DivinationState := "Find Resource"
					LLARS_DeveloperAction("Divination || Enriched RedClick not confirmed || Reacquire resource")
				}
			}
		}
	}
}
else if (DivinationState = "Find Deposit")
{
	LLARS_SetStatus("Searching", "Divination Deposit")
	if !LLARS_WaitForRuneScape("Divination deposit search")
	{
		if (LLARS_RUNNING)
			SetTimer, DivinationTick, 250
		return
	}

	if (!DivinationDepositSearchLogged)
	{
		LLARS_DeveloperAction("Divination || Searching || White deposit")
		DivinationDepositSearchLogged := true
	}

	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0

	; Find and verify the deposit from a RuneScape-only PrintWindow frame.
	; This prevents LLARS/Developer windows covering RuneScape from being mistaken
	; for the large bright white deposit rift.
	if Divination_FindDepositBackground(foundX, foundY, targetScore, targetDensity)
	{
		LLARS_SetStatus("Clicking", "Divination Deposit")
		LLARS_DeveloperAction("Divination || Deposit found || Client=(" . foundX . ", " . foundY . ") || Score=" . targetScore)
		if Divination_ClickDepositBackground(foundX, foundY)
		{
			DivinationDepositClickTick := A_TickCount
			Random, DivinationDepositWaitMs, 33000, 35000
			DivinationDepositCount++
			DivinationDepositSearchLogged := false
			DivinationState := "Deposit Grace"
			LLARS_DeveloperAction("Divination || Deposit clicked || Waiting " . Round(DivinationDepositWaitMs / 1000, 1) . " sec for inventory to clear")
		}
		else
		{
			DivinationDepositSearchLogged := false
			DivinationState := "Find Deposit"
			LLARS_DeveloperAction("Divination || Deposit RedClick not confirmed || Reacquire deposit")
		}
	}
}
else if (DivinationState = "Deposit Grace")
{
	LLARS_SetStatus("Depositing", "Divination")

	; Lower-level accounts can require roughly 33-35 seconds to deposit a full
	; inventory, plus a short walk to the deposit after the click. The slow variant uses a 33-35 second post-click deposit window.
	if (DivinationDepositClickTick
		&& DivinationDepositWaitMs
		&& (A_TickCount - DivinationDepositClickTick) >= DivinationDepositWaitMs)
	{
		DivinationDepositClickTick := 0
		DivinationDepositWaitMs := 0
		DivinationResourceSearchLogged := false
		DivinationDepositSearchLogged := false
		DivinationPostDepositEnrichedUntil := A_TickCount + 1250
		DivinationEnrichedPriorityMisses := 0
		DivinationState := "Find Resource"
		LLARS_DeveloperAction("Divination || Deposit wait complete || Enriched priority: 1250 ms + 4 verified misses before normal fallback")
	}
}
else
{
	DivinationResourceSearchLogged := false
	DivinationDepositSearchLogged := false
	DivinationPostDepositEnrichedUntil := A_TickCount + 1250
	DivinationEnrichedPriorityMisses := 0
	DivinationState := "Find Resource"
	LLARS_DeveloperAction("Divination || State recovered || Find resource")
}

if (LLARS_RUNNING)
	SetTimer, DivinationTick, 250
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
SetTimer, DivinationTick, Off
LLARS_EndTimerRun()
Logout()

GuiControl,, TimerCount, Done
GuiControl,, State3, Done


SoundPlay, C:\Windows\Media\Ring06.wav, 1
MsgBox, 64, LLARS Run Info, %scriptname% has completed running`n`nResources clicked: %DivinationResourceCount%`nDeposits clicked: %DivinationDepositCount%`nTotal time: %hours%h %minutes%m
return

Divination_MoveMouseOffResource(resourceX, resourceY)
{
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return false

	; Move naturally away from the clicked node without clicking anything else.
	moveX := Max(70, Round(clientWidth * 0.07))
	moveY := Max(55, Round(clientHeight * 0.07))

	if (resourceX <= (clientWidth / 2))
		parkX := resourceX - moveX
	else
		parkX := resourceX + moveX

	if (resourceY <= (clientHeight / 2))
		parkY := resourceY - moveY
	else
		parkY := resourceY + moveY

	parkX := Max(20, Min(clientWidth - 20, Round(parkX)))
	parkY := Max(20, Min(clientHeight - 20, Round(parkY)))

	LLARS_DeveloperAction("Divination || Mouse moved off resource || (" . resourceX . ", " . resourceY . ") > (" . parkX . ", " . parkY . ")")
	return AntiAFKNaturalClick(parkX, parkY)
}


Divination_FullInventoryDialogVisible()
{
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return false

	captureMethod := ""
	capture := LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return false

	visible := Divination_FindFullInventoryDialog(capture)
	LLARS_CreatorReleaseCapture(capture)
	return visible
}


Divination_FindDepositBackground(ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity)
{
	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0

	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return false

	captureMethod := ""
	capture := LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return false

	bodySamples := 0
	bodyWidth := 0
	bodyHeight := 0
	found := Divination_FindBestDepositCandidateFromCapture(capture, foundX, foundY, targetScore, targetDensity, bodySamples, bodyWidth, bodyHeight)
	LLARS_CreatorReleaseCapture(capture)
	return found
}

Divination_FindBestDepositCandidateFromCapture(capture, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity, ByRef bestBodySamples := 0, ByRef bestBodyWidth := 0, ByRef bestBodyHeight := 0)
{
	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0
	bestBodySamples := 0
	bestBodyWidth := 0
	bestBodyHeight := 0
	if !IsObject(capture)
		return false

	; Deposit size changes substantially with camera zoom. Enumerate plausible
	; connected white bodies and keep the largest body in this frame instead of
	; enforcing a fixed close-zoom 66x62 size.
	attempt := 0
	while (attempt < 8)
	{
		attempt++
		candidateX := ""
		candidateY := ""
		candidateScore := 0
		candidateDensity := 0

		if !LLARS_ColorFindLargeClusterFromCapture(capture
			, "Divination_IsDepositColor"
			, candidateX
			, candidateY
			, candidateScore
			, candidateDensity
			, 30
			, 4
			, 40
			, 6
			, 6
			, 2
			, 24
			, 3
			, "center-biased")
			break

		bodySamples := 0
		minX := ""
		maxX := ""
		minY := ""
		maxY := ""
		sumX := 0
		sumY := 0
		bodyWidth := 0
		bodyHeight := 0
		if Divination_GetDepositBody(capture, candidateX, candidateY, bodySamples, minX, maxX, minY, maxY, sumX, sumY)
		{
			bodyWidth := maxX - minX + 1
			bodyHeight := maxY - minY + 1
			if (Divination_DepositBodyLooksValid(bodySamples, bodyWidth, bodyHeight)
				&& bodySamples > bestBodySamples)
			{
				bestBodySamples := bodySamples
				bestBodyWidth := bodyWidth
				bestBodyHeight := bodyHeight
				foundX := Round(sumX / Max(1, bodySamples))
				foundY := Round(sumY / Max(1, bodySamples))
				targetScore := candidateScore
				targetDensity := candidateDensity
			}
		}

		maskRadius := Max(28, Min(75, Round(Max(bodyWidth, bodyHeight) * 0.72)))
		Divination_MaskCaptureArea(capture, candidateX, candidateY, maskRadius)
	}

	if (bestBodySamples > 0)
	{
		LLARS_DeveloperAction("Divination || Deposit body selected || Samples=" . bestBodySamples . " || Spread=" . bestBodyWidth . "x" . bestBodyHeight)
		return true
	}
	return false
}

Divination_DepositBodyLooksValid(bodySamples, bodyWidth, bodyHeight)
{
	if (bodySamples < 500 || bodyWidth < 34 || bodyHeight < 34)
		return false
	if (bodyWidth > 130 || bodyHeight > 130)
		return false
	aspect := bodyWidth / Max(1.0, bodyHeight)
	if (aspect < 0.62 || aspect > 1.62)
		return false
	fillRatio := bodySamples / Max(1.0, bodyWidth * bodyHeight)
	return (fillRatio >= 0.22)
}


Divination_ClickDepositBackground(ByRef clientX, ByRef clientY)
{
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return false

	captureMethod := ""
	capture := LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return false

	; Deposit clicking deliberately does NOT require the final click coordinate to
	; itself be a white pixel. The white swirl/rim is only used to recover the
	; deposit geometry; once the large deposit body is verified we click the true
	; center of that body's bounds. This avoids being pulled back to a bright edge.
	hintX := Round(clientX + 0)
	hintY := Round(clientY + 0)
	clickX := ""
	clickY := ""
	bodySamples := 0
	bodyWidth := 0
	bodyHeight := 0
	minX := ""
	maxX := ""
	minY := ""
	maxY := ""

	resolved := Divination_ResolveDepositGeometry(capture
		, hintX
		, hintY
		, clickX
		, clickY
		, bodySamples
		, bodyWidth
		, bodyHeight
		, minX
		, maxX
		, minY
		, maxY)

	LLARS_CreatorReleaseCapture(capture)

	if !resolved
	{
		; Do not use an edge-point fallback. If the full deposit geometry cannot
		; be resolved on this frame, wait for the next Find Deposit pass instead.
		LLARS_DeveloperAction("Divination || Deposit center unresolved || No edge fallback / no click")
		return false
	}

	clientX := clickX
	clientY := clickY
	depositCenterX := Round((minX + maxX) / 2)
	depositCenterY := Round((minY + maxY) / 2)
	LLARS_DeveloperAction("Divination || Deposit near-center target || Client=(" . clientX . ", " . clientY . ") || Center=(" . depositCenterX . ", " . depositCenterY . ") || Offset=(" . (clientX - depositCenterX) . ", " . (clientY - depositCenterY) . ") || Bounds=(" . minX . "," . minY . ")-(" . maxX . "," . maxY . ") || Spread=" . bodyWidth . "x" . bodyHeight . " || Samples=" . bodySamples)

	; LLARS runs mouse coordinates in Client mode, so the verified deposit center
	; must remain client-relative all the way into LLARS_ClickPoint. Converting it
	; with ClientToScreen would add the window-frame/title-bar offset a second
	; time and push an otherwise centered click down toward the deposit edge.
	clientX := Round(clientX + 0)
	clientY := Round(clientY + 0)

	LLARS_DeveloperAction("Divination || Deposit click verified || Client=(" . clientX . ", " . clientY . ") || Geometry=center/client-coordinates")
	return LLARS_RedClickRetryPoint(clientX, clientY, "left", "Divination Deposit")
}


Divination_ResolveDepositGeometry(capture, hintX, hintY, ByRef clickX, ByRef clickY, ByRef bodySamples, ByRef bodyWidth, ByRef bodyHeight, ByRef minX, ByRef maxX, ByRef minY, ByRef maxY)
{
	clickX := ""
	clickY := ""
	bodySamples := 0
	bodyWidth := 0
	bodyHeight := 0
	minX := ""
	maxX := ""
	minY := ""
	maxY := ""

	if !IsObject(capture)
		return false

	seedX := Round(hintX + 0)
	seedY := Round(hintY + 0)
	if LLARS_ColorReacquireDensePoint(capture
		, "Divination_IsDepositColor"
		, seedX
		, seedY
		, 16
		, 10
		, 5
		, 1)
	{
		if Divination_DepositGeometryFromSeed(capture, seedX, seedY, clickX, clickY, bodySamples, bodyWidth, bodyHeight, minX, maxX, minY, maxY)
			return true
	}

	candidateX := ""
	candidateY := ""
	candidateScore := 0
	candidateDensity := 0
	candidateSamples := 0
	candidateWidth := 0
	candidateHeight := 0
	if Divination_FindBestDepositCandidateFromCapture(capture, candidateX, candidateY, candidateScore, candidateDensity, candidateSamples, candidateWidth, candidateHeight)
		return Divination_DepositGeometryFromSeed(capture, candidateX, candidateY, clickX, clickY, bodySamples, bodyWidth, bodyHeight, minX, maxX, minY, maxY)

	return false
}


Divination_DepositGeometryFromSeed(capture, seedX, seedY, ByRef clickX, ByRef clickY, ByRef bodySamples, ByRef bodyWidth, ByRef bodyHeight, ByRef minX, ByRef maxX, ByRef minY, ByRef maxY)
{
	global Divination_LastDepositQuadrant
	clickX := ""
	clickY := ""
	bodySamples := 0
	bodyWidth := 0
	bodyHeight := 0
	minX := ""
	maxX := ""
	minY := ""
	maxY := ""
	sumX := 0
	sumY := 0

	if !Divination_GetDepositBody(capture, seedX, seedY, bodySamples, minX, maxX, minY, maxY, sumX, sumY)
		return false

	bodyWidth := maxX - minX + 1
	bodyHeight := maxY - minY + 1
	if !Divination_DepositBodyLooksValid(bodySamples, bodyWidth, bodyHeight)
		return false

	boxCenterX := Round((minX + maxX) / 2)
	boxCenterY := Round((minY + maxY) / 2)
	insetX := Min(boxCenterX - minX, maxX - boxCenterX)
	insetY := Min(boxCenterY - minY, maxY - boxCenterY)
	if (insetX < 14 || insetY < 14)
		return false

	Random, depositQuadrant, 1, 4
	if (Divination_LastDepositQuadrant >= 1 && Divination_LastDepositQuadrant <= 4 && depositQuadrant = Divination_LastDepositQuadrant)
	{
		Random, quadrantStep, 1, 3
		depositQuadrant := Mod(Divination_LastDepositQuadrant - 1 + quadrantStep, 4) + 1
	}
	Divination_LastDepositQuadrant := depositQuadrant

	maxOffset := Max(2, Min(5, Floor(Min(bodyWidth, bodyHeight) * 0.08)))
	Random, centerOffsetX, 2, %maxOffset%
	Random, centerOffsetY, 2, %maxOffset%
	if (depositQuadrant = 1)
	{
		clickX := boxCenterX + centerOffsetX
		clickY := boxCenterY - centerOffsetY
	}
	else if (depositQuadrant = 2)
	{
		clickX := boxCenterX - centerOffsetX
		clickY := boxCenterY - centerOffsetY
	}
	else if (depositQuadrant = 3)
	{
		clickX := boxCenterX - centerOffsetX
		clickY := boxCenterY + centerOffsetY
	}
	else
	{
		clickX := boxCenterX + centerOffsetX
		clickY := boxCenterY + centerOffsetY
	}
	return true
}


Divination_IsDepositConnectedBody(capture, centerX, centerY, ByRef bodySamples := 0, ByRef bodyWidth := 0, ByRef bodyHeight := 0)
{
	bodySamples := 0
	bodyWidth := 0
	bodyHeight := 0
	minX := ""
	maxX := ""
	minY := ""
	maxY := ""
	sumX := 0
	sumY := 0

	if !Divination_GetDepositBody(capture, centerX, centerY, bodySamples, minX, maxX, minY, maxY, sumX, sumY)
		return false

	bodyWidth := maxX - minX + 1
	bodyHeight := maxY - minY + 1
	return Divination_DepositBodyLooksValid(bodySamples, bodyWidth, bodyHeight)
}


Divination_GetDepositBody(capture, centerX, centerY, ByRef bodySamples, ByRef minX, ByRef maxX, ByRef minY, ByRef maxY, ByRef sumX, ByRef sumY)
{
	bodySamples := 0
	minX := ""
	maxX := ""
	minY := ""
	maxY := ""
	sumX := 0
	sumY := 0

	if !IsObject(capture)
		return false

	seedX := Round(centerX + 0)
	seedY := Round(centerY + 0)
	if !Divination_CaptureDepositPixel(capture, seedX, seedY)
	{
		foundSeed := false
		seedRadius := 16
		offsetY := -seedRadius
		while (offsetY <= seedRadius && !foundSeed)
		{
			offsetX := -seedRadius
			while (offsetX <= seedRadius)
			{
				testX := seedX + offsetX
				testY := seedY + offsetY
				if Divination_CaptureDepositPixel(capture, testX, testY)
				{
					seedX := testX
					seedY := testY
					foundSeed := true
					break
				}
				offsetX += 2
			}
			offsetY += 2
		}

		if !foundSeed
			return false
	}

	componentStep := 1
	componentRadius := 115
	leftLimit := Max(0, seedX - componentRadius)
	rightLimit := Min(capture.Width - 1, seedX + componentRadius)
	topLimit := Max(0, seedY - componentRadius)
	bottomLimit := Min(capture.Height - 1, seedY + componentRadius)

	queueX := [seedX]
	queueY := [seedY]
	visited := {}
	visited[seedX . "|" . seedY] := true
	head := 1

	minX := seedX
	maxX := seedX
	minY := seedY
	maxY := seedY

	while (head <= queueX.Length())
	{
		pointX := queueX[head]
		pointY := queueY[head]
		head++

		bodySamples++
		sumX += pointX
		sumY += pointY
		if (pointX < minX)
			minX := pointX
		if (pointX > maxX)
			maxX := pointX
		if (pointY < minY)
			minY := pointY
		if (pointY > maxY)
			maxY := pointY

		dyStep := -componentStep
		while (dyStep <= componentStep)
		{
			dxStep := -componentStep
			while (dxStep <= componentStep)
			{
				if (dxStep != 0 || dyStep != 0)
				{
					nextX := pointX + dxStep
					nextY := pointY + dyStep
					if (nextX >= leftLimit && nextX <= rightLimit
						&& nextY >= topLimit && nextY <= bottomLimit)
					{
						key := nextX . "|" . nextY
						if !visited.HasKey(key)
						{
							visited[key] := true
							if Divination_CaptureDepositPixel(capture, nextX, nextY)
							{
								queueX.Push(nextX)
								queueY.Push(nextY)
							}
						}
					}
				}
				dxStep += componentStep
			}
			dyStep += componentStep
		}
	}

	return (bodySamples > 0)
}


Divination_CaptureDepositPixel(capture, x, y)
{
	if !IsObject(capture)
		return false
	if (x < 0 || x >= capture.Width || y < 0 || y >= capture.Height)
		return false

	rgb := NumGet(capture.Bits + (((y * capture.Width) + x) * 4), 0, "UInt") & 0xFFFFFF
	return Divination_IsDepositColor(rgb)
}


Divination_FindFullInventoryDialog(capture)
{
	if !IsObject(capture)
		return false

	; Detect the dialog by its distinctive on-window colors, not by window geometry.
	parchmentHits := 0
	frameHits := 0
	buttonHits := 0

	step := 3
	y := 0
	while (y < capture.Height)
	{
		x := 0
		while (x < capture.Width)
		{
			rgb := NumGet(capture.Bits + (((y * capture.Width) + x) * 4), 0, "UInt") & 0xFFFFFF

			if Divination_IsFullInventoryParchmentColor(rgb)
				parchmentHits++
			else if Divination_IsFullInventoryFrameColor(rgb)
				frameHits++
			else if Divination_IsFullInventoryButtonColor(rgb)
				buttonHits++

			if (parchmentHits >= 450 && frameHits >= 60 && buttonHits >= 18)
				return true

			x += step
		}
		y += step
	}

	return false
}

Divination_IsFullInventoryParchmentColor(rgb)
{
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 198 && red <= 216
		&& green >= 179 && green <= 198
		&& blue >= 145 && blue <= 168
		&& red > green
		&& green > blue)
}

Divination_IsFullInventoryFrameColor(rgb)
{
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return ((red >= 68 && red <= 128
			&& green >= 50 && green <= 104
			&& blue >= 28 && blue <= 68)
		|| (red >= 135 && red <= 170
			&& green >= 105 && green <= 140
			&& blue >= 60 && blue <= 95))
}

Divination_IsFullInventoryButtonColor(rgb)
{
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 150 && red <= 225
		&& green >= 120 && green <= 190
		&& blue >= 65 && blue <= 120
		&& red - blue >= 55)
}


Divination_ClearResourceTarget()
{
	global DivinationTargetX, DivinationTargetY, DivinationTargetScore, DivinationTargetType
	global DivinationResourceClickTick, DivinationResourceAbsentChecks, DivinationResourceAbsentStartTick
	global DivinationResourceAbsenceLogged, DivinationNoYellowStartTick
	global DivinationResourceStartDensity, DivinationResourceTrackingEstablished, DivinationEnrichedScanTick
	global DivinationResourceSignature, DivinationResourceSignatureAbsentChecks, DivinationResourceSignatureAbsentStartTick
	global DivinationEnrichedConfirmX, DivinationEnrichedConfirmY, DivinationEnrichedConfirmCount

	DivinationTargetX := ""
	DivinationTargetY := ""
	DivinationTargetScore := 0
	DivinationTargetType := ""
	DivinationResourceClickTick := 0
	DivinationResourceAbsentChecks := 0
	DivinationResourcePresentChecks := 0
	DivinationResourceAbsentStartTick := 0
	DivinationResourceAbsenceLogged := false
	DivinationNoYellowStartTick := 0
	DivinationResourceStartDensity := 0
	DivinationResourceTrackingEstablished := false
	DivinationResourceSignature := ""
	DivinationResourceSignatureAbsentChecks := 0
	DivinationResourceSignatureAbsentStartTick := 0
	DivinationEnrichedScanTick := 0
	DivinationEnrichedConfirmX := ""
	DivinationEnrichedConfirmY := ""
	DivinationEnrichedConfirmCount := 0
}



Divination_ReadResourceDensity(centerX, centerY, targetType := "Normal")
{
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return 0
	if (DllCall("GetForegroundWindow", "Ptr") != hWnd)
		return 0

	captureMethod := ""
	capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return 0

	if (targetType = "Enriched")
		density := Divination_LocalEnrichedClusterScore(capture, centerX, centerY)
	else
		density := Divination_LocalResourceDensity(capture, centerX, centerY, targetType)

	LLARS_CreatorReleaseCapture(capture)
	return density
}

Divination_ResourcePresentAtClick(ByRef centerX, ByRef centerY, targetType, startDensity, ByRef currentDensity := 0, ByRef source := "", ByRef anyYellowVisible := true, allowGlobalReacquire := false)
{
	static lastHiddenCaptureTick := 0

	currentDensity := 0
	source := ""
	anyYellowVisible := true
	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return -1

	foreground := (DllCall("GetForegroundWindow", "Ptr") = hWnd)
	captureMethod := ""

	if (foreground)
	{
		lastHiddenCaptureTick := 0
		capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
		source := "visible"
	}
	else
	{
		if (lastHiddenCaptureTick && (A_TickCount - lastHiddenCaptureTick) < 2000)
			return -1

		lastHiddenCaptureTick := A_TickCount
		capture := LLARS_ColorCaptureBackgroundClient(hWnd, clientWidth, clientHeight, captureMethod)
		source := "hidden"
	}

	if !IsObject(capture)
		return -1

	if (targetType = "Enriched")
	{
		currentDensity := Divination_LocalEnrichedClusterScore(capture, centerX, centerY)

		if (startDensity > 0)
			minimumDensity := Max(90, Floor((startDensity + 0) * 0.55))
		else
			minimumDensity := 90

		; Density alone can be held up by nearby normal wisps after the clicked
		; enriched node has vanished. Keep the existing density tolerance, but
		; require the large connected enriched body to still exist at this target.
		enrichedBodySamples := 0
		enrichedBodyWidth := 0
		enrichedBodyHeight := 0
		if (currentDensity >= minimumDensity
			&& Divination_IsEnrichedConnectedBody(capture, centerX, centerY, currentDensity, enrichedBodySamples, enrichedBodyWidth, enrichedBodyHeight))
		{
			LLARS_CreatorReleaseCapture(capture)
			return 1
		}
	}
	else
	{
		currentDensity := Divination_LocalResourceDensity(capture, centerX, centerY, targetType)

		if (startDensity > 0)
			minimumDensity := Max(8, Floor((startDensity + 0) * 0.30))
		else
			minimumDensity := 12

		if (currentDensity >= minimumDensity)
		{
			LLARS_CreatorReleaseCapture(capture)
			return 1
		}
	}

	; Walking toward a clicked node can scroll the world under the fixed client view.
	; Before tracking is established, normal resources may be globally reacquired so
	; the initial walk/camera movement can settle. After establishment, however, the
	; clicked normal node is locked to its last confirmed screen position. After
	; lock-on, global reacquisition is disabled so depletion cannot jump tracking
	; to another nearby yellow wisp/resource.
	if (targetType != "Enriched" && !allowGlobalReacquire)
	{
		anyYellowVisible := Divination_CaptureHasResourceYellow(capture)
		LLARS_CreatorReleaseCapture(capture)
		return 0
	}

	reacquiredX := ""
	reacquiredY := ""
	reacquiredDensity := 0
	if Divination_ReacquireTrackedResource(capture, centerX, centerY, targetType, reacquiredX, reacquiredY, reacquiredDensity, allowGlobalReacquire)
	{
		oldX := centerX
		oldY := centerY
		centerX := reacquiredX
		centerY := reacquiredY
		currentDensity := reacquiredDensity

		if (Abs(centerX - oldX) >= 12 || Abs(centerY - oldY) >= 12)
			LLARS_DeveloperAction("Divination || Resource tracking shifted || (" . oldX . ", " . oldY . ") > (" . centerX . ", " . centerY . ")")

		LLARS_CreatorReleaseCapture(capture)
		return 1
	}

	; Only pay for a whole-client yellow scan when the clicked target itself is absent.
	anyYellowVisible := Divination_CaptureHasResourceYellow(capture)
	LLARS_CreatorReleaseCapture(capture)
	return 0
}

Divination_ReacquireTrackedResource(capture, oldX, oldY, targetType, ByRef foundX, ByRef foundY, ByRef foundDensity, allowGlobalReacquire := false)
{
	foundX := ""
	foundY := ""
	foundDensity := 0

	if !IsObject(capture)
		return false

	candidateX := ""
	candidateY := ""
	candidateScore := 0
	candidateDensity := 0

	if (targetType = "Enriched")
	{
		if !LLARS_ColorFindLargeClusterFromCapture(capture, "Divination_IsResourceColor", candidateX, candidateY, candidateScore, candidateDensity, 90, 4, 28, 8, 8, 2, 20, 4, "center-biased")
			return false

		bodySamples := 0
		bodyWidth := 0
		bodyHeight := 0
		if !Divination_IsEnrichedConnectedBody(capture, candidateX, candidateY, candidateScore, bodySamples, bodyWidth, bodyHeight)
			return false
	}
	else
	{
		if !LLARS_ColorFindLargeClusterFromCapture(capture, "Divination_IsResourceColor", candidateX, candidateY, candidateScore, candidateDensity, 10, 4, 48, 8, 8, 2, 20, 4, "center-biased")
			return false
	}

	; Camera/world scrolling from walking can move the same node a substantial amount on screen.
	if (!allowGlobalReacquire)
	{
		; Once tracking is established, an enriched node should only drift locally.
		; Do not silently adopt a newly spawned enriched node elsewhere on screen.
		if (targetType = "Enriched")
			reacquireRadius := Min(96, Max(64, Round(Min(capture.Width, capture.Height) * 0.10)))
		else
			reacquireRadius := Max(110, Round(Min(capture.Width, capture.Height) * 0.30))

		deltaX := candidateX - oldX
		deltaY := candidateY - oldY
		if (((deltaX * deltaX) + (deltaY * deltaY)) > (reacquireRadius * reacquireRadius))
			return false
	}

	foundX := candidateX
	foundY := candidateY
	foundDensity := candidateScore
	return true
}


Divination_CaptureHasResourceYellow(capture)
{
	if !IsObject(capture)
		return true

	; Sparse full-client scan.
	hits := 0
	step := 4
	y := 0
	while (y < capture.Height)
	{
		x := 0
		while (x < capture.Width)
		{
			rgb := NumGet(capture.Bits + (((y * capture.Width) + x) * 4), 0, "UInt") & 0xFFFFFF
			if Divination_IsResourceTrackingColor(rgb)
			{
				hits++
				if (hits >= 3)
					return true
			}

			x += step
		}
		y += step
	}

	return false
}

Divination_LocalEnrichedClusterScore(capture, centerX, centerY)
{
	if !IsObject(capture)
		return 0

	; Mirror the enriched-vs-normal size distinction used by discovery, but only inside a small area around the clicked enriched target.
	searchRadius := 84
	sampleStep := 4
	cellSize := 28

	left := Max(0, Floor(centerX - searchRadius))
	right := Min(capture.Width - 1, Ceil(centerX + searchRadius))
	top := Max(0, Floor(centerY - searchRadius))
	bottom := Min(capture.Height - 1, Ceil(centerY + searchRadius))

	cells := {}
	y := top
	while (y <= bottom)
	{
		x := left
		while (x <= right)
		{
			offset := ((y * capture.Width) + x) * 4
			rgb := NumGet(capture.Bits + offset, 0, "UInt") & 0xFFFFFF

			if Divination_IsResourceColor(rgb)
			{
				cellX := Floor((x - left) / cellSize)
				cellY := Floor((y - top) / cellSize)
				key := cellX . "|" . cellY

				if !cells.HasKey(key)
					cells[key] := 0

				cells[key]++
			}

			x += sampleStep
		}
		y += sampleStep
	}

	bestScore := 0
	for key, count in cells
	{
		parts := StrSplit(key, "|")
		baseX := parts[1] + 0
		baseY := parts[2] + 0
		clusterScore := 0

		dyCell := -1
		while (dyCell <= 1)
		{
			dxCell := -1
			while (dxCell <= 1)
			{
				neighborKey := (baseX + dxCell) . "|" . (baseY + dyCell)
				if cells.HasKey(neighborKey)
					clusterScore += cells[neighborKey]

				dxCell++
			}
			dyCell++
		}

		if (clusterScore > bestScore)
			bestScore := clusterScore
	}

	return bestScore
}


Divination_LocalResourceDensity(capture, centerX, centerY, targetType := "Normal")
{
	if !IsObject(capture)
		return 0

	radius := (targetType = "Enriched") ? 30 : 20
	offset := (targetType = "Enriched") ? 8 : 6
	bestDensity := 0

	density := LLARS_ColorDensity(capture, "Divination_IsResourceTrackingColor", centerX, centerY, radius, 2)
	if (density > bestDensity)
		bestDensity := density

	density := LLARS_ColorDensity(capture, "Divination_IsResourceTrackingColor", centerX + offset, centerY, radius, 2)
	if (density > bestDensity)
		bestDensity := density

	density := LLARS_ColorDensity(capture, "Divination_IsResourceTrackingColor", centerX - offset, centerY, radius, 2)
	if (density > bestDensity)
		bestDensity := density

	density := LLARS_ColorDensity(capture, "Divination_IsResourceTrackingColor", centerX, centerY + offset, radius, 2)
	if (density > bestDensity)
		bestDensity := density

	density := LLARS_ColorDensity(capture, "Divination_IsResourceTrackingColor", centerX, centerY - offset, radius, 2)
	if (density > bestDensity)
		bestDensity := density

	return bestDensity
}

Divination_IsEnrichedConnectedBody(capture, centerX, centerY, clusterScore, ByRef bodySamples := 0, ByRef bodyWidth := 0, ByRef bodyHeight := 0)
{
	bodySamples := 0
	bodyWidth := 0
	bodyHeight := 0

	if !IsObject(capture)
		return false

	; The large-cluster score can combine nearby normal nodes.
	seedX := centerX
	seedY := centerY

	if !Divination_CaptureResourcePixel(capture, seedX, seedY)
	{
		foundSeed := false
		seedRadius := 12
		offsetY := -seedRadius
		while (offsetY <= seedRadius && !foundSeed)
		{
			offsetX := -seedRadius
			while (offsetX <= seedRadius)
			{
				testX := centerX + offsetX
				testY := centerY + offsetY
				if Divination_CaptureResourcePixel(capture, testX, testY)
				{
					seedX := testX
					seedY := testY
					foundSeed := true
					break
				}
				offsetX += 2
			}
			offsetY += 2
		}

		if !foundSeed
			return false
	}

	componentStep := 2
	componentRadius := 140
	leftLimit := Max(0, seedX - componentRadius)
	rightLimit := Min(capture.Width - 1, seedX + componentRadius)
	topLimit := Max(0, seedY - componentRadius)
	bottomLimit := Min(capture.Height - 1, seedY + componentRadius)

	queueX := [seedX]
	queueY := [seedY]
	visited := {}
	visited[seedX . "|" . seedY] := true
	head := 1

	minX := seedX
	maxX := seedX
	minY := seedY
	maxY := seedY

	while (head <= queueX.Length())
	{
		pointX := queueX[head]
		pointY := queueY[head]
		head++

		bodySamples++
		if (pointX < minX)
			minX := pointX
		if (pointX > maxX)
			maxX := pointX
		if (pointY < minY)
			minY := pointY
		if (pointY > maxY)
			maxY := pointY

		dyStep := -componentStep
		while (dyStep <= componentStep)
		{
			dxStep := -componentStep
			while (dxStep <= componentStep)
			{
				if (dxStep != 0 || dyStep != 0)
				{
					nextX := pointX + dxStep
					nextY := pointY + dyStep

					if (nextX >= leftLimit && nextX <= rightLimit
						&& nextY >= topLimit && nextY <= bottomLimit)
					{
						key := nextX . "|" . nextY
						if !visited.HasKey(key)
						{
							visited[key] := true
							if Divination_CaptureResourcePixel(capture, nextX, nextY)
							{
								queueX.Push(nextX)
								queueY.Push(nextY)
							}
						}
					}
				}
				dxStep += componentStep
			}
			dyStep += componentStep
		}
	}

	bodyWidth := maxX - minX + 1
	bodyHeight := maxY - minY + 1

	; Scale-independent check: compare the connected body's samples with the neighborhood cluster score.
	if (clusterScore <= 0)
		return false

	bodyToClusterRatio := bodySamples / clusterScore

	; The real enriched wisp is consistently much larger than normal wisps in
	; the supported views. Keep the ratio test, but reject compact normal
	; bodies that can occasionally satisfy that ratio because of animation.
	minimumBodyWidth := 42
	minimumBodyHeight := 42
	minimumMaxSpan := 52
	return (bodyToClusterRatio >= 2.25
		&& bodyWidth >= minimumBodyWidth
		&& bodyHeight >= minimumBodyHeight
		&& Max(bodyWidth, bodyHeight) >= minimumMaxSpan)
}

Divination_CaptureResourcePixel(capture, x, y)
{
	if !IsObject(capture)
		return false
	if (x < 0 || x >= capture.Width || y < 0 || y >= capture.Height)
		return false

	rgb := NumGet(capture.Bits + (((y * capture.Width) + x) * 4), 0, "UInt") & 0xFFFFFF
	return Divination_IsResourceColor(rgb)
}


Divination_FindEnrichedCandidate(ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity, ByRef bodyWidth := 0, ByRef bodyHeight := 0, ByRef bodySamples := 0)
{
	global DivinationTargetX, DivinationTargetY, DivinationTargetType

	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0
	bodyWidth := 0
	bodyHeight := 0
	bodySamples := 0

	if !LLARS_ColorGetRuneScapeClient(hWnd, clientWidth, clientHeight)
		return false
	if (DllCall("GetForegroundWindow", "Ptr") != hWnd)
		return false

	captureMethod := ""
	capture := LLARS_ColorCaptureVisibleClient(hWnd, clientWidth, clientHeight, captureMethod)
	if !IsObject(capture)
		return false

	; If we are already on enriched, remove that node from this scan so the search
	; can see a second enriched spawn instead of returning the current one forever.
	if (DivinationTargetType = "Enriched")
		Divination_MaskCaptureArea(capture, DivinationTargetX, DivinationTargetY, 75)

	found := Divination_FindEnrichedCandidateFromCapture(capture, foundX, foundY, targetScore, targetDensity, bodyWidth, bodyHeight, bodySamples)

	LLARS_CreatorReleaseCapture(capture)
	return found
}


Divination_FindEnrichedCandidateFromCapture(capture, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity, ByRef bodyWidth := 0, ByRef bodyHeight := 0, ByRef bodySamples := 0)
{
	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0
	bodyWidth := 0
	bodyHeight := 0
	bodySamples := 0

	if !IsObject(capture)
		return false

	; LLARS' general large-cluster finder intentionally prefers the object nearest
	; screen center. For Divination that can be a normal wisp even when a larger
	; enriched wisp exists elsewhere. Reject verified-normal candidates, mask only
	; that small area, and try the next body before giving up.
	attempt := 0
	while (attempt < 6)
	{
		attempt++
		candidateX := ""
		candidateY := ""
		candidateScore := 0
		candidateDensity := 0

		if !LLARS_ColorFindLargeClusterFromCapture(capture, "Divination_IsResourceColor", candidateX, candidateY, candidateScore, candidateDensity, 90, 4, 28, 8, 8, 2, 20, 4, "center-biased")
			return false

		candidateSamples := 0
		candidateWidth := 0
		candidateHeight := 0
		if Divination_IsEnrichedConnectedBody(capture, candidateX, candidateY, candidateScore, candidateSamples, candidateWidth, candidateHeight)
		{
			foundX := candidateX
			foundY := candidateY
			targetScore := candidateScore
			targetDensity := candidateDensity
			bodyWidth := candidateWidth
			bodyHeight := candidateHeight
			bodySamples := candidateSamples
			return true
		}

		; Normal wisps are much smaller than enriched. A 38px mask removes the
		; rejected normal body without wiping a nearby enriched candidate.
		Divination_MaskCaptureArea(capture, candidateX, candidateY, 38)
	}

	return false
}


Divination_FindSmallNormalWispFromCapture(capture, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity)
{
	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0
	if !IsObject(capture)
		return false

	; Small unactivated wisps can be only a fraction of the footprint of an
	; active resource. Use a finer sampling pass, then reject isolated yellow
	; sparkles/noise with a full-resolution local-body check.
	attempt := 0
	while (attempt < 8)
	{
		attempt++
		candidateX := ""
		candidateY := ""
		candidateScore := 0
		candidateDensity := 0

		if !LLARS_ColorFindLargeClusterFromCapture(capture, "Divination_IsWispSearchColor", candidateX, candidateY, candidateScore, candidateDensity, 4, 2, 24, 3, 6, 1, 12, 2, "center-biased")
			return false

		wispSamples := 0
		wispWidth := 0
		wispHeight := 0
		if Divination_IsSmallNormalWispArea(capture, candidateX, candidateY, wispSamples, wispWidth, wispHeight)
		{
			foundX := candidateX
			foundY := candidateY
			targetScore := candidateScore
			targetDensity := candidateDensity
			return true
		}

		; Try the next independent yellow body rather than letting one tiny
		; particle near screen center hide a legitimate wisp elsewhere.
		Divination_MaskCaptureArea(capture, candidateX, candidateY, 20)
	}

	return false
}


Divination_IsSmallNormalWispArea(capture, centerX, centerY, ByRef sampleCount := 0, ByRef bodyWidth := 0, ByRef bodyHeight := 0)
{
	sampleCount := 0
	bodyWidth := 0
	bodyHeight := 0
	if !IsObject(capture)
		return false

	radius := 15
	left := Max(0, Round(centerX) - radius)
	right := Min(capture.Width - 1, Round(centerX) + radius)
	top := Max(0, Round(centerY) - radius)
	bottom := Min(capture.Height - 1, Round(centerY) + radius)
	minX := ""
	maxX := ""
	minY := ""
	maxY := ""

	y := top
	while (y <= bottom)
	{
		x := left
		while (x <= right)
		{
			rgb := NumGet(capture.Bits + (((y * capture.Width) + x) * 4), 0, "UInt") & 0xFFFFFF
			if Divination_IsWispSearchColor(rgb)
			{
				sampleCount++
				if (minX = "" || x < minX)
					minX := x
				if (maxX = "" || x > maxX)
					maxX := x
				if (minY = "" || y < minY)
					minY := y
				if (maxY = "" || y > maxY)
					maxY := y
			}
			x++
		}
		y++
	}

	if (sampleCount < 10 || minX = "")
		return false

	bodyWidth := maxX - minX + 1
	bodyHeight := maxY - minY + 1
	maxSpan := Max(bodyWidth, bodyHeight)
	minSpan := Min(bodyWidth, bodyHeight)

	; Reject single-pixel/sparkle noise, while allowing the genuinely small
	; pre-activation wisp body. Larger active nodes are handled by the existing
	; normal-resource detector before this fallback is reached.
	return (maxSpan >= 6 && minSpan >= 3 && maxSpan <= 31)
}

Divination_FindActivatedNormalFromCapture(capture, originX, originY, ByRef foundX, ByRef foundY, ByRef targetScore, ByRef targetDensity)
{
	foundX := ""
	foundY := ""
	targetScore := 0
	targetDensity := 0
	if !IsObject(capture)
		return false

	bestDistance := ""
	bestScore := -1
	attempt := 0

	while (attempt < 10)
	{
		attempt++
		candidateX := ""
		candidateY := ""
		candidateScore := 0
		candidateDensity := 0

		if !LLARS_ColorFindLargeClusterFromCapture(capture, "Divination_IsResourceColor", candidateX, candidateY, candidateScore, candidateDensity, 10, 4, 48, 8, 8, 2, 20, 4, "center-biased")
			break

		enrichedSamples := 0
		enrichedWidth := 0
		enrichedHeight := 0
		if Divination_IsEnrichedConnectedBody(capture, candidateX, candidateY, candidateScore, enrichedSamples, enrichedWidth, enrichedHeight)
		{
			Divination_MaskCaptureArea(capture, candidateX, candidateY, 75)
			continue
		}

		wispSamples := 0
		wispWidth := 0
		wispHeight := 0
		if Divination_IsSmallNormalWispArea(capture, candidateX, candidateY, wispSamples, wispWidth, wispHeight)
		{
			Divination_MaskCaptureArea(capture, candidateX, candidateY, 28)
			continue
		}

		dx := candidateX - originX
		dy := candidateY - originY
		distance := (dx * dx) + (dy * dy)
		if (bestDistance = "" || distance < bestDistance || (distance = bestDistance && candidateScore > bestScore))
		{
			bestDistance := distance
			bestScore := candidateScore
			foundX := candidateX
			foundY := candidateY
			targetScore := candidateScore
			targetDensity := candidateDensity
		}

		Divination_MaskCaptureArea(capture, candidateX, candidateY, 58)
	}

	return (foundX != "")
}

Divination_MaskCaptureArea(capture, centerX, centerY, radius)
{
	if !IsObject(capture)
		return

	left := Max(0, Floor(centerX - radius))
	right := Min(capture.Width - 1, Ceil(centerX + radius))
	top := Max(0, Floor(centerY - radius))
	bottom := Min(capture.Height - 1, Ceil(centerY + radius))

	y := top
	while (y <= bottom)
	{
		x := left
		while (x <= right)
		{
			deltaX := x - centerX
			deltaY := y - centerY
			if (((deltaX * deltaX) + (deltaY * deltaY)) <= (radius * radius))
				NumPut(0, capture.Bits + (((y * capture.Width) + x) * 4), 0, "UInt")

			x++
		}
		y++
	}
}


; ================================================================
; |     DIVINATION COLORS     -     DIVINATION COLORS            |
; ================================================================

; High Contrast resource nodes use a stable mustard-yellow fill.
Divination_IsResourceColor(rgb)
{
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 140 && red <= 185
		&& green >= 115 && green <= 155
		&& blue >= 10 && blue <= 55
		&& red - green >= 12
		&& red - green <= 35
		&& green - blue >= 75)
}

Divination_IsWispSearchColor(rgb)
{
	if Divination_IsResourceColor(rgb)
		return true

	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 175 && red <= 255
		&& green >= 145 && green <= 235
		&& blue <= 100
		&& red - green >= 4
		&& red - green <= 75
		&& green - blue >= 70)
}

; Tracking allows modest yellow animation variation, but stays deliberately narrow.
Divination_IsResourceTrackingColor(rgb)
{
	if Divination_IsResourceColor(rgb)
		return true

	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 130 && red <= 195
		&& green >= 105 && green <= 165
		&& blue >= 5 && blue <= 65
		&& red - green >= 8
		&& red - green <= 42
		&& green - blue >= 65)
}

; High Contrast deposit rifts are very large, bright, low-saturation white areas.
Divination_IsDepositColor(rgb)
{
	red := (rgb >> 16) & 0xFF
	green := (rgb >> 8) & 0xFF
	blue := rgb & 0xFF

	return (red >= 185 && green >= 185 && blue >= 180
		&& Abs(red - green) <= 18
		&& Abs(red - blue) <= 22
		&& Abs(green - blue) <= 18)
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
