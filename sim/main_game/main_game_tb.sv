`timescale 1ns/1ps

module main_game_tb;

    // sygna�y do main_game
    logic clk;
    logic rst;

    logic [1:0] moving;
    logic [1:0] change_angle;
    logic       fire_active;
    logic       show_help;

    logic [1:0] player_turn_out;
    logic [1:0] game_over;

    // interfejs VGA dla main_game
    vga_if vga_out();
    vga_if vga_timing();

    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .vcount (vga_timing.vcount),
        .vsync  (vga_timing.vsync),
        .vblnk  (vga_timing.vblnk),
        .hcount (vga_timing.hcount),
        .hsync  (vga_timing.hsync),
        .hblnk  (vga_timing.hblnk)
    );
    // instancja DUT
    main_game dut (
        .clk(clk),
        .rst(rst),
        .moving(moving),
        .change_angle(change_angle),
        .fire_active(fire_active),
        .show_help(show_help),
        .player_turn_out(player_turn_out),
        .game_over(game_over),
        .vga_main_game_in(vga_timing),
        .vga_main_game_out(vga_out)
    );

    // zegar 60 MHz (okres 16.67 ns)
    initial clk = 0;
    always #8.33 clk = ~clk;

    // reset
    initial begin
        rst = 1;
        #100;
        rst = 0;
    end

    // proste pobudzenie wej��
    initial begin
        moving       = 2'b00;
        change_angle = 2'b00;
        fire_active  = 1'b0;
        show_help    = 1'b0;
    end

    // monitorowanie hcount
    // sprawdzamy przesuni�cie projectile_in.hcount wzgl�dem vga_terrain.hcount
    int diff1, diff2;
    always_ff @(posedge clk) begin
        if (vga_timing.hcount < 224 && vga_timing.vcount < 1) begin
            diff1 <= dut.u_projectile.vga_projectile2explosion.hcount - dut.vga_terrain.hcount;
            $display("time=%0t | vga_terrain.hcount=%0d | explosion_in.hcount=%0d | diff=%0d",
                    $time,
                    dut.vga_terrain.hcount,
                    dut.u_projectile.vga_projectile2explosion.hcount,
                    diff1);
            diff2 <= dut.u_tank_RIGHT.tank_in.hcount - dut.vga_terrain.hcount;
            $display("time=%0t | vga_terrain.hcount=%0d | tankR_in.hcount=%0d | diff=%0d",
                    $time,
                    dut.vga_terrain.hcount,
                    dut.u_tank_RIGHT.tank_in.hcount,
                    diff2);
            $display("time=%0t | terrain_y_d8=%0d | terrain_y_d16=%0d",
                    $time,
                    dut.terrain_y_d8, 
                    dut.terrain_y_d16);
        end
    end

    // zako�cz symulacj� po kilku liniach
    initial begin
        #100000; // symulujemy pewien czas
        $finish;
    end

endmodule
