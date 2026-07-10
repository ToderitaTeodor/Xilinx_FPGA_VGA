# VGA pe FPGA Xilinx Artix-7

## Cuprins
- [VGA pe FPGA Xilinx Artix-7](#vga-pe-fpga-xilinx-artix-7)
  - [Cuprins](#cuprins)
  - [Istoric Revizii](#istoric-revizii)
  - [Obiectivele Proiectului:](#obiectivele-proiectului)
    - [Obiectivul General al Proiectului](#obiectivul-general-al-proiectului)
    - [Obiective Personale](#obiective-personale)
  - [Etapele Proiectului:](#etapele-proiectului)
    - [Etapa 0: Specificațiile Proiectului](#etapa-0-specificațiile-proiectului)
    - [Etapa 1: Proiectarea și Simularea Controllerului VGA (640x480)](#etapa-1-proiectarea-și-simularea-controllerului-vga-640x480)
    - [Etapa 2: Validarea Hardware și Generarea de Modele Statice](#etapa-2-validarea-hardware-și-generarea-de-modele-statice)
    - [Etapa 3: Animarea Obiectelor (Efectul „DVD Screensaver”)](#etapa-3-animarea-obiectelor-efectul-dvd-screensaver)
    - [Etapa 4: Scalarea Rezoluției (Full HD - 1920x1080)](#etapa-4-scalarea-rezoluției-full-hd---1920x1080)
    - [Etapa 5: Integrarea Senzorilor](#etapa-5-integrarea-senzorilor)

---

## Istoric Revizii

| Revizie | Data | Autor | Descriere |
| :--- | :--- | :--- | :--- |
| 0.1 | Iulie 6, 2026 | Teodor Toderiță | Proiectare & simulare VGA |
| 0.2 | Iulie 10, 2026 | Teodor Toderiță | Validare pe placă & animație |

---

## Obiectivele Proiectului:

### Obiectivul General al Proiectului
Obiectivul acestui proiect este proiectarea și implementarea unui controller VGA la nivel de hardware, având ca rezoluție de bază 640x480 pixeli. Proiectul presupune interfațarea unor senzori externi și utilizarea resurselor interne ale FPGA-ului pentru a afișa animații interactive și grafică dinamică pe un monitor.

### Obiective Personale
* **Aprofundarea limbajelor de descriere hardware:** Însușirea și aplicarea conceptelor de proiectare digitală prin utilizarea limbajelor de descriere hardware.
* **Deprinderea bunelor practici de programare:** Scrierea unui cod modular, bine comentat și sintezabil.
* **Stăpânirea fluxului de lucru în Vivado:** Utilizarea completă a suitei de dezvoltare Xilinx Vivado.
* **Dezvoltarea abilităților de depanare:** Învățarea tehnicilor de testare a hardware-ului, atât prin simulare, cât și direct pe placa de dezvoltare prin observarea comportamentului pe ecran.

---

## <u>Etapele Proiectului</u>:

### Etapa 0: Specificațiile Proiectului
* **Obiectivul etapei**: Crearea documentației inițiale a proiectului (README), planificarea etapelor de dezvoltare și studierea fișelor tehnice (datasheets) pentru parametrii de timing ai standardului VGA.
* **Realizarea etapei**: Am structurat planul de lucru și am extras valorile corecte de free-running counters (Front Porch, Back Porch, Sync Pulse) necesare rezoluției de 640x480.

### Etapa 1: Proiectarea și Simularea Controllerului VGA (640x480)
* **Obiectivul etapei**: Scrierea codului pentru semnalele de sincronizare VGA (`HSYNC`, `VSYNC`) și validarea diagramelor de timp folosinf Vivado Simulator.
* **Realizarea etapei**: Am implementat logica de control și am validat semnalele în simulator printr-un testbench, obținând diagramele de timp corecte.
* **Dificultăți întâmpinate**: Inițial, un test a eșuat deoarece culorile nu erau resetate la pornirea sistemului, rămânând cu valori nedefinite.
* **Mod de rezolvare**: Am corectat problema adăugând inițializarea culorilor pe valoarea `0` în blocul de reset.

### Etapa 2: Validarea Hardware și Generarea de Modele Statice
* **Obiectivul etapei**: Configurarea fișierului de constrângeri (`.xdc`) pentru pinii VGA ai plăcii de dezvoltare Basys 3 și afișarea unor modele statice de test (bare de culori) pe un monitor.
* **Realizarea etapei**: Am mapat pinii pentru semnalele de sincronizare și culori în fișierul `.xdc` și am generat pe ecran un model static de test.
* **Dificultăți întâmpinate**: La primul test pe placă, ecranul nu reacționa la apăsarea butonului de reset din cauză că acesta nu fusese mapat corect în fișierul de constrângeri.
* **Mod de rezolvare**: Am corectat maparea pinului corespunzător butonului de reset în fișierul `.xdc`, asigurând inițializarea corectă a controllerului VGA direct din hardware.
  
### Etapa 3: Animarea Obiectelor (Efectul „DVD Screensaver”)
* **Obiectivul etapei**: Implementarea logicii hardware pentru a anima o formă geometrică care se deplasează și ricoșează din marginile ecranului.
* **Realizarea etapei**: Am integrat logica de mișcare și calculul poziției direct în modulul principal al controllerului VGA, desenând un pătrat care își schimbă coordonatele la fiecare reîmprospătare de cadru.
* **Dificultăți întâmpinate**: După adăugarea unui switch pentru controlul vitezei, pătratul depășea limitele ecranului și dispărea pentru o fracțiune de secundă înainte de a ricoșa, din cauză că logica de bounce nu anticipa pasul mai mare de deplasare.
* **Mod de rezolvare**: Am inclus variabila `speed_step` direct în ecuațiile care verifică coliziunea cu marginile active, forțând schimbarea direcției (`dir_x`, `dir_y`) înainte ca obiectul să iasă din zona vizibilă.
    
### Etapa 4: Scalarea Rezoluției (Full HD - 1920x1080)
* **Obiectivul etapei**: Recalcularea parametrilor de timing pentru VGA și scalarea ceasului de pixeli (Pixel Clock) pentru a suporta rezoluția Full HD.
  
### Etapa 5: Integrarea Senzorilor
* **Obiectivul etapei**: Interfațarea unui senzor ultrasonic pentru controlul interactiv al elementelor grafice afișate.