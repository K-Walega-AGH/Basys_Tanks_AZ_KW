
module explosion_ctl (
    input  logic clk,
    input  logic rst,

    input  logic        terrain_hit,
    input  logic [11:0] explosion_xpos,
    input  logic [11:0] explosion_ypos,
    input  logic [10:0] hcount,
    input  logic [11:0] terrain_y_in,

    output logic [11:0] terrain_x_out,
    output logic [11:0] terrain_y_out,
    output logic        write_en,

    input  logic activate_explosion,            // whether explosion should activate

    output logic       show_animation,
    output logic [2:0] frame_index,   // current animation frame index (0..7)
	output logic       end_turn
);

timeunit 1ns;
timeprecision 1ps;

import projectile_pkg::*;

// FSM states
typedef enum logic [2:0] {
    IDLE,
    START,
    ANIMATE,
    DESTROY_TERRAIN,
	END_TURN
} explosion_state;

explosion_state explosion_st, explosion_st_nxt;

// frame counter
logic [2:0] frame_ctr;
// delay counter to slow down animation
logic [22:0] delay_ctr;
//
logic terrain_hit_detected;
logic [11:0] explosion_depth;

// signals assignments
assign end_turn = (explosion_st == END_TURN);

always_ff @(posedge clk) begin
    if(rst) begin
        frame_index <= '0;
        frame_ctr   <= '0;
        delay_ctr   <= '0;
        show_animation <= '0;
        write_en <= '0;
		
        explosion_st   <= IDLE;
    end else begin
        case(explosion_st)
            IDLE: begin
                // do nothing
                show_animation <= '0;
                terrain_x_out <= '0;
                terrain_y_out <= '0;
            end
			
            START: begin
                frame_ctr      <= '0;
                show_animation <= '1;
                terrain_x_out <= '0;
                terrain_y_out <= '0;
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
                terrain_x_out <= '0;
                terrain_y_out <= '0;
            end

            DESTROY_TERRAIN: begin
                write_en <= '0;
                // WORKS VERY BAD
                if (hcount >= explosion_xpos && hcount < explosion_xpos + EXPLOSION_REAL_RADIUS) begin
                    if (terrain_y_in <= explosion_depth) begin
                        terrain_x_out <= {1'b0, hcount};
                        terrain_y_out <= explosion_depth;
                        write_en <= '0;//'1; // NOT ENOUGH TIME TO FINISH DESTRUCTION, STOP WRITING
                    end else begin
                        terrain_y_out <= terrain_y_in;
                    end
                end else begin
                    terrain_y_out <= terrain_y_in;
                end
                terrain_hit_detected <= '0;
            end

            END_TURN: begin
                // just in this state for 1 clk
                show_animation <= '0;
                terrain_x_out <= '0;
                terrain_y_out <= '0;
            end
        endcase
        if(terrain_hit)
            terrain_hit_detected <= '1;

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
                if(terrain_hit_detected)
                    explosion_st_nxt = DESTROY_TERRAIN;
                else
                    explosion_st_nxt = END_TURN;
            else
                explosion_st_nxt = ANIMATE;
        end
        DESTROY_TERRAIN: begin
            if (hcount == explosion_xpos + EXPLOSION_REAL_RADIUS)
                explosion_st_nxt = END_TURN;
            else
                explosion_st_nxt = DESTROY_TERRAIN;
        end
		
        END_TURN: begin
            explosion_st_nxt = IDLE;
        end
    endcase
end

// calc current depth of explosion
always_comb begin
    case (hcount+1-explosion_xpos)
        5'd0, 5'd1, 5'd2, 5'd3, 5'd4, 5'd5, 5'd6, 5'd7:
            explosion_depth = explosion_ypos + EXPLOSION_RADIUS;

        5'd8, 5'd9, 5'd10, 5'd11, 5'd12, 5'd13, 5'd14, 5'd15:
            explosion_depth = explosion_ypos + EXPLOSION_RADIUS;

        5'd16, 5'd17, 5'd18, 5'd19, 5'd20, 5'd21, 5'd22, 5'd23:
            explosion_depth = explosion_ypos + EXPLOSION_RADIUS;

        default: // 5'd-1 and 5'd24 cases
            explosion_depth = terrain_y_in;
    endcase
end

endmodule
