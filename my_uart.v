module my_uart 
#(
    parameter N = 8,                // Counter width
    parameter PSCALER = 625         // Divider
    parameter DIV = 10              // Divider
)
(
    input   wire    sysclk,
    input   wire    reset_n,
    input   wire    rx_i,
    output  wire    tx_o
);

    // Declare the state register to be "safe" to implement
	// a safe state machine that can recover gracefully from
	// an illegal state (by returning to the reset state).
	(* syn_encoding = "safe" *) reg [2:0] state;

    reg [N-1:0]     pScaler_reg;
    // holds the next value of internal counter
    wire [N-1:0] pScaler_next;

    reg [7:0]       counter_bits;
    reg [DIV-1:0]   bits;
    integer index   = 0;
    // Declare states
	parameter START_BIT = 1, BITS = 2, STOP_BIT = 4;


    // Determine the next state
	always @ (posedge sysclk) begin
		if (!reset_n) begin
            state   <= START_BIT;
            bits    <= ~0;
        end
		else begin
            if(pScaler_reg >= PSCALER-1) 
            begin
                bits[DIV-1:1]   <= bits[DIV-2:0];
                bits[0]         <= rx_i;
                pScaler_reg <= 0;
            end
            else
                pScaler_reg <= pScaler_reg + 1;
			case (state)
				START_BIT: begin
					if (!bits[DIV-1]) begin
                        counter_bits = 0;
                        for(index=0; index < DIV-2; index=index+1)
                            counter_bits = counter_bits + bits[index];
                        if(counter_bits < 3) begin
                            counter_bits = 0;
                            state <= BITS;
                        end
                    end
                end
				BITS: begin
					state <= STOP_BIT;
                end
				STOP_BIT: begin
                    state <= START_BIT;
                end
			endcase
        end
	end
endmodule
