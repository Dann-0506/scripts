#!/usr/bin/env bash

# Directorios base
DESKTOP_DIR="$HOME/Escritorio"
MATERIAS_DIR="$HOME/Escritorio/Universidad"

# Verificar que el directorio de materias exista
if [ ! -d "$MATERIAS_DIR" ]; then
    echo "Error: El enlace simbólico de materias '$MATERIAS_DIR' no existe." >&2
    exit 1
fi

echo "Iniciando limpieza del Escritorio..."

# Iterar sobre cada archivo en el Escritorio
for file in "$DESKTOP_DIR"/*; do
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")
    
    # Ignorar archivos ocultos o del sistema
    case "$filename" in
        .*) continue ;;
    esac

    # Separar el nombre del archivo usando el guion bajo (_) como delimitador
    IFS='_' read -ra tokens <<< "$filename"
    
    # Se necesitan al menos un nombre y una materia (mínimo 2 tokens: ej. tarea1_admonbd.md)
    num_tokens=${#tokens[@]}
    if [ "$num_tokens" -lt 2 ]; then
        continue
    fi

    # Como el orden es <nombre>_<tipo>_<materia> o <nombre>_<materia>,
    # la materia siempre se encuentra en el ÚLTIMO token (antes de la extensión).
    
    # Limpiamos la extensión del último token por si acaso
    last_index=$((num_tokens - 1))
    raw_materia="${tokens[$last_index]}"
    materia_token=$(echo "${raw_materia%.*}" | tr '[:upper:]' '[:lower:]')
    
    # 1. Buscar la carpeta de materia principal haciendo coincidir el último token
    target_materia_path=""
    for materia_path in "$MATERIAS_DIR"/*/; do
        [ -d "$materia_path" ] || continue
        folder_name=$(basename "$materia_path")
        normalized_folder=$(echo "$folder_name" | tr '[:upper:]' '[:lower:]' | tr -d '_')
        
        if [ "$materia_token" = "$normalized_folder" ]; then
            target_materia_path="$materia_path"
            break
        fi
    done

    # Si no encuentra la materia en el último token, salta el archivo
    [ -n "$target_materia_path" ] || continue

    # 2. Construir la ruta de subcarpetas con los tokens intermedios (desde el índice 1 hasta el penúltimo)
    current_dest="$target_materia_path"
    
    if [ "$num_tokens" -gt 2 ]; then
        # Iteramos desde el primer token intermedio hasta antes de llegar a la materia
        for ((i=1; i<num_tokens - 1; i++)); do
            token="${tokens[$i]}"
            token_lower=$(echo "$token" | tr '[:upper:]' '[:lower:]')
            
            # Buscar si ya existe una subcarpeta con el mismo nombre (tolerante a mayúsculas)
            found_subfolder=""
            if [ -d "$current_dest" ]; then
                for sub in "$current_dest"/*/; do
                    [ -d "$sub" ] || continue
                    sub_name=$(basename "$sub")
                    sub_lower=$(echo "$sub_name" | tr '[:upper:]' '[:lower:]')
                    
                    if [ "$sub_lower" = "$token_lower" ]; then
                        found_subfolder="$sub_name"
                        break
                    fi
                done
            fi
            
            # Reutilizar nombre original si existe, o usar el token si se crea al vuelo
            if [ -n "$found_subfolder" ]; then
                current_dest="$current_dest/$found_subfolder"
            else
                current_dest="$current_dest/$token"
            fi
        done
    fi

    # Crear la ruta de subcarpetas dinámicamente si no existía
    mkdir -p "$current_dest"

    # NUEVO: Generar el nombre limpio eliminando los postfijos (tipo y materia)
    # El primer token es siempre el nombre base (ej. "tarea1")
    base_name="${tokens[0]}"
    
    # Extraer la extensión original del archivo completo
    ext="${filename##*.}"
    
    # Nombre final limpio con el que se guardará en su destino
    clean_filename="${base_name}.${ext}"
    target="$current_dest/$clean_filename"

    # Prevenir sobrescritura si ya existe un archivo idéntico en el destino
    if [ -e "$target" ]; then
        timestamp=$(date +%s)
        target="$current_dest/${base_name}_${timestamp}.${ext}"
        clean_filename="${base_name}_${timestamp}.${ext}"
    fi

    echo "  ➔ Archivando: $filename ➔ $(basename "$target_materia_path")/$(basename "$current_dest")/$clean_filename"
    mv "$file" "$target"
done

echo "Limpieza completada con éxito"