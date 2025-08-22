
module barrel_ctl
    #(
        PLAYER_ID = 1
    )(
    input  logic clk,
    input  logic rst,

    // change_angle[0] = 1 <== Angle input is pressed(UP or DOWN);
    // change_angle[1] = 0 <== move DOWN
    // change_angle[1] = 1 <== move UP
    input  logic [1:0] change_angle,
    input  logic       your_turn,
    output logic [2:0] angle_index,
    output logic [7:0] angle,

    // !!! it is barrel's end relative position !!!
    output logic [6:0] barrel_end_xpos,
    output logic [6:0] barrel_end_ypos
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
logic [21:0] delay_ctr;

always_ff @(posedge clk) begin
    if(rst) begin
        angle_index <= '0;
        angle       <= '0;
        angle_ctr   <= '0;
        delay_ctr   <= '0;
        
        barrel_end_xpos <= 'd64;
        barrel_end_ypos <= 'd34;

        barrel_st   <= IDLE;
    end else begin
        case(barrel_st)
            IDLE: begin
            end

            CHANGE_ANGLE: begin
                if(change_angle[0])begin
                    if(delay_ctr < ANGLE_DELAY) begin
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
                        angle <= angle_ctr;
                        // main cases for changing barrel rom
                        if (PLAYER_ID == 1) begin
                            if(angle_ctr >= 0 && angle_ctr < 12) begin
                                angle_index <= 3'd0;
                                barrel_end_xpos <= 'd64;
                                barrel_end_ypos <= 'd34;
                            end else if(angle_ctr >= 12 && angle_ctr < 24) begin
                                angle_index <= 3'd1;
                                barrel_end_xpos <= 'd63;
                                barrel_end_ypos <= 'd28;
                            end else if(angle_ctr >= 24 && angle_ctr < 36) begin
                                angle_index <= 3'd2;
                                barrel_end_xpos <= 'd62;
                                barrel_end_ypos <= 'd24;
                            end else if(angle_ctr >= 36 && angle_ctr < 48) begin
                                angle_index <= 3'd3;
                                barrel_end_xpos <= 'd60;
                                barrel_end_ypos <= 'd20;
                            end else if(angle_ctr >= 48 && angle_ctr < 60) begin
                                angle_index <= 3'd4;
                                barrel_end_xpos <= 'd53;
                                barrel_end_ypos <= 'd17;
                            end else if(angle_ctr >= 60 && angle_ctr < 72) begin
                                angle_index <= 3'd5;
                                barrel_end_xpos <= 'd50;
                                barrel_end_ypos <= 'd14;
                            end else if(angle_ctr >= 72 && angle_ctr < 84) begin
                                angle_index <= 3'd6;
                                barrel_end_xpos <= 'd46;
                                barrel_end_ypos <= 'd14;
                            end else if(angle_ctr >= 84 && angle_ctr < 90) begin
                                angle_index <= 3'd7;
                                barrel_end_xpos <= 'd42;
                                barrel_end_ypos <= 'd12;
                            end
                        end else begin
                            if(angle_ctr >= 0 && angle_ctr < 12) begin
                                angle_index <= 3'd0;
                                barrel_end_xpos <= 'd64;
                                barrel_end_ypos <= 'd34;
                            end else if(angle_ctr >= 12 && angle_ctr < 24) begin
                                angle_index <= 3'd1;
                                barrel_end_xpos <= 'd63;
                                barrel_end_ypos <= 'd28;
                            end else if(angle_ctr >= 24 && angle_ctr < 36) begin
                                angle_index <= 3'd2;
                                barrel_end_xpos <= 'd62;
                                barrel_end_ypos <= 'd24;
                            end else if(angle_ctr >= 36 && angle_ctr < 48) begin
                                angle_index <= 3'd3;
                                barrel_end_xpos <= 'd60;
                                barrel_end_ypos <= 'd20;
                            end else if(angle_ctr >= 48 && angle_ctr < 60) begin
                                angle_index <= 3'd4;
                                barrel_end_xpos <= 'd53;
                                barrel_end_ypos <= 'd17;
                            end else if(angle_ctr >= 60 && angle_ctr < 72) begin
                                angle_index <= 3'd5;
                                barrel_end_xpos <= 'd50;
                                barrel_end_ypos <= 'd14;
                            end else if(angle_ctr >= 72 && angle_ctr < 84) begin
                                angle_index <= 3'd6;
                                barrel_end_xpos <= 'd46;
                                barrel_end_ypos <= 'd14;
                            end else if(angle_ctr >= 84 && angle_ctr < 90) begin
                                angle_index <= 3'd7;
                                barrel_end_xpos <= 'd42;
                                barrel_end_ypos <= 'd12;
                            end
                        end
                        //---------------------------------------------
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