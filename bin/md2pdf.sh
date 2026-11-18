#!/usr/bin/env bash

for cmd in pandoc xelatex; do
    if ! command -v "$cmd" &> /dev/null; then
        command -v zenity &> /dev/null && zenity --error --text="Error: '$cmd' no está instalado."
        echo "Error: '$cmd' no está instalado." >&2
        exit 1
    fi
done

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

if [ -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" ] && command -v zenity &> /dev/null; then
    NOMBRE_SALIDA=$(zenity --entry --title="Exportar a PDF" --text="Nombre del archivo PDF:" --entry-text="${NOMBRE_BASE}.pdf")
    [ -z "$NOMBRE_SALIDA" ] && exit 0
elif [ -n "$2" ]; then
    NOMBRE_SALIDA="$2"
else
    NOMBRE_SALIDA="${NOMBRE_BASE}.pdf"
fi

NOMBRE_SALIDA="${NOMBRE_SALIDA%.pdf}.pdf"
OUTPUT="$DIR_DESTINO/$NOMBRE_SALIDA"

PLANTILLA="$HOME/.local/share/pandoc/templates/plantilla_itver.tex"
RECURSOS_DIR="$HOME/Escritorio/Imagenes/TecNM"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

if [ -f "$PLANTILLA" ]; then
    pandoc "$ARCHIVO" -s \
        --template="$PLANTILLA" \
        -V recursos="$RECURSOS_DIR" \
        --resource-path="$DIR_DESTINO:$RECURSOS_DIR" \
        -o "$TEMP_DIR/doc.tex"
else
    pandoc "$ARCHIVO" -s --resource-path="$DIR_DESTINO:$RECURSOS_DIR" -o "$TEMP_DIR/doc.tex"
fi

# Permitir que XeLaTeX encuentre imágenes en la carpeta del .md y en TecNM
export TEXINPUTS="$DIR_DESTINO:$RECURSOS_DIR:"

xelatex -interaction=nonstopmode -output-directory="$TEMP_DIR" "$TEMP_DIR/doc.tex" > /dev/null

if xelatex -interaction=nonstopmode -output-directory="$TEMP_DIR" "$TEMP_DIR/doc.tex" > /dev/null; then
    mv "$TEMP_DIR/doc.pdf" "$OUTPUT"
    echo "PDF generado: $OUTPUT"
else
    command -v zenity &> /dev/null && zenity --error --text="Error al compilar el archivo LaTeX."
    echo "Error al compilar con xelatex." >&2
    exit 1
fi
