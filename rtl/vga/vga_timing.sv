/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Vga timing controller.
 */

 module vga_timing (
    input  logic clk,
    input  logic rst,
    output logic [10:0] vcount,
    output logic vsync,
    output logic vblnk,
    output logic [10:0] hcount,
    output logic hsync,
    output logic hblnk
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local variables and signals
 */

// Add your signals and variables here.

/**
 * Internal logic
 */

// Add your code here.

// HORIZONTAL & VERTICAL BLOCK
always_ff @(posedge clk) begin
    if (rst) begin
        hcount <= '0;
        hblnk <= '0;
        hsync <= '0;
        vcount <= '0;
        vblnk <= '0;
        vsync <= '0;
    end
    else begin
        if(hcount == (TOTAL_HOR_PIXELS - 1)) begin
            hcount <= '0;

            if(vcount == (TOTAL_VER_PIXELS - 1)) begin
                vcount <= '0;
            end
            else begin
                vcount <= vcount + 1;
            end

            // vertical_blank
            // logical AND of 2 conditions >___<
            vblnk <= ((vcount >= VBLANK_START - 1) && (vcount <= VBLANK_END - 1));
            // vertical_sync
            vsync <= ((vcount >= VSYNC_START - 1) && (vcount <= VSYNC_END - 1));
        end
        else begin
            hcount <= hcount + 1;
        end
        
        /* PRZYKLADOWE ROZWIAZANIE Z ZAJEC 13.03.2025 ; 20.03.2025
        if((hcount >= HBLANK_START - 1) && (hcount <= HBLANK_END - 1)) begin
            hblnk <= 1'b1;
        end
        else begin
            hblnk <= 1'b0;
        end
        */

        // horizontal_blank
        hblnk <= ((hcount >= HBLANK_START - 1) && (hcount <= HBLANK_END - 1));
        // horizontal_sync
        hsync <= ((hcount >= HSYNC_START - 1) && (hcount <= HSYNC_END - 1));
    end
end

endmodule
