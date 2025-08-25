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
    input  logic rx,
    input  logic loopback_enable,
    input  logic increase_enable,
    output logic [7:0] sseg,
    output logic [3:0] an,
    output logic tx
);

    // UART-related signals
    logic [7:0] r_data, w_data;
    logic rd_uart, wr_uart; 
    logic rx_empty, rx_empty_prev, tx_full;
    logic btn_tick;
    // bytes recieved
    logic [7:0] byte_received, byte_previous;
    logic [7:0] send_data;
    // HEX digits for display
    logic [3:0] hex0, hex1, hex2, hex3;
    // Hex values assign
    assign hex0 = byte_received[3:0];
    assign hex1 = byte_received[7:4];
    assign hex2 = byte_previous[3:0];
    assign hex3 = byte_previous[7:4];
    // Assign what and when to send
    assign w_data = send_data;

    // Store and decode received byte
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_previous <= '0;
            byte_received <= '0;
            rx_empty_prev <= '0;
            rd_uart <= '0;
            wr_uart <= '0;
            send_data <= '0;
        end else begin
            rx_empty_prev <= rx_empty;
            rd_uart <= (rx_empty_prev & ~rx_empty);
            wr_uart <= '0;
            // When data is received
            if (rd_uart) begin
                byte_previous <= byte_received;
                byte_received <= r_data;
                if(loopback_enable) begin
                    if(btn_tick) begin
                        send_data <= byte_received + 3;
                    end else begin
                        send_data <= r_data;
                    end
                    wr_uart <= '1;
                end //else
            end else begin
                if(btn_tick) begin
                    send_data <= byte_received + 3;
                    wr_uart <= '1;
                end
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

    // 7-segment display driver
    disp_hex_mux seg7display (
        .clk(clk),
        .reset(rst),
        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0),
        .dp_in(4'b1111),    // dots are off
        .an(an),
        .sseg(sseg)
    );

endmodule
