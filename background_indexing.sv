
//module background_indexing(
//    input vga_clk,
//    input [17:0] rom_address,
//    output [3:0] rom_q,
    
//    input [17:0] rom_address_b,
//    output [3:0] rom_q_b
//    );
    
//logic negedge_vga_clk;

//// read from ROM on negedge, set pixel on posedge
//assign negedge_vga_clk = ~vga_clk;
    
//back_ROM init_map_rom (
//	.clka   (negedge_vga_clk),
//	.addra (rom_address),
//	.douta       (rom_q),
	
//	.clkb(negedge_vga_clk),
//	.addrb(rom_address_b),
//	.doutb(rom_q_b)
//);
//endmodule
