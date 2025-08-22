///experimental module for future development
// it existes to takes all the information in consider of movement of tank

module tank_move (
        input  logic clk,   // nie wiem czy clk i rst tu bedzie potrzebny - mozliwe ze ten modul bedzie kombinacyjny (chyba nie wsm) 
        input  logic rst,
        
        input  logic [11:0] tank_xpos_in,
        input  logic [11:0] tank_ypos_in,


        output  logic [11:0] tank_xpos_out,
        output  logic [11:0] tank_ypos_out
    );

  import tank_pkg::*;

    always_ff@(posedge clk) begin
        if (rst) begin 
            tank_xpos_out <= TANK_XPOS_START;
            tank_ypos_out <= TANK_YPOS_START;
        end
        else begin
            tank_xpos_out <= TANK_XPOS_START;
            tank_ypos_out <= TANK_YPOS_START;
    end

    end

endmodule