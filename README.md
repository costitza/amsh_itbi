# AMSH – Auto Mount Shell

**AMSH** este un interpretor de comenzi (shell) customizat pentru Linux, creat cu scopul de a gestiona automat montarea și demontarea sistemelor de fișiere (dispozitive de stocare) la accesare.

Proiectul pune accent pe eficiență și automatizare, demontând dispozitivele care nu mai sunt utilizate după o perioadă de timp configurabilă (**TTL – Time To Live**).

---

## 👥 Autori

Proiect realizat în cadrul cursului **Sisteme de Operare (2025)**:

- **Ababei Raul-Costin**
- **Iosub Dragoș-Casian**

---

## ✨ Funcționalități Principale

### 🔹 Smart Auto-Mounting
- Detectează automat când utilizatorul încearcă să acceseze un director care este un *mountpoint*:
  - prin `cd`
  - ca argument pentru comenzi precum `ls`, `cp`, `cat`
- Dacă dispozitivul nu este montat, AMSH îl montează automat înainte de executarea comenzii.

### 🔹 Auto-Unmount cu TTL (Time To Live)
- Fiecare mountpoint are o durată de viață configurabilă.
- Sistemul verifică periodic inactivitatea.
- Dacă timpul a expirat și resursa nu este ocupată (verificare cu `fuser`), dispozitivul este demontat automat pentru:
  - economisirea resurselor
  - siguranță sporită.

### 🔹 Interfață Grafică în Terminal (TUI)
- Banner de întâmpinare și de ieșire stilizat ASCII.
- Prompt colorat care afișează:
  - utilizatorul curent
  - calea curentă (cu suport pentru `~`).
- Tabele formatate pentru istoricul comenzilor și statusul sistemului.

### 🔹 Notificări Desktop
- Integrare cu `notify-send`.
- Trimite alerte vizuale în mediile grafice:
  - GNOME
  - KDE
  - XFCE.

### 🔹 Managementul Istoricului
- Salvează comenzile rulate între sesiuni în:
  ```bash
  ~/.amsh_history
  ```
- Permite vizualizarea și ștergerea istoricului direct din shell.

---

## 📂 Structura Proiectului

```
.
├── amsh.sh
├── mount_manager.sh
├── style.sh
├── amsh.conf
└── test_mount_logic.sh
```

---

## ⚙️ Configurare

Configurarea se face în fișierul **amsh.conf**, aflat în același director cu scripturile.

### Format

```text
# DEVICE          MOUNTPOINT       FS_TYPE   TTL (minute)
/tmp/disk.img     /tmp/amsh_mnt    ext4      1
/dev/sdb1         /mnt/usb         vfat      5
```

### Câmpuri

- **DEVICE** – Calea către fișierul imagine sau dispozitiv fizic.
- **MOUNTPOINT** – Directorul unde se va face montarea (trebuie să existe).
- **FS_TYPE** – Tipul sistemului de fișiere (`ext4`, `vfat`, `ntfs`).
- **TTL** – Timpul de inactivitate (în minute) după care se încearcă demontarea automată.

---

## 🚀 Utilizare

### ▶️ Pornire

```bash
sudo ./amsh.sh
```

---

## 🧩 Comenzi Interne (Built-in)

| Comandă        | Descriere |
|---------------|-----------|
| `cd <cale>`   | Schimbă directorul curent. Dacă `<cale>` este un mountpoint nemontat, declanșează montarea automată. |
| `status`      | Afișează starea mountpoint-urilor și timpul rămas până la expirare. |
| `history`     | Afișează istoricul comenzilor. |
| `history -c`  | Șterge istoricul comenzilor. |
| `exit`        | Închide shell-ul AMSH. |

---

## 🔧 Comenzi Externe

Orice altă comandă este pasată către shell-ul sistemului (`sh -c`).

---

## 🛠️ Detalii Tehnice

- Gestionarea semnalului `SIGINT` (`Ctrl+C`)
- Monitorizare TTL folosind fișiere martor în `/tmp/amsh_ttl/`
- Demontare sigură folosind `fuser -s`
- Conversia tuturor căilor la căi absolute cu `realpath -m`

---

## 🧪 Testare

```bash
sudo ./test_mount_logic.sh
```

Scriptul testează automat toate intrările din `amsh.conf`.

---

Proiect educațional realizat în scop academic.
