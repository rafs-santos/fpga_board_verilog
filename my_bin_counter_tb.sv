`timescale 1ns/1ns
`define PERIOD 10

module my_bin_counter_tb;
    parameter CONST_D = 8'h0A;
    logic sysclk;
    logic reset_n;
    logic [7:0] sig_d;
    logic [7:0] sig_q;
    logic sig_syn_clr;
    logic sig_load;
    logic sig_en;
    logic sig_up;
    logic sig_max_tick;
    logic sig_min_tick;

    logic     sig_sw;

    reg       sig_load_reg;
    reg       sig_load_next;
    reg       sig_en_reg;
    reg       sig_en_next;
    reg       sig_sw_reg;
    reg       sig_sw_next;


    //Instantiate the DUT
    my_bin_counter #
    (
        .N(8)
    )
    dut (
        .sysclk(sysclk),
        .reset_n(reset_n),
        .syn_clr(1'b0),
        .load(sig_load_reg),
        .en(sig_en_reg),
        .up(1'b0),
        .d(CONST_D),
        .max_tick(sig_max_tick),
        .min_tick(sig_min_tick),
        .q()
    );

    // Stimulus generator and test verification
    initial
        begin
            // Initialize inputs
            reset_n = 0;
            sig_d = 8'h00;
            sig_en = 0;
            sig_up = 0;
            sig_load = 1;
            sig_sw = 1;
            // Release reset after 20ns
            #20 reset_n = 1;
            // Wait for initial clock edge
            @(posedge sysclk);
            sig_load = 1'b0;
            sig_en = 1'b1; #30;
            @(posedge sysclk);
            // Trigger switch bounce (final state = 1)
            switch_bounce(1'b0, sig_sw);

            #200 $finish;  // Final termination
        end

    // Clock generation (100 MHz)
    always
        begin
            sysclk <= 1; #(`PERIOD/2);
            sysclk <= 0; #(`PERIOD/2);
        end

    always @(posedge sysclk, negedge reset_n)
    begin
        if(!reset_n)
        begin
            sig_en_reg      <= 1'b0;
            sig_load_reg    <= 1'b0;
        end
            
        else
        begin
            sig_load_reg  <= sig_load_next;
            sig_en_reg    <= sig_en_next;
            sig_sw_reg    <= sig_sw_next;    
        end    
    end

    // next state logic
    always @*
    begin

        sig_load_next = 1'b1;
        sig_en_next = 1'b0;
        sig_sw_next = sig_sw_reg;
        if (sig_sw)
            sig_sw_next <= 1'b1;
        else if (!sig_sw & sig_min_tick)
            sig_sw_next = 1'b0;    
        else
        begin
            sig_load_next = 1'b0;
            sig_en_next = 1'b1;
        end
    end
endmodule

task automatic switch_bounce(
    input   logic final_state_i,
    ref     logic bounced_sw_o
);
    const time MIN_BOUNCE_DELAY = 1ns;
    const time MAX_BOUNCE_DELAY = 20ns;
    const int  N_BOUNCES = 15;
    const time SETTLE_TIME = 200ns;
    
    int i;
    int prob;
    // Start at opposite state
    bounced_sw_o = ~final_state_i;  
    
    for (i = 0; i < N_BOUNCES; i++) begin
        // Random delay between bounces
        #($urandom_range(MIN_BOUNCE_DELAY, MAX_BOUNCE_DELAY));
        prob = $urandom_range(0, 100);
        // Apply random bounce state
        bounced_sw_o = (prob > 50) ? 1'b1 : 1'b0;
        // Monitor switch output
        $display("[%t] Bounce %0d: state=%b: ", 
                 $time, i+1, bounced_sw_o);
    end
    
    // Final settle and set to target state
    #SETTLE_TIME;
    bounced_sw_o = final_state_i;
endtask