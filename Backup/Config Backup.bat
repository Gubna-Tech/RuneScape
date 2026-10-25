@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "llarsRoot=%%~fI"
set "source=%llarsRoot%\Scripts"
set "backupRoot=%~dp0Config Backup"
set "backup1=%~dp0Config Backup 1"
set "backup2=%~dp0Config Backup 2"
set "staging=%~dp0Config Backup.tmp"
set "destination=%staging%\Scripts"
set "automatic=0"
set "failed=0"

if /I "%~1"=="--auto" set "automatic=1"

rem Never rotate a known-good snapshot until a complete new snapshot exists.
if not exist "%llarsRoot%\LLARS Config.ini" (
    set "failed=1"
    if "%automatic%"=="0" echo Missing shared config: "%llarsRoot%\LLARS Config.ini"
    goto :finish
)
for %%S in ("%llarsRoot%\LLARS Config.ini") do if %%~zS LEQ 0 (
    set "failed=1"
    if "%automatic%"=="0" echo Shared config is empty: "%llarsRoot%\LLARS Config.ini"
    goto :finish
)

if exist "%staging%" rmdir /S /Q "%staging%" >nul 2>&1
mkdir "%staging%" >nul 2>&1
if errorlevel 1 set "failed=1"
mkdir "%destination%" >nul 2>&1
if errorlevel 1 set "failed=1"

if "%failed%"=="0" (
    copy /Y "%llarsRoot%\LLARS Config.ini" "%staging%\LLARS Config.ini" >nul
    if errorlevel 1 (
        set "failed=1"
    ) else if "%automatic%"=="0" (
        echo Staged shared config: "%llarsRoot%\LLARS Config.ini"
    )
)

if "%failed%"=="0" (
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
                echo Staged script config: "%%G"
            )
        )
    )
)

if not "%failed%"=="0" (
    if exist "%staging%" rmdir /S /Q "%staging%" >nul 2>&1
    goto :finish
)

rem The staging snapshot is complete. Rotate at most two previous successful snapshots.
if exist "%backup2%" rmdir /S /Q "%backup2%" >nul 2>&1
if exist "%backup1%" (
    move /Y "%backup1%" "%backup2%" >nul
    if errorlevel 1 set "failed=1"
)
if "%failed%"=="0" if exist "%backupRoot%" (
    move /Y "%backupRoot%" "%backup1%" >nul
    if errorlevel 1 set "failed=1"
)
if "%failed%"=="0" (
    move /Y "%staging%" "%backupRoot%" >nul
    if errorlevel 1 set "failed=1"
)

rem If final promotion fails, restore the former latest snapshot when possible.
if not "%failed%"=="0" (
    if not exist "%backupRoot%" if exist "%backup1%" move /Y "%backup1%" "%backupRoot%" >nul 2>&1
    if exist "%staging%" rmdir /S /Q "%staging%" >nul 2>&1
)

:finish
if "%automatic%"=="0" (
    echo.
    if "%failed%"=="0" (
        echo Configuration backup complete.
        echo Latest backup: "%backupRoot%"
        echo Previous backups: "%backup1%" and "%backup2%"
    ) else (
        echo Configuration backup failed; the previous successful snapshot was preserved when possible.
    )
    pause
)

exit /b %failed%
