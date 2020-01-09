module clock_n(refclk, outclk);
	input      refclk;
	output reg outclk;
	reg [31:0] counter;
	parameter N = 10;

	initial begin
		counter <= 0;
		outclk <= 0;
	end

	always @(posedge refclk) begin
		if (counter >= N / 2 - 1) begin
			counter <= 0;
			outclk <= ~outclk;
		end else
			counter <= counter + 1;	
	end
endmodule
