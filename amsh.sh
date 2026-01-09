#!/bin/bash

# import la functii pt mount
source ./mount_manager.sh
source ./style.sh

# fisier de history
HISTORY_FILE="$HOME/.amsh_history"

handle_sigint() {
    echo "" # linie noua in loc sa iasa pt ctrl-c
}

trap handle_sigint SIGINT

process_command() {
    local cmd_line="$1"
    
    # Sparge stringul într-un array
    read -ra args <<< "$cmd_line"
    local command="${args[0]}"
    
    if [[ "$command" == "status" ]]; then
    	show_mount_status
    	return
    fi
    
    if [[ "$command" == "help" ]]; then
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYAN}║${GREEN}               COMENZI DISPONIBILE (HELP)                 ${CYAN}║${RESET}"
        echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${RESET}"

        printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN} ║${RESET}\n" "cd <cale>" "Navigare & Montare automată"
        printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}  ║${RESET}\n" "status" "Vezi timpul rămas (TTL) și starea"
        printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}   ║${RESET}\n" "locate <nume>" "Caută fișier în toate discurile"
        printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN} ║${RESET}\n" "history [-c]" "Vezi/Șterge istoricul comenzilor"
        printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}  ║${RESET}\n" "exit" "Cleanup (unmount all) și Ieșire"
        printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}  ║${RESET}\n" "help" "Afișează acest meniu"
        
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        return
    fi
    
    if [[ "$command" == "locate" ]]; then
        local search_term="${args[1]}"
        
        if [[ -z "$search_term" ]]; then
            echo "Utilizare: locate <nume_fisier>"
            return
        fi

        while read -r device mpoint fstype ttl; do
            [[ "$device" == \#* ]] && continue

            if mountpoint -q "$mpoint"; then
                local results=$(find "$mpoint" -type f -iname "*$search_term*" 2>/dev/null)
                
                if [[ -n "$results" ]]; then
                    echo "$results"
                fi
            fi
        done < "$CONFIG_FILE"
        return
    fi
    
    # --- comanda history custom ---
    if [[ "$command" == "history" ]]; then
        # sterge history -c
        if [[ "${args[1]}" == "-c" ]]; then
            > "$HISTORY_FILE"
            print_history_cleared
        
        # afisare
        else
            print_history_header
            
            if [[ -f "$HISTORY_FILE" && -s "$HISTORY_FILE" ]]; then
                local count=1
                # line by line read
                while read -r line; do
                    
                    print_history_entry "$count" "$line"
                    
                    ((count++))
                done < "$HISTORY_FILE"
            else
                print_history_empty
            fi
            
            print_history_footer
        fi
        return 
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
        cleanup_all_mounts 
        print_exit_message
        break
    fi

    # procesarea comenzii
    process_command "$linie_comanda"
done
