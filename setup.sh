#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# -----------------------------
# MasterCode Android Pentest Environment (quiet mode)
# -----------------------------

# Toggle verbosity: set VERBOSE=1 to see full command output, otherwise it's quiet.
VERBOSE=${VERBOSE:-0}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

WORKDIR="$HOME/Android-pentest-tool"
LOGFILE="$WORKDIR/install.log"

print_logo() {
  echo -e "${CYAN}"
  echo "  __  __           _             _               _      _            _  "
  echo " |  \/  | ___   __| | ___  _ __ (_) ___ ___     / \    | | ___   ___| | "
  echo " | |\/| |/ _ \ / _\` |/ _ \| '_ \| |/ __/ _ \   / _ \   | |/ _ \ / __| | "
  echo " | |  | | (_) | (_| | (_) | | | | | (_|  __/  / ___ \  | | (_) | (__|_| "
  echo " |_|  |_|\___/ \__,_|\___/|_| |_|_|\___\___| /_/   \_\ |_|\___/ \___(_) "
  echo -e "${GREEN}        MasterCode Android Penetration Testing Environment${NC}\n"
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Run a command quietly, log output, show friendly messages.
# Arguments:
#  $1 = short message to show (e.g., "Installing packages")
#  $2... = command to run
run_quiet() {
  local msg="$1"; shift
  printf "%-60s" "${msg}..."
  if [ "$VERBOSE" -eq 1 ]; then
    # verbose: show and log
    echo "" >> "$LOGFILE"
    echo "=== RUN: $msg ===" | tee -a "$LOGFILE"
    if "$@"; then
      echo -e "${GREEN}done${NC}"
      echo "=== OK: $msg ===" >> "$LOGFILE"
      return 0
    else
      echo -e "${RED}FAILED${NC}"
      echo "=== FAIL: $msg ===" >> "$LOGFILE"
      echo -e "${YELLOW}Last 40 lines of log:${NC}"
      tail -n 40 "$LOGFILE"
      exit 1
    fi
  else
    # quiet: redirect stdout/stderr to log file
    echo "" >> "$LOGFILE"
    echo "=== RUN: $msg ===" >> "$LOGFILE"
    if "$@" >> "$LOGFILE" 2>&1; then
      echo -e "${GREEN}done${NC}"
      echo "=== OK: $msg ===" >> "$LOGFILE"
      return 0
    else
      echo -e "${RED}FAILED${NC}"
      echo "=== FAIL: $msg ===" >> "$LOGFILE"
      echo -e "${YELLOW}Last 40 lines of log:${NC}"
      tail -n 40 "$LOGFILE"
      exit 1
    fi
  fi
}

# Run a command quietly but don't exit on failure; report failure and continue.
run_quiet_allow_fail() {
  local msg="$1"; shift
  printf "%-60s" "${msg}..."
  if [ "$VERBOSE" -eq 1 ]; then
    echo "" >> "$LOGFILE"
    echo "=== RUN (may fail): $msg ===" | tee -a "$LOGFILE"
    if "$@"; then
      echo -e "${GREEN}done${NC}"
      echo "=== OK: $msg ===" >> "$LOGFILE"
      return 0
    else
      echo -e "${YELLOW}warning${NC}"
      echo "=== WARN: $msg ===" >> "$LOGFILE"
      return 1
    fi
  else
    echo "" >> "$LOGFILE"
    echo "=== RUN (may fail): $msg ===" >> "$LOGFILE"
    if "$@" >> "$LOGFILE" 2>&1; then
      echo -e "${GREEN}done${NC}"
      echo "=== OK: $msg ===" >> "$LOGFILE"
      return 0
    else
      echo -e "${YELLOW}warning${NC}"
      echo "=== WARN: $msg ===" >> "$LOGFILE"
      return 1
    fi
  fi
}

ensure_sudo() {
  if [ "$EUID" -ne 0 ] && ! command_exists sudo; then
    echo -e "${RED}ERROR:${NC} This script requires 'sudo' or root privileges to install system packages."
    exit 1
  fi
}

# --- your lists (unchanged) ---
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

SYS_PKGS=(wget git unzip xz-utils adb python3-pip python3-dev build-essential google-android-platform-tools-installer pipx)

main() {
  print_logo

  echo -e "${GREEN}[+]${NC} Preparing working directory: ${WORKDIR}"
  mkdir -p "$WORKDIR"
  cd "$WORKDIR"
  # reset log file
  : > "$LOGFILE"

  ensure_sudo

  # Check which system packages are missing
  PKGS_TO_INSTALL=()
  for pkg in "${SYS_PKGS[@]}"; do
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
    run_quiet "Updating apt lists" sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
    run_quiet "Installing system packages: ${PKGS_TO_INSTALL[*]}" \
      sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install -y "${PKGS_TO_INSTALL[@]}"
    echo -e "${GREEN}[+]${NC} Installed system packages."
  else
    echo -e "${GREEN}[+]${NC} All required system packages already present."
  fi

  # pipx install (quiet)
  if ! command_exists pipx; then
    run_quiet_allow_fail "Installing pipx (user pip)" python3 -m pip install --user pipx
    run_quiet_allow_fail "Ensuring pipx path" python3 -m pipx ensurepath || true
    export PATH="$HOME/.local/bin:$PATH"
  fi

  # ensure pipx is present before using it
  if command_exists pipx; then
    if ! pipx list 2>/dev/null | grep -q frida-tools; then
      run_quiet "Installing frida-tools via pipx" pipx install frida-tools
    else
      echo -e "${GREEN}[+]${NC} frida-tools already installed via pipx."
    fi
  else
    echo -e "${YELLOW}[!]${NC} pipx not available; please install pipx manually to manage frida-tools."
  fi

  # Clone repos quietly
  echo -e "${GREEN}[+]${NC} Cloning repositories..."
  for repo in "${REPOS[@]}"; do
    dir=$(basename "${repo}" .git)
    if [ -d "$dir" ]; then
      echo " - ${dir}: skipped (already present)"
      continue
    fi
    run_quiet "Cloning ${dir}" git clone --depth 1 "$repo"
  done

  # Download files quietly
  echo -e "${GREEN}[+]${NC} Downloading artifacts..."
  for item in "${DOWNLOADS[@]}"; do
    url="${item%%::*}"
    out="${item#*::}"
    if [ "$out" = "$item" ]; then out=""; fi
    filename="${out:-$(basename "$url")}"

    if [ -f "$filename" ]; then
      echo " - $filename: skipped (exists)"
      continue
    fi

    # Use wget quiet; resume support with -c.
    run_quiet_allow_fail "Downloading $(basename "$filename")" wget -c -q "$url" -O "$filename"
    if [ -f "$filename" ]; then
      echo " - $filename: saved"
    else
      echo -e "${YELLOW}[!]${NC} $filename not present after download attempt."
    fi
  done

  echo -e "${GREEN}[+]${NC} All tasks attempted. Log saved to: ${LOGFILE}"
  echo -e "${GREEN}[+]${NC} Next recommended steps:"
  echo "  - Inspect downloaded scripts/APKs before installing on devices."
  echo "  - Verify checksums/signatures where available."
  echo "  - For debugging re-run with VERBOSE=1 to see full logs in the terminal."
  echo -e "${GREEN}[+] Setup finished.${NC}"
}

main "$@"
