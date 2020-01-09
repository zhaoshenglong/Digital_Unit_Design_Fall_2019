`define BLUE 	24'h0000FF
`define WHITE 	24'hFFFFFF
`define BLACK 	24'h000000

module vga_main(
		input  clk_50M, 
		input  reset,
		input  [1:0] key,
		output  [6:0] hex0,
		output  [6:0] hex1,
		output  [6:0] hex4,
		output  [6:0] hex5,
		output hs,
		output vs,
		output VGA_BLANK,
		output VGA_CLK,
		output wire[7:0] VGA_R,
		output wire[7:0] VGA_G,
		output wire[7:0] VGA_B
	);
	
	// Display area size
	parameter H_DISPLAY 	= 640;
	parameter V_DISPLAY 	= 480;
	parameter SEED 		= 4143;
	
	// Move Control
	parameter RIGHT 	= 2'd0;
	parameter LEFT   = 2'd1;
	parameter UP		= 2'd2;
	parameter DOWN 	= 2'd3;
	parameter BLOCK_SIZE = 10'd16;
	parameter SNAKE_LEN = 5;
	

	// 640*480@25.2MHz ~ 25MHz
	reg 				clk_25M;
	reg 				clk_10Hz;
	
	// counter for 4 Hz clock
	reg[31:0]		counter_10Hz;
	reg[7:0]			score, max_score;
	wire[3:0]		score_high, score_low, max_score_high, max_score_low;
	assign score_high = score / 10;
	assign score_low = score % 10;
	assign max_score_high = max_score / 10;
	assign max_score_low = max_score % 10;
	// egg & snake position
	// partition 640*480 into 40*30 16-size blocks
	reg[9:0]			egg_xpos;
	reg[9:0]			egg_ypos;
	wire[9:0]		last_egg_x, last_egg_y;
	assign last_egg_x = egg_xpos;
	assign last_egg_y = egg_ypos;
	
	// Fixed length
	reg[9:0]			snake_xpos[0:4];
	reg[9:0]			snake_ypos[0:4];
	
	// vga x,y pos, indicates current pixel under vga display
	wire[9:0] 		vga_xpos;
	wire[9:0] 		vga_ypos;
	
	// color for current pixel
	reg[23:0] 		rgb_data;
	
	wire left = key[1], right = key[0];
	
	reg[1:0]			cur_direction;
	
	// snake eat egg / snake dead
	reg				success, dead, disable_move;
	
	
	always @(posedge clk_50M)
	begin
		if (counter_10Hz >= 50 * 1000000 / 10 ) begin
			counter_10Hz = 0;
			clk_10Hz = ~clk_10Hz;
		end else begin
			counter_10Hz = counter_10Hz + 1;
		end
	end
	
	// Generate a 25MHz clock
	always @ (posedge clk_50M)
	begin
		clk_25M <= ~clk_25M;
	end
	
	
	// Render Eggs
	always @ (posedge clk_10Hz or negedge reset) 
	begin
		if (~reset) begin
			egg_xpos = 10'd0;
			egg_ypos = 10'd0;
			max_score = 0;
			score = 0;
		end else begin
			if( snake_xpos[0] >= egg_xpos && snake_xpos[0] <= egg_xpos + BLOCK_SIZE
				&& snake_ypos[0] >= egg_ypos && snake_ypos[0] <= egg_ypos + BLOCK_SIZE) begin
				success = 1'b1;
				score = score + 1;
				if(score > max_score) max_score = score;
			end
			if (success) begin
				egg_xpos = ((SEED | last_egg_x) % 40) * BLOCK_SIZE;
				egg_ypos = ((SEED | last_egg_y) % 30) * BLOCK_SIZE;
				success  = 1'b0;
			end 
		end
	end
	
	sevenseg score_display_high(score_high, hex5);
	sevenseg score_display_low(score_low, hex4);
	sevenseg max_score_display_high(max_score_high, hex1);
	sevenseg max_score_display_low(max_score_low, hex0);
	
	// Dead checking
	integer k;
	always @(posedge clk_10Hz or negedge reset)
	begin
		if (~reset) begin
			dead = 1'b0;
			disable_move = 1'b0;
		end else begin
			dead = 1'b0;
			if(snake_xpos[0] < -BLOCK_SIZE || snake_xpos[0] >= H_DISPLAY + BLOCK_SIZE 
				|| snake_ypos[0] < -BLOCK_SIZE || snake_ypos[0] >= H_DISPLAY + BLOCK_SIZE) 
				dead = 1'b1;
			for(k = 1; k < SNAKE_LEN; k = k + 1) 
			begin
				if(snake_xpos[0] == snake_xpos[k] && snake_ypos[0] == snake_ypos[k])
					dead = 1'b1;
			end
			if(dead) disable_move = 1'b0;
			else disable_move = 1'b0;
		end
	end
	
	// Move Control
	reg[9:0] prev_x, prev_y, temp_x, temp_y;
	integer i;
	always @ (posedge clk_10Hz or negedge reset) 
	begin
		if (~reset) begin
			snake_xpos[0] = 10'd64;
			snake_xpos[1] = 10'd48;
			snake_xpos[2] = 10'd32;
			snake_xpos[3] = 10'd16;
			snake_xpos[4] = 10'd0;
			snake_ypos[0] = 10'd240;
			snake_ypos[1] = 10'd240;
			snake_ypos[2] = 10'd240;
			snake_ypos[3] = 10'd240;
			snake_ypos[4] = 10'd240;
			cur_direction = RIGHT;
		end else begin
			// move head
			if (~disable_move) begin
				prev_x = snake_xpos[0];
				prev_y = snake_ypos[0];
				if (~left) begin
					if (cur_direction == RIGHT) begin
						snake_ypos[0] = snake_ypos[0] - BLOCK_SIZE;
						cur_direction = UP;
					end else if (cur_direction == LEFT) begin
						snake_ypos[0] = snake_ypos[0] + BLOCK_SIZE;
						cur_direction = DOWN;
					end else if (cur_direction == UP) begin
						snake_xpos[0] = snake_xpos[0] - BLOCK_SIZE;
						cur_direction = LEFT;
					end else begin
						snake_xpos[0] = snake_xpos[0] - BLOCK_SIZE;
						cur_direction = LEFT;
					end
				end else if (~right) begin
					if (cur_direction == RIGHT) begin
						snake_ypos[0] = snake_ypos[0] + BLOCK_SIZE;
						cur_direction = DOWN;
					end else if (cur_direction == LEFT) begin
						snake_ypos[0] = snake_ypos[0] - BLOCK_SIZE;
						cur_direction = UP;
					end else if (cur_direction == UP) begin
						snake_xpos[0] = snake_xpos[0] + BLOCK_SIZE;
						cur_direction = RIGHT;
					end else begin
						snake_xpos[0] = snake_xpos[0] + BLOCK_SIZE;
						cur_direction = RIGHT;
					end
				end else begin
					if (cur_direction == RIGHT) begin
						snake_xpos[0] = snake_xpos[0] + BLOCK_SIZE;
					end else if (cur_direction == LEFT) begin
						snake_xpos[0] = snake_xpos[0] - BLOCK_SIZE;
					end else if (cur_direction == UP) begin
						snake_ypos[0] = snake_ypos[0] - BLOCK_SIZE;
					end else begin
						snake_ypos[0] = snake_ypos[0] + BLOCK_SIZE;
					end
				end
				for(i = 1; i < SNAKE_LEN; i = i + 1) 
				begin
					temp_x = snake_xpos[i];
					temp_y = snake_ypos[i];
					snake_xpos[i] = prev_x;
					snake_ypos[i] = prev_y;
					prev_x = temp_x;
					prev_y = temp_y;
				end
			end
		end
	end
	
	// Display current pixel
	always @ (posedge clk_25M or negedge reset)
	begin
		if(~reset)
			rgb_data = 0;
		else begin
			if (vga_xpos >= egg_xpos  && vga_xpos <= egg_xpos + BLOCK_SIZE
				&& vga_ypos >= egg_ypos && vga_ypos <= egg_ypos + BLOCK_SIZE)
			begin
				rgb_data = 24'h00FFFF;
			end else begin
				if ((vga_xpos >= snake_xpos[0]  && vga_xpos <= snake_xpos[0] + BLOCK_SIZE
					&& vga_ypos >= snake_ypos[0] && vga_ypos <= snake_ypos[0] + BLOCK_SIZE) || 
					(vga_xpos >= snake_xpos[1]  && vga_xpos <= snake_xpos[1] + BLOCK_SIZE
					&& vga_ypos >= snake_ypos[1] && vga_ypos <= snake_ypos[1] + BLOCK_SIZE) ||
					(vga_xpos >= snake_xpos[2]  && vga_xpos <= snake_xpos[2] + BLOCK_SIZE
					&& vga_ypos >= snake_ypos[2] && vga_ypos <= snake_ypos[2] + BLOCK_SIZE) ||
					(vga_xpos >= snake_xpos[3]  && vga_xpos <= snake_xpos[3] + BLOCK_SIZE
					&& vga_ypos >= snake_ypos[3] && vga_ypos <= snake_ypos[3] + BLOCK_SIZE) ||
					(vga_xpos >= snake_xpos[4]  && vga_xpos <= snake_xpos[4] + BLOCK_SIZE
					&& vga_ypos >= snake_ypos[4] && vga_ypos <= snake_ypos[4] + BLOCK_SIZE)) 
					rgb_data = `WHITE;
				else rgb_data = `BLACK;
			end
		end
	end
	
	vga_controller controller(
		.clk(clk_25M),
		.reset(reset),
		.vga_data(rgb_data),
		.vga_clk(VGA_CLK),
		.vga_hs(hs), 
		.vga_vs(vs),
		.vga_blank(VGA_BLANK), 
		.vga_r(VGA_R), 
		.vga_g(VGA_G), 
		.vga_b(VGA_B), 
		.vga_xpos(vga_xpos), 
		.vga_ypos(vga_ypos)
	);
	
endmodule
