`timescale 1ns/1ps
module Datapath(
    input  [8:0] inportR,
    input  [8:0] inportG,
    input  [8:0] inportB,
    input  [21:0] control,
    input  clk,
    input  rst_n,
    input  done,
    output [8:0] outportY,
    output [8:0] outportU,
    output [8:0] outportV
);
    wire [8:0] M1_OUT, M2_OUT, M3_OUT, M4_OUT, M5_OUT, M6_OUT, M7_OUT, M8_OUT, M9_OUT;
    wire [8:0] Fadd, Fmul, R1, R2, R3, R4, R5, R6, data;

    Register r1(.D(M4_OUT), .reset(rst_n), .clk(clk), .load(control[21]), .Q(R1));
    Register r2(.D(M5_OUT), .reset(rst_n), .clk(clk), .load(control[20]), .Q(R2));
    Register r3(.D(M6_OUT), .reset(rst_n), .clk(clk), .load(control[19]), .Q(R3));
    Register r4(.D(M7_OUT), .reset(rst_n), .clk(clk), .load(control[18]), .Q(R4));
    Register r5(.D(M8_OUT), .reset(rst_n), .clk(clk), .load(control[17]), .Q(R5));
    Register r6(.D(M9_OUT), .reset(rst_n), .clk(clk), .load(control[16]), .Q(R6));

    // Main datapath muxes from the lecture slide
    MUX3 M1(.A(R3), .B(R2), .C(R1), .S(control[12:11]), .Y(M1_OUT));
    MUX4 M2(.A(9'b010000000), .B(R5), .C(R4), .D(R1), .S(control[10:9]), .Y(M2_OUT));
    MUX4 M3(.A(R6), .B(R3), .C(R2), .D(R5), .S(control[8:7]), .Y(M3_OUT));

    // Write-back muxes inferred from the register labels on the datapath figure
    MUX2 M4(.A(inportR), .B(Fadd), .S(control[6]),   .Y(M4_OUT));   // r1: R / t10 / U
    MUX3 M5(.A(inportG), .B(Fmul), .C(Fadd), .S(control[5:4]), .Y(M5_OUT)); // r2: G / t3 / t13 / t14 / Y
    MUX2 M6(.A(inportB), .B(Fadd), .S(control[3]),   .Y(M6_OUT));   // r3: B / t16 / V
    MUX2 M7(.A(Fmul),    .B(Fadd), .S(control[2]),   .Y(M7_OUT));   // r4: t1 / t4
    MUX2 M8(.A(Fmul),    .B(Fadd), .S(control[1]),   .Y(M8_OUT));   // r5: t2 / t6 / t8 / t12 / t15
    MUX2 M9(.A(Fmul),    .B(Fadd), .S(control[0]),   .Y(M9_OUT));   // r6: t7 / t9

    Mul FU1(.A(M1_OUT), .B(data), .Mul(Fmul));
    Add FU2(.A(M2_OUT), .B(M3_OUT), .Add(Fadd));
    ROM FU3(.clk(clk), .addr(control[15:13]), .data(data));

    Register r7(.D(R2), .reset(rst_n), .clk(clk), .load(done), .Q(outportY));
    Register r8(.D(R3), .reset(rst_n), .clk(clk), .load(done), .Q(outportV));
    Register r9(.D(R1), .reset(rst_n), .clk(clk), .load(done), .Q(outportU));
endmodule
