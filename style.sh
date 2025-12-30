show_prompt() {
    local GREEN='\033[1;32m'
    local BLUE='\033[1;34m'
    local RESET='\033[0m'
    
    local current_dir=$(pwd)
    
    if [[ "$current_dir" == "$HOME"* ]]; then
        current_dir="~${current_dir#$HOME}"
    fi
    
    echo -ne "${GREEN}amsh${RESET}:${BLUE}${current_dir}${RESET}> "
}

