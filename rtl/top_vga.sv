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

    // VGA signals from rectangle
    vga_if vga_rect_char();

    // VGA signals from rectangle
    vga_if vga_rect();

    // VGA signals from mouse
    vga_if vga_mouse();

    // xpos, ypos signals
    logic [11:0] rect_xpos, rect_ypos;
    // agh image on mouse
    logic [11:0] rgb_pixel;
    logic [11:0] pixel_addr;
    // mouse
    logic [11:0] mouse_xpos, mouse_ypos;
    logic left;
    // font stuff
    logic [10:0] addr;
    logic [7:0] char_xy;
    logic [6:0] char_code;
    logic [3:0] char_line;
    logic [7:0] char_line_pixels;

    assign addr = {char_code, char_line};

    /**
     * Signals assignments
     */
    assign vs = vga_mouse.vsync;
    assign hs = vga_mouse.hsync;
    assign {r,g,b} = vga_mouse.rgb;

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

        .rect_char_in    (vga_bg),
        .rect_char_out   (vga_rect_char)
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

    MouseCtl u_MouseCtl(
        .clk(clk100MHz),
        .rst(rst),
        .value(12'b0),
        .setx(1'b0),
        .sety(1'b0),
        .setmax_x(1'b0),
        .setmax_y(1'b0),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(mouse_xpos),
        .ypos(mouse_ypos),
        .left(left)
    );

    draw_rect_ctl u_draw_rect_ctl(
        .clk(clk),
        .rst(rst),
        .xpos_in(mouse_xpos),
        .ypos_in(mouse_ypos),
        .left(left),
    
        .xpos_out(rect_xpos),
        .ypos_out(rect_ypos)
    );

    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(48),
        .HEIGHT(64)
    ) u_draw_rect (
        .clk(clk),
        .rst(rst),

        .xpos(rect_xpos),
        .ypos(rect_ypos),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),


        .rect_image_in    (vga_rect_char),
        .rect_image_out   (vga_rect)
    );

    image_rom u_image_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[5:0], addrx[5:0]}
        .rgb(rgb_pixel)
    );

    draw_mouse u_draw_mouse (
        .clk(clk),
        .rst(rst),

        .xpos(mouse_xpos),
        .ypos(mouse_ypos),

        .mouse_in    (vga_rect),
        
        .mouse_out   (vga_mouse)
    );

endmodule
