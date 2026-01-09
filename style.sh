
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'
BLUE='\033[1;34m'

print_history_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}                   ${GREEN}ISTORIC COMENZI${RESET}                    ${CYAN}║${RESET}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════╣${RESET}"
}


print_history_entry() {
    local index="$1"
    local command_text="$2"
    
    # taie comanda
    local safe_command="${command_text:0:44}"
    
    printf "${CYAN}║${YELLOW} %3d ${CYAN}│${RESET} %-44s   ${CYAN}║${RESET}\n" "$index" "$safe_command"
}

print_history_footer() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
}

print_history_empty() {
    echo -e "${CYAN}║${YELLOW}               (Nu există istoric)            ${CYAN}║${RESET}"
}

print_history_cleared() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${GREEN}           Istoricul a fost șters cu succes!          ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
}

print_help_menu() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${GREEN}               COMENZI DISPONIBILE (HELP)                 ${CYAN}║${RESET}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${RESET}"

    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN} ║${RESET}\n" "cd <cale>" "Navigare & Montare automată"
    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}  ║${RESET}\n" "status" "Vezi timpul rămas (TTL) și starea"
    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}   ║${RESET}\n" "locate <nume>" "Caută fișier în toate discurile"
    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN} ║${RESET}\n" "history [-c]" "Vezi/Șterge istoricul comenzilor"
    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}  ║${RESET}\n" "exit" "Cleanup (unmount all) și Ieșire"
    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}║${RESET}\n" "scan" "Scaneaza pentru mpoint-uri noi"
    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN} ║${RESET}\n" "usage" "Vezi spațiul liber pe discuri"
    printf "${CYAN}║${YELLOW} %-18s ${CYAN}│${RESET} %-35s ${CYAN}  ║${RESET}\n" "help" "Afișează acest meniu"
    
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

show_prompt() {
    local current_dir=$(pwd)
    
    if [[ "$current_dir" == "$HOME"* ]]; then
        current_dir="~${current_dir#$HOME}"
    fi
    
    echo -ne "${GREEN}amsh${RESET}:${YELLOW}($(whoami))${CYAN}(${current_dir})${RESET}> "
}

show_welcome_banner() {

    clear

    echo -e "${CYAN}╔═════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}                                             ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}          ${GREEN}AUTO MOUNT SHELL (AMSH)${RESET} 	      ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}            ITBI – Proiect 2025              ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}       By Ababei Raul & Iosub Dragos         ${CYAN}║${RESET}"
    echo -e "${CYAN}║${RESET}                                             ${CYAN}║${RESET}"
    echo -e "${CYAN}╚═════════════════════════════════════════════╝${RESET}"

    echo
    echo -e "  👤 User : ${YELLOW}$(whoami)${RESET}"
    echo -e "  💻 Host : ${YELLOW}$(hostname)${RESET}"
    echo -e "  🕒 Date : ${YELLOW}$(date +'%Y-%m-%d %H:%M')${RESET}"
    echo -e "  ⚙️  Config: ${YELLOW}amsh.conf${RESET}"
    echo -e "  ──────────────────────────────────────────────────"
    echo
}

print_exit_message() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}                   ${GREEN}LA REVEDERE!${RESET}                       ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
}
