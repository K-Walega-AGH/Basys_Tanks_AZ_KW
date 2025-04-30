/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Define VGA interface with 7 inputs & 7 outputs.
 */

interface vga_if;
    // signals declaration
    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;
    logic [11:0] rgb;

    // modport IN
    modport in_m (
        input   hcount, hsync, hblnk, 
                vcount, vsync, vblnk, 
                rgb
    );

    // modport OUT
    modport out_m (
        output  hcount, hsync, hblnk,
                vcount, vsync, vblnk, 
                rgb
    );

endinterface