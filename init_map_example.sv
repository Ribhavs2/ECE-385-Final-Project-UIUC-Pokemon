module init_map_example (
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY, FrameX, FrameY,
	input  logic [9:0] BallX, BallY,
	input logic blank,
	input logic [12:0] rom_addr_charecter,
	output logic [3:0] red, green, blue,
	input logic [7:0] health_opp,
	input logic [7:0] health_user,
	
	output logic [17:0] rom_address,
	input logic [3:0] rom_q,
	
	input logic [1:0] battle_bit,
	input logic [3:0] battle_state,
	
	input logic [13:0] rom_address_user_attack,
	input logic [12:0] rom_address_user_health,
	input logic [12:0] rom_address_user_stun,
	
	input logic [13:0] rom_address_opp_attack,
	input logic [12:0] rom_address_opp_stun,
	
	input logic [14:0] rom_address_text,
	
	input logic attack_user_on,
	input logic health_user_on,
	input logic stun_user_on,
	input logic attack_opp_on,
	input logic stun_opp_on,
	
	input logic text_on,
	
	input logic [1:0] boss_bit
);

//logic [17:0] rom_address;
//logic [3:0] rom_q;
//31+health/3
logic [3:0] palette_red, palette_green, palette_blue, palette_red_character, palette_blue_character, palette_green_character;
logic [3:0] palette_red_boss, palette_green_boss, palette_blue_boss;
logic [3:0] palette_red_boss2, palette_green_boss2, palette_blue_boss2;
logic [3:0] palette_red_boss3, palette_green_boss3, palette_blue_boss3;

logic [3:0] palette_red_battle_bkg, palette_green_battle_bkg, palette_blue_battle_bkg;
logic [3:0] palette_red_potion_bkg, palette_green_potion_bkg, palette_blue_potion_bkg;

logic [3:0] palette_red_user_attack, palette_green_user_attack,palette_blue_user_attack;
logic [3:0] palette_red_health, palette_green_health, palette_blue_health;
logic [3:0] palette_red_user_stun, palette_green_user_stun, palette_blue_user_stun;

logic [3:0] palette_red_opp_attack, palette_green_opp_attack, palette_blue_opp_attack;
logic [3:0] palette_red_opp_stun, palette_green_opp_stun, palette_blue_opp_stun;

logic [3:0] palette_red_text, palette_green_text, palette_blue_text;

logic [3:0] palette_red_user_pok, palette_green_user_pok, palette_blue_user_pok;
logic [3:0] palette_red_fpga_pok, palette_green_fpga_pok, palette_blue_fpga_pok;
logic [3:0] palette_red_ill_pok, palette_green_ill_pok, palette_blue_ill_pok;
logic [3:0] palette_red_uiuc_pok, palette_green_uiuc_pok, palette_blue_uiuc_pok;

logic [3:0] palette_red_dialogues, palette_green_dialogues, palette_blue_dialogues;



logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
// this will stretch out the sprite across the entire screen
logic [9:0] tempX;
logic [9:0] tempY;	 

logic [9:0] tempX_user_pok;
logic [9:0] tempY_user_pok;

logic [9:0] tempX_fpga_pok;
logic [9:0] tempY_fpga_pok;

logic [9:0] tempX_dialogues;
logic [9:0] tempY_dialogues;

logic user_pok_on;
logic fpga_pok_on;

logic dialogues_on;

logic offscreen;
logic [13:0] rom_address_boss;

logic [15:0] rom_address_battle_bkg;

logic [10:0] rom_address_user_pok;
logic [10:0] rom_address_fpga_pok;

logic [14:0] rom_address_dialogues;

always_comb
begin 
    if (DrawX < 200 || DrawY<160 || DrawX > 439 ||DrawY >319)
    begin
        offscreen = 1;
        tempX = 0;
        tempY = 0;
    end
    else
    begin
        offscreen = 0;
        tempX = DrawX-200;
        tempY = DrawY-160;
    end
end

//assign rom_address = ((DrawX * 240) / 640) + (((DrawY * 160) / 480) * 240);
assign rom_address =(FrameX + tempX) + ((tempY + FrameY) *380);
assign rom_address_battle_bkg = (tempX) + (( tempY) *240);

assign tempX_user_pok = DrawX - (200 + 41);
assign tempY_user_pok = DrawY - (160 + 67);

assign tempX_fpga_pok = DrawX - (200 + 160);
assign tempY_fpga_pok = DrawY - (160 + 23);

assign tempX_dialogues = DrawX - (200 + 20);
assign tempY_dialogues = DrawY - (160 + 15);

always_comb  begin
    if (tempX >= 82 && tempX < 157)
        rom_address_boss = (tempX-82) + (( tempY) *75);
    else
        rom_address_boss = 0;
end

// user_pokemon on
always_comb begin
    if (tempX_user_pok >= 0 && tempY_user_pok >=0 && tempX_user_pok < 42 && tempY_user_pok < 40) begin
        rom_address_user_pok = tempX_user_pok + (tempY_user_pok * 42);
        user_pok_on = 1'b1;
    end
    else begin
        rom_address_user_pok = 0;
        user_pok_on = 1'b0;        
    end
end

// fpga pokemon on
always_comb begin
    if (tempX_fpga_pok >= 0 && tempY_fpga_pok >=0 && tempX_fpga_pok < 42 && tempY_fpga_pok < 40) begin
        rom_address_fpga_pok = tempX_fpga_pok + (tempY_fpga_pok * 42);
        fpga_pok_on = 1'b1;
    end
    else begin
        rom_address_fpga_pok = 0;
        fpga_pok_on = 1'b0;        
    end
end


// dialogues
always_comb begin
    if (tempX_dialogues >= 0 && tempY_dialogues >= 0 && tempX_dialogues < 80 && tempY_dialogues < 59) begin
        dialogues_on = 1'b1;
        if (battle_state == 0) begin
           if (boss_bit == 0)
                rom_address_dialogues =  tempX_dialogues + (tempY_dialogues * 80);
           else if (boss_bit == 1)
                rom_address_dialogues =  tempX_dialogues + ((tempY_dialogues + (59*1)) * 80);
           else 
                rom_address_dialogues =  tempX_dialogues + ((tempY_dialogues + (59*4)) * 80);
        end
        else if (battle_state == 10)
            rom_address_dialogues =  tempX_dialogues + ((tempY_dialogues + (59*2)) * 80);
        else if (battle_state == 11)
            rom_address_dialogues =  tempX_dialogues + ((tempY_dialogues + (59*3)) * 80);
        else begin
           dialogues_on = 1'b0;
           rom_address_dialogues = 0;
        end
    end
    else begin
        rom_address_dialogues = 0;
        dialogues_on = 1'b0;
    end
end
 



logic [3:0] index_char;
logic [3:0] index_boss;
logic [3:0] index_boss2;
logic [3:0] index_boss3;

logic [4:0] index_battle_bkg;
logic [3:0] index_potion_bkg;

logic [2:0] user_attack_rom_q, health_rom_q, user_stun_rom_q, opp_attack_rom_q, opp_stun_rom_q;

logic [3:0] text_rom_q;

logic [4:0] user_pok_rom_q;
logic [4:0] fpga_pok_rom_q;
logic [4:0] ill_pok_rom_q;
logic [4:0] uiuc_pok_rom_q;

logic [2:0] dialogues_rom_q;



logic ball_on;
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*BallS, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))
       )

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 120 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    logic [9:0] DistX, DistY;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
//    assign Size = Ball_size;
    logic [9:0] cursorX, cursorY;
    logic [9:0] rel_cursor_X, rel_cursor_Y;
    assign rel_cursor_X = DrawX - cursorX;
    assign rel_cursor_Y = DrawY - cursorY;
    logic cursor_on;
    
    logic [9:0] healthX, healthY;
    logic [9:0] rel_health_Opp_X, rel_health_Opp_Y;
    assign rel_health_Opp_X = DrawX - healthX;
    assign rel_health_Opp_Y = DrawY - healthY;
    logic health_on;
    
    logic [9:0] healthUserX, healthUserY;
    logic [9:0] rel_health_User_X, rel_health_User_Y;
    assign rel_health_User_X = DrawX - healthUserX;
    assign rel_health_User_Y = DrawY - healthUserY;
    logic health_on_User;
  
  
    always_comb
    begin:Ball_on_proc
        if ( (DistX <17 && DistY<34 && DistX>=0 && DistY>=0) && index_char != 0)
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
     
     
     always_comb
     begin
        // choosing moves
        if (battle_state == 4'd1 || battle_state == 4'd5) begin
            cursorX = 92 + 200;
            cursorY = 121 + 160;
        end
        else if (battle_state == 4'd2 || battle_state == 4'd6) begin
            cursorX = 152 + 200;
            cursorY = 121 + 160;
        end
        else if (battle_state == 4'd3 || battle_state == 4'd7) begin
            cursorX = 92 + 200;
            cursorY = 143 + 160;
        end        
        else if (battle_state == 4'd4 || battle_state == 4'd8) begin
            cursorX = 152 + 200;
            cursorY = 143 + 160;
        end
        
        // choosing potions
        else if (battle_state == 4'd12) begin
            cursorX = 24 + 200;
            cursorY = 135 + 160;
        end
        else if (battle_state == 4'd13) begin
            cursorX = 117 + 200;
            cursorY = 135 + 160;
        end
        else if (battle_state == 4'd14) begin
            cursorX = 195 + 200;
            cursorY = 135 + 160;
        end                
        
        else begin
            cursorX = 92 + 200;
            cursorY = 121 + 160;        
        end  
        
        
        if (rel_cursor_X >= 0 && rel_cursor_X <10 && rel_cursor_Y >= 0 && rel_cursor_Y <10) 
            cursor_on = 1'b1;
        else
            cursor_on = 1'b0;     
     end
     
     // health bars
     always_comb
     begin
        if (health_opp >= 100)
            healthX = 200 + 31 + 36 - 36;
        else
            healthX = 200 + 31 + 36 - (health_opp/3);
        healthY = 160 + 28;
        
        if (health_user >= 100)
            healthUserX = 200 + 197 + 2 + 36 - 38;
        else 
            healthUserX = 200 + 197 + 2 + 36 - (health_user/3);
        healthUserY = 160 + 83;
       
       if (health_opp>=100 && rel_health_Opp_X>=0 && rel_health_Opp_X<36 && rel_health_Opp_Y>0 && rel_health_Opp_Y < 3) begin
            health_on = 1'b1;
            health_on_User = 1'b0;
       end
       else if(rel_health_Opp_X>=0 && rel_health_Opp_X<(health_opp/3) && rel_health_Opp_Y>0 && rel_health_Opp_Y < 3) begin
            health_on = 1'b1;
            health_on_User = 1'b0;
        end               
        else if (health_user >= 100 && rel_health_User_X>= 0 && rel_health_User_X<38 && rel_health_User_Y>0 && rel_health_User_Y < 5) begin
            health_on = 1'b0;
            health_on_User = 1'b1;
        end
        else if (rel_health_User_X>= 0 && rel_health_User_X<(health_user/3) && rel_health_User_Y>0 && rel_health_User_Y < 5) begin
            health_on = 1'b0;
            health_on_User = 1'b1;
        end
        else begin
            health_on = 1'b0;
            health_on_User = 1'b0;
        end         
     end

always_ff @ (posedge vga_clk) begin
	red <= 4'h0;
	green <= 4'h0;
	blue <= 4'h0;

//	if (blank) begin
    if (!offscreen) begin
        // no battle
        if (battle_bit == 0) begin
            if (ball_on == 1'b1) begin 
                red <= palette_red_character;
                green <= palette_green_character;
                blue <= palette_blue_character;
            end 
            else begin
                red <= palette_red;
                green <= palette_green;
                blue <= palette_blue;
            end
        end
        // battle on 
        else  if (battle_bit == 1) begin
            if (battle_state == 4'd0 || battle_state == 4'd11 || battle_state == 4'd10) begin
               if (dialogues_on) begin
                   red <= palette_red_dialogues;
                   green <= palette_green_dialogues;
                   blue <= palette_blue_dialogues;               
               end
               else begin
                   if (boss_bit == 0) begin
                       red <= palette_red_boss;
                       green <= palette_green_boss;
                       blue <= palette_blue_boss;
                   end
                   else if (boss_bit == 1) begin
                       red <= palette_red_boss2;
                       green <= palette_green_boss2;
                       blue <= palette_blue_boss2;                   
                   end
                   else begin
                       red <= palette_red_boss3;
                       green <= palette_green_boss3;
                       blue <= palette_blue_boss3;                   
                   end                   
               end
            end
            else begin
               red <= palette_red_battle_bkg;
               green <= palette_green_battle_bkg;
               blue <= palette_blue_battle_bkg;            
                
                if (cursor_on) begin
                   red <= 4'h0;
                   green <= 4'h0;
                   blue <= 4'h0;                    
                end
                if ((user_pok_on) && (user_pok_rom_q != 1)) begin
                   red <= palette_red_user_pok;
                   green <= palette_green_user_pok;
                   blue <= palette_blue_user_pok;                 
                end
                if ( (fpga_pok_on)) begin
                   if ( (boss_bit == 0)  && (fpga_pok_rom_q != 1)) begin
                       red <= palette_red_fpga_pok;
                       green <= palette_green_fpga_pok;
                       blue <= palette_blue_fpga_pok;
                   end 
                   else if ( (boss_bit == 1)  && (ill_pok_rom_q != 0)) begin
                       red <= palette_red_ill_pok;
                       green <= palette_green_ill_pok;
                       blue <= palette_blue_ill_pok;
                   end     
                   else if (boss_bit == 2) begin
                       if (uiuc_pok_rom_q != 0) begin
                           red <= palette_red_uiuc_pok;
                           green <= palette_green_uiuc_pok;
                           blue <= palette_blue_uiuc_pok;
                       end
                   end                                                
                end                
                if (health_on || health_on_User) begin
                   red <= 4'hF;
                   green <= 4'h0;
                   blue <= 4'h0;                    
                end
                if (attack_user_on == 1'b1 && user_attack_rom_q != 1)begin
                   red <= palette_red_user_attack;
                   green <= palette_green_user_attack;
                   blue <= palette_blue_user_attack;
                end
                if (health_user_on == 1'b1 && health_rom_q != 0)begin
                   red <= palette_red_health;
                   green <= palette_green_health;
                   blue <= palette_blue_health; 
                end
                if (stun_user_on == 1'b1 && user_stun_rom_q != 0)begin
                   red <= palette_red_user_stun;
                   green <= palette_green_user_stun;
                   blue <= palette_blue_user_stun; 
                end
                if (attack_opp_on == 1'b1 && opp_attack_rom_q != 0)begin
                   red <= palette_red_opp_attack;
                   green <= palette_green_opp_attack;
                   blue <= palette_blue_opp_attack; 
                end
                if (stun_opp_on == 1'b1 && opp_stun_rom_q != 0)begin
                   red <= palette_red_opp_stun;
                   green <= palette_green_opp_stun;
                   blue <= palette_blue_opp_stun; 
                end                
                if (text_on) begin
                   red <= palette_red_text;
                   green <= palette_green_text;
                   blue <= palette_blue_text;                
                end                
//                else begin
//                   red <= palette_red_battle_bkg;
//                   green <= palette_green_battle_bkg;
//                   blue <= palette_blue_battle_bkg;
//                end
            end                
        end
        else begin
               red <= palette_red_potion_bkg;
               green <= palette_green_potion_bkg;
               blue <= palette_blue_potion_bkg;   

                if (cursor_on) begin
                   red <= 4'h0;
                   green <= 4'h0;
                   blue <= 4'h0;                    
                end                        
        end        
	end
end

//back_ROM init_map_rom (
//	.clka   (negedge_vga_clk),
//	.addra (rom_address),
//	.douta       (rom_q)
//);

init_map_palette init_map_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

character_bram Character_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_addr_charecter),
	.douta       (index_char)
);

Character_palette Character_palette (
	.index (index_char),
	.red   (palette_red_character),
	.green (palette_green_character),
	.blue  (palette_blue_character)
);

// Zoufu
boss_ROM boss_bram (
	.clka   (negedge_vga_clk),
	.addra (rom_address_boss),
	.douta       (index_boss)
);

Boss_palette Boss_palette (
	.index (index_boss),
	.red   (palette_red_boss),
	.green (palette_green_boss),
	.blue  (palette_blue_boss)
);

// Bashir
boss_ROM2 boss_bram2 (
	.clka   (negedge_vga_clk),
	.addra (rom_address_boss),
	.douta       (index_boss2)
);

Boss_palette2 Boss_palette2 (
	.index (index_boss2),
	.red   (palette_red_boss2),
	.green (palette_green_boss2),
	.blue  (palette_blue_boss2)
);

// Jones
boss_ROM3 boss_bram3 (
	.clka   (negedge_vga_clk),
	.addra (rom_address_boss),
	.douta       (index_boss3)
);

Boss_palette3 Boss_palette3 (
	.index (index_boss3),
	.red   (palette_red_boss3),
	.green (palette_green_boss3),
	.blue  (palette_blue_boss3)
);

// Battle background
battle_bkg_ROM battle_bkg_bram (
	.clka   (negedge_vga_clk),
	.addra (rom_address_battle_bkg),
	.douta       (index_battle_bkg)
);

battle_bkg_palette battle_palette (
	.index (index_battle_bkg),
	.red   (palette_red_battle_bkg),
	.green (palette_green_battle_bkg),
	.blue  (palette_blue_battle_bkg)
);

// Potion background
potion_bkg_ROM potion_bkg_ROM (
	.clka   (negedge_vga_clk),
	.addra (rom_address_battle_bkg),
	.douta       (index_potion_bkg)
);

potion_bkg_palette potion_bkg_palette (
	.index (index_potion_bkg),
	.red   (palette_red_potion_bkg),
	.green (palette_green_potion_bkg),
	.blue  (palette_blue_potion_bkg)
);

// user attack motion
user_attack_rom user_attack_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_user_attack),
	.douta       (user_attack_rom_q)
);

user_attack_palette user_attack_palette (
	.index (user_attack_rom_q),
	.red   (palette_red_user_attack),
	.green (palette_green_user_attack),
	.blue  (palette_blue_user_attack)
);

// user health motion
health_rom health_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_user_health),
	.douta       (health_rom_q)
);

health_palette health_palette (
	.index (health_rom_q),
	.red   (palette_red_health),
	.green (palette_green_health),
	.blue  (palette_blue_health)
);

// user stun motion
user_stun_rom user_stun_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_user_stun),
	.douta       (user_stun_rom_q)
);

user_stun_palette user_stun_palette (
	.index (user_stun_rom_q),
	.red   (palette_red_user_stun),
	.green (palette_green_user_stun),
	.blue  (palette_blue_user_stun)
);

// opp attack motion
opp_attack_rom opp_attack_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_opp_attack),
	.douta       (opp_attack_rom_q)
);

opp_attack_palette opp_attack_palette (
	.index (opp_attack_rom_q),
	.red   (palette_red_opp_attack),
	.green (palette_green_opp_attack),
	.blue  (palette_blue_opp_attack)
);

// Opp stun motion
opp_stun_rom opp_stun_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_opp_stun),
	.douta       (opp_stun_rom_q)
);

opp_stun_palette opp_stun_palette (
	.index (opp_stun_rom_q),
	.red   (palette_red_opp_stun),
	.green (palette_green_opp_stun),
	.blue  (palette_blue_opp_stun)
);

// text
text_rom text_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_text),
	.douta       (text_rom_q)
);

text_palette text_palette (
	.index (text_rom_q),
	.red   (palette_red_text),
	.green (palette_green_text),
	.blue  (palette_blue_text)
);

// user_pokemon
user_pok_rom user_pok_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_user_pok),
	.douta       (user_pok_rom_q)
);

user_pok_palette user_pok_palette (
	.index (user_pok_rom_q),
	.red   (palette_red_user_pok),
	.green (palette_green_user_pok),
	.blue  (palette_blue_user_pok)
);

// Zoufu's FPGA pokemon
fpga_pok_rom fpga_pok_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_fpga_pok),
	.douta       (fpga_pok_rom_q)
);

fpga_pok_palette fpga_pok_palette (
	.index (fpga_pok_rom_q),
	.red   (palette_red_fpga_pok),
	.green (palette_green_fpga_pok),
	.blue  (palette_blue_fpga_pok)
);

// Bashir's I pokemon
ill_pok_rom ill_pok_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_fpga_pok),
	.douta       (ill_pok_rom_q)
);

ill_pok_palette ill_pok_palette (
	.index (ill_pok_rom_q),
	.red   (palette_red_ill_pok),
	.green (palette_green_ill_pok),
	.blue  (palette_blue_ill_pok)
);

// Jone's UIUC pokemon
uiuc_pok_rom uiuc_pok_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_fpga_pok),
	.douta       (uiuc_pok_rom_q)
);

uiuc_pok_palette uiuc_pok_palette (
	.index (uiuc_pok_rom_q),
	.red   (palette_red_uiuc_pok),
	.green (palette_green_uiuc_pok),
	.blue  (palette_blue_uiuc_pok)
);

// Dialogues
dialogues_rom dialogues_rom (
	.clka   (negedge_vga_clk),
	.addra (rom_address_dialogues),
	.douta       (dialogues_rom_q)
);

dialogues_palette dialogues_palette (
	.index (dialogues_rom_q),
	.red   (palette_red_dialogues),
	.green (palette_green_dialogues),
	.blue  (palette_blue_dialogues)
);
endmodule
