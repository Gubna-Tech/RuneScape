#SingleInstance Force
#Persistent
SetBatchLines, -1

DetectHiddenWindows, On
closeotherllars()

IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit

settimer, configcheck, 250

scriptname := regexreplace(A_scriptname,"\..*","")

Hotkey %lhk1%, Start
Hotkey %lhk2%, coordb
Hotkey %lhk3%, Configb
Hotkey %lhk4%, exitb

Gui +LastFound +OwnDialogs +AlwaysOnTop
Gui, Font, s11
Gui, font, bold
Gui, Add, Button, x15 y5 w190 h25 gStart , Start %scriptname%
Gui, Add, Button, x15 y35 w90 h25 gCoordb , Coordinates
Gui, Add, Button, x115 y35 w90 h25 gConfigb , Config File
Gui, Add, Button, x35 y140 w150 h25 gExitb , Exit LLARS
Gui, Add, Text, x135 y90 w100 h25 vCounter
Gui, Add, Text, x8 y90 w125 h25, Total Run Count
Gui, Add, Text, x8 y65 w125 h25, Run Count
Gui, Add, Text, x135 y65 w150 h25 vCounter2
Gui, Font, cGreen
Gui, Add, Text, x135 y115 w70 h25 vState1
Gui, Add, Text, x8 y115 w125 h25 vScriptGreen
Gui, Font, cBlue
Gui, Add, Text, x135 y115 w70 h25 vState3
Gui, Add, Text, x8 y115 w125 h25 vScriptBlue
Gui, Font, cRed
Gui, Add, Text, x135 y115 w70 h25 vState2
Gui, Add, Text, x8 y115 w125 h25 vScriptRed
GuiControl,,State2, ** OFF **
Gui, Add, Text, x8 y115 w125 h25, %scriptname%
Gui, Show,w220 h170, LLARS

IniRead, x, LLARS Config.ini, GUI POS, guix
IniRead, y, LLARS Config.ini, GUI POS, guiy
WinMove A, ,%X%, %y%

coordcount = 0
frcount = 0

OnMessage(0x0201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN() {
	If (A_Gui)
		PostMessage, 0xA1, 2
}
return

CloseOtherLLARS()
{
	WinGet, hWndList, List, LLARS
	
	Loop, %hWndList%
	{
		hWnd := hWndList%A_Index%
		WinClose, % "ahk_id " hWnd
	}
}

CoordB:
If (coordcount = 0)
{
	++coordcount
	CoordMode, Mouse, Screen
	MouseGetPos,X,Y
	settimer, tooltipcoord1, 25	
	return
}
else if (coordcount = 1)
{	
	++coordcount
	CoordMode, Mouse, Screen	
	MouseGetPos,X2,Y2
	IniWrite,----------`nxmin=%x%`nxmax=%x2%`nymin=%y%`nymax=%y2%,Coordinates.ini, Coordinates [%A_Hour%:%A_Min%:%A_Sec%] - %A_MM%/%A_DD%
	settimer, tooltipcoord1, OFF
	settimer, tooltipcoord2, 100
	clipboard =
(
xmin=%x%
xmax=%x2%
ymin=%y%
ymax=%y2%
)
	ClipWait
	clipboard := clipboard
	return
}
else if (coordcount = 2)
{
	settimer, tooltipcoord2, off
	ToolTip
	coordcount = 0
	return
}
Return

tooltipcoord1:
mousegetpos xn, yn
ToolTip,x=%X% y=%Y%, (xn+7), (yn+7),1
return

tooltipcoord2:
mousegetpos xn, yn
ToolTip, xmin=%x%`nxmax=%x2%`nymin=%y%`nymax=%y2%`n`nCoordinates are stored in clipboard and`n%A_ScriptDir%\Coordinates.ini`n`nPress F10 to clear this message, (xn+7), (yn+7),1
return

ConfigB:
Run %A_ScriptDir%\Config.ini
Return

ResumeB:
GuiControl,,State3, Running
GuiControl,,ScriptBlue, %scriptname%
Pause
Return

PauseB:
GuiControl,,State2, Paused
GuiControl,,ScriptRed, %scriptname%
Pause
Return

Configcheck:
{
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
}
return

UpdateCountdown:
RemainingTime := EndTime - A_TickCount
if (RemainingTime > 0) {
	GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RemainingTime)
}
return

RandomSleepAmountToMinutesSeconds(time) {
	minutes := Floor(time / 60000)
	seconds := Mod(Floor(time / 1000), 60)
	return minutes . "m " . seconds . "s"
}
return

ExitB:
guiclose:
exitapp

Start:
If (frcount = 0)
{
	IniRead, lhk1, LLARS Config.ini, LLARS Hotkey, start
	IniRead, lhk2, LLARS Config.ini, LLARS Hotkey, coord/pause
	IniRead, lhk3, LLARS Config.ini, LLARS Hotkey, config/resume
	IniRead, lhk4, LLARS Config.ini, LLARS Hotkey, exit
	
	Hotkey %lhk1%, Start
	Hotkey %lhk2%, pauseb
	Hotkey %lhk3%, resumeb
	Hotkey %lhk4%, exitb
	
	WinGetPos, X, Y,,, LLARS
	Gui destroy
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	Gui, Font, s11
	Gui, font, bold
	Gui, Add, Button, x15 y5 w190 h25 gStart , Start %scriptname%
	Gui, Add, Button, x15 y35 w90 h25 gPauseb , Pause
	Gui, Add, Button, x115 y35 w90 h25 gResumeb , Resume
	Gui, Add, Button, x35 y140 w150 h25 gExitb , Exit LLARS
	Gui, Add, Text, x135 y90 w65 h25 center vCounter
	Gui, Add, Text, x8 y90 w125 h25, Total Run Count
	Gui, Add, Text, x8 y65 w125 h25, Run Count
	Gui, Add, Text, x135 y65 w150 h25 vCounter2
	Gui, Font, cGreen
	Gui, Add, Text, x135 y115 w70 h25 vState1
	Gui, Add, Text, x8 y115 w125 h25 vScriptGreen
	Gui, Font, cBlue
	Gui, Add, Text, x135 y115 w70 h25 vState3
	Gui, Add, Text, x8 y115 w125 h25 vScriptBlue
	Gui, Font, cRed
	Gui, Add, Text, x135 y115 w70 h25 vState2
	Gui, Add, Text, x8 y115 w125 h25 vScriptRed
	GuiControl,,State2, ** OFF **
	Gui, Add, Text, x8 y115 w125 h25, %scriptname%
	Gui, Show,w220 h170, LLARS
	WinMove, LLARS,, X, Y,
	
	count = 0
	++frcount
}

else
	
sleep 250

InputBox, runcount, Run How Many Times?,,,250, 100
if (runcount = "" or runcount = 0)
{
	MsgBox, 48, Invalid Input, Please enter a valid number greater than 0.
	return
}

sleep 250

GuiControl,,ScriptBlue, %scriptname% 
GuiControl,,State3, Running

runcount3 = %runcount%
count2 = 0
firstrun = 0
StartTime := A_TickCount
StartTimeStamp = %A_Hour%:%A_Min%:%A_Sec%
sleepcount = 0
totalSleepTime := 0

loop % runcount
{ 	
	If firstrun = 0
	{
		winactivate, RuneScape	
		
		++count
		++count2
		
		GuiControl,,Counter, %count%
		GuiControl,,Counter2, %count2% / %runcount3%
		GuiControl,,ScriptBlue, %scriptname%
		GuiControl,,State3, Running

		CoordMode, Mouse, Screen
		IniRead, x1, Config.ini, Trellis Prime, xmin
		IniRead, x2, Config.ini, Trellis Prime, xmax
		IniRead, y1, Config.ini, Trellis Prime, ymin
		IniRead, y2, Config.ini, Trellis Prime, ymax
		if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, %scriptname%		
			GuiControl,,State2, ERROR
			MsgBox, 48, Config Error, Please enter valid coordinates for [Trellis Prime] in the config.
			return
		}
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%
		
		IniRead, sa1, Config.ini, Sleep Climb 1, min
		IniRead, sa2, Config.ini, Sleep Climb 1, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
	}
	If firstrun = 1
	{
		++count
		++count2
		firstrun=0
		
		winactivate, RuneScape	
		
		GuiControl,,Counter, %count%
		GuiControl,,Counter2, %count2% / %runcount3%
		GuiControl,,ScriptBlue, %scriptname%
		GuiControl,,State3, Running
		
		CoordMode, Mouse, Screen
		IniRead, x1, Config.ini, Trellis Main, xmin
		IniRead, x2, Config.ini, Trellis Main, xmax
		IniRead, y1, Config.ini, Trellis Main, ymin
		IniRead, y2, Config.ini, Trellis Main, ymax
		if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, %scriptname%		
			GuiControl,,State2, ERROR
			MsgBox, 48, Config Error, Please enter valid coordinates for [Trellis Main] in the config.
			return
		}
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%	
		
		IniRead, sa1, Config.ini, Sleep Climb 2, min
		IniRead, sa2, Config.ini, Sleep Climb 2, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%
	}
	If firstrun = 0
	{
		++firstrun
		
		CoordMode, Mouse, Screen
		IniRead, x1, Config.ini, Ladder, xmin
		IniRead, x2, Config.ini, Ladder, xmax
		IniRead, y1, Config.ini, Ladder, ymin
		IniRead, y2, Config.ini, Ladder, ymax
		if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
		{
			Run %A_ScriptDir%\Config.ini
			GuiControl,,ScriptRed, %scriptname%		
			GuiControl,,State2, ERROR
			MsgBox, 48, Config Error, Please enter valid coordinates for [Ladder] in the config.
			return
		}
		Random, x, %x1%, %x2%
		Random, y, %y1%, %y2%
		Click, %x%, %y%
		
		IniRead, sa1, Config.ini, Sleep Ladder, min
		IniRead, sa2, Config.ini, Sleep Ladder, max
		Random, SleepAmount, %sa1%, %sa2%
		Sleep, %SleepAmount%	
		
		IniRead, option, LLARS Config.ini, Random Sleep, option
		if option = true
		{
			IniRead, chance, LLARS Config.ini, Random Sleep, chance
			Random, RandomNumber, 1, 100
			
			if % RandomNumber <= chance
			{
				
				++sleepcount
				GuiControl,, ScriptBlue, Random Sleep
				GuiControl,, State3, % RandomSleepAmountToMinutesSeconds(RandomSleepAmount)
				
				IniRead, rs1, LLARS Config.ini, Random Sleep, min
				IniRead, rs2, LLARS Config.ini, Random Sleep, max
				Random, RandomSleepAmount, %rs1%, %rs2%
				
				SetTimer, UpdateCountdown, 1000
				EndTime := A_TickCount + RandomSleepAmount
				totalSleepTime += RandomSleepAmount
				Sleep, RandomSleepAmount
				SetTimer, UpdateCountdown, Off
				
				GuiControl,,ScriptBlue, %scriptname%
				GuiControl,,State3, Running
			}
		}
	}	
}

IniRead, option, LLARS Config.ini, Logout, option
if option=true
{
	send {esc}	
	
	IniRead, sa1, Config.ini, Sleep Short, min
	IniRead, sa2, Config.ini, Sleep Short, max
	Random, SleepAmount, %sa1%, %sa2%
	Sleep, %SleepAmount%	
	
	CoordMode, Mouse, Screen
	IniRead, x1, LLARS Config.ini, Logout, xmin
	IniRead, x2, LLARS Config.ini, Logout, xmax
	IniRead, y1, LLARS Config.ini, Logout, ymin
	IniRead, y2, LLARS Config.ini, Logout, ymax
	if (x1 = "" or x2 = "" or y1 = "" or y2 = "")
	{
		Run %A_ScriptDir%\Config.ini
		GuiControl,,ScriptRed, %scriptname%		
		GuiControl,,State2, ERROR
		MsgBox, 48, Config Error, Please enter valid coordinates in the config for Logout.
		return
	}
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	Click, %x%, %y%
}

GuiControl,,ScriptGreen, %scriptname%
GuiControl,,State1, Finished

EndTimeStamp = %A_Hour%:%A_Min%:%A_Sec%
EndTime := A_TickCount
TotalTime := (EndTime - StartTime) / 1000
AverageTime := TotalTime / runcount3

TotalTimeHours := Floor(TotalTime / 3600)
TotalTimeMinutes := Mod(Floor(TotalTime / 60), 60)
TotalTimeSeconds := Mod(TotalTime, 60)

AverageTimeMinutes := Floor(AverageTime / 60)
AverageTimeSeconds := Mod(AverageTime, 60)

TotalTimeHours := Round(TotalTimeHours)
TotalTimeMinutes := Round(TotalTimeMinutes)
TotalTimeSeconds := Round(TotalTimeSeconds)
AverageTimeMinutes := Round(AverageTimeMinutes)
AverageTimeSeconds := Round(AverageTimeSeconds)

percentage := Round((sleepcount / runcount) * 100)

totalSleepTimeSeconds := Floor(totalSleepTime / 1000)
TotalSleepHours := Floor(totalSleepTimeSeconds / 3600)
TotalSleepMinutes := Floor(Mod(totalSleepTimeSeconds, 3600) / 60)
TotalSleepSeconds := Mod(totalSleepTimeSeconds, 60)

SoundPlay, C:\Windows\Media\Ring06.wav, 1
IniRead, chance, LLARS Config.ini, Random Sleep, chance
MsgBox, 64, LLARS Run Info, %scriptname% has completed %runcount3% runs`n`nTotal time: %TotalTimeHours%h : %TotalTimeMinutes%m : %TotalTimeSeconds%s`nAverage loop: %AverageTimeMinutes%m : %AverageTimeSeconds%s`n`nStart time: %starttimestamp%`nEnd time: %endtimestamp%`n`nSet chance: %chance%`%`nActual chance: %percentage%`%`nTotal random sleeps: %sleepcount%`nTotal time slept: %TotalSleepHours%h : %TotalSleepMinutes%m : %TotalSleepSeconds%s

return