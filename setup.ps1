# setup.ps1 — Install prerequisites for building Transcendence from source
# Run once before your first build. Re-running is safe (skips already-installed items).
#
# Prerequisites installed:
#   1. February 2010 DirectX SDK  (required by all build configurations)
#   2. Visual Studio 2022 with C++ workload  (required for MSBuild)
#
# Usage:
#   .\setup.ps1

$DXSDK_PATH = "C:\Program Files (x86)\Microsoft DirectX SDK (February 2010)"
$allOK = $true

#region ── DirectX SDK (February 2010) ──────────────────────────────────────────

if (Test-Path $DXSDK_PATH) {
    Write-Host "[OK]  DirectX SDK (February 2010) already installed."
} else {
    Write-Host "[ ]   DirectX SDK (February 2010) not found. Attempting install via Chocolatey..."

    $chocoCmd = Get-Command choco -ErrorAction SilentlyContinue
    $chocoExe = if ($chocoCmd) { $chocoCmd.Source } else { $null }
    if ($chocoExe) {
        choco install directx-sdk --yes --no-progress
        if (Test-Path $DXSDK_PATH) {
            Write-Host "[OK]  DirectX SDK installed."
        } else {
            Write-Warning ""
            Write-Warning "Chocolatey finished but the SDK was not found at:"
            Write-Warning "  $DXSDK_PATH"
            Write-Warning ""
            Write-Warning "Common cause: a newer Visual C++ Redistributable blocks the installer (error S1023)."
            Write-Warning "Fix: https://support.microsoft.com/kb/2728613"
            Write-Warning ""
            Write-Warning "Or download and install the SDK manually:"
            Write-Warning "  https://archive.org/details/dxsdk_feb10"
            $allOK = $false
        }
    } else {
        Write-Warning ""
        Write-Warning "Chocolatey is not installed. Install it first, then re-run this script:"
        Write-Warning "  https://chocolatey.org/install"
        Write-Warning ""
        Write-Warning "Or install the SDK manually (install to the default path when prompted):"
        Write-Warning "  https://archive.org/details/dxsdk_feb10"
        Write-Warning ""
        Write-Warning "Note: if the installer exits with error S1023, you need to temporarily"
        Write-Warning "uninstall newer Visual C++ Redistributables first:"
        Write-Warning "  https://support.microsoft.com/kb/2728613"
        $allOK = $false
    }
}

#endregion

#region ── Visual Studio 2022 ───────────────────────────────────────────────────

$vsFound = $false
foreach ($ed in @("Community", "Professional", "Enterprise")) {
    $candidate = "C:\Program Files\Microsoft Visual Studio\2022\$ed\MSBuild\Current\Bin\MSBuild.exe"
    if (Test-Path $candidate) {
        Write-Host "[OK]  Visual Studio 2022 ($ed) found."
        $vsFound = $true
        break
    }
}

if (-not $vsFound) {
    Write-Warning ""
    Write-Warning "Visual Studio 2022 not found."
    Write-Warning "Download Visual Studio 2022 Community (free):"
    Write-Warning "  https://visualstudio.microsoft.com/vs/community/"
    Write-Warning ""
    Write-Warning "During installation, select the workload:"
    Write-Warning "  'Desktop development with C++'"
    Write-Warning ""
    Write-Warning "After installing, re-run this script to verify all prerequisites are met."
    $allOK = $false
}

#endregion

#region ── Summary ──────────────────────────────────────────────────────────────

Write-Host ""
if ($allOK) {
    Write-Host "All prerequisites satisfied. You can now build:"
    Write-Host "  Command line:  .\build.ps1"
    Write-Host "  Visual Studio: open Transcendence\Transcendence.sln"
    Write-Host "                 set configuration to 'Debug For Contributors | Win32'"
} else {
    Write-Host "Some prerequisites are missing. Address the warnings above, then re-run this script."
    exit 1
}

#endregion
