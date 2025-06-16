`timescale 1ns/1ns

module uart_rx_tb;
reg sysclk;
reg reset_n;
reg sig_rx;
reg sig_parity;

uart_rx #
(
    .N(8),
    .PSCALER(1),
    .DIV(10)
)
dut
(
    .sysclk (sysclk),
    .reset_n (reset_n),
    .parity_i(sig_parity),
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
    sig_rx  <= 1'b0;                    // START BIT
    @(posedge sysclk);                  // 
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b1;                    // FIRST BIT
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b0;                    // SECOND
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b1;                    // THIRD
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b0;                    // FOURTH
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b1;                    // FIFTH
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b0;                    // SIXTH
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b1;                    // SEVENTH
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b0;                    // EIGHTH
    repeat(10) @(posedge sysclk);
    sig_rx  <= 1'b1;                    // STOP BIT
    #800
    $finish;
end

endmodule