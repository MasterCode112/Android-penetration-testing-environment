#!/bin/bash
set -e  # Exit if any command fails

# Color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII logo function
print_logo() {
  echo -e "${CYAN}"
  echo " __  __           _             _               _      _            _  "
  echo "|  \/  | ___   __| | ___  _ __ (_) ___ ___     / \    | | ___   ___| | "
  echo "| |\/| |/ _ \ / _\` |/ _ \| '_ \| |/ __/ _ \   / _ \   | |/ _ \ / __| | "
  echo "| |  | | (_) | (_| | (_) | | | | | (_|  __/  / ___ \  | | (_) | (__|_| "
  echo "|_|  |_|\___/ \__,_|\___/|_| |_|_|\___\___| /_/   \_\ |_|\___/ \___(_) "
  echo -e "${GREEN}                  Mastercode Android PenKit${NC}\n"
}

print_logo

echo "[+] Creating working directory..."
mkdir -p Android-pentest-tool
cd Android-pentest-tool

echo "[+] Cloning Git repositories..."
git clone https://gitlab.com/newbit/rootAVD.git
git clone https://github.com/raoshaab/Pen-Andro.git
git clone https://github.com/pwnlogs/cert-fixer.git
git clone https://github.com/fdciabdul/Frida-Multiple-Bypass.git
git clone https://github.com/worawit/blutter.git
git clone https://github.com/httptoolkit/frida-interception-and-unpinning.git

echo "[+] Downloading APKs & ZIP tools..."
wget -q --show-progress https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/download/v0.4.1/AlwaysTrustUserCerts.zip
wget -q --show-progress https://github.com/frida/frida/releases/download/17.2.11/frida-server-17.2.11-android-x86_64.xz
wget -q --show-progress https://github.com/LSPosed/LSPosed/releases/download/v1.9.2/LSPosed-v1.9.2-7024-zygisk-release.zip
wget -q --show-progress https://github.com/LSPosed/LSPosed/releases/download/v1.9.2/LSPosed-v1.9.2-7024-riru-release.zip
wget -q --show-progress https://github.com/satishpatnayak/MyTest/raw/master/AndroGoat.apk
wget -q --show-progress https://github.com/Dr-TSNG/ZygiskNext/releases/download/v1.2.8/Zygisk-Next-1.2.8-512-4b5d6ad-release.zip
wget -q --show-progress https://github.com/LSPosed/LSPosed.github.io/releases/download/shamiko-383/Shamiko-v1.2.1-383-release.zip
wget -q --show-progress https://github.com/Xposed-Modules-Repo/top.ltfan.notdeveloper/releases/download/3-1.0.2/app-release.apk -O am_not_developer.apk
wget -q --show-progress https://github.com/Xposed-Modules-Repo/ru.mike.mcroot/releases/download/8-2.1/mcroot_v2.1.apk
wget -q --show-progress https://github.com/kdrag0n/safetynet-fix/releases/download/v2.4.0/safetynet-fix-v2.4.0.zip
wget -q --show-progress https://github.com/chiteroman/PlayIntegrityFix/releases/download/v19.0/PlayIntegrityFix_v19.0.zip
wget -q --show-progress https://github.com/Dr-TSNG/Hide-My-Applist/releases/download/V3.4/HMA-V3.4.r436.d03edf7-release.zip
wget -q --show-progress https://github.com/5ec1cff/TrickyStore/archive/refs/heads/release.zip -O TrickyStore.zip

echo "[+] Installing dependencies..."
sudo apt update
sudo apt install -y \
    python3-pip python3-dev build-essential \
    adb google-android-platform-tools-installer \
    pipx

echo "[+] Configuring pipx & installing frida-tools..."
pipx ensurepath
pipx install frida-tools

echo -e "${GREEN}[+] Setup complete! Enjoy your Mastercode Android PenKit!${NC}"
