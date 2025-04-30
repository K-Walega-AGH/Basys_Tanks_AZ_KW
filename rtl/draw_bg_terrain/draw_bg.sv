/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
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
            bg_out.vcount <= bg_in.vcount;
            bg_out.vsync  <= bg_in.vsync;
            bg_out.vblnk  <= bg_in.vblnk;
            bg_out.hcount <= bg_in.hcount;
            bg_out.hsync  <= bg_in.hsync;
            bg_out.hblnk  <= bg_in.hblnk;
            bg_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (bg_in.vblnk || bg_in.hblnk) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it it black.
        end else begin                              // Active region:
            if (bg_in.vcount == 0)                     // - top edge:
                rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
            else if (bg_in.vcount == VER_PIXELS - 1)   // - bottom edge:
                rgb_nxt = 12'hf_0_0;                // - - make a red line.
            else if (bg_in.hcount == 0)                // - left edge:
                rgb_nxt = 12'h0_f_0;                // - - make a green line.
            else if (bg_in.hcount == HOR_PIXELS - 1)   // - right edge:
                rgb_nxt = 12'h0_0_f;                // - - make a blue line.
            
            // Add your code here.
            else if ((bg_in.hcount >= 235 && bg_in.hcount <= 250 && bg_in.vcount >= 200 && bg_in.vcount <= 400) // horizontal_1
            || (bg_in.hcount >= 235 && bg_in.hcount <= 340 && bg_in.vcount >= 200 && bg_in.vcount <= 215)       // vertical_1
            || (bg_in.hcount >= 340 && bg_in.hcount <= 355 && bg_in.vcount >= 200 && bg_in.vcount <= 400)       // horizontal_2
            || (bg_in.hcount >= 235 && bg_in.hcount <= 340 && bg_in.vcount >= 290 && bg_in.vcount <= 305))      // vertical_2
                rgb_nxt = 12'hA_0_A;  // Letter A
            
            else if ((bg_in.hcount >= 400 && bg_in.hcount <= 520 && bg_in.vcount >= 200 && bg_in.vcount <= 215) // vertical_1
            || ( (bg_in.vcount + 2*bg_in.hcount >= 1185) && (bg_in.vcount + 2*bg_in.hcount <= 1255) 
            && bg_in.vcount >= 215 && bg_in.vcount <= 385)                                                // diagonal_1
            || (bg_in.hcount >= 400 && bg_in.hcount <= 520 && bg_in.vcount >= 385 && bg_in.vcount <= 400))      // vertical_2
                rgb_nxt = 12'hA_0_A;  // Letter Z

            else if ((bg_in.hcount - 580)*(bg_in.hcount - 580) + (bg_in.vcount - 395)*(bg_in.vcount - 395) <= 12*12)
                    rgb_nxt = 12'h0_0_0;  // Dot
                    
            else if ((bg_in.hcount - 380)*(bg_in.hcount - 380) + (bg_in.vcount - 250)*(bg_in.vcount - 250) <= 120*120)
                    rgb_nxt = 12'hD_D_D;  // Big Circle

            else                                    // The rest of active display pixels:
                rgb_nxt = 12'h8_8_8;                // - fill with gray.
        end
    end

endmodule
