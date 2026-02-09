#!/bin/bash

# ---
# Title: Delete Local User & Home Directory
# Description: Completely removes a local user account, its home directory, and its group record.
# Author: Applivery
# Version: 1.0.0
# ---

# ==========================================
# CONFIGURATION
# ==========================================
# If running via Applivery, you can hardcode the user here or use $1
USER_NAME=$1

# ==========================================
# 1. INITIAL CHECKS
# ==========================================

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root."
   exit 1
fi

# Check if the username argument is provided
if [ -z "$USER_NAME" ]; then
    echo "Error: No username provided. Usage: $0 <username>"
    exit 1
fi

# Safety Check: Prevent deleting the currently logged-in user
CURRENT_USER=$(stat -f "%Su" /dev/console)
if [ "$USER_NAME" == "$CURRENT_USER" ]; then
    echo "Error: Cannot delete the currently logged-in user ($USER_NAME)."
    exit 1
fi

# Check if the user actually exists
id "$USER_NAME" &>/dev/null
if [ $? -ne 0 ]; then
    echo "Error: User '$USER_NAME' does not exist."
    exit 1
fi

# ==========================================
# 2. DELETION PROCESS
# ==========================================
echo "Starting deletion process for user: $USER_NAME..."

# Delete the user record from Directory Services (dscl)
dscl . -delete "/Users/$USER_NAME"
if [ $? -eq 0 ]; then
    echo "[SUCCESS] User record removed from Directory Services."
else
    echo "[FAILURE] Failed to remove user record."
    exit 1
fi

# Delete the Home Directory
if [ -d "/Users/$USER_NAME" ]; then
    rm -rf "/Users/$USER_NAME"
    echo "[SUCCESS] Home directory /Users/$USER_NAME has been deleted."
else
    echo "[INFO] No home directory found at /Users/$USER_NAME."
fi

# Delete the primary group associated with the user
dscl . -delete "/Groups/$USER_NAME" &>/dev/null

echo "Process complete. User '$USER_NAME' has been fully removed."
exit 0