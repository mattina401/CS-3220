module Mux4to1 (sel, in0, in1, in2, in3, out);
	input [1:0] sel;
	input [31:0] in0, in1, in2, in3;
	output [31:0] out;
	
	reg [31:0] out;
	
	always @(*) begin
		case(sel)
			2'b00: begin
				out <= in0;
			end
			2'b01: begin
				out <= in1;
			end
			2'b10: begin
				out <= in2;
			end
			2'b11: begin
				out <= in3;
			end
		endcase
	end
endmodule