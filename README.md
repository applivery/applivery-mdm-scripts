# Applivery Community Scripts 🚀

Welcome to the official repository for **Applivery Community Scripts**. This project is a curated collection of automation scripts designed to help IT Administrators manage, configure, and secure their fleet of devices using the Applivery MDM platform.

## 🗄️ Repository Structure

The repository is organized by Operating System. Each script has its own folder containing the script file and a specific documentation file.

* **/macOS**: Shell scripts (`.sh`) for macOS management (Intel and Apple Silicon).
* **/Windows**: PowerShell scripts (`.ps1`) for Windows 10/11 devices.

## 📂 Repository Index

### Apple (macOS)

| Script | API | User interaction | Version |
| :--- | :--- | :---: | :---: |
| **Create Admin User** <br/> *Automated creation of hidden management accounts.* | ❌ | ❌ |  `1.0.0` <br/> 2026-02-06 |
| **Crowdstrike enrollment** <br/> *Post-install licensing and tagging for Falcon sensors.* | ❌ | ❌ | `1.0.0` <br/> 2026-02-09 |
| **Delete Admin User** <br/> *Completely removes a user account and their data.* | ❌ | ❌ | `1.0.0` <br/> 2026-02-09 |
| **Force Reboot Policy** <br/> *Uptime monitoring and enforced restart intervals.* | ❌ | ✅ | `1.2.0` <br/> 2026-02-12 |
| **Restrict Admin Rights** <br/> *Demote local users to standard, keeping only IT admin.* | ❌ | ❌ | `1.0.0` <br/> 2026-02-06 |
| **Sync Device Name** <br/> *Syncs local ComputerName with Applivery Dashboard.* | ✅ | ❌ | `1.0.0` <br/> 2026-02-09 |
| **Temporary Admin Rights** <br/> *JIT elevation with reason logging and auto-revoke.* | ❌ | ✅ | `1.1.0` <br/> 2026-02-12 |

### Windows

| Script | API | User interaction | Version |
| :--- | :--- | :---: | :---: |
| **Cloudflare WARP Enrollment** <br/> *Joins the device to a Zero Trust organization.* | ❌ | ✅ | `1.1.0` <br/> 2026-02-12 |
| **Crowdstrike Installation** <br/> *Silent installation and CID licensing for Falcon sensor.* | ❌ | ❌ | `1.0.0` <br/> 2026-02-12 |
| **Lock Device** <br/> *Lost or Stolen Device Lock with persistent notice.*  | ❌ | ❌ | `1.0.0` <br/> 2026-02-09 |
| **Lock URLs** <br/> *Block specific domains via Windows Firewall.*  | ❌ | ❌ | `1.0.0` <br/> 2026-03-24 |
| **Force Reboot Policy** <br/> *Uptime monitoring and enforced restart intervals.* | ❌ | ✅ | `1.2.0` <br/> 2026-03-26 |
| **Temporary Admin Rights** <br/> *JIT elevation with reason logging and auto-revoke.* | ❌ | ✅ | `1.1.0` <br/> 2026-03-26 |


### Templates

| File | Description | Last Update |
| :--- | :--- | :---: |
| **README-script.md** | Documentation blueprint for new scripts. | 2026-02-06 |
| **template-macos.sh** | Bash boilerplate for macOS. | 2026-02-06 |
| **template-windows.ps1** | PowerShell boilerplate for Windows. | 2026-02-06 |

---

## 🚀 How to use these scripts

1.  **Browse** the repository and find the script that fits your needs.
2.  **Open** the script folder and read the specific `README.md` for instructions and variables.
3.  **Copy** the code.
4.  **Login** to your [Applivery Dashboard](https://dashboard.applivery.com).
5.  Navigate to **Device Management** > **Assets** and create a new one, pasting the code and selecting the appropriate execution context.

## 🤝 Contributing

We love community contributions! If you have a script that could help others:
1. Fork the repo.
2. Create a new folder under the correct OS.
3. Include your script and a README based on our template.
4. Submit a Pull Request.

## ⚠️ Disclaimer

These scripts are provided **"as is"** without any warranty of any kind. Applivery is not responsible for any damage or data loss caused by the execution of these scripts. **Always test scripts in a staging or sandbox environment before deploying them to your entire fleet.**

---
Built with ❤️ by the **Applivery Team** and the Community. Find us at https://www.applivery.com/