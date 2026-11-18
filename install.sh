#!/usr/bin/env bash
set -e

echo "Verificando dependencias necesarias..."
DEPENDENCIAS=("inotifywait" "fuser" "pandoc" "xelatex" "zenity")
FALTANTES=()

for cmd in "${DEPENDENCIAS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        FALTANTES+=("$cmd")
    fi
done

if [ ${#FALTANTES[@]} -ne 0 ]; then
    echo "Error: Faltan las siguientes herramientas: ${FALTANTES[*]}" >&2
    exit 1
fi
echo "Dependencias verificadas."
echo ""

echo "Instalando scripts de automatización..."

# Crear directorios
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$HOME/.local/share/nautilus/scripts"
mkdir -p "$HOME/.local/share/pandoc/templates"
echo ""

# Reenvio de descargas a escritorio
echo "Servicio de reenvio de descargas a escritorio"

cp bin/watch_downloads.sh "$HOME/.local/bin/watch_downloads.sh"
chmod +x "$HOME/.local/bin/watch_downloads.sh"
echo "Binario copiado"

cp systemd/watch-downloads.service "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now watch-downloads.service
echo "Servicio habilitado"
echo ""

# Cleaner de escritorio
echo "Servicio de organizacion de escritorio"
cp bin/clean_desktop.sh "$HOME/.local/bin/clean_desktop.sh"
chmod +x "$HOME/.local/bin/clean_desktop.sh"
echo "Binario copiado"

cp systemd/clean-desktop.service "$HOME/.config/systemd/user/"
cp systemd/clean-desktop.timer "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now clean-desktop.timer
echo "Servicio habilitado"
echo ""

# md2pdf
echo "Script de nautilus y terminal para convertir markdown a pdf con TeXLive"
cp templates/plantilla_itver.tex "$HOME/.local/share/pandoc/templates/"
cp bin/md2pdf.sh "$HOME/.local/bin/md2pdf"
chmod +x "$HOME/.local/bin/md2pdf"
ln -sf "$HOME/.local/bin/md2pdf" "$HOME/.local/share/nautilus/scripts/Convertir a PDF"
echo "Script instalado y vinculado"
echo ""

echo "Instalación y activación completadas"
