
module battle_control(
    input logic clk,
    input logic reset,
    input logic battle_bit
    );
    
    enum logic [2:0] {
    no_battle,
    init_boss,
    start_battle,
    user_turn,
    show_user_move,
    boss_turn,
    show_boss_move
    } cur_battle_state, next_battle_state;
    
 	always_ff @ (posedge clk)
	begin
		if (reset) begin
			cur_battle_state <= no_battle;
	    end
		else 
			cur_battle_state <= next_battle_state;
	end
    
    
endmodule
