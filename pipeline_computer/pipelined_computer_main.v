module pipelined_computer_main (resetn,clock,mem_clock, sw, hex0, hex1, hex2, hex3, hex4, hex5, pc,inst,ealu,malu,walu, wpcir_out, mmo_out, npc_out);
	//瀹氫箟椤跺眰妯″潡 pipelined_computer锛屼綔涓哄伐绋嬫枃浠剁殑椤跺眰鍏ュ彛锛屽鍥1-1 寤虹珛宸ョ▼鏃舵寚瀹氥€
	input resetn, clock, mem_clock;
	//瀹氫箟鏁翠釜璁＄畻鏈module 鍜屽鐣屼氦浜掔殑杈撳叆淇″彿锛屽寘鎷浣嶄俊鍙resetn銆佹椂閽熶俊鍙clock銆
	//浠ュ強涓€涓拰 clock 鍚岄鐜囦絾鍙嶇浉鐨mem_clock 淇″彿銆俶em_clock 鐢ㄤ簬鎸囦护鍚屾 ROM 鍜
	//鏁版嵁鍚屾 RAM 浣跨敤锛屽叾娉㈠舰闇€瑕佹湁鍒簬瀹為獙涓€銆
	//杩欎簺淇″彿鍙互鐢ㄤ綔浠跨湡楠岃瘉鏃剁殑杈撳嚭瑙傚療淇″彿銆
	input  [9:0]  sw;
	output [6:0]  hex0, hex1, hex2, hex3, hex4, hex5;
	output [31:0] pc,inst,ealu,malu,walu;
	output 			wpcir_out;
	output [31:0] 	mmo_out;
	output	 [31:0]	npc_out;
	
	//妯″潡鐢ㄤ簬浠跨湡杈撳嚭鐨勮瀵熶俊鍙枫€傜己鐪佷负 wire 鍨嬨€
	wire [31:0] bpc,jpc,npc,pc4,ins, inst;
	//妯″潡闂翠簰鑱斾紶閫掓暟鎹垨鎺у埗淇℃伅鐨勪俊鍙风嚎,鍧囦负 32 浣嶅淇″彿銆侷F 鍙栨寚浠ら樁娈点€
	wire [31:0] dpc4,da,db,dimm;	
	//妯″潡闂翠簰鑱斾紶閫掓暟鎹垨鎺у埗淇℃伅鐨勪俊鍙风嚎,鍧囦负 32 浣嶅淇″彿銆侷D 鎸囦护璇戠爜闃舵銆
	wire [31:0] epc4,ea,eb,eimm; 
	//妯″潡闂翠簰鑱斾紶閫掓暟鎹垨鎺у埗淇℃伅鐨勪俊鍙风嚎,鍧囦负 32 浣嶅淇″彿銆侲XE 鎸囦护杩愮畻闃舵銆
	wire [31:0] mb,mmo;
	//妯″潡闂翠簰鑱斾紶閫掓暟鎹垨鎺у埗淇℃伅鐨勪俊鍙风嚎,鍧囦负 32 浣嶅淇″彿銆侻EM 璁块棶鏁版嵁闃舵銆
	wire [31:0] wmo,wdi;
	//妯″潡闂翠簰鑱斾紶閫掓暟鎹垨鎺у埗淇℃伅鐨勪俊鍙风嚎,鍧囦负 32 浣嶅淇″彿銆俉B 鍥炲啓瀵勫瓨鍣ㄩ樁娈点€
	wire [4:0] drn,ern0,ern,mrn,wrn;
	//妯″潡闂翠簰鑱旓紝閫氳繃娴佹按绾垮瘎瀛樺櫒浼犻€掔粨鏋滃瘎瀛樺櫒鍙风殑淇鍙风嚎锛屽瘎瀛樺櫒鍙凤紙32 涓級涓5bit銆
	wire [3:0] daluc,ealuc;
	//ID 闃舵鍚EXE 闃舵閫氳繃娴佹按绾垮瘎瀛樺櫒浼犻€掔殑 aluc 鎺у埗淇″彿锛bit銆
	wire [1:0] pcsource;
	//CU 妯″潡鍚IF 闃舵妯″潡浼犻€掔殑 PC 閫夋嫨淇″彿锛bit銆
	wire wpcir;
	// CU 妯″潡鍙戝嚭鐨勬帶鍒舵祦姘寸嚎鍋滈】鐨勬帶鍒朵俊鍙凤紝浣PC 鍜IF/ID 娴佹按绾垮瘎瀛樺櫒淇濇寔涓嶅彉銆
	wire dwreg,dm2reg,dwmem,daluimm,dshift,djal; // id stage

	assign wpcir_out = wpcir;
	assign mmo_out = mmo;
	assign npc_out = npc;
	
	// ID 闃舵浜х敓锛岄渶寰€鍚庣画娴佹按绾т紶鎾殑淇″彿銆
	wire ewreg,em2reg,ewmem,ealuimm,eshift,ejal; // exe stage
	//鏉ヨ嚜浜ID/EXE 娴佹按绾垮瘎瀛樺櫒锛孍XE 闃舵浣跨敤锛屾垨闇€瑕佸線鍚庣画娴佹按绾т紶鎾殑淇″彿銆
	wire mwreg,mm2reg,mwmem; // mem stage
	//鏉ヨ嚜浜EXE/MEM 娴佹按绾垮瘎瀛樺櫒锛孧EM 闃舵浣跨敤锛屾垨闇€瑕佸線鍚庣画娴佹按绾т紶鎾殑淇″彿銆
	wire wwreg,wm2reg; // wb stage
	//鏉ヨ嚜浜MEM/WB 娴佹按绾垮瘎瀛樺櫒锛學B 闃舵浣跨敤鐨勪俊鍙枫€
	pipepc prog_cnt ( npc,wpcir,clock,resetn,pc );
	//绋嬪簭璁℃暟鍣ㄦā鍧楋紝鏄渶鍓嶉潰涓€绾IF 娴佹按娈电殑杈撳叆銆
	pipeif if_stage ( pcsource,pc,bpc,da,jpc,npc,pc4,ins,mem_clock ); // IF stage
	//IF 鍙栨寚浠ゆā鍧楋紝娉ㄦ剰鍏朵腑鍖呭惈鐨勬寚浠ゅ悓姝ROM 瀛樺偍鍣ㄧ殑鍚屾淇″彿锛
	//鍗宠緭鍏ョ粰璇ユā鍧楃殑 mem_clock 淇″彿锛屾ā鍧楀唴瀹氫箟涓rom_clk銆/ 娉ㄦ剰 mem_clock銆
	//瀹為獙涓彲閲囩敤绯荤粺 clock 鐨勫弽鐩镐俊鍙蜂綔涓mem_clock锛堜害鍗rom_clock锛
	//鍗崇暀缁欎俊鍙峰崐涓妭鎷嶇殑浼犺緭鏃堕棿銆
	pipeir inst_reg ( pc4,ins,wpcir,clock,resetn,dpc4,inst ); // IF/ID 娴佹按绾垮瘎瀛樺櫒
	//IF/ID 娴佹按绾垮瘎瀛樺櫒妯″潡锛岃捣鎵挎帴 IF 闃舵鍜ID 闃舵鐨勬祦姘翠换鍔°€
	//鍦clock 涓婂崌娌挎椂锛屽皢 IF 闃舵闇€浼犻€掔粰 ID 闃舵鐨勪俊鎭紝閿佸瓨鍦IF/ID 娴佹按绾垮瘎瀛樺櫒
	//涓紝骞跺憟鐜板湪 ID 闃舵銆
	pipeid id_stage ( mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
	wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
	bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
	daluimm,da,db,dimm,drn,dshift,djal ); // ID stage
	//ID 鎸囦护璇戠爜妯″潡銆傛敞鎰忓叾涓寘鍚帶鍒跺櫒 CU銆佸瘎瀛樺櫒鍫嗐€佸強澶氫釜澶氳矾鍣ㄧ瓑銆
	//鍏朵腑鐨勫瘎瀛樺櫒鍫嗭紝浼氬湪绯荤粺 clock 鐨勪笅娌胯繘琛屽瘎瀛樺櫒鍐欏叆锛屼篃灏辨槸缁欎俊鍙蜂粠 WB 闃舵
	//浼犺緭杩囨潵鐣欐湁鍗婁釜 clock 鐨勫欢杩熸椂闂达紝浜﹀嵆纭繚淇″彿绋冲畾銆
	//璇ラ樁娈CU 浜х敓鐨勩€佽浼犳挱鍒版祦姘寸嚎鍚庣骇鐨勪俊鍙疯緝澶氥€
	pipedereg de_reg ( dwreg,dm2reg,dwmem,daluc,daluimm,da,db,dimm,drn,dshift,
	djal,dpc4,clock,resetn,ewreg,em2reg,ewmem,ealuc,ealuimm,
	ea,eb,eimm,ern0,eshift,ejal,epc4 ); // ID/EXE 娴佹按绾垮瘎瀛樺櫒
	//ID/EXE 娴佹按绾垮瘎瀛樺櫒妯″潡锛岃捣鎵挎帴 ID 闃舵鍜EXE 闃舵鐨勬祦姘翠换鍔°€
	//鍦clock 涓婂崌娌挎椂锛屽皢 ID 闃舵闇€浼犻€掔粰 EXE 闃舵鐨勪俊鎭紝閿佸瓨鍦ID/EXE 娴佹按绾
	//瀵勫瓨鍣ㄤ腑锛屽苟鍛堢幇鍦EXE 闃舵銆

	pipeexe exe_stage ( ealuc,ealuimm,ea,eb,eimm,eshift,ern0,epc4,ejal,ern,ealu ); // EXE stage
	//EXE 杩愮畻妯″潡銆傚叾涓寘鍚ALU 鍙婂涓璺櫒绛夈€
	pipeemreg em_reg ( ewreg,em2reg,ewmem,ealu,eb,ern,clock,resetn,
	mwreg,mm2reg,mwmem,malu,mb,mrn); // EXE/MEM 娴佹按绾垮瘎瀛樺櫒
	//EXE/MEM 娴佹按绾垮瘎瀛樺櫒妯″潡锛岃捣鎵挎帴 EXE 闃舵鍜MEM 闃舵鐨勬祦姘翠换鍔°€
	//鍦clock 涓婂崌娌挎椂锛屽皢 EXE 闃舵闇€浼犻€掔粰 MEM 闃舵鐨勪俊鎭紝閿佸瓨鍦EXE/MEM
	//娴佹按绾垮瘎瀛樺櫒涓紝骞跺憟鐜板湪 MEM 闃舵銆
	pipemem mem_stage ( mwmem,malu,mb,clock,mem_clock,mmo,sw, hex0, hex1, hex2, hex3, hex4, hex5 ); // MEM stage
	//MEM 鏁版嵁瀛樺彇妯″潡銆傚叾涓寘鍚鏁版嵁鍚屾 RAM 鐨勮鍐欒闂€/ 娉ㄦ剰 mem_clock銆
	//杈撳叆缁欒鍚屾 RAM 鐨mem_clock 淇″彿锛屾ā鍧楀唴瀹氫箟涓ram_clk銆
	//瀹為獙涓彲閲囩敤绯荤粺 clock 鐨勫弽鐩镐俊鍙蜂綔涓mem_clock 淇″彿锛堜害鍗ram_clk锛
	//鍗崇暀缁欎俊鍙峰崐涓妭鎷嶇殑浼犺緭鏃堕棿锛岀劧鍚庡湪 mem_clock 涓婃部鏃讹紝璇昏緭鍑恒€佹垨鍐欒緭鍏ャ€

	pipemwreg mw_reg ( mwreg,mm2reg,mmo,malu,mrn,clock,resetn,
	wwreg,wm2reg,wmo,walu,wrn); // MEM/WB 娴佹按绾垮瘎瀛樺櫒
	//MEM/WB 娴佹按绾垮瘎瀛樺櫒妯″潡锛岃捣鎵挎帴 MEM 闃舵鍜WB 闃舵鐨勬祦姘翠换鍔°€
	//鍦clock 涓婂崌娌挎椂锛屽皢 MEM 闃舵闇€浼犻€掔粰 WB 闃舵鐨勪俊鎭紝閿佸瓨鍦MEM/WB
	//娴佹按绾垮瘎瀛樺櫒涓紝骞跺憟鐜板湪 WB 闃舵銆
	mux2x32 wb_stage ( walu,wmo,wm2reg,wdi ); // WB stage
	//WB 鍐欏洖闃舵妯″潡銆備簨瀹炰笂锛屼粠璁捐鍘熺悊鍥句笂鍙互鐪嬪嚭锛岃闃舵鐨勯€昏緫鍔熻兘閮ㄤ欢鍙
	//鍖呭惈涓€涓璺櫒锛屾墍浠ュ彲浠ヤ粎鐢ㄤ竴涓璺櫒鐨勫疄渚嬪嵆鍙疄鐜拌閮ㄥ垎銆
	//褰撶劧锛屽鏋滀笓闂ㄥ啓涓€涓畬鏁寸殑妯″潡涔熸槸寰堝ソ鐨勩€
endmodule
