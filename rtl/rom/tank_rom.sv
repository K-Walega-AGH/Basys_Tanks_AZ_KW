
module tank_rom (
    input  logic clk,
    input  logic [19:0] address,  // address = {addry[9:0], addrx[9:0]}
    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

reg [11:0] rom [0:16_383];    // 128x128 for BRAM

/**
 * Memory    ization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/data_files/tank.data", rom);

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[16:10],address[6:0]}];
end

endmodule
