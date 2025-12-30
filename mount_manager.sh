#!/bin/bash

# Configurare fișiere și foldere de lucru
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/amsh.conf"
TTL_DIR="/tmp/amsh_ttl"
mkdir -p "$TTL_DIR"

# afisare status a fiecarui mountpoint (in secunde)
show_mount_status() {
    echo "-----------------------------------------------------------------"
    printf "%-25s %-15s %-10s %s\n" "MOUNTPOINT" "DEVICE" "STARE" "TIMP RAMAS"
    echo "-----------------------------------------------------------------"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Eroare: Nu găsesc fișierul de configurare."
        return
    fi

    while read -r device mpoint fstype ttl; do
        [[ "$device" == \#* ]] || [[ -z "$device" ]] && continue

        if mountpoint -q "$mpoint"; then
            status_color="\033[1;32mMONTAT\033[0m"   # Verde
            
            local ttl_file="$TTL_DIR/${mpoint//\//_}.last_access"
            local time_info="Infinit (Activ)"

            if [[ -f "$ttl_file" ]]; then
                local last_access=$(stat -c %Y "$ttl_file")
                local current_time=$(date +%s)
                
                # --- MODIFICAREA ESTE AICI ---
                # 1. Calculăm cât timp a trecut (în secunde)
                local elapsed_sec=$(( current_time - last_access ))
                
                # 2. Convertim TTL-ul din config (minute) în secunde
                local ttl_sec_total=$(( ttl * 60 ))
                
                # 3. Calculăm cât a mai rămas
                local remaining_sec=$(( ttl_sec_total - elapsed_sec ))

                # Să nu afișăm numere negative
                if [[ $remaining_sec -lt 0 ]]; then remaining_sec=0; fi
                
                # Colorare: Roșu dacă mai sunt sub 60 de secunde
                if [[ $remaining_sec -lt 60 ]]; then
                    time_info="\033[1;31m${remaining_sec}s\033[0m (din ${ttl}m)"
                else
                    time_info="${remaining_sec}s"
                fi
            else
                time_info="N/A"
            fi

            printf "%-25s %-15s %b %b\n" "$mpoint" "$device" "$status_color" "$time_info"
        else
            status_color="\033[1;31mDEMONTAT\033[0m"
            printf "%-25s %-15s %b %s\n" "$mpoint" "$device" "$status_color" "-"
        fi

    done < "$CONFIG_FILE"
    echo "-----------------------------------------------------------------"
}


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

# Funcție helper pentru a trimite notificări către utilizatorul curent fără erori de D-Bus
send_notification() {
    local title="$1"
    local message="$2"
    local icon="$3"
    local real_user="${SUDO_USER:-$USER}"
    local user_id=$(id -u "$real_user")

    # Execută notify-send ca utilizator logat, indicând adresa corectă a bus-ului de sesiune
    sudo -u "$real_user" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$user_id"/bus \
    notify-send "$title" "$message" --icon="$icon"
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
            
            # Notificare Desktop pentru montare
            send_notification "AMSH: Montare automată" "Dispozitivul $device a fost montat în $mpoint" "drive-harddisk"
            
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
                    
                    # Notificare Desktop pentru demontare
                    send_notification "AMSH: Demontare automată" "TTL expirat pentru $mpoint. Dispozitivul a fost demontat." "drive-removable-media"
                    
                    sudo umount "$mpoint"
                    rm "$ttl_file"
                fi
            fi
        fi
    done < "$CONFIG_FILE"
}
