/////////////////////////////////////////////////////////////
//                                                         //
// School of Software of SJTU                              //
//                                                         //
/////////////////////////////////////////////////////////////

module sc_computer_main (resetn,clock,mem_clk,pc,inst,aluout,memout,imem_clk,dmem_clk,sw, hex0, hex1, hex2, hex3, hex4, hex5, mem_dataout, io_read_data);
   
   input resetn,clock,mem_clk; // resetn: key_0
	input [9:0] sw; 	// input switches, every 5 bits represent one operand
	
	output [6:0]  hex0,hex1,hex2,hex3,hex4,hex5;  // seven seg display
   output [31:0] pc,inst,aluout,memout;

   output        imem_clk,dmem_clk;
	output [31:0] mem_dataout, io_read_data;
   wire   [31:0] data;
   wire          wmem; // all these "wire"s are used to connect or interface the cpu,dmem,imem and so on.
   
   sc_cpu cpu (clock,resetn,inst,memout,pc,wmem,aluout,data);          // CPU module.
   sc_instmem  imem (pc,inst,clock,mem_clk,imem_clk);                  // instruction memory.
   sc_datamem  dmem (aluout,data,memout,wmem,clock,mem_clk,dmem_clk,resetn, mem_dataout, io_read_data,sw, hex0, hex1, hex2, hex3, hex4, hex5); // data memory.
	
endmodule



