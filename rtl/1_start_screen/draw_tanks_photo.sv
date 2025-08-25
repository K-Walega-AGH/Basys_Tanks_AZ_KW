module draw_tanks_photo #(
        parameter SCALE_SHIFT = 1,
        parameter XPOS = 1,
        parameter YPOS = 127
    )(
        input  logic clk,
        input  logic rst,

        vga_if.in_m  tanks_in,
        vga_if.out_m tanks_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    logic [11:0] rgb_nxt, tanks_in_d_rgb;
    logic [19:0] pixel_addr;
    logic [11:0] rgb_pixel;

    vga_if vga_tanks_photo();

    always_ff @(posedge clk) begin
        if (rst) begin
            tanks_out.vcount <= '0;
            tanks_out.vsync  <= '0;
            tanks_out.vblnk  <= '0;
            tanks_out.hcount <= '0;
            tanks_out.hsync  <= '0;
            tanks_out.hblnk  <= '0;
            tanks_out.rgb    <= '0;
        end else begin
            tanks_out.vcount <= vga_tanks_photo.vcount;
            tanks_out.vsync  <= vga_tanks_photo.vsync;
            tanks_out.vblnk  <= vga_tanks_photo.vblnk;
            tanks_out.hcount <= vga_tanks_photo.hcount;
            tanks_out.hsync  <= vga_tanks_photo.hsync;
            tanks_out.hblnk  <= vga_tanks_photo.hblnk;
            tanks_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin
        if(vga_tanks_photo.rgb == 12'hf_f_f) begin
            rgb_nxt = tanks_in_d_rgb;
        end else begin
            rgb_nxt = vga_tanks_photo.rgb;
        end
    end

    draw_rect_image #(
        .N_buf(2),
        .WIDTH(HOR_PIXELS-2),
        .HEIGHT(512)
    ) tank_image_from_file (
        .clk(clk),
        .rst(rst),

        .xpos(XPOS),
        .ypos(YPOS),

        .rgb_pixel(rgb_pixel),
        .pixel_addr(pixel_addr),

        .rect_image_in(tanks_in),
        .rect_image_out(vga_tanks_photo)
    );

    photo_tanks_rom #(
        .SCALE_SHIFT(SCALE_SHIFT)
    ) u_photo_tank_tile_rom (
        .clk(clk),
        .address(pixel_addr),
        .rgb(rgb_pixel)
    );

    delay #(.WIDTH(12), .CLK_DEL(3)) d_rgb (
        .clk(clk),
        .rst(rst),
        .din(tanks_in.rgb),
        .dout(tanks_in_d_rgb)
    );

endmodule
