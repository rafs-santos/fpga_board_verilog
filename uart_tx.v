module uart_tx
#(
    parameter N = 8,                // Counter width
    parameter PSCALER = 1,        // Divider
    parameter DIV = 10              // Divider
)
(
    input   wire    sysclk,
    input   wire    reset_n,
    input   wire    parity_i,
    input   wire    tx_start_i,
    input   wire    [N-1:0] tx_data_i,
    output  wire    tx_end_o,
    output  wire    tx_o
);

    // Declare the state register to be "safe" to implement
	// a safe state machine that can recover gracefully from
	// an illegal state (by returning to the reset state).
	(* syn_encoding = "safe" *) reg [3:0] state_reg;

    reg [7:0]       txdata_reg;
    reg [16-1:0]    pscaler_reg;
    reg [7:0]       counter_bits;
    reg [7:0]       counter_data;
    reg             sig_tx;
    reg             sig_tx_end;
    reg             rx_err;
    reg             rx_end;

    integer index   = 0;
    // Declare state_regs
	parameter IDLE = 1, START_BIT = 2, BITS = 4, STOP_BIT = 8;

    assign tx_o     = sig_tx;
    assign tx_end_o = sig_tx_end;
    // Determine the next state_reg
	always @ (posedge sysclk) begin
		if (!reset_n) begin
            state_reg       <= IDLE;
            pscaler_reg     <= 0;
            counter_bits    <= 0;
            counter_data    <= 0;
            sig_tx_end      <= 0;
            sig_tx          <= 1'b1;
        end
		else begin
            if(pscaler_reg >= PSCALER-1) 
            begin
                pscaler_reg <= 0;
            end
            else
                pscaler_reg <= pscaler_reg + 1;
                
			case (state_reg)
				IDLE: begin
                    sig_tx          <= 1'b1;
                    ///> After a transmition keep sig_tx_end for DIV TIME
                    // If transition occurs before DIV TIME it's fine.
                    if(counter_bits >= DIV-1)
                        sig_tx_end      <= 1'b0;
                    else
                        counter_bits <= counter_bits + 1;

                    if(tx_start_i) 
                    begin
                        state_reg       <= START_BIT;
                        pscaler_reg     <= 1;
                        sig_tx          <= 1'b0;
                        counter_bits    <= 0;
                    end
                end
                START_BIT: begin
					if(pscaler_reg == 0) 
                    begin
                        sig_tx              <= 1'b0;
                        sig_tx_end          <= 1'b0;
                        if (counter_bits == DIV-1) 
                        begin
                            counter_bits    <= 0;
                            state_reg       <= BITS;
                            counter_data    <= 0;
                            sig_tx          <= tx_data_i[0];
                        end
                        else
                            counter_bits <= counter_bits + 1;
                    end
                end
				BITS: begin
                    if(pscaler_reg == 0) 
                    begin
                        sig_tx_end      <= 1'b0;
                        sig_tx          <= tx_data_i[counter_data];
                        if (counter_bits == DIV-1) 
                        begin
                            counter_bits        <= 0;
                            if(counter_data >= 8'd7) 
                            begin
                                state_reg       <= STOP_BIT;
                                sig_tx          <= 1'b1;
                                counter_data    <= 0;
                                counter_bits    <= 0;
                            end 
                            else 
                            begin
                                counter_data    <= counter_data + 1;
                                sig_tx          <= tx_data_i[counter_data+1];
                            end 
                        end
                        else
                            counter_bits <= counter_bits + 1;    
                    end
                end
				STOP_BIT: begin
                    if (pscaler_reg == 0)
                    begin
                        sig_tx          <= 1'b1;
                        if (counter_bits == DIV-1) 
                        begin
                            counter_bits    <= 0;
                            state_reg       <= IDLE;
                            sig_tx_end      <= 1'b1;
                        end
                        else
                            counter_bits    <= counter_bits + 1;
                    end
                end
			endcase
        end
	end
endmodule