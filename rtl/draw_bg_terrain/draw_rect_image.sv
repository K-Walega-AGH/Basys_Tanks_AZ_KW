/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw RECTANGE.
 */

 module draw_rect #(parameter N_buf = 2)(
    input  logic clk,
    input  logic rst,

    input   logic   [11:0] xpos,
    input   logic   [11:0] ypos,

    input   logic   [11:0] rgb_pixel,
    output  logic   [11:0] pixel_addr,

    vga_if.in_m     rect_in,
    vga_if.out_m    rect_out    // has to be delayed
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;


/**
 * Local variables and signals
 */

logic [11:0] rgb_nxt;
logic [11:0] pixel_nxt;

logic [11:0] vcount_buf [N_buf-1:0];
logic        vsync_buf  [N_buf-1:0];
logic        vblnk_buf  [N_buf-1:0];
logic [11:0] hcount_buf [N_buf-1:0];
logic        hsync_buf  [N_buf-1:0];
logic        hblnk_buf  [N_buf-1:0];
logic [11:0] xpos_buf   [N_buf-1:0];
logic [11:0] ypos_buf   [N_buf-1:0];

logic [11:0] local_x, local_y;


import vga_pkg::*;

/**
 * Internal logic
 */

always_ff @(posedge clk) begin : rect_ff_blk
    if (rst) begin
        vcount_buf <= '{default: '0};
        vsync_buf  <= '{default: '0};
        vblnk_buf  <= '{default: '0};
        hcount_buf <= '{default: '0};
        hsync_buf  <= '{default: '0};
        hblnk_buf  <= '{default: '0};
        ypos_buf   <= '{default: '0};
        xpos_buf   <= '{default: '0};

        rect_out.vcount <= '0;
        rect_out.vsync  <= '0;
        rect_out.vblnk  <= '0;
        rect_out.hcount <= '0;
        rect_out.hsync  <= '0;
        rect_out.hblnk  <= '0;
        rect_out.rgb    <= '0;
        pixel_addr      <= '0;
    end else begin
        // delay by N_buf clk cycles
        if(N_buf > 1) begin
            vcount_buf <= {vcount_buf[N_buf-2:0], rect_in.vcount};
            vsync_buf  <= {vsync_buf[N_buf-2:0],  rect_in.vsync};
            vblnk_buf  <= {vblnk_buf[N_buf-2:0],  rect_in.vblnk};
            hcount_buf <= {hcount_buf[N_buf-2:0], rect_in.hcount};
            hsync_buf  <= {hsync_buf[N_buf-2:0],  rect_in.hsync};
            hblnk_buf  <= {hblnk_buf[N_buf-2:0],  rect_in.hblnk};
            ypos_buf   <= {ypos_buf[N_buf-2:0],  ypos};
            xpos_buf   <= {xpos_buf[N_buf-2:0],  xpos};
            
        end else begin
            vcount_buf[0] <= rect_in.vcount;
            vsync_buf[0]  <= rect_in.vsync;
            vblnk_buf[0]  <= rect_in.vblnk;
            hcount_buf[0] <= rect_in.hcount;
            hsync_buf[0]  <= rect_in.hsync;
            hblnk_buf[0]  <= rect_in.hblnk;
            xpos_buf[0]   <= xpos;
            ypos_buf[0]   <= ypos;
        end
        // output after N_buf-th delay
        rect_out.vcount <= vcount_buf[N_buf-1];
        rect_out.vsync  <= vsync_buf[N_buf-1];
        rect_out.vblnk  <= vblnk_buf[N_buf-1];
        rect_out.hcount <= hcount_buf[N_buf-1];
        rect_out.hsync  <= hsync_buf[N_buf-1];
        rect_out.hblnk  <= hblnk_buf[N_buf-1];
        rect_out.rgb    <= rgb_nxt;
        pixel_addr      <= pixel_nxt; // {[5:0] ypos, [5:0] xpos}
    end
end : rect_ff_blk

always_comb begin : rect_comb_blk
    if (vblnk_buf[N_buf-1] || hblnk_buf[N_buf-1]) begin             // Blanking region:
        rgb_nxt = rect_in.rgb;                  // - make it BACKGROUND.
        pixel_nxt = '0;
    end else begin                              // Active region:
        // draw rectangle
        if (hcount_buf[N_buf-1] >= xpos_buf[N_buf-1] && hcount_buf[N_buf-1] < (xpos_buf[N_buf-1] + WIDTH_HOR_X)      // horizontal limits
        && vcount_buf[N_buf-1] >= ypos_buf[N_buf-1] && vcount_buf[N_buf-1] < (ypos_buf[N_buf-1] + HEIGHT_VER_Y))     // vertical limits
        begin
            rgb_nxt = rgb_pixel;                // IMAGE RGB
            local_y = vcount_buf[N_buf-1] - ypos_buf[N_buf-1];
            local_x = hcount_buf[N_buf-1] - xpos_buf[N_buf-1] + N_buf;
            pixel_nxt = {local_y[5:0], local_x[5:0]};
        end else begin                          // The rest of active display pixels:
            rgb_nxt = rect_in.rgb;              // - fill with BACKGROUND.
            pixel_nxt = '0;
        end
    end
end : rect_comb_blk

endmodule
