`timescale 1ns / 1ps
module register_file(
    input wire clk,
    input wire we,
    input [4:0] rs1, rs2, rd,
    input wire [31:0] wd,
    output reg [31:0] rd1, rd2
    );
    
    reg [31:0] registers [31:0];   
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 0;
    end
    
    always @(*) begin
        rd1 = rs1 == 5'b0 ? 32'b0 : registers[rs1];
        rd2 = rs2 == 5'b0 ? 32'b0 : registers[rs2];
    end
    
    always @(posedge clk) begin
        if (we && rd != 0) begin
            registers[rd] = wd;
        end
    end
    
endmodule