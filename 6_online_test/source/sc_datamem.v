module sc_datamem (addr,datain,dataout,we,clock,mem_clk,dmem_clk, resetn, mem_dataout, io_read_data, sw, hex0, hex1, hex2, hex3, hex4, hex5);
 
   input  [31:0]  addr;
   input  [31:0]  datain;
   input  [9:0]	sw;
   input          we, clock,mem_clk;
	input 			resetn;
   output [31:0]  dataout;
   output         dmem_clk;
	output [6:0]	hex0,hex1,hex2,hex3,hex4,hex5;
   
	output [31:0] 	mem_dataout;
	output [31:0] 	io_read_data;
   wire           dmem_clk;    
   wire           write_enable;
	wire 				write_datamem_enable, write_io_output_reg_enable;
   
	assign         write_enable = we & ~clock;
	assign 			write_datamem_enable = write_enable & (~addr[7]);
   assign 			write_io_output_reg_enable = write_enable & ( addr[7]);
	assign         dmem_clk = mem_clk & ( ~ clock);
	
	
	// 读取数据时，如果是外设的地址，dataout 设置为 外设读取的数据，否则设置为正常 datamem 的数据
   mux2x32 mem_io_dataout_mux(mem_dataout,io_read_data,addr[7],dataout);
	
	
	lpm_ram_dq_dram dram(addr[6:2],dmem_clk,datain,write_datamem_enable, mem_dataout);
	
	// 写入外部设备
	io_output_reg io_output_regx2 (addr,datain,write_io_output_reg_enable,
		dmem_clk, hex0, hex1, hex2, hex3, hex4, hex5);
	
	// 从外部设备读取
	io_input_reg io_input_regx2(addr,dmem_clk,io_read_data,sw);
	
endmodule

module io_output_reg (addr,datain,write_io_enable,io_clk, hex0,hex1, hex2,hex3,hex4,hex5 );
	input [31:0] addr,datain;
	input write_io_enable,io_clk;
	
	output [6:0] hex0,hex1,hex2,hex3,hex4,hex5;
	reg[3:0] operand_left_high, operand_left_low, operand_right_high, operand_right_low, result_high, result_low;
	sevenseg LED8_operand_left_low ( operand_left_low, hex5 );

	always @(posedge io_clk)
		begin
		if (write_io_enable == 1)
			case (addr[7:2])
				6'b100000:
				begin
					result_high <= datain / 10;
					result_low <= datain % 10;
				end
				6'b100001:
				begin
					operand_right_high <= datain / 10;
					operand_right_low <= datain % 10;
				end
				6'b100010:
				begin
					operand_left_high <= datain / 10;
					operand_left_low <= datain % 10;
				end
			endcase
		end
endmodule

module io_input_reg (addr,io_clk,io_read_data,sw);
	input [31:0] addr;
	input io_clk;
	input [9:0] sw;
	output [31:0] io_read_data;
	
	reg [31:0] in_reg0; // input port0
	reg [31:0] in_reg1; // input port1

	io_input_mux io_imput_mux2x32(in_reg0,in_reg1,addr[7:2],io_read_data);
	always @(posedge io_clk) 
	begin
	 in_reg0 <= {24'b0, sw[9:2]};// 输入端口在 io_clk 上升沿时进行数据锁存
	 in_reg1 <= 32'h000000a0;// 输入端口在 io_clk 上升沿时进行数据锁存
	 end
endmodule 

module io_input_mux(a0,a1,sel_addr,y);
	input [31:0] a0,a1;
	input [ 5:0] sel_addr;
	output [31:0] y;
	reg [31:0] y;

	always @ *
		case (sel_addr)
			6'b110000: y = a0;
			6'b110001: y = a1;
			default: y = a0;
		endcase
endmodule

module sevenseg ( data, ledsegments);
input [3:0] data;
output[6:0] ledsegments;
reg [6:0] ledsegments;
always @ (*)
 case(data)
 // gfe_dcba // 7 段 LED 数码管的位段编号
 // 654_3210 // DE1-SOC 板上的信号位编号
 0: ledsegments = 7'b100_0000; // DE1-SOC 板上的数码管为共阳极接法。
 1: ledsegments = 7'b111_1001;
 2: ledsegments = 7'b010_0100;
 3: ledsegments = 7'b011_0000;
 4: ledsegments = 7'b001_1001;
 5: ledsegments = 7'b001_0010;
 6: ledsegments = 7'b000_0010;
 7: ledsegments = 7'b111_1000;
 8: ledsegments = 7'b000_0000;
 9: ledsegments = 7'b001_0000;
 default: ledsegments = 7'b111_1111; // 其它值时全灭。
endcase
endmodule