`timescale 1ns / 1ps

module ALU_control_tb;
    reg [1:0] ALUop;
    reg [2:0] funct3;
    reg [6:0] funct7;
    
    wire [3:0] ALUControl;
    
    integer passed = 0;
    integer failed = 0;
    
    ALU_control uut (
        .ALUop(ALUop),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );
    
    task assert4bit;
        input [3:0] actual;
        input [3:0] expected;
        begin
            if (actual !== expected) begin
                failed = failed + 1;
                $display("FAIL: Expected %b, got %b", expected, actual);
            end else begin
                passed = passed + 1;
            end
        end
    endtask
    
    task testLoadStore;
        begin
            $display("--- Testing Load/Store ---");
            ALUop = 2'b00;
            funct3 = 3'b000;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0010);
        end
    endtask
    
    task testBranch;
        begin
            $display("--- Testing Branch ---");
            ALUop = 2'b01;
            funct3 = 3'b000;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0110);
        end
    endtask
    
    task testADD;
        begin
            $display("--- Testing ADD ---");
            ALUop = 2'b10;
            funct3 = 3'b000;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0010);
        end
    endtask
    
    task testSUB;
        begin
            $display("--- Testing SUB ---");
            ALUop = 2'b10;
            funct3 = 3'b000;
            funct7 = 7'b0100000;
            #10;
            assert4bit(ALUControl, 4'b0110);
        end
    endtask
    
    task testSLL;
        begin
            $display("--- Testing SLL ---");
            ALUop = 2'b10;
            funct3 = 3'b001;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0100);
        end
    endtask
    
    task testSLT;
        begin
            $display("--- Testing SLT ---");
            ALUop = 2'b10;
            funct3 = 3'b010;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0111);
        end
    endtask
    
    task testSLTU;
        begin
            $display("--- Testing SLTU ---");
            ALUop = 2'b10;
            funct3 = 3'b011;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b1000);
        end
    endtask
    
    task testXOR;
        begin
            $display("--- Testing XOR ---");
            ALUop = 2'b10;
            funct3 = 3'b100;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0011);
        end
    endtask
    
    task testSRL;
        begin
            $display("--- Testing SRL ---");
            ALUop = 2'b10;
            funct3 = 3'b101;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0101);
        end
    endtask
    
    task testSRA;
        begin
            $display("--- Testing SRA ---");
            ALUop = 2'b10;
            funct3 = 3'b101;
            funct7 = 7'b0100000;
            #10;
            assert4bit(ALUControl, 4'b1001);
        end
    endtask
    
    task testOR;
        begin
            $display("--- Testing OR ---");
            ALUop = 2'b10;
            funct3 = 3'b110;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0001);
        end
    endtask
    
    task testAND;
        begin
            $display("--- Testing AND ---");
            ALUop = 2'b10;
            funct3 = 3'b111;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0000);
        end
    endtask
    
    task testInvalidFunct7;
        begin
            $display("--- Testing Invalid funct7 ---");
            ALUop = 2'b10;
            funct3 = 3'b111;
            funct7 = 7'b1111111;
            #10;
            assert4bit(ALUControl, 4'b0000);
        end
    endtask
    
    task testInvalidALUop;
        begin
            $display("--- Testing Invalid ALUop ---");
            ALUop = 2'b11;
            funct3 = 3'b000;
            funct7 = 7'b0000000;
            #10;
            assert4bit(ALUControl, 4'b0000);
        end
    endtask
    
    initial begin
        $display("=== ALU Control Unit Test Suite ===");
        
        testLoadStore();
        testBranch();
        testADD();
        testSUB();
        testSLL();
        testSLT();
        testSLTU();
        testXOR();
        testSRL();
        testSRA();
        testOR();
        testAND();
        testInvalidFunct7();
        testInvalidALUop();
        
        $display("================================");
        $display("Score: %0d/%0d", passed, passed+failed);
        
        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("%0d tests failed", failed);
            
        $finish;
    end
endmodule