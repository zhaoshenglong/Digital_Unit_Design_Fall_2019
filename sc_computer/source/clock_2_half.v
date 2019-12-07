module clock_2_half(mem_clk, clk);
input mem_clk;
output reg clk;

reg counter;

always @(posedge mem_clk)
begin
	clk <= ~clk;
end
endmodule