module my_project (
    input        clk_50,
    input        reset_n,
    input        sw_i,
    output       led_o
);

parameter CONST_D = 8'h0A;

wire       sysclk;
wire       locked;
reg        led_reg;
wire       rst_n;              		// Synchronous reset
wire       sig_sw;

reg       sig_load_reg;
reg       sig_load_next;
reg       sig_en_reg;
reg       sig_en_next;
reg       sig_sw_reg;
reg       sig_sw_next;

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

//Instantiate the DUT
my_bin_counter #
(
    .N(8)
)
dut (
    .sysclk(sysclk),
    .reset_n(rst_n),
    .syn_clr(1'b0),
    .load(sig_load_reg),
    .en(sig_en_reg),
    .up(1'b0),
    .d(CONST_D),
    .max_tick(sig_max_tick),
    .min_tick(sig_min_tick),
    .q()
);

always @(posedge sysclk, negedge reset_n)
begin
    if(!reset_n)
    begin
        sig_en_reg      <= 1'b0;
        sig_load_reg    <= 1'b0;
    end
        
    else
    begin
        sig_load_reg    <= sig_load_next;
        sig_load_reg    <= sig_load_next;
        sig_sw_reg      <= sig_sw_next;    
    end    
end

// next state logic
always @*
begin

    sig_load_next = 1'b1;
    sig_en_next = 1'b0;
    sig_sw_next <= sig_sw_reg;
    if (sig_sw)
        sig_sw_next <= sig_sw;
    else if (!sig_sw & sig_min_tick)
        sig_sw_next = sig_sw;    
    else
    begin
       sig_load_next = 1'b0;
       sig_en_next = 1'b1;
    end
end


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
