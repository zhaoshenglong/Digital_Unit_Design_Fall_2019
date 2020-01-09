module pipepc(npc, wpcir, clock, resetn, pc);
	input  [31:0] 		npc;
	input 				wpcir, clock, resetn;
	output reg [31:0]	pc;
	
	always @ (posedge clock or negedge resetn) begin
		if (~resetn) begin
			pc <= 0;
		end else begin
			if (~wpcir) begin
				pc = npc;
			end
		end
	end
endmodule
