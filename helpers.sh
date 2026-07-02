#!/bin/bash

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

pkg_install() {
  if pacman -Qi "$1" &>/dev/null; then
    ok "Package '$1' already installed"
    return 0
  fi
  info "Installing '$1'..."
  if sudo pacman -S --noconfirm --needed "$1"; then
    ok "Package '$1' installed"
  else
    error "Failed to install '$1'"
    return 1
  fi
}

aur_install() {
  if pacman -Qi "$1" &>/dev/null; then
    ok "AUR package '$1' already installed"
    return 0
  fi
  info "Installing AUR package '$1'..."
  if yay -S --noconfirm --needed "$1"; then
    ok "AUR package '$1' installed"
  else
    error "Failed to install AUR package '$1'"
    return 1
  fi
}

select_option() {
  local prompt="$1"
  shift
  local options=("$@")
  local selected=0

  echo "$prompt"
  for i in "${!options[@]}"; do
    echo "  $((i+1)). ${options[$i]}"
  done
  echo ""

  while true; do
    read -rp "Enter number (1-${#options[@]}): " choice
    if [[ $choice =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
      SELECTED="${options[$((choice-1))]}"
      return 0
    fi
    echo "Invalid choice, try again"
  done
}

# ---- Non-interactive mode helpers ----
# Set GNOME_ARCH_NONINTERACTIVE=true and provide env vars to skip prompts.

is_noninteractive() {
  [[ ${GNOME_ARCH_NONINTERACTIVE:-} == "true" ]]
}

# Select from list by matching env var value, or prompt interactively.
select_or_env() {
  local env_var="$1"
  local prompt="$2"
  shift 2
  local options=("$@")

  if is_noninteractive; then
    local val="${!env_var:-}"
    if [[ -z $val ]]; then
      error "$env_var must be set in non-interactive mode"
      exit 1
    fi
    for opt in "${options[@]}"; do
      if [[ $opt == *"$val"* ]]; then
        SELECTED="$opt"
        return 0
      fi
    done
    error "Value '$val' from $env_var does not match any option"
    exit 1
  fi

  select_option "$prompt" "${options[@]}"
}

# Prompt for input, or return env var value in non-interactive mode.
env_or_input() {
  local env_var="$1"
  local prompt="$2"

  if is_noninteractive; then
    local val="${!env_var:-}"
    if [[ -z $val ]]; then
      error "$env_var must be set in non-interactive mode"
      exit 1
    fi
    echo "$val"
    return 0
  fi

  local input
  read -rp "$prompt: " input
  echo "$input"
}

