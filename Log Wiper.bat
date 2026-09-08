@echo off
setlocal enabledelayedexpansion

set "source=%cd%"
set "excluded=%cd%\Config Backup"

for /r "%source%" %%G in (log.ini) do (
    set "filepath=%%~dpG"

    if "!filepath:%excluded%=!"=="!filepath!" (
        if exist "%%G" (
            del /Q "%%G" >nul 2>&1
            if not exist "%%G" (
                echo Deleted: "%%G"
            )
        )
    )
)

pause