module my_debounce 
#(
    parameter N = 8,                    // Counter width
    parameter [N-1:0] MAX_VAL = {N{1'b1}}  // Max counter value
)(
    input  wire        sysclk,
    input  wire        reset_n,
    input  wire        signal_i,       // Already synchronized input
    output wire        signal_o
);

// FSM states
localparam [1:0] 
    ST_UP   = 2'b01,
    ST_DOWN = 2'b10;

// Registers
reg [1:0] state_reg;
reg [1:0] state_next;
reg [N-1:0] counter_reg;
reg [N-1:0] counter_next;
reg        sig_edge;
reg        sig_prev;

// Edge detection (on synchronized signal)


// State and counter registers
always @(posedge sysclk or negedge reset_n) begin
    if (!reset_n) begin
        state_reg   <= ST_UP;
        counter_reg <= 0;
        sig_edge    <= 1'b0;
        sig_prev    <= 1'b0;
    end else begin
        state_reg   <= state_next;
        counter_reg <= counter_next;
        sig_prev    <= signal_i;
        sig_edge    <= signal_i ^ sig_prev;
    end
end
// Edge detection using synchronized signal
// wire sig_edge_pos = sig_reg_i & ~(signal_i);
// wire sig_edge_neg = ~sig_reg_i & signal_i;
// Counter logic
always @(*) begin
    if (sig_edge)
        counter_next = 0;
    else if (counter_reg <= MAX_VAL-1)
        counter_next = counter_reg + 1;
    else
        counter_next = counter_reg;
end

// FSM next state logic
always @(*) begin
    state_next = state_reg;
    case (state_reg)
        ST_UP:
        begin
            if ((counter_reg == MAX_VAL-1) && !signal_i)
                state_next = ST_DOWN;
        end
        ST_DOWN:
        begin
            if ((counter_reg == MAX_VAL-1) && signal_i)
                state_next = ST_UP;
        end
    endcase
end

// Output assignment
assign signal_o =  (state_reg == ST_UP) ? 1'b1 : 1'b0;

endmodule
