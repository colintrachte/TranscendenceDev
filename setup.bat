@echo off
:: setup.bat -- Install prerequisites for building Transcendence from source
:: Usage: setup.bat

:: Prefer PowerShell 7+ (pwsh); fall back to Windows PowerShell 5.1
where pwsh >nul 2>&1
if %ERRORLEVEL% equ 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
)
