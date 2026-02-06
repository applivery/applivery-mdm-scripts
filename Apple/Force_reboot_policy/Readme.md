# macOS Uptime Enforcement (Branded)

## 📝 Description
This script monitors system uptime and prompts users to reboot through escalating levels of alerts. It is designed to maintain system health and ensure security patches are applied.

## 🎨 Branding & Identity
**Crucial:** This script follows corporate policy regarding visual identity.
- It requires a logo file located at `/var/root/AppliveryAssets/applivery.png`.
- The script automatically handles the branding by resizing and deploying the logo to the swiftDialog assets folder.
- **Why it matters:** Using the official corporate logo increases user trust and ensures that system-level prompts are recognized as legitimate IT communications.

## ⚙️ How it works
- **Clean Install:** It removes any existing `/Applications/Dialog.app` to prevent version conflicts.
- **Auto-Provisioning:** If swiftDialog is missing or the brand icon needs updating, the script installs the latest version from GitHub.
- **Escalation:** Actions range from simple notifications (Day 5) to a forced 10-minute reboot countdown (Day 13+).

## 🧪 Testing
To test the UI levels, uncomment `TEST_UPTIME_DAYS` at the top of the script and set it to `7`, `10`, or `13`.

## 📋 Requirements
- **Platform:** macOS 11.0+
- **Execution:** Run as `root` via Applivery Custom Scripts.
- **Assets:** Ensure `applivery.png` is present in the specified assets path.