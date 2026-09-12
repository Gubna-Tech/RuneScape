@echo off
setlocal enabledelayedexpansion

set "source=%~dp0Scripts"
set "destination=%~dp0Config Backup\Scripts"

if not exist "%destination%" mkdir "%destination%"

for /r "%source%" %%G in (*) do (
    if /I "%%~nxG"=="Config.ini" (
        set "filepath=%%~dpG"
        set "filepath=!filepath:%source%=%destination%!"
        if not exist "!filepath!" mkdir "!filepath!"
        if exist "!filepath!\%%~nxG" (
            echo Overwriting existing file: "!filepath!\%%~nxG"
        ) else (
            echo Copying file: "%%G" to "!filepath!"
        )
        copy /Y "%%G" "!filepath!" >nul
    )
)

pause