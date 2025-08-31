module terrain_destruction (
    input  logic clk,
    input  logic rst,

    input  logic [11:0] write_xpos,
    input  logic [11:0] write_yval,
    input logic        write_en,
    
    output logic [11:0] new_xpos,
    output logic [11:0] new_yval,
    output logic        ram_en
);

    // pipeline registers
    logic [11:0] xpos_nxt;
    logic [11:0] yval_nxt;
    logic        en_nxt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            xpos_nxt <= '0;
            yval_nxt <= '0;
            en_nxt   <= 1'b0;
        end else begin
            if(write_en) begin
                xpos_nxt <= write_xpos;   
                yval_nxt <= write_yval;   
                en_nxt   <= 1'b1;
            end else begin
                en_nxt   <= 1'b0;
            end
        end
    end

    assign new_xpos = xpos_nxt;
    assign new_yval = yval_nxt;
    assign ram_en = en_nxt;

endmodule
