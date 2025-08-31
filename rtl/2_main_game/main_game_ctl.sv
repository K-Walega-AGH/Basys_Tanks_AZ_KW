module main_game_ctl (
    input  logic clk,
    input  logic rst,
    // tank signals
    input  logic  [1:0] hp_LEFT, hp_RIGHT,
    input  logic  [7:0] angle_LEFT, angle_RIGHT,
    input  logic [10:0] strength_LEFT, strength_RIGHT,
    input  logic  [6:0] fuel_LEFT, fuel_RIGHT,
    input  logic [11:0] tank_xpos_LEFT, tank_ypos_LEFT,
    input  logic [11:0] tank_xpos_RIGHT, tank_ypos_RIGHT,
    input  logic  [6:0] barrel_end_xpos_LEFT, barrel_end_ypos_LEFT,
    input  logic  [6:0] barrel_end_xpos_RIGHT, barrel_end_ypos_RIGHT,
    input  logic        end_turn,
    input  logic        enemy_hit,

    // output to indicate which player's turn it is
    output logic  [1:0]  player_turn,
    // interface signals for current player
    output logic  [1:0] hp_CURRENT, hp_ENEMY,
    output logic  [7:0] angle,
    output logic [10:0] projectile_strength,
    output logic  [6:0] fuel,
    // projectile signals
    output logic [11:0] barrel_final_xpos, barrel_final_ypos,
    output logic [11:0] enemy_xpos, enemy_ypos,
    output logic        damaged_LEFT, damaged_RIGHT,
    // LEFT  won => 2'b01
    // RIGHT won => 2'b11
    output logic  [1:0] game_over
);

    import projectile_pkg::*;
    // internal turn register (2-bit)
    logic [1:0] turn; // 2'b01 = LEFT, 2'b10 = RIGHT

    // turn logic
    always_ff @(posedge clk) begin
        if (rst) begin
            game_over <= 2'b00;
            turn <= 2'b01; // start with LEFT player
        end else begin
            if (turn == 2'b01 && end_turn)
                turn <= 2'b10; // switch to RIGHT
            else if (turn == 2'b10 && end_turn)
                turn <= 2'b01; // switch to LEFT
            
            if(end_turn && ((hp_LEFT == 0) || (hp_RIGHT == 0))) begin
                game_over[0] <= (hp_LEFT == 0) || (hp_RIGHT == 0);
                game_over[1] <= (hp_LEFT == 0);
            end
        end
    end

    /**
     * Signals assignments
     */

    // output logic
    always_comb begin : main_game_ctl_blk
        player_turn = turn;
        // select signals for interface depending on turn
        hp_CURRENT          = (turn == 2'b01) ? hp_LEFT  : hp_RIGHT;
        hp_ENEMY            = (turn == 2'b01) ? hp_RIGHT : hp_LEFT;
        angle               = (turn == 2'b01) ? angle_LEFT : angle_RIGHT;
        projectile_strength = (turn == 2'b01) ? strength_LEFT : strength_RIGHT;
        fuel                = (turn == 2'b01) ? fuel_LEFT : fuel_RIGHT;
        // compute barrel final positions
        barrel_final_xpos = (turn == 2'b01) ? 
        (tank_xpos_LEFT  + barrel_end_xpos_LEFT)  : (tank_xpos_RIGHT + barrel_end_xpos_RIGHT - PROJECTILE_RADIUS/2);
        barrel_final_ypos = (turn == 2'b01) ? 
        (tank_ypos_LEFT  + barrel_end_ypos_LEFT)  : (tank_ypos_RIGHT + barrel_end_ypos_RIGHT);
        // enemy position
        enemy_xpos = (turn == 2'b01) ? tank_xpos_RIGHT : tank_xpos_LEFT;
        enemy_ypos = (turn == 2'b01) ? tank_ypos_RIGHT : tank_ypos_LEFT;
        // enemy hit signal
        damaged_LEFT   = (enemy_hit && turn == 2'b10) ? enemy_hit : 1'b0;
        damaged_RIGHT  = (enemy_hit && turn == 2'b01) ? enemy_hit : 1'b0;
    end : main_game_ctl_blk
endmodule
