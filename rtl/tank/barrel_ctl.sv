
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
logic [7:0] angle_ctr;
// delay for animation
logic [19:0] delay_ctr;

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        angle_index <= '0;
        angle_ctr   <= '0;
        delay_ctr   <= '0;

        barrel_st   <= IDLE;
    end else begin
        case(barrel_st)
            IDLE: begin
            end

            CHANGE_ANGLE: begin
                if(change_angle[0])begin
                    if(delay_ctr < MOVE_DELAY) begin
                        delay_ctr <= delay_ctr + 1;
                    end else begin
                        if(change_angle[1]) begin   // barrel UP
                            if(angle_ctr < 90)
                                angle_ctr <= angle_ctr + 1;
                        end else begin              // barrel DOWN
                            if(angle_ctr > 0)
                                angle_ctr <= angle_ctr - 1;
                        end
                        delay_ctr <= '0;
                        // main cases for changing barrel rom
                        if(angle_ctr >= 0 && angle_ctr < 12)
                            angle_index <= 3'd0;
                        else if(angle_ctr >= 12 && angle_ctr < 24)
                            angle_index <= 3'd1;
                        else if(angle_ctr >= 24 && angle_ctr < 36)
                            angle_index <= 3'd2;
                        else if(angle_ctr >= 36 && angle_ctr < 48)
                            angle_index <= 3'd3;
                        else if(angle_ctr >= 48 && angle_ctr < 60)
                            angle_index <= 3'd4;
                        else if(angle_ctr >= 60 && angle_ctr < 72)
                            angle_index <= 3'd5;
                        else if(angle_ctr >= 72 && angle_ctr < 84)
                            angle_index <= 3'd6;
                        else if(angle_ctr >= 84 && angle_ctr < 90)
                            angle_index <= 3'd7;
                    end
                end
            end

            WAITING: begin
            end
        endcase

        barrel_st   <= barrel_st_nxt;
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
            if(!your_turn)begin
                barrel_st_nxt = WAITING;
            end else begin
                barrel_st_nxt = CHANGE_ANGLE;
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