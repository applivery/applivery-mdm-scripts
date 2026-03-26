<#
.SYNOPSIS
    Temporary Admin Rights (JIT Elevation) for Windows.
.DESCRIPTION
    Grants local administrator privileges to the current user for a limited time (5 minutes).
    Includes a cooldown mechanism to prevent abuse and automatic revocation.
.NOTES
    Author: Applivery
    Version: 1.0.0
.PREREQUISITES
    - Must run in a context with permissions to modify local groups (System/Admin).
#>

# ==========================================
# CONFIGURATION
# ==========================================
$DurationInSeconds = 300   # 5 minutes of admin time
$CooldownInSeconds = 1800  # 30 minutes wait between uses
$DataDir           = "$env:ProgramData\Applivery"
$CooldownFile      = "$DataDir\elevation_cooldown.txt"
$User              = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Handle localized Group Names (English/Spanish)
$AdminGroupSID = "S-1-5-32-544"
$GroupName = (Get-LocalGroup | Where-Object { $_.SID -eq $AdminGroupSID }).Name

# ==========================================
# 1. COOLDOWN VERIFICATION
# ==========================================
if (Test-Path $CooldownFile) {
    $LastRun = Get-Date (Get-Content $CooldownFile)
    $TimePassed = (Get-Date) - $LastRun
    
    if ($TimePassed.TotalSeconds -lt $CooldownInSeconds) {
        $Remaining = [math]::Round(($CooldownInSeconds - $TimePassed.TotalSeconds) / 60)
        Write-Host "----------------------------------------------------------" -ForegroundColor Red
        Write-Host "COOLDOWN ACTIVE: Please wait $Remaining minutes to request elevation again." -ForegroundColor Red
        Write-Host "----------------------------------------------------------" -ForegroundColor Red
        exit 1
    }
}

# ==========================================
# 2. ELEVATION LOGIC
# ==========================================
try {
    Write-Host "Granting temporary admin privileges to $User..." -ForegroundColor Cyan
    
    # Add user to the local Administrators group
    Add-LocalGroupMember -Group $GroupName -Member $User -ErrorAction Stop
    
    # Register execution time for Cooldown
    if (!(Test-Path $DataDir)) { New-Item -Path $DataDir -ItemType Directory -Force | Out-Null }
    Get-Date | Out-File $CooldownFile
    
    Write-Host "SUCCESS: Privileges granted for $($DurationInSeconds / 60) minutes." -ForegroundColor Green
    Write-Host "The session will be automatically revoked after the timer ends." -ForegroundColor Yellow
    
    # ==========================================
    # 3. TIMER (KEEP-ALIVE)
    # ==========================================
    Start-Sleep -Seconds $DurationInSeconds
    
} 
catch {
    Write-Host "ERROR: Failed to elevate privileges. $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # ==========================================
    # 4. REVOCATION
    # ==========================================
    Write-Host "Time expired. Revoking administrator privileges..." -ForegroundColor Cyan
    Remove-LocalGroupMember -Group $GroupName -Member $User -ErrorAction SilentlyContinue
    Write-Host "Privileges successfully revoked. User is now a Standard User." -ForegroundColor Green
}