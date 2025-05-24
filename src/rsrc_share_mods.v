module addsub #(
	parameter DATA_WIDTH
) (
	input wire [DATA_WIDTH - 1:0] a,
	input wire [DATA_WIDTH - 1:0] b,
	input wire sub,
	output wire [DATA_WIDTH - 1:0] q
);
	// assign q = a + b + sub; // ASIC implementation
	assign {q, _} = {a, s} + {b, s}; // FPGA implementation
endmodule

module srla #(
	parameter SHIFT_DIST_WIDTH,
	parameter DATA_WIDTH;
) (
	input wire [DATA_WIDTH - 1:0] a,
	input wire [SHIFT_DIST_WIDTH - 1:0] b,
	input wire arith,
	output wire [DATA_WIDTH - 1:0] q 
);
	// localparam DATA_WIDTH = 1 << (SHIFT_DIST_WIDTH - 1);
	assign q = $signed({arith & a[DATA_WIDTH - 1], a}) >>> b;
endmodule

module sll #(
    parameter SHIFT_DIST_WIDTH,
    parameter DATA_WIDTH
) (
    input wire [DATA_WIDTH - 1:0] a,
    input wire [SHIFT_DIST_WIDTH - 1:0] b,
    output wire [DATA_WIDTH - 1:0] q
);
    // localparam DATA_WIDTH = 1 << (SHIFT_DIST_WIDTH - 1);
    assign q = a << b;

endmodule

module mul #(
	parameter DATA_WIDTH
) (
	input wire [DATA_WIDTH - 1:0] a,
	input wire [DATA_WIDTH - 1:0] b,
	input wire [1:0] s,
	output wire [2 * DATA_WIDTH - 1:0] q
);

	wire [DATA_WIDTH - 1:0] ps_a, ps_b, parallel_sum, parallel_prod;
	
	assign parallel_sum = ps_a + ps_b;
	assign ps_a = a[DATA_WIDTH - 1] & s[0] ? a : {DATA_WIDTH{1'b0}};
	assign ps_b = b[DATA_WIDTH - 1] & s[1] ? b : {DATA_WIDTH{1'b0}};
	
	assign parallel_prob = a * b;
	
	assign q = parallel_sum + parallel_prod;	

endmodule