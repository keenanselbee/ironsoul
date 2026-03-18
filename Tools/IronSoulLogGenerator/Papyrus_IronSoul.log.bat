@echo off
setlocal

REM === Change these ===
set "IN=%USERPROFILE%\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log"
set "OUT=%~dp0Papyrus_IronSoul.log"

REM Filter lines containing "IronSoul" (case-insensitive)
findstr /I /C:"IronSoul" "%IN%" > "%OUT%"

echo Wrote: "%OUT%"
endlocal
