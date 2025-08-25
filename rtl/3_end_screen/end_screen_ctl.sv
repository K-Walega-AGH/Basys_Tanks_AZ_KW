
module end_screen_ctl (
    input  logic clk,
    input  logic rst,

    input  logic game_over,
    input  logic restart_game,

    vga_if.in_m  vga_player1_won,
    vga_if.in_m  vga_player2_won,

    output logic internal_rst,

    vga_if.out_m vga_player_won
);

    logic restart_game_d, restart_game_posedge;

    assign restart_game_posedge = (!restart_game_d && restart_game);

    always_ff @(posedge clk) begin
        if(rst) begin
            internal_rst   <= '0;
            restart_game_d <= '0;
        end else begin
            restart_game_d <= restart_game;
            if(restart_game_posedge) begin
                internal_rst   <= '1;
            end else begin
                internal_rst   <= '0;
            end
        end
    end

    always_comb begin
        if(game_over) begin
            vga_player_won.hcount = vga_player2_won.hcount;
            vga_player_won.hsync  = vga_player2_won.hsync;
            vga_player_won.hblnk  = vga_player2_won.hblnk;
            vga_player_won.vcount = vga_player2_won.vcount;
            vga_player_won.vsync  = vga_player2_won.vsync;
            vga_player_won.vblnk  = vga_player2_won.vblnk;
            vga_player_won.rgb    = vga_player2_won.rgb;
        end else begin
            vga_player_won.hcount = vga_player1_won.hcount;
            vga_player_won.hsync  = vga_player1_won.hsync;
            vga_player_won.hblnk  = vga_player1_won.hblnk;
            vga_player_won.vcount = vga_player1_won.vcount;
            vga_player_won.vsync  = vga_player1_won.vsync;
            vga_player_won.vblnk  = vga_player1_won.vblnk;
            vga_player_won.rgb    = vga_player1_won.rgb;
        end
    end

endmodule
