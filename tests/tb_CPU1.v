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
    reg [31:0] PC = 'hff0;
    reg [31:0] ext_mem_mock [9:0];
        integer counter = 0;

    initial
    begin
            ext_mem_mock[0] = 32'b00100000000100110000000000000011;
            ext_mem_mock[1] = 32'b00100000000100010000000000000001;
            ext_mem_mock[2] = 32'b00000010100100011010000000100010;
            ext_mem_mock[3] = 32'b00000010100100110000000000011000;
            ext_mem_mock[4] = 32'b00100000000100110000000000000011;
            ext_mem_mock[5] = 32'b00010010101000000001000000010100;
            ext_mem_mock[6] = 32'b00001000000000000001000000011000;
            ext_mem_mock[7] = 32'b00000010101101001010100000100000;
            ext_mem_mock[8] = 32'b00011110100000000001000000000000;

        while(1)
        begin
            #1; clk = 1'b1;
            #1; clk = 1'b0;
        end
    end

    always @(posedge clk)
    begin
        reset = 0;
        inst_mem_ack = 0;
        case(PC)
            'hffe: reset = 1'b1;
            'h1000:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[0];
                end
           'h1003:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[1];
                end
           'h1006:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[2];
                end
           'h1009:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[3];
                end
           'h100c:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[4];
                end
           'h100f:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[5];
                end
           'h1012:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[6];
                end

        endcase
        PC <= PC + 1;
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
