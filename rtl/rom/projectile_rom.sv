
module projectile_rom (
    input  logic clk,
    input  logic [19:0] address,  // address = {addry[9:0], addrx[9:0]}
    output logic [11:0] rgb
);

import projectile_pkg::*;

/**
 * Local variables and signals
 */

reg [11:0] rom [0:(PROJECTILE_RADIUS*PROJECTILE_RADIUS -1)];

/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/data_files/projectile1.data", rom);

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[12:10],address[2:0]}];  // update if change in size
end

endmodule
