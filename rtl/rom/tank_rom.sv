
module tank_rom (
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
initial $readmemh("../../rtl/data_files/tank.data", rom);

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[15:10],address[5:0]}];  //if tank size changes this also needs to be updated
end

endmodule
