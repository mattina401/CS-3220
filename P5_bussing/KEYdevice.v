module KEYdevice(key, abus, dbus, we, intr, clk, rst);
	
	input wire [3 : 0] key;
	input wire [31 : 0] abus;
	inout wire [31 : 0] dbus;
	input wire we, clk, rst;
	output wire intr;
	
	reg [31: 0] KCTRL, KDATA;
	
	//KDATA register at F0000010
	//Same as before
	//Current state of KEY[3:0]
	//Writes to these bits are ignored
	wire selKDATA = abus == 32'hF0000010;
	wire rdKDATA = !we && selKDATA;
	
	//KCTRL (control/status) register at F0000110
	wire selKCTRL = abus == 32'hF0000110;
	wire wrKCTRL = we && selKCTRL;
	wire rdKCTRL = !we && selKCTRL;
	
	assign dbus = rdKDATA ? KDATA :
					  rdKCTRL ? KCTRL :
					  {32{1'bz}};
					
	assign intr = KCTRL[0] && KCTRL[8];
	
	always @(posedge clk) begin
		//Start the device off with KCTRL all-zeros!
		if (rst) begin 
			KDATA <= 0;
			KCTRL <= 0;
		end
		//Bit 0 is the Ready bit. Becomes 1 if change in KDATA state detected
		//Bit 2 is the Overrun bit.Set to 1 if Ready bit still 1 when KDATA changes
		if (KDATA[3:0] != key) begin
			KDATA[3:0] <= (~key & 4'hf);
			KCTRL[2] <= KCTRL[0] | KCTRL[2];
			KCTRL[0] <= 1;
		end
		if (rdKDATA) KCTRL[0] <= 0;
		//Bit 8 is the IE bit. If 0, KEY device does not generate interrupts
		if (wrKCTRL) begin
			if(!dbus[2]) KCTRL[2] <= 0;
			KCTRL[8] <= dbus[8];
		end
	end
endmodule