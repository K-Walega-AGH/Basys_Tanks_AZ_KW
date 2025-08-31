
module terrain (
    input  logic clk,
    input  logic rst,

    input  logic [11:0] terrain_x_in,
    input  logic [11:0] terrain_y_in,
    input  logic        write_en,
    
    output logic [11:0] terrain_y_out,
    
    vga_if.in_m     terrain_in,
    vga_if.out_m    terrain_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import terrain_pkg::*;


    /**
     * Local variables and signals
     */
    logic [11:0] new_xpos, new_yval;
    logic        ram_en;

    /**
     * Signals assignments
     */

    /**
     * Submodules instances
     */

    draw_terrain u_draw_terrain (
        .clk(clk),
        .rst(rst),

        .new_xpos(new_xpos),
        .new_yval(new_yval),
        .ram_en(ram_en),

        .terrain_y_out(terrain_y_out),

        .terrain_in  (terrain_in),
        .terrain_out (terrain_out)
    );

    terrain_destruction u_terrain_destruction (
        .clk(clk),
        .rst(rst),

        .write_xpos(terrain_x_in),
        .write_yval(terrain_y_in),
        .write_en(write_en),
        
        .new_xpos(new_xpos),
        .new_yval(new_yval),
        .ram_en(ram_en)
        
    );

endmodule