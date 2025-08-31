/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_hp 
#(
    HP_X = 0,
    HP_Y = 0
)(
        input  logic clk,
        input  logic rst,

        input  logic  [1:0] hp,

        vga_if.in_m         hp_in,
        vga_if.out_m        hp_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import tank_pkg::*;
    import interface_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt, hp_in_d_rgb;
    logic [19:0] pixel_addr_1, pixel_addr_2, pixel_addr_3;
    logic [11:0] rgb_pixel_1, rgb_pixel_2, rgb_pixel_3;


    vga_if vga_image_hp_1();
    vga_if vga_image_hp_2();
    vga_if vga_image_hp_3();

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : tank_ff_blk
        if (rst) begin
            hp_out.vcount <= '0;
            hp_out.vsync  <= '0;
            hp_out.vblnk  <= '0;
            hp_out.hcount <= '0;
            hp_out.hsync  <= '0;
            hp_out.hblnk  <= '0;
            hp_out.rgb    <= '0;
        end else begin
            hp_out.vcount <= vga_image_hp_1.vcount;
            hp_out.vsync  <= vga_image_hp_1.vsync;
            hp_out.vblnk  <= vga_image_hp_1.vblnk;
            hp_out.hcount <= vga_image_hp_1.hcount;
            hp_out.hsync  <= vga_image_hp_1.hsync;
            hp_out.hblnk  <= vga_image_hp_1.hblnk;
            hp_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : tank_comb_blk
        case(hp)
            2'd0: rgb_nxt = hp_in_d_rgb;
            2'd1: rgb_nxt = (vga_image_hp_1.rgb == 12'hf_f_f) ? hp_in_d_rgb : vga_image_hp_1.rgb;
            2'd2: rgb_nxt = (vga_image_hp_2.rgb == 12'hf_f_f) ? hp_in_d_rgb : vga_image_hp_2.rgb;
            2'd3: rgb_nxt = (vga_image_hp_3.rgb == 12'hf_f_f) ? hp_in_d_rgb : vga_image_hp_3.rgb;
        endcase
    end

// draw_rect_image module for background generation from file
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(HP_ICON_WIDTH),
        .HEIGHT(HP_ICON_HEIGHT)
    ) hp_1_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(HP_X),
        .ypos(HP_Y),

        .rgb_pixel(rgb_pixel_1),
        .pixel_addr(pixel_addr_1),
        
        .rect_image_in    (hp_in),
        .rect_image_out   (vga_image_hp_1)
    );
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(2*HP_ICON_WIDTH),
        .HEIGHT(HP_ICON_HEIGHT)
    ) hp_2_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(HP_X),
        .ypos(HP_Y),

        .rgb_pixel(rgb_pixel_2),
        .pixel_addr(pixel_addr_2),
        
        .rect_image_in    (hp_in),
        .rect_image_out   (vga_image_hp_2)
    );
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(3*HP_ICON_WIDTH),
        .HEIGHT(HP_ICON_HEIGHT)
    ) hp_3_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(HP_X),
        .ypos(HP_Y),

        .rgb_pixel(rgb_pixel_3),
        .pixel_addr(pixel_addr_3),
        
        .rect_image_in    (hp_in),
        .rect_image_out   (vga_image_hp_3)
    );
    hp_rom u_hp_1_rom ( 
        .clk(clk),
        .address(pixel_addr_1),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel_1)
    );
    hp_rom u_hp_2_rom ( 
        .clk(clk),
        .address(pixel_addr_2),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel_2)
    );
    hp_rom u_hp_3_rom ( 
        .clk(clk),
        .address(pixel_addr_3),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel_3)
    );
    // delay bg to match image
    delay #(.WIDTH(12), .CLK_DEL(3)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(hp_in.rgb),
    .dout(hp_in_d_rgb)
    );

endmodule
