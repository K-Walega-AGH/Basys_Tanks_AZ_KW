
module explosion (
    input  logic clk,
    input  logic rst,

    input  logic        terrain_hit,
    input  logic [11:0] terrain_y_in,
    output logic [11:0] terrain_x_out,
    output logic [11:0] terrain_y_out,
    output logic        write_en,
    
    input  logic [11:0] explosion_xpos,
    input  logic [11:0] explosion_ypos,
    input  logic        activate_explosion,

    output logic        end_turn,

    vga_if.in_m         explosion_in,
    vga_if.out_m        explosion_out
);

    import projectile_pkg::*;

    /**
     * Local variables and signals
     */
    
    logic [2:0] frame_index;
    logic show_animation;
    logic [11:0] terrain_y_d4;
  
     /**
      * Signals assignments
      */
 
     /**
      * Submodules instances
      */

    draw_explosion u_draw_explosion (
        .clk(clk),
        .rst(rst),

        .explosion_xpos(explosion_xpos-EXPLOSION_OFFSET),
        .explosion_ypos(explosion_ypos-EXPLOSION_OFFSET),
        .show_animation(show_animation),
        .frame_index(frame_index),

        .explosion_in(explosion_in),
        .explosion_out(explosion_out)
    );
    delay #(.WIDTH(12), .CLK_DEL(4)) d4_terrain_y (
        .clk(clk),
        .rst(rst),
        .din(terrain_y_in),
        .dout(terrain_y_d4)
    );
    // Explosion control FSM
    explosion_ctl u_explosion_ctl (
        .clk(clk),
        .rst(rst),

        .terrain_hit(terrain_hit),
        .explosion_xpos(explosion_xpos-EXPLOSION_OFFSET),
        .explosion_ypos(explosion_ypos-EXPLOSION_OFFSET),
        .hcount(explosion_in.hcount),
        .terrain_y_in(terrain_y_d4),
        .write_en(write_en),

        .terrain_x_out(terrain_x_out),
        .terrain_y_out(terrain_y_out),

        .activate_explosion(activate_explosion),
		
        .show_animation(show_animation),
        .frame_index(frame_index),
        .end_turn(end_turn)
    );

endmodule
