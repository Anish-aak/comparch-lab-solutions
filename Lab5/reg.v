module d_ff(q, d, clk, reset);
    input d, reset, clk;
    output reg q;
    always @ (negedge reset or posedge clk) begin
        if (!reset) q <= 1'b0;
        else q <= d;
    end
endmodule

module reg_32bit(q, d, clk, reset);
    input [31:0] d;
    input clk, reset;
    output [31:0] q;
    genvar j;
    generate
        for(j = 0; j < 32; j = j + 1)
            d_ff d(q[j], d[j], clk, reset);
    endgenerate
endmodule

module mux4_1(regData,q1,q2,q3,q4,reg_no);
    input [1:0] reg_no;
    input [31:0] q1, q2, q3, q4;
    output reg [31:0] regData;
    always @(*) begin
        if(reg_no == 0) regData = q1;
        else if(reg_no == 1) regData = q2;
        else if(reg_no == 2) regData = q3;
        else regData = q4;
    end
endmodule

module decoder2_4 (register,reg_no);
    input [1:0] reg_no;
    output reg [3:0] register;
    always @(*) begin
        if(reg_no == 0) register = 1;
        else if(reg_no == 1) register = 2;
        else if(reg_no == 2) register = 4;
        else register = 8;
    end
endmodule

module RegFile(clk,reset,ReadReg1,ReadReg2,WriteData,WriteReg,RegWrite,ReadData1,ReadData2);
    output [31:0] ReadData1, ReadData2;
    input [1:0] ReadReg1, ReadReg2, WriteReg;
    input [31:0] WriteData;
    input clk, reset, RegWrite;
    wire clk1, clk2, clk3, clk4;
    wire [31:0] q1, q2, q3, q4;
    wire [3:0] WriteRegN;

    decoder2_4 d1(WriteRegN, WriteReg);
    and a1(clk1, clk, WriteRegN[0], RegWrite);
    and a2(clk2, clk, WriteRegN[1], RegWrite);
    and a3(clk3, clk, WriteRegN[2], RegWrite);
    and a4(clk4, clk, WriteRegN[3], RegWrite);
    reg_32bit r1(q1, WriteData, clk1, reset);
    reg_32bit r2(q2, WriteData, clk2, reset);
    reg_32bit r3(q3, WriteData, clk3, reset);
    reg_32bit r4(q4, WriteData, clk4, reset);
    mux4_1 m1(ReadData1, q1, q2, q3, q4, ReadReg1);
    mux4_1 m2(ReadData2, q1, q2, q3, q4, ReadReg2);
endmodule

module tbRegFile4;
    reg Clock, Reset, RegWrite;
    reg [1:0] ReadReg1, ReadReg2, WriteRegNo;
    reg [31:0]  WriteData;
    wire  [31:0]  ReadData1, ReadData2;
    RegFile rgf(Clock,Reset,ReadReg1,ReadReg2,WriteData,WriteRegNo,RegWrite,ReadData1,ReadData2);
    initial begin
        $monitor($time, ": Reset = %b, RegWrite = %b, ReadReg1 = %b, ReadReg2 = %b, WriteRegNo = %b, WriteData = %b, ReadData1 = %b, ReadData2 = %b.", Reset, RegWrite, ReadReg1, ReadReg2, WriteRegNo, WriteData, ReadData1, ReadData2);
        #0  Clock = 1'b1; ReadReg1 = 2'b00; ReadReg2 = 2'b01; Reset = 1'b1;
        #2  Reset = 1'b0;
        #10 Reset = 1'b1; RegWrite = 1'b1;  WriteData = 32'hF0F0F0F0; WriteRegNo = 2'b00;
        #10 RegWrite = 1'b1;  WriteData = 32'hF8F8F8F8; WriteRegNo = 2'b01;
        #10 RegWrite = 1'b1;  WriteData = 32'hFAFAFAFA; WriteRegNo = 2'b10;
        #10 RegWrite = 1'b1;  WriteData = 32'hFFFFFFFF; WriteRegNo = 2'b11;
        #10 RegWrite = 1'b0;
        #10 ReadReg1 = 2'b00; ReadReg2 = 2'b01;
        #10 ReadReg1 = 2'b10; ReadReg2 = 2'b11;
        #10 $finish;
    end
    always
        #5  Clock = ~Clock;
endmodule