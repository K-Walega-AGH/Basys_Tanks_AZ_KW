module top_vga_ctl (
    input  logic clk,
    input  logic rst,
    // tank signals
    input  logic  [1:0] hp_LEFT, hp_RIGHT,
    input  logic  [7:0] angle_LEFT, angle_RIGHT,
    input  logic [10:0] strength_LEFT, strength_RIGHT,
    input  logic [10:0] fuel_LEFT, fuel_RIGHT,
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
    output logic [10:0] fuel,
    // projectile signals
    output logic [11:0] barrel_final_xpos, barrel_final_ypos,
    output logic [11:0] enemy_xpos, enemy_ypos,
    output logic        damaged_LEFT, damaged_RIGHT
);

    // internal turn register (2-bit)
    logic [1:0] turn; // 2'b01 = LEFT, 2'b10 = RIGHT

    // turn logic
    always_ff @(posedge clk) begin
        if (rst) begin
            turn <= 2'b01; // start with LEFT player
        end else begin
            if (turn == 2'b01 && end_turn)
                turn <= 2'b10; // switch to RIGHT
            else if (turn == 2'b10 && end_turn)
                turn <= 2'b01; // switch to LEFT
        end
    end

    /**
     * Signals assignments
     */

    // assign turn signals to tanks

    // assign turn to output
    assign player_turn = turn;

    // select signals for interface depending on turn
    assign hp_CURRENT          = (turn == 2'b01) ? hp_LEFT  : hp_RIGHT;
    assign hp_ENEMY            = (turn == 2'b01) ? hp_RIGHT : hp_LEFT;
    assign angle               = (turn == 2'b01) ? angle_LEFT : angle_RIGHT;
    assign projectile_strength = (turn == 2'b01) ? strength_LEFT : strength_RIGHT;
    assign fuel                = (turn == 2'b01) ? fuel_LEFT : fuel_RIGHT;

    // compute barrel final positions
    assign barrel_final_xpos = (turn == 2'b01) ? 
    (tank_xpos_LEFT  + barrel_end_xpos_LEFT)  : (tank_xpos_RIGHT + barrel_end_xpos_RIGHT);
    assign barrel_final_ypos = (turn == 2'b01) ? 
    (tank_ypos_LEFT  + barrel_end_ypos_LEFT)  : (tank_ypos_RIGHT + barrel_end_ypos_RIGHT);

    // enemy position
    assign enemy_xpos = (turn == 2'b01) ? tank_xpos_RIGHT : tank_xpos_LEFT;
    assign enemy_ypos = (turn == 2'b01) ? tank_ypos_RIGHT : tank_ypos_LEFT;
    // enemy hit signal
    assign damaged_LEFT   = (enemy_hit && turn == 2'b10) ? enemy_hit : 1'b0;
    assign damaged_RIGHT  = (enemy_hit && turn == 2'b01) ? enemy_hit : 1'b0;

endmodule
