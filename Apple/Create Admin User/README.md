# Create Hidden Admin Account

## 📝 Description
This script ensures that a specific local administrator account exists on the system. It is designed for IT management purposes, allowing for a "backdoor" or maintenance account that remains invisible to the end user.

## ⚙️ How it works
- **Existence Check:** If the user already exists, it simply updates the password to match the one defined in the script.
- **Hidden Status:** If the `HIDDEN` variable is set to `yes`, the user will not appear in the macOS login window or the "Users & Groups" settings pane (though it will still exist in the file system).
- **Creation:** If the user doesn't exist, it uses `sysadminctl` to create a new administrator account with the specified credentials.

## 🛠 Variables to Customize
| Variable | Description | Default Value |
| :--- | :--- | :--- |
| `USERNAME` | The short name of the account. | `admin` |
| `FULLNAME` | The display name of the account. | `admin` |
| `PASSWORD` | The password for the account. | `PASSWORD` |
| `HIDDEN` | Whether to hide the account from the UI. | `yes` |

## 📋 Requirements
- **Platform:** macOS
- **Privileges:** Must run as `root` (Applivery default).
- **Security Note:** Since the password is stored in plain text within the script, ensure that access to your Applivery Dashboard is restricted to authorized personnel only.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*