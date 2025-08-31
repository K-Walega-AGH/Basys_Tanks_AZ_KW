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

module display_UART #(
    parameter DBIT = 8,
    parameter SB_TICK = 16,
    parameter DVSR = 54,       // 100 MHz clk / (16 * 115200 baud)
    parameter DVSR_BIT = 6,
    parameter FIFO_W = 2
)(
    input  logic clk,
    input  logic rst,
    input  logic loopback_enable,
    input  logic increase_enable,
    input  logic rx,
    output logic tx,
    output logic [7:0] rx_data,
    output logic       read_data,
    input  logic [7:0] tx_data,
    input  logic       send_data
);

    // UART-related signals
    logic [7:0] r_data, w_data;
    logic rd_uart, wr_uart; 
    logic rx_empty, rx_empty_d, tx_full;
    logic btn_tick;

    assign rx_data = r_data;
    assign read_data = rd_uart;

    // Store and decode received byte
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_empty_d <= '0;
            rd_uart <= '0;
            wr_uart <= '0;
            w_data <= '0;
        end else begin
            rx_empty_d <= rx_empty;
            rd_uart <= (rx_empty_d & ~rx_empty);
            wr_uart <= '0;
            // When data is received
            if (rd_uart) begin
                if(loopback_enable) begin
                    if(btn_tick) begin
                        w_data <= r_data + 3;
                    end else begin
                        w_data <= r_data;
                    end
                    wr_uart <= '1;
                end else begin
                    if(send_data) begin
                        w_data <= tx_data;
                        wr_uart <= '1;
                    end
                end
            end else if(send_data) begin
                w_data <= tx_data;
                wr_uart <= '1;
            end else if(btn_tick) begin
                w_data <= r_data + 3;
                wr_uart <= '1;
            end else begin
                //nothing
            end
        end
    end

    // UART instance
    uart #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK),
        .DVSR(DVSR),
        .DVSR_BIT(DVSR_BIT),
        .FIFO_W(FIFO_W)
    ) u_uart (
        .clk(clk),
        .reset(rst),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .rx(rx),
        .w_data(w_data),
        .tx(tx),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .r_data(r_data)
    );

    debounce u_debounce (
        .clk(clk),
        .reset(rst),
        .sw(increase_enable),
        .db_level(), 
        .db_tick(btn_tick)
    );

endmodule
