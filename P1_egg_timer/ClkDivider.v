module ClkDivider(input clkIn, output clkOut);
	reg[31: 0] counter;
	
	reg clkReg;
	
	assign clkOut = clkReg;
	
	always @(posedge clkIn) begin
		counter <= counter + 1;
		
		if (counter == 25000000) begin
			clkReg <= ~clkReg;
			counter <= 0;
		end
	end
endmodule 