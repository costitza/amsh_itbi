#!/bin/bash

CONFIG_FILE="amsh.conf"

# Culori
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[EROARE] Trebuie sa rulezi acest test cu SUDO!${NC}"
  exit 1
fi

# config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}[EROARE] Nu gasesc fisierul $CONFIG_FILE${NC}"
    exit 1
fi

# citire linie cu linie
while read -r device mountpoint fstype ttl; do
    # comments
    [[ "$device" == \#* ]] || [[ -z "$device" ]] && continue

    echo "---------------------------------------------------"
    echo -e "Testez intrarea: DEVICE=${CYAN}$device${NC} -> MNT=${CYAN}$mountpoint${NC}"

    # verificare daca sursa exista
    if [ ! -e "$device" ]; then
        echo -e "${RED}[FAIL] Device-ul sursă $device nu există!${NC}"
        continue
    fi

    # mountpoint exists
    if [ ! -d "$mountpoint" ]; then
        echo -e "[INFO] Folderul $mountpoint nu există. Îl creez acum..."
        mkdir -p "$mountpoint"
    fi

    # already mounted
    if mountpoint -q "$mountpoint"; then
        echo -e "[INFO] Este deja montat. Îl demontez pentru test..."
        umount "$mountpoint"
    fi

    # try to mount
    # daca fisier simplu (imagine), adauga automat '-o loop'
    MOUNT_OPTS=""
    if [ -f "$device" ]; then
        MOUNT_OPTS="-o loop"
    fi

    echo -e "[EXEC] Execut: mount $MOUNT_OPTS -t $fstype $device $mountpoint"
    mount $MOUNT_OPTS -t "$fstype" "$device" "$mountpoint"

    # verif rezultat
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Montare reușită!${NC}"
        echo "Conținutul directorului:"
        ls -F "$mountpoint"

        echo -e "[CLEANUP] Demontez $mountpoint..."
        umount "$mountpoint"
    else
        echo -e "${RED}[FAIL] Comanda mount a eșuat!${NC}"
    fi

done < "$CONFIG_FILE"

echo -e "\n${CYAN}=== Testare Finalizată ===${NC}"
