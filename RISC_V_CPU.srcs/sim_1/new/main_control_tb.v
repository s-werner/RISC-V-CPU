`timescale 1ns / 1ps

module main_control_tb();
    integer passed = 0;
    integer failed = 0;

    reg [6:0] opcode;
    wire MemRead, MemWrite, ALUSrc, RegWrite, MemToReg, Branch;
    wire [1:0] ALUop;
    main_control mc (
        .opcode(opcode),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .Branch(Branch),
        .ALUop(ALUop)
    );

    task assert1bit;
        input actual;
        input expected;
        begin
            if (actual !== expected) begin
                failed = failed + 1;
                $display("FAIL: Expected %b, got %b", expected, actual);
            end else begin
                passed = passed + 1;
            end
        end
    endtask
    
    task assert2bit;
        input [1:0] actual;
        input [1:0] expected;
        begin
            if (actual !== expected) begin
                failed = failed + 1;
                $display("FAIL: Expected %b, got %b", expected, actual);
            end else begin
                passed = passed + 1;
            end
        end
    endtask

    task rTypeTest;
        begin
            $display("--- Testing R-type ALU ---");
            opcode = 7'b0110011;
            #10;
            
            assert1bit(MemRead, 1'b0);
            assert1bit(RegWrite, 1'b1);
            assert2bit(ALUop, 2'b10);
        end
    endtask
    
    task iTypeTest;
        begin
            $display("--- Testing I-type ALU ---");
            opcode = 7'b0010011;
            #10;
            
            assert1bit(MemRead, 1'b0);
            assert1bit(MemWrite, 1'b0);
            assert1bit(ALUSrc, 1'b1);
            assert1bit(RegWrite, 1'b1);
            assert1bit(MemToReg, 1'b0);
            assert1bit(Branch, 1'b0);
            assert2bit(ALUop, 2'b10);
        end
    endtask
    
    task loadTest;
        begin
            $display("--- Testing Load ---");
            opcode = 7'b0000011;
            #10;
            
            assert1bit(MemRead, 1'b1);
            assert1bit(MemWrite, 1'b0);
            assert1bit(ALUSrc, 1'b1);
            assert1bit(RegWrite, 1'b1);
            assert1bit(MemToReg, 1'b1);
            assert1bit(Branch, 1'b0);
            assert2bit(ALUop, 2'b00);
        end
    endtask
    
    task storeTest;
        begin
            $display("--- Testing Store ---");
            opcode = 7'b0100011;
            #10;
            
            assert1bit(MemRead, 1'b0);
            assert1bit(MemWrite, 1'b1);
            assert1bit(ALUSrc, 1'b1);
            assert1bit(RegWrite, 1'b0);
            assert1bit(MemToReg, 1'b0);
            assert1bit(Branch, 1'b0);
            assert2bit(ALUop, 2'b00);
        end
    endtask
    
    task branchTest;
        begin
            $display("--- Testing Branch ---");
            opcode = 7'b1100011;
            #10;
            
            assert1bit(MemRead, 1'b0);
            assert1bit(MemWrite, 1'b0);
            assert1bit(ALUSrc, 1'b0);
            assert1bit(RegWrite, 1'b0);
            assert1bit(MemToReg, 1'b0);
            assert1bit(Branch, 1'b1);
            assert2bit(ALUop, 2'b01);
        end
    endtask
    
    task defaultTest;
        begin
            $display("--- Testing Default (invalid opcode) ---");
            opcode = 7'b1111111;  // Invalid opcode
            #10;
            
            assert1bit(MemRead, 1'b0);
            assert1bit(MemWrite, 1'b0);
            assert1bit(ALUSrc, 1'b0);
            assert1bit(RegWrite, 1'b0);
            assert1bit(MemToReg, 1'b0);
            assert1bit(Branch, 1'b0);
            assert2bit(ALUop, 2'b00);
        end
    endtask
    
    initial begin
        $display("=== Main Control Unit Test Suite ===");
        
        rTypeTest();
        iTypeTest();
        loadTest();
        storeTest();
        branchTest();
        defaultTest();
        
        $display("================================");
        $display("Score: %0d/%0d", passed, passed+failed);
        $finish;
    end

endmodule
