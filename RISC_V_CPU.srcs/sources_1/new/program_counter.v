`timescale 1ns / 1ps

module program_counter(
    input wire clk,
    input wire reset,
    input wire PCSrc,
    input [31:0] PCTarget,
    output reg [31:0] PC 
    );
    
    initial PC = 32'b0;
    
    always @(posedge clk) begin
        if (reset == 1)
            PC = 32'b0;
        else if (PCSrc == 1) 
            PC = PCTarget;
        else
            PC = PC + 4;
    end 
endmodule
