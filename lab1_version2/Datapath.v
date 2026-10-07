`timescale 1ns/1ps
module Datapath(
    input  [2:0] state,
    input  clk,
    input  rst_n,
    input  start,
    input  signed [8:0] inportR,
    input  signed [8:0] inportG,
    input  signed [8:0] inportB,
    output signed [8:0] outportY,
    output signed [8:0] outportU,
    output signed [8:0] outportV
);
    localparam IDLE = 3'd0,
               S1   = 3'd1,
               S2   = 3'd2,
               S3   = 3'd3,
               S4   = 3'd4,
               S5   = 3'd5;

    localparam signed [8:0] C_YR  = 9'sd76;   //  0.299 * 256
    localparam signed [8:0] C_YG  = 9'sd150;  //  0.587 * 256
    localparam signed [8:0] C_YB  = 9'sd29;   //  0.114 * 256
    localparam signed [8:0] C_UR  = -9'sd43;  // -0.169 * 256
    localparam signed [8:0] C_UG  = -9'sd84;  // -0.331 * 256
    localparam signed [8:0] C_UB  = 9'sd128;  //  0.500 * 256
    localparam signed [8:0] C_VR  = 9'sd128;  //  0.500 * 256
    localparam signed [8:0] C_VG  = -9'sd107; // -0.419 * 256
    localparam signed [8:0] C_VB  = -9'sd20;  // -0.081 * 256
    localparam signed [8:0] BIAS  = 9'sd128;
    localparam signed [8:0] ZERO  = 9'sd0;

    reg signed [8:0] r_reg, g_reg, b_reg;
    reg signed [8:0] t1, t2, t3, t4;
    reg signed [8:0] t6, t7, t8, t9, t10;
    reg signed [8:0] t12, t13, t14, t15, t16;
    reg signed [8:0] y_reg, u_reg, v_reg;

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

        case (state)
            S1: begin
                mulA0 = r_reg; mulB0 = C_YR;
                mulA1 = g_reg; mulB1 = C_YG;
                mulA2 = b_reg; mulB2 = C_YB;
            end
            S2: begin
                mulA0 = r_reg; mulB0 = C_UR;
                mulA1 = g_reg; mulB1 = C_UG;
                mulA2 = b_reg; mulB2 = C_UB;
                addA0 = t1;    addB0 = t2;
            end
            S3: begin
                mulA0 = r_reg; mulB0 = C_VR;
                mulA1 = g_reg; mulB1 = C_VG;
                mulA2 = b_reg; mulB2 = C_VB;
                addA0 = t4;    addB0 = t3;
                addA1 = t6;    addB1 = t7;
                addA2 = t8;    addB2 = BIAS;
            end
            S4: begin
                addA0 = t9;    addB0 = t10;
                addA1 = t12;   addB1 = t13;
                addA2 = t14;   addB2 = BIAS;
            end
            S5: begin
                addA0 = t15;   addB0 = t16;
            end
            default: begin
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_reg <= ZERO; g_reg <= ZERO; b_reg <= ZERO;
            t1 <= ZERO; t2 <= ZERO; t3 <= ZERO; t4 <= ZERO;
            t6 <= ZERO; t7 <= ZERO; t8 <= ZERO; t9 <= ZERO; t10 <= ZERO;
            t12 <= ZERO; t13 <= ZERO; t14 <= ZERO; t15 <= ZERO; t16 <= ZERO;
            y_reg <= ZERO; u_reg <= ZERO; v_reg <= ZERO;
        end else begin
            if ((state == IDLE) && start) begin
                r_reg <= inportR;
                g_reg <= inportG;
                b_reg <= inportB;
            end

            case (state)
                S1: begin
                    t1 <= mulOut0;
                    t2 <= mulOut1;
                    t3 <= mulOut2;
                end
                S2: begin
                    t4 <= addOut0;
                    t6 <= mulOut0;
                    t7 <= mulOut1;
                    t8 <= mulOut2;
                end
                S3: begin
                    y_reg <= addOut0;
                    t9   <= addOut1;
                    t10  <= addOut2;
                    t12  <= mulOut0;
                    t13  <= mulOut1;
                    t14  <= mulOut2;
                end
                S4: begin
                    u_reg <= addOut0;
                    t15   <= addOut1;
                    t16   <= addOut2;
                end
                S5: begin
                    v_reg <= addOut0;
                end
                default: begin
                end
            endcase
        end
    end

    assign outportY = y_reg;
    assign outportU = u_reg;
    assign outportV = v_reg;
endmodule
