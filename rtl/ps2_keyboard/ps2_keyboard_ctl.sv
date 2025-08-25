module ps2_keyboard_ctl (
    input  logic clk,
    input  logic rst,

    input  logic [7:0] rx_data,
    input  logic       read_data,

    output logic H,
    output logic F,
    output logic key_1,
    output logic key_5,
    output logic enter,
    output logic space,
    output logic arrow_up,
    output logic arrow_down,
    output logic arrow_left,
    output logic arrow_right
);

    timeunit 1ns;
    timeprecision 1ps;

    typedef enum logic [2:0] {
        IDLE,
        E0_RECIEVED,
        F0_RECIEVED,
        SET_KEY,
        STOP_KEY
    } keyboard_state;

    keyboard_state keyboard_st, keyboard_st_nxt;

    logic [7:0] scancode;
    logic       e0_flag;

    // Output registers & state <= state_nxt
    always_ff @(posedge clk) begin
        if (rst) begin
            H            <= '0;
            F            <= '0;
            key_1        <= '0;
            key_5        <= '0;
            enter        <= '0;
            space        <= '0;
            arrow_up     <= '0;
            arrow_down   <= '0;
            arrow_left   <= '0;
            arrow_right  <= '0;
            scancode     <= '0;
            e0_flag      <= '0;

            keyboard_st <= IDLE;
        end else begin
            case (keyboard_st)
                IDLE: begin
                    // if not extended or breakcode => normal key
                    if(rx_data != 8'hF0 || rx_data != 8'hE0) begin
                        scancode <= rx_data;
                    end
                end

                E0_RECIEVED: begin
                    e0_flag <= '1;
                    scancode <= rx_data;
                end

                F0_RECIEVED: begin
                    scancode <= rx_data;
                end

                SET_KEY: begin
                    case ({e0_flag, scancode})
                        9'h033: H           <= 1'b1; // is ok
                        9'h02B: F           <= 1'b1; // is ok
                        9'h016: key_1       <= 1'b1; // is ok
                        9'h016: key_5       <= 1'b1; // is ok
                        9'h05A: enter       <= 1'b1; // is ok
                        9'h029: space       <= 1'b1; // is ok
                        9'h075: arrow_up    <= 1'b1; // should be 9'h175 but my kb is weird
                        9'h072: arrow_down  <= 1'b1; // should be 9'h172 but my kb is weird
                        9'h06B: arrow_left  <= 1'b1; // should be 9'h16B but my kb is weird
                        9'h174: arrow_right <= 1'b1; // is ok
                    endcase
                    e0_flag <= '0;
                end

                STOP_KEY: begin
                    case ({e0_flag,scancode})
                        9'h033: H           <= 1'b0; // is ok
                        9'h02B: F           <= 1'b0; // is ok
                        9'h016: key_1       <= 1'b0; // is ok
                        9'h016: key_5       <= 1'b0; // is ok
                        9'h05A: enter       <= 1'b0; // is ok
                        9'h029: space       <= 1'b0; // is ok
                        9'h075: arrow_up    <= 1'b0; // should be 9'h175 but my kb is weird
                        9'h072: arrow_down  <= 1'b0; // should be 9'h172 but my kb is weird
                        9'h06B: arrow_left  <= 1'b0; // should be 9'h16B but my kb is weird
                        9'h174: arrow_right <= 1'b0; // is ok
                    endcase
                    e0_flag <= '0;
                end
            endcase

            keyboard_st <= keyboard_st_nxt;
        end
    end
    
    // Next-state logic
    always_comb begin
        case (keyboard_st)
            IDLE: begin
                if(read_data) begin
                    if(rx_data == 8'hE0) begin
                        keyboard_st_nxt = E0_RECIEVED;
                    end else
                    if(rx_data == 8'hF0) begin
                        keyboard_st_nxt = F0_RECIEVED;
                    end else begin
                        keyboard_st_nxt = SET_KEY;
                    end
                end else begin
                    keyboard_st_nxt = IDLE;
                end 
            end

            E0_RECIEVED: begin
                if(read_data) begin
                    if (rx_data == 8'hF0) begin
                        keyboard_st_nxt = F0_RECIEVED;
                    end else begin
                        keyboard_st_nxt = SET_KEY;
                    end
                end else begin
                    keyboard_st_nxt = E0_RECIEVED;
                end
            end

            F0_RECIEVED: begin
                if (read_data) begin
                    keyboard_st_nxt = STOP_KEY;
                end else begin
                    keyboard_st_nxt = F0_RECIEVED;
                end
            end

            SET_KEY: begin
                keyboard_st_nxt = IDLE;
            end

            STOP_KEY: begin
                keyboard_st_nxt = IDLE;
            end
        endcase
    end

endmodule
