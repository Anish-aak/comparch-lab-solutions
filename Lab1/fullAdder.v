`timescale 1ms/1ns
module full_add (a, b, cin, sum, cout);
    input a, b, cin;
    output sum, cout;
    wire x, y, z;

    half_add h1(a, b, x, y);
    half_add h2(x, cin, sum, z);
    or o1(cout, y, z);
endmodule

module half_add (a, b, sum, cout);
    input a, b;
    output sum, cout;

    xor x1(sum, a, b);
    and a1(cout, a, b);
endmodule

module fourb_add_sub (a, b, ctrl, s, cout);
    input [3:0] a, b;
    input ctrl;
    output [3:0] s;
    output cout;
    wire w1, w2, w3, w4;
    wire c0, c1, c2;
    
    xor x1(w1, b[0], ctrl);
    xor x2(w2, b[1], ctrl);
    xor x3(w3, b[2], ctrl);
    xor x4(w4, b[3], ctrl);
    full_add f1(w1, a[0], ctrl, s[0], c0);
    full_add f2(w2, a[1], c0, s[1], c1);
    full_add f3(w3, a[2], c1, s[2], c2);
    full_add f4(w4, a[3], c2, s[3], cout);
endmodule

module testbench_fullAdder;
    reg [3:0] a, b;
    reg cntrl;
    wire [3:0] sum;
    wire cout;
    fourb_add_sub f1(a, b, cntrl, sum, cout);
    initial begin
        $monitor($time," a=%b, b=%b, cntrl=%b, sum=%b, cout=%b",a,b,cntrl,sum,cout);
        #0 a=4'b1000; b=4'b0101; cntrl=1'b0;
        #1 a=4'b0111; b=4'b0011; cntrl=1'b0;
        #1 a=4'b1000; b=4'b0001; cntrl=1'b1;
        #1 a=4'b1000; b=4'b1000; cntrl=1'b1;
        #1 $finish;
    end
endmodule