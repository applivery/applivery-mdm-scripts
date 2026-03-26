<#
.SYNOPSIS
    Network URL & Domain Blocker via Windows Firewall.
.DESCRIPTION
    Resolves a list of prohibited domains to their current IP addresses and creates 
    outbound block rules in the Windows Defender Firewall.
.NOTES
    Author: Julian Munoz
    Version: 1.0.0
.PREREQUISITES
    - Administrative privileges are required to modify Firewall rules.
    - Active internet connection to resolve DNS addresses.
#>

# ==========================================
# REQUIREMENTS & PRE-FLIGHT CHECKS
# ==========================================
Write-Host "Checking privileges..." -ForegroundColor Cyan
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    Write-Host "ERROR: This script must be run as Administrator/SYSTEM." -ForegroundColor Red
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    exit 1
}

# ==========================================
# CONFIGURATION
# ==========================================
# List of domains to block (organized by category)
$Domains = @(
    # Direct Threats & Exploits
    "pastebin.com", "github.com", "sploitus.com", "glitch.me", "tebi.io", "ngrok.io",
    
    # Data Exfiltration & Unmanaged Storage
    "mega.nz", "mediafire.com", "4shared.com", "transfer.sh", "sendgb.com", 
    "anonymshare.com", "dropbox.com", "wetransfer.com",
    
    # Evasion & VPNs
    "proxysite.com", "hidemyass.com", "tunnelbear.com", "expressvpn.com", "whoer.net",
    
    # Piracy
    "thepiratebay.org", "1337x.to", "rarbg.to", "fitgirl-repacks.site", "softonic.com",
    
    # Remote Control
    "ammyy.com", "remotedesktop.google.com",
    
    # NSFW Content
    "pornhub.com", "xvideos.com", "porntube.com", "xxx.com"
)

# ==========================================
# MAIN LOGIC
# ==========================================
Write-Host "--- Initiating URL Block via Windows Firewall ---" -ForegroundColor Cyan

foreach ($Domain in $Domains) {
    Try {
        # Resolve all IPs associated with the domain
        $IPs = [System.Net.Dns]::GetHostAddresses($Domain).IPAddressToString
        
        if ($IPs) {
            Write-Host "Blocking $Domain (Resolved IPs: $($IPs -join ', '))" -ForegroundColor Yellow
            
            # Create the Outbound Firewall Rule
            # We use 'Continue' on ErrorAction to skip if a rule with the same name already exists
            New-NetFirewallRule -DisplayName "Bloqueo Applivery: $Domain" `
                                -Direction Outbound `
                                -Action Block `
                                -RemoteAddress $IPs `
                                -Description "Preventive security block managed by Applivery" `
                                -Enabled True `
                                -ErrorAction SilentlyContinue
        }
    }
    Catch {
        Write-Host "Could not resolve domain: $Domain (Skipping...)" -ForegroundColor Gray
    }
}

Write-Host "Process finished. All block rules are active." -ForegroundColor Green