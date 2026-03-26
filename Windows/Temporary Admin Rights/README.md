# Temporary Admin Access (JIT) - Windows

## 📝 Description
This script provides **Just-In-Time (JIT) Elevation** for Windows users. It promotes the current logged-in user to the local `Administrators` group for a fixed duration and then automatically demotes them back to a `Standard User`.

## ⚙️ How it works
1. **Language Agnostic:** Instead of hardcoding "Administradores" or "Administrators", the script uses the **Well-Known SID (S-1-5-32-544)** to find the correct local admin group regardless of the OS language.
2. **Abuse Prevention:** Implements a **Cooldown** mechanism. By default, a user must wait 30 minutes between elevation requests.
3. **Automated Cleanup:** The `finally` block ensures that even if the script is interrupted or fails, it attempts to remove the user from the admin group.

## 🛠 Variables to Customize
| Variable | Description | Default |
| :--- | :--- | :--- |
| `$DurationInSeconds` | Time the user remains an admin. | `300` (5 min) |
| `$CooldownInSeconds` | Wait time between successful elevations. | `1800` (30 min) |

## 📋 Requirements
- **Platform:** Windows 10 / 11.
- **Privileges:** Must be executed in a **System** or **Administrator** context via Applivery.
- **User:** A user must be logged into the physical or virtual console.

## 🚀 Applivery Deployment
1. Create a new **Custom Script** in Applivery.
2. Deployment Mode: **On-demand / Self-Service**.
3. Target: Windows Assets.
4. Users can trigger this from their **Applivery Agent** or **App Catalog** when they need to perform a specific administrative task (e.g., "Allow me to install this printer").

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*