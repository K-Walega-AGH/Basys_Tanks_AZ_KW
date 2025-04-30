# Basys_Tanks - UEC2 Basys3 Project
```

## Inicjalizacja środowiska

Komendę `. env.sh` trzeba uruchomić za każdym razem, gdy rozpoczynamy pracę w nowej sesji terminala. Następnie, pozostając w głównym folderze, można wywoływać dostępne narzędzia:

* `run_simulation.sh`
* `generate_bitstream.sh`
* `program_fpga.sh`
* `clean.sh`

## Opis Narzędzi

### `run_simulation.sh`

Tak jak na labolatioriach - wszystkie symulacje uruchamiane są skryptem `run_simulation.sh`.

* Wyświetlenie listy dostępnych testów

  ```bash
  run_simulation.sh -l
  ```

* Uruchamianie symulacji w trybie tekstowym

  ```bash
  run_simulation.sh -t <nazwa_testu>
  ```

* Uruchamianie symulacji w trybie graficznym

  ```bash
  run_simulation.sh -gt <nazwa_testu>
  ```

* Uruchamianie wszystkich symulacji

  ```bash
  run_simulation.sh -a
  ```

  W tym trybie, po kolei uruchamiane są wszystkie symulacje dostępne w folderze `sim`, a w terminalu wyświetlana jest informacja o ich wyniku:

  * PASSED - jeśli nie wykryto żadnych błędów,
  * FAILED - jeśli podczas symulacji wykryto błędy (w logu przynajmniej raz pojawiło się słowo _error_).

  Aby test działał poprawnie, należy w testbenchu stosować **asercje**, które w przypadku niespełnienia warunku zwrócą `$error`.

### `generate_bitstream.sh`

Skrypt ten uruchamia generację bitstreamu, który finalnie znajdzie się w folderze `results`. Następnie sprawdza logi z syntezy i implementacji pod kątem ewentualnych ostrzeżeń (_warning_, _critical warning_) i błędów (_error_), a w razie ich wystąpienie kopiuje ich treść do pliku `results/warning_summary.log`.

### `program_fpga.sh`

Aby skrypt poprawnie wgrał bitstream do FPGA, w folderze `results` musi znajdować się **tylko jeden** plik z rozszerzeniem `.bit`.

### `clean.sh`

Skrypt `clean.sh` kasuje wszystkie pliki i foldery, które są wymienione w `.gitignore`.

```

## Uruchamianie projektu w Vivado w trybie graficznym

Aby otworzyć w Vivado w trybie graficznym zbudowany projekt (tzn. po zakończeniu działania `generate_bitstream.sh`), należy przejść do folderu `fpga/build` i wywołać w nim komendę:

```bash
vivado <nazwa_projektu>.xpr
```

## Struktura projektu

Poniżej przedstawiono hierarchię plików w projekcie.

```text
.
├── env.sh                         - konfiguracja środowiska
```
