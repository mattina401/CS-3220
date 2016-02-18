module buffer( dr, clk, reset, incrementedPC, aluOut, sr2Out, memWrite, regWrite, jal, memtoReg, dr_B, incrementedPC_B,aluOut_B, sr2Out_B, memWrite_B, regWrite_B, jal_B, memtoReg_B);
	
	parameter RESET_VALUE = 0;
	input [3:0] dr;
	input clk, reset;
	input [31 : 0] incrementedPC, aluOut, sr2Out;
	input memWrite, regWrite, jal, memtoReg;
	output [3:0] dr_B;
	output [31 : 0] incrementedPC_B, aluOut_B, sr2Out_B;
	output memWrite_B, regWrite_B, jal_B, memtoReg_B;
	reg [31 : 0] incrementedPC_P, aluOut_P, sr2Out_P;
	reg memWrite_P, regWrite_P, jal_P, memtoReg_P;
	reg [3:0] dr_P;

always @(posedge clk) begin
			incrementedPC_P <= incrementedPC;
			aluOut_P <= aluOut;
			sr2Out_P <= sr2Out;
			memWrite_P <= memWrite;
			regWrite_P <=  regWrite;
			memtoReg_P <=  memtoReg;
			jal_P <= jal;
			dr_P <= dr;
	end
	
			assign incrementedPC_B = incrementedPC_P;
			assign aluOut_B = aluOut_P;
			assign sr2Out_B = sr2Out_P;
			assign memWrite_B = memWrite_P;
			assign regWrite_B = regWrite_P;
			assign memtoReg_B = memtoReg_P;
			assign dr_B = dr_P;
			assign jal_B = jal_P;
	
endmodule