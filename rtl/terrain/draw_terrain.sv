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

        vga_if.in_m     terrain_in,
        vga_if.out_m    terrain_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
  

    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;
    //logic [9:0] terrain_y [0:HOR_PIXELS-1];

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
            terrain_out.vcount <= terrain_in.vcount;
            terrain_out.vsync  <= terrain_in.vsync;
            terrain_out.vblnk  <= terrain_in.vblnk;
            terrain_out.hcount <= terrain_in.hcount;
            terrain_out.hsync  <= terrain_in.hsync;
            terrain_out.hblnk  <= terrain_in.hblnk;
            terrain_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : terrain_comb_blk
        if((terrain_in.vcount >= 700 && terrain_in.vcount < VER_PIXELS-1) 
        && (terrain_in.hcount >= 1 && terrain_in.hcount < HOR_PIXELS-1))
            rgb_nxt = 12'h0_f_0;            // - fill with GREEN
        else
            rgb_nxt = terrain_in.rgb;
    end

//     // pseudo-random terrain generator in progress...
//     logic [9:0] lfsr_reg;
//     logic [6:0] dy;
//     logic       feedback;
//     logic       lock_gen;

//     assign feedback  = lfsr_reg[9] ^ lfsr_reg[6];
//     assign dy        = (lfsr_reg * 100) >> 10;

//     // LFSR register
//     always_ff @(posedge clk or posedge rst) begin
//         if (rst)
//             lfsr_reg <= 10'b11_1010_0011;    // seed
//         else
//             lfsr_reg <= {lfsr_reg[8:0], feedback};
//     end

// integer i;
//     // stop terrain generation after 1st hsync
//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             for (i = 0; i < HOR_PIXELS-1; i = i + 1) begin
//                 terrain_y[i] <= 10'd500;
//             end
//             lock_gen     <= '0;
//         end else if (!lock_gen) begin
//             terrain_y[terrain_in.hcount] <= 10'd500 + dy;
//             if (terrain_in.hsync)
//                 lock_gen <= 1'b1;
//         end
//     end

endmodule
