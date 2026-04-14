# Basys Tanks 🚀
**Advanced SystemVerilog Game Engine for FPGA (Digilent Basys 3)**

[![Platform](https://img.shields.io/badge/Hardware-Basys3-blue)](https://digilent.com/reference/programmable-logic/basys-3/start)
[![Language](https://img.shields.io/badge/Language-SystemVerilog-orange)](https://en.wikipedia.org/wiki/SystemVerilog)
[![Toolchain](https://img.shields.io/badge/Tools-Vivado-brightgreen)](https://www.xilinx.com/products/design-tools/vivado.html)

## 📌 O Projekcie
**Basys Tanks** to w pełni sprzętowa implementacja gry zręcznościowej inspirowanej klasykami takimi jak *Pocket Tanks* i *Worms*. Projekt został stworzony w ramach przedmiotu UEC2 i realizuje zaawansowane koncepcje projektowania układów cyfrowych.

W przeciwieństwie do tradycyjnych gier, cały silnik graficzny, fizyka oraz logika rozgrywki zostały opisane w języku **SystemVerilog** i zaimplementowane bezpośrednio w strukturze FPGA (Artix-7), bez użycia procesora typu softcore (np. MicroBlaze).

### Kluczowe Funkcjonalności (Tech Stack):
* **Custom VGA Controller:** Generowanie obrazu 640x480 w czasie rzeczywistym z obsługą warstw i dynamicznych obiektów.
* **Dynamic Terrain Destruction:** Implementacja niszczalnego terenu oparta na dwuportowej pamięci RAM (Terrain RAM), pozwalająca na modyfikację mapy po każdym wybuchu.
* **Silnik Fizyczny:** Obliczanie trajektorii lotu pocisków w oparciu o tablice LUT (Sin/Cos) oraz detekcję kolizji z terenem i czołgami.
* **Interfejs PS/2:** Autorska obsługa klawiatury jako głównego kontrolera (sterowanie ruchem, kątem strzału i siłą).
* **Modular FSM Logic:** Architektura oparta na maszynach stanów zarządzających ekranem startowym, właściwą rozgrywką oraz podsumowaniem wyników.
* **System Diagnostyczny UART:** Monitorowanie statusu gry i przesyłanie logów diagnostycznych do PC.

---

## 🏗 Struktura Projektu
Projekt charakteryzuje się modularnością, co ułatwia testowanie i rozbudowę:

* `rtl/` – Kod źródłowy podzielony tematycznie (subsystemy: `tank`, `projectile`, `terrain`, `vga`, `ps2`).
* `sim/` – Środowisko weryfikacyjne z zestawem testbenchów dla kluczowych modułów.
* `tools/` – Zestaw skryptów automatyzujących proces syntezy, implementacji i symulacji (Bash + TCL).
* `doc/` – Pełna dokumentacja projektowa, w tym raporty i listy kontrolne.

---

## 🛠 Automatyzacja i Workflow
Projekt wykorzystuje skrypty automatyzujące, co znacząco przyspiesza cykl deweloperski i upodabnia go do profesjonalnych standardów "Scripts-First":

1.  **Inicjalizacja:** `source env.sh`
2.  **Symulacja:** `./tools/run_simulation.sh -a` (Automatyczne testowanie wszystkich modułów z raportowaniem PASSED/FAILED).
3.  **Synteza:** `./tools/generate_bitstream.sh` (Z automatyczną ekstrakcją błędów i ostrzeżeń do logów).
4.  **Programowanie:** `./tools/program_fpga.sh`

---

## 🚀 Jak uruchomić projekt?

### Wymagania:
* Vivado Design Suite (rekomendowana wersja zgodna z projektem).
* Płytka Digilent Basys 3.
* Monitor VGA oraz klawiatura PS/2.

Projekt realizowany w ramach laboratorium Układy Elektroniczne Cyfrowe 2 (UEC2).
