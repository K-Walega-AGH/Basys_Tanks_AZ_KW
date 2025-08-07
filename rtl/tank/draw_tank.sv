
module draw_tank (
        input  logic clk,
        input  logic rst,
        
        input  logic [11:0] tank_xpos,
        input  logic [11:0] tank_ypos,

        vga_if.in_m     tank_in,
        vga_if.out_m    tank_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import tank_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt, tank_in_d_rgb;
    logic [19:0] pixel_addr;
    logic [11:0] rgb_pixel;

    vga_if vga_image_tank();

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : tank_ff_blk
        if (rst) begin
            tank_out.vcount <= '0;
            tank_out.vsync  <= '0;
            tank_out.vblnk  <= '0;
            tank_out.hcount <= '0;
            tank_out.hsync  <= '0;
            tank_out.hblnk  <= '0;
            tank_out.rgb    <= '0;

            tank_in_d_rgb   <= '0;
        end else begin
            tank_out.vcount <= vga_image_tank.vcount;
            tank_out.vsync  <= vga_image_tank.vsync;
            tank_out.vblnk  <= vga_image_tank.vblnk;
            tank_out.hcount <= vga_image_tank.hcount;
            tank_out.hsync  <= vga_image_tank.hsync;
            tank_out.hblnk  <= vga_image_tank.hblnk;
            tank_out.rgb    <= rgb_nxt;

            tank_in_d_rgb   <= tank_in.rgb;     //delay rgb for 1 cycle for smooth background
        end
    end

    always_comb begin : tank_comb_blk
        if(vga_image_tank.rgb == 12'hf_f_f) begin
            rgb_nxt = tank_in_d_rgb;          // - fill with BACKGROUND
        end else begin
            rgb_nxt = vga_image_tank.rgb;   // - fill with IMAGE  
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

        .xpos(tank_xpos),
        .ypos(tank_ypos),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),
        
        .rect_image_in    (tank_in),
        .rect_image_out   (vga_image_tank)
    );
    tank_rom u_tank_rom ( 
        .clk(clk),
        .address(pixel_addr),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel)
    );

endmodule
