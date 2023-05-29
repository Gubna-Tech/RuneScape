@echo off
setlocal enabledelayedexpansion

set "source=%cd%"
set "destination=%cd%\Config Backup"

if not exist "%destination%" mkdir "%destination%"

for /r "%source%" %%G in (*.ini) do (
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
        copy /Y "%%G" "!filepath!"
    )
)

echo Folder structure and Config files have been copied to "%destination%".
pause
