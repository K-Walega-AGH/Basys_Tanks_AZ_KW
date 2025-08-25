
module start_screen (
    input  logic       clk,
    input  logic       rst,

    vga_if.in_m  vga_start_screen_in,
    vga_if.out_m vga_start_screen_out
);

    localparam INIT_XPOS = 1;
    localparam INIT_YPOS = 127;

    vga_if vga_tanks_photo();
    vga_if vga_text();


    draw_tanks_photo #(
        .SCALE_SHIFT(2),
        .XPOS(INIT_XPOS),
        .YPOS(INIT_YPOS)
    ) u_tanks_photo (
        .clk(clk),
        .rst(rst),

        .tanks_in  (vga_start_screen_in),
        .tanks_out (vga_tanks_photo)
    );

     draw_param_text_blink 
    #(
        .TEXT(" TO START THE GAME PRESS ENTER "),
        .TEXT_COLOR(12'hf_f_f),
        .BG_COLOR(12'h0_0_0),
        .LINES(1),
        .TEXT_X(337),
        .TEXT_Y(639)
    ) u_start_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_tanks_photo),
        .text_out(vga_text)
    );

    vga_if_delay #(
        .N_buf(48)
    ) u_vga_if_delay (
        .clk(clk),
        .rst(rst),

        .vga_if_in  (vga_text),
        .vga_if_out (vga_start_screen_out)
    );

endmodule
