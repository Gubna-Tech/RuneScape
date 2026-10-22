@echo off
setlocal EnableExtensions
for %%I in ("%~dp0..\..") do set "LLARS_ROOT=%%~fI"
set "PS=%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe"

if /I "%~1"=="finalize" exit /b 0

echo LLARS AutoHotInterception Full Uninstall
echo.
echo This runs the official Interception uninstaller once, verifies the
echo keyboard/mouse filter registrations were removed, and then requires one
echo Windows restart to finish unloading the driver.
echo.
echo Close any running LLARS scripts before continuing.
echo.
pause

"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%LLARS_ROOT%\Core\LLARS_AHI_Setup.ps1" -ProjectRoot "%LLARS_ROOT%" -Uninstall
set "RC=%ERRORLEVEL%"
if "%RC%"=="3010" goto UNINSTALL_OK
if "%RC%"=="0" goto UNINSTALL_OK
goto FAILED

:UNINSTALL_OK
echo.
echo AutoHotInterception / Interception was removed successfully.
echo LLARS verified the Interception keyboard/mouse filter registrations are gone.
echo.
echo Windows must restart once to finish unloading/deleting any pending driver remnants.
echo After that restart, uninstall is complete.
echo This LLARS copy will use standard AutoHotkey input afterward.
echo.
choice /C YN /N /M "Restart Windows now? [Y/N]: "
if errorlevel 2 (
    echo.
    echo Restart is still required. LLARS will remind you until Windows restarts once.
    pause
    exit /b 0
)
shutdown /r /t 0
exit /b 0

:FAILED
echo.
echo AutoHotInterception / Interception uninstall could not be verified.
echo Do NOT manually delete keyboard.sys or mouse.sys.
echo.
echo Copy/paste these files to Gubna:
echo   Vendor\AutoHotInterception\Logs\AutoHotInterception-Setup.log
echo   Vendor\AutoHotInterception\Logs\AutoHotInterception-Setup-Error.txt
echo.
pause
exit /b %RC%
