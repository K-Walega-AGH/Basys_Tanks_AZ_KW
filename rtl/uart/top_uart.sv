/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

module top_uart (
    input  logic clk,              // 100 MHz clock (W5)
    input  logic rst,              // reset button (btnC)
    input  logic loopback_enable,  // SW0 (V17)
    input  logic increase_enable,  // increase by 3 (btnU)
    input  logic uart_rx,          // UART RX (B18)
    output logic uart_tx,          // UART TX (A18)
    output logic [7:0] rx_data,
    output logic       read_data,
    input  logic [7:0] tx_data,
    input  logic       send_data,
    output logic rx_monitor,       // PMOD JA1 (J1)
    output logic tx_monitor        // PMOD JA2 (L2)
);

    timeunit 1ns;
    timeprecision 1ps;

    import uart_pkg::*;

    logic monitor_tx, display_tx;

    assign uart_tx = display_tx;

    // Instance of UART monitor
    monitor_UART u_monitor_UART (
        .clk(clk),
        .rst(rst),
        .loopback_enable(loopback_enable),
        .rx(uart_rx),
        .tx(monitor_tx),
        .rx_monitor(rx_monitor),
        .tx_monitor(tx_monitor)
    );

    display_UART 
    #(
         .DBIT(DBIT),
         .SB_TICK(SB_TICK),
         .DVSR(DVSR),
         .DVSR_BIT(DVSR_BIT),
         .FIFO_W(FIFO_W)
    ) u_display_UART (
        .clk(clk),
        .rst(rst),
        .loopback_enable(loopback_enable),
        .increase_enable(increase_enable),
        .rx(uart_rx),
        .tx(display_tx),
        .rx_data(rx_data),
        .read_data(read_data),
        .tx_data(tx_data),
        .send_data(send_data)
    );

endmodule
