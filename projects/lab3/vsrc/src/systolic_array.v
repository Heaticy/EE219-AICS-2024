`timescale 1ns / 1ps

`timescale 1ns / 1ps

module FIFO #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_LEN = 8
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] fifo [0:FIFO_LEN-1];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (integer i = 0; i < FIFO_LEN; i = i + 1) begin
            fifo[i] <= 0;
        end
    end else begin
        fifo[0] <= data_in;
        for (integer i = 1; i < FIFO_LEN; i = i + 1) begin
            fifo[i] <= fifo[i-1];
        end
    end
end

assign data_out = fifo[FIFO_LEN-1];

endmodule

module systolic_array#(
    parameter M           = 5,
    parameter N           = 3,
    parameter K           = 4,
    parameter DATA_WIDTH  = 32
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH*M-1:0] X,  // Input feature map (vector)
    input [DATA_WIDTH*K-1:0] W,  // Input weight matrix (vector)
    output reg [DATA_WIDTH*M*K-1:0] Y,  // Output result
    output done  // Done signal
);

reg [31:0] count;

// Declare wires for interconnecting PEs
wire [DATA_WIDTH-1:0] x_wire [0:M-1][0:K-1];
wire [DATA_WIDTH-1:0] w_wire [0:M-1][0:K-1];
wire [DATA_WIDTH-1:0] y_wire [0:M-1][0:K-1];

genvar i, j;
generate
    for (i = 1; i < M; i = i + 1) begin : row
        FIFO #(
            .DATA_WIDTH(DATA_WIDTH),
            .FIFO_LEN(i)
        ) fifo_inst (
            .clk(clk),
            .rst_n(rst_n),
            .data_in( X[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
            .data_out(x_wire[i][0])
        );
    end
    for (i = 1; i < K; i = i + 1) begin : col
        FIFO #(
            .DATA_WIDTH(DATA_WIDTH),
            .FIFO_LEN(i)
        ) fifo_inst (
            .clk(clk),
            .rst_n(rst_n),
            .data_in( W[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]),
            .data_out(w_wire[0][i])
        );
    end
endgenerate


// Instantiate the systolic array using generate

generate
    for (i = 0; i < M; i = i + 1) begin : row
        for (j = 0; j < K; j = j + 1) begin : col
            pe #(
                .DATA_WIDTH(DATA_WIDTH)
            ) pe_inst (
                .clk(clk),
                .rst(rst_n),
                // Input X: the first column gets input from the external X signal, others get from previous column
                .x_in((i == 0) ? X[DATA_WIDTH - 1:0] : x_wire[i][j]),
                // Input W: the first row gets input from the external W signal, others get from the previous row
                .w_in((j == 0) ? W[DATA_WIDTH - 1:0] : w_wire[i][j]),
                // Output signals to be passed to the next PE
                .x_out(x_wire[i][j]),
                .w_out(w_wire[i][j]),
                .y_out(y_wire[i][j])
            );
        end
    end
endgenerate

// Output logic: Collect the results from the last PEs in each row
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        Y <= 0;
    end else begin
        integer m, k;
        for (m = 0; m < M; m = m + 1) begin
            for (k = 0; k < K; k = k + 1) begin
                Y[DATA_WIDTH * (m * K + k + 1) - 1 -: DATA_WIDTH] <= y_wire[m][k];
            end
        end
    end
end

// Counter to simulate done signal after certain cycles
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end

assign done = (count > M + N + K );

endmodule
