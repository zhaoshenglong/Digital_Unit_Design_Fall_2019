module vga_controller(clk, reset, vga_data, 
							 vga_clk, vga_hs, vga_vs,
							 vga_blank,
							 vga_r, vga_g, vga_b, vga_xpos, vga_ypos);
	/**
	 **************  	clk		H_SYNC	H_BACK	H_DISPLAY	H_FRONT	H_TOTAL	V_SYNC	V_BACK	V_DISPLAY	V_FRONT	V_TOTAL
	 * 640x480@60Hz 	25.MHZ	96			48			640			16			800		2			33			480			10			525	
	 */
	
	input 		clk;
	input 		reset;
	input [23:0] vga_data;
	output		vga_hs;
	output		vga_vs;
	output		vga_blank;
	output		vga_clk;
	output reg[7:0] vga_r;
	output reg[7:0] vga_g;
	output reg[7:0] vga_b;
	output[9:0]	 vga_xpos;
	output[9:0]	 vga_ypos;
	
	reg[9:0]		hcnt;
	reg[9:0]		vcnt;
	
	parameter H_SYNC = 96;
	parameter H_BACK = 48;
	parameter H_DISPLAY = 640;
	parameter H_FRONT = 16;
	parameter H_TOTAL = 800;
	parameter V_SYNC = 2;
	parameter V_BACK = 33;
	parameter V_DISPLAY = 480;
	parameter V_FRONT = 10;
	parameter V_TOTAL = 525;
	
	assign vga_clk = clk;

	
	always@(posedge clk or negedge reset) 
	begin
		if (~reset) begin
			hcnt = 0;
			vcnt = 0;
		end else begin
			hcnt = hcnt + 9'b1;
			if(hcnt == H_TOTAL) begin						// line over
				hcnt = 9'b0;
				vcnt = vcnt + 9'b1;				
				if (vcnt == V_TOTAL)	 	   // frame over
					vcnt = 9'b0;
			end
		end
	end
	
	assign vga_hs = ~(hcnt >= H_DISPLAY + H_FRONT && hcnt < H_DISPLAY + H_FRONT + H_SYNC);
	assign vga_vs = ~(vcnt >= V_DISPLAY + V_FRONT && vcnt < V_DISPLAY + V_FRONT + V_SYNC);
	assign vga_blank = vcnt < V_DISPLAY && hcnt < H_DISPLAY;
	
	always @ (posedge clk)
	begin
		vga_r = vga_data[23:16];
		vga_g = vga_data[15:8];
		vga_b = vga_data[7:0];
	end
	
	assign vga_xpos = hcnt;
	assign vga_ypos = vcnt;
	
endmodule
