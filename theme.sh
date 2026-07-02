#!/bin/bash

echo ""
echo "============================================"
echo "  Theme Selection"
echo "============================================"
echo ""

# Font size applied to all terminals
TERMINAL_FONT_SIZE=9.5

# List available themes
THEME_DIR="$GNOME_INSTALL_DIR/themes"
TEMPLATES_DIR="$GNOME_INSTALL_DIR/templates"

AVAILABLE_THEMES=()
for dir in "$THEME_DIR"/*/; do
  name=$(basename "$dir")
  AVAILABLE_THEMES+=("$name")
done

echo "Available themes:"
echo ""
select_or_env "GNOME_ARCH_THEME" "Choose your theme:" "${AVAILABLE_THEMES[@]}"
THEME_NAME="$SELECTED"

COLORS_FILE="$THEME_DIR/$THEME_NAME/colors.toml"
if [[ ! -f $COLORS_FILE ]]; then
  error "Theme '$THEME_NAME' has no colors.toml"
  exit 1
fi

ok "Selected theme: $THEME_NAME"

# ---- Render template for the selected terminal ----
render_template() {
  local template="$1"
  local output="$2"
  local sed_script
  sed_script=$(mktemp)

  while IFS='=' read -r key value; do
    key="${key//[\"\' ]/}"
    [[ $key && $key != \#* ]] || continue
    value="${value#*[\"\']}"
    value="${value%%[\"\']*}"
    printf 's|{{ %s }}|%s|g\n' "$key" "$value"
  done <"$COLORS_FILE" >"$sed_script"

  sed -f "$sed_script" "$template" >"$output"
  rm "$sed_script"
}

case $TERMINAL_CHOICE in
  alacritty)
    if [[ -f $TEMPLATES_DIR/alacritty.toml.tpl ]]; then
      render_template "$TEMPLATES_DIR/alacritty.toml.tpl" "$HOME/.config/alacritty/alacritty-colors.toml"
      # Create main alacritty config if it doesn't exist
      if [[ ! -f $HOME/.config/alacritty/alacritty.toml ]]; then
        cat > "$HOME/.config/alacritty/alacritty.toml" << ALACRITTY
[env]
TERM = "xterm-256color"

[terminal]
osc52 = "CopyPaste"

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
size = $TERMINAL_FONT_SIZE

[window]
padding.x = 14
padding.y = 14

general.import = [ "~/.config/alacritty/alacritty-colors.toml" ]
ALACRITTY
      fi
      ok "Alacritty theme applied"
    fi
    ;;

  ghostty)
    if [[ -f $TEMPLATES_DIR/ghostty.conf.tpl ]]; then
      render_template "$TEMPLATES_DIR/ghostty.conf.tpl" "$HOME/.config/ghostty/theme.conf"
      if [[ ! -f $HOME/.config/ghostty/config ]]; then
        cat > "$HOME/.config/ghostty/config" << GHOSTTY
font-family = "JetBrainsMono Nerd Font"
font-size = $TERMINAL_FONT_SIZE
font-style = Regular

window-padding-x = 14
window-padding-y = 14
confirm-close-surface = false
resize-overlay = never
window-theme = ghostty
gtk-toolbar-style = flat

cursor-style = block
cursor-style-blink = false

shell-integration-features = no-cursor,ssh-env

mouse-scroll-multiplier = 0.95
async-backend = epoll

keybind = shift+insert=paste_from_clipboard
keybind = control+insert=copy_to_clipboard

config-file = "~/.config/ghostty/theme.conf"
GHOSTTY
      fi
      ok "Ghostty theme applied"
    fi
    ;;

  kitty)
    if [[ -f $TEMPLATES_DIR/kitty.conf.tpl ]]; then
      render_template "$TEMPLATES_DIR/kitty.conf.tpl" "$HOME/.config/kitty/kitty-colors.conf"
      if [[ ! -f $HOME/.config/kitty/kitty.conf ]]; then
        cat > "$HOME/.config/kitty/kitty.conf" << KITTY
font_family JetBrainsMono Nerd Font
bold_font JetBrainsMono Nerd Font
italic_font JetBrainsMono Nerd Font
font_size $TERMINAL_FONT_SIZE

hide_window_decorations titlebar-only
confirm_os_window_close 0

cursor_shape block
cursor_blink_interval 0

shell_integration enabled

include kitty-colors.conf
KITTY
      fi
      ok "Kitty theme applied"
    fi
    ;;

  gnome-terminal)
    if ! command -v dconf &>/dev/null; then
      pkg_install dconf
    fi

    profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
    if [[ -z $profile_id ]]; then
      profile_id=$(uuidgen)
      dconf write /org/gnome/terminal/legacy/profiles:/default "'$profile_id'"
    fi

    profile_path="/org/gnome/terminal/legacy/profiles:/:$profile_id/"

    bg=; fg=; c0=; c1=; c2=; c3=; c4=; c5=; c6=; c7=; c8=; c9=; c10=; c11=; c12=; c13=; c14=; c15=
    while IFS='=' read -r key value; do
      key="${key//[\"\' ]/}"
      [[ $key && $key != \#* ]] || continue
      value="${value#*[\"\']}"
      value="${value%%[\"\']*}"
      case $key in
        background) bg=$value ;;
        foreground) fg=$value ;;
        color0)  c0=$value ;; color1)  c1=$value ;; color2)  c2=$value ;; color3)  c3=$value ;;
        color4)  c4=$value ;; color5)  c5=$value ;; color6)  c6=$value ;; color7)  c7=$value ;;
        color8)  c8=$value ;; color9)  c9=$value ;; color10) c10=$value ;; color11) c11=$value ;;
        color12) c12=$value ;; color13) c13=$value ;; color14) c14=$value ;; color15) c15=$value ;;
      esac
    done <"$COLORS_FILE"

    dconf write "${profile_path}visible-name" "'gnome-arch $THEME_NAME'"
    dconf write "${profile_path}use-theme-colors" "false"
    dconf write "${profile_path}background-color" "'$bg'"
    dconf write "${profile_path}foreground-color" "'$fg'"
    dconf write "${profile_path}bold-color" "'$fg'"
    dconf write "${profile_path}bold-color-same-as-fg" "true"

    palette="['$c0', '$c1', '$c2', '$c3', '$c4', '$c5', '$c6', '$c7', '$c8', '$c9', '$c10', '$c11', '$c12', '$c13', '$c14', '$c15']"
    dconf write "${profile_path}palette" "$palette"

    dconf write "${profile_path}font" "'JetBrainsMono Nerd Font $TERMINAL_FONT_SIZE'"
    dconf write "${profile_path}use-system-font" "false"

    ok "GNOME Terminal theme applied"
    ;;
esac

# ---- Starship theme ----
# Apply accent/highlight color from theme to starship
STARSHIP_COLORS_FILE="$HOME/.config/starship.toml"
if [[ -f $STARSHIP_COLORS_FILE ]] && [[ ! -f $STARSHIP_COLORS_FILE.bak ]]; then
  cp "$STARSHIP_COLORS_FILE" "$STARSHIP_COLORS_FILE.bak"
  info "Existing starship.toml backed up"
fi
if [[ -f $COLORS_FILE ]]; then
  accent_color=$(grep '^accent' "$COLORS_FILE" | head -1 | sed 's/.*=[[:space:]]*"\(.*\)".*/\1/')
  if [[ -z $accent_color ]]; then
    accent_color=$(grep '^color4' "$COLORS_FILE" | head -1 | sed 's/.*=[[:space:]]*"\(.*\)".*/\1/')
  fi
else
  accent_color="#89b4fa"
fi

cat > "$STARSHIP_COLORS_FILE" << STARSHEOF
add_newline = true
command_timeout = 200
format = "[\$directory\$git_branch\$git_status](\$style)\$character"

[character]
error_symbol = "[✗](bold $accent_color)"
success_symbol = "[❯](bold $accent_color)"

[directory]
truncation_length = 2
truncation_symbol = "…/"
repo_root_style = "bold $accent_color"
repo_root_format = "[\$repo_root](\$repo_root_style)[\$path](\$style)[\$read_only](\$read_only_style) "

[git_branch]
format = "[\$branch](\$style) "
style = "italic $accent_color"

[git_status]
format = '[\$all_status](\$style)'
style = "$accent_color"
ahead = "⇡\${count} "
diverged = "⇕⇡\${ahead_count}⇣\${behind_count} "
behind = "⇣\${count} "
conflicted = " "
up_to_date = " "
untracked = "? "
modified = " "
stashed = ""
staged = ""
renamed = ""
deleted = ""
STARSHEOF

ok "Starship theme applied with accent: $accent_color"

# Store the theme name for reference
echo "$THEME_NAME" > "$HOME/.config/gnome-arch-theme" 2>/dev/null || true
