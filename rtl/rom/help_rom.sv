
module help_rom 
#(
    AMOUNT_OF_LETTERS = 32
)(
    input  logic [14:0] char_xy,
    output logic [6:0] char_code,
    output logic [5:0] used_lines
);

parameter string ASCII_mess = "\
                                                                                                \
   CONTROLS:                                                                                    \
                                                                                                \
------------------------------------------------------------------------------------------------\
                                                                                                \
 H (HOLD) - help menu                                                                           \
                                                                                                \
 ARROW RIGHT / ARROW LEFT - movement of the tank                                                \
                                                                                                \
 ARROW UP / ARROW DOWN - control the angle of the barrel                                        \
                                                                                                \
 SPACE (PRESS/HOLD) - fire the projectile                                                       \
                                                                                                \   ";  

localparam int MESS_LENGTH = $bits(ASCII_mess)/8;

always_comb begin : char_rom_comb_blk
    used_lines = (MESS_LENGTH + AMOUNT_OF_LETTERS - 1) / AMOUNT_OF_LETTERS;
    char_code = ASCII_mess[char_xy];
end : char_rom_comb_blk

endmodule