
module barrel (
    input  logic clk,
    input  logic rst,

    input  logic [11:0] barrel_xpos,
    input  logic [11:0] barrel_ypos,
    input  logic        your_turn,
    input  logic [1:0]  change_angle,

    vga_if.in_m         barrel_in,
    vga_if.out_m        barrel_out
);

    logic [2:0] angle_index;

    draw_barrel u_draw_barrel (
        .clk(clk),
        .rst(rst),

        .barrel_xpos(barrel_xpos),
        .barrel_ypos(barrel_ypos),
        .angle_index(angle_index),

        .barrel_in  (barrel_in),
        .barrel_out (barrel_out)
    );
    barrel_ctl u_barrel_ctl (
        .clk(clk),
        .rst(rst),

        .change_angle(change_angle),
        .your_turn(your_turn),
        .angle_index(angle_index)
    );


endmodule