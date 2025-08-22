
module draw_barrel 
    #(
        PLAYER_ID = 1
    )(
        input  logic clk,
        input  logic rst,
        
        input  logic [11:0] barrel_xpos,  // barrel has the same x,y pos as tank
        input  logic [11:0] barrel_ypos,
        input  logic [2:0]  angle_index,

        vga_if.in_m     barrel_in,
        vga_if.out_m    barrel_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import tank_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt, barrel_in_d_rgb;
    logic [19:0] pixel_addr;
    logic [11:0] rgb_pixel;
    logic [11:0] rgb_pixel0, rgb_pixel1, rgb_pixel2, rgb_pixel3, rgb_pixel4, rgb_pixel5, rgb_pixel6, rgb_pixel7;

    vga_if vga_image_barrel();

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : tank_ff_blk
        if (rst) begin
            barrel_out.vcount <= '0;
            barrel_out.vsync  <= '0;
            barrel_out.vblnk  <= '0;
            barrel_out.hcount <= '0;
            barrel_out.hsync  <= '0;
            barrel_out.hblnk  <= '0;
            barrel_out.rgb    <= '0;
        end else begin
            barrel_out.vcount <= vga_image_barrel.vcount;
            barrel_out.vsync  <= vga_image_barrel.vsync;
            barrel_out.vblnk  <= vga_image_barrel.vblnk;
            barrel_out.hcount <= vga_image_barrel.hcount;
            barrel_out.hsync  <= vga_image_barrel.hsync;
            barrel_out.hblnk  <= vga_image_barrel.hblnk;
            barrel_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : barrel_comb_blk
        case(angle_index)
            3'd0: rgb_pixel = rgb_pixel0;
            3'd1: rgb_pixel = rgb_pixel1;
            3'd2: rgb_pixel = rgb_pixel2;
            3'd3: rgb_pixel = rgb_pixel3;
            3'd4: rgb_pixel = rgb_pixel4;
            3'd5: rgb_pixel = rgb_pixel5;
            3'd6: rgb_pixel = rgb_pixel6;
            3'd7: rgb_pixel = rgb_pixel7;
        endcase
        if(vga_image_barrel.rgb == 12'hf_f_f || vga_image_barrel.rgb == 12'hf_0_f) begin
            rgb_nxt = barrel_in_d_rgb;          // - fill with BACKGROUND
        end else begin
            rgb_nxt = vga_image_barrel.rgb;   // - fill with IMAGE  
        end
    end

// draw_rect_image module for background generation from file
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(TANK_WIDTH),
        .HEIGHT(TANK_HEIGHT)
    ) tank_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(barrel_xpos),
        .ypos(barrel_ypos),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),
        
        .rect_image_in    (barrel_in),
        .rect_image_out   (vga_image_barrel)
    );
    // animation roms
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(0)
    ) u_barrel0_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel0)
    );
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(1)
    ) u_barrel1_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel1)
    );
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(2)
    ) u_barrel2_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel2)
    );
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(3)
    ) u_barrel3_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel3)
    );
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(4)
    ) u_barrel4_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel4)
    );
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(5)
    ) u_barrel5_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel5)
    );
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(6)
    ) u_barrel6_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel6)
    );
    barrel_rom     
    #(
        .PLAYER_ID(PLAYER_ID),
        .ANGLE_INDEX(7)
    ) u_barrel7_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel7)
    );
    // delay bg to match image
    delay #(.WIDTH(12), .CLK_DEL(3)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(barrel_in.rgb),
    .dout(barrel_in_d_rgb)
    );

endmodule
