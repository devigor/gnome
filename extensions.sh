#!/bin/bash

echo ""
echo "============================================"
echo "  GNOME Extensions"
echo "============================================"
echo ""

# Install extension packages (try pacman first, fallback to AUR)
ext_install() {
  pkg_install "$1" 2>/dev/null || aur_install "$1"
}

ext_install gnome-shell-extension-appindicator
ext_install gnome-shell-extension-dash-to-dock
ext_install gnome-shell-extension-clipboard-indicator

# Wait for GNOME Shell to be running before enabling
if pgrep -x gnome-shell &>/dev/null; then
  # Enable extensions
  gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null || true
  gnome-extensions enable dash-to-dock@micxgx.gmail.com 2>/dev/null || true
  gnome-extensions enable clipboard-indicator@tudmotu.com 2>/dev/null || true

  # Configure Dash to Dock
  dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 48 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/show-trash false 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/isolate-workspaces true 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/click-action "'minimize-or-previews'" 2>/dev/null || true

  # Configure Clipboard Indicator
  dconf write /org/gnome/shell/extensions/clipboard-indicator/history-size 50 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/clipboard-indicator/notify-on-copy false 2>/dev/null || true

  ok "Extensions enabled and configured"
else
  warn "GNOME Shell not running - extensions will be active after login"
fi
