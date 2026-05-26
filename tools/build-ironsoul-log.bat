@echo off
setlocal

REM === Iron Soul combined log builder ===
REM Writes the full SKSE ironsoul.log first, then appends filtered Papyrus IronSoul lines.

set "SKSE_LOG=%USERPROFILE%\Documents\My Games\Skyrim Special Edition\SKSE\ironsoul.log"
set "PAPYRUS_LOG=%USERPROFILE%\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log"
set "OUT=%~dp0ironsoul-combined.log"

REM Start fresh.
if exist "%OUT%" del "%OUT%"

REM Add every line from SKSE\ironsoul.log before Papyrus filtering.
>> "%OUT%" echo ===============================
>> "%OUT%" echo -- SKSE Iron Soul Native Log --
>> "%OUT%" echo ===============================
>> "%OUT%" echo Source: "%SKSE_LOG%"
>> "%OUT%" echo.

if exist "%SKSE_LOG%" (
    type "%SKSE_LOG%" >> "%OUT%"
) else (
    >> "%OUT%" echo [build-ironsoul-log] Missing SKSE log: "%SKSE_LOG%"
)

REM Add filtered Papyrus section.
>> "%OUT%" echo.
>> "%OUT%" echo.
>> "%OUT%" echo =================================================
>> "%OUT%" echo -- Filtered Papyrus lines containing IronSoul  --
>> "%OUT%" echo =================================================
>> "%OUT%" echo Source: "%PAPYRUS_LOG%"
>> "%OUT%" echo.

if exist "%PAPYRUS_LOG%" (
    findstr /I /C:"IronSoul" "%PAPYRUS_LOG%" >> "%OUT%"
) else (
    >> "%OUT%" echo [build-ironsoul-log] Missing Papyrus log: "%PAPYRUS_LOG%"
)

echo Wrote: "%OUT%"
endlocal
