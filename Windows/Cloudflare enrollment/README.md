# Cloudflare Zero Trust Enrollment

## 📝 Description
This script automates the registration of the **Cloudflare WARP** client into a specific **Zero Trust Organization**.

> [!IMPORTANT]
> **Requirement:** The Cloudflare WARP client must be installed on the machine prior to running this script. The script will validate the presence of `warp-cli` and fail if it's missing.

## ⚙️ How it works
1. **Requirement Check:** Validates if the WARP CLI is available in the system PATH.
2. **Registration:** Binds the client to the specified Team Name.
3. **Connection:** Enables the Zero Trust tunnel.

## 🛠 Variables to Customize
| Variable | Description | Example |
| :--- | :--- | :--- |
| `$OrgName` | Your Cloudflare Zero Trust organization slug. | `my-company-hq` |

## 📋 Requirements
- **Platform:** Windows 10 / 11.
- **Dependency:** Cloudflare WARP client (pre-installed).
- **Dependency:** Cloudflare Organization must exist under that name
- **Privileges:** Must run as **System/Administrator**.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*