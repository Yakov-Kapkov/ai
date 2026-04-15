@echo off
setlocal

set SCRIPT_DIR=.\

echo.
powershell -NoProfile -Command "Write-Host '=== Updating SDA tool ===' -ForegroundColor Cyan"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-tool.ps1" -Name "sda"

echo.
powershell -NoProfile -Command "Write-Host '== Updating commit skill ==' -ForegroundColor Yellow"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-skill.ps1" -Name "commit"

echo.
powershell -NoProfile -Command "Write-Host '== Updating standards-compliance skill ==' -ForegroundColor Yellow"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-standards-compliance.ps1"

echo.
powershell -NoProfile -Command "Write-Host '== Updating development-guidance skill ==' -ForegroundColor Yellow"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-skill.ps1" -Name "development-guidance"

echo.
powershell -NoProfile -Command "Write-Host '== Updating troubleshooting skill ==' -ForegroundColor Yellow"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%update-skill.ps1" -Name "troubleshooting"

echo.
endlocal
pause
