# AMSH - Auto Mount Shell

AMSH este un interpretor de comenzi (shell) customizat pentru Linux, creat cu scopul de a gestiona automat montarea și demontarea sistemelor de fișiere (dispozitive de stocare) la accesare. Proiectul pune accent pe eficiență și automatizare, demontând dispozitivele care nu mai sunt utilizate după o perioadă de timp configurabilă (TTL).

# 👥 Autori

    Ababei Raul-Costin

    Iosub Dragos-Casian

# ✨ Funcționalități Principale

    Smart Auto-Mounting:

        Detectează automat când utilizatorul încearcă să acceseze un director care este un mountpoint (fie prin cd, fie ca argument la comenzi precum ls, cp, cat).

        Dacă dispozitivul nu este montat, AMSH îl montează automat înainte de a executa comanda.

    Auto-Unmount cu TTL (Time To Live):

        Fiecare mountpoint are o durată de viață configurabilă.

        Sistemul verifică periodic inactivitatea. Dacă timpul a expirat și resursa nu este ocupată (verificare cu fuser), dispozitivul este demontat automat pentru a economisi resurse sau pentru siguranță.

    Interfață Grafică în Terminal (TUI):

        Banner de întâmpinare și de ieșire stilizat ASCII.

        Prompt colorat care afișează utilizatorul curent și calea curentă (cu suport pentru ~).

        Tabele formatate pentru istoricul comenzilor și statusul sistemului.

    Notificări Desktop:

        Integrare cu notify-send pentru a trimite alerte vizuale în mediul grafic (GNOME/KDE/XFCE) la montare și demontare.

    Managementul Istoricului:

        Salvează comenzile rulate între sesiuni în ~/.amsh_history.

        Permite vizualizarea și ștergerea istoricului direct din shell.

# 📂 Structura Proiectului

    amsh.sh: Scriptul principal. Gestionează bucla de citire a comenzilor (REPL), parsing-ul argumentelor și execuția comenzilor interne sau externe.

    mount_manager.sh: "Creierul" din spatele operațiunilor de sistem. Conține logica pentru:

        Citirea fișierului de configurare.

        Verificarea expirării timpului (TTL).

        Executarea comenzilor mount și umount.

        Trimiterea notificărilor.

    style.sh: Modul responsabil de aspectul vizual. Conține definițiile de culori și funcțiile pentru afișarea bannerelor și a tabelelor.

    amsh.conf: Fișierul de configurare unde sunt definite dispozitivele și regulile lor de montare.

## ⚙️ Configurare

Configurarea se face în fișierul amsh.conf aflat în același director cu scripturile. Formatul este următorul:

/# DEVICE          MOUNTPOINT       FS_TYPE   TTL (minute)
/tmp/disk.img     /tmp/amsh_mnt    ext4      1
/dev/sdb1         /mnt/usb         vfat      5

    DEVICE: Calea către fișierul imagine sau dispozitivul fizic.

    MOUNTPOINT: Directorul unde se va face montarea (trebuie să existe).

    FS_TYPE: Tipul sistemului de fișiere (ex: ext4, vfat, ntfs).

    TTL: Timpul de inactivitate (în minute) după care se va încerca demontarea automată.

## 🚀 Utilizare
Pornire

Deoarece comenzile mount și umount necesită privilegii de root, scriptul trebuie rulat cu sudo:
```bash
sudo ./amsh.sh
```
Comenzi Interne (Built-in)
Comandă	Descriere__
cd <cale>	Schimbă directorul curent. Dacă <cale> este un mountpoint nemontat, declanșează montarea automată.__
status	Afișează un tabel cu toate punctele de montare, starea lor (MONTAT/DEMONTAT) și timpul rămas până la expirare (în secunde).__
history	Afișează lista comenzilor anterioare într-un tabel stilizat.__
history -c	Șterge întregul istoric al comenzilor.__
exit	Închide shell-ul AMSH.__
Comenzi Externe__

Orice altă comandă (ex: ls, cat, vim, cp) este pasată către shell-ul sistemului (sh -c).__

    Notă: AMSH interceptează argumentele acestor comenzi. Dacă scrieți ls /mnt/usb, AMSH va verifica mai întâi dacă /mnt/usb trebuie montat.

## 🛠️ Detalii Tehnice și Observații
1. Gestionarea Semnalelor (SIGINT)

- Scriptul interceptează semnalul SIGINT (Ctrl+C).
- Dacă utilizatorul apasă Ctrl+C în timp ce scrie o comandă, promptul se resetează fără a închide shell-ul.
- Dacă o comandă externă rulează (ex: sleep 10), Ctrl+C va opri doar acea comandă, nu și AMSH.

2. Logica de Expirare (TTL)

- Sistemul folosește fișiere "martor" (timestamp files) stocate în /tmp/amsh_ttl/ pentru a monitoriza activitatea.
- La fiecare accesare (smart_mount), se actualizează timestamp-ul fișierului martor folosind touch.
- Funcția de curățare calculează diferența dintre timpul curent și timpul ultimei accesări.
- Siguranță: Chiar dacă timpul a expirat, umount nu se execută dacă directorul este ocupat de un proces (verificare realizată cu fuser -s).

3. Modularizare
Codul este strict modularizat:
- amsh.sh nu conține logică de afișare complexă sau logică de sistem, ci doar coordonează modulele style.sh și mount_manager.sh. Aceasta permite o întreținere ușoară și extinderea funcționalităților.

4. Parsarea Căilor
- Pentru a evita erorile cauzate de căi relative (ex: ../mnt), scriptul convertește toate argumentele în căi absolute folosind realpath -m înainte de a le verifica în fișierul de configurare.

## 🧪 Testare
- Pentru a verifica dacă logica de montare funcționează corect (fără interfața shell), se poate rula scriptul de test inclus:
```bash

sudo ./test_mount_logic.sh
```
Acesta va itera prin toate intrările din amsh.conf, va încerca să le monteze, va lista conținutul și le va demonta imediat, raportând succesul sau eșecul operațiunii.

