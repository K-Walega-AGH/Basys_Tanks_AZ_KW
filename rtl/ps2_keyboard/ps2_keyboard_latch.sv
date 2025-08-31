
module ps2_keyboard_latch (
    input  logic clk,
    input  logic rst,
    // input signals
    input  logic H_in,
    input  logic F_in,
    input  logic key_1_in,
    input  logic key_5_in,
    input  logic enter_in,
    input  logic space_in,
    input  logic arrow_up_in,
    input  logic arrow_down_in,
    input  logic arrow_left_in,
    input  logic arrow_right_in,
    // outputs sync'ed with clk60MHz
    output logic H,
    output logic F,
    output logic key_1,
    output logic key_5,
    output logic enter,
    output logic space,
    output logic arrow_up,
    output logic arrow_down,
    output logic arrow_left,
    output logic arrow_right
);

    always_ff @(posedge clk) begin
        if (rst) begin
            H           <= 1'b0;
            F           <= 1'b0;
            key_1       <= 1'b0;
            key_5       <= 1'b0;
            enter       <= 1'b0;
            space       <= 1'b0;
            arrow_up    <= 1'b0;
            arrow_down  <= 1'b0;
            arrow_left  <= 1'b0;
            arrow_right <= 1'b0;
        end else begin
            H           <= H_in;
            F           <= F_in;
            key_1       <= key_1_in;
            key_5       <= key_5_in;
            enter       <= enter_in;
            space       <= space_in;
            arrow_up    <= arrow_up_in;
            arrow_down  <= arrow_down_in;
            arrow_left  <= arrow_left_in;
            arrow_right <= arrow_right_in;
        end
    end

endmodule
