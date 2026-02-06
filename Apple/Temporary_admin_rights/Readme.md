# Temporary Admin Access

## 📝 Description
This script implements a "Just-In-Time" (JIT) admin elevation flow. It allows standard users to gain administrator privileges for a limited time (default: 3 minutes) only after providing a valid reason.

## ⚙️ How it works
1. **Validation:** Checks if the user is already an admin.
2. **Justification:** Opens a swiftDialog window requiring a text input (min. 5 characters).
3. **Elevation:** Adds the user to the `admin` group.
4. **Auto-Revoke:** Creates a temporary `LaunchDaemon` that waits for the specified time, removes the user from the admin group, and then deletes itself to leave no trace.

## 🛠 Variables to Customize
| Variable | Description | Default Value |
| :--- | :--- | :--- |
| `ADMIN_DURATION` | How long (in seconds) the user stays admin. | `180` |
| `MIN_REASON_LENGTH` | Minimum characters for the reason field. | `5` |

## 📋 Requirements
- **Platform:** macOS
- **Privileges:** Must run as `root` (Applivery default).
- **Dependencies:** **swiftDialog** (Installed automatically if missing).

## 🚀 Applivery Deployment
1. Create a new **Custom Script** in Applivery.
2. Platform: **macOS**.
3. Policy: **On-demand** (Self-Service) or via **Applivery Catalog**.
4. Users can then trigger this script whenever they need to install software or change system settings.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*