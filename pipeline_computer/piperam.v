module piperam(addr, datain, mwmem, clock, mem_clock, data_out, sw, hex0, hex1, hex2, hex3, hex4, hex5);
	input  [31:0]	addr, datain;
	input 			mwmem, clock, mem_clock;
	input  [9:0]   sw;
	output [31:0]	data_out;
	output [6:0]	hex0, hex1, hex2, hex3, hex4, hex5;
	
	wire				write_mem_enable, write_io_enable;
	wire	 [31:0]	mem_dataout, io_read_dataout;
	
	assign write_mem_enable = mwmem & ~addr[7];
	assign write_io_enable  = mwmem & addr[7];
	
	mux2x32 mem_io_mux(mem_dataout, io_read_dataout, addr[7], data_out);
	
	lpm_ram_dq_dram mem_ram(addr[6:2], mem_clock, datain, write_mem_enable, mem_dataout);
	
	io_mem_dram io_ram(addr, datain, write_io_enable, mem_clock, sw, hex0, hex1, hex2, hex3, hex4, hex5, io_read_dataout);
	
endmodule
