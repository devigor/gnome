#!/bin/bash
set -Eo pipefail

GNOME_INSTALL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export GNOME_INSTALL_DIR

# Source helpers
source "$GNOME_INSTALL_DIR/helpers.sh"

clear
echo "============================================"
echo "  gnome-arch - Arch Linux + GNOME Setup"
echo "============================================"
echo ""

# Check system requirements
if [[ $(id -u) -eq 0 ]]; then
  echo "ERROR: Do not run as root"
  exit 1
fi

if [[ ! -f /etc/arch-release ]]; then
  echo "ERROR: This installer is for Arch Linux only"
  exit 1
fi

echo "This script will set up your Arch Linux with GNOME desktop."
echo ""
echo "Installation steps:"
echo "  1. Select terminal emulator"
echo "  2. Select packages to install"
echo "  3. Install fonts"
echo "  4. Configure ZSH shell"
echo "  5. Select and apply theme"
echo "  6. System configuration"
echo "  7. GNOME extensions"
echo ""

if ! is_noninteractive; then
  read -rp "Press Enter to start installation..."
fi

# Bootstrap: ensure yay is available before any phase
if ! command -v yay &>/dev/null; then
  info "Installing yay (AUR helper)..."
  pkg_install base-devel git
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
  ok "yay installed"
fi

# Phase 1: Terminal
source "$GNOME_INSTALL_DIR/terminal.sh"

# Phase 2: Packages
source "$GNOME_INSTALL_DIR/packages.sh"

# Phase 3: Fonts
source "$GNOME_INSTALL_DIR/fonts.sh"

# Phase 4: Shell
source "$GNOME_INSTALL_DIR/shell.sh"

# Phase 5: Theme
source "$GNOME_INSTALL_DIR/theme.sh"

# Phase 6: Config
source "$GNOME_INSTALL_DIR/config.sh"

# Phase 7: GNOME Extensions
source "$GNOME_INSTALL_DIR/extensions.sh"

echo ""
echo "============================================"
echo "  Installation complete!"
echo "  Please reboot to start using GNOME."
echo "============================================"
