
module tank 
#(
    // Either 1 or 2
    //determines tank side of screen, roms and bullet vx direction
    PLAYER_ID = 1    
)(
    input  logic clk,
    input  logic rst,

    input  logic [1:0] moving,
    input  logic [1:0] change_angle,
    input  logic       fire_active,
    input  logic       your_turn,

    input  logic       damaged,

    //wyjscia potrzebne jeszcze:
    output logic  [7:0] angle,
    output logic [10:0] projectile_strength,
    output logic  [1:0] hp,
    output logic  [6:0] fuel,
    output logic [11:0] tank_xpos,
    output logic [11:0] tank_ypos,
    output logic  [6:0] barrel_end_xpos,
    output logic  [6:0] barrel_end_ypos,
    
    vga_if.in_m        tank_in,
    vga_if.out_m       tank_out
);

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    // VGA signals from tank to barrel
    vga_if vga_tank2barrel();

    // tank_move wires
    // logic [11:0] move_tank_to_draw_tank_xpos;
    // logic [11:0] move_tank_to_draw_tank_ypos;
 
    /**
     * Signals assignments
     */

    /**
     * Submodules instances
     */

    draw_tank 
    #(
        .PLAYER_ID(PLAYER_ID)
    ) u_draw_tank (
        .clk(clk),
        .rst(rst),

        .tank_xpos(tank_xpos),
        .tank_ypos(tank_ypos),

        .tank_in  (tank_in),
        .tank_out (vga_tank2barrel)
    );
    barrel 
    #(
        .PLAYER_ID(PLAYER_ID)
    ) u_barrel (
        .clk(clk),
        .rst(rst),

        .barrel_xpos(tank_xpos),
        .barrel_ypos(tank_ypos),
        .your_turn(your_turn),
        .change_angle(change_angle),
        .angle(angle),

        .barrel_end_xpos(barrel_end_xpos),  // !!! relative to tank position !!!
        .barrel_end_ypos(barrel_end_ypos),

        .barrel_in  (vga_tank2barrel),
        .barrel_out (tank_out)
    );

    tank_ctl
    #(
        .PLAYER_ID(PLAYER_ID)
    ) u_tank_ctl (
        .clk(clk),
        .rst(rst),
    
        .moving(moving),
        .fire_active(fire_active),
        .your_turn(your_turn),
        .damaged(damaged),

        .hp(hp),
        .fuel(fuel),
        .projectile_strength(projectile_strength),
        .tank_xpos(tank_xpos),
        .tank_ypos(tank_ypos)
    );
    tank_move u_tank_move (
        .clk(clk),
        .rst(rst),
        
        .tank_xpos_in(tank_xpos),
        .tank_ypos_in(tank_ypos),

        .tank_xpos_out(),   //this outpur will go to draw_tank ; disconected for now
        .tank_ypos_out()
    );

endmodule