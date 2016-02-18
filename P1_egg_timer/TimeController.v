module TimeController (CLOCK_50, SW, KEY, HEX0, HEX1, HEX2, HEX3, LEDR);
//inputs
input CLOCK_50;
input [9:0] SW;
input [3:0] KEY;
output [6:0] HEX0;
output [6:0] HEX1; 
output [6:0] HEX2; 
output [6:0] HEX3; 
output [9:0] LEDR;
//variables
wire [3:0] sec_1;
wire [3:0] sec_10;
wire [3:0] min_1;
wire [3:0] min_10;
reg [15:0] timer;
//for state machine
reg [9:0] onoff;
assign LEDR = onoff;
wire reset_state = (SW == 10'b0000000000) ? 1 : 0;
wire reset_btn = ~KEY[0];
reg [2:0] state;
parameter reset = 3'b000;
parameter second = 3'b001;
parameter minute = 3'b010;
parameter stop = 3'b100;
parameter run = 3'b101;
parameter light = 3'b111;
parameter off = 3'b110;
reg tick;
ClkDivider(CLOCK_50, CLOCK);
reg key_on = 0;

always @(posedge CLOCK_50) begin
	if(key_on) begin
		onoff = 10'b0000000000;
	end
	else if(reset_btn) begin
		state = reset;
		timer = 16'b0;
	end 
	else begin
		case(state)
				reset: begin
						if(reset_state && KEY[1]) begin
							state = second;
						end 
						else begin
							state = state;
						end
				end
				
				second: begin
						timer[7:0] <= SW[7:0];
						if(~KEY[1]) begin
							state = minute;
						end
						else begin
							state = state; 
						end	
				end
				
				minute: begin
						timer[15:8] <= SW[7:0];	
							if(~KEY[1]) begin
							state = stop;
							end
						else begin
							state = state;
						end
				end
				
				stop: begin
						if(~KEY[2]) begin
							state = run;
						end
						else begin
							state = state;
						end
				end
				
				run: begin	
						if(~KEY[2]) begin
							state = stop;
						end
						if(((sec_1 == sec_10) && (min_1 == min_10)) && ((min_1 == sec_1) && (min_1 == 4'b0000))) begin
							state = light;
							timer = 16'b0000000000000000;
							end
						else begin
							state = state;
						end
				end
				
				light: begin
				if( CLOCK_50 == CLOCK) begin
						onoff = 10'b1111111111;
						end
						else
						onoff = 10'b0000000000;
						end	
		endcase
	end
	
	key_on = ~KEY[0] | ~KEY[1] | ~KEY[2];
		
end

egg_timer(CLOCK, reset_btn, state, timer, sec_1, sec_10, min_1, min_10);
dec2_7seg(sec_1, HEX0);
dec2_7seg(sec_10, HEX1);
dec2_7seg(min_1, HEX2);
dec2_7seg(min_10, HEX3);
endmodule 


module dec2_7seg(input [3:0] num, output [6:0] display);
   assign display = 
	num == 0 ? ~7'b0111111 :
	num == 1 ? ~7'b0000110 :
	num == 2 ? ~7'b1011011 :
	num == 3 ? ~7'b1001111 :
	num == 4 ? ~7'b1100110 :
	num == 5 ? ~7'b1101101 :
	num == 6 ? ~7'b1111101 :
	num == 7 ? ~7'b0000111 :
	num == 8 ? ~7'b1111111 :
	num == 9 ? ~7'b1100111 :
	7'bxxxxxxx;   // Output is a don't care if illegal input
endmodule 

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