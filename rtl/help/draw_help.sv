
 module draw_help (
    input  logic clk,
    input  logic rst,

    input  logic show_help,

    vga_if.in_m     help_in,
    vga_if.out_m    help_out
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;


/**
 * Local variables and signals
 */

logic [11:0] rgb_nxt, help_in_d_rgb;
// font stuff
logic [10:0] addr;
logic [14:0] char_xy;
logic  [6:0] char_code;
logic  [3:0] char_line;
logic  [7:0] char_line_pixels;
logic  [5:0] used_lines;

vga_if vga_help();

//char_addr assignment
assign addr = {char_code, char_line};
/**
 * Internal logic
 */

always_ff @(posedge clk) begin : bg_ff_blk
    if (rst) begin
        help_out.vcount <= '0;
        help_out.vsync  <= '0;
        help_out.vblnk  <= '0;
        help_out.hcount <= '0;
        help_out.hsync  <= '0;
        help_out.hblnk  <= '0;
        help_out.rgb    <= '0;
    end else begin
        help_out.vcount <= vga_help.vcount;
        help_out.vsync  <= vga_help.vsync;
        help_out.vblnk  <= vga_help.vblnk;
        help_out.hcount <= vga_help.hcount;
        help_out.hsync  <= vga_help.hsync;
        help_out.hblnk  <= vga_help.hblnk;
        help_out.rgb    <= rgb_nxt;
    end
end

always_comb begin : bg_comb_blk
    if(show_help) begin
        rgb_nxt = vga_help.rgb;            // - fill with HELP
    end else begin
        rgb_nxt = help_in_d_rgb;           // - fill with BACKGROUND
    end
end

draw_rect_char 
#(
.N_buf(2),
.XPOS(100),
.YPOS(100),
.AMOUNT_OF_LETTERS(96),
.AMOUNT_OF_LINES(32)
) u_draw_rect_char (
    .clk(clk),
    .rst(rst),

    .used_lines(used_lines),
    .char_line_pixels(char_line_pixels),
    .char_xy(char_xy),
    .char_line(char_line),

    .rect_char_in    (help_in),
    .rect_char_out   (vga_help)
);
help_rom 
#(
    .AMOUNT_OF_LETTERS(96)
) u_help_rom (
    .char_xy(char_xy),
    .char_code(char_code),
    .used_lines(used_lines)
);
font_rom u_font_rom (
    .clk(clk),
    .addr(addr),
    .char_line_pixels(char_line_pixels)
);
// delay bg to match image
delay #(.WIDTH(12), .CLK_DEL(1)) d_rgb (
    .clk(clk),
    .rst(rst),
    .din(help_in.rgb),
    .dout(help_in_d_rgb)
);

endmodule
