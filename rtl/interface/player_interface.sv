
module player_interface
    #(
        PLAYER_ID = 1    
    )(
        input  logic clk,
        input  logic rst,
    
        input  logic  [1:0] hp_CURRENT,
        input  logic  [1:0] hp_ENEMY,
        input  logic  [7:0] angle,
        input  logic [10:0] projectile_strength,
        input  logic [10:0] fuel,
    
        vga_if.in_m         interface_in,
        vga_if.out_m        interface_out
    );


    timeunit 1ns;
    timeprecision 1ps;

    import tank_pkg::*;
    import interface_pkg::*;

    /**
     * Local variables and signals
     */
    
    // interface for gray box
    vga_if vga_if_bg();
    // interface for drawing hp
    vga_if vga_hp_CURRENT();
    vga_if vga_hp_ENEMY();
    // interface for drawing angle
    vga_if vga_angle();
    // interface for drawing strength
    vga_if vga_strength();
    // interface for drawing fuel
    vga_if vga_fuel();
 
    /**
     * Signals assignments
     */

    /**
     * Submodules instances
     */
    draw_if_bg u_draw_if_bg (
        .clk(clk),
        .rst(rst),

        .if_bg_in(interface_in),
        .if_bg_out(vga_if_bg)
    );
    draw_hp #(
        .HP_X(HP_CURRENT_X),
        .HP_Y(HP_CURRENT_Y)
    ) u_draw_CURRENT_hp (
        .clk(clk),
        .rst(rst),
        
        .hp(hp_CURRENT),

        .hp_in(vga_if_bg),
        .hp_out(vga_hp_CURRENT)
    );
    draw_hp 
    #(
        .HP_X(HP_ENEMY_X),
        .HP_Y(HP_ENEMY_Y)
    ) u_draw_ENEMY_hp (
        .clk(clk),
        .rst(rst),
        
        .hp(hp_ENEMY),

        .hp_in(vga_hp_CURRENT),
        .hp_out(vga_hp_ENEMY)
    );
    draw_strength u_draw_strength (
        .clk(clk),
        .rst(rst),
        
        .projectile_strength(projectile_strength),

        .strength_in(vga_hp_ENEMY),
        .strength_out(vga_strength)
    );
    draw_fuel u_draw_fuel (
        .clk(clk),
        .rst(rst),
        
        .fuel(fuel),

        .fuel_in(vga_strength),
        .fuel_out(vga_fuel)
    );
    draw_angle u_draw_angle (
        .clk(clk),
        .rst(rst),
        
        .angle(angle),

        .angle_in(vga_fuel),
        .angle_out(interface_out)
    );


endmodule