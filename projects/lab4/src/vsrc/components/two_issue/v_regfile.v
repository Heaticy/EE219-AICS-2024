// =======================================
// You need to finish this module
// =======================================

module v_regfile #(
    parameter VREG_DW    = 256,
    parameter VREG_AW    = 5
)(
    input                       clk,
    input                       rst,

    input                       vwb_en_i,
    input       [VREG_AW-1:0]   vwb_addr_i,
    input       [VREG_DW-1:0]   vwb_data_i,

    input                       vs1_en_i,
    input       [VREG_AW-1:0]   vs1_addr_i,
    output reg  [VREG_DW-1:0]   vs1_data_o,

    input                       vs2_en_i,
    input       [VREG_AW-1:0]   vs2_addr_i,
    output reg  [VREG_DW-1:0]   vs2_data_o
);

integer i;

reg [VREG_DW-1:0] vregfile [2**VREG_AW-1:0] ;

always @(posedge clk ) begin
    if ( rst == 1'b1 ) begin
        for(i=0; i<2**VREG_AW; i=i+1) begin
            vregfile[ i ] <= {(VREG_DW){1'b0}} ;
        end
    end else begin
        if ( (vwb_en_i == 1'b1) && (vwb_addr_i != 0) ) begin
            vregfile[ vwb_addr_i ] <= vwb_data_i ;
        end 
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        vs1_data_o = {(VREG_DW){1'b0}} ;
    end else begin
        if ( vs1_en_i ) begin
            vs1_data_o = vregfile[ vs1_addr_i ] ;
        end else begin
            vs1_data_o = {(VREG_DW){1'b0}} ;
        end
    end
end

always @(*) begin
    if( rst == 1'b1 ) begin
        vs2_data_o = {(VREG_DW){1'b0}} ;
    end else begin
        if ( vs2_en_i ) begin
            vs2_data_o = vregfile[ vs2_addr_i ] ;
        end else begin
            vs2_data_o = {(VREG_DW){1'b0}} ;
        end
    end
end



endmodule
