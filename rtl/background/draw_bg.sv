/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input  logic clk,
        input  logic rst,

        vga_if.in_m     bg_in,
        vga_if.out_m    bg_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;
    logic [19:0] pixel_addr;
    logic [11:0] rgb_pixel;

    vga_if vga_image_bg();

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            bg_out.vcount <= '0;
            bg_out.vsync  <= '0;
            bg_out.vblnk  <= '0;
            bg_out.hcount <= '0;
            bg_out.hsync  <= '0;
            bg_out.hblnk  <= '0;
            bg_out.rgb    <= '0;
        end else begin
            bg_out.vcount <= vga_image_bg.vcount;
            bg_out.vsync  <= vga_image_bg.vsync;
            bg_out.vblnk  <= vga_image_bg.vblnk;
            bg_out.hcount <= vga_image_bg.hcount;
            bg_out.hsync  <= vga_image_bg.hsync;
            bg_out.hblnk  <= vga_image_bg.hblnk;
            bg_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (vga_image_bg.vblnk || vga_image_bg.hblnk) begin               // Blanking region:
            rgb_nxt = 12'h0_0_0;        // - make it it black.
        end else begin                                      // Active region:
            // all blue edges
            if (vga_image_bg.vcount == 0)                     // - top edge:
                rgb_nxt = 12'h0_0_f;
            else if (vga_image_bg.vcount == VER_PIXELS - 1)   // - bottom edge:
                rgb_nxt = 12'h0_0_f;
            else if (vga_image_bg.hcount == 0)                // - left edge:
                rgb_nxt = 12'h0_0_f;
            else if (vga_image_bg.hcount == HOR_PIXELS - 1)   // - right edge:
                rgb_nxt = 12'h0_0_f;

            else                                    // The rest of active display pixels:
                rgb_nxt = vga_image_bg.rgb;            // - fill with IMAGE
        end
    end

// draw_rect_image module for background generation from file
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(HOR_PIXELS-2),
        .HEIGHT(VER_PIXELS-2)
    ) bg_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(12'b1),
        .ypos(12'b1),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),
        
        .rect_image_in    (bg_in),
        .rect_image_out   (vga_image_bg)
    );
    bg_rom u_bg_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel)
    );

endmodule
