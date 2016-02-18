module RegisterFile (clk, writerg, rd, rs1, rs2, dataIn, dataOut1, dataOut2);

	input clk;
	input writerg;
	input [3: 0] rd, rs1, rs2;
	input [31: 0] dataIn;
	output [31: 0] dataOut1, dataOut2;
	
	reg[31: 0] data [0: (1 << 4)];
	
	always @(posedge clk)
		
		//write
		if (writerg == 1'b1)
			data[rd] <= dataIn;
	
	//read
	assign dataOut1 = data[rs1];
	assign dataOut2 = data[rs2];
	
endmodule