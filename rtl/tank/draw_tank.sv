
module draw_tank 
    #(
        PLAYER_ID = 1
    )(
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
    logic [19:0] pixel_addr_L, pixel_addr_R;
    logic [11:0] rgb_pixel_L, rgb_pixel_R;

    vga_if vga_image_tank_L();
    vga_if vga_image_tank_R();

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
        end else begin
            tank_out.vcount <= vga_image_tank_L.vcount; //nie ma znaczenia L/R bo opoznione o tyle samo
            tank_out.vsync  <= vga_image_tank_L.vsync;
            tank_out.vblnk  <= vga_image_tank_L.vblnk;
            tank_out.hcount <= vga_image_tank_L.hcount;
            tank_out.hsync  <= vga_image_tank_L.hsync;
            tank_out.hblnk  <= vga_image_tank_L.hblnk;
            tank_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : tank_comb_blk
        if(vga_image_tank_L.rgb == 12'hf_f_f) begin
            rgb_nxt = tank_in_d_rgb;          // - fill with BACKGROUND
        end else begin
            if(PLAYER_ID == 1)
                rgb_nxt = vga_image_tank_L.rgb;   // - fill with IMAGE
            else
                rgb_nxt = vga_image_tank_R.rgb;   // - fill with IMAGE
        end
    end

    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(TANK_WIDTH),
        .HEIGHT(TANK_HEIGHT)
    ) tank_L_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(tank_xpos),
        .ypos(tank_ypos),

        .rgb_pixel(rgb_pixel_L),
        .pixel_addr(pixel_addr_L),
        
        .rect_image_in    (tank_in),
        .rect_image_out   (vga_image_tank_L)
    );
    tank_rom 
    #(
        .PLAYER_ID(PLAYER_ID)
    ) u_tank_L_rom ( 
        .clk(clk),
        .address(pixel_addr_L),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel_L)
    );
    draw_rect_image 
    #(
        .N_buf(2),
        .WIDTH(TANK_WIDTH),
        .HEIGHT(TANK_HEIGHT)
    ) tank_R_from_image (
        .clk(clk),
        .rst(rst),

        .xpos(tank_xpos),
        .ypos(tank_ypos),

        .rgb_pixel(rgb_pixel_R),
        .pixel_addr(pixel_addr_R),
        
        .rect_image_in    (tank_in),
        .rect_image_out   (vga_image_tank_R)
    );
    tank_rom 
    #(
        .PLAYER_ID(PLAYER_ID)
    ) u_tank_R_rom ( 
        .clk(clk),
        .address(pixel_addr_R),  // address = {addry[9:0], addrx[9:0]}
        .rgb(rgb_pixel_R)
    );
    // delay bg to match image
    delay #(.WIDTH(12), .CLK_DEL(3)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(tank_in.rgb),
    .dout(tank_in_d_rgb)
    );


endmodule
