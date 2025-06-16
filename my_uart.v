module my_uart 
#(
    parameter N = 8,                // Counter width
    parameter PSCALER = 1,          // Divider
    parameter DIV = 10              // Divider
)
(
    input   wire    sysclk,
    input   wire    reset_n,
    input   wire    parity_i,
    // input uart interface
    input   wire    tx_start_i,
    input   wire    [N-1:0] tx_data_i,
    input   wire    rx_i,
    // output uart interface
    output  wire    tx_end_o,
    output  wire    tx_o,
    output  wire    rx_err_o,
    output  wire    rx_end_o,
    output  wire    [N-1:0] rx_data_o
);

uart_tx #
(
    .N(N),
    .PSCALER(PSCALER),
    .DIV(DIV)
)
tx_uart
(
    .sysclk (sysclk),
    .reset_n (reset_n),
    .parity_i(1'b0),
    .tx_start_i(tx_start_i),
    .tx_data_i(tx_data_i),
    .tx_end_o(tx_end_o),
    .tx_o(tx_o)
);

uart_rx #
(
    .N(N),
    .PSCALER(PSCALER),
    .DIV(DIV)
)
rx_uart
(
    .sysclk (sysclk),
    .reset_n (reset_n),
    .parity_i(1'b0),
    .rx_i(rx_i),
    .rx_err_o(rx_err_o),
    .rx_end_o(rx_end_o),
    .rx_data_o(rx_data_o)
);
    
endmodule