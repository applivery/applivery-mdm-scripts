<#
.SYNOPSIS
    Cloudflare Zero Trust (WARP) Enrollment.
.DESCRIPTION
    Configures the Cloudflare WARP client to register with a specific Zero Trust organization.
.NOTES
    Author: Applivery
    Version: 1.1.0
#>

# ==========================================
# REQUIREMENTS & PRE-FLIGHT CHECKS
# ==========================================
# This script requires the Cloudflare WARP client to be pre-installed.
Write-Host "Checking requirements..." -ForegroundColor Cyan
if (!(Get-Command "warp-cli" -ErrorAction SilentlyContinue)) {
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    Write-Host "ERROR: Cloudflare WARP is NOT installed on this device." -ForegroundColor Red
    Write-Host "Please deploy the Cloudflare WARP MSI before running this script." -ForegroundColor Red
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    exit 1
}

# ==========================================
# CONFIGURATION
# ==========================================
$OrgName = "TEAMNAME"

# ==========================================
# MAIN LOGIC
# ==========================================
Write-Host "--- Starting Cloudflare Zero Trust Enrollment Process ---" -ForegroundColor Cyan

Try {
    # 1. Register the device
    Write-Host "Registering device with Organization: $OrgName..." -ForegroundColor Yellow
    warp-cli registration new $OrgName
    
    # 2. Connect the client
    Write-Host "Activating WARP connection..." -ForegroundColor Yellow
    warp-cli connect
    
    Write-Host "Success: Device enrollment initiated for $OrgName." -ForegroundColor Green
}
Catch {
    Write-Error "An error occurred during the enrollment process: $($_.Exception.Message)"
    exit 1
}

# 3. Final Status
Write-Host "`nCurrent WARP Status:" -ForegroundColor Cyan
warp-cli status