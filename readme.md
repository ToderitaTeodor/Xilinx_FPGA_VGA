# VGA pe FPGA Xilinx Artix-7
## Autor: Toderiță Teodor
---

## Istoric Revizii

| Revizie | Data | Autor | Descriere |
| :--- | :--- | :--- | :--- |
| 0.1 | Iulie 6, 2026 | Teodor Toderiță | First draft|
| 0.2 | Iulie 10, 2026 | Teodor Toderiță | Am implementat etapele 1, 2 și 3. Am documentat progesul |
| 0.3 | Iulie 15, 2026 | Teodor Toderiță | Am scalat rezoluția la 1920x180 @60Hz |

---

- [VGA pe FPGA Xilinx Artix-7](#vga-pe-fpga-xilinx-artix-7)
  - [Autor: Toderiță Teodor](#autor-toderiță-teodor)
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

## Obiectivele Proiectului:

### Obiectivul General al Proiectului
Obiectivul acestui proiect este proiectarea și implementarea unui controller VGA la nivel de hardware, având ca rezoluție de bază 640x480 pixeli. Proiectul presupune interfațarea unor senzori externi și utilizarea resurselor interne ale FPGA-ului pentru a afișa animații interactive și grafică dinamică pe un monitor.

### Obiective Personale
* **Aprofundarea limbajelor de descriere hardware:** Însușirea și aplicarea conceptelor de proiectare digitală prin utilizarea limbajelor de descriere hardware.
* **Deprinderea bunelor practici de programare:** Scrierea unui cod modular, bine comentat și sintezabil.
* **Stăpânirea fluxului de lucru în Vivado:** Utilizarea completă a suitei de dezvoltare Xilinx Vivado.
* **Dezvoltarea abilităților de depanare:** Învățarea tehnicilor de testare a hardware-ului, atât prin simulare, cât și direct pe placa de dezvoltare prin observarea comportamentului pe ecran.

---

## Etapele Proiectului:

### Etapa 0: Specificațiile Proiectului
* **Obiectivul etapei**: Crearea documentației inițiale a proiectului (README), planificarea etapelor de dezvoltare și studierea fișelor tehnice (datasheets) pentru parametrii de timing ai standardului VGA.
* **Realizarea etapei**: Am structurat planul de lucru și am extras valorile corecte de free-running counters (Front Porch, Back Porch, Sync Pulse) necesare rezoluției de 640x480.

### Etapa 1: Proiectarea și Simularea Controllerului VGA (640x480)
* **Obiectivul etapei**: Scrierea codului pentru semnalele de sincronizare VGA (`HSYNC`, `VSYNC`) și validarea diagramelor de timp folosinf Vivado Simulator.
* **Realizarea etapei**: Am proiectat logica de control prin implementarea a două numărătoare independente pentru axa orizontală și cea verticală. Pe baza acestora, am generat semnalele `hsync_o` și `vsync_o` respectând timpii din documentația standardului VGA (Active Video, Front Porch, Sync Pulse, Back Porch). Ulterior, am validat funcționalitatea în simulator printr-un testbench, obținând diagramele de timp corecte.
* **Dificultăți întâmpinate**: Inițial, un test a eșuat deoarece culorile nu erau resetate la pornirea sistemului, rămânând cu valori nedefinite.
* **Mod de rezolvare**: Am corectat problema adăugând inițializarea culorilor pe valoarea `0` în blocul de reset.

### Etapa 2: Validarea Hardware și Generarea de Modele Statice
* **Obiectivul etapei**: Configurarea fișierului de constrângeri (`.xdc`) pentru pinii VGA ai plăcii de dezvoltare Basys 3 și afișarea unor modele statice de test (bare de culori) pe un monitor.
* **Realizarea etapei**: Am realizat un Block Design în Vivado și am integrat IP-ul Clocking Wizard pentru a genera un ceas stabil la frecvența de 25.175 MHz. Arhitectura este modulară, ceea ce permite modificarea frecvenței de ceas în orice moment pentru alte rezoluții. În final, am mapat pinii pentru semnalele de sincronizare și culori în fișierul `.xdc`, reușind să afișez pe ecran modelul static de test.
* **Dificultăți întâmpinate**: La primul test pe placă, ecranul nu reacționa la apăsarea butonului de reset din cauză că acesta nu fusese mapat corect în fișierul de constrângeri.
* **Mod de rezolvare**: Am corectat maparea pinului corespunzător butonului de reset în fișierul `.xdc`, asigurând inițializarea corectă a controllerului VGA direct din hardware.
  
### Etapa 3: Animarea Obiectelor (Efectul „DVD Screensaver”)
* **Obiectivul etapei**: Implementarea logicii hardware pentru a anima o formă geometrică care se deplasează și ricoșează din marginile ecranului.
* **Realizarea etapei**: Am integrat logica de mișcare și calculul poziției direct în modulul principal al controllerului VGA, desenând un pătrat care își schimbă coordonatele la fiecare reîmprospătare de cadru.
* **Dificultăți întâmpinate**: După adăugarea unui switch pentru controlul vitezei, pătratul depășea limitele ecranului și dispărea pentru o fracțiune de secundă înainte de a ricoșa, din cauză că logica de bounce nu anticipa pasul mai mare de deplasare.
* **Mod de rezolvare**: Am inclus variabila `speed_step` direct în ecuațiile care verifică coliziunea cu marginile active, forțând schimbarea direcției (`dir_x`, `dir_y`) înainte ca obiectul să iasă din zona vizibilă.
    
### Etapa 4: Scalarea Rezoluției (Full HD - 1920x1080)

* **Obiectivul etapei**: Recalcularea parametrilor de sincronizare (timing) pentru VGA și scalarea ceasului de pixeli pentru a suporta rezoluția Full HD.
* **Realizarea etapei**: Am calculat frecvența necesară pentru a suporta rezoluția de 1920x1080 la 60Hz, care este de 148.5 MHz. Am configurat IP-ul Clocking Wizard pentru a genera acest ceas stabil (pornind de la ceasul fizic de 100 MHz al plăcii Basys 3) și am actualizat în cod parametrii de sincronizare (orizontală și verticală) conform standardului.
* **Dificultăți întâmpinate**: După aplicarea acestor modificări, ecranul monitorului nu afișa nimic sau arăta o eroare legată de frecvențele nesuportate.
* **Mod de rezolvare**: În codul inițial, numărătoarele de pixeli erau definite pe 10 biți. Însă pentru Full HD, numărul total de pixeli ajunge la 2200 pe orizontală și 1125 pe verticală. Am rezolvat această problemă prin extinderea porturilor și a registrelor la 12 biți.
   
### Etapa 5: Integrarea Senzorilor
* **Obiectivul etapei**: Interfațarea unui senzor ultrasonic pentru controlul interactiv al elementelor grafice afișate.