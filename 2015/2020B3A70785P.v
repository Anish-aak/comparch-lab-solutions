module mux_16to1(out, X);
    output reg [8:0] out;
    input [3:0] X;

    always @(*) begin
        case(X)
            4'b0000: out = 9'd0;
            4'b0001: out = 9'd25;
            4'b0010: out = 9'd50;
            4'b0011: out = 9'd75;
            4'b0100: out = 9'd100;
            4'b0101: out = 9'd125;
            4'b0110: out = 9'd150;
            4'b0111: out = 9'd175;
            4'b1000: out = 9'd200;
            4'b1001: out = 9'd225;
            4'b1010: out = 9'd250;
            4'b1011: out = 9'd275;
            4'b1100: out = 9'd300;
            4'b1101: out = 9'd325;
            4'b1110: out = 9'd350;
            4'b1111: out = 9'd375;
        endcase
    end
endmodule

module dff(q, qn, d, clk, reset);
    output reg q, qn;
    input d, clk, reset;

    always @(negedge reset or posedge clk) begin
        if(!reset) begin
            q <= 1'b0;
            qn <= 1'b1;
        end
        else begin
            q <= d;
            qn <= ~d;
        end
    end
endmodule

module ACC_RST(Acc_rst1, Acc_rst2, clk, reset);
    output Acc_rst1, Acc_rst2;
    input clk, reset;
    wire w1, w2, w3, w4, w5, w6, w7, w8;

    dff d1(w1, w2, w2, clk, reset);
    dff d2(w3, w4, w4, w1, reset);
    dff d3(w5, w6, w6, w3, reset);
    dff d4(w7, w8, w8, w5, reset);
    assign Acc_rst1 = w5;
    assign Acc_rst2 = w7;
endmodule

module Adder_Register(Y, mxout, Acc_rst1, Acc_rst2, clk);
    output reg [12:0] Y;
    input [8:0] mxout;
    input Acc_rst1, Acc_rst2, clk;

    always @(posedge Acc_rst2 or negedge Acc_rst2)
        Y <= 13'd0;

    always @(posedge clk)
        if(Acc_rst1)
            Y <= Y + mxout;
        else
            Y <= Y;
endmodule

module INTG(Y, X, clk, reset);
    output [12:0] Y;
    input [3:0] X;
    input clk, reset;

    wire Acc_rst1, Acc_rst2;
    wire [8:0] mxout;

    ACC_RST ac(Acc_rst1, Acc_rst2, clk, reset);
    mux_16to1 mx(mxout, X);
    Adder_Register ar(Y, mxout, Acc_rst1, Acc_rst2, clk);

endmodule

module Tb;
    reg [3:0] X;
    reg clk, reset;
    wire [12:0] Y;

    INTG i(Y, X, clk, reset);

    initial begin
        #1 clk <= 1'b0;
        repeat(25)
            #1 clk <= ~clk;
    end
    initial begin
        $monitor($time, " X=%d, Reset=%b, Y=%d", X, reset, Y, i.Acc_rst1);
        #0 reset = 1'b0; 
        #2 reset = 1'b1; X = 4'd10;
        #2 X = 4'd5;
        #2 X = 4'd12;
        #2 X = 4'd1;

        #2 X = 4'd13;
        #2 X = 4'd7;
        #2 X = 4'd9;
        #2 X = 4'd2;

        #2 X = 4'd11;
        #2 X = 4'd5;
        #2 X = 4'd4;
        #2 X = 4'd2;
    end
endmodule