
module sync_2xff
#(
    WIDTH = 1
)(
    input  logic clk,
    input  logic rst,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q2
);

    logic [WIDTH-1:0] q1;

    always_ff @(posedge clk) begin
        if(rst) begin
            q1 <= '0;
            q2 <= '0;
        end else begin
        q1 <= d;
        q2 <= q1;
        end
    end

    //sync_2xff inst
    // sync_2xff #(.WIDTH(1)) u_2xff (
    //     .clk(clk),
    //     .rst(rst),
    //     .d(),
    //     .q2()
    // );
    // (* max_fanout = 64 *) 
    
endmodule
