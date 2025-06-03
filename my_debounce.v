module my_debounce 
#(parameter N = 8) (
    input        sysclk,
    input        reset_n,
    input [N-1:0] max_value,   // Removed 'reg' for input
    input        signal_i,
    output       signal_o
);

reg sig_reg_i;
reg [1:0] state_reg;
reg [1:0] state_next;
reg [N-1:0] counter_reg;
reg [N-1:0] counter_next;

// Fixed parameter definitions
parameter UP   = 2'b01;
parameter DOWN = 2'b10;

// Synchronize input and update registers
always @(posedge sysclk or negedge reset_n) begin
    if (!reset_n) begin
        counter_reg <= 0;
        sig_reg_i   <= 0;
        state_reg   <= UP;
    end else begin
        counter_reg <= counter_next;
        sig_reg_i   <= signal_i;  // Single-stage synchronizer
        state_reg   <= state_next;
    end
end

// Edge detection using synchronized signal
wire sig_edge_pos = sig_reg_i & ~(signal_i);
wire sig_edge_neg = ~sig_reg_i & signal_i;

// Counter next-state logic
always @(*) begin
    if (sig_edge_pos || sig_edge_neg) 
        counter_next = 0;
    else if (counter_reg < max_value)
        counter_next = counter_reg + 1;
    else 
        counter_next = counter_reg;
end

// FSM next-state logic
always @(*) begin
    state_next = state_reg;  // Default: stay in current state
    
    case (state_reg)
        UP: begin
            if ((counter_reg == max_value) && !sig_reg_i)
                state_next = DOWN;
        end
        DOWN: begin
            if ((counter_reg == max_value) && sig_reg_i)
                state_next = UP;
        end
        default: state_next = UP;
    endcase
end

// Output assignment
assign signal_o = (state_reg == UP) ? 1'b1 : 1'b0;

endmodule

// module my_debounce 
// # (parameter N = 8)
// (
//     input               sysclk,
//     input               reset_n,
//     input reg[N-1:0]    max_value,
//     input               signal_i,
//     output              signal_o
// );


// reg         sig_reg_i;
// reg         sig_out;       		// Previous stable value
// wire        sig_comb;
// reg [1:0]   state_reg;
// reg [1:0]   state_next;
// reg [N-1:0] counter_reg;
// reg [N-1:0] counter_next;

// logic       sig_edge_pos;
// logic       sig_edge_neg;

// parameter UP    2'b01;
// parameter DOWN  2'b10;

// // Synchronize input and counter register
// always @(posedge sysclk, negedge reset_n)
// begin
//     if(!reset_n)
//         counter_reg <= 0;
//     else
//     begin
//         counter_reg <= counter_next;
//         sig_reg_i   <= signal_i;
//     end
// end

// assign sig_edge_pos = signal_i & ~sig_reg_i;
// assign sig_edge_neg = sig_reg_i & ~signal_i;
// // next state logic
// always @ (*)
// begin
//     counter_next = counter_reg;
//     if(sig_edge_pos | sig_edge_neg)
//         counter_next = 0;
//     else if(counter_reg < max_value)
//         counter_next = counter_next + 1;

// end
   
    

// // Synchronize switch input to avoid metastability
// always @(posedge sysclk, negedge reset_n)
// begin
//     if(!reset_n)
//         state_reg <= UP;
//     else
//         state_reg <= state_next;
// end

// // next state logic
// always @ (*)
//     case (state)
//         UP:
//             state_next = UP;
//             if(counter_reg == max_value-1)
//                 if(!sig_reg_i)
//                     state_next = DOWN;
//         DOWN:
//             state_next = DOWN;
//             if(counter_reg == max_value-1)
//                 if(sig_reg_i)
//                     state_next = UP;
//         default:
//             state_next = UP;
//     endcase


    
// endmodule
