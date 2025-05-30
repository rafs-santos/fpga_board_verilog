`timescale 1ns/1ns

module my_bin_counter_tb;
    'define WIDTH 8
    
    logic sysclk;
    logic [8:0] d;
    logic [8:0] q;
    
    //Instantiate the DUT
    my_bin_counter_tb #
    (
        .N(WIDTH)
    )
    dut (
        .sysclk(sysclk),
        .reset_n(reset_n),
        .sys_clr(sys_clr),
        .d(d),
        .q(q)
    );

    // Stimulus generator and test verification
    initial
        begin
            // Initialize inputs
            d = 4'b0000; #30;

            // Wait for initial clock edge
            @(posedge clk);

            // Test case sequence
            apply_test(4'b0001);
            
            apply_test(4'b0010);
            apply_test(4'b0100);
            apply_test(4'b1000);
            apply_test(4'b1111);

    
            #20 $finish;  // Final termination
        end
    // Task to apply and verify a single test case
    task apply_test(input [3:0] test_vector);
    // Apply test vector at negative edge
    @(negedge clk);
    d = test_vector;

    // Verify output at next positive edge
    @(posedge clk);
    @(posedge clk);
    if (q !== test_vector) begin
        $display("Error at time %0t: q = %b, expected %b", 
                $time, q, test_vector);
        $finish;
    end
    else begin
        $display("Time %0t: Test passed - d=%b, q=%b", 
                $time, test_vector, q);
    end
    endtask

    // Clock generation (100 MHz)
    always
        begin
            clk <= 1; #5;
            clk <= 0; #5;
        end
endmodule