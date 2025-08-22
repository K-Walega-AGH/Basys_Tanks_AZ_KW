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
 * The project top module.
 */

module top_vga (
        input  logic clk,
        input  logic rst,
        input  logic clk100MHz,
        inout  logic ps2_clk,
        inout  logic ps2_data,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,
        output logic [7:0] sseg,
        output logic [3:0] an,
        output logic [15:11] led
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    // VGA signals from timing
    vga_if vga_timing();
    // VGA signals from background
    vga_if vga_bg();
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

    // tank movement and action
    logic  [1:0] moving, change_angle;
    logic fire_active;
    // signals necessary for projectile
    logic [11:0] tank_xpos_LEFT, tank_ypos_LEFT;
    logic [11:0] tank_xpos_RIGHT, tank_ypos_RIGHT;
    logic        damaged_LEFT, damaged_RIGHT;
    logic  [6:0] barrel_end_xpos_LEFT, barrel_end_ypos_LEFT, barrel_end_xpos_RIGHT, barrel_end_ypos_RIGHT;
    logic        end_turn;
    logic  [7:0] angle_LEFT, angle_RIGHT;
    logic [10:0] projectile_strength_LEFT, projectile_strength_RIGHT;
    logic  [1:0] hp_LEFT, hp_RIGHT;
    logic [10:0] fuel_LEFT, fuel_RIGHT;
    // signal to show help
    logic        show_help;
    // ps2 signals for hex display
    logic  [7:0] rx_data;
    logic        read_data;
    // signals from top_vga_ctl
    logic  [1:0] hp_CURRENT, hp_ENEMY;
    logic  [7:0] angle;
    logic [10:0] projectile_strength;
    logic [10:0] fuel;
    logic [11:0] barrel_final_xpos, barrel_final_ypos;
    logic [11:0] enemy_xpos, enemy_ypos;
    logic        enemy_hit;
    // bit 0 => LEFT ; bit 1 => RIGHT
    logic  [1:0] player_turn;

    /**
     * Signals assignments
     */
    assign vs = vga_help.vsync;
    assign hs = vga_help.hsync;
    assign {r,g,b} = vga_help.rgb;
    // led for debug
    assign led = {fire_active, change_angle[1:0], moving[1:0]};
    // hit from projectile to tanks
    /**
     * Submodules instances
     */

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

    draw_bg u_draw_bg (
        .clk(clk),
        .rst(rst),

        .bg_in  (vga_timing),
        .bg_out (vga_bg)
    );

    draw_terrain u_draw_terrain (
        .clk(clk),
        .rst(rst),

        .terrain_in  (vga_bg),
        .terrain_out (vga_terrain)
    );
    tank
    #(
        .PLAYER_ID(1)
    ) u_tank_LEFT (
        .clk(clk),
        .rst(rst),

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

        .barrel_end_xpos(barrel_final_xpos),
        .barrel_end_ypos(barrel_final_ypos),

        .enemy_xpos(enemy_xpos),
        .enemy_ypos(enemy_ypos),
        .enemy_hit(enemy_hit),
        .end_turn(end_turn),

        .projectile_in(vga_tank_RIGHT),
        .projectile_out(vga_projectile)
    );
    draw_help u_draw_help(
        .clk(clk),
        .rst(rst),

        .show_help(show_help),

        .help_in(vga_interface),
        .help_out(vga_help)
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

    ps2_keyboard u_ps2_keyboard(
    .clk100MHz(clk100MHz),
    .clk60MHz(clk),
    .rst(rst),

    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),

    .moving(moving),
    .change_angle(change_angle),
    .fire_active(fire_active),
    .show_help(show_help),

    .rx_data_out(rx_data),
    .read_data_out(read_data)
    );
    ps2_display u_ps2_display(
    .clk(clk),
    .rst(rst),

    .rx_data(rx_data),
    .read_data(read_data),

    .sseg(sseg),
    .an(an)
    );

    // instance of top_vga_ctl
    top_vga_ctl u_vga_ctl (
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
        .damaged_RIGHT(damaged_RIGHT)
    );

endmodule
