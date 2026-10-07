`timescale 1ns/1ps
module Datapath(
    input  [1:0] phase,
    input  clk,
    input  rst_n,
    input  start,
    input  signed [8:0] inportR,
    input  signed [8:0] inportG,
    input  signed [8:0] inportB,
    output reg done,
    output reg signed [8:0] outportY,
    output reg signed [8:0] outportU,
    output reg signed [8:0] outportV
);
    localparam signed [8:0] C_YR  = 9'sd76;
    localparam signed [8:0] C_YG  = 9'sd150;
    localparam signed [8:0] C_YB  = 9'sd29;
    localparam signed [8:0] C_UR  = -9'sd43;
    localparam signed [8:0] C_UG  = -9'sd84;
    localparam signed [8:0] C_UB  = 9'sd128;
    localparam signed [8:0] C_VR  = 9'sd128;
    localparam signed [8:0] C_VG  = -9'sd107;
    localparam signed [8:0] C_VB  = -9'sd20;
    localparam signed [8:0] BIAS  = 9'sd128;
    localparam signed [8:0] ZERO  = 9'sd0;

    reg        valid0, valid1;
    reg [2:0]  age0, age1;
    reg        launch_slot;

    reg signed [8:0] r0, g0, b0, t10, t20, t30, t40, t60, t70, t80, t90, t100, t120, t130, t140, t150, t160, y0, u0;
    reg signed [8:0] r1, g1, b1, t11, t21, t31, t41, t61, t71, t81, t91, t101, t121, t131, t141, t151, t161, y1, u1;

    reg signed [8:0] mulA0, mulB0, mulA1, mulB1, mulA2, mulB2;
    reg signed [8:0] addA0, addB0, addA1, addB1, addA2, addB2;
    wire signed [8:0] mulOut0, mulOut1, mulOut2;
    wire signed [8:0] addOut0, addOut1, addOut2;

    Mul M0(.A(mulA0), .B(mulB0), .Mul(mulOut0));
    Mul M1(.A(mulA1), .B(mulB1), .Mul(mulOut1));
    Mul M2(.A(mulA2), .B(mulB2), .Mul(mulOut2));
    Add A0(.A(addA0), .B(addB0), .Add(addOut0));
    Add A1(.A(addA1), .B(addB1), .Add(addOut1));
    Add A2(.A(addA2), .B(addB2), .Add(addOut2));

    always @(*) begin
        mulA0 = ZERO; mulB0 = ZERO;
        mulA1 = ZERO; mulB1 = ZERO;
        mulA2 = ZERO; mulB2 = ZERO;
        addA0 = ZERO; addB0 = ZERO;
        addA1 = ZERO; addB1 = ZERO;
        addA2 = ZERO; addB2 = ZERO;

        case (phase)
            2'd0: begin
                if (start) begin
                    mulA0 = inportR; mulB0 = C_YR;
                    mulA1 = inportG; mulB1 = C_YG;
                    mulA2 = inportB; mulB2 = C_YB;
                end
                if (valid0 && age0 == 3'd3) begin
                    addA0 = t90;  addB0 = t100;
                    addA1 = t120; addB1 = t130;
                    addA2 = t140; addB2 = BIAS;
                end else if (valid1 && age1 == 3'd3) begin
                    addA0 = t91;  addB0 = t101;
                    addA1 = t121; addB1 = t131;
                    addA2 = t141; addB2 = BIAS;
                end
            end
            2'd1: begin
                if (valid0 && age0 == 3'd1) begin
                    mulA0 = r0; mulB0 = C_UR;
                    mulA1 = g0; mulB1 = C_UG;
                    mulA2 = b0; mulB2 = C_UB;
                    addA0 = t10; addB0 = t20;
                end else if (valid1 && age1 == 3'd1) begin
                    mulA0 = r1; mulB0 = C_UR;
                    mulA1 = g1; mulB1 = C_UG;
                    mulA2 = b1; mulB2 = C_UB;
                    addA0 = t11; addB0 = t21;
                end

                if (valid0 && age0 == 3'd4) begin
                    addA1 = t150; addB1 = t160;
                end else if (valid1 && age1 == 3'd4) begin
                    addA1 = t151; addB1 = t161;
                end
            end
            2'd2: begin
                if (valid0 && age0 == 3'd2) begin
                    mulA0 = r0; mulB0 = C_VR;
                    mulA1 = g0; mulB1 = C_VG;
                    mulA2 = b0; mulB2 = C_VB;
                    addA0 = t40; addB0 = t30;
                    addA1 = t60; addB1 = t70;
                    addA2 = t80; addB2 = BIAS;
                end else if (valid1 && age1 == 3'd2) begin
                    mulA0 = r1; mulB0 = C_VR;
                    mulA1 = g1; mulB1 = C_VG;
                    mulA2 = b1; mulB2 = C_VB;
                    addA0 = t41; addB0 = t31;
                    addA1 = t61; addB1 = t71;
                    addA2 = t81; addB2 = BIAS;
                end
            end
            default: begin
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid0 <= 1'b0; valid1 <= 1'b0;
            age0 <= 3'd0; age1 <= 3'd0;
            launch_slot <= 1'b0;
            done <= 1'b0;
            outportY <= ZERO; outportU <= ZERO; outportV <= ZERO;
            r0 <= ZERO; g0 <= ZERO; b0 <= ZERO; t10 <= ZERO; t20 <= ZERO; t30 <= ZERO; t40 <= ZERO; t60 <= ZERO; t70 <= ZERO; t80 <= ZERO; t90 <= ZERO; t100 <= ZERO; t120 <= ZERO; t130 <= ZERO; t140 <= ZERO; t150 <= ZERO; t160 <= ZERO; y0 <= ZERO; u0 <= ZERO;
            r1 <= ZERO; g1 <= ZERO; b1 <= ZERO; t11 <= ZERO; t21 <= ZERO; t31 <= ZERO; t41 <= ZERO; t61 <= ZERO; t71 <= ZERO; t81 <= ZERO; t91 <= ZERO; t101 <= ZERO; t121 <= ZERO; t131 <= ZERO; t141 <= ZERO; t151 <= ZERO; t161 <= ZERO; y1 <= ZERO; u1 <= ZERO;
        end else begin
            done <= 1'b0;

            case (phase)
                2'd0: begin
                    if (valid0 && age0 == 3'd3) begin
                        u0   <= addOut0;
                        t150 <= addOut1;
                        t160 <= addOut2;
                        age0 <= 3'd4;
                    end
                    if (valid1 && age1 == 3'd3) begin
                        u1   <= addOut0;
                        t151 <= addOut1;
                        t161 <= addOut2;
                        age1 <= 3'd4;
                    end

                    if (start) begin
                        if (!launch_slot) begin
                            r0 <= inportR; g0 <= inportG; b0 <= inportB;
                            t10 <= mulOut0; t20 <= mulOut1; t30 <= mulOut2;
                            valid0 <= 1'b1;
                            age0 <= 3'd1;
                        end else begin
                            r1 <= inportR; g1 <= inportG; b1 <= inportB;
                            t11 <= mulOut0; t21 <= mulOut1; t31 <= mulOut2;
                            valid1 <= 1'b1;
                            age1 <= 3'd1;
                        end
                        launch_slot <= ~launch_slot;
                    end
                end

                2'd1: begin
                    if (valid0 && age0 == 3'd1) begin
                        t40 <= addOut0;
                        t60 <= mulOut0;
                        t70 <= mulOut1;
                        t80 <= mulOut2;
                        age0 <= 3'd2;
                    end
                    if (valid1 && age1 == 3'd1) begin
                        t41 <= addOut0;
                        t61 <= mulOut0;
                        t71 <= mulOut1;
                        t81 <= mulOut2;
                        age1 <= 3'd2;
                    end

                    if (valid0 && age0 == 3'd4) begin
                        outportY <= y0;
                        outportU <= u0;
                        outportV <= addOut1;
                        done <= 1'b1;
                        valid0 <= 1'b0;
                        age0 <= 3'd0;
                    end
                    if (valid1 && age1 == 3'd4) begin
                        outportY <= y1;
                        outportU <= u1;
                        outportV <= addOut1;
                        done <= 1'b1;
                        valid1 <= 1'b0;
                        age1 <= 3'd0;
                    end
                end

                2'd2: begin
                    if (valid0 && age0 == 3'd2) begin
                        y0   <= addOut0;
                        t90  <= addOut1;
                        t100 <= addOut2;
                        t120 <= mulOut0;
                        t130 <= mulOut1;
                        t140 <= mulOut2;
                        age0 <= 3'd3;
                    end
                    if (valid1 && age1 == 3'd2) begin
                        y1   <= addOut0;
                        t91  <= addOut1;
                        t101 <= addOut2;
                        t121 <= mulOut0;
                        t131 <= mulOut1;
                        t141 <= mulOut2;
                        age1 <= 3'd3;
                    end
                end
                default: begin
                end
            endcase
        end
    end
endmodule
