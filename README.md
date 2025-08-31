# Basys_Tanks - UEC2 Basys3 Project

README zainspirowane tym z labolatorii.

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

### `get_errors.sh`

Skrypt ten można uruchomić po generacji bitstreamu (udanej, bądź nie udanej), który w folderze `results` utworzy plik `critical_errors_only.log` zawierający wszystkie CRITICAL_WARNING i ERROR zgłoszone w pliku `results/warning_summary.log`.

### `open_vivado.sh`

Prosty skrypt, żeby uruchomić Vivado po generacji bitstreamu w celu dokładnego sprawdzenia występujących błędów (Project Summary, Timing Report, etc).

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
│-- .gitignore
|-- env.sh
|-- README.md
|-- doc
|   |-- lista_kontrolna_AZ_KW_BasysTanks.pdf
|   `-- raport_AZ_KW_BasysTanks.pdf
|-- fpga
|   |-- constraints
|   |   |-- clk_wiz_1.xdc
|   |   `-- top_vga_basys3.xdc
|   |-- rtl
|   |   |-- clk_wiz_1.v
|   |   |-- clk_wiz_1_clk_wiz.v
|   |   `-- top_vga_basys3.sv
|   `-- scripts
|       |-- generate_bitstream.tcl
|       |-- program_fpga.tcl
|       `-- project_details.tcl
|-- results
|   |-- P1_top_vga_basys3.bit
|   `-- P2_top_vga_basys3.bit
|-- rtl
|   |-- 1_start_screen
|   |   |-- draw_tanks_photo.sv
|   |   |-- start_screen.sv
|   |   `-- start_screen_ctl.sv
|   |-- 2_main_game
|   |   |-- main_game.sv
|   |   `-- main_game_ctl.sv
|   |-- 3_end_screen
|   |   |-- end_screen.sv
|   |   `-- end_screen_ctl.sv
|   |-- background
|   |   `-- draw_bg.sv
|   |-- data_files
|   |   |-- barrel
|   |   |   |-- barrel0.data
|   |   |   |-- barrel0_L.data
|   |   |   |-- barrel0_R.data
|   |   |   |-- barrel1.data
|   |   |   |-- barrel1_L.data
|   |   |   |-- barrel1_R.data
|   |   |   |-- barrel2.data
|   |   |   |-- barrel2_L.data
|   |   |   |-- barrel2_R.data
|   |   |   |-- barrel3.data
|   |   |   |-- barrel3_L.data
|   |   |   |-- barrel3_R.data
|   |   |   |-- barrel4.data
|   |   |   |-- barrel4_L.data
|   |   |   |-- barrel4_R.data
|   |   |   |-- barrel5.data
|   |   |   |-- barrel5_L.data
|   |   |   |-- barrel5_R.data
|   |   |   |-- barrel6.data
|   |   |   |-- barrel6_L.data
|   |   |   |-- barrel6_R.data
|   |   |   |-- barrel7.data
|   |   |   |-- barrel7_L.data
|   |   |   `-- barrel7_R.data
|   |   |-- bg
|   |   |   |-- agh_b1_4bit.data
|   |   |   `-- bg2_4bit.data
|   |   |-- bg_rom.data
|   |   |-- border_fuel.data
|   |   |-- border_str.data
|   |   |-- explosion
|   |   |   |-- explosion0.data
|   |   |   |-- explosion1.data
|   |   |   |-- explosion2.data
|   |   |   |-- explosion3.data
|   |   |   |-- explosion4.data
|   |   |   |-- explosion5.data
|   |   |   |-- explosion6.data
|   |   |   `-- explosion7.data
|   |   |-- hp_agh.data
|   |   |-- hp_icon.data
|   |   |-- image_rom.data
|   |   |-- projectile1.data
|   |   |-- start_tank
|   |   |   `-- start_tank256x128_4bit.data
|   |   |-- tank.data
|   |   |-- tank_L.data
|   |   |-- tank_R.data
|   |   `-- terrain.data
|   |-- delay
|   |   |-- delay.sv
|   |   |-- sync_2xff.sv
|   |   |-- sync_handshake.sv
|   |   `-- vga_if_delay.sv
|   |-- delay.sv
|   |-- draw_img
|   |   |-- draw_param_text.sv
|   |   |-- draw_param_text_blink.sv
|   |   |-- draw_rect_char.sv
|   |   |-- draw_rect_ctl.sv
|   |   `-- draw_rect_image.sv
|   |-- help
|   |   `-- draw_help.sv
|   |-- interface
|   |   |-- draw_angle.sv
|   |   |-- draw_fuel.sv
|   |   |-- draw_hp.sv
|   |   |-- draw_if_bg.sv
|   |   |-- draw_strength.sv
|   |   |-- interface_pkg.sv
|   |   `-- player_interface.sv
|   |-- projectile
|   |   |-- cos_lut.sv
|   |   |-- draw_explosion.sv
|   |   |-- draw_projectile.sv
|   |   |-- explosion.sv
|   |   |-- explosion_ctl.sv
|   |   |-- projectile.sv
|   |   |-- projectile_ctl.sv
|   |   |-- projectile_pkg.sv
|   |   `-- sin_lut.sv
|   |-- ps2_keyboard
|   |   |-- FF_15.sv
|   |   |-- Ps2Interface.vhd
|   |   |-- ps2_display.sv
|   |   |-- ps2_keyboard.sv
|   |   |-- ps2_keyboard_2xff.sv
|   |   |-- ps2_keyboard_ctl.sv
|   |   `-- ps2_keyboard_latch.sv
|   |-- ram
|   |   `-- terrain_ram.sv
|   |-- rom
|   |   |-- angle_rom.sv
|   |   |-- barrel_rom.sv
|   |   |-- bg_rom.sv
|   |   |-- border_fuel_rom.sv
|   |   |-- border_str_rom.sv
|   |   |-- char_rom.sv
|   |   |-- explosion_rom.sv
|   |   |-- font_rom.sv
|   |   |-- help_rom.sv
|   |   |-- hp_rom.sv
|   |   |-- image_rom.sv
|   |   |-- photo_tanks_rom.sv
|   |   |-- projectile_rom.sv
|   |   |-- tank_rom.sv
|   |   `-- text_rom.sv
|   |-- tank
|   |   |-- barrel.sv
|   |   |-- barrel_ctl.sv
|   |   |-- draw_barrel.sv
|   |   |-- draw_tank.sv
|   |   |-- tank.sv
|   |   |-- tank_ctl.sv
|   |   |-- tank_move.sv
|   |   `-- tank_pkg.sv
|   |-- terrain
|   |   |-- draw_terrain.sv
|   |   |-- terrain.sv
|   |   |-- terrain_destruction.sv
|   |   `-- terrain_pkg.sv
|   |-- top_vga.sv
|   |-- top_vga_ctl.sv
|   |-- uart
|   |   |-- display_UART.sv
|   |   |-- lab6_files
|   |   |   |-- debounce.v
|   |   |   |-- disp_hex_mux.v
|   |   |   |-- fifo.v
|   |   |   |-- flag_buf.v
|   |   |   |-- mod_m_counter.v
|   |   |   |-- uart.v
|   |   |   |-- uart_rx.v
|   |   |   |-- uart_test.v
|   |   |   `-- uart_tx.v
|   |   |-- monitor_UART.sv
|   |   |-- top_uart.sv
|   |   `-- uart_pkg.sv
|   `-- vga
|       |-- vga_if.sv
|       |-- vga_pkg.sv
|       `-- vga_timing.sv
|-- sim
|   |-- common
|   |   |-- glbl.v
|   |   `-- tiff_writer.sv
|   |-- delay_test
|   |   `-- delay_test.sv
|   |-- draw_rect_ctl
|   |   |-- draw_rect_ctl.prj
|   |   |-- draw_rect_ctl_prog.sv
|   |   `-- draw_rect_ctl_tb.sv
|   |-- main_game
|   |   |-- main_game.prj
|   |   `-- main_game_tb.sv
|   |-- ps2_keyboard
|   |   |-- ps2_keyboard.prj
|   |   `-- ps2_keyboard_tb.sv
|   |-- tank_movement
|   |   |-- tank_movement.prj
|   |   `-- tank_movement_tb.sv
|   |-- top_fpga
|   |   |-- top_fpga.prj
|   |   `-- top_fpga_tb.sv
|   |-- top_vga
|   |   |-- top_vga.prj
|   |   `-- top_vga_tb.sv
|   `-- vga_timing
|       |-- vga_timing.prj
|       `-- vga_timing_tb.sv
`-- tools
    |-- clean.sh
    |-- generate_bitstream.sh
    |-- get_errors.sh
    |-- open_vivado.sh
    |-- program_fpga.sh
    |-- run_simulation.sh
    |-- sim_cmd.tcl
    `-- warning_summary.sh


```
