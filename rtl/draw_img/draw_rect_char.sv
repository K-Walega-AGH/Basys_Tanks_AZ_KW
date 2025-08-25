/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw RECTANGE.
 */

 module draw_rect_char 
    #(
    parameter N_buf = 2,
    parameter XPOS = 0,
    parameter YPOS = 0,
    parameter TEXT_COLOR = 12'hf_f_f,   //white
    parameter BG_COLOR = 12'h0_0_0,     //black
    // !!! AMOUNTS ONLY IN POWER OF 2 !!!
    parameter AMOUNT_OF_LETTERS = 32,
    parameter AMOUNT_OF_LINES = 8
    ) (
    input  logic clk,
    input  logic rst,

    input  logic          toggle_colors,
    input  logic    [5:0] used_lines,
    input  logic    [7:0] char_line_pixels,
    output logic   [14:0] char_xy,
    output logic    [3:0] char_line,

    vga_if.in_m     rect_char_in,
    vga_if.out_m    rect_char_out    // has to be delayed
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local variables and signals
 */

localparam MESS_WIDTH = WIDTH_CHAR*AMOUNT_OF_LETTERS;
localparam MESS_HEIGHT = HEIGHT_CHAR*AMOUNT_OF_LINES;

vga_if  d_rect_char_in();

logic [11:0] rgb_nxt;
logic [14:0] char_xy_nxt;
logic  [3:0] char_line_nxt;
logic  [2:0] char_pixel_index;
logic [10:0] local_x, local_y;
// line ctr dependant of amount of lines needed
logic [$clog2(AMOUNT_OF_LINES):0] line_ctr;

/**
 * Internal logic
 */

always_ff @(posedge clk) begin : rect_char_ff_blk
    if (rst) begin
        rect_char_out.vcount <= '0;
        rect_char_out.vsync  <= '0;
        rect_char_out.vblnk  <= '0;
        rect_char_out.hcount <= '0;
        rect_char_out.hsync  <= '0;
        rect_char_out.hblnk  <= '0;
        rect_char_out.rgb    <= '0;
        char_xy              <= '0;
        char_line            <= '0;
    end else begin
        // output after N_buf-th delay
        rect_char_out.vcount <= d_rect_char_in.vcount;
        rect_char_out.vsync  <= d_rect_char_in.vsync;
        rect_char_out.vblnk  <= d_rect_char_in.vblnk;
        rect_char_out.hcount <= d_rect_char_in.hcount;
        rect_char_out.hsync  <= d_rect_char_in.hsync;
        rect_char_out.hblnk  <= d_rect_char_in.hblnk;
        rect_char_out.rgb    <= rgb_nxt;
        char_xy              <= char_xy_nxt;
        char_line            <= char_line_nxt;
    end
end : rect_char_ff_blk

always_comb begin : rect_char_comb_blk
    // draw rectangle
    if (d_rect_char_in.hcount >= XPOS && d_rect_char_in.hcount <= (XPOS + MESS_WIDTH)      // horizontal limits
    && d_rect_char_in.vcount >= YPOS && d_rect_char_in.vcount <= (YPOS + MESS_HEIGHT))      // vertical limits
    begin
        local_x = d_rect_char_in.hcount - XPOS;
        local_y = d_rect_char_in.vcount - YPOS;
        line_ctr = local_y[$clog2(HEIGHT_CHAR)+$clog2(AMOUNT_OF_LINES):$clog2(HEIGHT_CHAR)];    //dla znakow: 0..31 -> 0 ; 32..63 -> 1 ; itd

        if(line_ctr < used_lines) begin
            char_xy_nxt   = local_x[10:3] + line_ctr*AMOUNT_OF_LETTERS;
            char_line_nxt = local_y[3:0];

            char_pixel_index = ~(local_x[2:0]) + N_buf;    // HAVE TO negate bcs font_rom starts from LSB ; include delay

            if(char_line_pixels[char_pixel_index]) begin
                if(!toggle_colors)
                    rgb_nxt = TEXT_COLOR;  // text color
                    else
                    rgb_nxt = BG_COLOR;    // background color
            end else begin
                if(!toggle_colors)
                    rgb_nxt = BG_COLOR;    // background color
                else
                    rgb_nxt = TEXT_COLOR;  // text color
            end
        end else begin
            rgb_nxt = BG_COLOR;        // background color
            char_xy_nxt   = '0;
            char_line_nxt = '0;
        end
    end else begin                          // The rest of active display pixels:
        rgb_nxt = rect_char_in.rgb;              // - fill with BACKGROUND.
        char_xy_nxt   = '0;
        char_line_nxt = '0;
        line_ctr      = '0;
    end
end : rect_char_comb_blk


// modules for delayed signals

delay #(.WIDTH(11), .CLK_DEL(N_buf)) d_vcount (
    .clk(clk),
    .rst(rst),
    .din(rect_char_in.vcount),
    .dout(d_rect_char_in.vcount)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_vsync (
    .clk(clk),
    .rst(rst),
    .din(rect_char_in.vsync),
    .dout(d_rect_char_in.vsync)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_vblnk (
    .clk(clk),
    .rst(rst),
    .din(rect_char_in.vblnk),
    .dout(d_rect_char_in.vblnk)
);

delay #(.WIDTH(11), .CLK_DEL(N_buf)) d_hcount (
    .clk(clk),
    .rst(rst),
    .din(rect_char_in.hcount),
    .dout(d_rect_char_in.hcount)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_hsync (
    .clk(clk),
    .rst(rst),
    .din(rect_char_in.hsync),
    .dout(d_rect_char_in.hsync)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_hblnk (
    .clk(clk),
    .rst(rst),
    .din(rect_char_in.hblnk),
    .dout(d_rect_char_in.hblnk)
);
delay #(.WIDTH(12), .CLK_DEL(N_buf)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(rect_char_in.rgb),
    .dout(d_rect_char_in.rgb)
);

endmodule
