# Lost or Stolen Device Lock (Windows)

## 📝 Description
This script is designed for emergency situations where a Windows device is reported lost or stolen. It performs two main actions:
1. **Immediate Lock:** Triggers the native Windows lock screen (`LockWorkStation`).
2. **Persistent Notice:** Modifies the Windows Registry to show a customized legal message at every login attempt, even after a reboot.

## ⚙️ How it works
- **Registry Modification:** It writes to `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`. This ensures that anyone who finds the device sees the return instructions before they can even try to log in.
- **Immediate Action:** The `rundll32.exe` command forces the current session to lock without closing applications, securing user data instantly.

## 🛠 Variables to Customize
| Variable | Description | Default Value |
| :--- | :--- | :--- |
| `$NoticeTitle` | The headline shown on the login screen. | `DISPOSITIVO BLOQUEADO` |
| `$NoticeMsg` | The instructions for the person who finds the device. | `Este equipo ha sido reportado...` |

## 📋 Requirements
- **Platform:** Windows 10 / 11.
- **Privileges:** Must run as **System/Administrator** (Applivery default).

## 🚀 Applivery Deployment
1. Create a new **Custom Script** in Applivery.
2. Platform: **Windows**.
3. Policy: **On-demand** (Run it when the incident is reported).
4. Once executed, the device will be locked and the message will be displayed at every startup.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*