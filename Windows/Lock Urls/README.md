# Network URL & Domain Blocker (Windows)

## 📝 Description
This PowerShell script provides a lightweight host-based web filtering solution. It automatically resolves a predefined list of domains to their current IP addresses and creates **Outbound Block Rules** in the Windows Defender Firewall.

## ⚙️ How it works
1. **DNS Resolution:** The script iterates through a categorized list of domains (Security Threats, Data Exfiltration, VPN/Proxies, etc.) and performs a DNS lookup to find all associated IPv4/IPv6 addresses.
2. **Firewall Enforcement:** For each identified IP, it generates a new `New-NetFirewallRule` with the `Outbound` direction and `Block` action.
3. **Persistent Protection:** The rules are named with the prefix `Bloqueo Applivery:`, making them easy to identify, manage, or remove from the Windows Firewall advanced interface.

## 🛡️ Blocked Categories
The script includes a comprehensive list of domains covering:
* **Direct Threats:** Malware hosting and exploit sites.
* **Data Exfiltration:** Unmanaged cloud storage and file transfer services.
* **Evasion Tools:** Proxies and VPN providers used to bypass corporate filters.
* **Remote Control:** Unauthorized remote desktop tools.
* **Unwanted Content:** Piracy and NSFW websites.

## 🛠 Variables to Customize
| Variable | Description |
| :--- | :--- |
| `$Domains` | Array containing the list of FQDNs (Fully Qualified Domain Names) to block. |

## 📋 Requirements
- **Platform:** Windows 10 / 11.
- **Privileges:** Must run as **System/Administrator** (required to modify Firewall rules).
- **Network:** Requires internet access during execution to resolve DNS records.

## 🚀 Applivery Deployment
1. Create a new **Custom Script** in Applivery for **Windows**.
2. **Policy:** It is recommended to run this as a **Periodic Script** (e.g., weekly) to catch any changes in the IP addresses of the blocked domains.
3. **Verification:** You can verify the active blocks by opening `wf.msc` on the target device and looking for rules starting with "Bloqueo Applivery".

---
*Part of the [Applivery Community Scripts](https://github.com/applivery/community-scripts) collection.*