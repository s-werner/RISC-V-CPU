`timescale 1ns / 1ps

module instruction_memory(
    input [31:0] address,
    output reg [31:0] instruction
    );
    
    parameter MEM_SIZE = 256;
    
    reg [31:0] instr_mem [0:MEM_SIZE-1];
    
    always @(*) begin
        if (address[1:0] != 2'b00)
            $warning("Misaligned instruction address: %h", address);
    
        if (address[31:2] >= MEM_SIZE)
            $warning("Instruction fetch out of bounds! Address %h (word index %0d >= memory size %0d)", address, address[31:2], MEM_SIZE);
    
        instruction = instr_mem[address[$clog2(MEM_SIZE)+1:2]];
    end    
endmodule
