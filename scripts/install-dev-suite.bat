@echo off
set SCRIPT_DIR=.\
set TARGET=%USERPROFILE%\.copilot

echo === Updating SDA tool ===
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-tool.ps1" -TargetBase "%TARGET%" -Name "sda"

echo === Updating commit skill ===
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-skill.ps1" -TargetBase "%TARGET%" -Name "commit"

echo === Updating standards-compliance skill ===
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-standards-compliance.ps1" -TargetBase "%TARGET%"

pause
