`timescale 1us/1us

module vga_sim;
	reg[2:0] KEY_sim;
	reg		CLOCK_50M_sim;
	reg  		reset_sim;
	wire	 	hs_sim;
	wire		vs_sim;
	wire		VGA_BLANK_sim;
	wire		VGA_CLK_sim;
	wire[7:0] VGA_R_sim;
	wire[7:0] VGA_G_sim;
	wire[7:0] VGA_B_sim;
	
	vga_main vga_instance(CLOCK_50M_sim, reset_sim, KEY_sim, hs_sim, 
								 vs_sim, VGA_BLANK_sim, VGA_CLK_sim, 
								 VGA_R_sim, VGA_G_sim, VGA_B_sim);
		
	initial
	begin
		CLOCK_50M_sim = 1;
		while(1)
			#1 CLOCK_50M_sim = ~ CLOCK_50M_sim;
	end
	
	initial
   begin
		reset_sim = 0;            // 低电平持续10个时间单位，后一直为1。
		while (1)
			#5 reset_sim = 1;
   end
	
endmodule
