
module terrain_ram (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] write_xpos,
    input  logic [11:0] write_yval,
    input  logic        write_en,
    input  logic [10:0] terrain_x_in,
    output logic [11:0] terrain_y_out
);

import vga_pkg::*;

/**
 * Local variables and signals
 */


reg [11:0] mem [0:(HOR_PIXELS-1)];
reg [11:0] mem_local [0:(HOR_PIXELS-1)];

/**
 * Memory initialization from a file
 */

/* Relative path from the simulation or synthesis working directory */
initial begin
    $readmemh("../../rtl/data_files/terrain.data", mem);
    $readmemh("../../rtl/data_files/terrain.data", mem_local);
end

/**
 * Internal logic
 */
integer ctr;
always_ff @(posedge clk) begin
    if(rst) begin
        for (ctr = 0; ctr <= (HOR_PIXELS-1); ctr = ctr+1)
            mem_local[ctr] <= mem[ctr];
    end else begin
        if(write_en)
            mem_local[write_xpos] <= write_yval;

        terrain_y_out <= mem[terrain_x_in];
    end
end

endmodule
