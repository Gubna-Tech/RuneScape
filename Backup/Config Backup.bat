@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "llarsRoot=%%~fI"
set "source=%llarsRoot%\Scripts"
set "backupRoot=%~dp0Config Backup"
set "destination=%backupRoot%\Scripts"
set "automatic=0"
set "failed=0"

if /I "%~1"=="--auto" set "automatic=1"

if not exist "%backupRoot%" mkdir "%backupRoot%" >nul 2>&1
if errorlevel 1 set "failed=1"
if not exist "%destination%" mkdir "%destination%" >nul 2>&1
if errorlevel 1 set "failed=1"

if exist "%llarsRoot%\LLARS Config.ini" (
    copy /Y "%llarsRoot%\LLARS Config.ini" "%backupRoot%\LLARS Config.ini" >nul
    if errorlevel 1 (
        set "failed=1"
    ) else if "%automatic%"=="0" (
        echo Backed up shared config: "%llarsRoot%\LLARS Config.ini"
    )
) else (
    set "failed=1"
    if "%automatic%"=="0" echo Missing shared config: "%llarsRoot%\LLARS Config.ini"
)

for /r "%source%" %%G in (*) do (
    if /I "%%~nxG"=="Config.ini" (
        set "filepath=%%~dpG"
        set "filepath=!filepath:%source%=%destination%!"
        if not exist "!filepath!" mkdir "!filepath!" >nul 2>&1
        if errorlevel 1 set "failed=1"
        copy /Y "%%G" "!filepath!\%%~nxG" >nul
        if errorlevel 1 (
            set "failed=1"
        ) else if "%automatic%"=="0" (
            echo Backed up script config: "%%G"
        )
    )
)

if "%automatic%"=="0" (
    echo.
    if "%failed%"=="0" (
        echo Configuration backup complete.
        echo Backup folder: "%backupRoot%"
    ) else (
        echo Configuration backup completed with one or more errors.
    )
    pause
)

exit /b %failed%
