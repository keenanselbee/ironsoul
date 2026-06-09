@echo off
setlocal

REM === Iron Soul log builder ===
REM Writes the full SKSE Iron Soul plugin log first, then appends filtered Papyrus IronSoul lines.

set "SKSE_LOG_DIR=%USERPROFILE%\Documents\My Games\Skyrim Special Edition\SKSE"
set "SKSE_LOG=%SKSE_LOG_DIR%\IronSoulSKSE.log"
set "PAPYRUS_LOG=%USERPROFILE%\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log"
for %%I in ("%~dp0..") do set "REPO_ROOT=%%~fI"
set "LOG_DIR=%REPO_ROOT%\logs"
set "OUT=%LOG_DIR%\ironsoul.log"
set "OUT_1=%LOG_DIR%\ironsoul.1.log"
set "OUT_2=%LOG_DIR%\ironsoul.2.log"
set "OUT_3=%LOG_DIR%\ironsoul.3.log"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Keep the current log plus three previous logs.
if exist "%OUT_3%" del "%OUT_3%"
if exist "%OUT_2%" ren "%OUT_2%" "ironsoul.3.log"
if exist "%OUT_1%" ren "%OUT_1%" "ironsoul.2.log"
if exist "%OUT%" ren "%OUT%" "ironsoul.1.log"

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
