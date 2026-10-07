module Register(
    input  [8:0] D,
    input        reset,
    input        clk,
    input        load,
    output reg [8:0] Q
);
    always @(posedge clk or negedge reset) begin
        if (!reset)
            Q <= 9'b0;
        else if (load)
            Q <= D;
    end
endmodule
