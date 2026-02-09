<#
.SYNOPSIS
    Lost or Stolen Device Lock.
.DESCRIPTION
    Immediately locks the workstation and sets a persistent legal notice on the login screen 
    stating the device is lost or stolen.
.NOTES
    Author: Applivery
    Version: 1.0.0
#>

# ==========================================
# CONFIGURATION
# ==========================================
$NoticeTitle = "DISPOSITIVO BLOQUEADO / DEVICE LOCKED"
$NoticeMsg = "This device has been reported as LOST or STOLEN. Please return to headquarters."

# ==========================================
# 1. PRIVILEGE CHECK
# ==========================================
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires administrator privileges to modify registry keys."
    exit 1
}

# ==========================================
# 2. SET LEGAL NOTICE (Persistent after reboot)
# ==========================================
Write-Host "Setting legal notice on login screen..." -ForegroundColor Cyan
Try {
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Set-ItemProperty -Path $RegistryPath -Name "legalnoticecaption" -Value $NoticeTitle -ErrorAction Stop
    Set-ItemProperty -Path $RegistryPath -Name "legalnoticetext" -Value $NoticeMsg -ErrorAction Stop
    Write-Host "Successfully updated legal notice." -ForegroundColor Green
} Catch {
    Write-Error "Failed to update registry: $($_.Exception.Message)"
}

# ==========================================
# 3. LOCK WORKSTATION
# ==========================================
Write-Host "Locking the workstation immediately..." -ForegroundColor Yellow
& rundll32.exe user32.dll, LockWorkStation

exit 0