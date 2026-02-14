`timescale 1ns / 1ps

module cpu(
    input wire clk,
    input wire reset,
    output wire [31:0] PC_out
    );
    
    wire MemRead, MemWrite, PCSrc, ALUSrc, RegWrite, MemToReg, Branch;
    wire [1:0] ALUop;
    wire [31:0] instruction, pc, PCTarget;
    wire [6:0] opcode = instruction[6:0];
    
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    wire [3:0] ALUControl;

    assign PC_out = pc;
    
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .PCSrc(PCSrc),
        .PCTarget(PCTarget),
        .PC(pc)
    );
    
    instruction_memory instr_mem (
        .address(pc),
        .instruction(instruction)
    );
    
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
    
    ALU_control alu_control (
        .ALUop(ALUop),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );
    
   
    
    wire [4:0] readReg1 = instruction[19:15];
    wire [4:0] readReg2 = instruction[24:20];
    wire [4:0] regDest = instruction[11:7];    
    
    wire [31:0] rd1, rd2, ALUResult;
    
    wire [31:0] wd;
    assign wd = MemToReg ? dataReadData : ALUResult;
    
    register_file reg_file (
        .clk(clk),
        .we(RegWrite),
        .rs1(readReg1),
        .rs2(readReg2),
        .rd(regDest),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );
   
    wire [31:0] aluB;
    wire [31:0] immediate;
    immediate_gen imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );
    
    assign aluB = ALUSrc ? immediate : rd2;
    alu alu (
        .A(rd1),
        .B(aluB),
        .ALUControl(ALUControl),
        .Result(ALUResult)
    );
   
    wire [31:0] dataReadData;
    data_memory data_mem (
        .clk(clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(ALUResult),
        .writeData(rd2),
        .readData(dataReadData)
    );
    
    wire ALUZero;
    assign ALUZero = ALUResult == 0;
    assign PCTarget = pc + immediate;
    assign PCSrc = Branch & ALUZero;
    
endmodule
