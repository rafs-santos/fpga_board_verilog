module my_uart 
#(
    parameter N = 8,                // Counter width
    parameter PSCALER = 1,        // Divider
    parameter DIV = 10              // Divider
)
(
    input   wire    sysclk,
    input   wire    reset_n,
    input   wire    parity_i,
    input   wire    rx_i,
    output  wire    tx_o
);

    // Declare the state register to be "safe" to implement
	// a safe state machine that can recover gracefully from
	// an illegal state (by returning to the reset state).
	(* syn_encoding = "safe" *) reg [2:0] state_reg;

    reg [8:0]       rxdata_reg;
    reg [N-1:0]     pscaler_reg;
    reg [7:0]       counter_bits;
    reg [7:0]       counter_data;
    reg [DIV-1:0]   shift_reg;
    reg [2:0]       mbits_reg;
    reg             rx_err;
    reg             rx_end;

    integer index   = 0;
    // Declare state_regs
	parameter START_BIT = 1, BITS = 2, STOP_BIT = 4;


    // Determine the next state_reg
	always @ (posedge sysclk) begin
		if (!reset_n) begin
            state_reg       <= START_BIT;
            shift_reg        <= ~0;
            pscaler_reg <= 0;
        end
		else begin
            if(pscaler_reg >= PSCALER-1) 
            begin
                shift_reg[DIV-1:1]  <= shift_reg[DIV-2:0];
                mbits_reg           <= shift_reg[DIV/2+1:DIV/2-1];
                shift_reg[0]        <= rx_i;
                pscaler_reg         <= 0;
                counter_bits        <= 0;
                counter_data        <= 0;
                rxdata_reg          <= 0;
            end
            else
                pscaler_reg <= pscaler_reg + 1;
			case (state_reg)
				START_BIT: begin
					if(pscaler_reg == 0) begin
                        if (!shift_reg[DIV-1]) 
                        begin
                            counter_bits = 0;
                            for(index=0; index < DIV-2; index=index+1)
                                counter_bits = counter_bits + shift_reg[index];
                            if(counter_bits < 8'd3) begin
                                counter_bits = 0;
                                state_reg <= BITS;
                            end
                        end
                    end
                end
				BITS: begin
                    if(pscaler_reg == 0) 
                    begin
                        if (counter_bits == DIV-1) 
                        begin
                            counter_bits        <= 0;
                            if((mbits_reg[0] + mbits_reg[1] + mbits_reg[2]) > 3'd1)
                                rxdata_reg[counter_data] <= 1'b1;
                            else
                                rxdata_reg[counter_data] <= 1'b0;
                            
                            if(counter_data >= 8'd7) 
                            begin
                                state_reg       <= STOP_BIT;
                                counter_data    <= 0;
                                counter_bits    <= 0;
                            end 
                            else
                                counter_data <= counter_data + 1;
                        end
                        else
                            counter_bits <= counter_bits + 1;    
                    end
                end
				STOP_BIT: begin
                    if (pscaler_reg == 0)
                    begin
                        if (counter_bits == DIV-1) 
                        begin
                            counter_bits    <= 0;
                            if((mbits_reg[0] + mbits_reg[1] + mbits_reg[2]) > 1) 
                            begin
                                rx_err <= 1'b0;
                                rx_end <= 1'b1;
                            end
                            else
                            begin
                                rx_err <= 1'b1;
                                rx_end <= 1'b0;
                            end
                        end
                        else
                            counter_bits    <= counter_bits + 1;
                    end
                end
			endcase
        end
	end
endmodule