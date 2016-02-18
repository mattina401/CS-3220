module egg_timer(clkIn, reset_btn, state, timer, sec_1, sec_10, min_1, min_10);
	input clkIn;
	input reset_btn;
	input [2:0] state;
	input [15:0] timer;
	output[3:0] sec_1;
	output[3:0] sec_10;
	output[3:0] min_1;
	output[3:0] min_10;
	
	reg [3:0] sec_1;
	reg [3:0] sec_10;
	reg [3:0] min_1;
	reg [3:0] min_10;
	
	
	always @(posedge clkIn) begin
		if(state == 3'b000) begin
			sec_1 <= 3'b000;
			sec_10 <= 3'b000;
			min_1 <= 3'b000;
			min_10 <= 3'b000;
		end 
		else if(state != 3'b101) begin
			if(state != 3'b100 && state != 3'b000) begin
				sec_1 <= timer[3:0];
				
				if(timer[7:4] > 6) begin
					sec_10 <= 5;
				
				end else begin
					sec_10 <= timer[7:4];
				
				end
				
				min_1 <= timer[11:8];
	
				if(timer[15:12] > 6) begin
					min_10 <= 5;
				end else begin
					min_10 <= timer[15:12];
				end
				
			end else if(state == 3'b001) begin
				min_1 <= 3'b000;
				min_10 <= 3'b000;				
			end
	
		end
		else begin
			sec_1 <= sec_1 -1;
				if(sec_1 == 0) begin
					sec_1 <= 9;
					sec_10 <= sec_10 -1;
					if(sec_10 == 0) begin
						sec_10 <= 5;
						min_1 <= min_1 - 1;
						if(min_1 == 0) begin
							min_10 <= 9;
							min_10 <= min_10 -1;
						end
					end
				end
		end
	end
	
endmodule

