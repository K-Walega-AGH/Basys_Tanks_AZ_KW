
module player_interface (
        input  logic clk,
        input  logic rst,
    
        input  logic  [1:0] hp_CURRENT,
        input  logic  [1:0] hp_ENEMY,
        input  logic  [7:0] angle,
        input  logic [10:0] projectile_strength,
        input  logic  [6:0] fuel,
    
        vga_if.in_m         interface_in,
        vga_if.out_m        interface_out
    );


    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import interface_pkg::*;

    /**
     * Local variables and signals
     */
    
    // interface for gray box
    vga_if vga_if_bg();
    // interface for drawing hp
    vga_if vga_hp_text_CURRENT();
    vga_if vga_hp_text_ENEMY();
    vga_if vga_hp_CURRENT();
    vga_if vga_hp_ENEMY();
    // interface for drawing strength
    vga_if vga_text_strength();
    vga_if vga_strength();
    // interface for drawing fuel
    vga_if vga_text_fuel();
    vga_if vga_fuel();
    // interface for drawing angle
    vga_if vga_angle();

 
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
    //---------- CURRENT hp ----------
    draw_param_text 
    #(
        .TEXT("CURRENT PLAYER HP: "),
        .LINES(1),
        .TEXT_X(HP_CURRENT_X - TEXT_OFFSET_X),
        .TEXT_Y(HP_CURRENT_Y - (HEIGHT_CHAR+TEXT_OFFSET_Y))
    ) u_draw_CURRENT_hp_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_if_bg),
        .text_out(vga_hp_text_CURRENT)
    );
    draw_hp #(
        .HP_X(HP_CURRENT_X),
        .HP_Y(HP_CURRENT_Y)
    ) u_draw_CURRENT_hp (
        .clk(clk),
        .rst(rst),
        
        .hp(hp_CURRENT),

        .hp_in(vga_hp_text_CURRENT),
        .hp_out(vga_hp_CURRENT)
    );
    //---------- ENEMY hp ----------
    draw_param_text 
    #(
        .TEXT("ENEMY PLAYER HP: "),
        .LINES(1),
        .TEXT_X(HP_ENEMY_X - TEXT_OFFSET_X),
        .TEXT_Y(HP_ENEMY_Y - (HEIGHT_CHAR+TEXT_OFFSET_Y))
    ) u_draw_ENEMY_hp_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_hp_CURRENT),
        .text_out(vga_hp_text_ENEMY)
    );
    draw_hp 
    #(
        .HP_X(HP_ENEMY_X),
        .HP_Y(HP_ENEMY_Y)
    ) u_draw_ENEMY_hp (
        .clk(clk),
        .rst(rst),
        
        .hp(hp_ENEMY),

        .hp_in(vga_hp_text_ENEMY),
        .hp_out(vga_hp_ENEMY)
    );
    //---------- strength ----------
    draw_param_text 
    #(
        .TEXT("STRENGTH: "),
        .LINES(1),
        .TEXT_X(STRENGTH_X),
        .TEXT_Y(STRENGTH_Y - (HEIGHT_CHAR+TEXT_OFFSET_Y))
    ) u_draw_stength_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_hp_ENEMY),
        .text_out(vga_text_strength)
    );
    draw_strength u_draw_strength (
        .clk(clk),
        .rst(rst),
        
        .projectile_strength(projectile_strength),

        .strength_in(vga_text_strength),
        .strength_out(vga_strength)
    );
    //---------- fuel ----------
    draw_param_text 
    #(
        .TEXT("FUEL: "),
        .LINES(1),
        .TEXT_X(FUEL_X),
        .TEXT_Y(FUEL_Y - (HEIGHT_CHAR+TEXT_OFFSET_Y))
    ) u_draw_fuel_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_strength),
        .text_out(vga_text_fuel)
    );
    draw_fuel u_draw_fuel (
        .clk(clk),
        .rst(rst),
        
        .fuel(fuel),

        .fuel_in(vga_text_fuel),
        .fuel_out(vga_fuel)
    );
    //---------- angle ----------
    draw_angle u_draw_angle (
        .clk(clk),
        .rst(rst),
        
        .angle(angle),

        .angle_in(vga_fuel),
        .angle_out(interface_out)
    );


endmodule