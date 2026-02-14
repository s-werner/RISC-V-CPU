`timescale 1ns / 1ps

module data_memory_tb;
    reg clk;
    reg MemWrite;
    reg MemRead;
    reg [31:0] address;
    reg [31:0] writeData;
    
    wire [31:0] readData;
    
    integer passed = 0;
    integer failed = 0;
    
    data_memory uut (
        .clk(clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(address),
        .writeData(writeData),
        .readData(readData)
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
    
    task writeMemory;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(negedge clk);
            MemWrite = 1;
            MemRead = 0;
            address = addr;
            writeData = data;
            @(posedge clk);
            #1;
            MemWrite = 0;
        end
    endtask
    
    task readMemory;
        input [31:0] addr;
        begin
            @(negedge clk);
            MemRead = 1;
            MemWrite = 0;
            address = addr;
            #1;
        end
    endtask
    
    initial begin
        $display("=== Data Memory Test Suite ===");
        
        clk = 0;
        MemWrite = 0;
        MemRead = 0;
        address = 0;
        writeData = 0;
        
        #10;
        
        $display("--- Test 1: Read without MemRead (should return 0) ---");
        address = 32'h00000000;
        MemRead = 0;
        #1;
        assert32bit(readData, 32'h00000000, "Read disabled returns 0");
        
        $display("--- Test 2: Write single value ---");
        writeMemory(32'h00000000, 32'h12345678);
        readMemory(32'h00000000);
        assert32bit(readData, 32'h12345678, "Write and read address 0");
        
        $display("--- Test 3: Write to different address ---");
        writeMemory(32'h00000004, 32'hDEADBEEF);
        readMemory(32'h00000004);
        assert32bit(readData, 32'hDEADBEEF, "Write and read address 4");
        
        $display("--- Test 4: Verify first value unchanged ---");
        readMemory(32'h00000000);
        assert32bit(readData, 32'h12345678, "Address 0 still has original value");
        
        $display("--- Test 5: Write multiple values ---");
        writeMemory(32'h00000008, 32'hCAFEBABE);
        writeMemory(32'h0000000C, 32'hAAAAAAAA);
        writeMemory(32'h00000010, 32'h55555555);
        
        readMemory(32'h00000008);
        assert32bit(readData, 32'hCAFEBABE, "Address 8");
        
        readMemory(32'h0000000C);
        assert32bit(readData, 32'hAAAAAAAA, "Address C");
        
        readMemory(32'h00000010);
        assert32bit(readData, 32'h55555555, "Address 10");
        
        $display("--- Test 6: Overwrite existing value ---");
        writeMemory(32'h00000000, 32'hFFFFFFFF);
        readMemory(32'h00000000);
        assert32bit(readData, 32'hFFFFFFFF, "Address 0 overwritten");
        
        $display("--- Test 7: Write without MemWrite (should not write) ---");
        writeMemory(32'h00000014, 32'hAAAAAAAA);
        readMemory(32'h00000014);
        assert32bit(readData, 32'hAAAAAAAA, "Initial write");
        
        @(negedge clk);
        MemWrite = 0;
        address = 32'h00000014;
        writeData = 32'h99999999;
        @(posedge clk);
        #1;
        
        readMemory(32'h00000014);
        assert32bit(readData, 32'hAAAAAAAA, "No write when MemWrite=0");
        
        $display("--- Test 8: Read from uninitialized location ---");
        readMemory(32'h00000020);
        
        $display("--- Test 9: Write to max valid address ---");
        writeMemory(32'h000003FC, 32'hAAAABBBB);
        readMemory(32'h000003FC);
        assert32bit(readData, 32'hAAAABBBB, "Max address (3FC)");
        
        $display("--- Test 10: Multiple reads same address ---");
        readMemory(32'h00000004);
        assert32bit(readData, 32'hDEADBEEF, "First read");
        
        readMemory(32'h00000004);
        assert32bit(readData, 32'hDEADBEEF, "Second read");
        
        readMemory(32'h00000004);
        assert32bit(readData, 32'hDEADBEEF, "Third read");
        
        $display("--- Test 11: Write then immediate read same address ---");
        writeMemory(32'h00000030, 32'h11112222);
        readMemory(32'h00000030);
        assert32bit(readData, 32'h11112222, "Write-then-read same address");
        
        $display("--- Test 12: Zero value storage ---");
        writeMemory(32'h00000040, 32'h00000000);
        readMemory(32'h00000040);
        assert32bit(readData, 32'h00000000, "Can store zero");
        
        $display("--- Test 13: Misaligned address (should warn) ---");
        $display("Expect warning for misaligned address...");
        readMemory(32'h00000001);
        
        $display("--- Test 14: Another misaligned address (should warn) ---");
        $display("Expect warning for misaligned address...");
        writeMemory(32'h00000003, 32'h12345678);
        
        $display("--- Test 15: Out of bounds read (should warn) ---");
        $display("Expect warning for out of bounds...");
        readMemory(32'h00000400);
        
        $display("--- Test 16: Out of bounds write (should warn) ---");
        $display("Expect warning for out of bounds...");
        writeMemory(32'hFFFFFFFC, 32'h12345678);
        
        $display("================================");
        $display("Score: %0d/%0d", passed, passed+failed);
        
        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("%0d tests failed", failed);
            
        $finish;
    end
endmodule