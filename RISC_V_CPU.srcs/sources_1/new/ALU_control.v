`timescale 1ns / 1ps

module ALU_control(
        input [1:0] ALUop,
        input [2:0] funct3,
        input [6:0] funct7,
        output reg [3:0] ALUControl
    );
    
    always @(*) begin
        case(ALUop)
            2'b00: ALUControl = 4'b0010;                        // lw/sw
            2'b01: ALUControl = 4'b0110;                        // beq
            2'b10: begin                                        // R-type
                case(funct3)
                    3'b000: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0010;   // add
                            7'b0100000: ALUControl = 4'b0110;   // subtract
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end     
                    
                    3'b001: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0100;   // sll
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end
                    
                    3'b010: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0111;   // slt
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end
                    
                    3'b011: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b1000;   // sltu
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end
                    
                    3'b100: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0011;   // xor
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end
                    
                    3'b101: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0101;   // srl
                            7'b0100000: ALUControl = 4'b1001;   // sra/srai
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end
                    
                    3'b110: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0001;   // or
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end  
                    
                    3'b111: begin
                        case(funct7)
                            7'b0000000: ALUControl = 4'b0000;   // and
                            default: begin
                                $warning("Unsupported funct7=%b for funct3=%b", funct7, funct3);
                                ALUControl = 4'b0000;
                            end        
                        endcase
                    end       
                            
                    default: begin
                        $warning("Unsupported funct3=%b with ALUop=%b", funct3, ALUop);
                        ALUControl = 4'b0000;
                    end                               
                endcase
            end
            default: begin
                $warning("Unsupported ALUop=%b", ALUop);
                ALUControl = 4'b0000;
            end                   
        endcase
    end
endmodule
