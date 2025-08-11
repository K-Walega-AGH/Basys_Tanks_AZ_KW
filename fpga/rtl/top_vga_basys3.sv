/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_vga_basys3 (
        input  wire clk,
        input  wire btnC,
        inout  wire ps2_clk,
        inout  wire ps2_data,
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA1,
        output wire [7:0] seg,
        output wire [3:0] an,
        output wire [15:11] led
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    wire locked;
    wire clk100MHz, clk60MHz, clk40MHz, clk40MHz_mirror;

    (* KEEP = "TRUE" *)
    (* ASYNC_REG = "TRUE" *)
    logic [7:0] safe_start = 0;
    // For details on synthesis attributes used above, see AMD Xilinx UG 901:
    // https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


    /**
     * Signals assignments
     */

    assign JA1 = clk40MHz_mirror;


    /**
     * FPGA submodules placement
     */

    clk_wiz_1 u_clk_wiz_1
    (
        // Clock out ports
        .clk100MHz(clk100MHz),
        .clk60MHz(clk60MHz),
        .clk40MHz(clk40MHz),
        // Status and control signals
        .locked(locked),
        // Clock in ports
        .clk_in1(clk)
    );


    // Mirror clk40MHz on a pin for use by the testbench;
    // not functionally required for this design to work.

    ODDR clk40MHz_oddr (
        .Q(clk40MHz_mirror),
        .C(clk40MHz),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );


    /**
     *  Project functional top module
     */

    top_vga u_top_vga (
        .clk(clk60MHz),
        .rst(btnC),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .clk100MHz(clk100MHz),
        .sseg(seg),
        .an(an),
        .led(led)
    );

endmodule
