
module barrel_ctl(
    input  logic clk,
    input  logic rst,

    // change_angle[0] = 1 <== Angle input is pressed(UP or DOWN);
    // change_angle[1] = 0 <== move DOWN
    // change_angle[1] = 1 <== move UP
    input  logic [1:0] change_angle,
    input  logic       your_turn,
    output logic [2:0] angle_index
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;
import tank_pkg::*;

// Tank FSM states
typedef enum logic [2:0] {
    IDLE,
    CHANGE_ANGLE,
    WAITING
} barrel_state;

barrel_state barrel_st, barrel_st_nxt;

// angle
// ZAMIENIC NA ZMIENNOPRZECINKOWY FORMAT I DOSTOSOWAC
logic [7:0]angle_ctr;
// na razie

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        angle_ctr <= '0;

        barrel_st <= IDLE;
    end else begin
        barrel_st <= barrel_st_nxt;
        case(barrel_st)
            IDLE: begin
            end
            CHANGE_ANGLE: begin
                if(change_angle[1]) begin // get barrel UP
                    angle_ctr <= angle_ctr + 1;
                    //ustawic limit angle_ctr!!!
                    // zrobic if elsey dla przedzialow - dla danego przedzialu ustawiac angle_index od 0-7
                    
                end else begin
                    angle_ctr <= angle_ctr - 1;
                    //ustawic limit!!!
                end
            end
            WAITING: begin
            end
        endcase
    end

end

always_comb begin
    case(barrel_st)
        IDLE: begin
            if(change_angle[0])begin
                barrel_st_nxt = CHANGE_ANGLE;
            end else begin
                if(!your_turn) begin
                    barrel_st_nxt = WAITING;
                end else begin
                    barrel_st_nxt = IDLE;
                end
            end
        end
        CHANGE_ANGLE: begin
            if(!change_angle[0])begin
                barrel_st_nxt = CHANGE_ANGLE;
            end else begin
                barrel_st_nxt = IDLE;
            end
        end
        WAITING: begin
            if(your_turn)begin
                barrel_st_nxt = IDLE;
            end else begin
                barrel_st_nxt = WAITING;
            end
        end
    endcase
    
end

endmodule