
module top_vga (
    input  logic clk,
    input  logic clk100MHz,
    input  logic rst_btnC,
    input  logic uart_btnU,
    input  logic [2:0] sw,

    input  logic uart_rx_usb,
    output logic uart_tx_usb,
    input  logic uart_rx_JA1,
    output logic uart_tx_JA2,
    input  logic Player_rd_JA3,
    output logic Player_rd_JA4,

    inout  logic ps2_clk,
    inout  logic ps2_data,
    output logic vs,
    output logic hs,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,
    output logic [7:0] sseg,
    output logic [3:0] an,
    output logic [15:11] led
);

    /**
     * Local variables and signals
     */


// ===============================================
//      CHOOSE WHICH PLAYER TO GENERERATE
// ===============================================
     localparam PLAYER_NUMBER = 1;
// ===============================================
//          LEFT = 1, RIGHT = 2
// ===============================================


    // rst from button or internal signal
    logic rst;
    // inputs
    logic arrow_up_ps2, arrow_down_ps2, arrow_left_ps2, arrow_right_ps2;
    logic space_ps2, enter_ps2, key_5_ps2, key_1_ps2, F_ps2, H_ps2;
    logic arrow_up, arrow_down, arrow_left, arrow_right;
    logic space, enter, key_5, key_1, F, H;
    // named signals
    logic [1:0] moving, change_angle;
    logic       fire_active, show_help;
    logic [1:0] player_turn;
    // signals to control game state
    logic       P1_ready, P2_ready;
    logic       P1andP2_ready, start_game;
    // LEFT  won => 2'b01
    // RIGHT won => 2'b11
    logic  [1:0] game_over;
    logic  [1:0] game_over_CODE;
    logic        restart_game;
    logic        internal_rst;
    // ps2 signals for hex display
    logic  [7:0] ps2_rx_data, rx_data;
    logic        ps2_read_data, read_data;
    // uart signals
    logic        uart_rx, uart_tx;
    logic  [7:0] uart_rx_data;
    logic        uart_read_data;

    // interfaces from different states
    vga_if vga_timing();
    vga_if vga_bg();
    vga_if vga_start_screen();
    vga_if vga_main_game();
    vga_if vga_end_screen();
    vga_if vga_top_if();

    /**
     * Signals assignments
     */

    // --------- output signals for top --------- 
    assign vs = vga_top_if.vsync;
    assign hs = vga_top_if.hsync;
    assign {r,g,b} = vga_top_if.rgb;
    // --------- inputs into named signals --------- 
    // start_screen
    always_comb begin   //  should in top_vga_ctl be but no time :P
        if(PLAYER_NUMBER == 1)begin
            P1_ready = enter;
            Player_rd_JA4 = P1_ready;
            P2_ready = (sw[2]) ? enter : Player_rd_JA3;
        end else begin
            P2_ready = enter;
            Player_rd_JA4 = P2_ready;
            P1_ready = (sw[2]) ? enter : Player_rd_JA3;
        end
    end

    assign start_game = P1andP2_ready;  // P1andP2 is an impulse based of flags
    // main_game
    assign moving = {arrow_right, (arrow_left || arrow_right)};
    assign change_angle = {arrow_up, (arrow_up || arrow_down)};
    assign fire_active = space;
    assign show_help = H;
    // start_screen
    assign restart_game = enter;
    // --------- led for debug --------- 
    assign led = {fire_active, moving, change_angle};
    assign game_over_CODE[1] = (player_turn == 2'b01) ? 1'b1 : 1'b0; // if left then P1 ff'ed
    // uart trying to implement
    assign uart_rx = (sw[1]) ? uart_rx_usb : uart_rx_JA1;
    assign uart_tx_usb = uart_tx;
    assign uart_tx_JA2 = (P1andP2_ready) ? uart_tx : '1;
    
    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .vcount (vga_timing.vcount),
        .vsync  (vga_timing.vsync),
        .vblnk  (vga_timing.vblnk),
        .hcount (vga_timing.hcount),
        .hsync  (vga_timing.hsync),
        .hblnk  (vga_timing.hblnk)
    );
    draw_bg u_draw_bg (
        .clk(clk),
        .rst(rst),

        .bg_in  (vga_timing),
        .bg_out (vga_bg)
    );

    start_screen u_start_screen (
        .clk(clk),
        .rst(rst),

        .P1_ready(P1_ready),
        .P2_ready(P2_ready),
        .P1andP2_ready(P1andP2_ready),
        .vga_start_screen_in(vga_bg),
        .vga_start_screen_out(vga_start_screen)
    );

    main_game u_main_game (
        .clk(clk),
        .rst(rst),

        .moving(moving),
        .change_angle(change_angle),
        .fire_active(fire_active),
        .show_help(show_help),

        .player_turn_out(player_turn),
        .game_over(game_over),
        
        .vga_main_game_in(vga_bg),
        .vga_main_game_out(vga_main_game)
    );

    end_screen u_end_screen (
        .clk(clk),
        .rst(rst_btnC),

        .game_over(game_over[1] || game_over_CODE[1]),
        .restart_game(restart_game),

        .internal_rst(internal_rst),

        .vga_end_screen_in(vga_bg),
        .vga_end_screen_out(vga_end_screen)
    );
    ps2_keyboard #(.PLAYER_NUMBER(PLAYER_NUMBER)) u_ps2_keyboard (
        .clk100MHz(clk100MHz),
        .clk60MHz(clk),
        .rst(rst_btnC),
        
        .player_turn(player_turn[0]),
        .P1andP2_ready(P1andP2_ready),
        .OneBasysMode(sw[2]),   // for single-device debug turn on sw[2]
        .uart_rx_data(uart_rx_data),
        .uart_read_data(uart_read_data),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
    
        .arrow_left(arrow_left_ps2),
        .arrow_right(arrow_right_ps2),
        .arrow_up(arrow_up_ps2),
        .arrow_down(arrow_down_ps2),
        .space(space_ps2),
        .enter(enter_ps2),
        .key_5(key_5_ps2),
        .key_1(key_1_ps2),
        .F(F_ps2),
        .H(H_ps2),
    
        .ps2_rx_data_out(ps2_rx_data),
        .ps2_read_data_out(ps2_read_data),
        .rx_data_out(rx_data),
        .read_data_out(read_data)
        );
    FF_15 u_ff15 (
        .clk(clk),
        .clk100MHz(clk100MHz),
        .rst(rst_btnC),

        .rx_data(rx_data),
        .read_data(read_data),

        .game_over_CODE(game_over_CODE[0])
    );
    ps2_display u_ps2_display(
        .clk(clk100MHz),
        .rst(rst_btnC),
    
        .rx_data(rx_data),
        .read_data(read_data),
    
        .sseg(sseg),
        .an(an)
        );
    top_uart u_top_uart (
        .clk(clk100MHz),
        .rst(rst_btnC),
        .loopback_enable(sw[0]),
        .increase_enable(uart_btnU),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .rx_data(uart_rx_data),
        .read_data(uart_read_data),
        .tx_data(ps2_rx_data),
        .send_data(ps2_read_data)
        // .rx_monitor(),
        // .tx_monitor()
        );

    top_vga_ctl u_top_vga_ctl (
        .clk(clk),
        .rst_btnC(rst_btnC),

        .start_game(start_game),
        .restart_game(restart_game),
        .game_over(game_over[0] || game_over_CODE[0]),
        .internal_rst(internal_rst),

        .arrow_left_in(arrow_left_ps2),
        .arrow_right_in(arrow_right_ps2),
        .arrow_up_in(arrow_up_ps2),
        .arrow_down_in(arrow_down_ps2),
        .space_in(space_ps2),
        .enter_in(enter_ps2),
        .key_5_in(key_5_ps2),
        .key_1_in(key_1_ps2),
        .F_in(F_ps2),
        .H_in(H_ps2),

        .vga_start_screen(vga_start_screen),
        .vga_main_game(vga_main_game),
        .vga_end_screen(vga_end_screen),

        .arrow_left(arrow_left),
        .arrow_right(arrow_right),
        .arrow_up(arrow_up),
        .arrow_down(arrow_down),
        .space(space),
        .enter(enter),
        .key_5(key_5),
        .key_1(key_1),
        .F(F),
        .H(H),

        .rst_out(rst),

        .vga_top_if(vga_top_if)
    );

endmodule
