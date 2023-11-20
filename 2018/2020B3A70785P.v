module TFF(q, T, clk, reset, en);
    output reg q;
    input T, clk, reset, en;

    initial q <= 1'b0;
    always @(posedge clk) begin
        if(!reset) begin
            q <= 1'b0;
        end 
        else begin
            if(T & en) begin
                q <= ~q;
            end
            else begin
                q <= q;
            end
        end
    end
endmodule

module DFF(q, D, clk, init, reset);
    output reg q;
    input D, clk, reset, init;

    initial q <= init;
    always @(posedge clk) begin
        if(!reset) begin
            q <= 1'b0;
        end
        else begin
            q <= D;
        end
    end
endmodule

module ControlLogic(T0, T1, T2, S, Z, X, clk, reset);
    output T0, T1, T2;
    input S, Z, X, clk, reset;
    wire Sbar, Zbar, Xbar, T2Z, T0Sbar, dT0;
    wire T0S, T2Xbar, T2XbarZbar, T1Xbar, ddT1, dT1;
    wire T1X, T2Zbar, T2ZbarX, dT2;
    not n1(Sbar, S);
    not n2(Zbar, Z);
    not n3(Xbar, X);
    and a1(T2Z, T2, Z);
    and a2(T0Sbar, T0, Sbar);
    or o1(dT0, T0Sbar, T2Z);

    and a3(T0S, T0, S);
    and a4(T2Xbar, T2, Xbar);
    and a5(T2XbarZbar, T2Xbar, Zbar);
    and a6(T1Xbar, T1, Xbar);
    or o2(ddT1, T0S, T2XbarZbar);
    or o3(dT1, ddT1, T1Xbar);

    and a7(T1X, T1, X);
    and a8(T2Zbar, T2, Zbar);
    and a9(T2ZbarX, T2Zbar, X);
    or o4(dT2, T1X, T2ZbarX);

    DFF d1(T0, dT0, clk, 1'b1, 1'b1);
    DFF d2(T1, dT1, clk, 1'b0, reset);
    DFF d3(T2, dT2, clk, 1'b0, reset);
endmodule

module COUNTER_4BIT(q, clk, reset, en);
    output [3:0] q;
    input clk, reset, en;

    TFF t1(q[0], 1'b1, clk, reset, en);
    TFF t2(q[1], q[0], clk, reset, en);
    TFF t3(q[2], q[0] & q[1], clk, reset, en);
    TFF t4(q[3], q[0] & q[1] & q[2], clk, reset, en);
endmodule

module INTG(G, q, S, X, clk, reset);
    output G;
    output [3:0] q;
    input S, clk, X, reset;
    wire T0, T1, T2, Z;

    assign Z = q[0] & q[1] & q[2] & q[3];
    COUNTER_4BIT c(q, clk, ~(T0 & S), (T1 & X) | (T2 & ~Z & X));
    ControlLogic cl(T0, T1, T2, S, Z, X, clk, reset);
    DFF d(G, T2 & Z, clk, 1'b0, reset);
endmodule

module Testbench;
    reg S, X, clk, reset;
    wire G;
    wire [3:0] q;
    INTG i(G, q, S, X, clk, reset);
    initial begin
        clk = 1'b0;
        repeat(100)
            #1 clk = ~clk;
    end

    initial begin
        $dumpfile("t.vcd");
        $dumpvars;
    end
    
    initial begin
        $monitor($time, " S=%b, X=%b, G=%b, q=%b", S, X, G, q);
        S = 1'b1; X = 1'b1; reset = 1'b1;
        #100 $finish;
    end
endmodule