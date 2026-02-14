`timescale 1ns / 1ps

module data_memory(
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input [31:0] address,
    input [31:0] writeData,
    output reg [31:0] readData
    );
    
    parameter MEM_SIZE = 256;
    
    reg [31:0] mem [0:MEM_SIZE-1];
    
    always @(posedge clk) begin
        if (MemWrite)
            mem[address[$clog2(MEM_SIZE)+1:2]] = writeData;
    end 
    
    always @(*) begin
        if (MemRead && MemWrite)
            $warning("Simultaneous read and write - this shouldn't happen!");
        if ((MemWrite || MemRead) && address[1:0] != 2'b00)
            $warning("Misaligned data address: %h", address);
        if ((MemWrite || MemRead) && address[31:2] >= MEM_SIZE)
            $warning("Data memory access out of bounds! Address %h (word index %0d >= memory size %0d)", address, address[31:2], MEM_SIZE);
            
        if (MemRead)
            readData = mem[address[$clog2(MEM_SIZE)+1:2]];
        else
            readData = 32'b0;
    end   
endmodule
