#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/amsh.conf"
TTL_DIR="/tmp/amsh_ttl"
mkdir -p "$TTL_DIR"

get_config_for_path() {
    local target_path=$(realpath -m "$1")
    while read -r device mpoint fstype ttl; do
        if [[ "$target_path" == "$mpoint"* ]]; then
            echo "$device $mpoint $fstype $ttl"
            return 0
        fi
    done < "$CONFIG_FILE"
    return 1
}

smart_mount() {
    local path="$1"
    local config_entry=$(get_config_for_path "$path")

    if [[ -n "$config_entry" ]]; then
        read -r device mpoint fstype ttl <<< "$config_entry"

        if ! mountpoint -q "$mpoint"; then
            echo "[SYSTEM] Montare automată: $mpoint"
            
            send_notification "AMSH: Montare automată" "Dispozitivul $device a fost montat în $mpoint" "drive-harddisk"
            
            sudo mount -t "$fstype" "$device" "$mpoint"
        fi

        touch "$TTL_DIR/${mpoint//\//_}.last_access"
    fi
}


check_and_umount_expired() {
    if [[ ! -f "$CONFIG_FILE" ]]; then return; fi

    while read -r device mpoint fstype ttl; do
        local ttl_file="$TTL_DIR/${mpoint//\//_}.last_access"
        
        if [[ -f "$ttl_file" ]] && mountpoint -q "$mpoint"; then
            local last_access=$(stat -c %Y "$ttl_file")
            local current_time=$(date +%s)
            local diff=$(( (current_time - last_access) / 60 ))

            # expirare timp & procese active 
            if [ "$diff" -ge "$ttl" ]; then
                if ! fuser -s "$mpoint" 2>/dev/null; then
                    echo "[SYSTEM] TTL expirat. Demontare: $mpoint"
                    
                    send_notification "AMSH: Demontare automată" "TTL expirat pentru $mpoint. Dispozitivul a fost demontat." "drive-removable-media"
                    
                    sudo umount "$mpoint"
                    rm "$ttl_file"
                fi
            fi
        fi
    done < "$CONFIG_FILE"
}


cleanup_all_mounts() {
    cd "$HOME" 2>/dev/null

    echo -e "\n[SYSTEM] Se inițializează curățenia la ieșire (Unmount All)..."

    if [[ ! -f "$CONFIG_FILE" ]]; then return; fi

    while read -r device mpoint fstype ttl; do
        [[ "$device" == \#* ]] || [[ -z "$device" ]] && continue
        
        local ttl_file="$TTL_DIR/${mpoint//\//_}.last_access"

        if mountpoint -q "$mpoint"; then
            echo "[SYSTEM] Încercare demontare la exit: $mpoint"
            
            if sudo umount "$mpoint"; then
                if [[ -f "$ttl_file" ]]; then
                    rm -f "$ttl_file"
                fi
                send_notification "AMSH: Cleanup" "S-a demontat $mpoint." "drive-removable-media"
            else
                echo -e "\033[1;31m[ATENȚIE]\033[0m Nu s-a putut demonta $mpoint (posibil utilizat de alt proces)."
            fi
        else
            if [[ -f "$ttl_file" ]]; then
                rm -f "$ttl_file"
            fi
        fi

    done < "$CONFIG_FILE"
}


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
            status_color="\033[1;32mMONTAT\033[0m"  
            
            local ttl_file="$TTL_DIR/${mpoint//\//_}.last_access"
            local time_info="Infinit (Activ)"

            if [[ -f "$ttl_file" ]]; then
                local last_access=$(stat -c %Y "$ttl_file")
                local current_time=$(date +%s)
                

                local elapsed_sec=$(( current_time - last_access ))
                local ttl_sec_total=$(( ttl * 60 ))
                local remaining_sec=$(( ttl_sec_total - elapsed_sec ))

                if [[ $remaining_sec -lt 0 ]]; then remaining_sec=0; fi
                
                if [[ $remaining_sec -lt 60 ]]; then
                    time_info="\033[1;31m${remaining_sec}s\033[0m (din ${ttl}m)"
                else
                    time_info="${remaining_sec}s"
                fi
            else
                time_info="N/A"
            fi

            printf "%-25s %-15s %b     %b\n" "$mpoint" "$device" "$status_color" "$time_info"
        else
            status_color="\033[1;31mDEMONTAT\033[0m"
            printf "%-25s %-15s %b   %s\n" "$mpoint" "$device" "$status_color" "-"
        fi

    done < "$CONFIG_FILE"
    echo "-----------------------------------------------------------------"
}

send_notification() {
    local title="$1"
    local message="$2"
    local icon="$3"
    local real_user="${SUDO_USER:-$USER}"
    local user_id=$(id -u "$real_user")

    sudo -u "$real_user" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$user_id"/bus \
    notify-send "$title" "$message" --icon="$icon"
}


