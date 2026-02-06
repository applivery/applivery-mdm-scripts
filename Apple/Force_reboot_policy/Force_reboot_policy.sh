#!/bin/bash

# ---
# Title: macOS Uptime Enforcement with Applivery Branding
# Description: Monitors uptime and triggers UI alerts using swiftDialog with corporate branding.
# Author: Applivery Community
# Version: 1.2.0
# ---

# ==========================================
# TESTING VARIABLES
# ==========================================
# Uncomment the line below to test a specific day threshold
# TEST_UPTIME_DAYS="13" 

# ==========================================
# 1. PRE-FLIGHT & CLEANUP (Dialog.app and old versions)
# ==========================================
# This ensures we don't use a previously installed Dialog.app that might conflict
DIALOG_OLD="/Applications/Dialog.app"

if [ -d "$DIALOG_OLD" ]; then
    echo "→ Old Dialog.app found. Removing..."
    pgrep -if "Dialog.app" && pkill -if "Dialog.app" && sleep 1
    sudo rm -rf "$DIALOG_OLD" 2>/dev/null
fi

# swiftDialog paths
DIALOG_CLI="/usr/local/bin/dialog"
DIALOG_APP="/Library/Application Support/Dialog/Dialog.app"
DIALOG_ICON_DIR="/Library/Application Support/Dialog"
DIALOG_ICON="$DIALOG_ICON_DIR/Dialog.png"
BRAND_ICON="/var/root/AppliveryAssets/applivery.png"

needs_install=0
needs_reinstall=0

CURRENT_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$CURRENT_USER" 2>/dev/null || true)

# ==========================================
# 2. BRANDING LOGIC (Corporate Policy)
# ==========================================
mkdir -p "$DIALOG_ICON_DIR"
chmod 755 "$DIALOG_ICON_DIR"

if [ -f "$BRAND_ICON" ]; then
    tmp_brand="$(/usr/bin/mktemp /tmp/dialog_brand.XXXXXX.png)"
    # Resizing logo to 512x512 for optimal UI rendering
    if ! sips -z 512 512 "$BRAND_ICON" --out "$tmp_brand" >/dev/null 2>&1; then
        /bin/cp "$BRAND_ICON" "$tmp_brand"
    fi
    if [ -f "$tmp_brand" ]; then
        if [ ! -f "$DIALOG_ICON" ] || ! cmp -s "$tmp_brand" "$DIALOG_ICON"; then
            cp "$tmp_brand" "$DIALOG_ICON"
            chmod 644 "$DIALOG_ICON"
            chown root:wheel "$DIALOG_ICON" >/dev/null 2>&1
            needs_reinstall=1 # Ensure Dialog is ready to use new icon
        fi
    fi
    rm -f "$tmp_brand"
fi

# ==========================================
# 3. SWIFTDIALOG INSTALLATION
# ==========================================
get_swiftdialog_pkg_url() {
    curl -fsSL -H "Accept: application/vnd.github+json" "https://api.github.com/repos/swiftDialog/swiftDialog/releases/latest" | \
    sed -nE 's/.*"browser_download_url":"([^"]*\.pkg)".*/\1/p' | head -n 1
}

if [ ! -x "$DIALOG_CLI" ] || [ ! -d "$DIALOG_APP" ]; then
    needs_install=1
fi

if [ "$needs_install" -eq 1 ] || [ "$needs_reinstall" -eq 1 ]; then
    pkg_url="$(get_swiftdialog_pkg_url)"
    if [ -n "$pkg_url" ]; then
        pkg_path="$(mktemp /tmp/swiftDialog.XXXXXX.pkg)"
        curl -fL "$pkg_url" -o "$pkg_path"
        installer -pkg "$pkg_path" -target /
        rm -f "$pkg_path"
    fi
fi

# ==========================================
# 4. UPTIME LOGIC
# ==========================================
run_as_user() {
    launchctl asuser "$USER_ID" sudo -u "$CURRENT_USER" "$@"
}

killall Dialog 2>/dev/null
current_unix_time="$(date '+%s')"
boot_time_unix="$(sysctl -n kern.boottime | awk -F 'sec = |, usec' '{ print $2; exit }')"
uptime_days="$(( (current_unix_time - boot_time_unix) / 86400 ))"

if [ -n "$TEST_UPTIME_DAYS" ]; then
    echo "⚠️ TESTING MODE: $TEST_UPTIME_DAYS days"
    uptime_days="$TEST_UPTIME_DAYS"
fi

# ==========================================
# 5. ENFORCEMENT LEVELS
# ==========================================
if [ "$uptime_days" -le 4 ]; then
    echo "Uptime OK ($uptime_days days). Exiting."
    exit 0

elif [ "$uptime_days" -ge 5 ]