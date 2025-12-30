# --- Configurare Culori Globale (pentru a fi folosite de toate functiile) ---
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

