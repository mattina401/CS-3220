module SCPocController(instWord, opcode, rd, rs1, rs2, imm, regFileEn, immSel, memOutSel, Bsel, isLoad, isStore,pnz,aluS);

	input [31:0] instWord;
	input pnz;
	output reg [7:0] opcode;
	output reg [3:0] rd, rs1, rs2;
	output reg [15:0] imm;
	output reg regFileEn,isLoad,isStore;
	output reg [1:0] Bsel,memOutSel,immSel;
	output reg[4:0] aluS;
	
	always @(instWord) begin
		
		
		//ALU_R
		if (instWord[3:0] == 4'b0000) begin
			opcode <= instWord[7:0];
			rd <= instWord[31:28];
			rs1 <= instWord[27:24];
			rs2 <= instWord[23:20];
			//imm <= instWord[19:8];
			Bsel <= 2'b00;
			regFileEn <= 1'b1;
			immSel <= 2'b00;
			memOutSel <= 2'b00;
			isLoad <= 1'b0;
			isStore <= 1'b0;
			aluS	<= {1'b0, instWord[7:4]};
		end
		//ALU_I
		if (instWord[3:0] == 4'b1000) begin
				//MVHI
				if (instWord[7:4] == 4'b1011) begin
					opcode <= instWord[7:0];
					rd <= instWord[31:28];
					//rs1 <= instWord[27:24];
					rs2 <= instWord[23:8];
					//imm <= instWord[23:8];
					Bsel <= 2'b00;
					regFileEn <= 1'b1;
					immSel <= 2'b01;
					memOutSel <= 2'b00;
					isLoad <= 1'b0;
					isStore <= 1'b0;
					aluS	<= {1'b0, instWord[7:4]};
				end
				else begin
					opcode <= instWord[7:0];
					rd <= instWord[31:28];
					rs1 <= instWord[27:24];
					//rs2 <= instWord[23:20];
					imm <= instWord[23:8];
					Bsel <= 2'b00;
					regFileEn <= 1'b1;
					immSel <= 2'b01;
					memOutSel <= 2'b00;
					isLoad <= 1'b0;
					isStore <= 1'b0;
					aluS	<= {1'b0, instWord[7:4]};
				end			
		end
		//LW
		if (instWord[3:0] == 4'b1001) begin
			opcode <= instWord[7:0];
			rd <= instWord[31:28];
			rs1 <= instWord[27:24];
			//rs2 <= instWord[23:20];
			imm <= instWord[23:8];
			Bsel <= 2'b00;
			regFileEn <= 1'b1;
			immSel <= 2'b01;
			memOutSel <= 2'b01;
			isLoad <= 1'b1;
			isStore <= 1'b0;
			aluS	<= 5'b0;
		end
		//SW
		if (instWord[3:0] == 4'b0101) begin
			opcode <= instWord[7:0];
			//rd <= instWord[31:28];
			rs1 <= instWord[31:28];
			rs2 <= instWord[27:24];
			imm <= instWord[23:8];
			Bsel <= 2'b00;
			regFileEn <= 1'b0;
			immSel <= 2'b01;
			memOutSel <= 2'b00;
			isLoad <= 1'b0;
			isStore <= 1'b1;
			aluS	<= 5'b0;
		end
		//CMP_R
		if (instWord[3:0] == 4'b0010) begin
			opcode <= instWord[7:0];
			rd <= instWord[31:28];
			rs1 <= instWord[27:24];
			rs2 <= instWord[23:20];
			//imm <= instWord[19:8];
			Bsel <= 2'b00;
			regFileEn <= 1'b1;
			immSel <= 2'b00;
			memOutSel <= 2'b00;
			isLoad <= 1'b0;
			isStore <= 1'b0;
			aluS	<= {1'b1, instWord[7:4]};
		end
		//CMP_I
		if (instWord[3:0] == 4'b1010) begin
			opcode <= instWord[7:0];
			rd <= instWord[31:28];
			rs1 <= instWord[27:24];
			//rs2 <= instWord[23:20];
			imm <= instWord[23:8];
			Bsel <= 2'b00;
			regFileEn <= 1'b1;
			immSel <= 2'b01;
			memOutSel <= 2'b00;
			isLoad <= 1'b0;
			isStore <= 1'b0;
			aluS	<= {1'b1, instWord[7:4]};
		end
		//BRANCH
		if (instWord[3:0] == 4'b0110) begin
			if(!pnz) begin
				Bsel <= 2'b00;
			end
			else begin
				Bsel <= 2'b01;
			end
			
			if(instWord[27:24] == 4'b0000) begin
				opcode <= instWord[7:0];
				//rd <= instWord[31:28];
				rs1 <= instWord[31:28];
				//rs2 <= instWord[23:20];
				imm <= instWord[23:8];
				//Bsel <= 2'b00;
				regFileEn <= 1'b0;
				immSel <= 2'b00;
				memOutSel <= 2'b00;
				isLoad <= 1'b0;
				isStore <= 1'b0;
				aluS	<= {1'b1, instWord[7:4]};
			end
			else begin
				opcode <= instWord[7:0];
				//rd <= instWord[31:28];
				rs1 <= instWord[31:28];
				rs2 <= instWord[27:24];
				imm <= instWord[23:8];
				//Bsel <= 2'b01;
				regFileEn <= 1'b0;
				immSel <= 2'b00;
				memOutSel <= 2'b00;
				isLoad <= 1'b0;
				isStore <= 1'b0;
				aluS	<= {1'b1, instWord[7:4]};
			end
		end
		//JAL
		if (instWord[3:0] == 4'b1011) begin
			opcode <= instWord[7:0];
			rd <= instWord[31:28];
			rs1 <= instWord[27:24];
			//rs2 <= instWord[23:20];
			imm <= instWord[23:8];
			Bsel <= 2'b10;
			regFileEn <= 1'b1;
			immSel <= 2'b10;
			memOutSel <= 2'b10;
			isLoad <= 1'b0;
			isStore <= 1'b0;
			aluS	<= 5'b0;
		end
	end

endmodule
