#!/bin/bash

# import la functii pt mount
source ./mount_manager.sh
source ./style.sh

# fisier de history
HISTORY_FILE="$HOME/.amsh_history"

handle_sigint() {
    echo "" # Trece la linie nouă ca să nu scrii peste prompt
    # Nu facem nimic altceva -> Shell-ul continuă să ruleze
}

trap handle_sigint SIGINT

process_command() {
    local cmd_line="$1"
    
    # Sparge stringul într-un array
    read -ra args <<< "$cmd_line"
    local command="${args[0]}"
    
    # --- comanda history custom ---
    if [[ "$command" == "history" ]]; then
        # "-c" pentru stergere history
        if [[ "${args[1]}" == "-c" ]]; then
            > "$HISTORY_FILE"  # goleste
            echo "Istoric sters."
        else
            # Afișează istoricul numerotat
            if [[ -f "$HISTORY_FILE" ]]; then
                cat -n "$HISTORY_FILE"
            fi
        fi
        return # nu trimiti "history" la sh -c
    fi

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

# banner de inceput
show_welcome_banner


# loop principal
while true; do
    check_and_umount_expired
    show_prompt

    
    
    
    read -r linie_comanda
    exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        # 130 -> ctrl-c
        if [ $exit_code -eq 130 ]; then
            continue  # reluare bucla
        fi
        
        # alte erori
        echo "La revedere."
        break
    fi
    

    # linie goala
    if [[ -z "$linie_comanda" ]] && continue ; then
        continue
    fi
    
    # salvam in history file
    if [[ "$linie_comanda" != "exit" &&  "$linie_comanda" != "history" ]]; then
        echo "$linie_comanda" >> "$HISTORY_FILE"
    fi

    # exit 
    if [[ "$linie_comanda" == "exit" ]]; then
        echo "La revedere!"
        break
    fi

    # procesarea comenzii
    process_command "$linie_comanda"
done
