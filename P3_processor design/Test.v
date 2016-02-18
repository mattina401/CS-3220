module Test(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
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
	
	alu2 (DATA1, ARG2, Dout,aluS);
	Get(instWord, opcode, rd, rs1, rs2, imm, regFileEn, immSel, memOutSel, Bsel, isLoad, isStore, Dout[0], aluS);
	

	// Initialize the data memory
	wire[DBITS - 1:0] MEM_OUT_TMP;
	DataMemory2 #(IMEM_INIT_FILE) dataMem (clk, Dout[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], MEM_OUT_TMP, DATA2, isStore);
   //DataMemory(clk, MEM_EN, ALU_OUT[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], DATA2, sw, key, ledr, ledg, hex, MEM_OUT_TMP);
	// Memory Mapped Inputs
	
	reg [DBITS-1:0] MEM_OUT;
	always @(*) begin
		if (Dout == ADDR_KEY)
			MEM_OUT <= {28'h0, ~KEY};
		else if (Dout == ADDR_SW)
			MEM_OUT <= {22'h0, SW};
		else
			MEM_OUT <= MEM_OUT_TMP;
	end
	
	
	// Memory Mapped Outputs
	MemoryMappedIO #(ADDR_HEX, 16) ioHex(clk, isStore, Dout, DATA2, HEXTMP);
	MemoryMappedIO #(ADDR_LEDR, 10) ioLedR(clk, isStore, Dout, DATA2, LEDR);
	MemoryMappedIO #(ADDR_LEDG, 8) ioLedG(clk, isStore, Dout, DATA2, LEDG);
	
	// Convert the binary to 7-seg
	wire[15:0] HEXTMP;
	SevenSeg hexConv3(HEXTMP[15:12], HEX3);
	SevenSeg hexConv2(HEXTMP[11:8], HEX2);
	SevenSeg hexConv1(HEXTMP[7:4], HEX1);
	SevenSeg hexConv0(HEXTMP[3:0], HEX0);
  
	// Mux to switch register input between the ALU, the PC counter, and the memory
	Mux4to1 (memOutSel, Dout, MEM_OUT, pc_4Out, 0, REG_IN);

	
endmodule

module MemoryMappedIO(clk, writeEn, addr, in, out);
	parameter address;
	parameter signalWidth;
	
	input clk, writeEn;
	input[31:0] in, addr;
	output reg [signalWidth-1:0] out;
	
	always @(posedge clk)
		if (writeEn & (addr == address)) 
			out <= in[signalWidth-1:0];
	
endmodule

module DataMemory2(clk, addr, dataOut, dataIn, writeEn);
	parameter MEM_INIT_FILE;
	parameter ADDR_BIT_WIDTH = 11;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_WORDS = (1 << ADDR_BIT_WIDTH);
	
	input clk, writeEn;
	input[ADDR_BIT_WIDTH - 1: 0] addr;
	input[DATA_BIT_WIDTH - 1: 0] dataIn;
	
	output reg[DATA_BIT_WIDTH - 1: 0] dataOut;

	(* ram_init_file = MEM_INIT_FILE *)
	reg[DATA_BIT_WIDTH - 1: 0] data[0: N_WORDS - 1];
		
	always @(negedge clk) begin
		dataOut <= data[addr];
		if (writeEn)
			data[addr] <= dataIn;
	end
endmodule