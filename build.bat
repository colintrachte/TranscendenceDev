@echo off
:: build.bat -- Build Transcendence from source
:: Usage:
::   build.bat           (Debug For Contributors build -- recommended for contributors)
::   build.bat release   (Release build)

setlocal

set CONFIGURATION=Debug For Contributors
if /i "%~1"=="release" set CONFIGURATION=Release

set MSBUILD=
for %%E in (Community Professional Enterprise) do (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\%%E\MSBuild\Current\Bin\MSBuild.exe" (
        set MSBUILD=C:\Program Files\Microsoft Visual Studio\2022\%%E\MSBuild\Current\Bin\MSBuild.exe
        goto :found
    )
)

echo ERROR: MSBuild not found. Install Visual Studio 2022 (Community or higher).
exit /b 1

:found
echo Building %CONFIGURATION%^|Win32 ...
"%MSBUILD%" Transcendence\Transcendence.sln "-p:Configuration=%CONFIGURATION%" -p:Platform=Win32 -m

if %ERRORLEVEL% neq 0 (
    echo Build failed.
    exit /b %ERRORLEVEL%
)
echo Build succeeded. Output: Transcendence\Game\Transcendence.exe
