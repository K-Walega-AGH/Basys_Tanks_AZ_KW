
module barrel_rom 
#(
    parameter PLAYER_ID = 1,
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
    case(PLAYER_ID)
        2'd1: begin
            case(ANGLE_INDEX)
                3'd0: $readmemh("../../rtl/data_files/barrel/barrel0_L.data", rom);
                3'd1: $readmemh("../../rtl/data_files/barrel/barrel1_L.data", rom);
                3'd2: $readmemh("../../rtl/data_files/barrel/barrel2_L.data", rom);
                3'd3: $readmemh("../../rtl/data_files/barrel/barrel3_L.data", rom);
                3'd4: $readmemh("../../rtl/data_files/barrel/barrel4_L.data", rom);
                3'd5: $readmemh("../../rtl/data_files/barrel/barrel5_L.data", rom);
                3'd6: $readmemh("../../rtl/data_files/barrel/barrel6_L.data", rom);
                3'd7: $readmemh("../../rtl/data_files/barrel/barrel7_L.data", rom);
                default: $readmemh("../../rtl/data_files/barrel/barrel0_L.data", rom);
            endcase
        end
        2'd2: begin
            case(ANGLE_INDEX)
                3'd0: $readmemh("../../rtl/data_files/barrel/barrel0_R.data", rom);
                3'd1: $readmemh("../../rtl/data_files/barrel/barrel1_R.data", rom);
                3'd2: $readmemh("../../rtl/data_files/barrel/barrel2_R.data", rom);
                3'd3: $readmemh("../../rtl/data_files/barrel/barrel3_R.data", rom);
                3'd4: $readmemh("../../rtl/data_files/barrel/barrel4_R.data", rom);
                3'd5: $readmemh("../../rtl/data_files/barrel/barrel5_R.data", rom);
                3'd6: $readmemh("../../rtl/data_files/barrel/barrel6_R.data", rom);
                3'd7: $readmemh("../../rtl/data_files/barrel/barrel7_R.data", rom);
                default: $readmemh("../../rtl/data_files/barrel/barrel0_R.data", rom);
            endcase
        end
        default: begin
            case(ANGLE_INDEX)
                3'd0: $readmemh("../../rtl/data_files/barrel/barrel0_L.data", rom);
                3'd1: $readmemh("../../rtl/data_files/barrel/barrel1_L.data", rom);
                3'd2: $readmemh("../../rtl/data_files/barrel/barrel2_L.data", rom);
                3'd3: $readmemh("../../rtl/data_files/barrel/barrel3_L.data", rom);
                3'd4: $readmemh("../../rtl/data_files/barrel/barrel4_L.data", rom);
                3'd5: $readmemh("../../rtl/data_files/barrel/barrel5_L.data", rom);
                3'd6: $readmemh("../../rtl/data_files/barrel/barrel6_L.data", rom);
                3'd7: $readmemh("../../rtl/data_files/barrel/barrel7_L.data", rom);
                default: $readmemh("../../rtl/data_files/barrel/barrel0_L.data", rom);
            endcase
        end
    endcase
end

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    rgb <= rom[{address[15:10],address[5:0]}];  //if tank size changes this also needs to be updated
end

endmodule
