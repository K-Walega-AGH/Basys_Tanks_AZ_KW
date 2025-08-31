
module start_screen_ctl (
    input  logic clk,
    input  logic rst,

    input  logic P2_ready,
    input  logic P1_ready,
    output logic P1andP2_ready
);

    logic P1_ready_d, P1_ready_flag;
    logic P2_ready_d, P2_ready_flag;


    always_ff @(posedge clk)begin
        if(rst) begin
            P1_ready_d <= '0;
            P2_ready_d <= '0;
            P1_ready_flag <= '0; 
            P2_ready_flag <= '0;
            P1andP2_ready <= '0;
        end else begin
            P1_ready_d <= P1_ready;
            P2_ready_d <= P2_ready;
            if(!P1_ready_d && P1_ready)
                P1_ready_flag <= '1; 
            if(!P2_ready_d && P2_ready)
                P2_ready_flag <= '1;
            if(P1_ready_flag && P2_ready_flag) begin
                P1andP2_ready <= '1;
                P1_ready_flag <= '0;
                P2_ready_flag <= '0;
            end
        end
    end
endmodule