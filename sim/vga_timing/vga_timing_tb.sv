/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 25;     // 40 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

    wire [10:0] vcount, hcount;
    wire        vsync,  hsync;
    wire        vblnk,  hblnk;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut(
        .clk,
        .rst,
        .vcount,
        .vsync,
        .vblnk,
        .hcount,
        .hsync,
        .hblnk
    );

    /**
     * Tasks and functions
     */

    // Here you can declare tasks with immediate assertions (assert).

    task check_reset_val;
        @(posedge rst);
        #5;
        assert(hcount == 0) else $error("hcount didnt reset to 0 ; val: %0d", hcount);
        assert(vcount == 0) else $error("vcount didnt reset to 0 ; val: %0d", vcount);
    endtask

    /**
     * Assertions
     */
    // Here you can declare concurrent assertions (assert property).
    
    // Check reset of hcount & vcount after reaching their max value
    property hcount_ends;
        @(posedge clk) disable iff (rst)
        (hcount == TOTAL_HOR_PIXELS - 1) |=> (hcount == 0);
    endproperty
    assert property (hcount_ends) else $error("hcount did not reset correctly!");
    property vcount_ends;
        @(posedge clk) disable iff (rst)
        ((vcount == TOTAL_VER_PIXELS - 1) && (hcount == TOTAL_HOR_PIXELS - 1)) |=> (vcount == 0);
    endproperty
    assert property (vcount_ends) else $error("vcount did not reset correctly!");

    // Chect if vcount increments on last value of hcount
    property vcount_increments;
        @(posedge clk) disable iff (rst)
        (hcount == TOTAL_HOR_PIXELS - 1) |=> (vcount == ($past(vcount) + 1) % TOTAL_VER_PIXELS);
    endproperty
    assert property (vcount_increments) else $error("vcount did not increment correctly!");

    // Check the SYNC pulses duration
    property hsync_asserted;
        @(posedge clk) disable iff (rst)
        (hcount >= HSYNC_START && hcount < HSYNC_END) |-> hsync;
    endproperty
    assert property (hsync_asserted) else $error("hsync not asserted at correct time!");

    property vsync_asserted;
        @(posedge clk) disable iff (rst)
        (vcount >= VSYNC_START && vcount < VSYNC_END) |-> vsync;
    endproperty
    assert property (vsync_asserted) else $error("vsync not asserted at correct time!");

    // Check the BLANK pulses duration
    property hblnk_asserted;
        @(posedge clk) disable iff (rst)
        (hcount >= HBLANK_START && hcount < HBLANK_END) |-> hblnk;
    endproperty
    assert property (hblnk_asserted) else $error("hblnk not asserted at correct time!");

    property vblnk_asserted;
        @(posedge clk) disable iff (rst)
        (vblnk >= VBLANK_START && vblnk < VBLANK_END) |-> vblnk;
    endproperty
    assert property (vblnk_asserted) else $error("vblnk not asserted at correct time!");

    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

endmodule
