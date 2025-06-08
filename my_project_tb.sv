`timescale 1ns/1ns
`define PERIOD 20

module my_project_tb;
    parameter CONST_D = 8'h0A;
    logic sysclk;
    logic reset_n;


    logic     sig_sw;
    logic     sig_out;

task automatic switch_bounce(
    input   logic final_state_i,
    ref     logic bounced_sw_o
);
    const time MIN_BOUNCE_DELAY = 1ns;
    const time MAX_BOUNCE_DELAY = 2ns;
    const int  N_BOUNCES = 20;
    const time SETTLE_TIME = 200ns;
    
    int i;
    int prob;
    // Start at opposite state
    bounced_sw_o = ~final_state_i;  
    
    for (i = 0; i < N_BOUNCES; i++) begin
        // Random delay between bounces
        #MAX_BOUNCE_DELAY;
        prob = $urandom_range(0, 100);
        // Apply random bounce state
        bounced_sw_o = (prob > 50) ? 1'b1 : 1'b0;
        // Monitor switch output
        $display("[%t] Bounce %0d: state=%b: ", 
                 $time, i+1, bounced_sw_o);
    end
    // Final settle and set to target state
    bounced_sw_o = final_state_i;
    #SETTLE_TIME;
    
endtask

my_project dut
(
    .clk_50(sysclk),
    .reset_n(reset_n),
    .sw_i(sig_sw),
    .led_o(sig_out)
);
    // Stimulus generator and test verification
    initial
        begin
            // Initialize inputs
            reset_n = 0;
            sig_sw = 1;
            // Release reset after 20ns
            #300 reset_n = 1;
            // Wait for initial clock edge
            @(posedge sysclk);
            @(posedge sysclk);
            // Trigger switch bounce (final state = 1)
            sig_sw = 1;
            #300 
            switch_bounce(.final_state_i(1'b0),
                          .bounced_sw_o(sig_sw));
            switch_bounce(.final_state_i(1'b1),
                          .bounced_sw_o(sig_sw));
            #400 $finish;  // Final termination
        end

    // Clock generation (100 MHz)
    always
        begin
            sysclk <= 1; #(`PERIOD/2);
            sysclk <= 0; #(`PERIOD/2);
        end
endmodule

