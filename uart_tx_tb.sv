`timescale 1ns/1ns

module uart_tx_tb;
reg sysclk;
reg reset_n;
reg sig_tx_start;
reg sig_tx_end;
reg [7:0] sig_tx_data;
reg [7:0] sig_shift_tx_data;
reg sig_tx;
reg sig_parity;

uart_tx #
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
    .tx_end_o(sig_tx_end),
    .tx_o(sig_tx)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) sysclk=~sysclk;

initial begin
    #1
    reset_n         <= 1'bx;
    sysclk          <= 1'bx;
    sig_tx_start    <= 1'bx;
    #(CLK_PERIOD*3)
    reset_n <= 1;
    #(CLK_PERIOD*3)
    reset_n         <= 0;
    sysclk          <= 0;
    sig_tx_data     <= 8'h55;
    sig_tx_start    <= 1'b1;
    repeat(5) @(posedge sysclk);
    reset_n       <= 1;
    @(posedge sysclk);                  // 
    repeat(10) @(posedge sysclk);
    sig_tx_start  <= 1'b0;              // START BIT
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[0] <= sig_tx;     // FIRST BIT
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[1] <= sig_tx;     // SECOND
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[2] <= sig_tx;     // THIRD
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[3] <= sig_tx;     // FOURTH
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[4] <= sig_tx;     // FIFTH
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[5] <= sig_tx;     // SIXTH
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[6] <= sig_tx;     // SEVENTH
    
    repeat(10) @(posedge sysclk);
    sig_shift_tx_data[7] <= sig_tx;     // EIGHTH
    wait(sig_tx_end == 1'b1);
    #800
    $finish;
end

endmodule