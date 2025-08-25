/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * ANTONI ZASADNI
 *
 * Description:
 * The project top module.
 */

module monitor_UART (
        input  logic clk,
        input  logic rst,
        input  logic rx,
        input  logic loopback_enable,
        output logic tx,
        output logic rx_monitor,
        output logic tx_monitor
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */
    logic d_rx, d_tx;

    // output tx
    assign tx = d_tx;
    // outputs for monitoring
    assign rx_monitor = d_rx;
    assign tx_monitor = tx;

    /**
     * Internal logic
     */

     always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            d_rx <= '0;
            d_tx <= '0;
        end else begin
            d_rx <= rx;

            if(loopback_enable) begin
                d_tx <= rx;
            end else begin
                d_tx <= '0;
            end
        end
     end

endmodule
