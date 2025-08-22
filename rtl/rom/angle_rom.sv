
module angle_rom (
    input  logic  [7:0] angle,
    input  logic [14:0] char_xy,
    output logic  [6:0] char_code,
    output logic  [5:0] used_lines
);
    parameter string PREFIX = "ANGLE: ";
    localparam PREFIX_LEN = $bits(PREFIX)/8;
    localparam logic [6:0] CHAR_0   = 7'h30;    // code for ZERO
    localparam logic [6:0] CHAR_SPACE = 7'h20;  // code for SPACE
    localparam logic [6:0] CHAR_DEG   = 7'h09;  // code for DEGREES
    
    logic [3:0] tens, ones;

    always_comb begin
        // divide number into tens and ones
        tens = angle / 10;
        ones = angle - 10*tens;
        // oneliner :P
        used_lines = 1;
        if (char_xy < PREFIX_LEN) begin
            // text from PREFIX
            char_code = PREFIX[char_xy];
        end else begin
            case (char_xy - PREFIX_LEN)
                0: char_code = (tens==0) ? (CHAR_0 + ones) : (CHAR_0 + tens);  // tens, w/o leading zero
                1: char_code = (tens==0) ? CHAR_DEG : (CHAR_0 + ones);         // ones
                2: char_code = (tens==0) ? CHAR_SPACE : CHAR_DEG;              // degree symbol
                default: char_code = CHAR_SPACE;
            endcase
        end
    end

endmodule
