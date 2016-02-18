module Timer(abus, dbus, we, intr, clk, rst);

	input wire [31 : 0] abus;
	inout wire [31 : 0] dbus;
	input wire we, clk, rst;
	output wire intr;
	
	reg [31: 0] TCNT, TLIM, TCTL, counter;
	
	//TCNT at F0000020
	wire selTCNT = abus == 32'hF0000020;
	//Read returns current value of the counter
	wire rdTCNT = !we && selTCNT;
	//	Write sets value of the counter
	wire wrTCNT = we && selTCNT;
	
	//TLIM at F0000024
	//Write sets the value, read gets the value
	//When TLIM is zero, it has no effect (counter just keeps counting)
	//When TLIM!=0, it acts as the limit/target value for the counter
	//If  TCNT==TLIM-1 and we want to increment TCNT,we reset TCNT back to zero and  set the ready bit (or overflow if Ready already set)
	//If TLIM>0, the TCNT never actually becomes equal to TLIM (wraps from TLIM-1 to 0)
	wire selTLIM = abus == 32'hF0000024;
	wire rdTLIM = !we && selTLIM;
	wire wrTLIM = we && selTLIM;
	
	//	TCTL (control/status) register at F0000120
	//	Same bits as KCTRL and SCTRL
	//	“Ready” and Overflow bits set as described for TLIM
	//	Writing 0 to the Ready or Overflow bit changes it to 0,but writing 1 to one (or both) of these is ignored
	//	Properly written code should not write 1 to “Ready, but if it does then it has no effect
	wire selTCTL = abus == 32'hF0000120;
	wire rdTCTL = !we && selTCTL;
	wire wrTCTL = we && selTCTL;
	
	assign dbus = rdTCNT ? TCNT :
					  rdTLIM ? TLIM :
					  rdTCTL ? TCTL :
					  {32{1'bz}};
					
	assign intr = TCTL[0] && TCTL[8];
					
	always @(posedge clk) begin
	//Start the device off with TCNT, TLIM, TCTL all-zeros!
		if (rst) begin
			TCNT <= 0;
			TLIM <= 0;
			TCTL <= 0;
			counter <= 0;
		end
		if (wrTCNT) TCNT <= dbus;
		if (wrTLIM) TLIM <= dbus;
		if (wrTCTL) begin
			if(!dbus[0]) TCTL[0] <= 0;
			if(!dbus[2]) TCTL[2] <= 0;
			TCTL[8] <= dbus[8];
		end
		
	   // TCNT Incremented every 1ms
		counter <= counter + 1;
		if (counter == 10000 - 1) begin
			counter <= 32'd0;
			TCNT <= TCNT + 1;
			if (TLIM != 0 && TCNT == TLIM - 1) begin
				TCNT <= 0;
				TCTL[2] <= TCTL[0] | TCTL[2];
				TCTL[0] <= 1;
			end
		end
	end	
endmodule