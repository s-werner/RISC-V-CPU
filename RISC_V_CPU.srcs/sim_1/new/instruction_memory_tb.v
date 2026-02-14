`timescale 1ns / 1ps

module instruction_memory_tb;
    reg [31:0] address;
    wire [31:0] instruction;
    
    integer passed = 0;
    integer failed = 0;
    
    instruction_memory uut (
        .address(address),
        .instruction(instruction)
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
    
    initial begin
        $display("=== Instruction Memory Test Suite ===");
        
        $display("--- Loading test program into memory ---");
        uut.instr_mem[0] = 32'h00000013;
        uut.instr_mem[1] = 32'h00100093;
        uut.instr_mem[2] = 32'h00200113;
        uut.instr_mem[3] = 32'h00408193;
        uut.instr_mem[4] = 32'hDEADBEEF;
        uut.instr_mem[5] = 32'hCAFEBABE;
        uut.instr_mem[10] = 32'h12345678;
        uut.instr_mem[255] = 32'hFFFFFFFF;
        
        #10;
        
        $display("--- Test 1: Read from address 0 ---");
        address = 32'h00000000;
        #1;
        assert32bit(instruction, 32'h00000013, "Address 0");
        
        $display("--- Test 2: Read from address 4 ---");
        address = 32'h00000004;
        #1;
        assert32bit(instruction, 32'h00100093, "Address 4");
        
        $display("--- Test 3: Read from address 8 ---");
        address = 32'h00000008;
        #1;
        assert32bit(instruction, 32'h00200113, "Address 8");
        
        $display("--- Test 4: Read from address 12 ---");
        address = 32'h0000000C;
        #1;
        assert32bit(instruction, 32'h00408193, "Address C");
        
        $display("--- Test 5: Read from address 16 ---");
        address = 32'h00000010;
        #1;
        assert32bit(instruction, 32'hDEADBEEF, "Address 10");
        
        $display("--- Test 6: Read from address 20 ---");
        address = 32'h00000014;
        #1;
        assert32bit(instruction, 32'hCAFEBABE, "Address 14");
        
        $display("--- Test 7: Read from non-sequential address 40 ---");
        address = 32'h00000028;
        #1;
        assert32bit(instruction, 32'h12345678, "Address 28 (index 10)");
        
        $display("--- Test 8: Read from maximum address (1020) ---");
        address = 32'h000003FC;
        #1;
        assert32bit(instruction, 32'hFFFFFFFF, "Address 3FC (index 255)");
        
        $display("--- Test 9: Multiple sequential reads ---");
        address = 32'h00000000;
        #1;
        assert32bit(instruction, 32'h00000013, "Sequential read 1");
        
        address = 32'h00000004;
        #1;
        assert32bit(instruction, 32'h00100093, "Sequential read 2");
        
        address = 32'h00000008;
        #1;
        assert32bit(instruction, 32'h00200113, "Sequential read 3");
        
        $display("--- Test 10: Read back to address 0 ---");
        address = 32'h00000000;
        #1;
        assert32bit(instruction, 32'h00000013, "Back to address 0");
        
        $display("--- Test 11: Misaligned address (should warn) ---");
        $display("Expect warning for misaligned address...");
        address = 32'h00000001;
        #1;
        
        $display("--- Test 12: Another misaligned address ---");
        $display("Expect warning for misaligned address...");
        address = 32'h00000003;
        #1;
        
        $display("--- Test 13: Out of bounds address (should warn) ---");
        $display("Expect warning for out of bounds address...");
        address = 32'h00000400;
        #1;
        
        $display("--- Test 14: Way out of bounds address (should warn) ---");
        $display("Expect warning for out of bounds address...");
        address = 32'hFFFFFFFC;
        #1;
        
        $display("================================");
        $display("Score: %0d/%0d", passed, passed+failed);
        
        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("%0d tests failed", failed);
            
        $finish;
    end
endmodule