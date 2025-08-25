/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 * Co-Author: Kacper Wałęga
 *
 * Description:
 * Module input and output connection to be added at top module.
 */
module projectile 
(
    input  logic clk,
    input  logic rst,

    input  logic  [1:0] player_turn,
    input  logic        fire_active,
    input  logic  [7:0] angle,
    input  logic [10:0] projectile_strength,

    input  logic [11:0] barrel_end_xpos,
    input  logic [11:0] barrel_end_ypos,

    input  logic [11:0] enemy_xpos,
    input  logic [11:0] enemy_ypos,

    output logic        enemy_hit,
    output logic        end_turn,

    vga_if.in_m         projectile_in,
    vga_if.out_m        projectile_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import tank_pkg::*;
    import projectile_pkg::*;

    /**
     * Local variables and signals
     */
    
    logic [11:0] projectile_xpos, projectile_ypos;
    logic [11:0] explosion_xpos, explosion_ypos;
    logic        show_bullet, activate_explosion;
    logic [31:0] sin_val, cos_val;
    logic        end_turn_HIT, end_turn_NO_HIT;

    vga_if vga_projectile2explosion();
 
    /**
     * Signals assignments
     */

    assign end_turn = (end_turn_HIT || end_turn_NO_HIT);
    /**
     * Submodules instances
     */

    draw_projectile u_draw_projectile (
    .clk(clk),
    .rst(rst),

    .show_bullet(show_bullet),

    .projectile_xpos(projectile_xpos),
    .projectile_ypos(projectile_ypos),

    .projectile_in(projectile_in),
    .projectile_out(vga_projectile2explosion)
    );

    projectile_ctl u_projectile_ctl (
    .clk(clk),
    .rst(rst),

    .player_turn(player_turn),
    .fire_active(fire_active),
    .sin_val(sin_val),
    .cos_val(cos_val),
    .projectile_strength(projectile_strength),

    .barrel_end_xpos(barrel_end_xpos),
    .barrel_end_ypos(barrel_end_ypos),

    .enemy_xpos(enemy_xpos),
    .enemy_ypos(enemy_ypos),

    .enemy_hit(enemy_hit),
    .end_turn(end_turn_NO_HIT),
    .activate_explosion(activate_explosion),
    .show_bullet(show_bullet),

    .projectile_xpos(projectile_xpos),
    .projectile_ypos(projectile_ypos),
    .explosion_xpos(explosion_xpos),
    .explosion_ypos(explosion_ypos)
    );
    sin_lut u_sin_lut (
    .angle(angle),
    .sin_val(sin_val)
    );
    cos_lut u_cos_lut (
    .angle(angle),
    .cos_val(cos_val)
    );

    explosion u_explosion (
    .clk(clk),
    .rst(rst),

    .explosion_xpos(explosion_xpos),
    .explosion_ypos(explosion_ypos),
    .activate_explosion(activate_explosion),

    .end_turn(end_turn_HIT),

    .explosion_in(vga_projectile2explosion),
    .explosion_out(projectile_out)
);
endmodule