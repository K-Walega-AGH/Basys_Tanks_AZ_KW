
module tank_rom 
#(
    PLAYER_ID = 1
)(
    input  logic clk,
    input  logic [19:0] address,  // address = {addry[9:0], addrx[9:0]}
    output logic [11:0] rgb
);

import tank_pkg::*;

/**
 * Local variables and signals
 */

reg [11:0] rom [0:(TANK_WIDTH*TANK_HEIGHT - 1)];

/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial begin
    case(PLAYER_ID)
        2'd1: $readmemh("../../rtl/data_files/tank_L.data", rom);
        2'd2: $readmemh("../../rtl/data_files/tank_R.data", rom);
        default: $readmemh("../../rtl/data_files/tank_L.data", rom);
    endcase
end

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[15:10],address[5:0]}];  //if tank size changes this also needs to be updated
end

endmodule
