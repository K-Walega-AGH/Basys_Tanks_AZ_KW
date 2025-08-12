/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 * Co-Author: Kacper Wałęga
 *
 * Description:
 * Module input and output connection to be added at top module.
 */
module projectile (
    input  logic clk,
    input  logic rst,

    input  logic        fire_active,
    input  logic  [7:0] angle,
    input  logic [10:0] projectile_strength,

    input  logic [11:0] barrel_end_xpos,
    input  logic [11:0] barrel_end_ypos,

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
    logic        show_bullet;
    logic [31:0] sin_val, cos_val;
 
    /**
     * Signals assignments
     */

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
    .projectile_out(projectile_out)
    );

    projectile_ctl u_projectile_ctl (
    .clk(clk),
    .rst(rst),

    //sin cos inputs
    .fire_active(fire_active),
    .sin_val(sin_val),
    .cos_val(cos_val),
    .projectile_strength(projectile_strength),

    .barrel_end_xpos(barrel_end_xpos),
    .barrel_end_ypos(barrel_end_ypos),

    .collision(),
    .show_bullet(show_bullet),

    .projectile_xpos(projectile_xpos),
    .projectile_ypos(projectile_ypos)

    );
    sin_lut u_sin_lut (
    .angle(angle),
    .sin_val(sin_val)
    );
    cos_lut u_cos_lut (
    .angle(angle),
    .cos_val(cos_val)
    );

endmodule