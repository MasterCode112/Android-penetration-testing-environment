#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# -----------------------------
# MasterCode Android Penetration Testing Environment
# -----------------------------

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_logo() {
  echo -e "${CYAN}"
  echo "  __  __           _             _               _      _            _  "
  echo " |  \/  | ___   __| | ___  _ __ (_) ___ ___     / \    | | ___   ___| | "
  echo " | |\/| |/ _ \ / _\` |/ _ \| '_ \| |/ __/ _ \   / _ \   | |/ _ \ / __| | "
  echo " | |  | | (_) | (_| | (_) | | | | | (_|  __/  / ___ \  | | (_) | (__|_| "
  echo " |_|  |_|\___/ \__,_|\___/|_| |_|_|\___\___| /_/   \_\ |_|\___/ \___(_) "
  echo -e "${GREEN}        MasterCode Android Penetration Testing Environment${NC}\n"
}

# Utilities
command_exists() { command -v "$1" >/dev/null 2>&1; }
ensure_sudo() {
  if [ "$EUID" -ne 0 ] && ! command_exists sudo; then
    echo -e "${RED}ERROR:${NC} This script requires 'sudo' or root privileges to install system packages."
    exit 1
  fi
}

# Target working dir
WORKDIR="$HOME/Android-pentest-tool"

# Repositories and downloads (array of "url:outname" or just "url")
REPOS=(
  "https://gitlab.com/newbit/rootAVD.git"
  "https://github.com/raoshaab/Pen-Andro.git"
  "https://github.com/pwnlogs/cert-fixer.git"
  "https://github.com/fdciabdul/Frida-Multiple-Bypass.git"
  "https://github.com/worawit/blutter.git"
  "https://github.com/httptoolkit/frida-interception-and-unpinning.git"
)

DOWNLOADS=(
  "https://github.com/NVISOsecurity/MagiskTrustUserCerts/releases/download/v0.4.1/AlwaysTrustUserCerts.zip"
  "https://github.com/frida/frida/releases/download/17.2.11/frida-server-17.2.11-android-x86_64.xz"
  "https://github.com/LSPosed/LSPosed/releases/download/v1.9.2/LSPosed-v1.9.2-7024-zygisk-release.zip"
  "https://github.com/LSPosed/LSPosed/releases/download/v1.9.2/LSPosed-v1.9.2-7024-riru-release.zip"
  "https://github.com/satishpatnayak/MyTest/raw/master/AndroGoat.apk"
  "https://github.com/Dr-TSNG/ZygiskNext/releases/download/v1.2.8/Zygisk-Next-1.2.8-512-4b5d6ad-release.zip"
  "https://github.com/LSPosed/LSPosed.github.io/releases/download/shamiko-383/Shamiko-v1.2.1-383-release.zip"
  "https://github.com/Xposed-Modules-Repo/top.ltfan.notdeveloper/releases/download/3-1.0.2/app-release.apk::am_not_developer.apk"
  "https://github.com/Xposed-Modules-Repo/ru.mike.mcroot/releases/download/8-2.1/mcroot_v2.1.apk"
  "https://github.com/kdrag0n/safetynet-fix/releases/download/v2.4.0/safetynet-fix-v2.4.0.zip"
  "https://github.com/chiteroman/PlayIntegrityFix/releases/download/v19.0/PlayIntegrityFix_v19.0.zip"
  "https://github.com/Dr-TSNG/Hide-My-Applist/releases/download/V3.4/HMA-V3.4.r436.d03edf7-release.zip"
  "https://github.com/5ec1cff/TrickyStore/archive/refs/heads/release.zip::TrickyStore-release.zip"
  "https://github.com/fatalSec/flutter_reversing/raw/refs/heads/main/funnybones.apk"
)

# System packages we want to ensure installed (apt-based)
SYS_PKGS=(wget git unzip xz-utils adb python3-pip python3-dev build-essential google-android-platform-tools-installer pipx)

main() {
  print_logo

  echo -e "${GREEN}[+]${NC} Preparing working directory: ${WORKDIR}"
  mkdir -p "$WORKDIR"
  cd "$WORKDIR"

  # Ensure sudo is available (for non-root users)
  ensure_sudo

  # Find missing system packages
  echo -e "${GREEN}[+]${NC} Checking required system packages..."
  PKGS_TO_INSTALL=()
  for pkg in "${SYS_PKGS[@]}"; do
    # map some commands to package names for quick check
    case "$pkg" in
      wget) check_cmd="wget" ;;
      git) check_cmd="git" ;;
      unzip) check_cmd="unzip" ;;
      xz-utils) check_cmd="xz" ;;
      adb) check_cmd="adb" ;;
      python3-pip) check_cmd="pip3" ;;
      pipx) check_cmd="pipx" ;;
      google-android-platform-tools-installer) check_cmd="adb" ;;
      *) check_cmd="$pkg" ;;
    esac

    if ! command_exists "$check_cmd"; then
      PKGS_TO_INSTALL+=("$pkg")
    fi
  done

  if [ "${#PKGS_TO_INSTALL[@]}" -gt 0 ]; then
    echo -e "${YELLOW}[i]${NC} Missing packages: ${PKGS_TO_INSTALL[*]}"
    echo -e "${GREEN}[+]${NC} Updating package lists and installing missing packages..."
    sudo apt-get update -y
    sudo apt-get install -y "${PKGS_TO_INSTALL[@]}"
  else
    echo -e "${GREEN}[+]${NC} All required system packages appear to be installed."
  fi

  # Ensure pipx present & frida-tools installed via pipx
  if ! command_exists pipx; then
    echo -e "${YELLOW}[i]${NC} pipx not found, attempting to install via pip..."
    python3 -m pip install --user pipx || true
    python3 -m pipx ensurepath || true
    export PATH="$HOME/.local/bin:$PATH"
  fi

  if ! command_exists pipx; then
    echo -e "${RED}ERROR:${NC} pipx installation failed. Please install pipx manually and re-run."
  else
    pipx ensurepath || true
    if ! pipx list | grep -q frida-tools; then
      echo -e "${GREEN}[+]${NC} Installing frida-tools via pipx..."
      pipx install frida-tools || echo -e "${YELLOW}[!]${NC} pipx install frida-tools failed (continue)."
    else
      echo -e "${GREEN}[+]${NC} frida-tools already installed via pipx."
    fi
  fi

  # Clone repos (skip if directory exists)
  echo -e "${GREEN}[+]${NC} Cloning repositories..."
  for repo in "${REPOS[@]}"; do
    dir=$(basename "${repo}" .git)
    if [ -d "$dir" ]; then
      echo " - Skipping ${dir} (already present)"
    else
      echo " - Cloning ${repo} ..."
      git clone --depth 1 "$repo" || echo -e "${YELLOW}[!]${NC} git clone failed for $repo (continuing)."
    fi
  done

  # Download files
  echo -e "${GREEN}[+]${NC} Downloading artifacts..."
  for item in "${DOWNLOADS[@]}"; do
    url="${item%%::*}"
    out="${item#*::}"
    if [ "$out" = "$item" ]; then out=""; fi
    filename="${out:-$(basename "$url")}"

    if [ -f "$filename" ]; then
      echo " - Skipping $filename (already exists)"
      continue
    fi

    echo " - Downloading: $url -> $filename"
    # using -c to allow resume; --show-progress provides a progress bar
    if ! wget -c --show-progress "$url" -O "$filename"; then
      echo -e "${YELLOW}[!]${NC} wget failed for $url (you may want to retry manually)."
    fi
  done

  # Minor convenience: rename the downloaded Xposed module apk if necessary
  if [ -f "app-release.apk" ] && [ ! -f "am_not_developer.apk" ]; then
    mv -n app-release.apk am_not_developer.apk || true
  fi

  echo -e "${GREEN}[+]${NC} All tasks attempted. Please verify files in: ${WORKDIR}"
  echo -e "${GREEN}[+]${NC} Next recommended steps:"
  echo "  - Inspect downloaded scripts/APKs before installing on devices."
  echo "  - Verify checksums/signatures where available."
  echo "  - To inspect APK versionCode/versionName: use 'aapt dump badging <APK>' (requires Android build-tools)."

  echo -e "${GREEN}[+] Setup finished.${NC}"
}

main "$@"
