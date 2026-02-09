# Applivery Community Scripts 🚀

Welcome to the official repository for **Applivery Community Scripts**. This project is a curated collection of automation scripts designed to help IT Administrators manage, configure, and secure their fleet of devices using the Applivery MDM platform.

## 📂 Repository Structure

The repository is organized by Operating System. Each script has its own folder containing the script file and a specific documentation file.

* **/macOS**: Shell scripts (`.sh`) for macOS management (Intel and Apple Silicon).
* **/Windows**: PowerShell scripts (`.ps1`) for Windows 10/11 devices.

## 📂 Repository Structure

```text
.
├── 🛠️ .templates ................... [2026-02-06]
│   ├── README-script.md (Documentation blueprint)
│   ├── template-macos.sh (Bash boilerplate)
│   └── template-windows.ps1 (PowerShell boilerplate)
│
├── 🍎 Apple (macOS)
│   ├── 📁 Create Admin User ......... [2026-02-06]
│   │   └── Automated creation of hidden management accounts.
│   ├── 📁 Crowdstrike enrollment .... [2026-02-09]
│   │   └── Post-install licensing and tagging for Falcon sensors.
│   ├── 📁 Force Reboot Policy ....... [2026-02-06]
│   │   └── Uptime monitoring and enforced restart intervals.
│   ├── 📁 Restrict Admin Rights ..... [2026-02-06]
│   │   └── Demote local users to standard, keeping only IT admin.
│   └── 📁 Temporary Admin Rights .... [2026-02-06]
│       └── JIT elevation with reason logging and auto-revoke.
│
└── 🪟 Windows
    ├── 📁 Lock Device ......... [2026-02-09]
        └── Lost or Stolen Device Lock.
```

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