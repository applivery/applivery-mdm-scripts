#!/bin/bash

# ---
# Title: Force Reboot Policy (Uptime Enforcement)
# Description: Monitors macOS uptime and triggers escalating alerts via swiftDialog to force a restart.
# Author: Applivery
# Version: 1.2.0
# ---

# ==========================================
# 1. CLEANUP OLD INSTALLATIONS
# ==========================================
# Removes legacy Dialog.app from /Applications to avoid version conflicts
DIALOG_OLD="/Applications/Dialog.app"

if [ -d "$DIALOG_OLD" ]; then
    echo "→ Old Dialog.app found"
    pgrep -if "Dialog.app" && {
        echo "  → Quitting Dialog..."
        pkill -if "Dialog.app" 2>/dev/null
        sleep 1
    }
    
    if sudo rm -rf "$DIALOG_OLD" 2>/dev/null; then
        echo "  → Removed successfully"
    else
        echo "  → Failed to remove legacy app."
    fi
else
    echo "→ No old Dialog.app present"
fi

# ==========================================
# 2. PRE-FLIGHT & BRANDING SETUP
# ==========================================
PATH=/usr/bin:/bin:/usr/sbin:/sbin

DIALOG_CLI="/usr/local/bin/dialog"
DIALOG_APP="/Library/Application Support/Dialog/Dialog.app"
DIALOG_ICON_DIR="/Library/Application Support/Dialog"
DIALOG_ICON="$DIALOG_ICON_DIR/Dialog.png"
BRAND_ICON="/var/root/AppliveryAssets/applivery.png"

needs_install=0
needs_reinstall=0

CURRENT_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$CURRENT_USER" 2>/dev/null || true)

get_swiftdialog_pkg_url() {
    local url
    url="$(/usr/bin/curl -fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: Force_Reboot" \
        "https://api.github.com/repos/swiftDialog/swiftDialog/releases/latest" | \
        /usr/bin/sed -nE 's/.*"browser_download_url":"([^"]*\.pkg)".*/\1/p' | \
        /usr/bin/head -n 1)"
    [ -n "$url" ] && echo "$url" && return 0
    return 1
}

run_as_user() {
    if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" = "loginwindow" ] || [ -z "$USER_ID" ]; then
        return 1
    fi
    launchctl asuser "$USER_ID" /usr/bin/sudo -u "$CURRENT_USER" -- "$@"
}

# Check if swiftDialog is missing
if [ ! -x "$DIALOG_CLI" ] || [ ! -d "$DIALOG_APP" ]; then
    needs_install=1
fi

# Apply Branding Icon Logic
mkdir -p "$DIALOG_ICON_DIR"
chmod 755 "$DIALOG_ICON_DIR"

if [ -f "$BRAND_ICON" ]; then
    tmp_brand="$(/usr/bin/mktemp /tmp/dialog_brand.XXXXXX.png)"
    if ! sips -z 512 512 "$BRAND_ICON" --out "$tmp_brand" >/dev/null 2>&1; then
        /bin/cp "$BRAND_ICON" "$tmp_brand"
    fi
    if [ -f "$tmp_brand" ]; then
        if [ ! -f "$DIALOG_ICON" ] || ! cmp -s "$tmp_brand" "$DIALOG_ICON"; then
            cp "$tmp_brand" "$DIALOG_ICON"
            chmod 644 "$DIALOG_ICON"
            chown root:wheel "$DIALOG_ICON" >/dev/null 2>&1
            needs_reinstall=1
        fi
    fi
    rm -f "$tmp_brand"
fi

# ==========================================
# 3. SWIFTDIALOG INSTALLATION
# ==========================================
if [ "$needs_install" -eq 1 ] || [ "$needs_reinstall" -eq 1 ]; then
    pkg_url="$(get_swiftdialog_pkg_url 2>/dev/null || true)"
    if [ -n "$pkg_url" ]; then
        pkg_path="/tmp/swiftDialog_$(date +%s).pkg"
        /usr/bin/curl -fL --retry 3 --retry-delay 1 "$pkg_url" -o "$pkg_path"
        installer -pkg "$pkg_path" -target /
        rm -f "$pkg_path"
    else
        echo "ERROR: Could not retrieve swiftDialog URL." >&2
        exit 1
    fi
fi

killall Dialog 2>/dev/null

# ==========================================
# 4. UPTIME CALCULATION
# ==========================================
current_unix_time="$(date '+%s')"
boot_time_unix="$(sysctl -n kern.boottime | awk -F 'sec = |, usec' '{ print $2; exit }')"
uptime_seconds="$(( current_unix_time - boot_time_unix ))"
uptime_days="$(( uptime_seconds / 86400 ))"

# TEST_UPTIME_DAYS="7" # Uncomment for testing

if [ -n "$TEST_UPTIME_DAYS" ]; then
    uptime_days="$TEST_UPTIME_DAYS"
fi

# ==========================================
# 5. ESCALATION LOGIC
# ==========================================

# --- LEVEL 1: OK (0-4 days) ---
if [ "$uptime_days" -le 4 ]; then
    echo "Uptime: $uptime_days days. No action needed."
    exit 0

# --- LEVEL 2: NOTIFICATION (5-8 days) ---
elif [ "$uptime_days" -ge 5 ] && [ "$uptime_days" -le 8 ]; then
    echo "Uptime: $uptime_days days. Showing Notification."
    run_as_user "$DIALOG_CLI" --notification \
    --title "$uptime_days days without a reboot!" \
    --message "Your Mac needs to restart to regain performance and apply security updates."
    afplay "/System/Library/Sounds/Sosumi.aiff"
    exit 0

# --- LEVEL 3: SOFT WARNING (9-12 days) ---
elif [ "$uptime_days" -ge 9 ] && [ "$uptime_days" -le 12 ]; then
    echo "Uptime: $uptime_days days. Showing Dialog with Postpone."
    afplay "/System/Library/Sounds/Sosumi.aiff" &
    run_as_user "$DIALOG_CLI" \
        --title "Restart Required" \
        --message "*${uptime_days} days without a reboot!* \n\nPlease save your work and restart. If postponed, you will be reminded in 24 hours." \
        --icon "$DIALOG_ICON" \
        --button1text "Restart now" \
        --button2text "Postpone" \
        --timer 840 --width 650 --height 280 --position bottomright --ontop
    dialog_results=$?

# --- LEVEL 4: HARD WARNING (13+ days) ---
elif [ "$uptime_days" -ge 13 ]; then
    echo "Uptime: $uptime_days days. Final warning."
    afplay "/System/Library/Sounds/Sosumi.aiff" & sleep 0.2 && afplay "/System/Library/Sounds/Sosumi.aiff" &
    
    run_as_user "$DIALOG_CLI" \
        --title "Restart Required" \
        --message "*${uptime_days} days without a reboot!* \n\n*After pressing I Understand, you will have 10 minutes to save your work.*" \
        --icon "$DIALOG_ICON" --button1text "I Understand" --width 650 --height 230 --blurscreen --ontop

    run_as_user "$DIALOG_CLI" \
        --title none --message "Computer will restart when the timer reaches zero." \
        --button1text "Restart now" --timer 600 --width 320 --height 110 --position bottomright --icon none --ontop
    dialog_results=$?
fi

# ==========================================
# 6. REBOOT EXECUTION
# ==========================================
if [ "$dialog_results" = "0" ] || [ "$dialog_results" = "4" ]; then
    echo "Rebooting now..."
    shutdown -r now
    sleep 2
    reboot
elif [ "$dialog_results" = "2" ]; then
    echo "User postponed the restart."
fi

exit 0