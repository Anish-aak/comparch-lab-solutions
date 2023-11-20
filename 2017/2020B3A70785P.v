// 2020B3A70785P
module MUX_SMALL(out, in0, in1, sel);
    input in0, in1, sel;
    output out;
    assign out = (in0 & ~sel) | (in1 & sel);
endmodule

module MUX_BIG(out, in0, in1, in2, in3, in4, in5, in6, in7, sel);
    input in0, in1, in2, in3, in4, in5, in6, in7;
    input [2:0] sel;
    output out;
    wire w0, w1, w2, w3, w4, w5;
    MUX_SMALL m0(w0, in0, in1, sel[0]);
    MUX_SMALL m1(w1, in2, in3, sel[0]);
    MUX_SMALL m2(w2, in4, in5, sel[0]);
    MUX_SMALL m3(w3, in6, in7, sel[0]);
    MUX_SMALL m4(w4, w0, w1, sel[1]);
    MUX_SMALL m5(w5, w2, w3, sel[1]);
    MUX_SMALL m6(out, w4, w5, sel[2]);
endmodule

module TFF(q, t, clk, clear);
    input t, clk, clear;
    output reg q;
    always @(negedge clear or posedge clk) begin
        if(!clear)
            q <= 1'b0;
        else if(t)
            q <= ~q;
        else
            q <= q;
    end
endmodule

module COUNTER_4BIT(q0, q1, q2, q3, clk, clear);
    input clk, clear;
    output q0, q1, q2, q3;  
    TFF t1(q0, 1'b1, clk, clear);
    TFF t2(q1, q0, clk, clear);
    TFF t3(q2, q0&q1, clk, clear);
    TFF t4(q3, q0&q1&q2, clk, clear);
endmodule

module COUNTER_3BIT(q0, q1, q2, clk, clear);
    input clk, clear;
    output q0, q1, q2;
    TFF t1(q0, 1'b1, clk, clear);
    TFF t2(q1, q0, clk, clear);
    TFF t3(q2, q0&q1, clk, clear);
endmodule

module MEMORY(o0, o1, o2, o3, o4, o5, o6, o7, i0, i1, i2, i3);
    input i0, i1, i2, i3;
    output reg o0, o1, o2, o3, o4, o5, o6, o7;
    reg [7:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
    initial begin
        r0 = 8'hCC;
        r1 = 8'hAA;
        r2 = 8'hCC;
        r3 = 8'hAA;
        r4 = 8'hCC;
        r5 = 8'hAA;
        r6 = 8'hCC;
        r7 = 8'hAA;
        r8 = 8'hCC;
        r9 = 8'hAA;
        r10 = 8'hCC;
        r11 = 8'hAA;
        r12 = 8'hCC;
        r13 = 8'hAA;
        r14 = 8'hCC;
        r15 = 8'hAA;
    end
    always @(i0 or i1 or i2 or i3) begin
        case ({i3, i2, i1, i0})
            4'b0000: {o7, o6, o5, o4, o3, o2, o1, o0} = r0;
            4'b0001: {o7, o6, o5, o4, o3, o2, o1, o0} = r1;
            4'b0010: {o7, o6, o5, o4, o3, o2, o1, o0} = r2;
            4'b0011: {o7, o6, o5, o4, o3, o2, o1, o0} = r3;
            4'b0100: {o7, o6, o5, o4, o3, o2, o1, o0} = r4;
            4'b0101: {o7, o6, o5, o4, o3, o2, o1, o0} = r5;
            4'b0110: {o7, o6, o5, o4, o3, o2, o1, o0} = r6;
            4'b0111: {o7, o6, o5, o4, o3, o2, o1, o0} = r7;
            4'b1000: {o7, o6, o5, o4, o3, o2, o1, o0} = r8;
            4'b1001: {o7, o6, o5, o4, o3, o2, o1, o0} = r9;
            4'b1010: {o7, o6, o5, o4, o3, o2, o1, o0} = r10;
            4'b1011: {o7, o6, o5, o4, o3, o2, o1, o0} = r11;
            4'b1100: {o7, o6, o5, o4, o3, o2, o1, o0} = r12;
            4'b1101: {o7, o6, o5, o4, o3, o2, o1, o0} = r13;
            4'b1101: {o7, o6, o5, o4, o3, o2, o1, o0} = r14;
            4'b1111: {o7, o6, o5, o4, o3, o2, o1, o0} = r15;
        endcase
    end
endmodule

module INTG(waveform, clk, clear);
    input clk, clear;
    output waveform;
    wire q00, q01, q02, q10, q11, q12, q13;
    wire o0, o1, o2, o3, o4, o5, o6, o7;

    COUNTER_3BIT c1(q00, q01, q02, clk, clear);
    COUNTER_4BIT c2(q10, q11, q12, q13, q00&q01&q02, clear);
    MEMORY mem1(o0, o1, o2, o3, o4, o5, o6, o7, q10, q11, q12, q13);
    MUX_BIG mux1(waveform, o0, o1, o2, o3, o4, o5, o6, o7, {q02, q01, q00});
endmodule

module tb;
    reg clk = 0, clear;
    wire waveform;
    INTG i(waveform, clk, clear);
    always
        #1 clk = ~clk;
    initial begin
        $dumpfile("filename.vcd");
        $dumpvars;
    end
    initial begin
        clear = 0; clk = 0;
        $monitor($time, " waveform=%b, clk=%b, clear=%b\n", waveform, clk, clear);
        #1 clear = 1;
        #100 $finish;
    end
endmodule