module MUX3(
    input  [8:0] A,
    input  [8:0] B,
    input  [8:0] C,
    input  [1:0] S,
    output reg [8:0] Y
);
    always @(*) begin
        case (S)
            2'b00: Y = A;
            2'b01: Y = B;
            2'b10: Y = C;
            default: Y = A;
        endcase
    end
endmodule
