module projectile (
    input  logic clk,
    input  logic rst,

    input  logic  [7:0] angle,

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

    .fire_active(fire_active),

    .barrel_end_xpos(barrel_end_xpos),
    .barrel_end_ypos(barrel_end_ypos),

    .collision(),
    .show_bullet(show_bullet),

    .projectile_xpos(projectile_xpos),
    .projectile_ypos(projectile_ypos)

    );

endmodule