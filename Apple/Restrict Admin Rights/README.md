# Demote Local Admins

## 📝 Description
This script enforces a security policy by removing administrator privileges from all local user accounts, except for one designated "Protected User" (typically the IT management account).

## ⚙️ How it works
1. **Safety Check:** Verifies that the designated `EXCLUDE_USER` exists and is an administrator before proceeding to avoid "locking out" the system.
2. **User Discovery:** Scans the directory service for "human" users (UID ≥ 501), ignoring system accounts (starting with `_`).
3. **Privilege Removal:** Iterates through each user and, if they have admin rights and are not the excluded user, demotes them to a Standard User.
4. **Verification:** Performs a final check to confirm the protected user still has admin rights.

## 🛠 Variables to Customize
| Variable | Description | Default Value |
| :--- | :--- | :--- |
| `EXCLUDE_USER` | The username that MUST keep admin rights. | `admin` |

## ⚠️ Important Note for MDM
This script is designed to run silently. However, it contains a safety check that aborts if the `EXCLUDE_USER` is not an admin. Ensure your management account is properly provisioned before deploying this script to your fleet.

## 📋 Requirements
- **Platform:** macOS
- **Privileges:** Must run as `root` (Applivery default).

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*