//4bit 的 BCD 码至 7 段 LED 数码管译码器模块
//可供实例化共 6 个显示译码模块
module sevenseg ( data, ledsegments);
	input [3:0] data;
	output ledsegments;
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