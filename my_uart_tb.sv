`timescale 1ns/1ns

module my_uart_tb;
reg sysclk;
reg reset_n;
// signals transmitter
reg sig_tx_start;
reg sig_tx_end;
reg [7:0] sig_tx_data;
reg sig_tx;
// signals receiver
reg sig_rx;
reg sig_rx_err;
reg sig_rx_end;
reg [7:0] sig_rx_data;

my_uart #
(
    .N(8),
    .PSCALER(1),
    .DIV(10)
)
dut
(
    .sysclk (sysclk),
    .reset_n (reset_n),
    .parity_i(1'b0),
    .tx_start_i(sig_tx_start),
    .tx_data_i(sig_tx_data),
    .rx_i(sig_rx),
    .tx_end_o(sig_tx_end),
    .tx_o(sig_tx),
    .rx_err_o(sig_rx_err),
    .rx_end_o(sig_rx_end),
    .rx_data_o(sig_rx_data)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) sysclk=~sysclk;

assign sig_rx = sig_tx;
initial begin
    #1
    reset_n     <= 1'bx;
    sysclk      <= 1'bx;
    #(CLK_PERIOD*3)
    reset_n <= 1;
    #(CLK_PERIOD*3)
    reset_n     <= 0;
    sysclk      <= 0;
    sig_tx_data     <= 8'h55;
    sig_tx_start    <= 1'b1;
    repeat(20) @(posedge sysclk);
    reset_n       <= 1;
    @(posedge sysclk);                  //
    sig_tx_start    <= 1'b0;
    wait(sig_tx_end == 1'b1);
    wait(sig_rx_end == 1'b1);
    #800
    $finish;
end

endmodule