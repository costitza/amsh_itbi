show_prompt() {
    local GREEN='\033[1;32m'
    local BLUE='\033[1;34m'
    local RESET='\033[0m'
    local YELLOW='\033[1;33m'
    local CYAN='\033[1;36m'
    
    local current_dir=$(pwd)
    
    if [[ "$current_dir" == "$HOME"* ]]; then
        current_dir="~${current_dir#$HOME}"
    fi
    
    echo -ne "${GREEN}amsh${RESET}:${YELLOW}($(whoami))${CYAN}(${current_dir})${RESET}> "
}

show_welcome_banner() {
    local CYAN='\033[1;36m'
    local GREEN='\033[1;32m'
    local YELLOW='\033[1;33m'
    local RESET='\033[0m'

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

