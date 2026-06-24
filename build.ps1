# build.ps1 — Build Transcendence from source using MSBuild
# Usage:
#   .\build.ps1                 # Debug For Contributors build (recommended for contributors)
#   .\build.ps1 -Release        # Release build
#   .\build.ps1 -Parallel 4     # Debug For Contributors build with 4 parallel jobs

param(
    [switch]$Release,
    [int]$Parallel = 0
)

$SOLUTION = "$PSScriptRoot\Transcendence\Transcendence.sln"
$CONFIGURATION = if ($Release) { "Release" } else { "Debug For Contributors" }
$MSBUILD_CANDIDATES = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
)

$msbuild = $null
foreach ($candidate in $MSBUILD_CANDIDATES) {
    if (Test-Path $candidate) { $msbuild = $candidate; break }
}

if (-not $msbuild) {
    Write-Error "MSBuild not found. Install Visual Studio 2022 (Community or higher), then run .\setup.ps1 to verify prerequisites."
    exit 1
}

$msbuildArgs = @(
    $SOLUTION,
    "-p:Configuration=$CONFIGURATION",
    "-p:Platform=Win32"
)
if ($Parallel -gt 0) { $msbuildArgs += "-m:$Parallel" } else { $msbuildArgs += "-m" }

Write-Host "Building $CONFIGURATION|Win32 ..."
& $msbuild @msbuildArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build succeeded. Output: Transcendence\Game\Transcendence.exe"
} else {
    Write-Error "Build failed (exit code $LASTEXITCODE)."
    exit $LASTEXITCODE
}
