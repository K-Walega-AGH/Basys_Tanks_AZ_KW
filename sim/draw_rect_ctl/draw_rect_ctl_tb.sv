`timescale 1ns/1ps

module draw_rect_ctl_tb;

    logic clk;
    logic rst;

    logic [11:0] xpos_in, ypos_in;
    logic        left;

    logic [11:0] xpos_out, ypos_out;

    // Generowanie zegara 40 MHz
    always #12.5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #100;
        rst = 0;
    end

    // Instancja programu testowego (symulator myszy)
    draw_rect_ctl_prog prog_inst (
        .clk(clk),
        .rst(rst),
        .xpos_in(xpos_in),
        .ypos_in(ypos_in),
        .left(left)
    );

    // Instancja testowanego modułu
    draw_rect_ctl dut_inst (
        .clk(clk),
        .rst(rst),
        .xpos_in(xpos_in),
        .ypos_in(ypos_in),
        .left(left),
        .xpos_out(xpos_out),
        .ypos_out(ypos_out)
    );

endmodule
