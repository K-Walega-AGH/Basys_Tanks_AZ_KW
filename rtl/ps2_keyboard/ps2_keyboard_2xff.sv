
module ps2_keyboard_2xff (
    input  logic clk,
    input  logic rst,
    // input signals (100 MHz)
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
    // outputs sync'ed with clk (60 MHz)
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

    // stage registers (first and second flipflop)
    logic H_s1, F_s1, key_1_s1, key_5_s1, enter_s1, space_s1;
    logic arrow_up_s1, arrow_down_s1, arrow_left_s1, arrow_right_s1;

    // second stage
    logic H_s2, F_s2, key_1_s2, key_5_s2, enter_s2, space_s2;
    logic arrow_up_s2, arrow_down_s2, arrow_left_s2, arrow_right_s2;

    always_ff @(posedge clk) begin
        if (rst) begin
            // clear all stages
            H_s1 <= 1'b0; H_s2 <= 1'b0;
            F_s1 <= 1'b0; F_s2 <= 1'b0;
            key_1_s1 <= 1'b0; key_1_s2 <= 1'b0;
            key_5_s1 <= 1'b0; key_5_s2 <= 1'b0;
            enter_s1 <= 1'b0; enter_s2 <= 1'b0;
            space_s1 <= 1'b0; space_s2 <= 1'b0;
            arrow_up_s1 <= 1'b0; arrow_up_s2 <= 1'b0;
            arrow_down_s1 <= 1'b0; arrow_down_s2 <= 1'b0;
            arrow_left_s1 <= 1'b0; arrow_left_s2 <= 1'b0;
            arrow_right_s1 <= 1'b0; arrow_right_s2 <= 1'b0;

            // outputs
            H <= 1'b0; F <= 1'b0;
            key_1 <= 1'b0; key_5 <= 1'b0;
            enter <= 1'b0; space <= 1'b0;
            arrow_up <= 1'b0; arrow_down <= 1'b0;
            arrow_left <= 1'b0; arrow_right <= 1'b0;
        end else begin
            // first stage captures async input (metastability possible but contained)
            H_s1 <= H_in;
            F_s1 <= F_in;
            key_1_s1 <= key_1_in;
            key_5_s1 <= key_5_in;
            enter_s1 <= enter_in;
            space_s1 <= space_in;
            arrow_up_s1 <= arrow_up_in;
            arrow_down_s1 <= arrow_down_in;
            arrow_left_s1 <= arrow_left_in;
            arrow_right_s1 <= arrow_right_in;

            // second stage reduces metastability risk
            H_s2 <= H_s1;
            F_s2 <= F_s1;
            key_1_s2 <= key_1_s1;
            key_5_s2 <= key_5_s1;
            enter_s2 <= enter_s1;
            space_s2 <= space_s1;
            arrow_up_s2 <= arrow_up_s1;
            arrow_down_s2 <= arrow_down_s1;
            arrow_left_s2 <= arrow_left_s1;
            arrow_right_s2 <= arrow_right_s1;

            // outputs driven from second stage
            H <= H_s2;
            F <= F_s2;
            key_1 <= key_1_s2;
            key_5 <= key_5_s2;
            enter <= enter_s2;
            space <= space_s2;
            arrow_up <= arrow_up_s2;
            arrow_down <= arrow_down_s2;
            arrow_left <= arrow_left_s2;
            arrow_right <= arrow_right_s2;
        end
    end

endmodule
