<#
.SYNOPSIS
    CrowdStrike Falcon Sensor Installation.
.DESCRIPTION
    Installs the CrowdStrike Falcon sensor using a local .exe installer and a Customer ID (CID).
.NOTES
    Author: Applivery
    Version: 1.0.0
.PREREQUISITES
    - The 'WindowsSensor.exe' must be present in the same directory or distributed via Applivery App Distribution.
#>

# ==========================================
# REQUIREMENTS & PRE-FLIGHT CHECKS
# ==========================================
$Installer = "WindowsSensor.exe"

Write-Host "Checking requirements..." -ForegroundColor Cyan
if (!(Test-Path -Path ".\$Installer")) {
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    Write-Host "ERROR: Installer '$Installer' not found." -ForegroundColor Red
    Write-Host "Please ensure the file is distributed via Applivery App " -ForegroundColor Red
    Write-Host "Distribution before running this script." -ForegroundColor Red
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    exit 1
}

# ==========================================
# CONFIGURATION
# ==========================================
# Replace with your actual Customer ID (CID) from the Falcon Console
$CID = "YOUR_CID_HERE"
$Arguments = "/install /quiet /norestart CID=$CID"

# ==========================================
# MAIN LOGIC
# ==========================================
Write-Host "Starting CrowdStrike Falcon installation..." -ForegroundColor Yellow

Try {
    # Execute installation and wait for completion
    $Process = Start-Process -FilePath ".\$Installer" -ArgumentList $Arguments -Wait -PassThru

    # Validate result
    if ($Process.ExitCode -eq 0) {
        Write-Host "SUCCESS: CrowdStrike installed successfully." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Installation failed with Exit Code: $($Process.ExitCode)" -ForegroundColor Red
        exit $Process.ExitCode
    }
}
Catch {
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    exit 1
}