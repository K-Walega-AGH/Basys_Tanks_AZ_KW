
module draw_explosion (
        input  logic clk,
        input  logic rst,
        
        input  logic [11:0] explosion_xpos,  
        input  logic [11:0] explosion_ypos,
        input  logic        show_animation,
        input  logic [2:0]  frame_index,

        vga_if.in_m     explosion_in,
        vga_if.out_m    explosion_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import projectile_pkg::*;

    /**
     * Local variables and signals
     */
    logic [11:0] rgb_nxt, explosion_in_d_rgb;
    logic [19:0] pixel_addr;
    logic [11:0] rgb_pixel;
    logic [11:0] rgb_pixel0, rgb_pixel1, rgb_pixel2, rgb_pixel3, rgb_pixel4, rgb_pixel5, rgb_pixel6, rgb_pixel7;

    vga_if vga_image_explosion();

    /**
     * Internal logic
     */
    always_ff @(posedge clk) begin : explosion_ff_blk
        if (rst) begin
            explosion_out.vcount <= '0;
            explosion_out.vsync  <= '0;
            explosion_out.vblnk  <= '0;
            explosion_out.hcount <= '0;
            explosion_out.hsync  <= '0;
            explosion_out.hblnk  <= '0;
            explosion_out.rgb    <= '0;
        end else begin
            explosion_out.vcount <= vga_image_explosion.vcount;
            explosion_out.vsync  <= vga_image_explosion.vsync;
            explosion_out.vblnk  <= vga_image_explosion.vblnk;
            explosion_out.hcount <= vga_image_explosion.hcount;
            explosion_out.hsync  <= vga_image_explosion.hsync;
            explosion_out.hblnk  <= vga_image_explosion.hblnk;
            explosion_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : explosion_comb_blk
        case(frame_index)
            3'd0: rgb_pixel = rgb_pixel0;
            3'd1: rgb_pixel = rgb_pixel1;
            3'd2: rgb_pixel = rgb_pixel2;
            3'd3: rgb_pixel = rgb_pixel3;
            3'd4: rgb_pixel = rgb_pixel4;
            3'd5: rgb_pixel = rgb_pixel5;
            3'd6: rgb_pixel = rgb_pixel6;
            3'd7: rgb_pixel = rgb_pixel7;
        endcase
        if(show_animation) begin
            if(vga_image_explosion.rgb == 12'hf_f_f) begin
                rgb_nxt = explosion_in_d_rgb;        // fill with BACKGROUND
            end else begin
                rgb_nxt = vga_image_explosion.rgb;   // fill with IMAGE  
            end
        end else begin
            rgb_nxt = explosion_in_d_rgb;        // fill with BACKGROUND
        end
    end

    // draw_rect_image module for explosion image
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(EXPLOSION_RADIUS),
        .HEIGHT(EXPLOSION_RADIUS)
    ) explosion_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(explosion_xpos),
        .ypos(explosion_ypos),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),
        
        .rect_image_in    (explosion_in),
        .rect_image_out   (vga_image_explosion)
    );

    // animation ROMs for explosion
    explosion_rom     
    #(
        .FRAME_INDEX(0)
    ) u_explosion0_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel0)
    );

    explosion_rom     
    #(
        .FRAME_INDEX(1)
    ) u_explosion1_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel1)
    );

    explosion_rom     
    #(
        .FRAME_INDEX(2)
    ) u_explosion2_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel2)
    );

    explosion_rom     
    #(
        .FRAME_INDEX(3)
    ) u_explosion3_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel3)
    );

    explosion_rom     
    #(
        .FRAME_INDEX(4)
    ) u_explosion4_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel4)
    );

    explosion_rom     
    #(
        .FRAME_INDEX(5)
    ) u_explosion5_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel5)
    );

    explosion_rom     
    #(
        .FRAME_INDEX(6)
    ) u_explosion6_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel6)
    );

    explosion_rom     
    #(
        .FRAME_INDEX(7)
    ) u_explosion7_rom ( 
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel7)
    );

    // delay background to match image
    delay #(.WIDTH(12), .CLK_DEL(3)) d_rgb (
        .clk(clk),
        .rst(rst),
        .din(explosion_in.rgb),
        .dout(explosion_in_d_rgb)
    );

endmodule
