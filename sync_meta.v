module sync_meta #(
    parameter WIDTH = 1,          // Bit-width of input signal
    parameter STAGES = 2         // Number of sync stages (min 2)
) (
    input sysclk,
    input [WIDTH-1:0] async_in,   // Asynchronous input
    output [WIDTH-1:0] sync_out  // Synchronized output
);

// Synchronization chain registers
reg [WIDTH-1:0] sync_pipe [STAGES-1:0];
integer i;

always @(posedge sysclk) 
begin    
    // First stage directly samples async input
    sync_pipe[0] <= async_in;

    // Subsequent stages sample previous stage
    for (i = 1; i < STAGES; i = i + 1) 
    begin
        sync_pipe[i] <= sync_pipe[i-1];
    end   
end

assign sync_out = sync_pipe[STAGES-1];


endmodule