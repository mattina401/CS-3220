module DISPdevice(dev, abus, dbus, we, clk);
	parameter LENG;
	parameter PAR_ADDR;
		
	input wire [31 : 0] abus;
	inout wire [31 : 0] dbus;
	input wire we, clk;
	inout reg [31: 0] dev;
	
	//Writes to F0000000, F0000004 and F0000008 change what is shown on HEX, LEDR, and LEDG
	//Only bits that actually exist are written
	//E.g. writing value 0xFFFFFFFF to F0000008 is the same as writing 0x000000FF (LEDG only has 8 actual bits)
	wire selDATA = abus == PAR_ADDR;
	wire wrDATA = we && selDATA;
	wire rdDATA = !we && selDATA;
	
	assign dbus = rdDATA ? dev : {32{1'bz}};
	
	//But now reads from these addresses return what is currently shown
	//Bits that don’t exist are returned as zero, e.g. after writing FFFFFFFF to LEDG, a read returns 0x000000FF
	always @(posedge clk) begin
		if (wrDATA)	dev[LENG - 1 : 0] <= dbus[LENG - 1 : 0];
	end
endmodule