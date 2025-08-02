module tank_movement_tb;

    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK_PERIOD = 16;     // 60 MHz
    localparam STEP_REPEAT = 100;     // 60 MHz

    import vga_pkg::*;
    import tank_pkg::*;

    logic clk, rst;
    wire vs, hs;
    wire [3:0] r, g, b;

    // sterowanie czo�giem
    logic [1:0] moving;
    logic fire_active, your_turn;

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // DUT
    top_vga dut (
        .clk(clk),
        .rst(rst),
        .clk100MHz(),
        .ps2_clk(),
        .ps2_data(),
        .vs(vs),
        .hs(hs),
        .r(r),
        .g(g),
        .b(b)
    );

    logic tiff_go = 1'b0;

    // TIFF Writer (zapis po zako�czeniu)
    tiff_writer #(
        .XDIM(TOTAL_HOR_PIXELS),
        .YDIM(TOTAL_VER_PIXELS),
        .FILE_DIR("../../results")
    ) u_tiff_writer (
        .clk(clk),
        .r({r,r}),
        .g({g,g}),
        .b({b,b}),
        .go(tiff_go)
    );

    

    // Reset
    initial begin
        rst = 1'b1;
        # (5 * CLK_PERIOD);
        rst = 1'b0;
    end

    // Pocz�tkowe sterowanie
    initial begin
        // start the turn
        force dut.your_turn = 1'b1;
        force dut.fire_active = 1'b0;

        // wait for rst end
        wait(!rst);

        // move to the RIGHT
        force dut.moving = 2'b11;

        // MAX_FUEL = 100, MOVE_STEP = 1, clk 16ns -> need 100 cycles
        // times 2 bcs drawing takes 2 cycles
        repeat (2*STEP_REPEAT + 10) @(posedge clk);

        // stop moving
        force dut.moving = 2'b00;
        #(10 * CLK_PERIOD);

        // zrzut klatki do pliku
        wait (vs == 1'b0);
        @(negedge vs);
        tiff_go = 1'b1;
        @(negedge vs);
        tiff_go = 1'b0;

        
        #(3*CLK_PERIOD)

        $display("Simulation finished. Check generated TIFF image.");
        $stop;
    end


endmodule
