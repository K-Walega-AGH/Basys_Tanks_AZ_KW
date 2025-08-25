module top_vga_ctl (
    input  logic clk,
    input  logic rst_btnC,

    input  logic start_game,
    input  logic game_over,
    input  logic restart_game,
    input  logic internal_rst,

    input  logic arrow_up_in,
    input  logic arrow_down_in,
    input  logic arrow_left_in,
    input  logic arrow_right_in,
    input  logic space_in,
    input  logic enter_in,
    input  logic key_5_in,
    input  logic key_1_in,
    input  logic F_in,
    input  logic H_in,

    vga_if.in_m vga_start_screen,
    vga_if.in_m vga_main_game,
    vga_if.in_m vga_end_screen,

    output logic arrow_up,
    output logic arrow_down,
    output logic arrow_left,
    output logic arrow_right,
    output logic space,
    output logic enter,
    output logic key_5,
    output logic key_1,
    output logic F,
    output logic H,

    output logic rst_out,

    vga_if.out_m vga_top_if
);

    // --------- FSM STATES ---------
    typedef enum logic [1:0] {
        STATE_START = 2'b00,
        STATE_GAME  = 2'b01,
        STATE_END   = 2'b10
    } top_vga_state_t;

    top_vga_state_t top_vga_st, top_vga_st_nxt;

    // sync game_over with the clk
    logic game_over_sync;
    // catch posedge of start_game to launch game
    logic start_game_d, start_game_posedge;

    assign start_game_posedge = (!start_game_d && start_game);

    // --------- NEXT STATE LOGIC (kombinacyjnie) ---------
    always_comb begin
        case (top_vga_st)
            STATE_START: top_vga_st_nxt = start_game_posedge ? STATE_GAME  : STATE_START;
            STATE_GAME:  top_vga_st_nxt = game_over_sync     ? STATE_END   : STATE_GAME;
            STATE_END:   top_vga_st_nxt = STATE_END;
        endcase
    end

    // --------- STATE REGISTER ---------
    always_ff @(posedge clk) begin
        if (rst_out) begin
            game_over_sync <= '0;
            start_game_d   <= '0;
            
            top_vga_st <= STATE_START;
        end else begin
            game_over_sync <= game_over;
            start_game_d   <= start_game;

            top_vga_st <= top_vga_st_nxt;
        end
    end

    // --------- OUTPUT LOGIC ---------
    always_comb begin
        vga_top_if.hcount = vga_main_game.hcount;
        vga_top_if.hsync  = vga_main_game.hsync;
        vga_top_if.hblnk  = vga_main_game.hblnk;
        vga_top_if.vcount = vga_main_game.vcount;
        vga_top_if.vsync  = vga_main_game.vsync;
        vga_top_if.vblnk  = vga_main_game.vblnk;
        rst_out = (top_vga_st == STATE_END) ? (rst_btnC || internal_rst) : rst_btnC;
        case (top_vga_st)
            STATE_START: begin
                vga_top_if.rgb    = vga_start_screen.rgb;
                arrow_up     = 0;
                arrow_down   = 0;
                arrow_left   = 0;
                arrow_right  = 0;
                space        = 0;
                enter        = enter_in;
                key_5        = 0;
                key_1        = 0;
                F            = 0;
                H            = 0;
            end
            STATE_GAME: begin
                vga_top_if.rgb    = vga_main_game.rgb;
                arrow_up     = arrow_up_in;
                arrow_down   = arrow_down_in;
                arrow_left   = arrow_left_in;
                arrow_right  = arrow_right_in;
                space        = space_in;
                enter        = 0;
                key_5        = 0;
                key_1        = 0;
                F            = F_in;
                H            = H_in;
            end
            STATE_END: begin
                vga_top_if.rgb    = vga_end_screen.rgb;
                arrow_up     = 0;
                arrow_down   = 0;
                arrow_left   = 0;
                arrow_right  = 0;
                space        = 0;
                enter        = enter_in;
                key_5        = 0;
                key_1        = 0;
                F            = 0;
                H            = 0;
            end
        endcase
    end

endmodule
