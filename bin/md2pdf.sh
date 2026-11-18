#!/usr/bin/env bash

# Verificar que los comandos reales existan
for cmd in pandoc xelatex; do
    if ! command -v "$cmd" &> /dev/null; then
        command -v zenity &> /dev/null && zenity --error --text="Error: '$cmd' no está instalado."
        echo "Error: '$cmd' no está instalado." >&2
        exit 1
    fi
done

# Obtener el archivo desde Nautilus o desde el primer argumento en terminal
if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ]; then
    ARCHIVO=$(echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
elif [ -n "$1" ]; then
    ARCHIVO="$1"
else
    echo "Uso: md2pdf archivo.md [nombre_salida.pdf]"
    exit 1
fi

ARCHIVO=$(realpath "$ARCHIVO")
DIR_DESTINO=$(dirname "$ARCHIVO")
NOMBRE_BASE=$(basename "$ARCHIVO" .md)

# Pedir nombre personalizado si se ejecuta desde Nautilus, o usar argumento $2 en terminal
if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ] && command -v zenity &> /dev/null; then
    NOMBRE_SALIDA=$(zenity --entry --title="Exportar a PDF" --text="Nombre del archivo PDF:" --entry-text="${NOMBRE_BASE}.pdf")
    [ -z "$NOMBRE_SALIDA" ] && exit 0
elif [ -n "$2" ]; then
    NOMBRE_SALIDA="$2"
else
    NOMBRE_SALIDA="${NOMBRE_BASE}.pdf"
fi

# Asegurar extensión .pdf
NOMBRE_SALIDA="${NOMBRE_SALIDA%.pdf}.pdf"
OUTPUT="$DIR_DESTINO/$NOMBRE_SALIDA"

# Crear directorio temporal y limpiar al terminar
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Convertir y compilar dentro del directorio temporal
pandoc "$ARCHIVO" -s -o "$TEMP_DIR/doc.tex"
if xelatex -interaction=nonstopmode -output-directory="$TEMP_DIR" "$TEMP_DIR/doc.tex" > /dev/null; then
    mv "$TEMP_DIR/doc.pdf" "$OUTPUT"
    command -v notify-send &> /dev/null && notify-send "PDF Generado" "$NOMBRE_SALIDA"
    echo "PDF generado: $OUTPUT"
else
    command -v zenity &> /dev/null && zenity --error --text="Error al compilar el archivo LaTeX."
    echo "Error al compilar con xelatex." >&2
    exit 1
fi
