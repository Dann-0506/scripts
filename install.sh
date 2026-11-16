#!/usr/bin/env bash

set -e

echo "Iniciando la instalación del ecosistema de automatización..."

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"

echo "Copiando script de monitoreo a ~/.local/bin/..."
cp bin/watch_downloads.sh "$HOME/.local/bin/watch_downloads.sh"
chmod +x "$HOME/.local/bin/watch_downloads.sh"

echo "Configurando el servicio de systemd..."
cp systemd/watch-downloads.service "$HOME/.config/systemd/user/watch-downloads.service"

echo "Activando el servicio en systemd..."
systemctl --user daemon-reload
systemctl --user enable watch-downloads.service
systemctl --user restart watch-downloads.service

echo "Instalacion completada"