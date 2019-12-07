module pipedereg(dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift,
	djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
	ea,eb,eimm,ern0,eshift,ejal,epc4);
	
	input  		 	dwreg, dm2reg, dwmem, daluimm, dshift, djal, clock, resetn;
	input  [3:0]	daluc;
	input	 [4:0]	drn;
	input  [31:0] 	da, db, dimm, dpc4;
	
	output reg [31:0]	epc4, ea, eb, eimm;
	output reg [3:0]	ealuc;
	output reg [4:0]	ern0;
	output reg			ewreg, em2reg, ewmem, ealuimm, eshift, ejal;
	
	always @(posedge clock or negedge resetn) begin
		if (~resetn) begin
		// 这里是不是可能有bug
			epc4 	<= 0;
			ea 	<= 0;
			eb 	<= 0;
			eimm	<= 0;
			ealuc	<= 0;
			ern0	<= 0;
			ewreg <= 0;
			em2reg <= 0;
			ewmem <= 0;
			ealuimm <= 0;
			eshift <= 0;
			ejal  <= 0;
		end else begin
			epc4 	<= dpc4;
			ea 	<=	da;
			eb 	<= db;
			eimm 	<= dimm;
			
			ealuc <= daluc;
			ern0 	<= drn;
			
			ewreg <= dwreg;
			em2reg <= dm2reg;
			ewmem <= dwmem;
			ealuimm <= daluimm;
			eshift <= dshift;
			ejal  <= djal;
		end
	end
endmodule