`timescale 1ns/1ns

module my_uart_tb;
reg sysclk;
reg reset_n;
reg sig_rx;

my_uart #
(
    .N(8),
    .PSCALER(2),
    .DIV(10)
)
dut
(
    .sysclk (sysclk),
    .reset_n (reset_n),
    .rx_i(sig_rx),
    .tx_o()
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) sysclk=~sysclk;

initial begin
    #1
    reset_n     <= 1'bx;
    sysclk      <= 1'bx;
    sig_rx      <= 1'bx;
    #(CLK_PERIOD*3)
    reset_n <= 1;
    #(CLK_PERIOD*3)
    reset_n   <= 0;
    sysclk  <= 0;
    sig_rx  <= 1'b1;
    repeat(5) @(posedge sysclk);
    reset_n   <= 1;
    sig_rx  <= 1'b0;
    @(posedge sysclk);
    repeat(2) @(posedge sysclk);
    #400
    $finish;
end

endmodule


