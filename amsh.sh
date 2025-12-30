#!/bin/bash

# import la functii pt mount
source ./mount_manager.sh

echo "Bun venit în Automounter Shell!"


process_command() {
    local cmd_line="$1"
    
    # Sparge stringul într-un array
    read -ra args <<< "$cmd_line"
    local command="${args[0]}"

    # --- comanda CD ---
    if [[ "$command" == "cd" ]]; then
        local target_dir="${args[1]}"
        
        # if not argument then $HOME
        if [[ -z "$target_dir" ]]; then
            target_dir="$HOME"
        fi

        # cale abs (rezolva ../ si ./)
        local abs_path=$(realpath -m "$target_dir")

        # de facut partea verific
        smart_mount "$abs_path"
        
        builtin cd "$target_dir"
        return
    fi

    # --- comenzi externe (ls, cp, cat, etc) ---
    
    # verificare fiecare arg
    for arg in "${args[@]}"; do
        # seamana cu un path sau nu pentru pharsing
        if [[ "$arg" == /* ]] || [[ "$arg" == ./* ]] || [[ "$arg" == ../* ]]; then
             local abs_arg=$(realpath -m "$arg")
             
             # din nou logica de introudus
             smart_mount "$abs_arg"
        fi
    done

    # execute
    sh -c "$cmd_line"
}

# loop principal
while true; do
    check_and_umount_expired
    echo -n "amsh> "
    read -r linie_comanda

    # linie goala
    if [[ -z "$linie_comanda" ]]; then
        continue
    fi

    # exit 
    if [[ "$linie_comanda" == "exit" ]]; then
        echo "La revedere!"
        break
    fi

    # procesarea comenzii
    process_command "$linie_comanda"
done
