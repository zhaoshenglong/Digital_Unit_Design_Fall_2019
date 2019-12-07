// ==============================================================
//
// This stopwatch is just to test the work of LED and KEY on DE1-SOC board.
// The counter is designed by a series mode. / asynchronous mode. 即异步进位
// use "=" to give value to hour_counter_high and so on. 异步操作/阻塞赋值方式
//
// 3 key: key_reset/系统复位, key_start_pause/暂停计时, key_display_stop/暂停显示
//
// ==============================================================
module stopwatch_01(clk,key_reset,key_start_pause,key_display_stop,
	// 时钟输入 + 3 个按键；按键按下为 0 。板上利用施密特触发器做了一定消抖，效果待测试。
	hex0,hex1,hex2,hex3,hex4,hex5,
	// 板上的 6 个 7 段数码管，每个数码管有 7 位控制信号。
	led0,led1,led2,led3 );
	// LED 发光二极管指示灯，用于指示/测试程序按键状态，若需要，可增加。 高电平亮。
	input clk,key_reset,key_start_pause,key_display_stop;
	output [6:0] hex0,hex1,hex2,hex3,hex4,hex5;
	output led0,led1,led2,led3;
	reg led0,led1,led2,led3;
	
	// 显示刷新，即显示寄存器的值 实时 更新为 计数寄存器 的值。
	reg display_stop;
	// 计数（计时）工作 状态，由按键 “计时/暂停” 控制。
	reg counter_stop;
	// 定义一个常量参数。 10000000 ->200ms；
	parameter DELAY_TIME = 10000000;
	// 定义 6 个显示数据（变量）寄存器：
	reg [3:0] minute_display_high;
	reg [3:0] minute_display_low;
	reg [3:0] second_display_high;
	reg [3:0] second_display_low;
	reg [3:0] msecond_display_high;
	reg [3:0] msecond_display_low;
	
	reg [31:0] timer;
	reg [31:0] counter_50M; // 计时用计数器， 每个 50MHz 的 clock 为 20ns。
	// DE1-SOC 板上有 4 个时钟， 都为 50MHz，所以需要 500000 次 20ns 之后，才是 10ms。
	parameter COUNTER_10MS = 500000;
	// 60 minutes * 60 seconds * 100 ms
	parameter MAX_TIMER = 60*60*100 - 1;
	
	reg reset_1_time; // 消抖动用状态寄存器 -- for reset KEY
	reg [31:0] counter_reset; // 按键状态时间计数器
	reg start_1_time; //消抖动用状态寄存器 -- for counter/pause KEY
	reg [31:0] counter_start; //按键状态时间计数器
	reg display_1_time; //消抖动用状态寄存器 -- for KEY_display_refresh/pause
	reg [31:0] counter_display; //按键状态时间计数器
	reg start; // 工作状态寄存器
	reg display; // 工作状态寄存器
	reg debounce_50M; // 消除抖动用的clock，可以直接写在clk中不用此变量
	
	// sevenseg 模块为 4 位的 BCD 码至 7 段 LED 的译码器，
	//下面实例化 6 个 LED 数码管的各自译码器。
	sevenseg LED8_minute_display_high ( minute_display_high, hex5 );
	sevenseg LED8_minute_display_low ( minute_display_low, hex4 );
	sevenseg LED8_second_display_high( second_display_high, hex3 );
	sevenseg LED8_second_display_low ( second_display_low, hex2 );
	sevenseg LED8_msecond_display_high( msecond_display_high, hex1 );
	sevenseg LED8_msecond_display_low ( msecond_display_low, hex0 );

	initial
	begin
			counter_50M <= 0;
			timer <= 0;
			msecond_display_high <= 0;
			msecond_display_low <= 0;
			second_display_high <= 0;
			second_display_low <= 0;
			minute_display_low <= 0;
			minute_display_high <= 0;
			debounce_50M <= 0;
	end
	
	always @ (posedge clk) // 每一个时钟上升沿开始触发下面的逻辑，
	// 进行计时后各部分的刷新工作
	begin
		
		// 10ms passed, increment timer
		if(counter_50M == COUNTER_10MS) 
		begin
			counter_50M <= 0;
			if(~counter_stop)
			begin
				timer <= timer + 1;
			end

			if(~display_stop)
			begin
				msecond_display_low <= timer % 10;
				msecond_display_high <= (timer / 10) % 10;
				second_display_low <= (timer / 100) % 10;
				second_display_high <= (timer / 1000) % 6;
				minute_display_low <= (timer / 6000) % 10;
				minute_display_high <= (timer / 60000) % 6;
			end
		end
		else 
		begin
			counter_50M <= counter_50M + 1;
		end
		
		// debounce clock
		debounce_50M <= ~debounce_50M;
		// 
		if(~key_reset)
		begin
			counter_50M <= 0;
			msecond_display_high <= 0;
			msecond_display_low <= 0;
			second_display_high <= 0;
			second_display_low <= 0;
			minute_display_low <= 0;
			minute_display_high <= 0;
			timer <= 0;
			led1 <= 1;
		end
		else
		begin
			led1 <= 0;
		end
	end
	
	always @ (posedge debounce_50M)
	begin
		if(~key_display_stop)
		begin
			counter_display <= counter_display + 1;
			led0<=1;
			if(counter_display >= COUNTER_10MS)
			begin
				display_1_time = 1;
			end
		end
		else
		begin
			counter_display <= 0;
			display_1_time = 0;
			led0<=0;
		end
		if(~key_start_pause)
		begin			
			led2<=1;
			counter_start <= counter_start + 1;
			if(counter_start >= COUNTER_10MS)
			begin
				start_1_time = 1;
			end
		end
		else	
		begin
			led2<=0;
			counter_start <= 0;
			start_1_time = 0;
		end
	end
	
	always @ (posedge start_1_time)
	begin
		counter_stop <= ~counter_stop;
	end
	
	always @ (posedge display_1_time)
	begin
		display_stop <= ~display_stop;
	end
endmodule
