
module char_rom (
    input   logic    [7:0] char_xy,
    output  logic    [6:0] char_code
);

parameter string ASCII_mess =
"HELLO WORLD! Wazzup Beijing 'b32\
->|NEXT LINE HERE|<-    (^-^)   \
    >_< --- d-_-b  ---  /[ ]-----\
--HOLYY SMOKES-IT-KEEPS-GOING-----\
------STO-P--IT--PL-eas-eEAEAAAaAaaAAAaAAAAAaa...   X_X";  

always_comb begin : char_rom_comb_blk
    char_code = ASCII_mess[char_xy];
end : char_rom_comb_blk

endmodule