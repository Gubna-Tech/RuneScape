@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "llarsRoot=%%~fI"
set "backupRoot=%~dp0Config Backup"
set "source=%backupRoot%\Scripts"
set "destination=%llarsRoot%\Scripts"
set "automatic=0"
set "failed=0"

if /I "%~1"=="--auto" set "automatic=1"

if exist "%backupRoot%\LLARS Config.ini" (
    copy /Y "%backupRoot%\LLARS Config.ini" "%llarsRoot%\LLARS Config.ini" >nul
    if errorlevel 1 (
        set "failed=1"
    ) else if "%automatic%"=="0" (
        echo Restored shared config: "%llarsRoot%\LLARS Config.ini"
    )
) else (
    set "failed=1"
    if "%automatic%"=="0" echo Missing shared backup: "%backupRoot%\LLARS Config.ini"
)

if exist "%source%" (
    for /r "%source%" %%G in (*) do (
        if /I "%%~nxG"=="Config.ini" (
            set "filepath=%%~dpG"
            set "filepath=!filepath:%source%=%destination%!"
            if exist "!filepath!" (
                copy /Y "%%G" "!filepath!\%%~nxG" >nul
                if errorlevel 1 (
                    set "failed=1"
                ) else if "%automatic%"=="0" (
                    echo Restored script config: "%%G"
                )
            )
        )
    )
) else (
    set "failed=1"
    if "%automatic%"=="0" echo Missing script backup folder: "%source%"
)

if "%automatic%"=="0" (
    echo.
    if "%failed%"=="0" (
        echo Configuration restore complete.
    ) else (
        echo Configuration restore completed with one or more errors.
    )
    pause
)

exit /b %failed%
