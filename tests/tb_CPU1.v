`timescale 1ns / 1ps

module tb_CPU1();

    // Processor inputs
    reg clk = 1'b0;
    reg reset = 1'b0;
    reg [4:0] interrupts = 5'b0;
    reg nmi = 1'b0;
    reg [31:0] dataMem_In = 32'b0;
    reg dataMem_Ack = 1'b0;
    reg [31:0] instruction = 32'b0;
    reg inst_mem_ack = 1'b0;

    // Processor outputs
    wire InstMem_Read;
    wire [29:0] InstMem_Address;
    // Local variables
    reg [31:0] loop_index = 'hff0;
    reg [31:0] ext_mem_mock [11:0];
    integer counter = 0;

    initial
    begin
			// Our sample "program"
            ext_mem_mock[0] = 32'b00100000000100110000000000000011; // addi $s3, $zero, 3
            ext_mem_mock[1] = 32'b00100000000100010000000000000001; // addi $s1, $zero, 1
            ext_mem_mock[2] = 32'b00000010100100011010000000100010; // sub  $s4, $s4, $s1
            ext_mem_mock[3] = 32'b00000010100100110000000000011000; // mult $s4, $s3
            ext_mem_mock[4] = 32'b00000000000000001010100000010010; // mflo $s5
            ext_mem_mock[5] = 32'b00010010101000000000000000000010; // beq  $s5, $r0 2 (T1)
            ext_mem_mock[6] = 32'b00001000000000000001000000011000; // j    1000 (T2)
            ext_mem_mock[7] = 32'b00000010101101001010100000100000; // add  $s5, $s5, $s4
            ext_mem_mock[8] = 32'b00011110100000001111111111111010; // bgtz $s4, -6 (L0)
			// Extra & initialization. Init vals: $s4 <- 5, $s5 <- 1
            ext_mem_mock[9]  = 32'b00001000000000000000111111111000; // j 0xff8, initializer to jump near our loop and use the InstMem_Address from there
            ext_mem_mock[10] = 32'b00100000000101000000000000000101; // addi $s4, $r0, 5
            ext_mem_mock[11] = 32'b00100000000101010000000000000001; // addi $s5, $r0, 1
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

        case(loop_index)
            'hffe: reset = 1'b1;
            'h1000:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[10];
                end
           'h1003:  // Some dummy instructions to start, and here we do the jump (not necessary,
                    // but useful for consistency with our example) to the code.
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[9];
                end
           'h1006:  // extra dummy instructions to keep the core rolling until it finally jumps...
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[11];
                end
           'h1009:
                begin
                inst_mem_ack = 1;
                instruction <= ext_mem_mock[0];
                end
           default: // The core's peculiarities make it difficult to control the ack signal correctly,
                    // so this non-intuitive, ugly hack here serves to just manipulate this for correct function.
                    // Long story short: It's every 3 cycles that we need to read the next instruction.
                begin
                    if (((loop_index -'hffe) % 3) == 0)
                    begin
                        inst_mem_ack = 1;
                    end
                end
         endcase
         case(InstMem_Address)
           'hff8: instruction <= ext_mem_mock[0];
           'hff9: instruction <= ext_mem_mock[1];
           'hffa: instruction <= ext_mem_mock[2];
           'hffb: instruction <= ext_mem_mock[3];
           'hffc: instruction <= ext_mem_mock[4];
           'hffd: instruction <= ext_mem_mock[5];
           'hffe: instruction <= ext_mem_mock[6];
           'hfff: instruction <= ext_mem_mock[7];
           'h1000:instruction <= ext_mem_mock[8];
        endcase
        loop_index <= loop_index + 1;

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
