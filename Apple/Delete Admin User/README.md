# Delete Local User

## 📝 Description
This script provides a clean way to permanently delete a local user account from a macOS device. Unlike simply removing the user from the UI, this script ensures that both the **Directory Services record** and the **Home Directory** (`/Users/username`) are completely wiped.

## ⚙️ How it works
1. **Safety First:** The script checks if the user exists and, most importantly, prevents the deletion of the user currently logged into the console to avoid system instability.
2. **Account Removal:** Uses `dscl` to remove the user from the local node.
3. **Data Cleanup:** Force-deletes the entire home folder of the user.
4. **Group Cleanup:** Attempts to remove the primary group associated with the account.

## 🛠 Variables to Customize
| Variable | Description |
| :--- | :--- |
| `$1` (Argument) | The short name (username) of the account to be deleted. |

## 📋 Requirements
- **Platform:** macOS.
- **Privileges:** Must run as `root` (Applivery default).

## 🚀 Applivery Deployment
1. Create a new **Custom Script** in Applivery.
2. Platform: **macOS**.
3. In the **Arguments** field of the Applivery deployment, specify the username you wish to delete.
4. Alternatively, you can edit the script and set `USER_NAME="the_user"` directly in the code.

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*