#!/bin/bash

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

# Check root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[EROARE] Ruleaza cu SUDO!${RESET}"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/amsh.conf"

echo -e "${CYAN}--- SETUP DEMO AMSH ---${RESET}"

# Init config file
echo "# DEVICE            MOUNTPOINT                FS_TYPE   TTL" > "$CONFIG_FILE"

setup_virtual_device() {
    local dev_name="$1"     
    local mnt_name="$2"     
    local fs_type="$3"      
    local ttl="$4"          
    local label="$5"        
    local dummy_files=("${@:6}") 

    local img_path="/tmp/$dev_name"
    
    echo -e "\n${GREEN}[SETUP] $label ($dev_name)${RESET}"

    # creeaza mountpoint
    if [ ! -d "$mnt_name" ]; then
        echo "   -> mkdir $mnt_name"
        mkdir -p "$mnt_name"
        chmod 777 "$mnt_name"
    fi

    # disk image
    if [ ! -f "$img_path" ]; then
        echo "   -> dd image (20MB)..."
        dd if=/dev/zero of="$img_path" bs=1M count=20 status=none
        
        echo "   -> mkfs $fs_type..."
        if [[ "$fs_type" == "vfat" ]]; then
            if command -v mkfs.vfat &> /dev/null; then
                mkfs.vfat "$img_path" > /dev/null
            else
                mkfs.ext4 "$img_path" > /dev/null 2>&1
                fs_type="ext4"
            fi
        else
            mkfs.ext4 "$img_path" > /dev/null 2>&1
        fi

        # dummy files
        echo "   -> populating files..."
        mount -o loop -t "$fs_type" "$img_path" "$mnt_name"
        for file in "${dummy_files[@]}"; do
            touch "$mnt_name/$file"
        done
        mkdir -p "$mnt_name/Folder_Date"
        umount "$mnt_name"
    fi

    # update in asmh.conf
    printf "%-19s %-25s %-9s %s\n" "$img_path" "$mnt_name" "$fs_type" "$ttl" >> "$CONFIG_FILE"
}



setup_virtual_device "demo_usb.img" "/tmp/amsh_usb" "vfat" "1" "USB Stick" "Poze_Vacanta.jpg" "Proiect_SO.pdf"

setup_virtual_device "demo_work.img" "/tmp/amsh_work" "ext4" "10" "HDD Work" "Salarii_2025.xlsx" "Baza_Date.sql"

setup_virtual_device "demo_secret.img" "/tmp/amsh_secret" "ext4" "2" "Secret Disk" "Parole.txt" "Coduri.bin"

echo -e "\n${CYAN}--------------------------------------------------${RESET}"
echo -e "${GREEN}Done! Config generated.${RESET}"
echo -e "Run: ${YELLOW}sudo ./amsh.sh${RESET}"
