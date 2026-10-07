module Mul(
    input  signed [8:0] A,
    input  signed [8:0] B,
    output signed [8:0] Mul
);
    wire signed [17:0] product;
    assign product = A * B;
    assign Mul = product[16:8];
endmodule
