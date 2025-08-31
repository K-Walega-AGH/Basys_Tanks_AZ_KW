/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_angle (
        input  logic clk,
        input  logic rst,
        
        input  logic  [7:0] angle,

        vga_if.in_m         angle_in,
        vga_if.out_m        angle_out
    );

    timeunit 1ns;
    timeprecision 1ps;
    
    import vga_pkg::*;
    import tank_pkg::*;
    import interface_pkg::*;

    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;
    logic [10:0] addr;
    logic [14:0]  char_xy;
    logic  [6:0]  char_code;
    logic  [3:0]  char_line;
    logic  [7:0]  char_line_pixels;
    logic  [5:0]  used_lines;

    vga_if vga_angle();

    // char_addr assignment
    assign addr = {char_code, char_line};

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin
        if (rst) begin
            angle_out.vcount <= '0;
            angle_out.vsync <= '0;
            angle_out.vblnk <= '0; 
            angle_out.hcount <= '0; 
            angle_out.hsync <= '0;
            angle_out.hblnk <= '0; 
            angle_out.rgb <= '0;
        end else begin
            angle_out.vcount <= vga_angle.vcount;
            angle_out.vsync  <= vga_angle.vsync;
            angle_out.vblnk  <= vga_angle.vblnk;
            angle_out.hcount <= vga_angle.hcount;
            angle_out.hsync  <= vga_angle.hsync;
            angle_out.hblnk  <= vga_angle.hblnk;
            angle_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin
        rgb_nxt = vga_angle.rgb;
    end

    draw_rect_char #(
        .N_buf(2),
        .XPOS(ANGLE_X),
        .YPOS(ANGLE_Y),
        .AMOUNT_OF_LETTERS(10),
        .AMOUNT_OF_LINES(1)
    ) u_draw_rect_char (
        .clk(clk),
        .rst(rst),
        .used_lines(used_lines),
        .char_line_pixels(char_line_pixels),
        .char_xy(char_xy),
        .char_line(char_line),
        .rect_char_in(angle_in),
        .rect_char_out(vga_angle)
    );
    angle_rom u_angle_rom (
        .angle(angle),
        .char_xy(char_xy),
        .char_code(char_code),
        .used_lines(used_lines)
    );
    font_rom u_font_rom (
        .clk(clk),
        .addr(addr),
        .char_line_pixels(char_line_pixels)
    );

endmodule
