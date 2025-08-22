
module border_fuel_rom (
    input  logic clk,
    input  logic [19:0] address,  // address = {addry[9:0], addrx[9:0]}
    output logic [11:0] rgb
);

import interface_pkg::*;

/**
 * Local variables and signals
 */

reg [11:0] rom [0:(BORDER_STR_WIDTH*BORDER_STR_HEIGHT -1)];

/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/data_files/border_fuel.data", rom);

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[14:10],address[6:0]}];  // update if change in size
end

endmodule
