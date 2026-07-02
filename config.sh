#!/bin/bash

echo ""
echo "============================================"
echo "  System Configuration"
echo "============================================"
echo ""

# ---- Git ----
if command -v git &>/dev/null; then
  if [[ -z $(git config --global user.name 2>/dev/null) ]]; then
    git_name=$(env_or_input "GNOME_ARCH_GIT_NAME" "Git user name")
    git config --global user.name "$git_name"
  fi
  if [[ -z $(git config --global user.email 2>/dev/null) ]]; then
    git_email=$(env_or_input "GNOME_ARCH_GIT_EMAIL" "Git user email")
    git config --global user.email "$git_email"
  fi
  git config --global init.defaultBranch main
  ok "Git configured"
fi

# ---- Docker ----
if command -v docker &>/dev/null; then
  if ! groups "$USER" | grep -q docker; then
    sudo usermod -aG docker "$USER"
    ok "User added to docker group (login required)"
  fi
  sudo systemctl enable docker --now 2>/dev/null || true
  ok "Docker service enabled"
fi

# ---- Mise ----
if command -v mise &>/dev/null; then
  mkdir -p "$HOME/.config/mise"
  if [[ -f $HOME/.config/mise/config.toml ]] && [[ ! -f $HOME/.config/mise/config.toml.bak ]]; then
    cp "$HOME/.config/mise/config.toml" "$HOME/.config/mise/config.toml.bak"
  fi
  cat > "$HOME/.config/mise/config.toml" << 'MISEEOF'
[plugins]
node = "registry:node"
python = "registry:python"
ruby = "registry:ruby"
go = "registry:go"
rust = "registry:rust"
java = "registry:java"
MISEEOF
  ok "Mise configured"
fi

# ---- GNOME settings ----
info "Applying GNOME preferences..."

# Dark mode
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true

# Show weekday on clock
gsettings set org.gnome.desktop.interface clock-show-weekday true 2>/dev/null || true

# Enable minimize/maximize buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close" 2>/dev/null || true

# Nautilus preferences
gsettings set org.gnome.nautilus.preferences show-hidden-files true 2>/dev/null || true
gsettings set org.gnome.nautilus.preferences default-folder-viewer "list-view" 2>/dev/null || true

# Touchpad
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true 2>/dev/null || true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true 2>/dev/null || true

# Disable screen lock
gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true

# Favorite apps in dock
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop']" 2>/dev/null || true

ok "GNOME preferences configured"

# ---- System tweaks ----
# Increase file watcher limit for development
if [[ ! -f /etc/sysctl.d/99-inotify.conf ]]; then
  echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
  sudo sysctl -p /etc/sysctl.d/99-inotify.conf 2>/dev/null || true
  ok "File watcher limit increased"
fi

# Enable multilib
if ! grep -q '^\[multilib\]' /etc/pacman.conf 2>/dev/null; then
  echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null
  sudo pacman -Sy --noconfirm 2>/dev/null || true
  ok "Multilib repository enabled"
fi

# Truncate package list in pacman output
sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf 2>/dev/null || true

ok "System configuration complete"
