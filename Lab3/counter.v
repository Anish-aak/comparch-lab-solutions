module jkff(j, k, clr, clk, q);
    output reg q;
    input j, k, clr, clk;
    initial
        q = 1'b0;
    always @(posedge clk) begin
        if(!clr) q <= 0;
        else begin
            if(j == 0 && k == 0) q <= q;
            else if(j == 1 && k == 0) q <= 1;
            else if(j == 0 && k == 1) q <= 0;
            else q <= ~q;
        end
    end
endmodule

module four_counter(clk, clr, q);
    input clk, clr;
    output [3:0] q;

    jkff j0(1'b1, 1'b1, clr, clk, q[0]);
    jkff j1(q[0], q[0], clr, clk, q[1]);
    jkff j2(q[0] & q[1], q[0] & q[1], clr, clk, q[2]);
    jkff j3(q[0] & q[1] & q[2], q[0] & q[1] & q[2], clr, clk, q[3]);
endmodule

module testbench;
    parameter n = 20;
    reg clk, rst;
    integer  i;
    wire [3:0] q;
    four_counter f(clk, rst, q);
    initial begin
        clk = 0;
        rst = 1;
        for( i = 0; i < n; i = i + 1) begin
            $display("q = ", q, " i = ", i);
            #2 clk = 1;
            #2 clk = 0;
        end
    end
endmodule