# AMSH – Auto Mount Shell

**AMSH** este un interpretor de comenzi (shell) customizat pentru Linux, creat cu scopul de a gestiona automat montarea și demontarea sistemelor de fișiere (dispozitive de stocare) la accesare.

Proiectul pune accent pe eficiență și automatizare, demontând dispozitivele care nu mai sunt utilizate după o perioadă de timp configurabilă (**TTL – Time To Live**).

---

## 👥 Autori

- **Ababei Raul-Costin**
- **Iosub Dragoș-Casian**

---

## ✨ Funcționalități Principale

### 🔹 Smart Auto-Mounting
- Detectează automat când utilizatorul încearcă să acceseze un director care este un *mountpoint* (configurat):
  - prin comanda `cd`
  - ca argument pentru comenzi externe (ex: `ls`, `cp`, `cat`)
- Dacă dispozitivul nu este montat, AMSH îl montează automat înainte de executarea comenzii.

### 🔹 Auto-Unmount cu TTL (Time To Live)
- Fiecare mountpoint are o durată de viață configurabilă.
- Sistemul verifică periodic inactivitatea.
- Dacă timpul a expirat și resursa nu este ocupată (verificare cu `fuser`), dispozitivul este demontat automat pentru a economisi resurse și a spori siguranța.

### 🔹 Interfață Grafică în Terminal (TUI)
- Banner de întâmpinare și de ieșire stilizat ASCII.
- Prompt colorat care afișează utilizatorul curent și calea (cu suport pentru `~`).
- Tabele formatate pentru istoricul comenzilor și statusul sistemului.

### 🔹 Notificări Desktop
- Integrare cu `notify-send`.
- Trimite alerte vizuale în mediile grafice (GNOME, KDE, XFCE) la montare și demontare.

### 🔹 Managementul Istoricului
- Salvează comenzile rulate între sesiuni în `~/.amsh_history`.
- Permite vizualizarea și ștergerea istoricului direct din shell.

---

## 📂 Structura Proiectului

```
.
├── amsh.sh              # Scriptul principal (Shell Loop)
├── mount_manager.sh     # Logica de montare/demontare și verificare TTL
├── style.sh             # Funcții pentru interfața grafică (TUI)
├── amsh.conf            # Fișierul de configurare
└── setup_demo.sh        # Script pentru generarea mediului de demo
```

---

## ⚙️ Configurare

Configurarea se face în fișierul **amsh.conf**, aflat în același director cu scripturile.

### Format

```
# DEVICE          MOUNTPOINT       FS_TYPE   TTL (minute)
/tmp/disk.img     /tmp/amsh_mnt    ext4      1
/dev/sdb1         /mnt/usb         vfat      5
```

### Câmpuri

* **DEVICE** – Calea către fișierul imagine sau dispozitiv fizic.
* **MOUNTPOINT** – Directorul unde se va face montarea (trebuie să existe).
* **FS_TYPE** – Tipul sistemului de fișiere (`ext4`, `vfat`, `ntfs`).
* **TTL** – Timpul de inactivitate (în minute) după care se încearcă demontarea automată.

---

### 🎮 Configurare Automată pentru Demo (`setup_demo.sh`)

Pentru a facilita testarea și prezentarea proiectului fără a necesita dispozitive fizice, este inclus scriptul `setup_demo.sh`.

**Rulare:**

```
sudo ./setup_demo.sh
```

**Ce face acest script?**

1. Generează discuri virtuale folosind fișiere imagine (`dd`).
2. Formatează sistemele de fișiere (`vfat`, `ext4`).
3. Populează discurile cu fișiere demonstrative.
4. Generează automat fișierul `amsh.conf` cu valori TTL diferite.

⚠️ **Notă:** Rulați acest script o singură dată înainte de a porni shell-ul AMSH.

---

## 🚀 Utilizare

### ▶️ Pornire

```
sudo ./amsh.sh
```

---

## 🧩 Comenzi Interne (Built-in)

| Comandă | Descriere |
|--------|-----------|
| `cd <cale>` | Schimbă directorul curent. Dacă `<cale>` este un mountpoint nemontat, declanșează montarea automată. |
| `status` | Afișează starea mountpoint-urilor și timpul rămas până la expirare. |
| `history` | Afișează istoricul comenzilor. |
| `history -c` | Șterge istoricul comenzilor. |
| `exit` | Închide shell-ul AMSH. |

---

## 🔧 Comenzi Externe

Orice altă comandă este pasată către shell-ul sistemului și executată normal.

---

## 🛠️ Detalii Tehnice

- Gestionarea semnalului `SIGINT` (`Ctrl+C`) cu `trap`.
- Monitorizare TTL folosind fișiere temporare în `/tmp/amsh_ttl/`.
- Demontare sigură cu `fuser -s`.
- Normalizarea căilor folosind `realpath -m`.
