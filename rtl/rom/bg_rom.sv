
module bg_rom (
    input  logic clk ,
    input  logic [11:0] address,  // address = {addry[5:0], addrx[5:0]}
    output logic [11:0] rgb
);


/**
 * Local variables and signals
 */

reg [11:0] rom [0:131_071];    // docelowo 1024x768

/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial $readmemh("../../rtl/data_files/bg_files/bg2_rom.data", rom);


/**
 * Internal logic
 */

always_ff @(posedge clk)
    rgb <= rom[address];

endmodule
