/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

 package vga_pkg;

    // Parameters for VGA Display 1024 x 768 @ 60fps using a 40 MHz clock;
    localparam HOR_PIXELS = 1024;       //800;
    localparam VER_PIXELS = 768;        //600;

    // Add VGA timing parameters here and refer to them in other modules.
    localparam TOTAL_HOR_PIXELS = 1344; //1056;
    localparam TOTAL_VER_PIXELS = 806;  //628;

    localparam HBLANK_START = 1024;     //800;
    localparam HBLANK_TIME = 320;       //256;
    localparam HBLANK_END = HBLANK_START + HBLANK_TIME - 1;
    localparam VBLANK_START = 768;      //600;
    localparam VBLANK_TIME = 38;        //28;
    localparam VBLANK_END = VBLANK_START + VBLANK_TIME - 1;
    
    localparam HSYNC_START = 1048;      //840;
    localparam HSYNC_TIME = 136;        //128;
    localparam HSYNC_END = HSYNC_START + HSYNC_TIME;
    localparam VSYNC_START = 771;       //601;
    localparam VSYNC_TIME = 6;          //4;
    localparam VSYNC_END = VSYNC_START + VSYNC_TIME;

    // draw_rect_image parameters
    //localparam POSITION_HOR_X = 300;
    localparam WIDTH_HOR_X = 48;
    //localparam POSITION_VER_Y = 50;
    localparam HEIGHT_VER_Y = 64;
    //localparam RECT_COLOR = 12'hF_0_0;

    // draw_rect_char parameters
    localparam WIDTH_CHAR = 8;
    localparam HEIGHT_CHAR = 16;

endpackage
