
module draw_rect_ctl (
    input  logic        clk,
    input  logic        rst, 
    input  logic [11:0] xpos_in,
    input  logic [11:0] ypos_in,
    input  logic        left,

    output logic [11:0] xpos_out,
    output logic [11:0] ypos_out
);

import vga_pkg::*;

/*
 * g = 9,81 [m/s^2]
 * 1 cycle (for 40MHz clk) = 25 * 10^-9 [s]
 * Using "cycles", bcs I have implemented delay to see falling better
 * 
 * velocity increase:
 * V = g* 1 cycle = 2,4525 * 10^-7 [m/cycle]
 * 
 * scale to pixels:
 * 0,3m = 600 pixels -> 1m = 2000 pixels
 * V_pix = V * 2000 = 4,905 * 10^-4 [pixels/cycle]
 * 
 * Q12.20 formating:
 * GRAVITY = V_pix << 20 = 514
 */
localparam GRAVITY = 514;
localparam YPOS_DESTINATION = VER_PIXELS - HEIGHT_VER_Y - 1;
localparam DELAY = 40_000;  // delay by 1ms , clk 40MHz ; DECREASE FOR SIMULATION
localparam DAMPING = 13; // zamiana 0.8 na Q1.4 ->  0.8 * 2^4


typedef enum logic [2:0] {      // Finite State Machine, at the end stays in STOP state
    IDLE,
    START,
    FALLING,
    BOUNCING,
    STOP
} state_t;

state_t state, state_nxt;

logic [11:0] xpos_locked;
logic [31:0] ypos_nxt;      // Q12.20 format
logic [31:0] ypos_start;
logic [23:0] delay_counter;
logic [31:0] velocity;      // Q12.20 format
logic        falling;

always_ff @(posedge clk) begin
    if (rst) begin
        xpos_out        <= '0;
        ypos_out        <= '0;
        xpos_locked     <= '0;
        ypos_nxt        <= '0;
        ypos_start      <= '0;
        delay_counter   <= '0;
        velocity        <= '0;
        falling         <= '0;

        state <= IDLE;
    end else begin
        state <= state_nxt;

        case (state)
            IDLE: begin
                xpos_out <= xpos_in;
                ypos_out <= ypos_in;
            end

            START: begin
                if(!falling) begin
                    xpos_out <= xpos_in;
                    ypos_out <= ypos_in;

                    ypos_nxt <= '0;
                    xpos_locked     <= xpos_in;
                    ypos_nxt[31:20] <= ypos_in;
                    ypos_start[31:20] <= ypos_in;
                    falling <= '1;
                end else begin
                    xpos_out <= xpos_locked;
                    ypos_out <= ypos_nxt[31:20];
                end
                delay_counter    <= '0;
                velocity         <= '0;
            end

            FALLING: begin
                xpos_out <= xpos_locked;
                ypos_out <= ypos_nxt[31:20];

                if (delay_counter < DELAY) begin        // added delay to see falling better
                    delay_counter <= delay_counter + 1;
                end else begin
                    velocity <= velocity + GRAVITY;
                    ypos_nxt <= ypos_nxt + velocity;
                    delay_counter <= 0;
                    if(ypos_nxt[31:20] + velocity[31:20] >= YPOS_DESTINATION) begin
                        velocity <= ((velocity * DAMPING) >> 4);
                    end
                end
            end

            BOUNCING: begin
                xpos_out <= xpos_locked;
                ypos_out <= ypos_nxt[31:20];

                if (delay_counter < DELAY) begin        // added delay to see falling better
                    delay_counter <= delay_counter + 1;
                end else begin
                    ypos_nxt <= ypos_nxt - velocity;
                    if(velocity >= GRAVITY) begin
                        velocity <= velocity - GRAVITY;
                    end else begin
                        ypos_start <= ypos_nxt;
                    end
                    delay_counter <= 0;
                end
            end

            STOP: begin
                xpos_out <= xpos_locked;
                ypos_out <= YPOS_DESTINATION;
            end
        endcase
    end
end

always_comb begin
    state_nxt = state;

    case (state)
        IDLE: begin
            if (left) begin
                state_nxt = START;
            end else begin
                state_nxt = IDLE;
            end
        end

        START: begin
            state_nxt = FALLING;

        end

        FALLING: begin
            if(ypos_nxt[31:20] + velocity[31:20] <= YPOS_DESTINATION) begin
                if(ypos_out == YPOS_DESTINATION && velocity < GRAVITY) begin
                    state_nxt = STOP;
                end else begin
                    state_nxt = FALLING;
                end
            end else begin
                state_nxt = BOUNCING;
            end
        end

        BOUNCING: begin
            if( ypos_nxt - velocity >= ypos_start) begin
                state_nxt = BOUNCING;
            end else begin
                state_nxt = START;
            end
        end

        STOP: begin
            state_nxt = STOP;   //Stay in STOP state after finished falling
        end
    endcase
end

endmodule