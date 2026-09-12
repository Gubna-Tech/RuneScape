@echo off
setlocal enabledelayedexpansion

set "source=%~dp0Scripts"

for /r "%source%" %%G in (log.ini) do (
    if exist "%%G" (
        del /Q "%%G" >nul 2>&1
        if not exist "%%G" (
            echo Deleted: "%%G"
        )
    )
)

pause