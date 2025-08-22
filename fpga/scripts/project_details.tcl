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
    ../fpga/constraints/clk_wiz_0.xdc
    ../fpga/constraints/clk_wiz_0_late.xdc
    ../fpga/constraints/clk_wiz_1.xdc
    constraints/top_vga_basys3.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/vga/vga_if.sv
    ../rtl/vga/vga_pkg.sv
    ../rtl/tank/tank_pkg.sv
    ../rtl/projectile/projectile_pkg.sv
    ../rtl/delay.sv
    ../rtl/vga/vga_timing.sv
    ../rtl/ps2_keyboard/ps2_keyboard_latch.sv
    ../rtl/ps2_keyboard/ps2_keyboard_ctl.sv
    ../rtl/ps2_keyboard/ps2_keyboard.sv
    ../rtl/background/draw_bg.sv
    ../rtl/terrain/draw_terrain.sv
    ../rtl/terrain/terrain_pkg.sv
    ../rtl/interface/draw_if_bg.sv
    ../rtl/interface/draw_hp.sv
    ../rtl/interface/draw_strength.sv
    ../rtl/interface/draw_fuel.sv
    ../rtl/interface/draw_angle.sv
    ../rtl/interface/interface_pkg.sv
    ../rtl/interface/player_interface.sv
    ../rtl/draw_img/draw_param_text.sv
    ../rtl/draw_img/draw_rect_char.sv
    ../rtl/draw_img/draw_rect_image.sv
    ../rtl/draw_img/draw_rect_ctl.sv
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
    ../rtl/rom/help_rom.sv
    ../rtl/rom/text_rom.sv
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
    ../rtl/help/draw_help.sv
    ../rtl/ps2_display.sv
    ../rtl/top_vga_ctl.sv
    ../rtl/top_vga.sv
    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../fpga/rtl/clk_wiz_0.v
    ../fpga/rtl/clk_wiz_0_clk_wiz.v
    ../fpga/rtl/clk_wiz_1.v
    ../fpga/rtl/clk_wiz_1_clk_wiz.v
    ../rtl/disp_hex_mux.v
}

# Specify VHDL design files location            -- EDIT
set vhdl_files {
    ../rtl/ps2_keyboard/Ps2Interface.vhd
}

# Specify files for a memory initialization     -- EDIT
#set mem_files {
#
#}
