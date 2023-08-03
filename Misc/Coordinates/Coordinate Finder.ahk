#SingleInstance Force
#Persistent
SetBatchLines, -1

coordcount=0

Gui +LastFound +OwnDialogs +AlwaysOnTop
Gui, Font, s11
Gui, font, bold
Gui, Add, Text, x15 y5 w240 h245, Press F10 to select the top-left coordinates`n`nPress F10 again for the bottom-right coordinates.`n`nThe coordinates will be saved in your clipboard for pasting.`n`nPress F10 a third time to clear the tooltip message.`n`nF12 to Exit
Menu, Tray, Icon, %A_ScriptDir%\LLARS Logo.ico
Gui, Show,w255 h240, LLARS

IniRead, x, LLARS Config.ini, GUI POS, guix
IniRead, y, LLARS Config.ini, GUI POS, guiy
WinMove A, ,%X%, %y%

hIcon := DllCall("LoadImage", uint, 0, str, "LLARS Logo.ico"
   	, uint, 1, int, 0, int, 0, uint, 0x10)
SendMessage, 0x80, 0, hIcon
SendMessage, 0x80, 1, hIcon

OnMessage(0x0201, "WM_LBUTTONDOWN")
WM_LBUTTONDOWN() {
	If (A_Gui)
		PostMessage, 0xA1, 2
}
return

F10::
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

F12::
guiclose:
exitapp