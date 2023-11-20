module bcdToGc_gate (bcd,gc);
    input [3:0] bcd;
    output [3:0] gc;
    buf b1(gc[3], bcd[3]);
    xor x3(gc[2],bcd[3],bcd[2]);
    xor x2(gc[1],bcd[2],bcd[1]); 
    xor x1(gc[0],bcd[1],bcd[0]); 
endmodule

module bcdToGc_df (bcd, gc);
    input [3:0] bcd;
    output [3:0] gc;
    assign gc[3] = bcd[3];
    assign gc[2] = bcd[3] ^ bcd[2];
    assign gc[1] = bcd[2] ^ bcd[1];
    assign gc[0] = bcd[1] ^ bcd[0];
endmodule

module testbench;
    reg [3:0] bcd;
    wire [3:0] gc;
    bcdToGc_gate bg (bcd, gc);
    initial begin
        $monitor($time," bcd=%b, gc=%b",bcd,gc);
        #0 bcd = 4'b0000;
        #1 bcd = 4'b0001;
        #1 bcd = 4'b0010;
        #1 bcd = 4'b0011;
        #1 bcd = 4'b0100;
        #1 bcd = 4'b0101;
        #1 bcd = 4'b0110;
        #1 bcd = 4'b0111;
        #1 bcd = 4'b1000;
        #1 bcd = 4'b1001;
        #1 $finish;
    end
endmodule