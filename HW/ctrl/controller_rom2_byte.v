module controller_rom2
#
(
	parameter ADDR_WIDTH = 15 // Specify your actual ROM size to save LEs and unnecessary block RAM usage.
)
(
	input  wire                 clk,
	input  wire                 reset_n,
	input  wire                 we,
	input  wire[           3:0] bytesel,
	input  wire[ADDR_WIDTH-1:0] addr,
	input  wire[          31:0] d,
	output reg [          31:0] q
);

reg[7:0] ram0[2**ADDR_WIDTH-1:0];
reg[7:0] ram1[2**ADDR_WIDTH-1:0];
reg[7:0] ram2[2**ADDR_WIDTH-1:0];
reg[7:0] ram3[2**ADDR_WIDTH-1:0];

initial begin
	$readmemh("controller_rom2_byte_0.hex", ram0);
	$readmemh("controller_rom2_byte_1.hex", ram1);
	$readmemh("controller_rom2_byte_2.hex", ram2);
	$readmemh("controller_rom2_byte_3.hex", ram3);
end

always @(posedge clk) begin
	if(we) begin
		if(bytesel[3]) ram3[addr] <= d[ 7: 0];
		if(bytesel[2]) ram2[addr] <= d[15: 8];
		if(bytesel[1]) ram1[addr] <= d[23:16];
		if(bytesel[0]) ram0[addr] <= d[31:24];
	end
	q <= { ram0[addr], ram1[addr], ram2[addr], ram3[addr] };
end

endmodule
