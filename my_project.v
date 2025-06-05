module my_project (
    input        clk_50,
    input        reset_n,
    input        sw_i,
    output       led_o
);

parameter CONST_D = 8'h0A;

wire       sysclk;
reg        led_reg;
wire       rst_n;              		// Synchronous reset
wire       sig_sw;

reg       sig_load_reg;
reg       sig_load_next;
reg       sig_en_reg;
reg       sig_en_next;
wire      sig_sw_reg;


// PLL instance
pll u0(
    .areset(1'b0),    // Active high async reset for PLL
    .inclk0(clk_50),
    .c0(sysclk),
    .locked()
);

sync_meta #(.STAGES(2)) sync_bit (
    .sysclk(sysclk),
    .async_in(reset_n),
    .sync_out(rst_n)
);

sync_meta #(.STAGES(2)) sync_bit1 (
    .sysclk(sysclk),
    .async_in(sw_i),
    .sync_out(sig_sw)
);
// .max_value(32'h0016E360),
//Debounce
my_debounce #
(
    .N(32)
)
dut (
    .sysclk(sysclk),
    .reset_n(rst_n),
    .max_value(32'h007270E0),
    .signal_i(sig_sw),
    .signal_o(sig_sw_reg)
);

always @(posedge sysclk or negedge rst_n)
begin
    if (!rst_n) 
        led_reg     <= 1'b0; 
    else
    begin
        if (!sig_sw_reg) 
            led_reg <= ~led_reg;  // Toggle LED on falling edge
    end
end

assign led_o = led_reg;


endmodule
