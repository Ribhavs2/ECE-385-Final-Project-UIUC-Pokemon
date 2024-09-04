module dialogues_palette(
	input logic [2:0] index,
	output logic [3:0] red, green, blue
);

localparam [0:7][11:0] palette = {
	{4'hE, 4'hE, 4'hE},
	{4'h2, 4'h2, 4'h2},
	{4'h8, 4'h8, 4'h8},
	{4'hF, 4'hF, 4'hF},
	{4'hA, 4'hA, 4'hA},
	{4'h0, 4'h0, 4'h0},
	{4'hC, 4'hC, 4'hC},
	{4'h5, 4'h5, 4'h5}
};

assign {red, green, blue} = palette[index];

endmodule
