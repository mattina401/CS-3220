module SWdevice(sw, abus, dbus, we, intr, clk, rst);
	
	input wire [9 : 0] sw;
	input wire [32 - 1 : 0] abus;
	inout wire [32 - 1 : 0] dbus;
	input wire we, clk, rst;
	output wire intr;
	
	reg [32 - 1: 0] SCTRL, SDATA, PREV_SDATA, counter;
	//SDATA register at F0000014
	wire selSDATA = abus == 32'hF0000014;
	wire rdSDATA = !we && selSDATA;
	
	//SCTRL (control/status) register at F0000114
	//Exact same bits as SCTRL, but these apply to SDATA
	//Problem: if SW not debounced, will Overrun often
	//Solution: SDATA holds debounced value
	wire selSCTRL = abus == 32'hF0000114;
	wire wrSCTRL = we && selSCTRL;
	wire rdSCTRL = !we && selSCTRL;
	
	assign dbus = rdSDATA ? SDATA :
					  rdSCTRL ? SCTRL :
					  {32{1'bz}};
					
	assign intr = SCTRL[0] && SCTRL[8];
	
	//Holds debounced value of SW (not raw SW value)
	always @(posedge clk) begin
		if (rst) begin 
			SDATA <= 0;
			SCTRL <= 0;
			PREV_SDATA <= 0;
		end
		counter <= counter + 1;
		if ((PREV_SDATA[9:0] != sw) && (counter < 100000 - 1)) begin
			PREV_SDATA[9:0] <= sw;
			counter <= 0;
		end
		if(counter == 100000 - 1) begin
			counter <= 0;
			SDATA <= PREV_SDATA;
			SCTRL[2] <= SCTRL[0] | SCTRL[2];
			SCTRL[0] <= 1;
		end
		if (rdSDATA) SCTRL[0] <= 0;
		if (wrSCTRL) begin
			if(!dbus[2]) SCTRL[2] <= 0;
			SCTRL[8] <= dbus[8];
		end
	end
endmodule