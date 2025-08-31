
module photo_tanks_rom
#(
    parameter PHOTO_ORIGINAL_WIDTH  = 256,
    parameter PHOTO_ORIGINAL_HEIGHT = 128,
    parameter SCALE_SHIFT = 1
)(
    input  logic clk,
    input  logic [19:0] address,  // address = {addry[9:0], addrx[9:0]}
    output logic [11:0] rgb
);

reg [11:0] rom [0:(PHOTO_ORIGINAL_WIDTH*PHOTO_ORIGINAL_HEIGHT - 1)];

initial $readmemh("../../rtl/data_files/start_tank/start_tank256x128_4bit.data", rom);

always_ff @(posedge clk) begin
    rgb <= rom[{address[18:(10+SCALE_SHIFT)], address[9:(0+SCALE_SHIFT)]}];
end

endmodule
