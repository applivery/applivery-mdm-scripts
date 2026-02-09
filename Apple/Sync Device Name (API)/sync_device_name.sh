#!/bin/bash

# ---
# Title: Sync Device Name with Applivery API
# Description: Automatically updates the Device Display Name in Applivery Dashboard to match the local macOS ComputerName.
# Author: Applivery
# Version: 1.0.0
# ---

# ==========================================
# CONFIGURATION
# ==========================================
# IMPORTANT: Replace these values with your actual Organization ID and API Token
ID_ORG="lab"
API_TOKEN="API TOKEN"
BASE_URL="https://api.applivery.io/v1/organizations/$ID_ORG/mdm/apple/enterprise/devices"

# ==========================================
# 1. LOCAL DATA GATHERING
# ==========================================
SERIAL_NUMBER=$(system_profiler SPHardwareDataType | grep "Serial Number" | awk '{print $4}')
NEW_DEVICE_NAME=$(scutil --get ComputerName)

if [ -z "$NEW_DEVICE_NAME" ]; then
  echo "Error: Local ComputerName is empty. Please set a hostname on the Mac."
  exit 1
fi

echo "Syncing Device Name for Serial: $SERIAL_NUMBER"
echo "Target Name: $NEW_DEVICE_NAME"

# ==========================================
# 2. API INTERACTION
# ==========================================

# GET Device Info to find the internal Device ID
response=$(curl -s -X GET "$BASE_URL/$SERIAL_NUMBER" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json")

# Verify if admDevice exists in response
if echo "$response" | grep -q '"admDevice"'; then
  # Extract Device ID
  DEVICE_ID=$(echo "$response" | grep -o '"admDevice":"[^"]*"' | sed 's/"admDevice":"\([^"]*\)"/\1/')

  if [ -n "$DEVICE_ID" ]; then
    echo "Found internal DeviceID: $DEVICE_ID"

    # PUT request to update the display name
    update_response=$(curl -s -X PUT "$BASE_URL/$DEVICE_ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"displayName\": \"$NEW_DEVICE_NAME\"}")

    # Final Verification
    if echo "$update_response" | grep -q '"status":200' || echo "$update_response" | grep -q '"displayName"'; then
      echo "SUCCESS: Display name updated to: $NEW_DEVICE_NAME"
    else
      echo "FAILURE: Error updating name: $update_response"
    fi
  else
    echo "ERROR: Could not find DeviceID for Serial Number $SERIAL_NUMBER"
  fi
else
  echo "ERROR: Could not fetch device info from API. Check Token and Org ID."
  echo "Response: $response"
fi

exit 0