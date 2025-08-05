
module barrel_rom 
#(
    parameter ANGLE_INDEX = 0
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
    case(ANGLE_INDEX)
        3'd0: $readmemh("../../rtl/data_files/barrel/barrel0.data", rom);
        3'd1: $readmemh("../../rtl/data_files/barrel/barrel1.data", rom);
        3'd2: $readmemh("../../rtl/data_files/barrel/barrel2.data", rom);
        3'd3: $readmemh("../../rtl/data_files/barrel/barrel3.data", rom);
        3'd4: $readmemh("../../rtl/data_files/barrel/barrel4.data", rom);
        3'd5: $readmemh("../../rtl/data_files/barrel/barrel5.data", rom);
        3'd6: $readmemh("../../rtl/data_files/barrel/barrel6.data", rom);
        3'd7: $readmemh("../../rtl/data_files/barrel/barrel7.data", rom);
        default: $readmemh("../../rtl/data_files/barrel/barrel0.data", rom);
    endcase
end

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[15:10],address[5:0]}];  //if tank size changes this also needs to be updated
end

endmodule
