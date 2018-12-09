`timescale 1ns / 1ps

module tb_CPU1();

	// Processor inputs
	reg clk = 1'b0;
	reg reset = 1'b0;
	reg [4:0] interrupts = 5'b0;
	reg nmi = 1'b0;
	reg [31:0] dataMem_In = 32'b0;
	reg dataMem_Ack;
	reg [31:0] instruction = 32'b0;
	reg inst_mem_ack = 1'b0;

	// Processor outputs
	wire InstMem_Read;
	wire [29:0] InstMem_Address;
	// Local variables
	reg [31:0] PC = 32'b0;

	initial
	begin
		while(1)
		begin
			#1; clk = 1'b1;
			#1; clk = 1'b0;
		end
	end

	always @(posedge clk)
	begin

		PC <= PC + 4;

	end

	Processor DUT
	(
		.clock(clk),
		.reset(reset),
		.Interrupts(interrupts),
		.NMI(nmi),
		.DataMem_In(dataMem_In),
		.DataMem_Ack(dataMem_Ack),
		.InstMem_In(instruction),
		.InstMem_Ack(inst_mem_ack),
		.InstMem_Address(InstMem_Address),
		.InstMem_Read(InstMem_Read)

	);
endmodule

