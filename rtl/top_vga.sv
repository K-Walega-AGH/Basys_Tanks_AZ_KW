/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

module top_vga (
        input  logic clk,
        input  logic rst,
        input  logic clk100MHz,
        inout  logic ps2_clk,
        inout  logic ps2_data,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    // VGA signals from timing
    vga_if vga_timing();
    // VGA signals from background
    vga_if vga_bg();
    // VGA signals from background
    vga_if vga_terrain();
    // VGA signals from display characters
    vga_if vga_char();
    // VGA signals from tank
    vga_if vga_tank();

    // // VGA signals from rectangle
    // vga_if vga_rect();

    // // VGA signals from mouse
    // vga_if vga_mouse();

    // tank movement and action
    logic [11:0] tank_xpos, tank_ypos;
    logic [1:0] moving;
    logic fire_active, your_turn;
    // tank_move wires
    // logic [11:0] move_tank_to_draw_tank_xpos;
    // logic [11:0] move_tank_to_draw_tank_ypos;
    // font stuff
    logic [10:0] addr;
    logic [7:0] char_xy;
    logic [6:0] char_code;
    logic [3:0] char_line;
    logic [7:0] char_line_pixels;

    /**
     * Signals assignments
     */
    assign vs = vga_tank.vsync;
    assign hs = vga_tank.hsync;
    assign {r,g,b} = vga_tank.rgb;
    //char_addr assignment
    assign addr = {char_code, char_line};

    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .vcount (vga_timing.vcount),
        .vsync  (vga_timing.vsync),
        .vblnk  (vga_timing.vblnk),
        .hcount (vga_timing.hcount),
        .hsync  (vga_timing.hsync),
        .hblnk  (vga_timing.hblnk)
    );

    draw_bg u_draw_bg (
        .clk(clk),
        .rst(rst),

        .bg_in  (vga_timing),
        .bg_out (vga_bg)
    );

    draw_terrain u_draw_terrain (
        .clk(clk),
        .rst(rst),

        .terrain_in  (vga_bg),
        .terrain_out (vga_terrain)
    );

    draw_rect_char 
        #(
        .N_buf(2),
        .XPOS(272),
        .YPOS(460)
        ) u_draw_rect_char (
        .clk(clk),
        .rst(rst),

        .char_line_pixels(char_line_pixels),
        .char_xy(char_xy),
        .char_line(char_line),

        .rect_char_in    (vga_terrain),
        .rect_char_out   (vga_char)
    );

    char_rom u_char_rom (
        .char_xy(char_xy),
        .char_code(char_code)
    );

    font_rom u_font_rom (
        .clk(clk),
        .addr(addr),
        .char_line_pixels(char_line_pixels)
    );


    draw_tank u_draw_tank (
        .clk(clk),
        .rst(rst),

        .tank_xpos(tank_xpos),
        .tank_ypos(tank_ypos),

        .tank_in  (vga_char),
        .tank_out (vga_tank)
    );
    tank_ctl u_tank_ctl(
        .clk(clk),
        .rst(rst),
    
        .moving(moving),
        .fire_active(fire_active),
        .your_turn(your_turn),
    
        .tank_xpos(tank_xpos),
        .tank_ypos(tank_ypos)
    );
    tank_move u_tank_move(
        .clk(clk),
        .rst(rst),
        
        .tank_xpos_in(tank_xpos),
        .tank_ypos_in(tank_ypos),

        .tank_xpos_out(),   //this outpur will go to draw_tank ; disconected for now
        .tank_ypos_out()
    );

endmodule
