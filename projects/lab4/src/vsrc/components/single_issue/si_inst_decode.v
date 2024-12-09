// =======================================
// You need to finish this module
// =======================================


`include "define_rv32im.v"

module si_inst_decode #(
    parameter INST_DW   = 32,
    parameter INST_AW   = 32,
    parameter MEM_AW    = 32,
    parameter REG_DW    = 32,
    parameter REG_AW    = 5,
    parameter ALUOP_DW  = 5

) (
    input                   clk,
    input                   rst,
    // instruction
    input   [INST_DW-1:0]   inst_i,
    // regfile
    output  reg             rs1_en_o,
    output  reg[REG_AW-1:0]    rs1_addr_o,
    input   [REG_DW-1:0]    rs1_dout_i,
    output  reg             rs2_en_o,
    output  [REG_AW-1:0]    rs2_addr_o,
    input   [REG_DW-1:0]    rs2_dout_i,
    // alu
    output  reg[ALUOP_DW-1:0]  alu_opcode_o,
    output  reg[REG_DW-1:0]    operand_1_o,
    output  reg[REG_DW-1:0]    operand_2_o,
    output                  branch_en_o,
    output  reg[INST_AW-1:0]   branch_offset_o,
    output                  jump_en_o,
    output  reg[INST_AW-1:0]   jump_offset_o,
    // mem-access
    output  reg             mem_ren_o,
    output  reg             mem_wen_o,
    output  [INST_DW-1:0]   mem_din_o,
    // write-back
    output  reg             id_wb_en_o,
    output  reg             id_wb_sel_o,
    output  [REG_AW-1:0]    id_wb_addr_o 
);

localparam ALU_OP_NOP   = 5'd0 ;
localparam ALU_OP_ADD   = 5'd1 ;
localparam ALU_OP_MUL   = 5'd2 ;
localparam ALU_OP_BNE   = 5'd3 ;
localparam ALU_OP_JAL   = 5'd4 ;
localparam ALU_OP_LUI   = 5'd5 ;
localparam ALU_OP_AUIPC = 5'd6 ;
localparam ALU_OP_AND   = 5'd7 ;
localparam ALU_OP_SLL   = 5'd8 ;
localparam ALU_OP_SLT   = 5'd9 ;
localparam ALU_OP_BLT   = 5'd10 ;

wire [6:0] opcode = inst_i[6:0];
wire [2:0] funct3 = inst_i[14:12];
wire [6:0] funct7 = inst_i[31:25];
wire [4:0] rs1 = inst_i[19:15];
wire [4:0] rs2 = inst_i[24:20];
wire [4:0] rd = inst_i[11:7];
reg [31:0] imm_gen;
assign rs1_en_o = 1'b1;
assign rs1_addr_o = rs1;
assign rs2_addr_o = rs2;
assign id_wb_addr_o = rd;
assign branch_offset_o = imm_gen;
assign jump_offset_o = imm_gen;
assign mem_din_o = rs2_dout_i;

always@(*)begin
    case(opcode)
        7'b0110011: begin//R-type
            rs2_en_o = 1'b1;
            operand_1_o = rs1_dout_i;
            operand_2_o = rs2_dout_i;
            mem_ren_o = 1'b0;
            mem_wen_o = 1'b0;
            id_wb_en_o = 1'b1;
            id_wb_sel_o = 1'b0;
            imm_gen = 32'h0;
            branch_en_o = 1'b0;
            jump_en_o = 1'b0;
            case(funct3) 
                3'b000: begin //ADD, MUL
                    case(funct7)
                        7'b0000000: alu_opcode_o = ALU_OP_ADD;
                        7'b0000001: alu_opcode_o = ALU_OP_MUL;
                        default: alu_opcode_o = ALU_OP_NOP;
                    endcase
                end
                3'b111: alu_opcode_o = ALU_OP_AND;//AND
                3'b001: alu_opcode_o = ALU_OP_SLL; //SLL
                default: alu_opcode_o = ALU_OP_NOP;
            endcase
        end
        7'b0010011: begin//I-type but not load
            rs2_en_o = 1'b0;
            operand_1_o = rs1_dout_i;
            operand_2_o = imm_gen;
            mem_ren_o = 1'b0;
            mem_wen_o = 1'b0;
            id_wb_en_o = 1'b1;
            id_wb_sel_o = 1'b0;
            branch_en_o = 1'b0;
            jump_en_o = 1'b0;
            case(funct3)
                3'b000: begin//ADDI
                    alu_opcode_o = ALU_OP_ADD;
                    imm_gen = {{20{inst_i[31]}}, inst_i[31:20]};
                end
                3'b010: begin//SLLI
                    alu_opcode_o = ALU_OP_SLT;
                    imm_gen = {{27{1'b0}}, inst_i[24:20]};
                end
                default: begin
                    alu_opcode_o = ALU_OP_NOP;
                    imm_gen = 32'h0;
                end
            endcase
        end
        7'b0000011: begin//I-type load
            rs2_en_o = 1'b0;
            operand_1_o = rs1_dout_i;
            operand_2_o = imm_gen;
            mem_ren_o = 1'b1;
            mem_wen_o = 1'b0;
            id_wb_en_o = 1'b1;
            id_wb_sel_o = 1'b1;
            branch_en_o = 1'b0;
            jump_en_o = 1'b0;
            case(funct3)
                3'b010: begin//LW
                    alu_opcode_o = ALU_OP_ADD;
                    imm_gen = {{20{1'b0}}, inst_i[31:20]};
                end
                default: begin
                    alu_opcode_o = ALU_OP_NOP;
                    imm_gen = 32'h0;
                end
            endcase
        end
        7'b0100011: begin//S-type
            rs2_en_o = 1'b1;
            operand_1_o = rs1_dout_i;
            operand_2_o = imm_gen;
            mem_ren_o = 1'b0;
            mem_wen_o = 1'b1;
            id_wb_en_o = 1'b0;
            id_wb_sel_o = 1'b0;
            branch_en_o = 1'b0;
            jump_en_o = 1'b0;
            case(funct3)
                3'b010: begin //SW
                    alu_opcode_o = ALU_OP_ADD;
                    imm_gen = {{20{1'b0}}, inst_i[31:25], inst_i[11:7]};
                end
                default: begin
                    alu_opcode_o = ALU_OP_NOP;
                    imm_gen = 32'h0;
                end
            endcase
        end
        7'b1100011: begin //B-type
            rs2_en_o = 1'b1;
            operand_1_o = rs1_dout_i;
            operand_2_o = rs2_dout_i;
            mem_ren_o = 1'b0;
            mem_wen_o = 1'b0;
            id_wb_en_o = 1'b0;
            id_wb_sel_o = 1'b0;
            branch_en_o = 1'b1;
            jump_en_o = 1'b0;
            case(funct3)
                3'b001: begin //BNE
                    alu_opcode_o = ALU_OP_BNE;
                    imm_gen = {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
                3'b100: begin //BLT
                    alu_opcode_o = ALU_OP_BLT;
                    imm_gen = {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
                default: begin
                    alu_opcode_o = ALU_OP_NOP;
                    imm_gen = 32'h0;
                end
            endcase
        end
        7'b0110111: begin //U-type LUI
            rs2_en_o = 1'b0;
            operand_1_o = rs1_dout_i;
            operand_2_o = imm_gen;
            mem_ren_o = 1'b0;
            mem_wen_o = 1'b0;
            id_wb_en_o = 1'b1;
            id_wb_sel_o = 1'b0;
            branch_en_o = 1'b0;
            jump_en_o = 1'b0;
            alu_opcode_o = ALU_OP_LUI;
            imm_gen = {inst_i[31:12], {12{1'b0}}};
        end
        7'b1101111: begin //J-type JAL
            rs2_en_o = 1'b0;
            operand_1_o = rs1_dout_i;
            operand_2_o = imm_gen;
            mem_ren_o = 1'b0;
            mem_wen_o = 1'b0;
            id_wb_en_o = 1'b1;
            id_wb_sel_o = 1'b0;
            branch_en_o = 1'b0;
            jump_en_o = 1'b1;
            alu_opcode_o = ALU_OP_JAL;
            imm_gen = {{11{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
        end
        default: begin
            rs2_en_o = 1'b0;
            operand_1_o = 32'h0;
            operand_2_o = 32'h0;
            mem_ren_o = 1'b0;
            mem_wen_o = 1'b0;
            id_wb_en_o = 1'b0;
            id_wb_sel_o = 1'b0;
            branch_en_o = 1'b0;
            jump_en_o = 1'b0;
            alu_opcode_o = ALU_OP_NOP;
            imm_gen = 32'h0;
        end
    endcase
end

endmodule 
