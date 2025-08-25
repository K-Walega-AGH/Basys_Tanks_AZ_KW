
module explosion (
    input  logic clk,
    input  logic rst,

    input  logic [11:0] explosion_xpos,
    input  logic [11:0] explosion_ypos,
    input  logic        activate_explosion,

    output logic        end_turn,

    vga_if.in_m         explosion_in,
    vga_if.out_m        explosion_out
);

    /**
     * Local variables and signals
     */
    
    logic [2:0] frame_index;
    logic show_animation;
  
     /**
      * Signals assignments
      */
 
     /**
      * Submodules instances
      */

    draw_explosion u_draw_explosion (
        .clk(clk),
        .rst(rst),

        .explosion_xpos(explosion_xpos),
        .explosion_ypos(explosion_ypos),
        .show_animation(show_animation),
        .frame_index(frame_index),

        .explosion_in(explosion_in),
        .explosion_out(explosion_out)
    );

    // Explosion control FSM
    explosion_ctl u_explosion_ctl (
        .clk(clk),
        .rst(rst),

        .activate_explosion(activate_explosion),
		
        .show_animation(show_animation),
        .frame_index(frame_index),
        .end_turn(end_turn)
    );

endmodule
