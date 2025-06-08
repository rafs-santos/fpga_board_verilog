module my_project (
    input   wire    clk_50,
    input   wire    reset_n,
    input   wire    sw_i,
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
// Combine external reset and PLL lock status
assign master_arst_n = reset_n & locked;

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
