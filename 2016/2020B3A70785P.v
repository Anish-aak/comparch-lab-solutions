// THIS PROGRAM IS INCOMPLETE
// If someone would like to add the solution, send a PR

module BHT(out, addr, in, wr, clk);
    output [1:0] out;
    input [9:0] addr;
    input [1:0] in;
    input wr, clk;
    reg [1:0] bht[0:1023];
    integer i;

    assign out = bht[addr];
    initial begin
        for(i=0; i<1024; i=i+1)
            bht[i] = 2'b00;
    end
    always @(posedge clk) begin
        if(wr) bht[addr] = in;
    end
endmodule

module MUX1(out, in, sel);
    output [1:0] out;
    input [1:0] in;
    input sel;
    assign out = in[sel];
endmodule

module PREDICTOR(out, in, clk);
    output reg [1:0] out;
    input in, clk;

    initial begin
        out = 2'b0;
    end
    always @(posedge clk) begin
        case(out)
            2'b00: begin
                if(in) out = 2'b01;
                else out = 2'b00;
            end
            2'b01: begin
                if(in) out = 2'b11;
                else out = 2'b00;
            end
            2'b10: begin
                if(in) out = 2'b11;
                else out = 2'b00;
            end
            2'b11: begin
                if(in) out = 2'b11;
                else out = 2'b10;
            end
        endcase
    end
endmodule

module INTG(out, in, addr, clk);
    output reg [1:0] out;
    input in, clk;
    input [9:0] addr;
    wire [1:0] op1, op2, ip1, ip2;
    wire w1, w2;

    BHT b1(op1, addr, ip1, w1, clk);
    BHT b2(op2, addr, ip2, w2, clk);
endmodule