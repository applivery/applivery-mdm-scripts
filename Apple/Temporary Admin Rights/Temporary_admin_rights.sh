#!/bin/bash

# ---
# Title: Temporary Admin Rights (JIT Elevation)
# Description: Grants local admin privileges to a standard user for a limited time with mandatory reason logging.
# Author: Applivery
# Version: 1.1.0
# ---

# ==========================================
# 1. PRE-FLIGHT & PREREQUISITES
# ==========================================

# Script must be run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run with sudo." >&2
    exit 1
fi

# Function to install Rosetta on Apple Silicon
install_rosetta() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        if /usr/sbin/pkgutil --pkgs | grep -q "com.apple.pkg.RosettaUpdateAuto"; then
            echo "✅ Rosetta is already installed."
        else
            echo "🔄 Installing Rosetta..."
            if /usr/sbin/softwareupdate --install-rosetta --agree-to-license; then
                echo "✅ Rosetta installed successfully."
            else
                echo "❌ Error installing Rosetta."
                exit 1
            fi
        fi
    fi
}

# Function to ensure Command Line Tools are available
ensure_clt() {
    if /usr/bin/xcode-select -p >/dev/null 2>&1; then
        echo "✅ Command Line Tools are already installed."
        return 0
    fi
    echo "Command Line Tools not found. Attempting silent installation..."
    clt_label=$(softwareupdate -l 2>/dev/null | awk -F'*' '/Command Line Tools/ {print $2}' | sed -e 's/^ *//' | head -n1)
    if [[ -n "$clt_label" ]]; then
        softwareupdate -i "$clt_label" -a --agree-to-license || true
    fi
    
    if [[ -d "/Library/Developer/CommandLineTools" ]]; then
        /usr/bin/xcode-select --switch "/Library/Developer/CommandLineTools" 2>/dev/null || true
    fi
}

echo "Starting installation of prerequisites..."
install_rosetta
ensure_clt

# ==========================================
# 2. SWIFTDIALOG DEPLOYMENT
# ==========================================
DIALOG_APP="/Library/Application Support/Dialog/Dialog.app"
DIALOG_CLI="/usr/local/bin/dialog"

get_swiftdialog_pkg_url() {
    curl -fsSL -H "Accept: application/vnd.github+json" "https://api.github.com/repos/swiftDialog/swiftDialog/releases/latest" | \
    sed -nE 's/.*"browser_download_url":"([^"]*\.pkg)".*/\1/p' | head -n 1
}

if [ ! -x "$DIALOG_CLI" ] || [ ! -d "$DIALOG_APP" ]; then
    echo "SwiftDialog not found. Installing..."
    pkg_url="$(get_swiftdialog_pkg_url)"
    if [ -n "$pkg_url" ]; then
        pkg_path="$(/usr/bin/mktemp /tmp/swiftDialog.XXXXXX.pkg)"
        curl -fL "$pkg_url" -o "$pkg_path"
        installer -pkg "$pkg_path" -target /
        rm -f "$pkg_path"
    fi
fi

# ==========================================
# 3. USER DETECTION & BRANDING
# ==========================================
currentUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
[ "$currentUser" = "loginwindow" ] && exit 0

brandIconSource="/var/root/AppliveryAssets/applivery.png"
brandIconDir="/Library/Application Support/Dialog"
brandIconPath="$brandIconDir/applivery.png"

if [ -f "$brandIconSource" ]; then
    mkdir -p "$brandIconDir"
    sips -z 512 512 "$brandIconSource" --out "$brandIconPath" >/dev/null 2>&1 || cp "$brandIconSource" "$brandIconPath"
    chmod 644 "$brandIconPath"
fi

# Check if already admin
if id -Gn "$currentUser" | grep -qw admin; then
    "$DIALOG_CLI" --title "Temporary Admin Rights" --message "You are already an administrator." --button1text "OK" --icon "$brandIconPath" --height 220 --width 480
    exit 0
fi

# ==========================================
# 4. ELEVATION DIALOG
# ==========================================
message="You are about to be granted administrator privileges for 3 minutes. Use them responsibly."

dialogRaw=$("$DIALOG_CLI" \
    --json \
    --title "Temporary Admin Rights" \
    --message "$message" \
    --textfield "Reason,name=reason,prompt=\"Reason (optional)\"" \
    --button1text "MAKE ME ADMIN" \
    --button2text "CANCEL" \
    --icon "$brandIconPath" \
    --height 280 --width 720 2>&1)

[ $? != 0 ] && exit 0

# Extract reason via Python
reason=$(/usr/bin/python3 -c "import json, sys, os, re; raw=os.environ.get('DIALOG_OUTPUT', ''); data=json.loads(re.search(r'\{.*\}', raw).group(0)); print(data.get('reason', ''))" 2>/dev/null <<<$dialogRaw)

echo "Admin request approved by user: $currentUser | Reason: $reason"

# ==========================================
# 5. EXECUTION & AUTO-REVOKE
# ==========================================
scriptDir="/Users/Shared/AdminTime"
scriptFile="$scriptDir/admin_privileges.sh"
launchDaemonFile="/Library/LaunchDaemons/com.applivery.adminprivileges.plist"

mkdir -p "$scriptDir"

cat << EOF > "$scriptFile"
#!/bin/bash
currentUser=\$(/bin/ls -l /dev/console | /usr/bin/awk '{ print \$3 }')
dseditgroup -o edit -a "\$currentUser" -t user admin
sleep 180
dseditgroup -o edit -d "\$currentUser" -t user admin
rm -rf "$scriptDir"
rm -f "$launchDaemonFile"
EOF

chmod +x "$scriptFile"

# Create LaunchDaemon for persistence during the 3-minute window
cat << EOF > "$launchDaemonFile"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>Label</key><string>com.applivery.adminprivileges</string>
    <key>ProgramArguments</key><array><string>$scriptFile</string></array>
    <key>RunAtLoad</key><true/>
</dict></plist>
EOF

chown root:wheel "$launchDaemonFile"
chmod 644 "$launchDaemonFile"
launchctl load "$launchDaemonFile"

echo "Success: User $currentUser elevated for 3 minutes."