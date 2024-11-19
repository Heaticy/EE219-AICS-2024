`timescale 1ns / 1ps

module pe #(
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] x_in,
    input [DATA_WIDTH-1:0] w_in,
    output reg [DATA_WIDTH-1:0] x_out,
    output reg [DATA_WIDTH-1:0] w_out,
    output reg [DATA_WIDTH-1:0] y_out
);

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        x_out <= 0;
        w_out <= 0;
        y_out <= 0;
    end
    else begin
        x_out <= x_in;
        w_out <= w_in;
        y_out <= y_out + x_in * w_in;
    end
end

endmodule