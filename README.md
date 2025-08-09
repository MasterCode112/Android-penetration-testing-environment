# Android-penetration-testing-environment

**Android-penetration-testing-environment** is an automated setup script for preparing a complete **Android penetration testing environment**.  
It downloads, installs, and configures popular tools, APKs, and modules for Android app security testing.

---

## ✨ Features
- Downloads popular Android pentesting tools & APKs:
  - **Frida**, **Frida-Multiple-Bypass**, **MagiskTrustUserCerts**
  - **LSPosed** (Zygisk & Riru), **Shamiko**, **SafetyNet Fix**
  - **AndroGoat** vulnerable app for testing
  - Multiple Xposed modules for root detection bypass
- Installs required dependencies (adb, Python, frida-tools, etc.)
- Organizes everything in a single directory

---

## 📦 Installation
```bash
git clone https://github.com/mastercode112/AndroPentestKit.git
cd AndroPentestKit
chmod +x setup.sh
./setup.sh
