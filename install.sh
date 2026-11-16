#!/usr/bin/env bash
set -e

echo "Instalando el ecosistema completo de automatización..."

# Crear directorios
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"

# Copiar scripts de binarios
cp bin/watch_downloads.sh "$HOME/.local/bin/watch_downloads.sh"
cp bin/clean_desktop.sh "$HOME/.local/bin/clean_desktop.sh"
chmod +x "$HOME/.local/bin/"*.sh

# Copiar servicios de systemd
cp systemd/watch-downloads.service "$HOME/.config/systemd/user/"
cp systemd/clean-desktop.service "$HOME/.config/systemd/user/"
cp systemd/clean-desktop.timer "$HOME/.config/systemd/user/"

# Recargar y habilitar servicios
systemctl --user daemon-reload
systemctl --user enable --now watch-downloads.service
systemctl --user enable --now clean-desktop.timer

echo "Instalación y activación completadas"