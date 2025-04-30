
module draw_rect_ctl_prog (
    input logic clk,
    input logic rst,
    output logic [11:0] xpos_in,
    output logic [11:0] ypos_in,
    output logic        left
);

    typedef enum logic [2:0] {
        INIT,
        MOVE_MOUSE,
        PRESS_LEFT,
        WAIT_FALL,
        DONE
    } prog_state_t;

    prog_state_t state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            xpos_in <= 12'd0;
            ypos_in <= 12'd0;       // Wysoko, żeby był efekt "spadania"
            left    <= 0;
            state   <= INIT;
        end else begin
            case (state)
                INIT: begin
                    xpos_in <= 12'd0;
                    ypos_in <= 12'd0;
                    left    <= 0;
                    state   <= MOVE_MOUSE;
                end

                MOVE_MOUSE: begin
                    // Ustawiamy pozycję myszy w górnej części ekranu bez przycisku
                    xpos_in <= 12'd320;
                    ypos_in <= 12'd10;
                    left    <= 0;
                    state <= PRESS_LEFT;
                end

                PRESS_LEFT: begin
                    left <= 1;
                    state <= WAIT_FALL;
                end

                WAIT_FALL: begin
                        left <= 0;
                        state <= WAIT_FALL;
                end

                DONE: begin
                    // Nic nie robimy więcej
                end
            endcase
        end
    end

endmodule
