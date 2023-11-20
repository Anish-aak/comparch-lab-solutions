// BITS ID: 2020B3A70785P
// Name: Anish Ashish Kasegaonkar

module JK(q, qbar, j, k, CLK);
	output reg q, qbar;
	input j, k, CLK;
	
	// Initialised as such, so that the counter starts from 0 at the first clock edge
	// Using behavioural modelling
	initial begin
		q <= 1'b1;
		qbar <= 1'b0;
	end
	always @(negedge CLK) begin
		if(j == 0 && k == 0) begin
			q <= q;
			qbar <= qbar;
		end
		else if(j == 1 && k == 0) begin
			q <= 1'b1;
			qbar <= 1'b0;
		end
		else if(j == 0 && k == 1) begin
			q <= 1'b0;
			qbar <= 1'b1;
		end
		else begin
			q <= ~q;
			qbar <= ~qbar;
		end
	end
endmodule

module BCD_Counter(Q_out, CLK);
	output [3:0] Q_out;
	input CLK;
	
	wire [3:0] Q_bar;
	wire q1q2;
	
	// Using gate-level modelling
	and a0(q1q2, Q_out[1], Q_out[2]);
	JK j0(Q_out[0], Q_bar[0], 1'b1, 1'b1, CLK);
	JK j1(Q_out[1], Q_bar[1], Q_bar[3], 1'b1, Q_out[0]);
	JK j2(Q_out[2], Q_bar[2], 1'b1, 1'b1, Q_out[1]);
	JK j3(Q_out[3], Q_bar[3], q1q2, 1'b1, Q_out[0]);
endmodule

module MEM_16(D_16, A_4);
	output reg [15:0] D_16;
	input [3:0] A_4;
	
	// Using behavioural modelling
	always@(*) begin
		case(A_4)
			4'b0000: D_16 = 16'h0001;
			4'b0001: D_16 = 16'h0002;
			4'b0010: D_16 = 16'h0004;
			4'b0011: D_16 = 16'h0008;
			4'b0100: D_16 = 16'h0010;
			4'b0101: D_16 = 16'h0020;
			4'b0110: D_16 = 16'h0000;
			4'b0111: D_16 = 16'h0000;
			4'b1000: D_16 = 16'h0000;
			4'b1001: D_16 = 16'h0000;
			4'b1010: D_16 = 16'h0400;
			4'b1011: D_16 = 16'h0800;
			4'b1100: D_16 = 16'h1000;
			4'b1101: D_16 = 16'h0000;
			4'b1110: D_16 = 16'h0000;
			4'b1111: D_16 = 16'h0000;
		endcase
	end
endmodule

module MUX_16(O, I_16, S_4);
	output reg O;
	input [15:0] I_16;
	input [3:0] S_4;
	
	// assign O = I_16[S_4]; -> Can be used for simplicity, after assigning O as a wire instead of reg
	
	// Using behavioural modelling
	always @(*) begin
		case(S_4)
			4'b0000: O = I_16[0];
			4'b0001: O = I_16[1];
			4'b0010: O = I_16[2];
			4'b0011: O = I_16[3];
			4'b0100: O = I_16[4];
			4'b0101: O = I_16[5];
			4'b0110: O = I_16[6];
			4'b0111: O = I_16[7];
			4'b1000: O = I_16[8];
			4'b1001: O = I_16[9];
			4'b1010: O = I_16[10];
			4'b1011: O = I_16[11];
			4'b1100: O = I_16[12];
			4'b1101: O = I_16[13];
			4'b1110: O = I_16[14];
			4'b1111: O = I_16[15];
		endcase
	end
endmodule

module INTG(OUT, CLK);
	output OUT;
	input CLK;
	
	wire [3:0] Q_out;
	wire [15:0] D_16;
	
	BCD_Counter b(Q_out, CLK);
	MEM_16 m(D_16, Q_out);
	MUX_16 mx(OUT, D_16, Q_out);
endmodule

module TESTBENCH;
	reg CLK;
	wire OUT;
	
	INTG i(OUT, CLK);
	
	initial begin
		$dumpfile("t.vcd");
		$dumpvars;
	end
	
	initial begin
		CLK = 1'b1;
		repeat(1000)
			#1 CLK = ~CLK;
	end
	
	initial begin
		$monitor($time, " OUT = %b, CLK = %b", OUT, CLK);
		// The output is 1 for first 6 clock negedges (1->0 of clock), and is 0 for the next 4 clock edges
		#100 $finish;
	end
endmodule
