/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

 package vga_pkg;

    // Parameters for VGA Display 800 x 600 @ 60fps using a 40 MHz clock;
    localparam HOR_PIXELS = 800;
    localparam VER_PIXELS = 600;

    // Add VGA timing parameters here and refer to them in other modules.
    localparam TOTAL_HOR_PIXELS = 1056;
    localparam TOTAL_VER_PIXELS = 628;

    localparam HBLANK_START = 800;
    localparam HBLANK_TIME = 256;
    localparam HBLANK_END = HBLANK_START + HBLANK_TIME - 1;
    localparam VBLANK_START = 600;
    localparam VBLANK_TIME = 28;
    localparam VBLANK_END = VBLANK_START + VBLANK_TIME - 1;
    
    localparam HSYNC_START = 840;
    localparam HSYNC_TIME = 128;
    localparam HSYNC_END = HSYNC_START + HSYNC_TIME;
    localparam VSYNC_START = 601;
    localparam VSYNC_TIME = 4;
    localparam VSYNC_END = VSYNC_START + VSYNC_TIME;

    // draw_rect_image parameters
    //localparam POSITION_HOR_X = 300;
    localparam WIDTH_HOR_X = 48;
    //localparam POSITION_VER_Y = 50;
    localparam HEIGHT_VER_Y = 64;
    //localparam RECT_COLOR = 12'hF_0_0;

endpackage
