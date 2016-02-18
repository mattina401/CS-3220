module Project2(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
	input  [9:0] SW;
	input  [3:0] KEY;
	input  CLOCK_50;
	output [9:0] LEDR;
	output [7:0] LEDG;
	output [6:0] HEX0,HEX1,HEX2,HEX3;
 
	parameter DBITS         				= 32;
	parameter INST_SIZE      			 	= 32'd4;
	parameter INST_BIT_WIDTH				= 32;
	parameter START_PC       			 	= 32'h40;
	parameter REG_INDEX_BIT_WIDTH 		= 4;
	parameter ADDR_KEY  					 	= 32'hF0000010;
	parameter ADDR_SW   					 	= 32'hF0000014;
	parameter ADDR_HEX  					 	= 32'hF0000000;
	parameter ADDR_LEDR 					 	= 32'hF0000004;
	parameter ADDR_LEDG 					 	= 32'hF0000008;
  
	parameter IMEM_INIT_FILE				= "Test2.mif";
	parameter IMEM_ADDR_BIT_WIDTH 		= 11;
	parameter IMEM_DATA_BIT_WIDTH 		= INST_BIT_WIDTH;
	parameter IMEM_PC_BITS_HI     		= IMEM_ADDR_BIT_WIDTH + 2;
	parameter IMEM_PC_BITS_LO     		= 2;
  
	parameter DMEMADDRBITS 				 	= 13;
	parameter DMEMWORDBITS				 	= 2;
	parameter DMEMWORDS					 	= 2048;
    
	//PLL, clock genration, and reset generation
	wire clk, lock;
  
	//Pll pll(.inclk0(CLOCK_50), .c0(clk), .locked(lock));
	PLL	PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
	wire reset = ~lock;
  
	// Create PC and its logic
	wire pcWrtEn = 1'b1;
	wire[DBITS - 1: 0] pcIn;
	wire[DBITS - 1: 0] pcOut;
  
  wire[DBITS - 1: 0] pc_4Out;
  
  pc_4(pcOut, pc_4Out);
  
  wire[DBITS - 1:0] nextBranch;
	assign nextBranch = pc_4Out + immShift;
	Mux4to1 (Bsel, pc_4Out, nextBranch, Dout, 0, pcIn);
    
	// Control logic
	wire regSel;
	wire REG_EN;
	wire isStore;
	wire[4:0] aluSel,aluS;
	wire[1:0] pcSel, argSel, regWrSel,memOutSel,Bsel;
  
	// This PC instantiation is your starting point
	Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, reset, pcWrtEn, pcIn, pcOut);

	// Create instruction memeory
	wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;
	InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWord);
  
	// Put the code for getting opcode1, rd, rs, rt, imm, etc. here
	wire[REG_INDEX_BIT_WIDTH - 1:0] RS1, RS2;
	Mux2to1 (regFileEn, instWord[31:24], instWord[27:20], {RS1, RS2});
  
  
	// Extend the immediate
	wire[15:0] immSmall;
	wire[DBITS - 1:0] immExt, immShift;
	assign immSmall = instWord[23:8];
	assign immShift = immExt[29:0] << 2;
	SignExtension #(16,32) extender(immSmall, immExt);
  
	// Create the registers
	wire[REG_INDEX_BIT_WIDTH - 1:0] RD;
	wire[DBITS - 1:0] DATA1, DATA2, REG_IN;
	assign RD = instWord[31:28];
	
	RegisterFile (clk, regFileEn, RD, RS1, RS2, REG_IN, DATA1, DATA2);

	// Switch between the immediate and DATA2
	wire[DBITS - 1:0] ARG2,immSel;
	Mux4to1 (immSel, DATA2, immExt, immShift, 0, ARG2);
  
	// Create ALU unit
	wire[DBITS - 1:0] Dout,ALU_OUT;
	
	alu (DATA1, ARG2, Dout,aluS);
	SCPocController (instWord, opcode, rd, rs1, rs2, imm, regFileEn, immSel, memOutSel, Bsel, isLoad, isStore, Dout[0], aluS);
	

	// Initialize the data memory
	wire[DBITS - 1:0] MEM_OUT_TMP;
   DataMemory #(IMEM_INIT_FILE) dmem(clk, isStore, ALU_OUT[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], DATA2, sw, key, ledr, ledg, hex, MEM_OUT_TMP);

	
	wire[15:0] hex;
	SevenSeg hexConv3(hex[15:12], HEX3);
	SevenSeg hexConv2(hex[11:8], HEX2);
	SevenSeg hexConv1(hex[7:4], HEX1);
	SevenSeg hexConv0(hex[3:0], HEX0);

	Mux4to1 (memOutSel, Dout, MEM_OUT_TMP, pc_4Out, 0, REG_IN);

	
endmodule

/*
module Project2(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
  input  [9:0] SW;
  input  [3:0] KEY;
  input  CLOCK_50;
  output [9:0] LEDR;
  output [7:0] LEDG;
  output [6:0] HEX0,HEX1,HEX2,HEX3;
  
  parameter DBITS         				 = 32;
  parameter INST_SIZE      			 = 32'd4;
  parameter INST_BIT_WIDTH				 = 32;
  parameter START_PC       			 = 32'h40;
  parameter REG_INDEX_BIT_WIDTH 		 = 4;
  parameter ADDR_KEY  					 = 32'hF0000010;
  parameter ADDR_SW   					 = 32'hF0000014;
  parameter ADDR_HEX  					 = 32'hF0000000;
  parameter ADDR_LEDR 					 = 32'hF0000004;
  parameter ADDR_LEDG 					 = 32'hF0000008;
  
  parameter IMEM_INIT_FILE				 = "Test2.mif";
  parameter IMEM_ADDR_BIT_WIDTH 		 = 11;
  parameter IMEM_DATA_BIT_WIDTH 		 = INST_BIT_WIDTH;
  parameter IMEM_PC_BITS_HI     		 = IMEM_ADDR_BIT_WIDTH + 2;
  parameter IMEM_PC_BITS_LO     		 = 2;
  
  parameter DMEMADDRBITS 				 = 13;
  parameter DMEMWORDBITS				 = 2;
  parameter DMEMWORDS					 = 2048;
  
  parameter OP1_ALUR 					 = 4'b0000;
  parameter OP1_ALUI 					 = 4'b1000;
  parameter OP1_CMPR 					 = 4'b0010;
  parameter OP1_CMPI 					 = 4'b1010;
  parameter OP1_BCOND					 = 4'b0110;
  parameter OP1_SW   					 = 4'b0101;
  parameter OP1_LW   					 = 4'b1001;
  parameter OP1_JAL  					 = 4'b1011;
  
  // Add parameters for various secondary opcode values
  
  //PLL, clock genration, and reset generation
  wire clk, lock;
  //Pll pll(.inclk0(CLOCK_50), .c0(clk), .locked(lock));
  PLL	PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
  wire reset = ~lock;
  
  // Create PC and its logic
  wire pcWrtEn = 1'b1;
  wire[DBITS - 1: 0] pcIn; // Implement the logic that generates pcIn; you may change pcIn to reg if necessary
  wire[DBITS - 1: 0] pcOut;
  // This PC instantiation is your starting point
  Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, reset, pcWrtEn, pcIn, pcOut);

  wire[DBITS - 1: 0] pc_4Out;
  wire [1:0] Bsel;
  wire[DBITS - 1: 0] branchPc;
  wire[7:0] opcode;
  wire[3:0] rd, rs1, rs2;
  wire[15:0] imm;
  wire FileEn,immSel,isLoad,isStore;
  wire [1:0] memOutSel;
  wire [31: 0] dataIn, dataOut1, dataOut2, Dout,addrMemIn;
  wire pnz;
  
  pc_4(pcOut, pc_4Out);
  
  //if Bsel is 00 -> pc +4, Bsel is 01 is branch, 10 is jal
  Mux4to1 (Bsel, pc_4Out, branchPc, Dout, 32'd0, pcIn);
  
  
  // Creat instruction memeory
  wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;
  InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWord);
  
  // Put the code for getting opcode1, rd, rs, rt, imm, etc. here 
  

  Get get(instWord, opcode, rd, rs1, rs2, imm, regFileEn, immSel, memOutSel, Bsel, isLoad, isStore, pnz);
  
  
  // Create the registers
  
  RegisterFile regFile (clk, regFileEn, rd, rs1, rs2, dataIn, dataOut1, dataOut2);
  
  
  wire [31:0] aluIn2;
  
  // Create ALU unit
  
  //alu (opcode, dataOut1, aluIn2, Dout, pnz);
  
  // imm 익스텐션
  SignExtension (imm, seImm);
  
  // imm 벨류쓰면 익스텐션 한거 들어가고 아니면 그냥 레지
  Mux2to1 (immSel, seImm, dataOut2, aluIn2);
  //alu (opcode, dataOut1, aluIn2, Dout, pnz);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////여기까진 일치
  
  wire dataWrtEn;
  wire [31:0] dataWord,dataMemoryOut;
  wire [1:0] dataMemOutSel;
  wire swEn, ledrEn, ledgEn, keyEn, hexEn;
  wire[DBITS - 1: 0] switchOut;
  wire[DBITS - 1: 0] keyOut;
  wire[DBITS - 1: 0] ledrOut;
  wire[DBITS - 1: 0] ledgOut;
  wire[DBITS - 1: 0] hexOut;

  
  
  wire [15:0] hex;
  // Put the code for data memory and I/O here
  DataMemory #(.MEM_INIT_FILE(IMEM_INIT_FILE)) datamem(clk, isStore, Dout, dataIn, sw, key, ledr, ledg, hex, dOut);
  
  //memOutSel 00 is 나머지, 01 is LW, 10 is jal
  Mux4to1 (memOutSel, Dout, dataIn, pc_4Out, 32'd0, dataIn);
  
  
  
  //Mux4to1 (dataMemOutSel,dataWord,switchOut,keyOut,32'd0,dataMemoryOut);
  
  
  
  assign LEDR = ledr;
  assign LEDG = ledg;
  
  
  SevenSeg (hex[3:0], HEX0);
  SevenSeg (hex[7:4], HEX1);
  SevenSeg (hex[11:8], HEX2);
  SevenSeg (hex[15:12], HEX3);
  
  
endmodule

*/