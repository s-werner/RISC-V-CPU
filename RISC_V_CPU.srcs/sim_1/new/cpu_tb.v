`timescale 1ns / 1ps

module cpu_tb;
    reg clk;
    reg reset;
    wire [31:0] PC_out;
    
    cpu uut (
        .clk(clk),
        .reset(reset),
        .PC_out(PC_out)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $display("=== CPU Test ===");
        
        // Initialize
        clk = 0;
        reset = 1;
        
        // Load program into instruction memory
        uut.instr_mem.instr_mem[0] = 32'h00500093;  // addi x1, x0, 5
        uut.instr_mem.instr_mem[1] = 32'h00A00113;  // addi x2, x0, 10
        uut.instr_mem.instr_mem[2] = 32'h002081B3;  // add  x3, x1, x2
        uut.instr_mem.instr_mem[3] = 32'h00302023;  // sw   x3, 0(x0)    stores 15 from x3
        uut.instr_mem.instr_mem[4] = 32'h00002203;  // lw   x4, 0(x0)    loads  15 into x4
        uut.instr_mem.instr_mem[5] = 32'h00108463;  // beq  x1, x1, 8    skip two instructions ahead
        uut.instr_mem.instr_mem[6] = 32'h06300293;  // addi x5, x0, 99
        uut.instr_mem.instr_mem[7] = 32'h02A00313;  // addi x6, x0, 42
         
        // Release reset
        #10 reset = 0;
        
        repeat(20) begin  // Monitor for 20 clock cycles
            #10;
            $display("PC=0x%h, Instr=0x%h, ALUResult=0x%h, rd1=%d, rd2=%d, aluB=%d, MemRead=%0b, MemWrite=%0b, RegWrite=%0b", 
                     PC_out, uut.instruction, uut.ALUResult, uut.rd1, uut.rd2, uut.aluB, uut.MemRead, uut.MemWrite, uut.RegWrite);
        end
        
        // Run for several cycles
        #200;
        
        // Check results
        $display("x1 = %d (expected 5)", uut.reg_file.registers[1]);
        $display("x2 = %d (expected 10)", uut.reg_file.registers[2]);
        $display("x3 = %d (expected 15)", uut.reg_file.registers[3]);
        $display("x4 = %d (expected 15)", uut.reg_file.registers[4]);
        $display("x5 = %d (expected 0, shouldn't execute)", uut.reg_file.registers[5]);
        $display("x6 = %d (expected 42)", uut.reg_file.registers[6]);
        $display("mem[0] = %d (expected 15)", uut.data_mem.mem[0]);
        
        $finish;
    end
endmodule