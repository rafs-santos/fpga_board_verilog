module my_project (
    input        clk_50,
    input        reset_n,
    input        sw_i,
    output       led_o
);

wire       sysclk;
wire       locked;
reg        led_reg;
reg        button_reg;       		// Previous stable value
reg        sw_sync_0, sw_sync_1; 	// Synchronizer stages
reg        reset_sync_0, reset_sync_1;
wire       rst;              		// Synchronous reset

// PLL instance
pll u0(
    .areset(~reset_n),    // Active high async reset for PLL
    .inclk0(clk_50),
    .c0(sysclk),
    .locked(locked)
);

// Synchronize reset to system clock
always @(posedge sysclk) begin
    reset_sync_0 <= ~reset_n | ~locked;
    reset_sync_1 <= reset_sync_0;
end

assign rst = reset_sync_1;

// Synchronize switch input to avoid metastability
always @(posedge sysclk) begin
    sw_sync_0 <= sw_i;
    sw_sync_1 <= sw_sync_0;
end

assign led_o = led_reg;

always @(posedge sysclk) begin
    if (rst) begin
        led_reg     <= 1'b0;
        button_reg  <= 1'b1;  // Assume switch is unpressed at start
    end else begin
        if (!sw_sync_1 && button_reg) begin
            led_reg <= ~led_reg;  // Toggle LED on falling edge
        end
        button_reg <= sw_sync_1;  // Store last switch state
    end
end

endmodule
