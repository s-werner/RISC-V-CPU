`timescale 1ns / 1ps

module register_file_tb;
    reg clk;
    reg we;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] wd;
    
    wire [31:0] rd1, rd2;
    
    integer passed = 0;
    integer failed = 0;
    
    register_file uut (
        .clk(clk),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
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
    
    task writeRegister;
        input [4:0] reg_addr;
        input [31:0] data;
        begin
            @(negedge clk);
            we = 1;
            rd = reg_addr;
            wd = data;
            @(posedge clk);
            #1;
            we = 0;
        end
    endtask
    
    task readRegisters;
        input [4:0] addr1;
        input [4:0] addr2;
        begin
            @(negedge clk);
            rs1 = addr1;
            rs2 = addr2;
            #1;
        end
    endtask
    
    initial begin
        $display("=== Register File Test Suite ===");
        
        clk = 0;
        we = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;
        
        #10;
        
        $display("--- Test 1: x0 always reads zero ---");
        readRegisters(0, 0);
        assert32bit(rd1, 32'h00000000, "x0 initial read port 1");
        assert32bit(rd2, 32'h00000000, "x0 initial read port 2");
        
        $display("--- Test 2: Write to x0 should be ignored ---");
        writeRegister(0, 32'hDEADBEEF);
        readRegisters(0, 0);
        assert32bit(rd1, 32'h00000000, "x0 stays zero after write attempt");
        
        $display("--- Test 3: Write and read single register ---");
        writeRegister(5, 32'h12345678);
        readRegisters(5, 0);
        assert32bit(rd1, 32'h12345678, "Read from x5");
        assert32bit(rd2, 32'h00000000, "x0 still zero");
        
        $display("--- Test 4: Write multiple registers ---");
        writeRegister(1, 32'hAAAAAAAA);
        writeRegister(2, 32'h55555555);
        writeRegister(3, 32'hFFFF0000);
        
        readRegisters(1, 2);
        assert32bit(rd1, 32'hAAAAAAAA, "Read from x1");
        assert32bit(rd2, 32'h55555555, "Read from x2");
        
        readRegisters(3, 5);
        assert32bit(rd1, 32'hFFFF0000, "Read from x3");
        assert32bit(rd2, 32'h12345678, "Read from x5 (previous value)");
        
        $display("--- Test 5: Overwrite existing register ---");
        writeRegister(5, 32'hCAFEBABE);
        readRegisters(5, 5);
        assert32bit(rd1, 32'hCAFEBABE, "x5 updated value port 1");
        assert32bit(rd2, 32'hCAFEBABE, "x5 updated value port 2");
        
        $display("--- Test 6: Write enable control ---");
        we = 0;
        rd = 10;
        wd = 32'h99999999;
        @(posedge clk);
        #1;
        readRegisters(10, 0);
        assert32bit(rd1, 32'h00000000, "x10 not written when we=0");
        we = 0;
        
        $display("--- Test 7: All registers independent ---");
        writeRegister(10, 32'h11111111);
        writeRegister(20, 32'h22222222);
        writeRegister(30, 32'h33333333);
        
        readRegisters(10, 20);
        assert32bit(rd1, 32'h11111111, "x10 independent");
        assert32bit(rd2, 32'h22222222, "x20 independent");
        
        readRegisters(30, 1);
        assert32bit(rd1, 32'h33333333, "x30 independent");
        assert32bit(rd2, 32'hAAAAAAAA, "x1 unchanged");
        
        $display("--- Test 8: Edge registers (x31) ---");
        writeRegister(31, 32'hFFFFFFFF);
        readRegisters(31, 0);
        assert32bit(rd1, 32'hFFFFFFFF, "x31 works");
        assert32bit(rd2, 32'h00000000, "x0 still zero");
        
        $display("--- Test 9: Read two different registers simultaneously ---");
        readRegisters(1, 31);
        assert32bit(rd1, 32'hAAAAAAAA, "Dual read port 1");
        assert32bit(rd2, 32'hFFFFFFFF, "Dual read port 2");
        
        $display("--- Test 10: Zero values in non-zero registers ---");
        writeRegister(15, 32'h00000000);
        readRegisters(15, 0);
        assert32bit(rd1, 32'h00000000, "x15 can hold zero");
        assert32bit(rd2, 32'h00000000, "x0 still zero");
        
        writeRegister(15, 32'h12345678);
        readRegisters(15, 0);
        assert32bit(rd1, 32'h12345678, "x15 can change from zero");
        
        $display("================================");
        $display("Score: %0d/%0d", passed, passed+failed);
        
        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("%0d tests failed", failed);
            
        $finish;
    end
endmodule