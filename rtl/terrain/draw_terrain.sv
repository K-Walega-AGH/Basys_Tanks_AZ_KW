/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Zasadni
 *
 * Description:
 * Draw background.
 */

module draw_terrain (
        input  logic clk,
        input  logic rst,

        input  logic [11:0] new_xpos,
        input  logic [11:0] new_yval,
        input  logic        ram_en,

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

    logic [11:0] rgb_nxt;
    logic [11:0] local_terrain_y;

    vga_if vga_terrain_d();

    /**
     * Signals assignments
     */

    assign terrain_y_out = local_terrain_y;

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            terrain_out.vcount <= '0;
            terrain_out.vsync  <= '0;
            terrain_out.vblnk  <= '0;
            terrain_out.hcount <= '0;
            terrain_out.hsync  <= '0;
            terrain_out.hblnk  <= '0;
            terrain_out.rgb    <= '0;
        end else begin
            terrain_out.vcount <= vga_terrain_d.vcount;
            terrain_out.vsync  <= vga_terrain_d.vsync;
            terrain_out.vblnk  <= vga_terrain_d.vblnk;
            terrain_out.hcount <= vga_terrain_d.hcount;
            terrain_out.hsync  <= vga_terrain_d.hsync;
            terrain_out.hblnk  <= vga_terrain_d.hblnk;
            terrain_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : terrain_comb_blk
        if((vga_terrain_d.vcount >= local_terrain_y && vga_terrain_d.vcount < VER_PIXELS-1) 
        && (vga_terrain_d.hcount >= 1 && vga_terrain_d.hcount < HOR_PIXELS-1))
            rgb_nxt = 12'h5_5_5;            // - fill with GRAY
        else
            rgb_nxt = vga_terrain_d.rgb;
    end

    terrain_ram u_terrain_ram (
        .clk(clk),
        .rst(rst),

        .write_xpos(new_xpos),
        .write_yval(new_yval),
        .write_en(ram_en),
        .terrain_x_in(terrain_in.hcount),
        .terrain_y_out(local_terrain_y)
    );
    vga_if_delay #(
        .N_buf(1)
    ) u_vga_if_delay (
        .clk(clk),
        .rst(rst),

        .vga_if_in  (terrain_in),
        .vga_if_out (vga_terrain_d)
    );

endmodule
