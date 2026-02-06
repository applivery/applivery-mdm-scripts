# macOS Uptime Enforcement

## 📝 Description
This script monitors system uptime and prompts the user to reboot through escalating levels of notifications and dialogs using **swiftDialog**.

## ⚙️ Enforcement Levels
- **0-4 Days:** No notification.
- **5-8 Days:** Native notification (Non-intrusive).
- **9-12 Days:** Soft dialog in the corner with a "Postpone" option.
- **13+ Days:** Blocking screen blur with a mandatory 10-minute countdown to restart.

## 🧪 Testing the Script
To test the different UI behaviors without waiting for days, edit the script and uncomment the testing variable:
1. Locate `# TEST_UPTIME_DAYS="13"`
2. Uncomment it and change the number to the level you want to test (e.g., `7`, `10`, or `13`).
3. Run the script manually or via Applivery.

## 📋 Requirements
- **OS:** macOS 11.0+
- **Execution:** Must run as `root`.
- **Dependency:** The script automatically handles the installation/update of **swiftDialog**.

---
*Powered by Applivery Community*