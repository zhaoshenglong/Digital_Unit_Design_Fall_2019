module pipemem(mwmem,malu,mb,clock,mem_clock,mmo, sw, hex0, hex1, hex2, hex3, hex4, hex5);
	input 			mwmem, clock, mem_clock;
	input	 [31:0]	malu, mb;
	input  [9:0]	sw;
	output [31:0]	mmo;
	output [6:0]	hex0, hex1, hex2, hex3, hex4, hex5;
	
	
	piperam pipe_ram_unit(malu, mb, mwmem, clock, mem_clock, mmo, sw, hex0, hex1, hex2, hex3, hex4, hex5);
	
endmodule
