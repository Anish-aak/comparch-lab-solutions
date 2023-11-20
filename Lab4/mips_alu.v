module mux2to1(out,sel,in1,in2);
    input [31:0] in1,in2;
    input sel;
    output reg [31:0] out;
    always @(in1 or in2 or sel) begin
        if(sel == 0) out = in1;
        else out = in2;
    end
endmodule

module mux4to1(out,sel,in1,in2,in3,in4);
    input in1,in2,in3,in4;
    input [1:0] sel;
    output reg out;
    always @(in1 or in2 or in3 or sel) begin
        if(sel == 0) out = in1;
        else if(sel == 1) out = in2;
        else if(sel == 2) out = in3;
        else out = in4;
    end
endmodule

module bit8_4to1mux(out,sel,in1,in2,in3,in4);
    input [7:0] in1,in2, in3, in4;
    output [7:0] out;
    input [1:0] sel;
    genvar j;
    generate 
        for (j=0; j<8;j=j+1) 
            mux4to1 m1(out[j],sel,in1[j],in2[j],in3[j],in4[j]);
    endgenerate
endmodule

module bit32_4to1mux(out,sel,in1,in2,in3,in4);
    input [31:0] in1,in2,in3,in4;
    output [31:0] out;
    input [1:0] sel;
    genvar j;
    generate
        for(j=0; j<4;j=j+1)
            bit8_4to1mux m1(out[8*(j+1)-1:8*j], sel, in1[8*(j+1)-1:8*j], in2[8*(j+1)-1:8*j], in3[8*(j+1)-1:8*j], in4[8*(j+1)-1:8*j]);
    endgenerate
endmodule

module bit32AND (out,in1,in2);
    input [31:0] in1,in2;
    output [31:0] out;
    assign {out}=in1 &in2;
endmodule

module bit32OR (out,in1,in2);
    input [31:0] in1,in2;
    output [31:0] out;
    assign {out}=in1 |in2;
endmodule

module DECODER(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
    input x,y,z;
    output d0,d1,d2,d3,d4,d5,d6,d7;
    wire x0,y0,z0;

    not n1(x0,x);
    not n2(y0,y);
    not n3(z0,z);
    and a0(d0,x0,y0,z0);
    and a1(d1,x0,y0,z);
    and a2(d2,x0,y,z0);
    and a3(d3,x0,y,z);
    and a4(d4,x,y0,z0);
    and a5(d5,x,y0,z);
    and a6(d6,x,y,z0);
    and a7(d7,x,y,z);
endmodule

module FADDER(s,c,x,y,z);
    input x,y,z;
    wire d0,d1,d2,d3,d4,d5,d6,d7;
    output s,c;
    DECODER dec(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
    assign s = d1 | d2 | d4 | d7, c = d3 | d5 | d6 | d7;
endmodule

module eight_fadder(s,c,x,y,z);
    input [7:0] x, y;
    input z;
    output [7:0] s;
    output c;
    wire c0, c1, c2, c3, c4, c5, c6;

    FADDER f0(s[0], c0, x[0], y[0], z);
    FADDER f1(s[1], c1, x[1], y[1], c0);
    FADDER f2(s[2], c2, x[2], y[2], c1);
    FADDER f3(s[3], c3, x[3], y[3], c2);
    FADDER f4(s[4], c4, x[4], y[4], c3);
    FADDER f5(s[5], c5, x[5], y[5], c4);
    FADDER f6(s[6], c6, x[6], y[6], c5);
    FADDER f7(s[7], c, x[7], y[7], c6);
endmodule

module thirty_two_fadder(s,c,x,y,z);
    input [31:0] x, y;
    input z;
    output [31:0] s;
    output c;
    wire c0, c1, c2;

    eight_fadder e0(s[7:0], c0, x[7:0], y[7:0], z);
    eight_fadder e1(s[15:8], c1, x[15:8], y[15:8], c0);
    eight_fadder e2(s[23:16], c2, x[23:16], y[23:16], c1);
    eight_fadder e3(s[31:24], c, x[31:24], y[31:24], c2);
endmodule

module ALU(a,b,Binvert,Carryin,Operation,Result,CarryOut);
    input [31:0] a, b;
    input Binvert, Carryin;
    input [1:0] Operation;
    output [31:0] Result;
    output CarryOut;
    wire [31:0] wAnd, wOr, wAdd, wMux, notB;
    assign {notB} = ~b;
    bit32AND a1(wAnd, a, b);
    bit32OR o1(wOr, a, b);
    mux2to1 m1(wMux, Binvert, b, notB);
    thirty_two_fadder s1(wAdd, CarryOut, a, wMux, Binvert);
    bit32_4to1mux m2(Result, Operation, wAnd, wOr, wAdd, wAdd);
endmodule

module ALUcontrol (Op, ALUOp0, ALUOp1, Func);
    output [2:0] Op;
    input ALUOp0, ALUOp1;
    input [5:0] Func;
    assign Op[0] = ALUOp1 & (Func[3] | Func[0]);
    assign Op[1] = ~ALUOp0 | ~Func[2];
    assign Op[2] = ALUOp0 | (ALUOp1 & Func[1]);
endmodule

module  ANDarray (RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1, Op);
    output  RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1;
    input [5:0] Op;
    wire  RFormat, LW, SW, BEQ;
    assign  RFormat = (~Op[5])&(~Op[4])&(~Op[3])&(~Op[2])&(~Op[1])&(~Op[0]);
    assign  LW = (Op[5])&(~Op[4])&(~Op[3])&(~Op[2])&(Op[1])&(Op[0]);
    assign  SW = (Op[5])&(~Op[4])&(Op[3])&(~Op[2])&(Op[1])&(Op[0]);
    assign  BEQ = (~Op[5])&(~Op[4])&(~Op[3])&(Op[2])&(~Op[1])&(~Op[0]);
    assign  RegDst = RFormat;
    assign  ALUSrc = LW | SW;
    assign  MemToReg = LW;
    assign  RegWrite = RFormat | LW;
    assign  MemRead = LW;
    assign  MemWrite = SW;
    assign  Branch = BEQ;
    assign  ALUOp0 = RFormat;
    assign  ALUOp1 = BEQ;
endmodule

module tbALU;
    reg Binvert, Carryin;
    reg [1:0] Operation;
    reg [31:0] a,b;
    wire [31:0] Result;
    wire CarryOut;
    ALU a1(a,b,Binvert,Carryin,Operation,Result,CarryOut);
    initial begin
        $monitor($time, " a=%b b=%b Carryin=%b Operation=%b Result=%b Carryout=%b",a,b,Carryin,Operation,Result,CarryOut);
        a=32'h00aaaaaa;
        b=32'h00000aaa;
        Operation=2'b00;
        Binvert=1'b0;
        Carryin=1'b0; //must perform AND resulting in zero
        #100 Operation=2'b01; //OR
        #100 Operation=2'b10; //ADD
        #100 Binvert=1'b1;//SUB
        #200 $finish;
    end
endmodule