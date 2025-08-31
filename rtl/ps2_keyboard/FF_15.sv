
module FF_15 (
    input  logic clk,
    input  logic clk100MHz,
    input  logic rst,

    input  logic [7:0] rx_data,  // PS/2 scan code input
    input  logic       read_data,

    output logic game_over_CODE
);

    // ====== FSM STATES ======
    typedef enum logic [2:0] {
        S_IDLE,
        S_F1,
        S_F2,
        S_1,
        S_5
    } state_t;

    state_t st, st_nxt;

    // ====== INPUT FLAGS FROM RX_DATA ======
    logic F_pressed, key1_pressed, key5_pressed, wrong_key;

    // ====== SYNC RX_DATA TO 60MHZ CLK ======
    // sygna�y handshake
    logic        rx_ready;       // "odebrane"
    logic [7:0]  rx_data_sync;   // bezpiecznie przeniesiony bajt
    logic        rx_data_valid;  // 1 cykl puls w clk (dest)

    // instancja handshake bridge
    sync_handshake u_rx_cdc (
        .clkA(clk100MHz), .rstA(rst),        // �r�d�o = UART/PS2 domena
        .clkB(clk),       .rstB(rst),        // cel = FSM w FF_15

        .data_in(rx_data),                   // dane z PS/2 (8 bit)
        .data_valid(read_data),              // w��czasz, gdy dost�pny bajt
        .data_ready(rx_ready),               // handshake odpowied�

        .data_out(rx_data_sync),             // zsynchronizowane dane
        .data_valid_out(rx_data_valid),      // 1 cykl puls w clk
        .data_ready_out(1'b1)                // FSM zawsze pobiera dane
    );

    // ====== FLAG GENERATION FROM PS/2 DATA ======
    always_comb begin
        F_pressed    = 1'b0;
        key1_pressed = 1'b0;
        key5_pressed = 1'b0;
        wrong_key    = 1'b0;

        if (rx_data_valid && rx_data_sync != 8'hF0) begin  // ignore break code
            case (rx_data_sync)
                8'h2B: F_pressed    = 1'b1; // F
                8'h16: key1_pressed = 1'b1; // 1
                8'h2E: key5_pressed = 1'b1; // 5
                default: wrong_key  = 1'b1; // any other key
            endcase
        end
    end

    // ====== OUTPUT/STATE LOGIC ======
    always_ff @(posedge clk) begin
        if (rst) begin
            st <= S_IDLE;
            game_over_CODE <= 1'b0;
        end else begin
            st <= st_nxt;
            // generate 1 clk pulse when reaching S_5
            game_over_CODE <= (st_nxt == S_5);
        end
    end

    // ====== NEXT STATE LOGIC ======
    always_comb begin
        case (st)
            S_IDLE: begin
                if (F_pressed) st_nxt = S_F1;
                else st_nxt = S_IDLE;
            end

            S_F1: begin
                if (F_pressed) st_nxt = S_F2;
                else if (wrong_key) st_nxt = S_IDLE;
                else st_nxt = S_F1;
            end

            S_F2: begin
                if (key1_pressed) st_nxt = S_1;
                else if (wrong_key) st_nxt = S_IDLE;
                else st_nxt = S_F2;
            end

            S_1: begin
                if (key5_pressed) st_nxt = S_5;
                else if (wrong_key) st_nxt = S_IDLE;
                else st_nxt = S_1;
            end

            S_5: begin
                st_nxt = S_IDLE; // reset FSM after successful sequence
            end

            default: st_nxt = S_IDLE;
        endcase
    end

endmodule
