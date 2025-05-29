module my_debounce (
    input        sysclk,
    input        reset_n,
    input        signal_i,
    output       signal_o
);


reg        led_reg;
reg        sig_out;       		// Previous stable value
wire       sig_comb;
reg [3:0] counter_down;

// Synchronize switch input to avoid metastability
always @(posedge sysclk)
begin
    sw_sync_0 <= sw_i;
    sw_sync_1 <= sw_sync_0;
end

assign led_o = led_reg;

always @(posedge sysclk) begin
    if (!reset_n) begin
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
