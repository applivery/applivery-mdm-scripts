# Force Reboot Policy (Windows)

## 📝 Description
This script enforces a reboot policy on Windows devices to ensure system stability, performance, and the application of pending security updates. It uses native Windows tools (`msg.exe` and `shutdown.exe`) to minimize external dependencies.

## ⚙️ Escalation Levels
The script evaluates the system uptime and takes the following actions:
1. **Day 5 to 9:** Displays a simple reminder message to the user.
2. **Day 10 to 14:** Displays a critical security warning, urging the user to restart before the deadline.
3. **Day 15+:** Triggers a **forced restart** with a 5-minute (300 seconds) countdown. The user cannot cancel this countdown.

## 🛠 Variables to Customize
| Variable | Description | Default |
| :--- | :--- | :--- |
| `$EnableForceRestart` | Set to `$false` to test the logic without actually rebooting. | `$true` |
| `$UptimeDays` | The script calculates this automatically, but can be overridden for testing. | `Auto` |

## 📋 Requirements
- **Platform:** Windows 10 / 11.
- **Privileges:** Must run as **System/Administrator**.
- **User Session:** The `msg` command requires an active user session to display the pop-up.

## 🚀 Applivery Deployment
1. Create a new **Custom Script** in Applivery for **Windows**.
2. **Policy:** Set as a **Periodic Script** (e.g., every 24 hours) to check the uptime daily.
3. **Logs:** The script will report the current "Phase" and uptime days to the Applivery execution logs.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*