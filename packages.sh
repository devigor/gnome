#!/bin/bash

echo ""
echo "============================================"
echo "  Package Selection"
echo "============================================"
echo ""

# Read package list
mapfile -t ALL_PACKAGES < <(grep -v '^#' "$GNOME_INSTALL_DIR/packages.txt" | grep -v '^$')

# Always-installed defaults (dev essentials)
DEFAULT_PACKAGES=(
  docker docker-compose nvim mise
  eza zoxide starship fzf
  ripgrep fd bat jq tldr
  lazygit lazydocker tmux
  github-cli wl-clipboard tree-sitter-cli
  rust unzip fontconfig less man-db
  git base-devel
)

echo "Default packages (always installed):"
for pkg in "${DEFAULT_PACKAGES[@]}"; do
  echo "  - $pkg"
done
echo ""

echo "Available packages (select which to install):"
echo ""

SELECTED_PACKAGES=()
if is_noninteractive; then
  case ${GNOME_ARCH_PACKAGES:-} in
    ALL)
      SELECTED_PACKAGES=("${ALL_PACKAGES[@]}")
      info "Non-interactive: installing ALL optional packages"
      ;;
    "")
      info "Non-interactive: no optional packages selected (set GNOME_ARCH_PACKAGES)"
      ;;
    *)
      read -ra selected <<< "$GNOME_ARCH_PACKAGES"
      for pkg in "${ALL_PACKAGES[@]}"; do
        for sel in "${selected[@]}"; do
          if [[ $pkg == "$sel" ]]; then
            SELECTED_PACKAGES+=("$pkg")
          fi
        done
      done
      info "Non-interactive: selected ${#SELECTED_PACKAGES[@]} optional packages"
      ;;
  esac
else
  for pkg in "${ALL_PACKAGES[@]}"; do
    read -rp "  Install '$pkg'? [Y/n]: " choice
    if [[ ! $choice =~ ^[Nn]$ ]]; then
      SELECTED_PACKAGES+=("$pkg")
    fi
  done
fi

echo ""
info "Installing default packages..."
for pkg in "${DEFAULT_PACKAGES[@]}"; do
  pkg_install "$pkg"
done

info "Installing selected packages..."
for pkg in "${SELECTED_PACKAGES[@]}"; do
  pkg_install "$pkg" 2>/dev/null || aur_install "$pkg"
done

ok "Package installation complete"
