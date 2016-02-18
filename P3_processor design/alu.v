module alu (Din1, Din2, Dout,aluS);
	input [31:0] Din1, Din2;
	input [4:0] aluS;
	output reg [31:0] Dout;
	
	wire signed [31:0] D1, D2;
	assign D1 = Din1;
	assign D2 = Din2;
	
	always@(*) begin
	
		Dout <= 0;
		
		case(aluS)
			5'b00000: Dout <= D1 + D2;
			5'b00001: Dout <= D1 - D2;
			5'b00100: Dout <= D1 & D2;
			5'b00101: Dout <= D1 | D2;
			5'b00110: Dout <= D1 ^ D2;
			5'b01011: Dout <= (D2 << 16);	
			5'b01101: Dout <= ~(D1 ^ D2);
			5'b01100: Dout <= ~(D1 & D2);
			5'b01101: Dout <= ~(D1 | D2);
			
			5'b10000: Dout <= 32'h00000000;
			5'b10001: Dout <= (D1 == D2);
			5'b10010: Dout <= (D1 < D2);
			5'b10011: Dout <= (D1 <= D2);
			5'b11000: Dout <= 32'h00000001;
			5'b11001: Dout <= (D1 != D2);
			5'b11010: Dout <= (D1 >= D2);
			5'b11011: Dout <= (D1 > D2);
			
			5'b10101: Dout <= (D1 == 0);
			5'b10110: Dout <= (D1 < 0);
			5'b10111: Dout <= (D1 <= 0);
			5'b11101: Dout <= (D1 != 0);
		endcase
	
	end
endmodule



/*
module alu (opcode, Din1, Din2, Dout, pnz);
	input [31:0] Din1, Din2;
	input [7:0] opcode;
	output reg pnz;
	output reg [31:0] Dout;
	
	wire signed [31:0] D1, D2;
	wire signed [3:0] opcode1, opcode2;
	assign D1 = Din1;
	assign D2 = Din2;
	//pnz = 0;
	assign opcode1 = opcode[7:4];
	assign opcode2 = opcode[3:0];
	
	//opcode2 types
	parameter OPALUR = 4'b0000;
	parameter OPALUI = 4'b1000;
	parameter OPCMPR = 4'b0010;
	parameter OPCMPI = 4'b1010;
	parameter OPBRANCH = 4'b0110;
	
	//opcode1 
	parameter op0 = 4'b0000;
	parameter op1 = 4'b0001; 
	parameter op2 = 4'b0010;
	parameter op3 = 4'b0011;
	parameter op4 = 4'b0100;
	parameter op5 = 4'b0101;
	parameter op6 = 4'b0110;
	parameter op7 = 4'b0111;
	parameter op8 = 4'b1000;
	parameter op9 = 4'b1001;
	parameter op10 = 4'b1010;
	parameter op11 = 4'b1011;
	parameter op12 = 4'b1100;
	parameter op13 = 4'b1101;
	parameter op14 = 4'b1110;
	parameter op15 = 4'b1111;
	//LD SW 안들어감 
	always @(*)
	begin
		if ((opcode2 == OPALUR) || (opcode2 == OPALUI)) begin
			case (opcode1)
				op0: begin // ADD, ADDI
					Dout <= D1+D2;
					pnz <= 1'b0;
				end
				
				op1: begin //SUB, SUBI
					Dout <= D1-D2;
					pnz <= 1'b0;
				end
				
				op4: begin//AND, ANDI
					Dout <= D1&D2;
					pnz <= 1'b0;
				end
				
				op5: begin //OR, ORI
					Dout <= D1|D2;
					pnz <= 1'b0;
				end
				
				op6: begin//XOR, XORI
					Dout <= D1^D2;
					pnz <= 1'b0;
				end
				op11: begin // MVHI
					Dout <= ((D2 & 32'h0000FFFF) << 16);
					pnz <= 1'b0;
				end
				
				op12: begin //NAND, NANDI
					Dout <= ~(D1&D2);
					pnz <= 1'b0;
				end
				
				op13: begin //NOR, NORI
					Dout <= ~(D1|D2);
					pnz <= 1'b0;
				end
				
				op14: begin//XNOR, XNORI
					Dout <= ~(D1^D2);
					pnz <= 1'b0;
				end
			endcase
		end
		
		if (opcode2 == OPCMPR || opcode2 == OPCMPI) begin
			case (opcode1)
				op0: begin // F, FI
					Dout <= 32'd0;
					pnz <= 1'b0;
				end
				
				op1: begin // EQ, EQI
					if (D1 == D2) begin
						Dout <= 32'd1;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op2: begin //LT, LTI
					if (D1 < D2) begin
						Dout <= 32'd1;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op3: begin //LTE, LTEI
					if (D1 <= D2) begin
						Dout <= 32'd1;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op8: begin // T, TI
					Dout <= 32'd1;
					pnz <= 1'b1;
				end
				
				op9: begin //NE, NEI
					if (D1 != D2) begin
						Dout <= 32'd1;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op10: begin //GTE, GTEI
					if (D1 >= D2) begin
						Dout <= 32'd1;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op11: begin //GT, GTI
					if (D1 > D2) begin
						Dout <= 32'd1;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
			endcase
		end
		
		if (opcode2 == OPBRANCH) begin
			case (opcode1)
				op5: begin //BEQZ
					if (D1 == 32'd0) begin
						Dout <= 32'd0;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op6: begin //BLTZ
					if (D1[31] == 1'b1) begin
						Dout <= 32'd0;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op7: begin //BLTEZ
					if (D1[31] == 1'b1 || D1 == 32'd0) begin
						Dout <= 32'd0;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op13: begin //BNEZ
					if (D1[31] != 32'd0) begin
						Dout <= 32'd0;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op14: begin //BGTEZ
					if (D1[31] == 32'd0 || D1 == 32'd0) begin
						Dout <= 32'd0;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
				op15: begin //BGTZ
					if (D1[31] == 32'd0 && D1[30:0] != 32'd0) begin
						Dout <= 32'd0;
						pnz <= 1'b1;
					end
					else begin
						Dout <= 32'd0;
						pnz <= 1'b0;
					end
				end
				
			endcase
		end
		
		
	end
endmodule
*/