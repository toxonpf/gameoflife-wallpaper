#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
wallpaper_target="${XDG_DATA_HOME:-${HOME}/.local/share}/plasma/wallpapers"
plasmoid_target="${XDG_DATA_HOME:-${HOME}/.local/share}/plasma/plasmoids"

mkdir -p "${wallpaper_target}" "${plasmoid_target}"
cp -a "${project_dir}/plasma-wallpaper/org.kde.plasma.gameoflife" "${wallpaper_target}/"
cp -a "${project_dir}/plasmoid/org.kde.desktopcontainment" "${plasmoid_target}/"

if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet plasma-plasmashell.service; then
    systemctl --user restart plasma-plasmashell.service
else
    printf '%s\n' 'Пакеты установлены. Перезапустите plasmashell вручную, чтобы применить изменения.'
fi

printf 'Установлено из: %s\n' "${project_dir}"
