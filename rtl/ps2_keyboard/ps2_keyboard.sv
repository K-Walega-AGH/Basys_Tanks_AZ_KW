module ps2_keyboard (
    input  logic clk100MHz,
    input  logic clk60MHz,
    input  logic rst,

    input  logic ps2_clk,
    input  logic ps2_data,

    output logic [1:0] moving,
    output logic [1:0] change_angle,
    output logic       fire_active,

    output logic [7:0] rx_data_out,
    output logic       read_data_out
);

    /**
     * Local variables and signals
     */

    // interface signals
    logic [7:0] rx_data;
    logic       read_data;
    logic       busy;
    logic       err;
    // keys pressed signals
    logic arrow_up, arrow_down, arrow_left, arrow_right, space;
    logic arrow_up100MHz, arrow_down100MHz, arrow_left100MHz, arrow_right100MHz, space100MHz;

    /**
     * Signals assignments
     */

    assign fire_active = space;
    assign moving = {arrow_right, (arrow_left || arrow_right)};
    assign change_angle = {arrow_up, (arrow_up || arrow_down)};

    assign rx_data_out = rx_data;
    assign read_data_out = read_data;

    /**
     * Submodules instances
     */

    Ps2Interface u_Ps2Interface (
        .ps2_clk   (ps2_clk),
        .ps2_data  (ps2_data),
        .clk       (clk100MHz),
        .rst       (rst),
        .tx_data   (8'd0),
        .write_data(1'b0),
        .rx_data   (rx_data),
        .read_data (read_data),
        .busy      (busy),
        .err       (err)
    );
    ps2_keyboard_ctl u_ps2_keyboard_ctl (
        .clk        (clk100MHz),
        .rst        (rst),
        .rx_data    (rx_data),
        .read_data  (read_data),
        .space      (space100MHz),
        .arrow_up   (arrow_up100MHz),
        .arrow_down (arrow_down100MHz),
        .arrow_left (arrow_left100MHz),
        .arrow_right(arrow_right100MHz)
    );
    ps2_keyboard_latch u_ps2_keyboard_latch(
        .clk(clk60MHz),
        .rst(rst),
        // input signals
        .space_in      (space100MHz),
        .arrow_up_in   (arrow_up100MHz),
        .arrow_down_in (arrow_down100MHz),
        .arrow_left_in (arrow_left100MHz),
        .arrow_right_in(arrow_right100MHz),
        // outputs sync'ed with clk60MHz
        .space      (space),
        .arrow_up   (arrow_up),
        .arrow_down (arrow_down),
        .arrow_left (arrow_left),
        .arrow_right(arrow_right)
    );

endmodule
