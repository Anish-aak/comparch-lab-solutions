module RSFF(Q, Qbar, S, R, clk, reset);
    output reg Q, Qbar;
    input S, R, clk, reset;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            Q <= 1'b1;
            Qbar <= 1'b0;
        end
        else begin
            if(S == 0 && R == 1) begin
                Q <= 1'b0;
                Qbar <= 1'b1;
            end
            else if(S == 1 && R == 0) begin
                Q <= 1'b1;
                Qbar <= 1'b0;
            end
            if(S == 1 && R == 1) begin
                Q <= 1'b1;
                Qbar <= 1'b0;
            end
        end
    end
endmodule

module DFF(Q, Qbar, D, clk, reset);
    output Q, Qbar;
    input D, clk, reset;
    RSFF s(Q, Qbar, D, ~D, clk, reset);
endmodule

module Ripple_Counter(Q, clk, reset);
    output [3:0] Q;
    input clk, reset;
    wire [3:0] Qbar;
    DFF d0(Q[0], Qbar[0], Qbar[0], clk, reset);
    DFF d1(Q[1], Qbar[1], Qbar[1], Qbar[0], reset);
    DFF d2(Q[2], Qbar[2], Qbar[2], Qbar[1], reset);
    DFF d3(Q[3], Qbar[3], Qbar[3], Qbar[2], reset);
endmodule

module MEM1(memout, addr);
    output [7:0] memout;
    input [2:0] addr;
    reg [7:0] mem[0:7];
    assign memout = mem[addr];

    initial begin
        mem[0] = 8'b0001_1111;
        mem[1] = 8'b0011_0001;
        mem[2] = 8'b0101_0011;
        mem[3] = 8'b0111_0101;
        mem[4] = 8'b1001_0111;
        mem[5] = 8'b1011_1001;
        mem[6] = 8'b1101_1011;
        mem[7] = 8'b1111_1101;
    end
endmodule

module MEM2(memout, addr);
    output [7:0] memout;
    input [2:0] addr;
    reg [7:0] mem[0:7];
    assign memout = mem[addr];

    initial begin
        mem[0] = 8'b0000_0000;
        mem[1] = 8'b0010_0010;
        mem[2] = 8'b0100_0100;
        mem[3] = 8'b0110_0110;
        mem[4] = 8'b1000_1000;
        mem[5] = 8'b1010_1010;
        mem[6] = 8'b1100_1100;
        mem[7] = 8'b1110_1110;
    end
endmodule

module MUX2To1(out, in, sel);
    output out;
    input [1:0] in;
    input sel;
    assign out = in[sel];
endmodule

module MUX16To8(out, in, sel);
    output [7:0] out;
    input [15:0] in;
    input sel;
    genvar i;
    parameter n = 8;
    generate
        for(i = 0; i < n; i = i + 1)
            MUX2To1 m(out[i], {in[i+n], in[i]}, sel);
    endgenerate
endmodule

module Fetch_data(data, parity, in);
    output [7:0] data;
    output parity;
    input [3:0] in;
    wire [7:0] memout1, memout2;

    MEM1 m1(memout1, in[2:0]);
    MEM2 m2(memout2, in[2:0]);
    MUX16To8 mx1(data, {memout2, memout1}, in[3]);
    MUX2To1 mx2(parity, {1'b0, 1'b1}, in[3]);
endmodule

module Parity_Checker(match, data, parity);
    output match;
    input [7:0] data;
    input parity;
    assign detectedParity = (data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]);
    assign match = (detectedParity == parity);
endmodule

module Design(match, clk, reset);
    output match;
    input clk, reset;
    wire [3:0] q;
    wire [7:0] data;
    wire parity;

    Ripple_Counter r(q, clk, reset);
    Fetch_data f(data, parity, q);
    Parity_Checker p(match, data, parity);
endmodule

module TestBench;
    reg clk, reset;
    wire match;
    Design d(match, clk, reset);

    initial begin
        $dumpfile("f.vcd");
        $dumpvars;
    end

    initial begin
        clk = 1'b0;
        repeat(1000)
            #1 clk = ~clk;
    end

    initial begin
        $monitor($time, " reset=%b, match=%b", reset, match);
        reset = 1'b0;
        #1 reset = 1'b1;
        #100 $finish;
    end
endmodule