module vga_if_delay #(
    parameter N_buf = 2
)(
    input  logic clk,
    input  logic rst,
    vga_if.in_m  vga_if_in,
    vga_if.out_m vga_if_out
);

    logic [11:0] rgb_pipe   [0:N_buf-1];
    logic [11:0] hcount_pipe[0:N_buf-1];
    logic        hsync_pipe [0:N_buf-1];
    logic        hblnk_pipe [0:N_buf-1];
    logic [11:0] vcount_pipe[0:N_buf-1];
    logic        vsync_pipe [0:N_buf-1];
    logic        vblnk_pipe [0:N_buf-1];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < N_buf; i++) begin
                rgb_pipe[i]    <= '0;
                hcount_pipe[i] <= '0;
                hsync_pipe[i]  <= '0;
                hblnk_pipe[i]  <= '0;
                vcount_pipe[i] <= '0;
                vsync_pipe[i]  <= '0;
                vblnk_pipe[i]  <= '0;
            end
        end else begin
            if(N_buf == 1) begin
                vga_if_out.rgb    <= vga_if_in.rgb;
                vga_if_out.hcount <= vga_if_in.hcount;
                vga_if_out.hsync  <= vga_if_in.hsync;
                vga_if_out.hblnk  <= vga_if_in.hblnk;
                vga_if_out.vcount <= vga_if_in.vcount;
                vga_if_out.vsync  <= vga_if_in.vsync;
                vga_if_out.vblnk  <= vga_if_in.vblnk;
            end
            rgb_pipe[0]    <= vga_if_in.rgb;
            hcount_pipe[0] <= vga_if_in.hcount;
            hsync_pipe[0]  <= vga_if_in.hsync;
            hblnk_pipe[0]  <= vga_if_in.hblnk;
            vcount_pipe[0] <= vga_if_in.vcount;
            vsync_pipe[0]  <= vga_if_in.vsync;
            vblnk_pipe[0]  <= vga_if_in.vblnk;

            for (int i = 1; i < N_buf; i++) begin
                rgb_pipe[i]    <= rgb_pipe[i-1];
                hcount_pipe[i] <= hcount_pipe[i-1];
                hsync_pipe[i]  <= hsync_pipe[i-1];
                hblnk_pipe[i]  <= hblnk_pipe[i-1];
                vcount_pipe[i] <= vcount_pipe[i-1];
                vsync_pipe[i]  <= vsync_pipe[i-1];
                vblnk_pipe[i]  <= vblnk_pipe[i-1];
            end
        end
    end

    always_comb begin
        if(N_buf != 1) begin
            vga_if_out.rgb    = rgb_pipe[N_buf-1];
            vga_if_out.hcount = hcount_pipe[N_buf-1];
            vga_if_out.hsync  = hsync_pipe[N_buf-1];
            vga_if_out.hblnk  = hblnk_pipe[N_buf-1];
            vga_if_out.vcount = vcount_pipe[N_buf-1];
            vga_if_out.vsync  = vsync_pipe[N_buf-1];
            vga_if_out.vblnk  = vblnk_pipe[N_buf-1];
        end
    end

endmodule
