module ps2_display (
    input  logic clk,
    input  logic rst,
    
    input  logic [7:0] rx_data,
    input  logic read_data,             // z ps2_interface, sygnał gdy dane są gotowe
    
    output logic [7:0] sseg,
    output logic [3:0] an
);

    // HEX digits for display
    logic [7:0] byte_current, byte_previous, byte_2ago;
    logic [3:0] hex0, hex1, hex2, hex3;

    // hex assignment
    assign hex0 = byte_current[3:0];
    assign hex1 = byte_current[7:4];
    assign hex2 = byte_previous[3:0];
    assign hex3 = byte_previous[7:4];

    // capture data
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_current  <= 8'd0;
            byte_previous <= 8'd0;
            byte_2ago     <= 8'd0;
        end else begin
            if (read_data) begin
                byte_2ago     <= byte_previous;
                byte_previous <= byte_current;
                byte_current  <= rx_data;
            end
        end
    end

    // Use existing 7-segment display driver
    disp_hex_mux seg7display (
        .clk(clk),
        .reset(rst),
        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0),
        .dp_in(4'b1111),    // dots off
        .an(an),
        .sseg(sseg)
    );

endmodule
