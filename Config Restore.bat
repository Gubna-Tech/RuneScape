@echo off
setlocal enabledelayedexpansion

set "source=%~dp0Config Backup\Scripts"
set "destination=%~dp0Scripts"

for /r "%source%" %%G in (*) do (
    if /I "%%~nxG"=="Config.ini" (
        set "filepath=%%~dpG"
        set "filepath=!filepath:%source%=%destination%!"

        if exist "!filepath!" (
            if exist "!filepath!\%%~nxG" (
                echo Overwriting existing file: "!filepath!\%%~nxG"
            ) else (
                echo Restoring file: "%%G" to "!filepath!"
            )
            copy /Y "%%G" "!filepath!" >nul
        )
    )
)

pause