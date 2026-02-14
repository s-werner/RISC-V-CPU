`timescale 1ns / 1ps

module cpu(
    input wire clk,
    input wire reset,
    output wire [31:0] PC_out
    );
    
    // Control signals
    wire MemRead, MemWrite, PCSrc, ALUSrc, RegWrite, MemToReg, Branch;
    wire [1:0] ALUop;
    wire [3:0] ALUControl;
    
    // Datapath signals
    wire [31:0] pc, instruction, immediate;
    wire [31:0] rd1, rd2, ALUResult, dataReadData, wd;
    wire [31:0] aluB, PCTarget;
    wire ALUZero;
    
    // Instruction fields
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = (opcode == 7'b0110011) ? instruction[31:25] : 7'b0000000;
    wire [4:0] readReg1 = instruction[19:15];
    wire [4:0] readReg2 = instruction[24:20];
    wire [4:0] regDest = instruction[11:7];
    
    // ========== Datapath Logic ==========
    assign PC_out = pc;
    assign aluB = ALUSrc ? immediate : rd2;
    assign wd = MemToReg ? dataReadData : ALUResult;
    assign ALUZero = (ALUResult == 0);
    assign PCTarget = pc + immediate;
    assign PCSrc = Branch & ALUZero;
    
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
   
    immediate_gen imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );
    
    alu alu (
        .A(rd1),
        .B(aluB),
        .ALUControl(ALUControl),
        .Result(ALUResult)
    );
   
    data_memory data_mem (
        .clk(clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .address(ALUResult),
        .writeData(rd2),
        .readData(dataReadData)
    );
endmodule
