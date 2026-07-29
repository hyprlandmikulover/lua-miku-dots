#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/lua-miku-dots"
BACKUP="$HOME/.config/miku-dots-backup-$(date +%Y%m%d_%H%M%S)"

color() { tput setaf "$1"; tput bold; }
reset() { tput sgr0; }
info()  { echo "$(color 2)::$(reset) $*"; }
warn()  { echo "$(color 3)!!$(reset) $*"; }
err()   { echo "$(color 1)!!$(reset) $*"; }

backup() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        local bak="$BACKUP${target%/*}"
        mkdir -p "$bak"
        mv "$target" "$bak/"
        warn "backed up $target → $bak/"
    fi
}

install_link() {
    local src="$1" target="$2"
    mkdir -p "$(dirname "$target")"
    backup "$target"
    ln -sf "$src" "$target"
    info "linked $src → $target"
}

install_dir() {
    local src="$1" target="$2"
    backup "$target"
    ln -sfn "$src" "$target"
    info "linked dir $src → $target"
}

main() {
    echo "$(color 6)󰋗 Miku Hyprland Dotfiles Installer$(reset)"
    echo

    [ -d "$DOTFILES" ] || { err "$DOTFILES not found"; exit 1; }

    install_link "$DOTFILES/hypr/hyprland.lua"           "$HOME/.config/hypr/hyprland.lua"
    install_link "$DOTFILES/kitty/kitty.conf"             "$HOME/.config/kitty/kitty.conf"
    install_link "$DOTFILES/rofi/launcher.rasi"           "$HOME/.config/rofi/launcher.rasi"
    install_link "$DOTFILES/rofi/bg.png"                  "$HOME/.config/rofi/bg.png"
    install_link "$DOTFILES/waybar/config.jsonc"          "$HOME/.config/waybar/config.jsonc"
    install_link "$DOTFILES/waybar/style.css"             "$HOME/.config/waybar/style.css"
    install_link "$DOTFILES/fastfetch/config.jsonc"       "$HOME/.config/fastfetch/config.jsonc"
    install_link "$DOTFILES/xdg-desktop-portal/hyprland.lua" "$HOME/.config/xdg-desktop-portal/hyprland.lua"

    install_dir "$DOTFILES/4configs" "$HOME/4configs"
    install_dir "$DOTFILES/Wallpapers" "$HOME/Wallpapers"

    echo
    info "done! restart Hyprland or run 'hyprctl reload' to apply."
}

main "$@"
