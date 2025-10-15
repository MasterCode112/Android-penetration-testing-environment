# Android-penetration-testing-environment

**Android-penetration-testing-environment** is an automated setup script for preparing a complete **Android penetration testing environment**.  
It downloads, installs, and configures popular tools, APKs, and modules for Android app security testing.

---

## Features
- Downloads popular Android pentesting tools & APKs:
  - **Frida**, **Frida-Multiple-Bypass**, **MagiskTrustUserCerts**
  - **LSPosed** (Zygisk & Riru), **Shamiko**, **SafetyNet Fix**
  - **AndroGoat** vulnerable app for testing
  - Multiple Xposed modules for root detection bypass
- Installs required dependencies (adb, Python, frida-tools, etc.)
- Organizes everything in a single directory

---

## Installation
```bash
$ sudo curl -fsSL https://raw.githubusercontent.com/MasterCode112/Android-penetration-testing-environment/main/setup.sh | bash -s -- -euo pipefail
```
