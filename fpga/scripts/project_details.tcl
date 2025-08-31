# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    ../fpga/constraints/clk_wiz_1.xdc
    constraints/top_vga_basys3.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/vga/vga_timing.sv
    ../rtl/vga/vga_if.sv
    ../rtl/delay/vga_if_delay.sv
    ../rtl/delay/delay.sv
    ../rtl/delay/sync_2xff.sv
    ../rtl/delay/sync_handshake.sv
    ../rtl/vga/vga_pkg.sv
    ../rtl/uart/uart_pkg.sv
    ../rtl/terrain/terrain_pkg.sv
    ../rtl/tank/tank_pkg.sv
    ../rtl/interface/interface_pkg.sv
    ../rtl/projectile/projectile_pkg.sv
    ../rtl/ps2_keyboard/ps2_keyboard_2xff.sv
    ../rtl/ps2_keyboard/ps2_keyboard_ctl.sv
    ../rtl/ps2_keyboard/ps2_keyboard.sv
    ../rtl/ps2_keyboard/ps2_display.sv
    ../rtl/ps2_keyboard/FF_15.sv
    ../rtl/uart/display_UART.sv
    ../rtl/uart/monitor_UART.sv
    ../rtl/uart/top_uart.sv
    ../rtl/draw_img/draw_param_text_blink.sv
    ../rtl/draw_img/draw_param_text.sv
    ../rtl/draw_img/draw_rect_char.sv
    ../rtl/draw_img/draw_rect_image.sv
    ../rtl/draw_img/draw_rect_ctl.sv
    ../rtl/ram/terrain_ram.sv
    ../rtl/rom/char_rom.sv
    ../rtl/rom/font_rom.sv
    ../rtl/rom/image_rom.sv
    ../rtl/rom/bg_rom.sv
    ../rtl/rom/border_str_rom.sv
    ../rtl/rom/border_fuel_rom.sv
    ../rtl/rom/hp_rom.sv
    ../rtl/rom/angle_rom.sv
    ../rtl/rom/tank_rom.sv
    ../rtl/rom/barrel_rom.sv
    ../rtl/rom/projectile_rom.sv
    ../rtl/rom/photo_tanks_rom.sv
    ../rtl/rom/explosion_rom.sv
    ../rtl/rom/help_rom.sv
    ../rtl/rom/text_rom.sv
    ../rtl/background/draw_bg.sv
    ../rtl/terrain/draw_terrain.sv
    ../rtl/terrain/terrain_destruction.sv
    ../rtl/terrain/terrain.sv
    ../rtl/interface/draw_if_bg.sv
    ../rtl/interface/draw_hp.sv
    ../rtl/interface/draw_strength.sv
    ../rtl/interface/draw_fuel.sv
    ../rtl/interface/draw_angle.sv
    ../rtl/interface/player_interface.sv
    ../rtl/tank/draw_tank.sv
    ../rtl/tank/tank_ctl.sv
    ../rtl/tank/tank_move.sv
    ../rtl/tank/draw_barrel.sv
    ../rtl/tank/barrel_ctl.sv
    ../rtl/tank/barrel.sv
    ../rtl/tank/tank.sv
    ../rtl/projectile/draw_projectile.sv
    ../rtl/projectile/projectile_ctl.sv
    ../rtl/projectile/projectile.sv
    ../rtl/projectile/sin_lut.sv
    ../rtl/projectile/cos_lut.sv
    ../rtl/projectile/draw_explosion.sv
    ../rtl/projectile/explosion_ctl.sv
    ../rtl/projectile/explosion.sv
    ../rtl/help/draw_help.sv
    ../rtl/1_start_screen/draw_tanks_photo.sv
    ../rtl/1_start_screen/start_screen_ctl.sv
    ../rtl/1_start_screen/start_screen.sv
    ../rtl/2_main_game/main_game_ctl.sv
    ../rtl/2_main_game/main_game.sv
    ../rtl/3_end_screen/end_screen_ctl.sv
    ../rtl/3_end_screen/end_screen.sv
    ../rtl/top_vga_ctl.sv
    ../rtl/top_vga.sv
    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../fpga/rtl/clk_wiz_1.v
    ../fpga/rtl/clk_wiz_1_clk_wiz.v
    ../rtl/uart/lab6_files/flag_buf.v
    ../rtl/uart/lab6_files/debounce.v
    ../rtl/uart/lab6_files/fifo.v
    ../rtl/uart/lab6_files/mod_m_counter.v
    ../rtl/uart/lab6_files/uart_tx.v
    ../rtl/uart/lab6_files/uart_rx.v
    ../rtl/uart/lab6_files/uart.v
    ../rtl/uart/lab6_files/disp_hex_mux.v
    
}

# Specify VHDL design files location            -- EDIT
set vhdl_files {
    ../rtl/ps2_keyboard/Ps2Interface.vhd
}

# Specify files for a memory initialization     -- EDIT
#set mem_files {
#
#}
