`timescale 1ns / 1ps

`timescale 1ns / 1ps

module systolic_array#(
    parameter M           = 5,
    parameter N           = 3,
    parameter K           = 4,
    parameter DATA_WIDTH  = 32
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH*M-1:0] X,
    input [DATA_WIDTH*K-1:0] W,
    output reg [DATA_WIDTH*M*K-1:0] Y,
    output done
);


genvar i, j;
generate
    for (i = 0; i < M; i = i + 1) begin : row
        for (j = 0; j < K; j = j + 1) begin : col
            pe #(
                .DATA_WIDTH(DATA_WIDTH)
            ) pe_inst (
                .clk(clk),
                .rst(rst_n),
                .x_in((j == 0) ? X[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] : row[i].col[j-1].pe_inst.x_out),
                .w_in((i == 0) ? W[DATA_WIDTH*(j+1)-1:DATA_WIDTH*j] : row[i-1].col[j].pe_inst.w_out),
                .x_out(row[i].col[j].pe_inst.x_out),
                .w_out(row[i].col[j].pe_inst.w_out),
                .y_out(row[i].col[j].pe_inst.y_out)
            );
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Y <= 0;
    end
    else begin
        integer m, k;
        for (m = 0; m < M; m = m + 1) begin
            for (k = 0; k < K; k = k + 1) begin
                Y[DATA_WIDTH*(m*K + k + 1)-1:DATA_WIDTH*(m*K + k)] <= row[m].col[k].pe_inst.y_out;
            end
        end
    end
end


reg count;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
    end
    else begin
        count <= count + 1;
    end
end

assign done = (count == K+N+M);

endmodule