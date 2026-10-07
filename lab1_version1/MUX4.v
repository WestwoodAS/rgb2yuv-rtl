module MUX4(
    input  [8:0] A,
    input  [8:0] B,
    input  [8:0] C,
    input  [8:0] D,
    input  [1:0] S,
    output reg [8:0] Y
);
    always @(*) begin
        case (S)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
            2'b11: Y = D;
        endcase
    end
endmodule
