module pipeexe(ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu);
	input  [3:0]	ealuc; 
	input	 [4:0]	ern0;
	input 			ealuimm, eshift, ejal; 
	input  [31:0]	ea, eb, eimm, epc4;
	
	output [4:0]	ern;
	output [31:0]	ealu;
	
	wire 	 [31:0]	alua, alub, ealu_from_unit, epc8;
	
	assign epc8 = epc4 + 32'h4;
	
	mux2x32 alu_a(ea, eimm, eshift, alua);
	mux2x32 alu_b(eb, eimm, ealuimm, alub);
	alu alu_unit(alua, alub, ealuc, ealu_from_unit);
	mux2x32 ealu_mux(ealu_from_unit, epc8, ejal, ealu);
	assign ern = ejal ? 5'b11111 : ern0;
endmodule
