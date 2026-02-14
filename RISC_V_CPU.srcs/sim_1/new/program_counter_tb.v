`timescale 1ns / 1ps

module program_counter_tb;
    reg clk;
    reg reset;
    reg PCSrc;
    reg [31:0] PCTarget;
    
    wire [31:0] PC;
    
    integer passed = 0;
    integer failed = 0;
    
    program_counter uut (
        .clk(clk),
        .reset(reset),
        .PCSrc(PCSrc),
        .PCTarget(PCTarget),
        .PC(PC)
    );
    
    always #5 clk = ~clk;
    
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
        $display("=== Program Counter Test Suite ===");
        
        clk = 0;
        reset = 0;
        PCSrc = 0;
        PCTarget = 0;
        
        #2;
        
        $display("--- Test 1: Initial PC value ---");
        assert32bit(PC, 32'h00000000, "PC starts at 0");
        
        $display("--- Test 2: Reset functionality ---");
        reset = 1;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000000, "PC resets to 0");
        
        reset = 0;
        @(posedge clk);
        #1;
        
        $display("--- Test 3: Sequential increment by 4 ---");
        assert32bit(PC, 32'h00000004, "PC increments to 4");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000008, "PC increments to 8");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h0000000C, "PC increments to C");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000010, "PC increments to 10");
        
        $display("--- Test 4: Branch to target address ---");
        PCSrc = 1;
        PCTarget = 32'h00001000;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00001000, "PC branches to target 1000");
        
        $display("--- Test 5: Resume incrementing after branch ---");
        PCSrc = 0;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00001004, "PC increments from branch target");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00001008, "PC continues incrementing");
        
        $display("--- Test 6: Branch to different target ---");
        PCSrc = 1;
        PCTarget = 32'h00000100;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000100, "PC branches to target 100");
        
        $display("--- Test 7: Multiple sequential increments ---");
        PCSrc = 0;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000104, "Increment 1");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000108, "Increment 2");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h0000010C, "Increment 3");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000110, "Increment 4");
        
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000114, "Increment 5");
        
        $display("--- Test 8: Reset during execution ---");
        reset = 1;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000000, "PC resets during execution");
        
        reset = 0;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000004, "PC resumes from 0");
        
        $display("--- Test 9: Branch to 0 address ---");
        PCSrc = 1;
        PCTarget = 32'h00000000;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000000, "PC can branch to 0");
        
        $display("--- Test 10: Branch to maximum address ---");
        PCSrc = 1;
        PCTarget = 32'hFFFFFFFC;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'hFFFFFFFC, "PC branches to max address");
        
        PCSrc = 0;
        @(posedge clk);
        #1;
        assert32bit(PC, 32'h00000000, "PC overflows back to 0");
        
        $display("================================");
        $display("Score: %0d/%0d", passed, passed+failed);
        
        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("%0d tests failed", failed);
            
        $finish;
    end
endmodule