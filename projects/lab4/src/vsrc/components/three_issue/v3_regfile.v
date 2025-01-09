// =======================================
// You need to finish this module
// =======================================

module v3_regfile #(
    parameter VREG_DW    = 256,
    parameter VREG_AW    = 5
)(
    input                       clk,
    input                       rst,

    input                       is1_vwb_en_i,
    input       [VREG_AW-1:0]   is1_vwb_addr_i,
    input       [VREG_DW-1:0]   is1_vwb_data_i,

    input                       is1_vs1_en_i,
    input       [VREG_AW-1:0]   is1_vs1_addr_i,
    output reg  [VREG_DW-1:0]   is1_vs1_data_o,

    input                       is1_vs2_en_i,
    input       [VREG_AW-1:0]   is1_vs2_addr_i,
    output reg  [VREG_DW-1:0]   is1_vs2_data_o,

    input                       is2_vwb_en_i,
    input       [VREG_AW-1:0]   is2_vwb_addr_i,
    input       [VREG_DW-1:0]   is2_vwb_data_i,

    input                       is2_vs1_en_i,
    input       [VREG_AW-1:0]   is2_vs1_addr_i,
    output reg  [VREG_DW-1:0]   is2_vs1_data_o,

    input                       is2_vs2_en_i,
    input       [VREG_AW-1:0]   is2_vs2_addr_i,
    output reg  [VREG_DW-1:0]   is2_vs2_data_o
);

integer i;

reg [VREG_DW-1:0] vregfile [2**VREG_AW-1:0] ;

always @(posedge clk ) begin
    if ( rst == 1'b1 ) begin
        for(i=0; i<2**VREG_AW; i=i+1) begin
            vregfile[ i ] <= {(VREG_DW){1'b0}} ;
        end
    end else begin
        if ( (is1_vwb_en_i == 1'b1) && (is1_vwb_addr_i != 0) ) begin
            vregfile[ is1_vwb_addr_i ] <= is1_vwb_data_i ;
        end 
        if ( (is2_vwb_en_i == 1'b1) && (is2_vwb_addr_i != 0) ) begin
            vregfile[ is2_vwb_addr_i ] <= is2_vwb_data_i ;
        end 
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is1_vs1_data_o = {(VREG_DW){1'b0}} ;
    end else begin
        if ( is1_vs1_en_i ) begin
            is1_vs1_data_o = vregfile[ is1_vs1_addr_i ] ;
        end else begin
            is1_vs1_data_o = {(VREG_DW){1'b0}} ;
        end
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is1_vs2_data_o = {(VREG_DW){1'b0}} ;
    end else begin
        if ( is1_vs2_en_i ) begin
            is1_vs2_data_o = vregfile[ is1_vs2_addr_i ] ;
        end else begin
            is1_vs2_data_o = {(VREG_DW){1'b0}} ;
        end
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is2_vs1_data_o = {(VREG_DW){1'b0}} ;
    end else begin
        if ( is2_vs1_en_i ) begin
            is2_vs1_data_o = vregfile[ is2_vs1_addr_i ] ;
        end else begin
            is2_vs1_data_o = {(VREG_DW){1'b0}} ;
        end
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        is2_vs2_data_o = {(VREG_DW){1'b0}} ;
    end else begin
        if ( is2_vs2_en_i ) begin
            is2_vs2_data_o = vregfile[ is2_vs2_addr_i ] ;
        end else begin
            is2_vs2_data_o = {(VREG_DW){1'b0}} ;
        end
    end
end

endmodule
