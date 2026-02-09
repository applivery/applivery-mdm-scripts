# Sync Device Name with Applivery

## 📝 Description
This script bridges the gap between the local macOS configuration and the Applivery Dashboard. It fetches the local `ComputerName` from the Mac and uses the **Applivery API** to update the device's "Display Name" in the portal.

## ⚙️ How it works
1. **Gathering:** It identifies the Mac by its **Serial Number** and reads the local **ComputerName**.
2. **Identification:** It queries the Applivery API to translate the Serial Number into an internal `admDevice` ID.
3. **Synchronization:** It sends a `PUT` request to update the device metadata in your Applivery Organization.

## 🛠 Variables to Customize
| Variable | Description | Example |
| :--- | :--- | :--- |
| `ID_ORG` | Your Applivery Organization Slug/ID. | `my-company-lab` |
| `API_TOKEN` | A valid API Token with MDM permissions. | `wfkj2Gi...` |

## 📋 Requirements
- **Platform:** macOS.
- **Connectivity:** The device must have internet access to reach `api.applivery.io`.
- **API Token:** You need a token generated from the Applivery Dashboard.

## 🚀 Applivery Deployment
1. Create a new **Custom Script** in Applivery.
2. Platform: **macOS**.
3. **Security Tip:** For production environments, ensure your API Token is kept secure and rotate it periodically.
4. This script is ideal to be run as a **Periodic Script** (e.g., once a week) to ensure the Dashboard stays up to date if users change their computer names.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*