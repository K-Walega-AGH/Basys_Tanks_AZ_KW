/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_if_bg (
        input  logic clk,
        input  logic rst,

        vga_if.in_m     if_bg_in,
        vga_if.out_m    if_bg_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import interface_pkg::*;
  

    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            if_bg_out.vcount <= '0;
            if_bg_out.vsync  <= '0;
            if_bg_out.vblnk  <= '0;
            if_bg_out.hcount <= '0;
            if_bg_out.hsync  <= '0;
            if_bg_out.hblnk  <= '0;
            if_bg_out.rgb    <= '0;
        end else begin
            if_bg_out.vcount <= if_bg_in.vcount;
            if_bg_out.vsync  <= if_bg_in.vsync;
            if_bg_out.vblnk  <= if_bg_in.vblnk;
            if_bg_out.hcount <= if_bg_in.hcount;
            if_bg_out.hsync  <= if_bg_in.hsync;
            if_bg_out.hblnk  <= if_bg_in.hblnk;
            if_bg_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : if_bg_comb_blk
        if((if_bg_in.vcount >= GRAY_BOX_INIT && if_bg_in.vcount < VER_PIXELS-1) 
        && (if_bg_in.hcount >= 1 && if_bg_in.hcount < HOR_PIXELS-1))
            rgb_nxt = 12'h3_3_3;            // - fill with GRAY
        else
            rgb_nxt = if_bg_in.rgb;
    end

endmodule
