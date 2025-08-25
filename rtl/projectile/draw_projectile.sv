/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_projectile (
        input  logic clk,
        input  logic rst,
        
        input  logic show_bullet,
        
        input  logic [11:0] projectile_xpos,
        input  logic [11:0] projectile_ypos,

        vga_if.in_m         projectile_in,
        vga_if.out_m        projectile_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import projectile_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt, projectile_in_d_rgb;
    logic [19:0] pixel_addr;
    logic [11:0] rgb_pixel;

    vga_if vga_image_projectile();

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : tank_ff_blk
        if (rst) begin
            projectile_out.vcount <= '0;
            projectile_out.vsync  <= '0;
            projectile_out.vblnk  <= '0;
            projectile_out.hcount <= '0;
            projectile_out.hsync  <= '0;
            projectile_out.hblnk  <= '0;
            projectile_out.rgb    <= '0;
        end else begin
            projectile_out.vcount <= vga_image_projectile.vcount;
            projectile_out.vsync  <= vga_image_projectile.vsync;
            projectile_out.vblnk  <= vga_image_projectile.vblnk;
            projectile_out.hcount <= vga_image_projectile.hcount;
            projectile_out.hsync  <= vga_image_projectile.hsync;
            projectile_out.hblnk  <= vga_image_projectile.hblnk;
            projectile_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : tank_comb_blk
        if(show_bullet) begin
            if(vga_image_projectile.rgb == 12'hf_f_f) begin
                rgb_nxt = projectile_in_d_rgb;        // - fill with BACKGROUND
            end else begin
                rgb_nxt = vga_image_projectile.rgb;   // - fill with IMAGE
            end
        end else begin
            rgb_nxt = projectile_in_d_rgb;            // - fill with BACKGROUND
        end
    end

// draw_rect_image module for background generation from file
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(PROJECTILE_RADIUS),
        .HEIGHT(PROJECTILE_RADIUS)
    ) projectile_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(projectile_xpos),
        .ypos(projectile_ypos),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),
        
        .rect_image_in    (projectile_in),
        .rect_image_out   (vga_image_projectile)
    );
    projectile_rom u_projectile_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel)
    );
    // delay bg to match image
    delay #(.WIDTH(12), .CLK_DEL(3)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(projectile_in.rgb),
    .dout(projectile_in_d_rgb)
    );

endmodule
