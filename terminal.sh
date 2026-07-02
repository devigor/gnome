#!/bin/bash

echo ""
echo "============================================"
echo "  Terminal Selection"
echo "============================================"

TERMINAL_OPTIONS=(
  "gnome-terminal  - Default GNOME terminal"
  "alacritty       - GPU-accelerated terminal emulator"
  "kitty           - Fast, feature-rich terminal emulator"
  "ghostty         - Native Wayland terminal emulator"
)

select_or_env "GNOME_ARCH_TERMINAL" "Choose your terminal emulator:" "${TERMINAL_OPTIONS[@]}"

case $SELECTED in
  *gnome-terminal*)
    TERMINAL_CHOICE="gnome-terminal"
    pkg_install gnome-terminal
    ;;
  *alacritty*)
    TERMINAL_CHOICE="alacritty"
    pkg_install alacritty
    # Install alacritty themes helper
    mkdir -p ~/.config/alacritty
    ;;
  *kitty*)
    TERMINAL_CHOICE="kitty"
    pkg_install kitty
    mkdir -p ~/.config/kitty
    ;;
  *ghostty*)
    TERMINAL_CHOICE="ghostty"
    pkg_install ghostty 2>/dev/null || aur_install ghostty
    mkdir -p ~/.config/ghostty
    ;;
esac

export TERMINAL_CHOICE
ok "Terminal selected: $TERMINAL_CHOICE"

# Install xdg-terminal-exec so xdg-open uses the chosen terminal
pkg_install xdg-terminal-exec

# Create xdg-terminal-exec config (user-level preference)
case $TERMINAL_CHOICE in
  gnome-terminal) term_desktop="org.gnome.Terminal.desktop" ;;
  alacritty)      term_desktop="Alacritty.desktop" ;;
  kitty)          term_desktop="kitty.desktop" ;;
  ghostty)        term_desktop="com.mitchellh.ghostty.desktop" ;;
esac
mkdir -p ~/.config
if [[ -f ~/.config/xdg-terminals.list ]] && [[ ! -f ~/.config/xdg-terminals.list.bak ]]; then
  cp ~/.config/xdg-terminals.list ~/.config/xdg-terminals.list.bak
fi
cat > ~/.config/xdg-terminals.list << XDGEOF
# xdg-terminal-exec configuration
$term_desktop
XDGEOF
