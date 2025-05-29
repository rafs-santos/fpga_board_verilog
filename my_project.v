module my_project (
    input        clk_50,
    input        reset_n,
    input        sw_i,
    output       led_o
);

wire       sysclk;
wire       locked;
reg        led_reg;
wire       rst_n;              		// Synchronous reset
wire       sig_sw;

// PLL instance
pll u0(
    .areset(~reset_n),    // Active high async reset for PLL
    .inclk0(clk_50),
    .c0(sysclk),
    .locked(locked)
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

always @(posedge sysclk or negedge rst_n)
begin
    if (!rst_n) 
        led_reg     <= 1'b0; 
    else
    begin
        if (!sig_sw) 
            led_reg <= ~led_reg;  // Toggle LED on falling edge
    end
end

assign led_o = led_reg;


endmodule
