module signa(neg,A);
//this module is used to get the sign of an input 4-digit number
    input [3:0] A;
    output neg;
    reg neg;
    always @ (A)
        if (A[3] == 1) begin
            neg = 1;
            end
        else
            neg = 0;
endmodule

module compar(A,B,signA,signB,CMP1, CMP2,CMP3);
    input [3:0] A;
    input [3:0] B;
    output signA,signB,CMP1,CMP2,CMP3;
    reg CMP1,CMP2,CMP3;
    signa forA(signA,A);
    signa forB(signB,B);
    always @ (A or B or signA or signB)
        if(signA==1 && signB==0)
            begin
            CMP1 = 0;
            CMP2 = 0;
            CMP3 = 1;
            end
        else if(signA==0 && signB==1)
        begin
            CMP1 = 1;
            CMP2 = 0;
            CMP3 = 0;
            end
        else if (A > B )
            begin
            CMP1 = 1;
            CMP2 = 0;
            CMP3 = 0;
            end
        else if (A == B)
            begin
            CMP1 = 0;
            CMP2 = 1;
            CMP3 = 0;
            end
        else
            begin
            CMP1 = 0;
            CMP2 = 0;
            CMP3 = 1;
            end
endmodule

module testbench;
    reg Input,Clk;
    wire Out;
    reg [3:0] A;
    wire a,b,c,OutA,OutB,signA,signB,CMP1,CMP2,CMP3;
    reg [3:0] B;
    initial
        begin
        A=4'b0000;//input1
        B=4'b0000;//input2
        end
    initial
        begin
        #1 A=-8;B=-5;
        #1 A=2; B=7;
        #1 A=5; B=-1;
        end
    compar c1(A,B,signA,signB,CMP1,CMP2,CMP3);
    initial
        begin
        $monitor($time," A=%b, B=%b AgrB=%b, AeqB=%b, AltB=%b",A,B,CMP1,CMP2,CMP3);
        end
    initial
        begin
        #5 $finish;
        end
endmodule