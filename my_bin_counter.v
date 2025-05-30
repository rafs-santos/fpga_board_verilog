module my_bin_counter #
(
    parameter N=8
)
(
    input   wire    sysclk,
    input   wire    reset_n,
    input   wire    syn_clr,
    input   wire    load,
    input   wire    en,
    input   wire    up,
    input   wire    [N-1:0] d,
    output  wire    max_tick,
    output  wire    min_tick,
    output  wire    [N-1:0] q
);


reg [N-1:0] r_reg;
reg [N-1:0] r_next;

always @(posedge sysclk, negedge reset_n)
begin
    if(!reset_n)
        r_reg <= 0;
    else
        r_reg <= r_next;
end


// next state logic
always @*
begin
    if (syn_clr)
        r_next = 0;
    else if (load)
        r_next = d; 
    else if (en & up)
        r_next = r_reg + 1;
    else if (en & !up)
        r_next = r_reg - 1;
    else
        r_next = r_reg;
end
assign q = r_reg;
assign max_tick = (r_reg == 2**N-1) ? 1'b1 : 1'b0;
assign min_tick = (r_reg == 0) ? 1'b1 : 1'b0;

endmodule
