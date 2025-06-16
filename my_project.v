module my_project (
    input   wire    clk_50,
    input   wire    reset_n,
    input   wire    sw_i,
    input   wire    rx_i,
    output  wire    tx_o,
    output  wire    led_o
);

parameter CONST_D = 8'h0A;

wire        sysclk;
wire        locked;                  // PLL lock signal
wire        rst_n;              		// Synchronous reset
wire        master_arst_n;       // Combined master reset

reg         led_reg;
reg         led_next;
wire        sig_sw;
wire        db_f_edge;
wire        db_o;
reg         db_dly;

/// uart signals
// signals transmitter
reg sig_tx_start_reg;
reg sig_tx_start_next;
reg sig_tx_end;
reg [7:0] sig_tx_data_reg;
reg [7:0] sig_tx_data_next;
reg sig_tx;
// signals receiver
// reg sig_rx;
reg sig_rx_err;
reg sig_rx_end;
reg [7:0] sig_rx_data;

// Combine external reset and PLL lock status
assign master_arst_n = reset_n & locked;
assign sig_rx = sig_tx;
// PLL instance
pll u0(
    .areset(~reset_n),    // Active high async reset for PLL
    .inclk0(clk_50),
    .c0(sysclk),
    .locked(locked)
);

sync_meta async_reset
(
    .sysclk(sysclk),
    .reset_n(reset_n),
    .async_in(master_arst_n),
    .sync_out(rst_n)
); 

sync_meta sync_button 
(
    .sysclk(sysclk),
    .reset_n(rst_n),
    .async_in(sw_i),
    .sync_out(sig_sw)
);

my_debounce #
(
    .N(32),
    .MAX_VAL(32'd150000)
)
my_debounce0 
(
    .sysclk(sysclk),
    .reset_n(rst_n),
    .signal_i(sig_sw),
    .signal_o(db_o)
);


my_uart #
(
    .N(8),
    .PSCALER(625),
    .DIV(10)
)
uart_loopback
(
    .sysclk (sysclk),
    .reset_n (reset_n),
    .parity_i(1'b0),
    .tx_start_i(sig_tx_start_reg),
    .tx_data_i(sig_tx_data_reg),
    .rx_i(rx_i),
    .tx_end_o(sig_tx_end),
    .tx_o(tx_o),
    .rx_err_o(sig_rx_err),
    .rx_end_o(sig_rx_end),
    .rx_data_o(sig_rx_data)
);



// toogle output led
always @(posedge sysclk, negedge rst_n)
begin
    if (!rst_n) 
    begin
        sig_tx_data_reg     <= 0; 
        sig_tx_start_reg    <= 0;
    end
    else
    begin
        sig_tx_data_reg     <= sig_tx_data_next;
        sig_tx_start_reg    <= sig_tx_start_next;
    end 
end

//next-state logic
always @(*) 
begin
    sig_tx_data_next = sig_tx_data_reg;  // Default: stay in current state
    sig_tx_start_next   = sig_tx_start_reg;
    if(sig_rx_end & !sig_rx_err)
    begin
        sig_tx_data_next    = sig_rx_data;
        sig_tx_start_next   = 1'b1;
    end
    else
        sig_tx_start_next   = 1'b0;
        
end

// falling edge detection
always @(posedge sysclk)
begin
    db_dly <= db_o;
end
assign db_f_edge = !db_o & db_dly;

// toogle output led
always @(posedge sysclk, negedge rst_n)
begin
    if (!rst_n) 
        led_reg     <= 1'b0; 
    else
        led_reg <= led_next;  // Toggle LED on falling edge
end

//next-state logic
always @(*) begin
    led_next = led_reg;  // Default: stay in current state
    if(db_f_edge)
        led_next = !led_reg;
end

//output logic
assign led_o = led_reg;

endmodule
