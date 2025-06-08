module sync_meta #(
    parameter WIDTH = 1,          // Bit-width of input signal
    parameter STAGES = 2          // Number of sync stages (min 2)
) (
    input wire sysclk,
    input wire reset_n,
    input wire [WIDTH-1:0] async_in,   // Asynchronous input
    output wire [WIDTH-1:0] sync_out   // Synchronized output
);

    // Flattened synchronization pipe
    reg [WIDTH-1:0] sync_pipe [0:STAGES-1];
    integer i;  // Only need single index variable

    always @(posedge sysclk or negedge reset_n) 
    begin
        if(!reset_n) begin
            // CORRECTED RESET LOGIC
            for (i = 0; i < STAGES; i = i + 1) begin
                sync_pipe[i] <= {WIDTH{1'b0}};  // Proper vector reset
            end
        end
        else begin
            sync_pipe[0] <= async_in;           // First stage samples async input
            for (i = 1; i < STAGES; i = i + 1) begin
                sync_pipe[i] <= sync_pipe[i-1]; // Shift through pipeline
            end    
        end        
    end

    assign sync_out = sync_pipe[STAGES-1];  // Output from last stage

endmodule