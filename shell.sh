#!/bin/bash

echo ""
echo "============================================"
echo "  Shell Configuration (ZSH)"
echo "============================================"
echo ""

# Install ZSH and plugins
pkg_install zsh
pkg_install zsh-syntax-highlighting
pkg_install zsh-autosuggestions
pkg_install zsh-completions

# Create ~/.zshrc (backup existing)
ZSHRC="$HOME/.zshrc"
if [[ -f $ZSHRC ]]; then
  cp "$ZSHRC" "$ZSHRC.bak.$(date +%s)"
  info "Existing .zshrc backed up"
fi

cat > "$ZSHRC" << 'ZSHEOF'
# ---- gnome-arch ZSH Configuration ----

# History
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# Key bindings
bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# ---- Aliases ----
alias ls='eza --icons=auto'
alias ll='eza -l --icons=auto'
alias la='eza -la --icons=auto'
alias lt='eza --tree --icons=auto'
alias cat='bat --theme=base16'
alias cd='z'
alias vi='nvim'
alias vim='nvim'
alias grep='rg'
alias du='dua'
alias top='btop'
alias ..='cd ..'
alias ...='cd ../..'

# ---- Zoxide ----
eval "$(zoxide init zsh)"

# ---- Starship ----
eval "$(starship init zsh)"

# ---- ZSH Plugins ----
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || true
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || true

# ---- Mise ----
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# ---- Editor ----
export EDITOR=nvim
export VISUAL=nvim
ZSHEOF

ok ".zshrc created"

# Set ZSH as default shell
ZSH_PATH=$(type -p zsh)
if [[ -z $ZSH_PATH ]]; then
  warn "ZSH not found, cannot set as default"
elif [[ $SHELL != "$ZSH_PATH" ]]; then
  info "Setting ZSH as default shell..."
  if chsh -s "$ZSH_PATH"; then
    ok "Default shell set to ZSH (will apply after logout)"
  else
    warn "Could not set ZSH as default. Run manually: chsh -s $ZSH_PATH"
  fi
fi

# Create starship config directory
mkdir -p ~/.config
