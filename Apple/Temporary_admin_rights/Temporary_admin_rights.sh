#!/bin/bash

# ---
# Title: Temporary Admin Access with Reason Logging
# Description: Grants a standard user admin rights for 3 minutes after providing a reason.
# Author: Applivery
# Version: 1.0.0
# ---

# ==========================================
# CONFIGURATION
# ==========================================
ADMIN_DURATION=180 # Seconds (3 minutes)
MIN_REASON_LENGTH=5
SCRIPT_DIR="/Users/Shared/AppliveryAdmin"
DAEMON_LABEL="com.applivery.adminprivileges"
DAEMON_PLIST="/Library/LaunchDaemons/${DAEMON_LABEL}.plist"
BRAND_ICON="/Library/Application Support/Dialog/applivery.png"

# ==========================================
# 1. PRE-FLIGHT (swiftDialog Check)
# ==========================================
DIALOG_CLI="/usr/local/bin/dialog"
if [ ! -x "$DIALOG_CLI" ]; then
    echo "swiftDialog not found. Installing..."
    URL=$(curl -sfL https://api.github.com/repos/swiftDialog/swiftDialog/releases/latest | grep "browser_download_url.*pkg" | cut -d '"' -f 4)
    curl -L "$URL" -o "/tmp/dialog.pkg"
    installer -pkg "/tmp/dialog.pkg" -target /
    rm /tmp/dialog.pkg
fi

# ==========================================
# 2. USER DETECTION
# ==========================================
CURRENT_USER=$(stat -f %Su /dev/console)
if [ -z "$CURRENT_USER" ] || [ "$CURRENT_USER" = "loginwindow" ]; then
    echo "No user logged in. Exiting."
    exit 0
fi

# Check if already admin
if id -Gn "$CURRENT_USER" | grep -qw admin; then
    "$DIALOG_CLI" --title "Admin Rights" --message "You already have administrator privileges." --button1text "OK" --icon "$BRAND_ICON" --height 200
    exit 0
fi

# ==========================================
# 3. REASON INPUT LOOP
# ==========================================
while true; do
    DIALOG_OUT=$("$DIALOG_CLI" \
        --title "Request Admin Privileges" \
        --message "You are requesting admin rights for $((ADMIN_DURATION / 60)) minutes. Please provide a justification." \
        --textfield "Reason,name=reason,prompt=Minimum $MIN_REASON_LENGTH characters" \
        --button1text "Make me Admin" --button2text "Cancel" \
        --icon "$BRAND_ICON" --json)

    [ $? -ne 0 ] && echo "User cancelled." && exit 0

    # Extract reason using Python
    REASON=$(echo "$DIALOG_OUT" | python3 -c "import json, sys; d=json.load(sys.stdin); print(d.get('reason', ''))")
    
    if [ ${#REASON} -ge $MIN_REASON_LENGTH ]; then
        echo "Access granted. User: $CURRENT_USER | Reason: $REASON"
        break
    else
        "$DIALOG_CLI" --title "Error" --message "Reason is too short. Please be more descriptive." --icon warning --timer 3
    fi
done

# ==========================================
# 4. ELEVATION & AUTO-REVOKE SETUP
# ==========================================
mkdir -p "$SCRIPT_DIR"
PAYLOAD_SCRIPT="$SCRIPT_DIR/revoke_admin.sh"

cat << EOF > "$PAYLOAD_SCRIPT"
#!/bin/bash
# Promote
dseditgroup -o edit -a "$CURRENT_USER" -t user admin
# Wait
sleep $ADMIN_DURATION
# Demote
dseditgroup -o edit -d "$CURRENT_USER" -t user admin
# Cleanup
launchctl unload "$DAEMON_PLIST"
rm -f "$DAEMON_PLIST"
rm -rf "$SCRIPT_DIR"
EOF

chmod +x "$PAYLOAD_SCRIPT"

# Create LaunchDaemon for background execution
cat << EOF > "$DAEMON_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>Label</key><string>$DAEMON_LABEL</string>
    <key>ProgramArguments</key><array><string>$PAYLOAD_SCRIPT</string></array>
    <key>RunAtLoad</key><true/>
</dict></plist>
EOF

chown root:wheel "$DAEMON_PLIST"
chmod 644 "$DAEMON_PLIST"
launchctl load "$DAEMON_PLIST"

"$DIALOG_CLI" --notification --title "Success" --message "Admin rights granted for $((ADMIN_DURATION / 60)) minutes."