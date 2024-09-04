
module character_motion(
    input logic reset,
    input logic clk,
    
 	input logic [9:0] DrawX, DrawY,
	input  logic [9:0] BallX, BallY,
	input logic [7:0] keycode,

    output logic [12:0] rom_address,
    output logic [13:0] rom_address_user_attack,
    output logic [12:0] rom_address_user_health,
    output logic [12:0] rom_address_user_stun,
    
    output logic [13:0] rom_address_opp_attack,
    output logic [12:0] rom_address_opp_stun,
    
    output logic [14:0] rom_address_text,
    
    
    output logic [1:0] battle_bit,
    
    input logic [9:0]  FrameX, 
    input logic [9:0]  FrameY,
    output logic [7:0] health_opp,
    output logic [7:0] health_user,
    output logic [3:0] battle_state,
    
    output logic [3:0] credits, 
    output logic [3:0] num_attack_potions, 
    output logic [3:0] num_heal_potions, 
    output logic [3:0] num_stun_potions,    
    
    output  logic attack_user_on,
    output logic health_user_on,
    output logic stun_user_on,
    output logic attack_opp_on,
    output logic stun_opp_on,
    
    output logic text_on,
    
    output logic [1:0] boss_bit
    );
    logic [9:0] rel_x;
    logic [9:0] rel_y;
    
    logic [9:0] rel_x_text;
    logic [9:0] rel_y_text;
    
    assign rel_x = DrawX - BallX;
    assign rel_y = DrawY - BallY;
    
//    logic [3:0] counter_char;
    logic [6:0] counter_battle;
//    logic [6:0] health_user;
//    logic [1:0] stun_result;
    
//    parameter [31:0] M = 773;
    parameter [31:0] M = 32'd27856441;
    logic [31:0] B;
    logic [31:0] B_next;
    
    logic flag_attack_potion;
    logic flag_heal_potion;
    logic flag_stun_potion;
    
    logic temp_flag_stun;

    logic [9:0] rel_x_user,rel_y_user,rel_x_opp,rel_y_opp; 
	
	assign rel_x_opp = (DrawX - (158+1+200));
	assign rel_y_opp = (DrawY - (20+7+160));
	
	assign rel_x_user = (DrawX - (41+1+200));
	assign rel_y_user = (DrawY - (67+7+160));
	
	
	assign rel_x_text = DrawX - (8 + 200);
    assign rel_y_text = DrawY - (118 + 160);
    
    assign num_attack_potions = {1'b0, 1'b0, 1'b0, flag_attack_potion}; 
    assign num_heal_potions = {1'b0, 1'b0, 1'b0, flag_heal_potion}; 
    assign num_stun_potions = {1'b0, 1'b0, 1'b0, flag_stun_potion}; 
	
    enum logic [4:0] {
        down_face_left_foot,
        down_face_stand_foot,
        down_face_right_foot,
        
        up_face_left_foot,
        up_face_stand_foot,
        up_face_right_foot,
        
        left_face_left_foot,
        left_face_stand_foot,
        left_face_right_foot,
        
        right_face_left_foot,
        right_face_stand_foot,
        right_face_right_foot,
        
//        no_battle,
        init_boss,
//        start_battle,
        attack,
        stun,
        heal,
        run,
        show_user_move_attack,
        show_user_move_stun,
        show_user_move_heal,
        show_user_move_run,
        show_opp,
        
        win_eceb,
        loss_eceb,
        
        attack_potion,
        heal_potion,
        stun_potion,
        potion_end_attack,
        potion_end_heal,
        potion_end_stun
//        boss_turn,
//        show_boss_move
    } char_state, char_next_state;
    
	always_ff @ (posedge clk)
	begin
		if (reset) begin
			char_state <= up_face_stand_foot;
			counter_battle <= 0;
			health_opp <= 8'd0;
			health_user <= 8'd0;
			B <= 32'd2785642816;
			credits <= 0;
			flag_attack_potion <= 0;
			flag_heal_potion <= 0;
			flag_stun_potion <= 0;
			temp_flag_stun <= 0;
//			M <= 32'd773;
//			stun_result <= 0;
			//attack_user_on <= 1'b0;
			//rom_address_user_attack<= 0;
	    end
		else begin
			char_state <= char_next_state;
			health_opp <= health_opp;
			health_user <= health_user;
			B <= B_next;
			credits <= credits;
//			B <= B;
//			M <= M;
//			stun_result <= stun_result;
			//attack_user_on <= 1'b0;
			//rom_address_user_attack<= 0;
			if (char_state == init_boss) begin
    //			B <= B * M;
                health_opp <= 8'd0;
                health_user <= 8'd0;
                     if (counter_battle < 7'd120)
                         counter_battle <= counter_battle + 1;
                     else
                         counter_battle <= 0;
			end
			else if(char_state == show_user_move_attack) begin
//			     B <= B * M;
			     if (counter_battle == 0) begin
			         if (keycode == 8'h2C) begin
			             flag_attack_potion <= 0; // supr attack used
                         if (health_opp < 60)
                             health_opp<= health_opp+40;
                         else 
                             health_opp<= 100;
			         end
			         else begin
                         if (health_opp < 80)
                             health_opp<= health_opp+20;
                         else 
                             health_opp<= 100;
			         end
			         counter_battle <= counter_battle + 1; 
			     end
			     else if (counter_battle < 7'd120)begin
			        counter_battle <= counter_battle + 1; 
			        end           	    
			     else begin
			         counter_battle <= 0;
			         end
			 end
			      
			 else if(char_state == show_user_move_stun) begin
			     if (counter_battle == 0) begin			     
			         temp_flag_stun <= 0;
			         counter_battle <= counter_battle + 1;
			     end
			     else if (counter_battle == 1) begin
//			         B <= B * M;
//			         stun_result <= B%3;
                     if (keycode == 8'h2C) begin
                        flag_stun_potion <= 0; // super stun used
                        temp_flag_stun <= 1;
                        health_opp <= health_opp+10; // attack and opp loses turn
                     end
                     else begin
                         case (B%3) 
                             2'd0: health_opp <= health_opp+10; // attack and opp loses turn
                             2'd1: health_user <= health_user + 5; // self-harm and opp does not lose turn
                             2'd2: health_user <= health_user + 5; // self-harm and opp does not lose turn
                             default: health_user<= health_user;
                         endcase
			         end
			         counter_battle <= counter_battle + 1; 
			     end
			     else if (counter_battle < 7'd120)
			        counter_battle <= counter_battle + 1;
			     else begin
			         counter_battle <= 0;
//			         temp_flag_stun <= 0;
			     end
			 end
			 
			 else if(char_state == show_user_move_heal) begin
//			     B <= B * M;
			     if (counter_battle == 0) begin
			         if (keycode == 8'h2C) begin
			             flag_heal_potion <= 0;
			             health_user <= 0;
			         end
			         else begin
                         if (health_user > 15)
                             health_user <= health_user-15;
                         else
                             health_user <= 0;
			         end
			         counter_battle <= counter_battle + 1; 
			     end
			     else if (counter_battle < 7'd120)
			        counter_battle <= counter_battle + 1;
			     else
			         counter_battle <= 0;
			 end			 
			 
			 else if (char_state == show_opp) begin
			     if (counter_battle == 1) begin
//			         B <= B * M;
                     if ( (boss_bit == 0) || (boss_bit == 1) ) begin
                         case (B%3) 
                             2'd0: begin
                                     if (health_user < 80) 
                                         health_user <= health_user+20; // attack
                                     else
                                         health_user <= 100;
                                 end
                             2'd1: begin 
                                     case (B%5)
                                         3'd0: health_user<= health_user+10; //stun success
                                         3'd1: health_user<= health_user+10; //stun success
                                         3'd2: health_opp<= health_opp+5; //stun failure
                                         3'd3: health_opp<= health_opp+5; //stun failure
                                         3'd4: health_opp<= health_opp+5; //stun failure
                                         default: health_opp <= health_opp;
                                     endcase
                                 end
                             2'd2: begin 
                                 if (health_opp > 15)
                                     health_opp <= health_opp - 15;
                                 else
                                     health_opp <= 0;
                             end
                             default: health_user<= health_user;
                         endcase
                     end
                     else begin
                         case (B%3) 
                             2'd0: begin
                                     if (health_user < 65) 
                                         health_user <= health_user+35; // attack
                                     else
                                         health_user <= 100;
                                 end
                             2'd1: begin 
                                     case (B%5)
                                         3'd0: health_user<= health_user+15; //stun success
                                         3'd1: health_user<= health_user+15; //stun success
                                         3'd2: health_user<= health_user+15; //stun failure
                                         3'd3: health_opp<= health_opp+5; //stun failure
                                         3'd4: health_opp<= health_opp+5; //stun failure
                                         default: health_opp <= health_opp;
                                     endcase
                                 end
                             2'd2: begin 
                                 if (health_opp > 25)
                                     health_opp <= health_opp - 25;
                                 else
                                     health_opp <= 0;
                             end
                             default: health_user<= health_user;
                         endcase                     
                     end
			         counter_battle <= counter_battle + 1;
			     end
			     else if (counter_battle < 7'd120)
			        counter_battle <= counter_battle + 1;
			     else
			         counter_battle <= 0;
			 end
			 
            else if (char_state == win_eceb) begin
                 if (counter_battle == 0) begin
                     if (boss_bit == 2)
                        credits <= credits + 3;
                     else
                        credits <= credits + 2;
                     counter_battle <= counter_battle + 1;
                 end
                 if (counter_battle < 7'd120)
                     counter_battle <= counter_battle + 1;
                 else
                     counter_battle <= 0;
            end		

            else if (char_state == loss_eceb) begin
                 if (counter_battle < 7'd120)
                     counter_battle <= counter_battle + 1;
                 else
                     counter_battle <= 0;
            end	     
        
            // buying attack potion
			else if(char_state == potion_end_attack) begin
//			     B <= B * M;
			     if (counter_battle == 0) begin
                    credits <= credits - 1;
                    counter_battle <= counter_battle + 1; 
                    flag_attack_potion <= 1'b1;
			     end
			     else if (counter_battle < 7'd10) begin
			        counter_battle <= counter_battle + 1; 
			        end           	    
			     else begin
			         counter_battle <= 0;
			         end
			 end    
			
			// buying heal potion 
			else if(char_state == potion_end_heal) begin
//			     B <= B * M;
			     if (counter_battle == 0) begin
                    credits <= credits - 1;
                    counter_battle <= counter_battle + 1; 
                    flag_heal_potion <= 1'b1;
			     end
			     else if (counter_battle < 7'd10) begin
			        counter_battle <= counter_battle + 1; 
			        end           	    
			     else begin
			         counter_battle <= 0;
			         end
			 end
			 
			// buying stun potion 
			else if(char_state == potion_end_stun) begin
//			     B <= B * M;
			     if (counter_battle == 0) begin
                    credits <= credits - 1;
                    counter_battle <= counter_battle + 1; 
                    flag_stun_potion <= 1'b1;
			     end
			     else if (counter_battle < 7'd10) begin
			        counter_battle <= counter_battle + 1; 
			        end           	    
			     else begin
			         counter_battle <= 0;
			         end
			 end			 			                	 
			 
//			 else
//			     B <= B * M;
		 
	   end
	end
	
	
	
	// next B logic
	always_comb begin
	   B_next = B;
	   
	   if (char_state == show_user_move_stun || char_state == show_opp) begin
	       if (counter_battle == 0)
	           B_next = B * M;
           else
               B_next = B;	       
	   end
	   
	   else
	       B_next = B * M;

	end
	
	// Next-state logic
	always_comb
	begin
	   char_next_state = char_state;
	   
	   // if battle-scene is on
	   if (battle_bit == 1) begin
	       if (char_state == up_face_stand_foot)
	           char_next_state = init_boss;
	       else if (char_state == init_boss) begin
	           if (counter_battle == 7'd120)
	               char_next_state = attack;
	           else
	               char_next_state = init_boss;
	       end
	       else if (char_state == attack) begin
                case(keycode)
                    8'h1A: char_next_state = attack;
                    8'h16: char_next_state = heal;
                    8'h04: char_next_state = attack;
                    8'h07: char_next_state = stun;
                    8'h28: char_next_state = show_user_move_attack;
                    8'h2C: begin
                                if (flag_attack_potion)
                                    char_next_state = show_user_move_attack;
                                else
                                    char_next_state = char_state;                              
                           end
                    default: char_next_state = attack;
                endcase
	       end
	       else if (char_state == stun) begin
                case(keycode)
                    8'h1A: char_next_state = stun;
                    8'h16: char_next_state = run;
                    8'h04: char_next_state = attack;
                    8'h07: char_next_state = stun;
                    8'h28: char_next_state = show_user_move_stun;
                    8'h2C: begin
                                if (flag_stun_potion)
                                    char_next_state = show_user_move_stun;
                                else
                                    char_next_state = char_state;                              
                           end                    
                    default: char_next_state = stun;
                endcase
	       end
	       else if (char_state == heal) begin
                case(keycode)
                    8'h1A: char_next_state = attack;
                    8'h16: char_next_state = heal;
                    8'h04: char_next_state = heal;
                    8'h07: char_next_state = run;
                    8'h28: char_next_state = show_user_move_heal;
                    8'h2C: begin
                                if (flag_heal_potion)
                                    char_next_state = show_user_move_heal;
                                else
                                    char_next_state = char_state;                              
                           end                    
                    default: char_next_state = heal;
                endcase
	       end	
	       else if (char_state == run) begin
                case(keycode)
                    8'h1A: char_next_state = stun;
                    8'h16: char_next_state = run;
                    8'h04: char_next_state = heal;
                    8'h07: char_next_state = run;
                    8'h28: char_next_state = show_user_move_run;
                    default: char_next_state = run;
                endcase
	       end	 
	       else if (char_state == show_user_move_attack || char_state == show_user_move_heal) begin
	           if (counter_battle == 7'd120) begin
                   if (health_opp >= 8'd100)
                       char_next_state = win_eceb;	 
                   else          
	                   char_next_state = show_opp;
	            end
	            else
	               char_next_state = char_state;
	       end
	       
	       else if (char_state == show_user_move_stun) begin
	           if (counter_battle == 7'd120) begin
                   if (health_opp >= 8'd100)
                       char_next_state = win_eceb;
                   else if (health_user >= 8'd100)
                       char_next_state = loss_eceb;	           
	               else if ( (B%3 == 0) || (temp_flag_stun == 1))
	                    char_next_state = attack;
	               else
	                   char_next_state = show_opp;
	            end
	            else
	               char_next_state = char_state;
	       end	       
	        
	       else if (char_state == show_user_move_run) begin
	           char_next_state = down_face_stand_foot;
	       end
	       
	       else if (char_state == show_opp) begin
	           if (counter_battle == 7'd120) begin
                   if (health_opp >= 8'd100)
                       char_next_state = win_eceb;	       
                   else if (health_user >= 8'd100)
                       char_next_state = loss_eceb;	           
	               else if ( B%3 == 1) begin
	                   if (boss_bit == 2) begin
	                       if (B%5 <= 2)
	                           char_next_state = show_opp;
	                       else
	                           char_next_state = attack; 
	                   end
	                   else begin
	                       if (B%5 <= 1)
	                           char_next_state = show_opp;
	                       else
	                           char_next_state = attack; 
	                   end
	               end
	               else 
	                   char_next_state = attack;
	           end
	           else
	               char_next_state = char_state;	           
	       end
	       
	       else if ( (char_state == win_eceb) || (char_state == loss_eceb)) begin
	           if (counter_battle == 7'd120)
	               char_next_state = down_face_stand_foot;
	           else
	               char_next_state = char_state;	
	      end       
	                        
	   end
	   
	   else if (battle_bit == 2) begin
	       if (char_state == up_face_stand_foot)
	           char_next_state = attack_potion;
	       else if (char_state == attack_potion) begin
                case(keycode)
                    8'h04: char_next_state = attack_potion;
                    8'h16: char_next_state = stun_potion;
                    8'h07: char_next_state = heal_potion;
                    8'h29: char_next_state = down_face_stand_foot;
                    8'h28: begin
                                if (credits == 0)
                                    char_next_state = char_state;
                                else begin
                                    if (flag_attack_potion) // already have potion
                                        char_next_state = char_state;
                                    else
                                        char_next_state = potion_end_attack;
                                end
                           end
                    default: char_next_state = char_state;
                endcase
	       end	    
	       else if (char_state == stun_potion) begin
                case(keycode)
                    8'h04: char_next_state = attack_potion;
                    8'h16: char_next_state = stun_potion;
                    8'h07: char_next_state = heal_potion;
                    8'h29: char_next_state = down_face_stand_foot;
                    8'h28: begin
                                if (credits == 0)
                                    char_next_state = char_state;
                                else begin
                                    if (flag_stun_potion) // already have potion
                                        char_next_state = char_state;
                                    else
                                        char_next_state = potion_end_stun;
                                end
                           end
                    default: char_next_state = char_state;
                endcase
	       end	  
	       else if (char_state == heal_potion) begin
                case(keycode)
                    8'h04: char_next_state = attack_potion;
                    8'h16: char_next_state = stun_potion;
                    8'h07: char_next_state = heal_potion;
                    8'h29: char_next_state = down_face_stand_foot;
                    8'h28: begin
                                if (credits == 0)
                                    char_next_state = char_state;
                                else begin
                                    if (flag_heal_potion) // already have potion
                                        char_next_state = char_state;
                                    else
                                        char_next_state = potion_end_heal;
                                end
                           end
                    default: char_next_state = char_state;
                endcase
	       end		
	       else if (char_state == potion_end_attack) begin
	           if (counter_battle == 7'd10)
	               char_next_state = attack_potion;    
	           else
	               char_next_state = char_state;
	       end 
	       
	       else if (char_state == potion_end_heal) begin
	           if (counter_battle == 7'd10)
	               char_next_state = attack_potion;    
	           else
	               char_next_state = char_state;
	       end
	       
	       else if (char_state == potion_end_stun) begin
	           if (counter_battle == 7'd10)
	               char_next_state = attack_potion;    
	           else
	               char_next_state = char_state;
	       end	       	                     	 
	   end  
	   
	   // if battle-scene is off
	   else begin
           case (keycode)
               8'h1A: begin
                   if (char_state == up_face_left_foot)
                       char_next_state = up_face_right_foot;
                   else if (char_state == up_face_right_foot)
                       char_next_state = up_face_left_foot;
                   else if (char_state == up_face_stand_foot)
                       char_next_state = up_face_left_foot;
                   else
                       char_next_state = up_face_stand_foot;
               end
               8'h16: begin
                   if (char_state == down_face_left_foot)
                       char_next_state = down_face_right_foot;
                   else if (char_state == down_face_right_foot)
                       char_next_state = down_face_left_foot;
                  else if (char_state == down_face_stand_foot)
                       char_next_state = down_face_left_foot;
                   else
                       char_next_state = down_face_stand_foot;
               end
               8'h04: begin
                   if (char_state == left_face_left_foot)
                       char_next_state = left_face_right_foot;
                   else if (char_state == left_face_right_foot)
                       char_next_state = left_face_left_foot;
                   else if (char_state == left_face_stand_foot)
                       char_next_state = left_face_left_foot;
                   else
                       char_next_state = left_face_stand_foot;
               end
               8'h07: begin
                   if (char_state == right_face_left_foot)
                       char_next_state = right_face_right_foot;
                   else if (char_state == right_face_right_foot)
                       char_next_state = right_face_left_foot;
                   else if (char_state == right_face_stand_foot)
                       char_next_state = right_face_left_foot;
                   else
                       char_next_state = right_face_stand_foot;
               end
               
               default: begin
                   if (char_state == down_face_left_foot || char_state == down_face_right_foot)
                       char_next_state = down_face_stand_foot;
                   else if (char_state == up_face_left_foot || char_state == up_face_right_foot)
                       char_next_state = up_face_stand_foot;
                   else if (char_state ==left_face_left_foot || char_state == left_face_right_foot)
                       char_next_state = left_face_stand_foot;
                   else if (char_state == right_face_left_foot || char_state == right_face_right_foot)
                       char_next_state = right_face_stand_foot;
                   else
                       char_next_state = char_state;     
               end
           endcase
       end   
	end
	
	// battle-bit and boss_bit outputs
	always_comb begin
	   if ((char_state == up_face_stand_foot) && (FrameX + BallX + 8 - 200 >= 180) && (FrameX + BallX + 8 - 200 <= 195) && (FrameY + BallY + 17 - 160 >= 120) && (FrameY + BallY + 17 - 160 <= 140)) begin
	       battle_bit = 2'b1;
	       boss_bit = 2'b0;
	   end
	   else if ((char_state == up_face_stand_foot) && (FrameX + BallX + 8 - 200 >= 177) && (FrameX + BallX + 8 - 200 <= 200) && (FrameY + BallY + 17 - 160 >= 273) && (FrameY + BallY + 17 - 160 <= 290)) begin 
	   	   battle_bit = 2'b1;
	       boss_bit = 2'b1;    
	   end
	   else if ((char_state == up_face_stand_foot) && (FrameX + BallX + 8 - 200 >= 272) && (FrameX + BallX + 8 - 200 <= 288) && (FrameY + BallY + 17 - 160 >= 273) && (FrameY + BallY + 17 - 160 <= 290)) begin 
	   	   battle_bit = 2'b1;
	       boss_bit = 2'd2;    
	   end	   
	   else if (char_state == init_boss || char_state == attack || char_state == stun || char_state == heal || char_state == run || char_state == show_user_move_attack || char_state == show_user_move_stun || char_state == show_user_move_heal || char_state == show_user_move_run || char_state == show_opp || char_state == win_eceb || char_state == loss_eceb) begin
	       battle_bit = 2'b1;
	       if ( (FrameX + BallX + 8 - 200 >= 180) && (FrameX + BallX + 8 - 200 <= 195) && (FrameY + BallY + 17 - 160 >= 120) && (FrameY + BallY + 17 - 160 <= 140) )
	           boss_bit = 2'b0;
	       else if ((FrameX + BallX + 8 - 200 >= 177) && (FrameX + BallX + 8 - 200 <= 200) && (FrameY + BallY + 17 - 160 >= 273) && (FrameY + BallY + 17 - 160 <= 290))
	           boss_bit = 2'b1;
	       else
	           boss_bit = 2'd2;
       end
	   else if ((char_state == up_face_stand_foot) && (FrameX + BallX + 8 - 200 >= 275) && (FrameX + BallX + 8 - 200 <= 295) && (FrameY + BallY + 17 - 160 >= 200) && (FrameY + BallY + 17 - 160 <= 215)) begin 
	   	   battle_bit = 2'd2;
	       boss_bit = 2'b0;    
	   end         
	   else if ((char_state == attack_potion) || (char_state == stun_potion) || (char_state == heal_potion) || (char_state == potion_end_attack) || (char_state == potion_end_heal) || (char_state == potion_end_stun)) begin
	   	   battle_bit = 2'd2;
	       boss_bit = 2'b0;	       
	   end  
	   else begin
	       battle_bit = 2'b0;
	       boss_bit = 2'b0;
	   end
	end
	
	// battle-state output
	always_comb begin
	   battle_state = 4'd0;
	   if (char_state == init_boss)
	       battle_state = 4'd0;
	   else if (char_state == attack)
	       battle_state = 4'd1;
	   else if (char_state == stun)
	       battle_state = 4'd2;
	   else if (char_state == heal)
	       battle_state = 4'd3;
	   else if (char_state == run)
	       battle_state = 4'd4;
	   else if (char_state == show_user_move_attack)
	       battle_state = 4'd5;
	   else if (char_state == show_user_move_stun)
	       battle_state = 4'd6;
	   else if (char_state == show_user_move_heal)
	       battle_state = 4'd7;
	   else if (char_state == show_user_move_run)
	       battle_state = 4'd8;	 
	   else if (char_state == show_opp)
	       battle_state = 4'd9;	  
	   else if (char_state == win_eceb)
	       battle_state = 4'd10;
	   else if (char_state == loss_eceb)
	       battle_state = 4'd11;	 
	   else if ( (char_state == attack_potion) || (char_state == potion_end_attack) )
	       battle_state = 4'd12;
	   else if ( (char_state == stun_potion) || (char_state == potion_end_stun) )
	       battle_state = 4'd13;
	   else if ( (char_state == heal_potion) || (char_state == potion_end_heal) )
	       battle_state = 4'd14;	       	       	                 
	end
	
	// rom-address (for character motion) outpout
	always_comb begin
	   if(rel_x <17 && rel_y<34 && rel_x>=0 && rel_y>=0) begin
           case (char_state)
               down_face_left_foot: rom_address = rel_x + rel_y*51;
               down_face_stand_foot: rom_address = (rel_x + 17) + rel_y*51;
               down_face_right_foot: rom_address = (rel_x + 17 + 17) + rel_y*51;
               
               up_face_left_foot: rom_address = rel_x + ((rel_y + 34)*51);
               up_face_stand_foot: rom_address = (rel_x + 17) + ((rel_y + 34)*51);
               up_face_right_foot: rom_address = (rel_x + 17 + 17) + ((rel_y + 34)*51);
               
               left_face_left_foot: rom_address = rel_x + ((rel_y + 34 + 34)*51);
               left_face_stand_foot: rom_address = (rel_x + 17) + ((rel_y + 34 + 34)*51);
               left_face_right_foot: rom_address = (rel_x + 17 + 17) + ((rel_y + 34 + 34)*51);
               
               right_face_left_foot: rom_address = rel_x + ((rel_y + 34 + 34 + 34)*51);
               right_face_stand_foot: rom_address = (rel_x + 17) + ((rel_y + 34 + 34 + 34)*51);
               right_face_right_foot: rom_address = (rel_x + 17 + 17) + ((rel_y + 34 + 34 + 34)*51);
               
               default: rom_address = (rel_x + 17) + ((rel_y + 34)*51);
           endcase
       end
       else
           rom_address = 0;
	end
	
	

	always_comb begin
	   attack_user_on = 1'b0;
	   health_user_on = 1'b0;
	   stun_user_on = 1'b0;
	   attack_opp_on = 1'b0;
	   text_on = 1'b0;
	   stun_opp_on = 1'b0;
	   
	   rom_address_user_attack = 0;
	   rom_address_user_health = 0;
	   rom_address_user_stun = 0;
	   rom_address_opp_attack = 0;
	   rom_address_text = 0;
	   rom_address_opp_stun = 0;
	   
	   
	   if (char_state == show_user_move_attack) begin
	        if(rel_x_opp>=0 && rel_y_opp>=0 && rel_x_opp<40 && rel_y_opp<35) begin
	            attack_user_on = 1'b1;
                rom_address_user_attack = rel_x_opp + ((rel_y_opp+ (35*(counter_battle >> 4))) * 40 );
                end
            else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                text_on = 1'b1;
                rom_address_text = rel_x_text + ((rel_y_text+ (34*4)) * 73 );
            end
	   end
	   else if (char_state == show_user_move_heal) begin
	        if(rel_x_user>=0 && rel_y_user>=0 && rel_x_user<40 && rel_y_user<35) begin
	            health_user_on = 1'b1;
                rom_address_user_health = rel_x_user + ((rel_y_user+ (35*(counter_battle/24))) * 40 );
                end
            else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                text_on = 1'b1;
                rom_address_text = rel_x_text + ((rel_y_text+ (34*5)) * 73 );
            end             
	   end
	   else if ( (char_state == show_user_move_stun) && (counter_battle >= 1)) begin
	       if ((B%3== 0) || (temp_flag_stun == 1)) begin
	           if(rel_x_opp>=0 && rel_y_opp>=0 && rel_x_opp<40 && rel_y_opp<35) begin
	               stun_user_on = 1'b1;
                    rom_address_user_stun = rel_x_opp + ((rel_y_opp+ (35*((2*counter_battle/30)%4))) * 40 );
                end
                else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                    text_on = 1'b1;
                    rom_address_text = rel_x_text + ((rel_y_text+ (34*6)) * 73 );
                end                
	        end	       
	       else begin
	           if(rel_x_user>=0 && rel_y_user>=0 && rel_x_user<40 && rel_y_user<35) begin
	               stun_user_on = 1'b1;
	               rom_address_user_stun = rel_x_user + ((rel_y_user+ (35*((2*counter_battle/30)%4))) * 40 );
	           end
                else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                    text_on = 1'b1;
                    rom_address_text = rel_x_text + ((rel_y_text+ (34*7)) * 73 );
                end	           
            end 
	   end
	   else if (char_state == show_opp) begin
	       if (B%3 == 2'd0 && counter_battle >= 1) begin
	           //attack
	           if(rel_x_user>=0 && rel_y_user>=0 && rel_x_user<40 && rel_y_user<35) begin
	               attack_opp_on = 1'b1;
	               rom_address_opp_attack = rel_x_user + ((rel_y_user+ (35*(counter_battle/20))) * 40 );
	           end	  
               else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                    text_on = 1'b1;
                    rom_address_text = rel_x_text + ((rel_y_text+ (34*8)) * 73 );
               end	                    
	       end
	       
	       else if ( (B%3 == 2'd2) && (counter_battle >= 1)) begin
                if(rel_x_opp>=0 && rel_y_opp>=0 && rel_x_opp<40 && rel_y_opp<35) begin
                    health_user_on = 1'b1;
                    rom_address_user_health = rel_x_opp + ((rel_y_opp+ (35*(counter_battle/24))) * 40 );
                end
                else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                    text_on = 1'b1;
                    rom_address_text = rel_x_text + ((rel_y_text+ (34*9)) * 73 );
                end            	       
	       end 
	       // stun
	       else if ( (B%3 == 2'd1) && (counter_battle >= 1)) begin
	           if (boss_bit == 2) begin
	               // success
                   if (B%5 <= 2) begin
                       if(rel_x_user>=0 && rel_y_user>=0 && rel_x_user<40 && rel_y_user<35) begin
                           stun_opp_on = 1'b1;
                            rom_address_opp_stun = rel_x_user + ((rel_y_user+ (35*((2*counter_battle/30)%4))) * 40 );
                        end
                        else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                            text_on = 1'b1;
                            rom_address_text = rel_x_text + ((rel_y_text+ (34*10)) * 73 );
                        end                
                    end
                    
                    // failure
                    else begin
                       if(rel_x_opp>=0 && rel_y_opp>=0 && rel_x_opp<40 && rel_y_opp<35) begin
                           stun_opp_on = 1'b1;
                           rom_address_opp_stun = rel_x_opp + ((rel_y_opp+ (35*((2*counter_battle/30)%4))) * 40 );
                       end
                        else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                            text_on = 1'b1;
                            rom_address_text = rel_x_text + ((rel_y_text+ (34*11)) * 73 );
                        end	                
                    end	           
	           end
	           else begin
	               // success
                   if (B%5 <= 1) begin
                       if(rel_x_user>=0 && rel_y_user>=0 && rel_x_user<40 && rel_y_user<35) begin
                           stun_opp_on = 1'b1;
                            rom_address_opp_stun = rel_x_user + ((rel_y_user+ (35*((2*counter_battle/30)%4))) * 40 );
                        end
                        else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                            text_on = 1'b1;
                            rom_address_text = rel_x_text + ((rel_y_text+ (34*10)) * 73 );
                        end                
                    end
                    
                    // failure
                    else begin
                       if(rel_x_opp>=0 && rel_y_opp>=0 && rel_x_opp<40 && rel_y_opp<35) begin
                           stun_opp_on = 1'b1;
                           rom_address_opp_stun = rel_x_opp + ((rel_y_opp+ (35*((2*counter_battle/30)%4))) * 40 );
                       end
                        else if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                            text_on = 1'b1;
                            rom_address_text = rel_x_text + ((rel_y_text+ (34*11)) * 73 );
                        end	                
                    end
                end                   
	       end
	   end
	   
	   else if (char_state ==  attack) begin
            if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                text_on = 1'b1;
                rom_address_text = rel_x_text + ((rel_y_text+ (34*0)) * 73 );
            end	   
	   end
	   
	   else if (char_state ==  heal) begin
            if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                text_on = 1'b1;
                rom_address_text = rel_x_text + ((rel_y_text+ (34*1)) * 73 );
            end	   
	   end
	   
	   else if (char_state ==  stun) begin
            if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                text_on = 1'b1;
                rom_address_text = rel_x_text + ((rel_y_text+ (34*2)) * 73 );
            end	   
	   end
	   
	   else if (char_state ==  run) begin
            if (rel_x_text >= 0 && rel_y_text >= 0 && rel_x_text < 73 && rel_y_text < 34) begin
                text_on = 1'b1;
                rom_address_text = rel_x_text + ((rel_y_text+ (34*3)) * 73 );
            end	   
	   end	   	   	   
	end
	
       
endmodule
