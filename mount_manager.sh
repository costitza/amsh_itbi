#!/bin/bash

# Configurare fișiere și foldere de lucru
CONFIG_FILE="amsh.conf"
TTL_DIR="/tmp/amsh_ttl"
mkdir -p "$TTL_DIR"

# Caută dacă o cale aparține unui mountpoint din config
get_config_for_path() {
    local target_path=$(realpath -m "$1")
    while read -r device mpoint fstype ttl; do
        # Verifică dacă prefixul căii este un mountpoint cunoscut
        if [[ "$target_path" == "$mpoint"* ]]; then
            echo "$device $mpoint $fstype $ttl"
            return 0
        fi
    done < "$CONFIG_FILE"
    return 1
}

# Funcția principală de montare automată
smart_mount() {
    local path="$1"
    local config_entry=$(get_config_for_path "$path")

    if [[ -n "$config_entry" ]]; then
        read -r device mpoint fstype ttl <<< "$config_entry"

        # Montează dacă nu este deja instalat
        if ! mountpoint -q "$mpoint"; then
            echo "[SYSTEM] Montare automată: $mpoint"
            sudo mount -t "$fstype" "$device" "$mpoint"
        fi

        # Actualizează timpul ultimului acces pentru TTL
        touch "$TTL_DIR/${mpoint//\//_}.last_access"
    fi
}

# Verifică expirarea timpului și demontează dacă e liber
check_and_umount_expired() {
    if [[ ! -f "$CONFIG_FILE" ]]; then return; fi

    while read -r device mpoint fstype ttl; do
        local ttl_file="$TTL_DIR/${mpoint//\//_}.last_access"
        
        # Verifică dacă mountpoint-ul este activ
        if [[ -f "$ttl_file" ]] && mountpoint -q "$mpoint"; then
            local last_access=$(stat -c %Y "$ttl_file")
            local current_time=$(date +%s)
            local diff=$(( (current_time - last_access) / 60 ))

            # Dacă a trecut timpul (TTL) și nu sunt procese active
            if [ "$diff" -ge "$ttl" ]; then
                if ! fuser -s "$mpoint" 2>/dev/null; then
                    echo "[SYSTEM] TTL expirat. Demontare: $mpoint"
                    sudo umount "$mpoint"
                    rm "$ttl_file"
                fi
            fi
        fi
    done < "$CONFIG_FILE"
}
