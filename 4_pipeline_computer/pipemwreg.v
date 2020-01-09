module pipemwreg(mwreg,mm2reg,mmo,malu,mrn,clock,resetn,
	wwreg,wm2reg,wmo,walu,wrn);
	input 			mwreg, mm2reg, clock, resetn;
	input  [31:0]	mmo, malu;
	input  [4:0]	mrn;
	
	output reg			wwreg, wm2reg;
	output reg [31:0]	wmo, walu;
	output reg [4:0]	wrn;
	
	always @ (posedge clock or negedge resetn) begin
		if (~resetn) begin
			wwreg 	<= 0;
			wm2reg 	<= 0;
			wmo 		<= 0;
			walu		<= 0;
			wrn		<= 0;
		end else begin
			wwreg		<= mwreg;
			wm2reg	<= mm2reg;
			wmo		<= mmo;
			walu		<= malu;
			wrn		<= mrn;
		end 
	end 
	
endmodule
