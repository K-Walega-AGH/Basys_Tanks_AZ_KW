
module explosion_ctl (
    input  logic clk,
    input  logic rst,

    input  logic activate_explosion,            // whether explosion should activate

    output logic       show_animation,
    output logic [2:0] frame_index,   // current animation frame index (0..7)
	output logic       end_turn
);

timeunit 1ns;
timeprecision 1ps;

import projectile_pkg::*;

// FSM states
typedef enum logic [1:0] {
    IDLE,
    START,
    ANIMATE,
	END_TURN
} explosion_state;

explosion_state explosion_st, explosion_st_nxt;

// frame counter
logic [2:0] frame_ctr;
// delay counter to slow down animation
logic [22:0] delay_ctr;

// signals assignments
assign end_turn = (explosion_st == END_TURN);

always_ff @(posedge clk) begin
    if(rst) begin
        frame_index <= '0;
        frame_ctr   <= '0;
        delay_ctr   <= '0;
        show_animation <= '0;
		
        explosion_st   <= IDLE;
    end else begin
        case(explosion_st)
            IDLE: begin
                show_animation <= '0;
                // do nothing
            end
			
            START: begin
                frame_ctr      <= '0;
                show_animation <= '1;
            end

            ANIMATE: begin
                if(delay_ctr < EXPLOSION_DELAY) begin
                    delay_ctr <= delay_ctr + 1;
                end else begin
                    frame_index <= frame_ctr;
                    delay_ctr   <= '0;
                    if(frame_ctr < 7) begin
                        frame_ctr <= frame_ctr + 1;
                    end else begin
                        frame_ctr <= frame_ctr;
                    end
                end
            end
            END_TURN: begin
                show_animation <= '0;
                // just in this state for 1 clk
            end
        endcase

        explosion_st <= explosion_st_nxt;
    end
end

always_comb begin
    case(explosion_st)
        IDLE: begin
            if(activate_explosion)
                explosion_st_nxt = START;
            else
                explosion_st_nxt = IDLE;
        end

        START: begin
            explosion_st_nxt = ANIMATE;
        end

        ANIMATE: begin
            if(frame_ctr == 7)
                explosion_st_nxt = END_TURN;
            else
                explosion_st_nxt = ANIMATE;
        end
		
        END_TURN: begin
            explosion_st_nxt = IDLE;
        end
    endcase
end

endmodule
