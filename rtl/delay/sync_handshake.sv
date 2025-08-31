// ========================================
// HANDSHAKE BRIDGE: clkA -> clkB
// ========================================
module sync_handshake (
    input  logic        clkA, rstA,
    input  logic        clkB, rstB,

    // source domain (clkA)
    input  logic [7:0]  data_in,
    input  logic        data_valid,   // sygna� startu
    output logic        data_ready,   // odpowied� z clkB

    // destination domain (clkB)
    output logic [7:0]  data_out,
    output logic        data_valid_out, // pulsy w clkB
    input  logic        data_ready_out  // konsumpcja w clkB
);

    // ====== SYNC VALID (clkA -> clkB) ======
    logic        validA, validB_sync;
    logic [7:0]  data_reg;

    // rejestr w clkA
    always_ff @(posedge clkA or posedge rstA) begin
        if (rstA) begin
            validA   <= 1'b0;
            data_reg <= '0;
        end else begin
            if (data_valid && !validA) begin
                data_reg <= data_in;
                validA   <= 1'b1; // wystaw dane
            end else if (data_ready) begin
                validA <= 1'b0;   // zdejmij gdy odebrane
            end
        end
    end

    // synchronizacja validA do clkB
    logic validA_sync1, validA_sync2;
    always_ff @(posedge clkB or posedge rstB) begin
        if (rstB) {validA_sync1, validA_sync2} <= 2'b0;
        else      {validA_sync1, validA_sync2} <= {validA, validA_sync1};
    end
    assign validB_sync = validA_sync2;

    // ====== ODBIORNIK (clkB) ======
    always_ff @(posedge clkB or posedge rstB) begin
        if (rstB) begin
            data_out       <= '0;
            data_valid_out <= 1'b0;
        end else begin
            if (validB_sync && !data_valid_out) begin
                data_out       <= data_reg;   // pobierz dane
                data_valid_out <= 1'b1;       // zg�o� gotowo��
            end else if (data_ready_out) begin
                data_valid_out <= 1'b0;
            end
        end
    end

    // ====== SYNC READY (clkB -> clkA) ======
    logic readyB, readyA_sync1, readyA_sync2;
    assign readyB = data_ready_out & data_valid_out;

    always_ff @(posedge clkA or posedge rstA) begin
        if (rstA) {readyA_sync1, readyA_sync2} <= 2'b0;
        else      {readyA_sync1, readyA_sync2} <= {readyB, readyA_sync1};
    end
    assign data_ready = readyA_sync2;

endmodule
