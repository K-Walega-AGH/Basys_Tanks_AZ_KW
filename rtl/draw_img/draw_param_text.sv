/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_param_text 
    #(
        parameter string TEXT = " ",
        parameter LINES = 1,
        parameter TEXT_X = 0,
        parameter TEXT_Y = 0
    )(
        input  logic clk,
        input  logic rst,

        vga_if.in_m         text_in,
        vga_if.out_m        text_out
    );

    timeunit 1ns;
    timeprecision 1ps;
    
    import vga_pkg::*;
    import tank_pkg::*;
    import interface_pkg::*;

    /**
     * Local variables and signals
     */

    localparam TEXT_LENGTH = $bits(TEXT)/8;
    
    logic [11:0] rgb_nxt;
    logic [10:0] addr;
    logic [14:0]  char_xy;
    logic  [6:0]  char_code;
    logic  [3:0]  char_line;
    logic  [7:0]  char_line_pixels;
    logic  [5:0]  used_lines;

    vga_if vga_text();

    // char_addr assignment
    assign addr = {char_code, char_line};

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin
        if (rst) begin
            text_out.vcount <= '0;
            text_out.vsync <= '0;
            text_out.vblnk <= '0; 
            text_out.hcount <= '0; 
            text_out.hsync <= '0;
            text_out.hblnk <= '0; 
            text_out.rgb <= '0;
        end else begin
            text_out.vcount <= vga_text.vcount;
            text_out.vsync  <= vga_text.vsync;
            text_out.vblnk  <= vga_text.vblnk;
            text_out.hcount <= vga_text.hcount;
            text_out.hsync  <= vga_text.hsync;
            text_out.hblnk  <= vga_text.hblnk;
            text_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin
        rgb_nxt = vga_text.rgb;
    end

    draw_rect_char #(
        .N_buf(2),
        .XPOS(TEXT_X),
        .YPOS(TEXT_Y),
        .AMOUNT_OF_LETTERS(TEXT_LENGTH),
        .AMOUNT_OF_LINES(LINES)
    ) u_draw_rect_char (
        .clk(clk),
        .rst(rst),
        .toggle_colors(1'b0),
        .used_lines(used_lines),
        .char_line_pixels(char_line_pixels),
        .char_xy(char_xy),
        .char_line(char_line),
        .rect_char_in(text_in),
        .rect_char_out(vga_text)
    );
    text_rom #(
        .TEXT(TEXT)
    ) u_text_rom (
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
