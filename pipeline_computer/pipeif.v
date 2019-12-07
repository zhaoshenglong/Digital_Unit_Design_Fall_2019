module pipeif(pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock);
	input  [1:0]	pcsource;
	input  [31:0] 	pc, bpc, da, jpc;
	input 			mem_clock;
	output [31:0]	npc, ins, pc4;
	
	assign pc4 = pc + 32'h4;
	mux4x32 nextpc(pc4, bpc, da, jpc, pcsource, npc);
	
	lpm_rom_irom irom (pc[7:2], mem_clock, ins);

endmodule
