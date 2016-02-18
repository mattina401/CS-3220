module pc_4(dIn, dOut);

	input [31:0] dIn;
	output [31:0] dOut;
	reg [31:0] dOut;
	
	always @(dIn) begin
		dOut <= dIn + 4;
	end
	
endmodule