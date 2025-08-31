
module end_screen (
    input  logic clk,
    input  logic rst,

    input  logic game_over,
    input  logic restart_game,

    output logic internal_rst,

    vga_if.in_m  vga_end_screen_in,
    vga_if.out_m vga_end_screen_out
);

    vga_if vga_player1_won();
    vga_if vga_player2_won();
    vga_if vga_player_won();
    vga_if vga_restart();
    vga_if vga_enter_blink();

    draw_param_text 
    #(
        .TEXT(" PLAYER 1 WON "),
        .LINES(1),
        .TEXT_X(455),
        .TEXT_Y(375)
    ) u_draw_player1_win_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_end_screen_in),
        .text_out(vga_player1_won)
    );
    draw_param_text 
    #(
        .TEXT(" PLAYER 2 WON "),
        .LINES(1),
        .TEXT_X(455),
        .TEXT_Y(375)
    ) u_draw_player2_win_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_end_screen_in),
        .text_out(vga_player2_won)
    );
    draw_param_text 
    #(
        .TEXT(" IF YOU WANT TO RESTART THE GAME, PRESS "),
        .LINES(1),
        .TEXT_X(375),
        .TEXT_Y(407)
    ) u_draw_restart_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_player_won),
        .text_out(vga_restart)
    );
    draw_param_text_blink
    #(
        .TEXT(" ENTER "),
        .LINES(1),
        .TEXT_COLOR(12'hf_f_f),
        .BG_COLOR(12'h0_0_0),
        .TEXT_X(483),
        .TEXT_Y(439)
    ) u_enter_blink_text (
        .clk(clk),
        .rst(rst),

        .text_in(vga_restart),
        .text_out(vga_enter_blink)
    );
    
    end_screen_ctl u_end_screen_ctl (
        .clk(clk),
        .rst(rst),

        .game_over(game_over),
        .restart_game(restart_game),

        .vga_player1_won(vga_player1_won),
        .vga_player2_won(vga_player2_won),

        .internal_rst(internal_rst),
        .vga_player_won(vga_player_won)
    );

    vga_if_delay #(
        .N_buf(49)
    ) u_vga_if_delay (
        .clk(clk),
        .rst(rst),

        .vga_if_in  (vga_enter_blink),
        .vga_if_out (vga_end_screen_out)
    );

endmodule
