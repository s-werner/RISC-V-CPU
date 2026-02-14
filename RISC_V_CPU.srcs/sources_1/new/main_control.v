`timescale 1ns / 1ps

module main_control(
    input [6:0] opcode,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg MemToReg,
    output reg Branch,
    output reg [1:0] ALUop
    );
    
   always @(*) begin
    case(opcode)
        7'b0110011 : begin // R-type (ALU)
            MemRead = 1'b0;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
            MemToReg = 1'b0;
            Branch =  1'b0;
            ALUop = 2'b10;
        end
        7'b0010011 : begin // I-type (ALU)
            MemRead = 1'b0;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            MemToReg = 1'b0;
            Branch = 1'b0;
            ALUop = 2'b10;
        end
        7'b0000011 : begin // Load
            MemRead = 1'b1;
            MemWrite = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1; 
            MemToReg = 1'b1;
            Branch = 1'b0;
            ALUop = 2'b00;
        end
        7'b0100011 : begin // Store
            MemRead = 1'b0;
            MemWrite = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b0; 
            MemToReg = 1'b0; // unused
            Branch = 1'b0;
            ALUop = 2'b00;
        end
        7'b1100011 : begin // Branch
            MemRead = 1'b0;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0; 
            MemToReg = 1'b0;
            Branch = 1'b1;
            ALUop = 2'b01;
        end
        default: begin
            MemRead = 1'b0;
            MemWrite = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0; 
            MemToReg = 1'b0;
            Branch = 1'b0;
            ALUop = 2'b00;
        end
    endcase   
   end
endmodule
