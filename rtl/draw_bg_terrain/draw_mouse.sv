/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw RECTANGE.
 */

 module draw_mouse (
    input  logic clk,
    input  logic rst,

    input   logic   [11:0] xpos,
    input   logic   [11:0] ypos,

    vga_if.in_m     mouse_in,
    vga_if.out_m    mouse_out
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;


/**
 * Local variables and signals
 */

logic [11:0] rgb_nxt;
logic blank;
logic [11:0] mouse_rgb;
/**
 * Internal logic
 */

assign blank = mouse_in.vblnk || mouse_in.hblnk;

MouseDisplay u_MouseDisplay (
    .pixel_clk(clk),
    .xpos(xpos),
    .ypos(ypos),
    .hcount(mouse_in.hcount),
    .vcount(mouse_in.vcount),
    .blank(blank),
    .rgb_in(mouse_in.rgb),
    .enable_mouse_display_out(),    //useless now
    .rgb_out(mouse_rgb)
);

always_ff @(posedge clk) begin : mouse_ff_blk
    if (rst) begin
        mouse_out.vcount <= '0;
        mouse_out.vsync  <= '0;
        mouse_out.vblnk  <= '0;
        mouse_out.hcount <= '0;
        mouse_out.hsync  <= '0;
        mouse_out.hblnk  <= '0;
        mouse_out.rgb    <= '0;
    end else begin
        mouse_out.vcount <= mouse_in.vcount;
        mouse_out.vsync  <= mouse_in.vsync;
        mouse_out.vblnk  <= mouse_in.vblnk;
        mouse_out.hcount <= mouse_in.hcount;
        mouse_out.hsync  <= mouse_in.hsync;
        mouse_out.hblnk  <= mouse_in.hblnk;
        mouse_out.rgb    <= rgb_nxt;
    end
end

always_comb begin : mouse_comb_blk
    rgb_nxt = mouse_rgb;
end

endmodule
