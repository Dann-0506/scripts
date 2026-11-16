#!/usr/bin/env bash

SOURCE_DIR="$HOME/Descargas"
TARGET_DIR="$HOME/Escritorio"

if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotify-tools no está instalado. Instálalo con: sudo apt install inotify-tools" >&2
    exit 1
fi

inotifywait -m -e close_write --format '%f' "$SOURCE_DIR" | while read -r filename; do

    case "$filename" in
        *.crdownload|*.part|*.tmp|*.swp|*.opdownload)
            continue
            ;;
    esac

    target="$TARGET_DIR/$filename"

    if [ -e "$target" ]; then
        ext="${filename##*.}"
        name="${filename%.*}"
        timestamp=$(date +%s)
        target="$TARGET_DIR/${name}_${timestamp}.${ext}"
    fi

    if [ -f "$SOURCE_DIR/$filename" ]; then
        mv "$SOURCE_DIR/$filename" "$target"
    fi
done