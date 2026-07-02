#!/bin/bash

echo ""
echo "============================================"
echo "  Font Installation"
echo "============================================"
echo ""

# Install JetBrains Mono Nerd Font (default system + terminal font)
pkg_install ttf-jetbrains-mono-nerd
pkg_install noto-fonts
pkg_install noto-fonts-cjk
pkg_install noto-fonts-emoji

# Set JetBrains Mono as default system font
gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font 10" 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name "JetBrainsMono Nerd Font 10" 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10" 2>/dev/null || true

# Create fontconfig to set JetBrains Mono as default monospace
mkdir -p ~/.config/fontconfig
if [[ -f ~/.config/fontconfig/fonts.conf ]] && [[ ! -f ~/.config/fontconfig/fonts.conf.bak ]]; then
  cp ~/.config/fontconfig/fonts.conf ~/.config/fontconfig/fonts.conf.bak
fi
cat > ~/.config/fontconfig/fonts.conf << 'FONTCONF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer><family>JetBrainsMono Nerd Font</family></prefer>
  </alias>
</fontconfig>
FONTCONF

fc-cache -f
ok "Fonts installed and configured"
