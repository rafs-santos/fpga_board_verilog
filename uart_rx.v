module uart_rx
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
    output  reg     rx_err_o,
    output  reg     rx_end_o,
    output  wire    [N-1:0] rx_data_o
);

    // Declare the state register to be "safe" to implement
	// a safe state machine that can recover gracefully from
	// an illegal state (by returning to the reset state).
	(* syn_encoding = "safe" *) reg [3:0] state_reg;

    reg [7:0]       rxdata_reg;
    reg [16-1:0]    pscaler_reg;
    reg [7:0]       counter_bits;
    reg [7:0]       counter_data;
    reg [DIV-1:0]   shift_reg;
    reg [2:0]       mbits_reg;

    integer index   = 0;
    // Declare state_regs
	parameter IDLE=1, START_BIT = 2, BITS = 4, STOP_BIT = 8;

    assign rx_data_o = rxdata_reg;

    // Determine the next state_reg
	always @ (posedge sysclk) begin
		if (!reset_n) 
        begin
            state_reg       <= IDLE;
            shift_reg       <= ~0;
            pscaler_reg     <= 0;
            counter_bits    <= 0;
            counter_data    <= 0;
            rxdata_reg      <= 0;
        end
		else
        begin
            if(pscaler_reg >= PSCALER-1) 
            begin
                shift_reg[DIV-1:1]  <= shift_reg[DIV-2:0];
                mbits_reg           <= shift_reg[DIV/2+1:DIV/2-1];
                shift_reg[0]        <= rx_i;
                pscaler_reg         <= 0;
            end
            else
                pscaler_reg <= pscaler_reg + 1;
                
			case (state_reg)
                IDLE:
                begin
					if(rx_i == 0)
                    begin
                        state_reg   <= START_BIT;
                        pscaler_reg <= 1;
                    end
                end
				START_BIT: 
                begin
					if(pscaler_reg == 0) 
                    begin
                        rx_err_o    <= 1'b0;
                        rx_end_o    <= 1'b0;
                        if (counter_bits == DIV-1) 
                        begin
                                counter_bits = 0;
                                if((mbits_reg[0] + mbits_reg[1] + mbits_reg[2]) > 3'd1)
                                    state_reg   <= IDLE;
                                else
                                    state_reg   <= BITS;
                        end
                        else
                            counter_bits <= counter_bits + 1;  
                    end
                end
				BITS:
                begin
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
				STOP_BIT:
                begin
                    if (pscaler_reg == 0)
                    begin
                        if (counter_bits == DIV-1) 
                        begin
                            counter_bits    <= 0;
                            if((mbits_reg[0] + mbits_reg[1] + mbits_reg[2]) > 1) 
                            begin
                                rx_err_o    <= 1'b0;
                                rx_end_o    <= 1'b1;
                                state_reg   <= IDLE;
                            end
                            else
                            begin
                                rx_err_o <= 1'b1;
                                rx_end_o <= 1'b0;
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