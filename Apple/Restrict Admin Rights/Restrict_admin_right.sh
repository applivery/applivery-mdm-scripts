#!/bin/bash

# ---
# Title: Demote all local users to standard (except EXCLUDE_USER)
# Description: Ensures only a specific local account has administrator privileges.
# Author: Applivery
# Version: 1.0.0
# ---

# ======== CONFIGURATION ========
EXCLUDE_USER="admin"
ADMIN_GROUP="admin"

# ======== FUNCTIONS ========
is_admin() {
    local user="$1"
    dseditgroup -o checkmember -m "$user" "$ADMIN_GROUP" &>/dev/null
    return $?
}

# ======== INITIAL CHECKS ========
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run with sudo"
    echo "       sudo bash $0"
    exit 1
fi

if ! id "$EXCLUDE_USER" &>/dev/null; then
    echo "Error: User '$EXCLUDE_USER' does not exist on this system."
    exit 1
fi

if ! is_admin "$EXCLUDE_USER"; then
    echo "WARNING!"
    echo "The user '$EXCLUDE_USER' is NOT an administrator."
    echo "Continuing might leave the system with NO admin accounts."
    echo ""
    # Note: In MDM deployment, interactive 'read' might hang. 
    # For automation, this check should be handled via Applivery Policy.
    echo "Aborting for safety in automated environment."
    exit 1
fi

# ======== GET HUMAN USERS ========
# Only users with UID ≥ 501 and not starting with _
users=$(dscl . list /Users | grep -v '^_' | while read -r user; do
    uid=$(dscl . read "/Users/$user" UniqueID | awk '{print $2}')
    if [[ "$uid" =~ ^[0-9]+$ && "$uid" -ge 501 ]]; then
        echo "$user"
    fi
done)

# ======== PROCESS EACH USER ========
echo "Processing local users..."
echo "──────────────────────────────────────────────"

count_changed=0
count_skipped=0

while IFS= read -r username; do
    [[ -z "$username" ]] && continue

    if [[ "$username" == "$EXCLUDE_USER" ]]; then
        echo "[SKIP] $username  (intentionally excluded)"
        ((count_skipped++))
        continue
    fi

    if ! is_admin "$username"; then
        echo "[OK]   $username  → already standard (non-admin)"
        continue
    fi

    echo -n "[PROC] $username  → removing admin rights... "

    if dseditgroup -o edit -d "$username" -t user "$ADMIN_GROUP" 2>/dev/null; then
        echo "SUCCESS"
        ((count_changed++))
    else
        echo "FAILED"
        echo "   → Could not remove admin rights (directory service issue?)"
    fi

done <<< "$users"

echo "──────────────────────────────────────────────"
echo "Summary:"
echo "   Users processed       : $(echo "$users" | wc -l | xargs)"
echo "   Demoted to standard   : $count_changed"
echo "   Already standard      : $(($(echo "$users" | wc -l | xargs) - count_changed - count_skipped))"
echo "   Skipped (excluded)    : $count_skipped"
echo ""
echo "Protected user (should remain admin): $EXCLUDE_USER"
echo ""

# Final quick verification
if is_admin "$EXCLUDE_USER"; then
    echo "✓ User '$EXCLUDE_USER' still has administrator privileges."
else
    echo "⚠  ATTENTION: '$EXCLUDE_USER' is NO LONGER an administrator."
    echo "   It is strongly recommended to restore admin rights manually:"
    echo "   sudo dseditgroup -o edit -a \"$EXCLUDE_USER\" -t user admin"
fi

exit 0