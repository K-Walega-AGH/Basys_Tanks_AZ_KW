
module main_game (
        input  logic clk,
        input  logic rst,
        
        input  logic [1:0] moving,
        input  logic [1:0] change_angle,
        input  logic       fire_active,
        input  logic       show_help,

        output logic [1:0] player_turn_out,
        output logic [1:0] game_over,

        vga_if.in_m        vga_main_game_in,
        vga_if.out_m       vga_main_game_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    // VGA signals from terrain
    vga_if vga_terrain();
    // VGA signals from tanks
    vga_if vga_tank_LEFT();
    vga_if vga_tank_RIGHT();
    // VGA signals from projectile
    vga_if vga_projectile();
    // VGA signals from interface
    vga_if vga_interface();
    // VGA signals from help module
    vga_if vga_help();

    // signals necessary for projectile
    logic [11:0] tank_xpos_LEFT, tank_ypos_LEFT;
    logic [11:0] tank_xpos_RIGHT, tank_ypos_RIGHT;
    logic        damaged_LEFT, damaged_RIGHT;
    logic  [6:0] barrel_end_xpos_LEFT, barrel_end_ypos_LEFT;
    logic  [6:0] barrel_end_xpos_RIGHT, barrel_end_ypos_RIGHT;
    logic        end_turn;
    logic  [7:0] angle_LEFT, angle_RIGHT;
    logic [10:0] projectile_strength_LEFT, projectile_strength_RIGHT;
    logic  [1:0] hp_LEFT, hp_RIGHT;
    logic  [6:0] fuel_LEFT, fuel_RIGHT;
    // signals from top_vga_ctl
    logic  [1:0] hp_CURRENT, hp_ENEMY;
    logic  [7:0] angle;
    logic [10:0] projectile_strength;
    logic  [6:0] fuel;
    logic [11:0] barrel_final_xpos, barrel_final_ypos;
    logic [11:0] enemy_xpos, enemy_ypos;
    logic        enemy_hit;
    // terrain_y value and configuration
    logic [11:0] terrain_y, terrain_y_d8, terrain_y_d16;
    logic [11:0] terrain_y_LEFT, terrain_y_RIGHT, terrain_y_PRJCTL;
    logic [11:0] terrain_x_new, terrain_y_new;
    logic        write_en;
    // bit 0 => LEFT ; bit 1 => RIGHT
    logic  [1:0] player_turn;

    /**
     * Signals assignments
     */

    //output assignments
    assign vga_main_game_out.hcount = vga_help.hcount;
    assign vga_main_game_out.hsync  = vga_help.hsync;
    assign vga_main_game_out.hblnk  = vga_help.hblnk;
    assign vga_main_game_out.vcount = vga_help.vcount;
    assign vga_main_game_out.vsync  = vga_help.vsync;
    assign vga_main_game_out.vblnk  = vga_help.vblnk;
    assign vga_main_game_out.rgb    = vga_help.rgb;
    // player_turn output for ff'ing
    assign player_turn_out = player_turn;
    // terrain signal for tanks, 
    // for RIGHT has to be delayed bcs vga_if goes through LEFT first
    assign terrain_y_LEFT   = terrain_y;
    assign terrain_y_RIGHT  = terrain_y_d8;
    assign terrain_y_PRJCTL = terrain_y_d16;
    /**
     * Submodules instances
     */

    terrain u_terrain (
        .clk(clk),
        .rst(rst),

        .terrain_x_in(terrain_x_new),
        .terrain_y_in(terrain_y_new),
        .write_en(write_en),

        .terrain_y_out(terrain_y),

        .terrain_in  (vga_main_game_in),
        .terrain_out (vga_terrain)
    );
    delay #(.WIDTH(12), .CLK_DEL(8)) d8_terrain_y (
        .clk(clk),
        .rst(rst),
        .din(terrain_y),
        .dout(terrain_y_d8)
    );
    delay #(.WIDTH(12), .CLK_DEL(16)) d16_terrain_y (
        .clk(clk),
        .rst(rst),
        .din(terrain_y),
        .dout(terrain_y_d16)
    );
    tank
    #(
        .PLAYER_ID(1)
    ) u_tank_LEFT (
        .clk(clk),
        .rst(rst),

        .terrain_y(terrain_y_LEFT),

        .moving(moving),
        .change_angle(change_angle),
        .fire_active(fire_active),
        .your_turn(player_turn[0]),

        .damaged(damaged_LEFT),

        .angle(angle_LEFT),
        .projectile_strength(projectile_strength_LEFT),
        .hp(hp_LEFT),
        .fuel(fuel_LEFT),
        .tank_xpos(tank_xpos_LEFT),
        .tank_ypos(tank_ypos_LEFT),
        .barrel_end_xpos(barrel_end_xpos_LEFT),
        .barrel_end_ypos(barrel_end_ypos_LEFT),

        .tank_in  (vga_terrain),
        .tank_out (vga_tank_LEFT)
    );
    tank
    #(
        .PLAYER_ID(2)
    ) u_tank_RIGHT (
        .clk(clk),
        .rst(rst),

        .terrain_y(terrain_y_RIGHT),

        .moving(moving),
        .change_angle(change_angle),
        .fire_active(fire_active),
        .your_turn(player_turn[1]),

        .damaged(damaged_RIGHT),

        .angle(angle_RIGHT),
        .projectile_strength(projectile_strength_RIGHT),
        .hp(hp_RIGHT),
        .fuel(fuel_RIGHT),
        .tank_xpos(tank_xpos_RIGHT),
        .tank_ypos(tank_ypos_RIGHT),
        .barrel_end_xpos(barrel_end_xpos_RIGHT),
        .barrel_end_ypos(barrel_end_ypos_RIGHT),

        .tank_in  (vga_tank_LEFT),
        .tank_out (vga_tank_RIGHT)
    );
    projectile u_projectile (
        .clk(clk),
        .rst(rst),

        .player_turn(player_turn),
        .fire_active(fire_active),
        .angle(angle),
        .projectile_strength(projectile_strength),

        .terrain_y_in(terrain_y_PRJCTL),
        .terrain_x_out(terrain_x_new),
        .terrain_y_out(terrain_y_new),
        .write_en(write_en),

        .barrel_end_xpos(barrel_final_xpos),
        .barrel_end_ypos(barrel_final_ypos),

        .enemy_xpos(enemy_xpos),
        .enemy_ypos(enemy_ypos),
        .enemy_hit(enemy_hit),
        .end_turn(end_turn),

        .projectile_in(vga_tank_RIGHT),
        .projectile_out(vga_projectile)
    );
    player_interface u_player_interface (
        .clk(clk),
        .rst(rst),

        .hp_CURRENT(hp_CURRENT),
        .hp_ENEMY(hp_ENEMY),
        .angle(angle),
        .projectile_strength(projectile_strength),
        .fuel(fuel),

        .interface_in(vga_projectile),
        .interface_out(vga_interface)
    );
    draw_help u_draw_help(
        .clk(clk),
        .rst(rst),

        .show_help(show_help),

        .help_in(vga_interface),
        .help_out(vga_help)
    );

    // instance of top_vga_ctl
    main_game_ctl u_main_game_ctl (
        .clk(clk),
        .rst(rst),
        // input signals
        .hp_LEFT(hp_LEFT),
        .hp_RIGHT(hp_RIGHT),
        .angle_LEFT(angle_LEFT),
        .angle_RIGHT(angle_RIGHT),
        .strength_LEFT(projectile_strength_LEFT),
        .strength_RIGHT(projectile_strength_RIGHT),
        .fuel_LEFT(fuel_LEFT),
        .fuel_RIGHT(fuel_RIGHT),
        .tank_xpos_LEFT(tank_xpos_LEFT),
        .tank_ypos_LEFT(tank_ypos_LEFT),
        .tank_xpos_RIGHT(tank_xpos_RIGHT),
        .tank_ypos_RIGHT(tank_ypos_RIGHT),
        .barrel_end_xpos_LEFT(barrel_end_xpos_LEFT),
        .barrel_end_ypos_LEFT(barrel_end_ypos_LEFT),
        .barrel_end_xpos_RIGHT(barrel_end_xpos_RIGHT),
        .barrel_end_ypos_RIGHT(barrel_end_ypos_RIGHT),
        .end_turn(end_turn),
        .enemy_hit(enemy_hit),
        // output signals
        .player_turn(player_turn),
        .hp_CURRENT(hp_CURRENT),
        .hp_ENEMY(hp_ENEMY),
        .angle(angle),
        .projectile_strength(projectile_strength),
        .fuel(fuel),
        .barrel_final_xpos(barrel_final_xpos),
        .barrel_final_ypos(barrel_final_ypos),
        .enemy_xpos(enemy_xpos),
        .enemy_ypos(enemy_ypos),
        .damaged_LEFT(damaged_LEFT),
        .damaged_RIGHT(damaged_RIGHT),
        .game_over(game_over)
    );


endmodule
