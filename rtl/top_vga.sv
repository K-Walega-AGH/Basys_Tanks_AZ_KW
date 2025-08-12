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
        output logic [3:0] b,
        output logic [7:0] sseg,
        output logic [3:0] an,
        output logic [15:11] led
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
    logic [1:0] moving, change_angle;
    logic fire_active, your_turn;
    // tank_move wires
    // logic [11:0] move_tank_to_draw_tank_xpos;
    // logic [11:0] move_tank_to_draw_tank_ypos;
    // ps2 signals for hex display
    logic [7:0] rx_data;
    logic read_data;
    // font stuff
    logic [10:0] addr;
    logic [7:0] char_xy;
    logic [6:0] char_code;
    logic [3:0] char_line;
    logic [7:0] char_line_pixels;

    /**
     * Signals assignments
     */
    assign vs = vga_char.vsync;
    assign hs = vga_char.hsync;
    assign {r,g,b} = vga_char.rgb;
    //char_addr assignment
    assign addr = {char_code, char_line};
    // led for debug
    assign led = {fire_active, change_angle[1:0], moving[1:0]};

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

        .rect_char_in    (vga_tank),
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

    tank u_tank_LEFT (
        .clk(clk),
        .rst(rst),

        .moving(moving),
        .change_angle(change_angle),
        .fire_active(fire_active),
        .your_turn(1'b1),

        .tank_in  (vga_terrain),
        .tank_out (vga_tank)
    );

    ps2_keyboard u_ps2_keyboard(
    .clk100MHz(clk100MHz),
    .clk60MHz(clk),
    .rst(rst),

    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),

    .moving(moving),
    .change_angle(change_angle),
    .fire_active(fire_active),

    .rx_data_out(rx_data),
    .read_data_out(read_data)
    );
    ps2_display u_ps2_display(
    .clk(clk),
    .rst(rst),

    .rx_data(rx_data),
    .read_data(read_data),

    .sseg(sseg),
    .an(an)
    );

endmodule
