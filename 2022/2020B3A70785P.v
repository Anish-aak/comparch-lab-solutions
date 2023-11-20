module REG_8BIT(reg_out, num_in, clock, reset);
    input [7:0] num_in;
    input clock, reset;
    output reg [7:0] reg_out;

    always @(posedge clock) begin
        if(reset) begin
            reg_out = 8'b0000_0000;
        end
        else begin
            reg_out = num_in;
        end
    end
endmodule

module EXPANSION_BOX(in, out);
    input [3:0] in;
    output [7:0] out;
    assign out[0] = in[0];
    assign out[1] = in[2];
    assign out[2] = in[3];
    assign out[3] = in[1];
    assign out[4] = in[2];
    assign out[5] = in[1];
    assign out[6] = in[0];
    assign out[7] = in[3];
endmodule

module XOR_8BIT(xout_8, xin1_8, xin2_8);
    input [7:0] xin1_8, xin2_8;
    output [7:0] xout_8;
    assign xout_8 = xin1_8 ^ xin2_8;
endmodule

module XOR_4BIT(xout_4, xin1_4, xin2_4);
    input [3:0] xin1_4, xin2_4;
    output [3:0] xout_4;
    assign xout_4 = xin1_4 ^ xin2_4;
endmodule

module CONCAT(concat_out, concat_in1, concat_in2);
    input [3:0] concat_in1, concat_in2;
    output [7:0] concat_out;
    assign concat_out = {concat_in1, concat_in2};
endmodule

module MUX2x1(out, in, sel);
    input [1:0] in;
    input sel;
    output out;
    assign out = in[sel];
endmodule

module MUX8x4(out, in, sel);
    input [7:0] in;
    input sel;
    output [3:0] out;

    MUX2x1 m0(out[0], {in[4], in[0]}, sel);
    MUX2x1 m1(out[1], {in[5], in[1]}, sel);
    MUX2x1 m2(out[2], {in[6], in[2]}, sel);
    MUX2x1 m3(out[3], {in[7], in[3]}, sel);
endmodule

module FA(out, cout, inA, inB, cin);
    input inA, inB, cin;
    output out, cout;
    assign {cout, out} = inA + inB + cin;
endmodule

module CSA_4BIT(cin, inA, inB, cout, out);
    input [3:0] inA, inB;
    input cin;
    output [3:0] out;
    output cout;

    wire [3:0] o0, o1;
    wire c0, c1;
    wire w0, w1, w2;
    wire w3, w4, w5;

    // cin = 1
    FA f0(o0[0], w0, inA[0], inB[0], 1'b1);
    FA f1(o0[1], w1, inA[1], inB[1], w0);
    FA f2(o0[2], w2, inA[2], inB[2], w1);
    FA f3(o0[3], c0, inA[3], inB[3], w2);

    // cin = 0
    FA f4(o1[0], w3, inA[0], inB[0], 1'b0);
    FA f5(o1[1], w4, inA[1], inB[1], w3);
    FA f6(o1[2], w5, inA[2], inB[2], w4);
    FA f7(o1[3], c1, inA[3], inB[3], w5);

    MUX2x1 m0(cout, {c0, c1}, cin);
    MUX8x4 m1(out, {o0, o1}, cin);
endmodule

module ENCRYPT(number, key, clock, reset, enc_number);
    input clock, reset;
    input [7:0] key, number;
    output [7:0] enc_number;

    wire [7:0] rout0, rout1, expout, xout0;
    wire [3:0] xout1, csaout;
    wire cout;

    REG_8BIT r0(rout0, number, clock, reset);
    REG_8BIT r1(rout1, key, clock, reset);

    EXPANSION_BOX e0(rout0[3:0], expout);
    XOR_8BIT x0(xout0, expout, rout1);
    CSA_4BIT c0(rout1[0], xout0[7:4], xout0[3:0], cout, csaout);
    XOR_4BIT x1(xout1, rout0[7:4], csaout);
    CONCAT conc(enc_number, xout1, rout0[3:0]);
endmodule

module TESTBENCH;
    reg clock, reset;
    reg [7:0] key, number;
    wire [7:0] enc_number;

    ENCRYPT e(number, key, clock, reset, enc_number);

    initial begin
        clock = 1'b0;
        repeat(1000)
            #1 clock = ~clock;
    end

    initial begin
        $monitor($time, " num=%b, key=%b, enc_number=%b", number, key, enc_number);
        #1 reset = 1'b1;
        #2 reset = 1'b0; number = 8'b0100_0110; key = 8'b1001_0011;
        #2 number = 8'b1100_1001; key = 8'b1010_1100;
        #2 number = 8'b1010_0101; key = 8'b0101_1010;
        #2 number = 8'b1111_0000; key = 8'b1011_0001;
    end
endmodule