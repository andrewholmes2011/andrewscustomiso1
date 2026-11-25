@echo off
setlocal
set "BASE=%ProgramData%\AndrewEdition"
if not exist "%BASE%\Scripts\FirstLogon.ps1" exit /b 0
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v "AndrewEditionFirstLogon" /t REG_SZ /d "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%BASE%\Scripts\FirstLogon.ps1\"" /f >nul
exit /b 0