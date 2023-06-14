#SingleInstance Force
#Persistent
SetBatchLines, -1

isPaused := true

F11::
if (isPaused)
{
	isPaused := false
	
	IniRead, sa1, Config.ini, Timer, min
	IniRead, sa2, Config.ini, Timer, max
	Random, SleepClick, %sa1%, %sa2%
	SetTimer, RandomClick, %SleepClick%
}
else
{
	isPaused := true
	SetTimer, RandomClick, Off
}
return

RandomClick:
if (!isPaused)
{
	IniRead, x1, Config.ini, Click, xmin
	IniRead, x2, Config.ini, Click, xmax
	IniRead, y1, Config.ini, Click, ymin
	IniRead, y2, Config.ini, Click, ymax
	Random, x, %x1%, %x2%
	Random, y, %y1%, %y2%
	Click, %x%, %y%
	
	IniRead, sa1, Config.ini, Timer, min
	IniRead, sa2, Config.ini, Timer, max
	Random, SleepClick, %sa1%, %sa2%
	SetTimer, RandomClick, %SleepClick%
}
return

F12::
GuiClose:
ExitApp
