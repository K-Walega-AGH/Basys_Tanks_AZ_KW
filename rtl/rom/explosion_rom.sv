module explosion_rom 
#(
    parameter FRAME_INDEX = 0
)(
    input  logic clk,
    input  logic [19:0] address,  // address = {addry[9:0], addrx[9:0]}
    output logic [11:0] rgb
);

import projectile_pkg::*;

/**
 * Local variables and signals
 */

reg [11:0] rom [0:(EXPLOSION_RADIUS*EXPLOSION_RADIUS - 1)];

/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial begin
    case(FRAME_INDEX)
        3'd0: $readmemh("../../rtl/data_files/explosion/explosion0.data", rom);
        3'd1: $readmemh("../../rtl/data_files/explosion/explosion1.data", rom);
        3'd2: $readmemh("../../rtl/data_files/explosion/explosion2.data", rom);
        3'd3: $readmemh("../../rtl/data_files/explosion/explosion3.data", rom);
        3'd4: $readmemh("../../rtl/data_files/explosion/explosion4.data", rom);
        3'd5: $readmemh("../../rtl/data_files/explosion/explosion5.data", rom);
        3'd6: $readmemh("../../rtl/data_files/explosion/explosion6.data", rom);
        3'd7: $readmemh("../../rtl/data_files/explosion/explosion7.data", rom);
        default: $readmemh("../../rtl/data_files/explosion/explosion0.data", rom);
    endcase
end

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[14:10], address[4:0]}]; // if size changes, update this
end

endmodule
