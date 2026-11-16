#!/usr/bin/env bash

SOURCE_DIR="$HOME/Descargas"
DESKTOP_DIR="$HOME/Escritorio"
IMAGES_DIR="$HOME/Imágenes"

for cmd in inotifywait fuser; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' no está instalado. Instálalo con: sudo apt install inotify-tools psmisc" >&2
        exit 1
    fi
done

mkdir -p "$DESKTOP_DIR" "$IMAGES_DIR"

inotifywait -m -e close_write -e moved_to --format '%f' "$SOURCE_DIR" | while read -r filename; do

    case "$filename" in
        .*|*.crdownload|*.part|*.tmp|*.swp|*.opdownload|*.download|*.aria2)
            continue
            ;;
    esac

    source_file="$SOURCE_DIR/$filename"

    sleep 2

    while fuser "$source_file" >/dev/null 2>&1; do
        sleep 5
    done

    if [ ! -f "$source_file" ]; then
        continue
    fi

    ext="${filename##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    filename_lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')

    case "$ext_lower" in
        jpg|jpeg|png|gif|webp|svg|bmp|tiff|ico|avif)
            case "$filename_lower" in
                wp_*)
                    dest_dir="$IMAGES_DIR/Wallpapers"
                    ;;
                itv_*)
                    dest_dir="$IMAGES_DIR/TecNM"
                    ;;
                *)
                    dest_dir="$IMAGES_DIR"
                    ;;
            esac
            ;;
        *)
            dest_dir="$DESKTOP_DIR"
            ;;
    esac

    mkdir -p "$dest_dir"

    target="$dest_dir/$filename"

    if [ -e "$target" ]; then
        name="${filename%.*}"
        timestamp=$(date +%s)
        target="$dest_dir/${name}_${timestamp}.${ext}"
    fi

    mv "$source_file" "$target"

done