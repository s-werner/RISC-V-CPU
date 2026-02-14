`timescale 1ns / 1ps

module alu_tb;
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALUControl;
    
    wire [31:0] Result;
    
    integer passed = 0;
    integer failed = 0;
    
    alu uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .Result(Result)
    );
    
    task assert32bit;
        input [31:0] actual;
        input [31:0] expected;
        input [256*8-1:0] test_name;
        begin
            if (actual !== expected) begin
                failed = failed + 1;
                $display("FAIL [%s]: Expected %h, got %h", test_name, expected, actual);
            end else begin
                passed = passed + 1;
            end
        end
    endtask
    
    task testAND;
        begin
            $display("--- Testing AND ---");
            A = 32'hFFFF0000;
            B = 32'h0F0F0F0F;
            ALUControl = 4'b0000;
            #10;
            assert32bit(Result, 32'h0F0F0000, "AND basic");
            
            A = 32'hAAAAAAAA;
            B = 32'h55555555;
            ALUControl = 4'b0000;
            #10;
            assert32bit(Result, 32'h00000000, "AND complement");
        end
    endtask
    
    task testOR;
        begin
            $display("--- Testing OR ---");
            A = 32'hFFFF0000;
            B = 32'h0000FFFF;
            ALUControl = 4'b0001;
            #10;
            assert32bit(Result, 32'hFFFFFFFF, "OR basic");
            
            A = 32'h12345678;
            B = 32'h00000000;
            ALUControl = 4'b0001;
            #10;
            assert32bit(Result, 32'h12345678, "OR with zero");
        end
    endtask
    
    task testADD;
        begin
            $display("--- Testing ADD ---");
            A = 32'd10;
            B = 32'd20;
            ALUControl = 4'b0010;
            #10;
            assert32bit(Result, 32'd30, "ADD positive");
            
            A = 32'hFFFFFFFF;
            B = 32'd1;
            ALUControl = 4'b0010;
            #10;
            assert32bit(Result, 32'd0, "ADD overflow");
            
            A = 32'd0;
            B = 32'd0;
            ALUControl = 4'b0010;
            #10;
            assert32bit(Result, 32'd0, "ADD zeros");
        end
    endtask
    
    task testXOR;
        begin
            $display("--- Testing XOR ---");
            A = 32'hAAAAAAAA;
            B = 32'h55555555;
            ALUControl = 4'b0011;
            #10;
            assert32bit(Result, 32'hFFFFFFFF, "XOR complement");
            
            A = 32'h12345678;
            B = 32'h12345678;
            ALUControl = 4'b0011;
            #10;
            assert32bit(Result, 32'h00000000, "XOR same value");
        end
    endtask
    
    task testSLL;
        begin
            $display("--- Testing SLL ---");
            A = 32'h00000001;
            B = 32'd4;
            ALUControl = 4'b0100;
            #10;
            assert32bit(Result, 32'h00000010, "SLL by 4");
            
            A = 32'h00000001;
            B = 32'd31;
            ALUControl = 4'b0100;
            #10;
            assert32bit(Result, 32'h80000000, "SLL by 31");
            
            A = 32'hFFFFFFFF;
            B = 32'd0;
            ALUControl = 4'b0100;
            #10;
            assert32bit(Result, 32'hFFFFFFFF, "SLL by 0");
        end
    endtask
    
    task testSRL;
        begin
            $display("--- Testing SRL ---");
            A = 32'h80000000;
            B = 32'd4;
            ALUControl = 4'b0101;
            #10;
            assert32bit(Result, 32'h08000000, "SRL by 4");
            
            A = 32'hFFFFFFFF;
            B = 32'd1;
            ALUControl = 4'b0101;
            #10;
            assert32bit(Result, 32'h7FFFFFFF, "SRL negative by 1");
            
            A = 32'h12345678;
            B = 32'd0;
            ALUControl = 4'b0101;
            #10;
            assert32bit(Result, 32'h12345678, "SRL by 0");
        end
    endtask
    
    task testSUB;
        begin
            $display("--- Testing SUB ---");
            A = 32'd100;
            B = 32'd50;
            ALUControl = 4'b0110;
            #10;
            assert32bit(Result, 32'd50, "SUB positive");
            
            A = 32'd50;
            B = 32'd100;
            ALUControl = 4'b0110;
            #10;
            assert32bit(Result, 32'hFFFFFFCE, "SUB negative result");
            
            A = 32'd42;
            B = 32'd42;
            ALUControl = 4'b0110;
            #10;
            assert32bit(Result, 32'd0, "SUB equal values");
        end
    endtask
    
    task testSLT;
        begin
            $display("--- Testing SLT (signed) ---");
            A = 32'd10;
            B = 32'd20;
            ALUControl = 4'b0111;
            #10;
            assert32bit(Result, 32'd1, "SLT positive less than");
            
            A = 32'd20;
            B = 32'd10;
            ALUControl = 4'b0111;
            #10;
            assert32bit(Result, 32'd0, "SLT positive greater than");
            
            A = 32'hFFFFFFFF;
            B = 32'd1;
            ALUControl = 4'b0111;
            #10;
            assert32bit(Result, 32'd1, "SLT negative vs positive");
            
            A = 32'd1;
            B = 32'hFFFFFFFF;
            ALUControl = 4'b0111;
            #10;
            assert32bit(Result, 32'd0, "SLT positive vs negative");
        end
    endtask
    
    task testSLTU;
        begin
            $display("--- Testing SLTU (unsigned) ---");
            A = 32'd10;
            B = 32'd20;
            ALUControl = 4'b1000;
            #10;
            assert32bit(Result, 32'd1, "SLTU less than");
            
            A = 32'd20;
            B = 32'd10;
            ALUControl = 4'b1000;
            #10;
            assert32bit(Result, 32'd0, "SLTU greater than");
            
            A = 32'hFFFFFFFF;
            B = 32'd1;
            ALUControl = 4'b1000;
            #10;
            assert32bit(Result, 32'd0, "SLTU max vs small");
            
            A = 32'd1;
            B = 32'hFFFFFFFF;
            ALUControl = 4'b1000;
            #10;
            assert32bit(Result, 32'd1, "SLTU small vs max");
        end
    endtask
    
    task testSRA;
        begin
            $display("--- Testing SRA (arithmetic) ---");
            A = 32'h80000000;
            B = 32'd4;
            ALUControl = 4'b1001;
            #10;
            assert32bit(Result, 32'hF8000000, "SRA negative by 4");
            
            A = 32'h7FFFFFFF;
            B = 32'd4;
            ALUControl = 4'b1001;
            #10;
            assert32bit(Result, 32'h07FFFFFF, "SRA positive by 4");
            
            A = 32'hFFFFFFFF;
            B = 32'd1;
            ALUControl = 4'b1001;
            #10;
            assert32bit(Result, 32'hFFFFFFFF, "SRA all ones");
        end
    endtask
    
    task testInvalidControl;
        begin
            $display("--- Testing Invalid ALU Control ---");
            A = 32'd100;
            B = 32'd50;
            ALUControl = 4'b1111;
            #10;
            assert32bit(Result, 32'd0, "Invalid control defaults to zero");
        end
    endtask
    
    initial begin
        $display("=== ALU Test Suite ===");
        
        testAND();
        testOR();
        testADD();
        testXOR();
        testSLL();
        testSRL();
        testSUB();
        testSLT();
        testSLTU();
        testSRA();
        testInvalidControl();
        
        $display("================================");
        $display("Score: %0d/%0d", passed, passed+failed);
        
        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("%0d tests failed", failed);
            
        $finish;
    end
endmodule