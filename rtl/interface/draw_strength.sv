/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_strength (
        input  logic clk,
        input  logic rst,
        
        input  logic [10:0] projectile_strength,

        vga_if.in_m         strength_in,
        vga_if.out_m        strength_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import tank_pkg::*;
    import interface_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt, strength_in_d_rgb;
    logic [19:0] pixel_addr;
    logic [11:0] rgb_pixel;
    // bar_width scaled for a sec to Q10.12 to reduce math operation (timing violation)
    logic [21:0] bar_width_temp;
    logic [10:0] bar_width;
    logic [11:0] bar_left, bar_right;   //change bits in case of different bar size
    // strength to bar variables
    localparam logic [10:0] BAR_MAX_WIDTH = BORDER_STR_WIDTH - 6;
    localparam BAR_SCALE_SHIFT = 12;
    localparam BAR_SCALE_CONST = (BAR_MAX_WIDTH << BAR_SCALE_SHIFT) / MAX_STRENGTH;

    vga_if vga_image_strength();

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : tank_ff_blk
        if (rst) begin
            strength_out.vcount <= '0;
            strength_out.vsync  <= '0;
            strength_out.vblnk  <= '0;
            strength_out.hcount <= '0;
            strength_out.hsync  <= '0;
            strength_out.hblnk  <= '0;
            strength_out.rgb    <= '0;
        end else begin
            strength_out.vcount <= vga_image_strength.vcount;
            strength_out.vsync  <= vga_image_strength.vsync;
            strength_out.vblnk  <= vga_image_strength.vblnk;
            strength_out.hcount <= vga_image_strength.hcount;
            strength_out.hsync  <= vga_image_strength.hsync;
            strength_out.hblnk  <= vga_image_strength.hblnk;
            strength_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : strength_comb_blk
        if(vga_image_strength.rgb == 12'hf_f_f) begin
            rgb_nxt = strength_in_d_rgb;        // - fill with BACKGROUND
        end else begin
            rgb_nxt = vga_image_strength.rgb;   // - fill with IMAGE
        end
        // --- strength bar calculation ---
        // scale projectile_strength to bar to bar_width
	    bar_width_temp = projectile_strength * BAR_SCALE_CONST;
        bar_width = bar_width_temp >> BAR_SCALE_SHIFT;
        if (bar_width > BAR_MAX_WIDTH) begin
            bar_width = BAR_MAX_WIDTH;
        end
        // bar border values
        bar_left  = STRENGTH_X + BORDER_STR_OFFSET;
        bar_right = bar_left + bar_width;

        // Fill border inside, offset = 3px
        if ( (vga_image_strength.hcount >= STRENGTH_X + BORDER_STR_OFFSET) &&
             (vga_image_strength.hcount <  STRENGTH_X + BORDER_STR_WIDTH  - BORDER_STR_OFFSET) &&
             (vga_image_strength.vcount >= STRENGTH_Y + BORDER_STR_OFFSET) &&
             (vga_image_strength.vcount <  STRENGTH_Y + BORDER_STR_HEIGHT - BORDER_STR_OFFSET) ) begin

            if ( (vga_image_strength.hcount >= bar_left) &&
                 (vga_image_strength.hcount < bar_right) ) begin
                rgb_nxt = 12'hF00;  // color of the bar
            end
        end
    end

// draw_rect_image module for background generation from file
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(BORDER_STR_WIDTH),
        .HEIGHT(BORDER_STR_HEIGHT)
    ) border_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(STRENGTH_X),
        .ypos(STRENGTH_Y),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),
        
        .rect_image_in    (strength_in),
        .rect_image_out   (vga_image_strength)
    );
    border_str_rom u_border_str_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel)
    );
    // delay bg to match image
    delay #(.WIDTH(12), .CLK_DEL(3)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(strength_in.rgb),
    .dout(strength_in_d_rgb)
    );

endmodule
