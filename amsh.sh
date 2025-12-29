#!/bin/bash

# Aici vei include (source) funcțiile colegului B mai târziu
# source ./mount_manager.sh

echo "Bun venit în Automounter Shell!"


# Mock function (O ștergi când e gata colegul B)
ensure_mount_exists() {
    echo "[DEBUG] Verific daca trebuie montat ceva pentru calea: $1"
    # Aici el va pune logica de mount. 
    # Deocamdată doar ne prefacem că merge.
}


process_command() {
    local cmd_line="$1"
    
    # Sparge stringul într-un array
    read -ra args <<< "$cmd_line"
    local command="${args[0]}"

    # --- CAZUL 1: Este comanda CD ---
    if [[ "$command" == "cd" ]]; then
        local target_dir="${args[1]}"
        
        # Dacă nu e dat argument, mergi în HOME
        if [[ -z "$target_dir" ]]; then
            target_dir="$HOME"
        fi

        # Obține calea absolută (rezolvă ../ și ./)
        # "2>/dev/null" ascunde erorile dacă calea nu există încă (deși ar trebui gestionat)
        local abs_path=$(realpath -m "$target_dir")

        # AICI APELEZI LOGICA COLEGULUI B
        ensure_mount_exists "$abs_path"
        
        # Schimbă directorul
        builtin cd "$target_dir"
        return
    fi

    # --- CAZUL 2: Comenzi Externe (ls, cp, cat, etc) ---
    
    # Verificăm fiecare argument să vedem dacă e o cale care necesită montare
    for arg in "${args[@]}"; do
        # Verificăm dacă argumentul arată a cale (începe cu / sau . sau ..)
        if [[ "$arg" == /* ]] || [[ "$arg" == ./* ]] || [[ "$arg" == ../* ]]; then
             local abs_arg=$(realpath -m "$arg")
             
             # AICI APELEZI LOGICA COLEGULUI B PENTRU FIECARE ARGUMENT
             # ensure_mount_exists "$abs_arg"
        fi
    done

    # Execută comanda
    sh -c "$cmd_line"
}

# loop principal
while true; do
    echo -n "amsh> "
    read -r linie_comanda

    # 1. Verificăm dacă linia e goală
    if [[ -z "$linie_comanda" ]]; then
        continue
    fi

    # 2. Ieșirea din shell
    if [[ "$linie_comanda" == "exit" ]]; then
        echo "La revedere!"
        break
    fi

    # Aici urmează logica de procesare (vezi pașii 2 și 3)
    process_command "$linie_comanda"
done
