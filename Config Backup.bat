@echo off
setlocal enabledelayedexpansion

set "source=%cd%"
set "destination=%cd%\Config Backup"

if not exist "%destination%" mkdir "%destination%"

for /r "%source%" %%G in (*) do (
    if /I "%%~nxG"=="Config.ini" (
        set "filepath=%%~dpG"

        REM If current file is in the Config Backup directory, skip it
        if "!filepath:%destination%=!"=="!filepath!" (
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

    if /I "%%~nxG"=="LLARS Config.ini" (
        set "filepath=%%~dpG"

        REM If current file is in the Config Backup directory, skip it
        if "!filepath:%destination%=!"=="!filepath!" (
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
)

pause
