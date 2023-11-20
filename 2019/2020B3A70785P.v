module MUX_2x1(out, in, sel);
    output out;
    input [1:0] in;
    input sel;
    assign out = in[sel];
endmodule

module MUX_8x1(out, in, sel);
    output out;
    input [7:0] in;
    input [2:0] sel;
    assign out = in[sel];
endmodule

module MUX_ARRAY(out, in, sel);
    output [7:0] out;
    input [7:0] in, sel;
    genvar i;
    parameter n = 8;
    generate
        for(i=0; i<n; i=i+1)
            MUX_2x1 m(out[i], {in[i], 1'b0}, sel[i]);
    endgenerate
endmodule

module COUNTER_3BIT(q, clk, reset);
    output reg [2:0] q;
    input clk, reset;

    initial q <= 3'b111;
    always @(posedge clk or negedge reset) begin
        if(!reset) q <= 3'b000;
        else q <= q + 1;
    end
endmodule

module DECODER(out, in, en);
    output reg [7:0] out;
    input [2:0] in;
    input en;

    always @(*) begin
        if(en) out = 1 << in;
    end
endmodule

module MEMORY(out, in);
    output [7:0] out;
    input [2:0] in;
    reg [7:0] mem[0:7];

    assign out = mem[in];
    initial begin
        mem[0] = 8'h01;
        mem[1] = 8'h03;
        mem[2] = 8'h07;
        mem[3] = 8'h0F;
        mem[4] = 8'h1F;
        mem[5] = 8'h3F;
        mem[6] = 8'h7F;
        mem[7] = 8'hFF;
    end
endmodule

module TOP_MODULE(o, s, clk, reset);
    output o;
    input clk, reset;
    input [2:0] s;
    wire [2:0] q;
    wire [7:0] out, outflip, sel, e;

    COUNTER_3BIT c(q, clk, reset);
    DECODER d(out, q, 1'b1);
    assign outflip = out;//{out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7]};
    MUX_ARRAY ma(e, outflip, sel);
    MEMORY mem(sel, s);
    MUX_8x1 m8(o, e, q);
endmodule

module TestBench;
    reg [2:0] s;
    reg clk, reset;
    wire o;
    TOP_MODULE t(o, s, clk, reset);

    initial begin
        $dumpfile("t.vcd");
        $dumpvars;
    end

    initial begin
        #1 clk = 1'b0;
        repeat(100)
            #1 clk = ~clk;
    end

    initial begin
        $monitor($time, " s=%b, reset=%b, o=%b, clk=%b", s, reset, o, clk);
        reset = 1'b0;
        #1 reset = 1'b1; s = 3'b000;
        #8 s = 3'b001;
        #8 s = 3'b010;
        #8 s = 3'b011;
        #8 s = 3'b100;
        #8 s = 3'b101;
        #8 s = 3'b110;
        #8 s = 3'b111;
        #8 $finish;
    end
endmodule