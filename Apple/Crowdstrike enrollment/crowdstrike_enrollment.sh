#!/bin/bash

# ---
# Title: CrowdStrike Falcon Enrollment
# Description: Licenses and configures the CrowdStrike Falcon sensor after installation.
# Author: Applivery
# Version: 1.0.0
# ---

# ==========================================
# CONFIGURATION
# ==========================================
# Replace CID with your Customer ID checksum from the Falcon Console
CID="CUSTOMER-CID"

# Optional: Set a grouping tag for policy assignment
# GROUPING_TAG="YourTagHere"

# ==========================================
# MAIN LOGIC
# ==========================================

echo "Starting CrowdStrike Falcon configuration..."

# 1. Check if the Falcon agent is installed
if [ ! -f "/Applications/Falcon.app/Contents/Resources/falconctl" ]; then
    echo "ERROR: Falcon sensor is not installed at the expected path."
    exit 1
fi

# 2. Apply CID license
echo "Applying CID: $CID"
sudo /Applications/Falcon.app/Contents/Resources/falconctl license "$CID"

# 3. Set Grouping Tag (if variable is defined)
if [ -n "$GROUPING_TAG" ]; then
    echo "Setting grouping tag: $GROUPING_TAG"
    sudo /Applications/Falcon.app/Contents/Resources/falconctl grouping-tags set "$GROUPING_TAG"
fi

# 4. Restart the service to apply changes
echo "Restarting Falcon service..."
sudo /Applications/Falcon.app/Contents/Resources/falconctl unload
sudo /Applications/Falcon.app/Contents/Resources/falconctl load

echo "Configuration successfully updated."

exit 0