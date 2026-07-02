# gnome-arch

Portabilidade do [Omarchy](https://omarchy.org) para **Arch Linux + GNOME**, com foco em desenvolvimento.

Remove toda a dependência do Hyprland e substitui por equivalentes GNOME, mantendo a curadoria de pacotes, temas e configurações para programadores.

## Instalação

### Pré-requisitos

- Arch Linux instalado (qualquer derivada baseada em Arch)
- Acesso `sudo` configurado
- Conexão com internet

### Instalação interativa

```bash
git clone https://github.com/devigor/omarchy.git ~/.local/share/omarchy
cd ~/.local/share/omarchy
git checkout port/arch-gnome
source gnome-install.sh
```

O instalador guiará por 7 fases:

1. **Terminal** — escolha entre gnome-terminal, alacritty, kitty ou ghostty
2. **Pacotes** — seleção interativa dos pacotes opcionais
3. **Fontes** — JetBrains Mono Nerd Font como padrão
4. **Shell** — ZSH com syntax highlighting, autosuggestions, eza, zoxide e starship
5. **Tema** — seleção de tema aplicado ao terminal + starship
6. **Config** — git, docker, mise, preferências GNOME
7. **Extensões** — AppIndicator, Dash to Dock, Clipboard Indicator

### Instalação não-interativa

Defina as variáveis de ambiente antes de executar:

```bash
export GNOME_ARCH_NONINTERACTIVE=true
export GNOME_ARCH_TERMINAL=kitty
export GNOME_ARCH_THEME=catppuccin
export GNOME_ARCH_PACKAGES="ALL"
export GNOME_ARCH_GIT_NAME="Seu Nome"
export GNOME_ARCH_GIT_EMAIL="email@exemplo.com"
source gnome-install.sh
```

### Ajuda

```bash
source gnome-install.sh --help
```

## O que é instalado

### Pacotes padrão (sempre instalados)

| Categoria | Pacotes |
|---|---|
| Containers | docker, docker-compose |
| Editor | nvim |
| Runtime | mise |
| Terminal | eza, zoxide, starship, fzf |
| Dev tools | ripgrep, fd, bat, jq, tldr, lazygit, lazydocker, tmux, github-cli, wl-clipboard, tree-sitter-cli |
| Toolchain | rust, unzip, git, base-devel |
| Sistema | fontconfig, less, man-db |

### Pacotes opcionais (usuário escolhe)

`1password-beta`, `1password-cli`, `avahi`, `brightnessctl`, `btop`, `chromium`, `clang`, `dosfstools`, `dua-cli`, `exfatprogs`, `fastfetch`, `ffmpegthumbnailer`, `go`, `grim`, `gum`, `imagemagick`, `imv`, `inxi`, `kernel-modules-hook`, `libsecret`, `libyaml`, `llvm`, `localsend`, `mariadb-libs`, `mpv`, `mpv-mpris`, `nautilus-python`, `nodejs`, `npm`, `nss-mdns`, `pamixer`, `playerctl`, `plocate`, `postgresql-libs`, `power-profiles-daemon`, `python`, `python-gobject`, `qt5-wayland`, `ruby`, `satty`, `slurp`, `socat`, `sqlite`, `ufw`, `ufw-docker`, `xmlstarlet`

### Temas disponíveis

6 temas curados: catppuccin, catppuccin-latte, tokyo-night, gruvbox, nord, rose-pine

### Extensões GNOME

- AppIndicator (bandeja do sistema)
- Dash to Dock (dock inferior customizável)
- Clipboard Indicator (histórico de área de transferência)

## Estrutura do projeto

```
gnome-install/
├── install.sh          - Ponto de partida (orquestra as 7 fases)
├── helpers.sh          - Funções compartilhadas
├── packages.txt        - Lista de pacotes opcionais
├── packages.sh         - Seleção e instalação de pacotes
├── terminal.sh         - Escolha e configuração do terminal
├── fonts.sh            - Instalação de fontes
├── shell.sh            - Configuração do ZSH
├── theme.sh            - Seleção e aplicação de tema
├── config.sh           - Configurações do sistema
├── extensions.sh       - Instalação de extensões GNOME
├── templates/          - Templates de tema para cada terminal
└── themes/             - Cores dos temas curados
gnome-install.sh        - Entry point
```

## Diferenças do Omarchy original

| Omarchy | gnome-arch |
|---|---|
| Hyprland | GNOME |
| Waybar | Dash to Dock |
| Mako | GNOME notificações nativas |
| SDDM | GDM |
| Swaybg | GNOME wallpapers nativos |
| foot | gnome-terminal / alacritty / kitty / ghostty |
| 155+ pacotes base | 22 padrão + 46 opcionais |
| 21 temas | 6 temas curados |
| Instalação com perfil único | Interativa ou não-interativa |
