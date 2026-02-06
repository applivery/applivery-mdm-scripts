#!/bin/bash

# ---
# Title: macOS Uptime Enforcement with swiftDialog
# Description: Monitors system uptime and triggers notifications or forced reboots.
# Author: Applivery Community
# Version: 2.0.0
# ---

# ==========================================
# TESTING VARIABLES
# ==========================================
# Uncomment the line below to test a specific day threshold
# TEST_UPTIME_DAYS="13" 

# ==========================================
# 1. PRE-FLIGHT & CLEANUP
# ==========================================
DIALOG_OLD_APP="/Applications/Dialog.app"
DIALOG_NEW_PATH="/Library/Application Support/Dialog"

if [ -d "$DIALOG_OLD_APP" ] || [ -d "$DIALOG_NEW_PATH" ]; then
    echo "Checking for existing Dialog installations..."
    pkill -if "Dialog.app" 2>/dev/null
    rm -rf "$DIALOG_OLD_APP" "$DIALOG_NEW_PATH" "/usr/local/bin/dialog" 2>/dev/null
fi

# ==========================================
# 2. INSTALL SWIFTDIALOG
# ==========================================
get_dialog() {
    echo "Downloading latest swiftDialog..."
    URL=$(curl -sfL https://api.github.com/repos/swiftDialog/swiftDialog/releases/latest | grep "browser_download_url.*pkg" | cut -d '"' -f 4)
    curl -L "$URL" -o "/tmp/dialog.pkg"
    installer -pkg "/tmp/dialog.pkg" -target /
    rm /tmp/dialog.pkg
}

[ ! -f "/usr/local/bin/dialog" ] && get_dialog

# ==========================================
# 3. UPTIME LOGIC
# ==========================================
DIALOG_CLI="/usr/local/bin/dialog"
CURRENT_USER=$(stat -f %Su /dev/console)
USER_ID=$(id -u "$CURRENT_USER")
BOOT_TIME=$(sysctl -n kern.boottime | awk -F 'sec = |, usec' '{ print $2; exit }')
UPTIME_SECONDS=$(( $(date +%s) - BOOT_TIME ))
UPTIME_DAYS=$(( UPTIME_SECONDS / 86400 ))

# Apply Testing Overrides
if [ -n "$TEST_UPTIME_DAYS" ]; then
    echo "⚠️ TESTING MODE ACTIVE: Forcing uptime to $TEST_UPTIME_DAYS days"
    UPTIME_DAYS="$TEST_UPTIME_DAYS"
fi

run_as_user() {
    launchctl asuser "$USER_ID" sudo -u "$CURRENT_USER" "$@"
}

# ==========================================
# 4. ENFORCEMENT LEVELS
# ==========================================
echo "Device Uptime: $UPTIME_DAYS days."

if [ "$UPTIME_DAYS" -le 4 ]; then
    echo "Uptime within limits ($UPTIME_DAYS days). No action."
    exit 0

elif [ "$UPTIME_DAYS" -ge 5 ] && [ "$UPTIME_DAYS" -le 8 ]; then
    echo "Level 1: Advice Notification"
    run_as_user "$DIALOG_CLI" \
        --notification \
        --title "$UPTIME_DAYS days without a reboot!" \
        --message "Your Mac needs to restart to regain performance. Security updates may be pending."
    afplay "/System/Library/Sounds/Sosumi.aiff"

elif [ "$UPTIME_DAYS" -ge 9 ] && [ "$UPTIME_DAYS" -le 12 ]; then
    echo "Level 2: Dialog with Postpone"
    afplay "/System/Library/Sounds/Sosumi.aiff" &
    run_as_user "$DIALOG_CLI" \
        --title "Restart Required" \
        --message "*${UPTIME_DAYS} days without a reboot!* \n\nPlease save your work and press Restart. If you press Postpone, you will be reminded in 24 hours." \
        --button1text "Restart now" \
        --button2text "Postpone" \
        --timer 840 --width 650 --height 280 --position bottomright --ontop --moveable
    [ $? -eq 0 ] && shutdown -r now

elif [ "$UPTIME_DAYS" -ge 13 ]; then
    echo "Level 3: Critical Blocking Warning"
    afplay "/System/Library/Sounds/Sosumi.aiff" & 

    # Forced Acknowledgment
    run_as_user "$DIALOG_CLI" \
        --title "Restart Required" \
        --message "*${UPTIME_DAYS} days without a reboot!* \n\n*After pressing I Understand, you will have 10 minutes to restart your computer.*" \
        --button1text "I Understand" \
        --width 650 --height 230 --blurscreen --ontop

    # Final Timer Countdown
    run_as_user "$DIALOG_CLI" \
        --title none \
        --message "Your computer will restart when the timer reaches zero. Save your work now." \
        --button1text "Restart now" \
        --timer 600 --width 320 --height 110 --position bottomright --icon none --ontop
    
    shutdown -r now
fi