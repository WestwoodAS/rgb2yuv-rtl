module Add(
    input  signed [8:0] A,
    input  signed [8:0] B,
    output signed [8:0] Add
);
    assign Add = A + B;
endmodule
