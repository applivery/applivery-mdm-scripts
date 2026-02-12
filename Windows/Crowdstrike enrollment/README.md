# CrowdStrike Falcon Installation (Windows)

## 📝 Description
This script automates the silent installation of the **CrowdStrike Falcon Sensor** on Windows endpoints. It ensures the sensor is properly licensed and linked to your organization's Falcon Console.

## ⚙️ How it works
1. **Pre-flight Check:** Verifies that the `WindowsSensor.exe` is present in the execution directory.
2. **Silent Install:** Runs the installer with `/quiet` and `/norestart` flags to avoid user interruption.
3. **Provisioning:** Passes the `CID` parameter during installation for immediate enrollment.
4. **Error Handling:** Captures the installer's exit code to report success or failure back to the Applivery Dashboard.

## 🛠 Variables to Customize
| Variable | Description | Example |
| :--- | :--- | :--- |
| `$CID` | Your Falcon Customer ID (with checksum). | `12345ABC...-B0` |
| `$Installer` | The name of the installer file. | `WindowsSensor.exe` |

## 📋 Requirements & Deployment
- **Platform:** Windows 10 / 11.
- **Privileges:** Must run as **System/Administrator**.
- **Important:** Since Applivery Custom Scripts run independently, you must ensure the `.exe` is available.
    - **Recommended Method:** Distribute the `WindowsSensor.exe` via **Applivery App Distribution** as a private app first, or ensure it is downloaded to a known path before execution.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*