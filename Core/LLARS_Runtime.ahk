; ================================================================
; |     LLARS RUNTIME LIBRARY     -     LLARS RUNTIME LIBRARY    |
; ================================================================

; Calculates the configured average loop time used for RunCount estimates.
CalculateScriptRuntime()
{
	global EstConfiguredLoopMin
	global EstConfiguredLoopMax
	global EstConfiguredLoopAverage
	global EstConfiguredFirstLoopAverage, EstConfiguredFollowingLoopAverage
	global EstRuntimeCalculated
	global EstimationRunCount
	global EstFinalFirstSleepID, EstFinalFollowingSleepID

	EstConfiguredLoopMin := 0
	EstConfiguredLoopMax := 0
	EstConfiguredLoopAverage := 0
	EstConfiguredFirstLoopAverage := 0
	EstConfiguredFollowingLoopAverage := 0
	EstFinalFirstSleepID := 0
	EstFinalFollowingSleepID := 0
	EstRuntimeCalculated := false

	; Read only the section of this script marked for LLARS editing.
	FileRead, ScriptContents, %A_ScriptFullPath%

	; Build the marker text in pieces so FileRead does not find the
	; marker strings inside this function itself.
	BeginMarker := "SCRIPT_EDIT_" . "BEGIN_4C4C415253"
	EndMarker := "SCRIPT_EDIT_" . "END_4C4C415253"
	StartPos := InStr(ScriptContents, "; " . BeginMarker)
	if (!StartPos)
		return false

	EndSearchPos := StartPos + StrLen("; " . BeginMarker)
	EndPos := InStr(ScriptContents, "; " . EndMarker, false, EndSearchPos)
	if (!EndPos)
		return false

	ScriptSection := SubStr(ScriptContents, EndSearchPos, EndPos - EndSearchPos)
	ScriptSectionLineOffset := StrLen(SubStr(ScriptContents, 1, EndSearchPos)) - StrLen(StrReplace(SubStr(ScriptContents, 1, EndSearchPos), "`n", ""))
	if (!ParseLLARSRuntime(ScriptSection, ScriptSectionLineOffset, FirstLoopAverage, FollowingLoopAverage, FirstLoopMin, FirstLoopMax, FollowingLoopMin, FollowingLoopMax, FirstFinalSleepID, FollowingFinalSleepID))
		return false

	EstFinalFirstSleepID := FirstFinalSleepID
	EstFinalFollowingSleepID := FollowingFinalSleepID
	EstConfiguredFirstLoopAverage := FirstLoopAverage
	EstConfiguredFollowingLoopAverage := FollowingLoopAverage

	if InStr(ScriptSection, "LLARS_FinalSleep(")
	{
		IniRead, FinalSleepOption, %LLARS_CONFIG_FILE%, Random Sleep, option, false
		StringLower, FinalSleepOption, FinalSleepOption
		IniRead, FinalSleepChance, %LLARS_CONFIG_FILE%, Random Sleep, chance, 0
		if (FinalSleepOption = "true" && FinalSleepChance + 0 > 0)
		{
			EstFinalFirstSleepID := 0
			EstFinalFollowingSleepID := 0
		}
	}

	if (FirstLoopAverage <= 0 || FollowingLoopAverage <= 0)
		return false

	; Use the fixed estimation count only to stabilize the mathematical
	; average. It never changes the user's actual runcount.
	if (EstimationRunCount <= 1)
	{
		EstConfiguredLoopAverage := FirstLoopAverage
		EstConfiguredLoopMin := FirstLoopMin
		EstConfiguredLoopMax := FirstLoopMax
	}
	else
	{
		EstConfiguredLoopAverage := (FirstLoopAverage + ((EstimationRunCount - 1) * FollowingLoopAverage)) / EstimationRunCount
		EstConfiguredLoopMin := FirstLoopMin
		EstConfiguredLoopMax := FollowingLoopMax
	}

	if (EstConfiguredLoopAverage <= 0)
		return false

	EstRuntimeCalculated := true
	return true
}

; Parses the marked script section and separates first-loop timing from
; timing used by subsequent loops.
ParseLLARSRuntime(ScriptSection, ScriptSectionLineOffset, ByRef FirstAverage, ByRef FollowingAverage, ByRef FirstMin, ByRef FirstMax, ByRef FollowingMin, ByRef FollowingMax, ByRef FirstFinalSleepID, ByRef FollowingFinalSleepID)
{
	FirstAverage := 0
	FollowingAverage := 0
	FirstMin := 0
	FirstMax := 0
	FollowingMin := 0
	FollowingMax := 0
	FirstFinalSleepID := 0
	FollowingFinalSleepID := 0

	; Split the editable script into lines so timer occurrences can be
	; matched to their actual branch instead of counting every timer in
	; the file as though it runs on every loop.
	Lines := []
	Loop, Parse, ScriptSection, `n, `r
		Lines.Push(A_LoopField)
	TimerEntries := []
	LineCount := Lines.Length()
	Loop, % LineCount
	{
		Index := A_Index
		Line := Trim(Lines[Index])
		if (!RegExMatch(Line, "i)^IniRead\s*,\s*\w+\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*min\s*$", Match))
			continue
		ConfigFile := Trim(Match1)
		SectionName := Trim(Match2)
		MaxIndex := 0
		SleepIndex := 0
		IsEstimatedSleep := false
		Loop, 5
		{
			CheckIndex := Index + A_Index
			if (CheckIndex > LineCount)
				break
			CheckLine := Trim(Lines[CheckIndex])
			if (MaxIndex = 0 && RegExMatch(CheckLine, "i)^IniRead\s*,\s*\w+\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*max\s*$", MaxMatch))
			{
				if (Trim(MaxMatch1) = ConfigFile && Trim(MaxMatch2) = SectionName)
					MaxIndex := CheckIndex
			}

			if (MaxIndex > 0 && RegExMatch(CheckLine, "i)^LLARS_(?:Estimated|Final)Sleep\(\s*[^,]+\s*\)\s*$"))
			{
				SleepIndex := CheckIndex
				IsEstimatedSleep := true
				break
			}

			if (MaxIndex > 0 && RegExMatch(CheckLine, "i)^Sleep\s*,\s*%[^%]+%\s*$"))
			{
				SleepIndex := CheckIndex
				break
			}
		}

		if (MaxIndex = 0 || SleepIndex = 0)
			continue
		IniRead, MinValue, %ConfigFile%, %SectionName%, min, ERROR
		IniRead, MaxValue, %ConfigFile%, %SectionName%, max, ERROR
		if (MinValue = "ERROR" || MaxValue = "ERROR")
			continue
		if (MinValue = "" || MaxValue = "")
			continue
		if (MinValue + 0 < 0 || MaxValue + 0 < MinValue + 0)
			continue
		Entry := {}
		Entry.Min := MinValue + 0
		Entry.Max := MaxValue + 0
		Entry.Average := (Entry.Min + Entry.Max) / 2
		Entry.Line := SleepIndex
		Entry.SourceLine := ScriptSectionLineOffset + SleepIndex
		Entry.File := ConfigFile
		Entry.Section := SectionName
		Entry.Weight := 1.0
		Entry.IsEstimatedSleep := IsEstimatedSleep
		TimerEntries.Push(Entry)
	}

	if (TimerEntries.Length() = 0)
		return false

	; Locate config option blocks so disabled script features do not
	; contribute timers to the configured runtime estimate.
	OptionBlocks := []
	Loop, % LineCount
	{
		Index := A_Index
		Line := Trim(Lines[Index])
		if (!RegExMatch(Line, "i)^IniRead\s*,\s*(\w+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)(?:\s*,.*)?$", OptionMatch))
			continue
		OptionVariable := Trim(OptionMatch1)
		OptionConfigFile := Trim(OptionMatch2)
		OptionSection := Trim(OptionMatch3)
		OptionKey := Trim(OptionMatch4)
		IfIndex := 0
		Loop, 6
		{
			CheckIndex := Index + A_Index
			if (CheckIndex > LineCount)
				break
			CheckLine := Trim(Lines[CheckIndex])
			if (RegExMatch(CheckLine, "i)^if\s*(?:\(\s*)?" . OptionVariable . "\s*=\s*(?:""true""|true)\s*(?:\)\s*)?$"))
			{
				IfIndex := CheckIndex
				break
			}
		}

		if (IfIndex = 0)
			continue
		OpenIndex := IfIndex + 1
		Loop
		{
			while (OpenIndex <= LineCount && Trim(Lines[OpenIndex]) = "")
				OpenIndex++
			if (OpenIndex > LineCount)
				break
			OpenLine := Trim(Lines[OpenIndex])
			if (InStr(OpenLine, "{"))
				break
			if (!RegExMatch(OpenLine, "i)^if\b"))
				break
			OpenIndex++
		}

		if (OpenIndex > LineCount || !InStr(Trim(Lines[OpenIndex]), "{"))
			continue
		BlockDepth := 0
		EndIndex := OpenIndex
		Loop
		{
			BlockLine := Lines[EndIndex]
			BlockDepth += StrLen(BlockLine) - StrLen(StrReplace(BlockLine, "{", ""))
			BlockDepth -= StrLen(BlockLine) - StrLen(StrReplace(BlockLine, "}", ""))
			if (BlockDepth <= 0)
				break
			EndIndex++
			if (EndIndex > LineCount)
				break
		}

		IniRead, OptionValue, %OptionConfigFile%, %OptionSection%, %OptionKey%, false
		StringLower, OptionValue, OptionValue
		OptionBlock := {}
		OptionBlock.Start := IfIndex
		OptionBlock.End := EndIndex
		OptionBlock.Enabled := (OptionValue = "true")
		OptionBlocks.Push(OptionBlock)
	}

	; Locate top-level firstrun branches and calculate whether each branch
	; executes on the first loop and on following loops.
	BranchBlocks := []
	Depth := 0
	FirstPathState := 0
	FollowingPathState := 1
	Loop, % LineCount
	{
		Index := A_Index
		Line := Trim(Lines[Index])
		if (Depth = 1 && RegExMatch(Line, "i)^if\s*(?:\(\s*)?firstrun\s*=\s*(0|1)\s*(?:\)\s*)?$", BranchMatch))
		{
			State := BranchMatch1
			OpenIndex := Index + 1
			while (OpenIndex <= LineCount && Trim(Lines[OpenIndex]) = "")
				OpenIndex++
			if (OpenIndex <= LineCount && InStr(Trim(Lines[OpenIndex]), "{"))
			{
				BlockDepth := 0
				EndIndex := OpenIndex
				Loop
				{
					BlockLine := Lines[EndIndex]
					BlockDepth += StrLen(BlockLine) - StrLen(StrReplace(BlockLine, "{", ""))
					BlockDepth -= StrLen(BlockLine) - StrLen(StrReplace(BlockLine, "}", ""))
					if (BlockDepth <= 0)
						break
					EndIndex++
					if (EndIndex > LineCount)
						break
				}

				Branch := {}
				Branch.State := State
				Branch.Start := Index
				Branch.End := EndIndex
				Branch.FirstEnabled := (FirstPathState = State)
				Branch.FollowingEnabled := (FollowingPathState = State)

				if (Branch.FirstEnabled)
				{
					MutationIndex := OpenIndex + 1
					while (MutationIndex < EndIndex)
					{
						MutationLine := Trim(Lines[MutationIndex])
						if (RegExMatch(MutationLine, "i)^firstrun\s*:?=\s*(0|1)\s*$", MutationMatch))
							FirstPathState := MutationMatch1 + 0
						else if (RegExMatch(MutationLine, "i)^(?:\+\+firstrun|firstrun\+\+)\s*$"))
							++FirstPathState
						else if (RegExMatch(MutationLine, "i)^(?:--firstrun|firstrun--)\s*$"))
							--FirstPathState
						MutationIndex++
					}
				}

				if (Branch.FollowingEnabled)
				{
					MutationIndex := OpenIndex + 1
					while (MutationIndex < EndIndex)
					{
						MutationLine := Trim(Lines[MutationIndex])
						if (RegExMatch(MutationLine, "i)^firstrun\s*:?=\s*(0|1)\s*$", MutationMatch))
							FollowingPathState := MutationMatch1 + 0
						else if (RegExMatch(MutationLine, "i)^(?:\+\+firstrun|firstrun\+\+)\s*$"))
							++FollowingPathState
						else if (RegExMatch(MutationLine, "i)^(?:--firstrun|firstrun--)\s*$"))
							--FollowingPathState
						MutationIndex++
					}
				}

				BranchBlocks.Push(Branch)
			}
		}

		Depth += StrLen(Line) - StrLen(StrReplace(Line, "{", ""))
		Depth -= StrLen(Line) - StrLen(StrReplace(Line, "}", ""))
	}

	HasFirstRunBranches := (BranchBlocks.Length() > 0)
	FirstTotal := 0
	FirstMinTotal := 0
	FirstMaxTotal := 0
	FollowingTotal := 0
	FollowingMinTotal := 0
	FollowingMaxTotal := 0

	; Add each discovered timer only to the loop path(s) that execute it.
	for _, Entry in TimerEntries
	{
		EntryDisabled := false
		for _, OptionBlock in OptionBlocks
		{
			if (!OptionBlock.Enabled && Entry.Line >= OptionBlock.Start && Entry.Line <= OptionBlock.End)
			{
				EntryDisabled := true
				break
			}
		}

		if (EntryDisabled)
			continue

		RunsFirst := true
		RunsFollowing := true
		for _, Branch in BranchBlocks
		{
			if (Entry.Line >= Branch.Start && Entry.Line <= Branch.End)
			{
				RunsFirst := Branch.FirstEnabled
				RunsFollowing := Branch.FollowingEnabled
				break
			}
		}

		; Random Sleep is conditional and is represented by its expected value.
		EntrySectionLower := Entry.Section
		StringLower, EntrySectionLower, EntrySectionLower
		if (EntrySectionLower = "random sleep")
		{
			ConfigFile := Entry.File
			ConfigSection := Entry.Section
			IniRead, Chance, %ConfigFile%, %ConfigSection%, chance, 0
			if (Chance = "" || Chance + 0 < 0 || Chance + 0 > 100)
				Chance := 0
			Entry.Weight := (Chance + 0) / 100
		}

		ContributionAverage := Entry.Average * Entry.Weight
		ContributionMin := Entry.Min * Entry.Weight
		ContributionMax := Entry.Max * Entry.Weight

		if (RunsFirst)
		{
			FirstTotal += ContributionAverage
			FirstMinTotal += ContributionMin
			FirstMaxTotal += ContributionMax
			if (Entry.Weight > 0)
			{
				if (Entry.IsEstimatedSleep)
					FirstFinalSleepID := Entry.SourceLine
				else
					FirstFinalSleepID := 0
			}
		}

		if (RunsFollowing)
		{
			FollowingTotal += ContributionAverage
			FollowingMinTotal += ContributionMin
			FollowingMaxTotal += ContributionMax
			if (Entry.Weight > 0)
			{
				if (Entry.IsEstimatedSleep)
					FollowingFinalSleepID := Entry.SourceLine
				else
					FollowingFinalSleepID := 0
			}
		}
	}

	if (!HasFirstRunBranches)
	{
		FirstTotal := FollowingTotal
		FirstMinTotal := FollowingMinTotal
		FirstMaxTotal := FollowingMaxTotal
		FirstFinalSleepID := FollowingFinalSleepID
	}

	FirstAverage := FirstTotal
	FollowingAverage := FollowingTotal
	FirstMin := FirstMinTotal
	FirstMax := FirstMaxTotal
	FollowingMin := FollowingMinTotal
	FollowingMax := FollowingMaxTotal
	if (FirstAverage <= 0 || FollowingAverage <= 0)
		return false

	return true
}

; Performs an optional logout after the timed run completes. The logout
; process uses Escape, a randomized delay, and a random point inside
; the configured logout rectangle from LLARS Config.ini.
; Performs the shared end-of-run logout action when Logout is enabled.
Logout(){
	IniRead, option, %LLARS_CONFIG_FILE%, Logout, option
	Log("LOGOUT CHECK", "Logout option = " option)
	if option=true
	{
		Log("LOGOUT", "Logout initiated")
		send {esc}
		IniRead, sa1, Config.ini, Sleep Short, min
		IniRead, sa2, Config.ini, Sleep Short, max
		Random, SleepAmount, %sa1%, %sa2%
		Log("LOGOUT WAIT", "Random sleep before logout click: " SleepAmount " ms")
		Sleep, %SleepAmount%
		IniRead, x1, %LLARS_CONFIG_FILE%, Logout, xmin
		IniRead, x2, %LLARS_CONFIG_FILE%, Logout, xmax
		IniRead, y1, %LLARS_CONFIG_FILE%, Logout, ymin
		IniRead, y2, %LLARS_CONFIG_FILE%, Logout, ymax
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Log("LOGOUT CLICK", "Logout coordinates X=" x " Y=" y)
		Click, %x%, %y%
		Log("LOGOUT", "Logout click completed")
	}
}
