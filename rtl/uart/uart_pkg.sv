
package uart_pkg;

    // number of data bits in UART frame
    localparam int DBIT      = 8;
    // oversampling ticks per bit (commonly 16x)
    localparam int SB_TICK   = 16;
    // clock divider: 100 MHz / (16 * 115200 baud) = 54
    localparam int DVSR      = 54;
    // number of bits required to represent DVSR (log2(54) = 6)
    localparam int DVSR_BIT  = 6;
    // FIFO address width (2 means 4 byte FIFO)
    localparam int FIFO_W    = 2;

endpackage
