module ps2_keyboard (
    input  logic clk100MHz,
    input  logic clk60MHz,
    input  logic rst,

    input  logic ps2_clk,
    input  logic ps2_data,

    output logic       arrow_left,
    output logic       arrow_right,
    output logic       arrow_up,
    output logic       arrow_down,
    output logic       space,
    output logic       enter,
    output logic       key_5,
    output logic       key_1,
    output logic       F,
    output logic       H,

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
    // keys pressed 100MHz signals
    logic arrow_up100MHz, arrow_down100MHz, arrow_left100MHz, arrow_right100MHz;
    logic space100MHz, enter100MHz, key_1_100MHz, key_5_100MHz, F100MHz, H100MHz;

    /**
     * Signals assignments
     */

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
        .H          (H100MHz),
        .F          (F100MHz),
        .key_1      (key_1_100MHz),
        .key_5      (key_5_100MHz),
        .enter      (enter100MHz),
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
        .H_in          (H100MHz),
        .F_in          (F100MHz),
        .key_1_in      (key_1_100MHz),
        .key_5_in      (key_5_100MHz),
        .enter_in      (enter100MHz),
        .space_in      (space100MHz),
        .arrow_up_in   (arrow_up100MHz),
        .arrow_down_in (arrow_down100MHz),
        .arrow_left_in (arrow_left100MHz),
        .arrow_right_in(arrow_right100MHz),
        // outputs sync'ed with clk60MHz
        .H          (H),
        .F          (F),
        .key_1      (key_1),
        .key_5      (key_5),
        .enter      (enter),
        .space      (space),
        .arrow_up   (arrow_up),
        .arrow_down (arrow_down),
        .arrow_left (arrow_left),
        .arrow_right(arrow_right)
    );

endmodule
