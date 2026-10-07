module MUX2(
    input  [8:0] A,
    input  [8:0] B,
    input        S,
    output reg [8:0] Y
);
    always @(*) begin
        case (S)
            1'b0: Y = A;
            1'b1: Y = B;
        endcase
    end
endmodule
