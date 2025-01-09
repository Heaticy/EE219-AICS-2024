// =======================================
// You need to finish this module
// =======================================

module mi3_regfile #(
    parameter REG_DW    = 32,
    parameter REG_AW    = 5
)(
    input                       clk,
    input                       rst,

    input                       is1_wb_en_i,
    input       [REG_AW-1:0]    is1_wb_addr_i,
    input       [REG_DW-1:0]    is1_wb_data_i,
    input                       is1_rs1_en_i,
    input       [REG_AW-1:0]    is1_rs1_addr_i,
    output reg  [REG_DW-1:0]    is1_rs1_data_o,
    input                       is1_rs2_en_i,
    input       [REG_AW-1:0]    is1_rs2_addr_i,
    output reg  [REG_DW-1:0]    is1_rs2_data_o,

    input                       is2_rs1_en_i,
    input       [REG_AW-1:0]    is2_rs1_addr_i,
    output reg  [REG_DW-1:0]    is2_rs1_data_o,

    input                       is3_rs1_en_i,
    input       [REG_AW-1:0]    is3_rs1_addr_i,
    output reg  [REG_DW-1:0]    is3_rs1_data_o
);

integer i ;

reg [REG_DW-1:0] regfile [2**REG_AW-1:0] ;

always @(posedge clk ) begin
    if ( rst == 1'b1 ) begin
        for(i=0; i<2**REG_AW; i=i+1) begin
            regfile[ i ] <= {(REG_DW){1'b0}} ;
        end
    end else begin
        if ( (is1_wb_en_i == 1'b1) && (is1_wb_addr_i != 0) ) begin
            regfile[ is1_wb_addr_i ] <= is1_wb_data_i ;
        end 
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is1_rs1_data_o = {(REG_DW){1'b0}} ;
    end else begin
        if ( is1_rs1_en_i ) begin
            is1_rs1_data_o = regfile[ is1_rs1_addr_i ] ;
        end else begin
            is1_rs1_data_o = {(REG_DW){1'b0}} ;
        end
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is1_rs2_data_o = {(REG_DW){1'b0}} ;
    end else begin
        if ( is1_rs2_en_i ) begin
            is1_rs2_data_o = regfile[ is1_rs2_addr_i ] ;
        end else begin
            is1_rs2_data_o = {(REG_DW){1'b0}} ;
        end
    end 
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is2_rs1_data_o = {(REG_DW){1'b0}} ;
    end else begin
        if ( is2_rs1_en_i ) begin
            is2_rs1_data_o = regfile[ is2_rs1_addr_i ] ;
        end else begin
            is2_rs1_data_o = {(REG_DW){1'b0}} ;
        end
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is3_rs1_data_o = {(REG_DW){1'b0}} ;
    end else begin
        if ( is3_rs1_en_i ) begin
            is3_rs1_data_o = regfile[ is3_rs1_addr_i ] ;
        end else begin
            is3_rs1_data_o = {(REG_DW){1'b0}} ;
        end
    end
end

endmodule
