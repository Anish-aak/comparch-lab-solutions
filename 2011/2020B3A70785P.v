module ALU64bit(key, left, right, select);
    input [0:31] left, right;
    input select;
    output reg [63:0] key;

    always @(*) begin
        if(!select)
            {key} = left + right;
        else 
            {key} = left - right;
    end
endmodule

module Keygen(key1, key2, key);
    input [63:0] key;
    output [63:0] key1, key2;
    
    ALU64bit a1(key1, key[63:32], key[31:0], 1'b0);
    ALU64bit a2(key2, key[63:32], key[31:0], 1'b1);
endmodule

module Padd(paddedText, plainText);
    input [247:0] plainText;
    output [255:0] paddedText;

    assign paddedText[247:0] = plainText;
    assign paddedText[255:248] = 8'd248;
endmodule

module Encrypt(cipherText, plainText, key);
    input [247:0] plainText;
    input [63:0] key;
    output reg [255:0] cipherText;
    reg [63:0] b1, b2, b3, b4;
    wire [63:0] key1, key2;
    wire [255:0] paddedText;
    Keygen k1(key1, key2, key);
    Padd p1(paddedText, plainText);

    always @(*) begin
        b1 = {paddedText[192], paddedText[255:193]};
        b2 = {paddedText[128], paddedText[191:129]};
        b3 = {paddedText[64], paddedText[127:65]};
        b4 = {paddedText[0], paddedText[63:1]};
        b1 = b1 ^ key2;
        b2 = b2 ^ key2;
        b3 = b3 ^ key2;
        b4 = b4 ^ key1 ^ key2;
        cipherText = {b4, b1, b2, b3};
    end
endmodule

module Decrypt(decipherText, cipherText, key);
    input [255:0] cipherText;
    input [63:0] key;
    output reg [255:0] decipherText;
    reg [63:0] b1, b2, b3, b4;
    wire [63:0] key1, key2;
    Keygen k1(key1, key2, key);

    always @(*) begin
        b1 = cipherText[255:192] ^ key2 ^ key1;
        b2 = cipherText[191:128] ^ key2;
        b3 = cipherText[127:64] ^ key2;
        b4 = cipherText[63:0] ^ key2;
        b1 = {b1[62:0], b1[63]};
        b2 = {b2[62:0], b2[63]};
        b3 = {b3[62:0], b3[63]};
        b4 = {b4[62:0], b4[63]};
        decipherText = {b2, b3, b4, b1};
    end
endmodule

module AlgoTest;
    reg [247:0] plainText;
    reg [63:0] key;
    wire [255:0] cipherText, decipherText;

    Encrypt e(cipherText, plainText, key);
    Decrypt d(decipherText, cipherText, key);

    initial begin
        $monitor("PlainText=%b\nCipherText=%b\nDecipherText=%b\n", plainText, cipherText, decipherText);
        #0 plainText = 20; key = 15;
        #10 $finish;
    end
endmodule