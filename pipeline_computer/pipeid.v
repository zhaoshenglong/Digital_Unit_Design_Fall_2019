module pipeid( mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,
	wrn,wdi,ealu,malu,mmo,wwreg,clock,resetn,
	bpc,jpc,pcsource,wpcir,dwreg,dm2reg,dwmem,daluc,
	daluimm,da,db,dimm,drn,dshift,djal );
	
	input 			mwreg, ewreg, em2reg, mm2reg, wwreg, clock, resetn;
	input  [4:0]	mrn, ern, wrn;
	input  [31:0]	dpc4, inst, wdi, ealu, malu, mmo;
	
	output [31:0]	bpc, jpc, da, db, dimm;
	reg 	 [31:0]  da, db;
	output [4:0]	drn;
	output [3:0]	daluc;
	output [1:0]	pcsource;
	output			wpcir, dwreg, dm2reg, dwmem, daluimm, dshift, djal;
	
	wire	 [5:0]	dop, dfunc;
	wire 	 [4:0]	drs = {inst[25:21]};
	wire   [4:0]   drt = {inst[20:16]};
	wire 				drsrtequ, dregrt, dsext, de;
	reg	 [1:0]	dfwda;										// forwarding
	reg	 [1:0]	dfwdb;										// default 0
	wire	 [31:0]	dq1, dq2, bpc_off;
	wire   [15:0]	imm_ext;
	
	assign wpcir = em2reg & (ern == drs | ern == drt);			// 处理wpcir, 即是否stall
	assign dop 	= {inst[31:26]};										// op code
	assign dfunc = {inst[5:0]};   									// func code
	
	wire r_type = ~|dop;
   wire i_add = r_type & dfunc[5] & ~dfunc[4] & ~dfunc[3] &
                ~dfunc[2] & ~dfunc[1] & ~dfunc[0];          //100000
   wire i_sub = r_type & dfunc[5] & ~dfunc[4] & ~dfunc[3] &
                ~dfunc[2] &  dfunc[1] & ~dfunc[0];          //100010
      
   
   wire i_and = r_type & dfunc[5] & ~dfunc[4] & ~dfunc[3] &
					 dfunc[2] & ~dfunc[1] & ~dfunc[0];				//100100
   wire i_or  = r_type & dfunc[5] & ~dfunc[4] & ~dfunc[3] &
					 dfunc[2] & ~dfunc[1] & dfunc[0];				//100101
   wire i_xor = r_type & dfunc[5] & ~dfunc[4] & ~dfunc[3] &
					 dfunc[2] & dfunc[1] & ~dfunc[0];				//100110
   wire i_sll = r_type & ~dfunc[5] & ~dfunc[4] & ~dfunc[3] &
					 ~dfunc[2] & ~dfunc[1] & ~dfunc[0];				//000000
   wire i_srl = r_type & ~dfunc[5] & ~dfunc[4] & ~dfunc[3] &
					 ~dfunc[2] & dfunc[1] & ~dfunc[0];				//000010
   wire i_sra = r_type & ~dfunc[5] & ~dfunc[4] & ~dfunc[3] &
					 ~dfunc[2] & dfunc[1] & dfunc[0];				//000011
   wire i_jr  = r_type & ~dfunc[5] & ~dfunc[4] & dfunc[3] &
					 ~dfunc[2] & ~dfunc[1] & ~dfunc[0];				//001000
                
   wire i_addi = ~dop[5] & ~dop[4] &  dop[3] & ~dop[2] & ~dop[1] & ~dop[0]; //001000
   wire i_andi = ~dop[5] & ~dop[4] &  dop[3] &  dop[2] & ~dop[1] & ~dop[0]; //001100
   
   wire i_ori  = ~dop[5] & ~dop[4] &  dop[3] &  dop[2] & ~dop[1] &  dop[0]; //001101
   wire i_xori = ~dop[5] & ~dop[4] &  dop[3] &  dop[2] &  dop[1] & ~dop[0]; //001110
   wire i_lw   =  dop[5] & ~dop[4] & ~dop[3] & ~dop[2] &  dop[1] &  dop[0]; //100011
   wire i_sw   =  dop[5] & ~dop[4] &  dop[3] & ~dop[2] &  dop[1] &  dop[0]; //101011
   wire i_beq  = ~dop[5] & ~dop[4] & ~dop[3] &  dop[2] & ~dop[1] & ~dop[0]; //000100
   wire i_bne  = ~dop[5] & ~dop[4] & ~dop[3] &  dop[2] & ~dop[1] &  dop[0]; //000101
   wire i_lui  = ~dop[5] & ~dop[4] &  dop[3] &  dop[2] &  dop[1] &  dop[0]; //001111
   wire i_j    = ~dop[5] & ~dop[4] & ~dop[3] & ~dop[2] &  dop[1] & ~dop[0]; //000010
   wire i_jal  = ~dop[5] & ~dop[4] & ~dop[3] & ~dop[2] &  dop[1] &  dop[0]; //000011
	
	// 读取/写寄存器，使用和pipeline同一个clock
	regfile reg_read_write (drs, drt, wdi, wrn, wwreg, clock, resetn, dq1, dq2);
	
	// choose forwarding signal
	always @ * begin
		dfwda <= 2'b00;
		dfwdb <= 2'b00;
		if (ewreg & (ern != 0) & (ern == drs) & ~em2reg) begin
			dfwda <= 2'b01;
		end else begin
			if (mwreg & (mrn != 0) & (mrn == drs) & ~mm2reg) begin
				dfwda <= 2'b10;
			end else begin
				if (mwreg & (mrn != 0) & (mrn == drs) & mm2reg) begin
					dfwda <= 2'b11;
				end
			end
		end
		if (ewreg & (ern != 0) & (ern == drt) & ~em2reg) begin
			dfwdb <= 2'b01;
		end else begin
			if (mwreg & (mrn != 0) & (mrn == drt) & ~mm2reg) begin
				dfwdb <= 2'b10;
			end else begin
				if (mwreg & (mrn != 0) & (mrn == drt) & mm2reg) begin
					dfwdb <= 2'b11;
				end
			end
		end
		case (dfwda)
			2'b00: da = dq1;
			2'b01: da = ealu;
			2'b10: da = malu;
			2'b11: da = mmo;
		endcase
		case (dfwdb)
			2'b00: db = dq2;
			2'b01: db = ealu;
			2'b10: db = malu;
			2'b11: db = mmo;
		endcase
	end
	
	assign  drsrtequ = da == db;
	assign  pcsource[1] = i_jr | i_j | i_jal;
   assign  pcsource[0] = ( i_beq & drsrtequ ) | (i_bne & ~drsrtequ) | i_j | i_jal ;
   
   assign  dwreg = wpcir ? {1'b0} : i_add | i_sub | i_and | i_or   | i_xor  |
                 i_sll | i_srl | i_sra | i_addi | i_andi |
                 i_ori | i_xori | i_lw | i_lui  | i_jal;
   
   assign  daluc[3] = wpcir ? {1'b0} : i_sra;
   assign  daluc[2] = wpcir ? {1'b0} : i_sub | i_or | i_srl | i_sra | i_ori | i_lui | i_beq | i_bne;
   assign  daluc[1] = wpcir ? {1'b0} : i_xor | i_sll | i_srl | i_sra | i_lui | i_xori;
   assign  daluc[0] = wpcir ? {1'b0} : i_and | i_or | i_sll | i_srl | i_sra | i_andi | i_ori;
   assign  dshift   = wpcir ? {1'b0} : i_sll | i_srl | i_sra ;
   assign  daluimm  = wpcir ? {1'b0} : i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_lui;
   assign  dsext    = wpcir ? {1'b0} : i_addi | i_lw | i_sw | i_beq | i_bne;
   assign  dwmem    = wpcir ? {1'b0} : i_sw;
   assign  dm2reg   = wpcir ? {1'b0} : i_lw;
   assign  dregrt   = wpcir ? {1'b0} : i_addi| i_andi | i_ori | i_xori | i_lw | i_sw | i_lui;
   assign  djal     = wpcir ? {1'b0} : i_jal;
	
	assign  de 		  = dsext & inst[15];
	assign  imm_ext  = {16{de}};
	assign  bpc_off  = {imm_ext[13:0], inst[15:0], 1'b0, 1'b0};
	assign  dimm     = {imm_ext, inst[15:0]};
	assign  jpc 	  = {dpc4[31:28],inst[25:0],1'b0,1'b0};
	assign  bpc		  = dpc4 + bpc_off;
	mux2x5  drn_mux(inst[15:11], inst[20:16], dregrt, drn);
	
endmodule
