
module text_rom #(
    parameter string TEXT = " ",
    parameter AMOUNT_OF_LETTERS = 32
)(
    input  logic [14:0] char_xy,
    output logic  [6:0] char_code,
    output logic  [5:0] used_lines
);

    localparam TEXT_LENGTH = $bits(TEXT)/8;

    always_comb begin
        used_lines = (TEXT_LENGTH + AMOUNT_OF_LETTERS - 1) / AMOUNT_OF_LETTERS;
        char_code = TEXT[char_xy];
    end

endmodule
