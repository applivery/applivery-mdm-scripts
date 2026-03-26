<#
.SYNOPSIS
    Force Reboot Policy (Uptime Enforcement) for Windows.
.DESCRIPTION
    Monitors Windows uptime and triggers escalating alerts. 
    - Day 5: Periodic reminder.
    - Day 10: Critical security warning.
    - Day 15: Forced reboot with a 5-minute countdown.
.NOTES
    Author: Applivery
    Version: 1.0.0
.PREREQUISITES
    - Administrative privileges are required to execute the shutdown command.
#>

# ==========================================
# CONFIGURATION
# ==========================================
# Set to $true to enable the actual restart. Set to $false for testing purposes.
$EnableForceRestart = $true 

# Get System Uptime in Days
$Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$UptimeDays = [math]::Floor($Uptime.TotalDays)

# TEST MODE: Uncomment the line below to simulate a specific uptime
# $UptimeDays = 15 

# ==========================================
# MAIN LOGIC
# ==========================================
Write-Host "--- Starting Reboot Efficiency Check ---" -ForegroundColor Cyan
Write-Host "Current Uptime: $UptimeDays days." -ForegroundColor White

# --- PHASE 3: CRITICAL LIMIT (Day 15+) ---
if ($UptimeDays -ge 15) {
    Write-Host "PHASE: Limit reached (Day 15+). Executing countdown." -ForegroundColor Red
    if ($EnableForceRestart) {
        # Windows native shutdown: /r (restart), /f (force), /t (seconds), /c (comment)
        shutdown /r /f /t 300 /c "APPLIVERY POLICY: This device has reached the 15-day uptime limit. Automatic restart in 5 minutes. Please save your work."
    } else {
        Write-Host "REBOOT SIMULATED: Shutdown command would have triggered now." -ForegroundColor Yellow
    }
}

# --- PHASE 2: CRITICAL WARNING (Day 10-14) ---
elseif ($UptimeDays -ge 10) {
    Write-Host "PHASE: Critical warning (Day 10+)." -ForegroundColor Yellow
    $MsgTitle = "SECURITY WARNING"
    $MsgText = "Your computer has been running for $UptimeDays days without a reboot. To ensure security updates are applied, please restart before Day 15."
    
    # Using native Windows msg command
    msg * /TIME:3600 "$MsgTitle: $MsgText"
}

# --- PHASE 1: INITIAL REMINDER (Day 5-9) ---
elseif ($UptimeDays -ge 5) {
    Write-Host "PHASE: Initial reminder (Day 5+)." -ForegroundColor Green
    $MsgText = "REBOOT REMINDER: To maintain optimal performance, a restart is recommended. Current uptime: $UptimeDays days."
    
    msg * /TIME:1800 "$MsgText"
}

# --- COMPLIANT STATE ---
else {
    Write-Host "Device is compliant with reboot policy." -ForegroundColor Green
}

exit 0