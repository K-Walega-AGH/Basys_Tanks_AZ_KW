/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw RECTANGE.
 */

 module draw_rect_image 
#(
    parameter N_buf = 2,
    parameter WIDTH,
    parameter HEIGHT
)(
    input  logic clk,
    input  logic rst,

    input   logic   [11:0] xpos,
    input   logic   [11:0] ypos,

    input   logic   [11:0] rgb_pixel,
    output  logic   [19:0] pixel_addr,

    vga_if.in_m     rect_image_in,
    vga_if.out_m    rect_image_out    // has to be delayed
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;


/**
 * Local variables and signals
 */

logic [11:0] rgb_nxt;
logic [19:0] pixel_nxt;
logic [11:0] local_x, local_y;
logic [11:0] d_xpos, d_ypos;

vga_if  d_rect_image_in();

/**
 * Internal logic
 */

always_ff @(posedge clk) begin : rect_ff_blk
    if (rst) begin
        rect_image_out.vcount <= '0;
        rect_image_out.vsync  <= '0;
        rect_image_out.vblnk  <= '0;
        rect_image_out.hcount <= '0;
        rect_image_out.hsync  <= '0;
        rect_image_out.hblnk  <= '0;
        rect_image_out.rgb    <= '0;
        pixel_addr            <= '0;
    end else begin
        // output after N_buf-th delay
        rect_image_out.vcount <= d_rect_image_in.vcount;
        rect_image_out.vsync  <= d_rect_image_in.vsync;
        rect_image_out.vblnk  <= d_rect_image_in.vblnk;
        rect_image_out.hcount <= d_rect_image_in.hcount;
        rect_image_out.hsync  <= d_rect_image_in.hsync;
        rect_image_out.hblnk  <= d_rect_image_in.hblnk;
        rect_image_out.rgb    <= rgb_nxt;
        pixel_addr            <= pixel_nxt; // {[5:0] ypos, [5:0] xpos}
    end
end : rect_ff_blk

always_comb begin : rect_comb_blk
    if (d_rect_image_in.vblnk || d_rect_image_in.hblnk) begin             // Blanking region:
        rgb_nxt = d_rect_image_in.rgb;                  // - make it BACKGROUND.
        pixel_nxt = '0;
    end else begin                              // Active region:
        // draw rectangle
        local_y = rect_image_in.vcount - ypos;
        local_x = rect_image_in.hcount - xpos;
        pixel_nxt = {local_y[9:0], local_x[9:0]};   // [9:0] for 1024x1024
        if (d_rect_image_in.hcount >= d_xpos && d_rect_image_in.hcount < (d_xpos + WIDTH)      // horizontal limits
        && d_rect_image_in.vcount >= d_ypos && d_rect_image_in.vcount < (d_ypos + HEIGHT))     // vertical limits
        begin
            rgb_nxt = rgb_pixel;                // IMAGE RGB
        end else begin                          // The rest of active display pixels:
            rgb_nxt = d_rect_image_in.rgb;              // - fill with BACKGROUND.
        end
    end
end : rect_comb_blk

// modules for delayed signals

delay #(.WIDTH(11), .CLK_DEL(N_buf)) d_vcount (
    .clk(clk),
    .rst(rst),
    .din(rect_image_in.vcount),
    .dout(d_rect_image_in.vcount)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_vsync (
    .clk(clk),
    .rst(rst),
    .din(rect_image_in.vsync),
    .dout(d_rect_image_in.vsync)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_vblnk (
    .clk(clk),
    .rst(rst),
    .din(rect_image_in.vblnk),
    .dout(d_rect_image_in.vblnk)
);

delay #(.WIDTH(11), .CLK_DEL(N_buf)) d_hcount (
    .clk(clk),
    .rst(rst),
    .din(rect_image_in.hcount),
    .dout(d_rect_image_in.hcount)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_hsync (
    .clk(clk),
    .rst(rst),
    .din(rect_image_in.hsync),
    .dout(d_rect_image_in.hsync)
);
delay #(.WIDTH(1), .CLK_DEL(N_buf)) d_hblnk (
    .clk(clk),
    .rst(rst),
    .din(rect_image_in.hblnk),
    .dout(d_rect_image_in.hblnk)
);
delay #(.WIDTH(12), .CLK_DEL(N_buf)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(rect_image_in.rgb),
    .dout(d_rect_image_in.rgb)
);
delay #(.WIDTH(12), .CLK_DEL(N_buf)) d_xpos_inst (
    .clk(clk),
    .rst(rst),
    .din(xpos),
    .dout(d_xpos)
);
delay #(.WIDTH(12), .CLK_DEL(N_buf)) d_ypos_inst (
    .clk(clk),
    .rst(rst),
    .din(ypos),
    .dout(d_ypos)
);

endmodule
