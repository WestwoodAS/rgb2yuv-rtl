module ROM(
    input        clk,
    input  [2:0] addr,
    output reg [8:0] data
);
    always @(*) begin
        case (addr)
            3'b000: data = 9'b001001100; //  0.299  ~=  76/256
            3'b001: data = 9'b010010110; //  0.587  ~= 150/256
            3'b010: data = 9'b111010101; // -0.169  ~= -43/256
            3'b011: data = 9'b110101100; // -0.331  ~= -84/256
            3'b100: data = 9'b010000000; //  0.5    = 128/256
            3'b101: data = 9'b110010101; // -0.419  ~= -107/256
            3'b110: data = 9'b111101100; // -0.081  ~= -20/256
            3'b111: data = 9'b000011101; //  0.114  ~=  29/256
            default: data = 9'b0;
        endcase
    end
endmodule
