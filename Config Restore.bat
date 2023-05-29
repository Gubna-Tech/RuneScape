@echo off
setlocal enabledelayedexpansion

set "source=%cd%\Config Backup"
set "destination=%cd%"

for /r "%source%" %%G in (*.ini) do (
    set "filepath=%%~dpG"
    set "filepath=!filepath:%source%=%destination%!"
    if exist "!filepath!" (
        if exist "!filepath!\%%~nxG" (
            echo Overwriting existing file: "!filepath!\%%~nxG"
        ) else (
            echo Restoring file: "%%G" to "!filepath!"
        )
        copy /Y "%%G" "!filepath!"
    )
)

echo Config files have been restored from "%source%".
pause
