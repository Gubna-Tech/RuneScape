#SingleInstance Force
#Persistent
SetBatchLines, -1

f2::
send {w down}
sleep 750
send {w up}
sleep 25
send {right down}
IniRead, sa, Config.ini, Sleep Camera, time
sleep %sa%
send {right up}
return

f3::
guiclose:
exitapp