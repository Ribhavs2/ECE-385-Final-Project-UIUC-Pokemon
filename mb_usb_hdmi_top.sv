//-------------------------------------------------------------------------
//    mb_usb_hdmi_top.sv                                                 --
//    Zuofu Cheng                                                        --
//    2-29-24                                                            --
//                                                                       --
//                                                                       --
//    Spring 2024 Distribution                                           --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0]hdmi_tmds_data_n,
    output logic [2:0]hdmi_tmds_data_p,
        
    //HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);
    
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, clk, clk_100MHz;
    logic locked;
    logic [9:0] drawX, drawY, ballxsig, ballysig, ballsizesig, framex, framey;

    logic hsync, vsync, vde;
    logic [3:0] red, green, blue;
    logic reset_ah;
    logic col;
    logic [12:0] rom_addr_char;
    logic [17:0] temp_rom_address_b;
    logic [3:0] pelette_index_b;
    
    logic [17:0] temp_rom_address_a;
    logic [3:0] rom_q_a;
    
    logic [1:0] battle_on;
    logic [3:0] battle_status;
    
    logic [7:0] health_opp;
    logic [7:0] health_user;
    
    logic [13:0] rom_address_user_attack;
    logic [12:0] rom_address_user_health;
    logic [12:0] rom_address_user_stun;
    
    logic [13:0] rom_address_opp_attack;
    logic [12:0] rom_address_opp_stun;
    
    logic [14:0] rom_address_text;
    
    logic attack_user_on;
    logic health_user_on;
    logic stun_user_on;
    logic attack_opp_on;
    logic stun_opp_on;
    
    logic text_on;
    
    logic [1:0] boss_bit;
    logic [3:0] credits;
    logic [3:0] num_attack_potions;
    logic [3:0] num_heal_potions;
    logic [3:0] num_stun_potions;
    
    assign reset_ah = reset_rtl_0;
    
    
    //Keycode HEX drivers
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({num_attack_potions, num_stun_potions, num_heal_potions, credits}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );
    
    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    mb_block mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah), //Block designs expect active low reset, all other modules are active high
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );
        
    //clock wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );

    
    //Ball Module
    ball ball_instance(
        .Reset(reset_ah),
        .frame_clk(vsync),                    //Figure out what this should be so that the ball will move
        .keycode(keycode0_gpio[7:0]),    //Notice: only one keycode connected to ball by default
        .BallX(ballxsig),
        .BallY(ballysig),
//        .BallS(ballsizesig),
        .read_address(temp_rom_address_b),
        .pelette_index(pelette_index_b),
        .FrameX(framex),
        .FrameY(framey),
        .battle_bit(battle_on)
//        .collision_bit(col)
    );
    
     map map_instance(
        .Reset(reset_ah), 
        .frame_clk(vsync),
        .keycode(keycode0_gpio[7:0]),
        
        .FrameX(framex),
        .FrameY(framey),
//        .collision_bit(col)
        .pelette_index(pelette_index_b),
        .battle_bit(battle_on)
    );
    
    back_ROM_interface bkg_interface(
        .vga_clk(clk_25MHz),
        .rom_address_a(temp_rom_address_a),
        .rom_q_a(rom_q_a),
        
        .rom_address_b(temp_rom_address_b),
        .rom_q_b(pelette_index_b)
    );
    
    
    
    //Color Mapper Module   
//    color_mapper color_instance(
//        .BallX(ballxsig),
//        .BallY(ballysig),
//        .DrawX(drawX),
//        .DrawY(drawY),
//        .Ball_size(ballsizesig),
//        .Red(red),
//        .Green(green),
//        .Blue(blue)
//    );
init_map_example background(
	.vga_clk(clk_25MHz),
	.DrawX(drawX), 
	.DrawY(drawY),
	.FrameX(framex),
	.FrameY(framey),
    .BallX(ballxsig),
    .BallY(ballysig),
//    .Ball_size(ballsizesig),
	.blank(vde),
	.rom_addr_charecter(rom_addr_char),
	.red(red), 
	.green(green), 
	.blue(blue),
	
	.rom_address(temp_rom_address_a),
	.rom_q(rom_q_a),
	
	.battle_bit(battle_on),
	.battle_state(battle_status),
	
	.health_opp(health_opp),
	.health_user(health_user),
	
	.rom_address_user_attack(rom_address_user_attack),
	.rom_address_user_health(rom_address_user_health),
	.rom_address_user_stun(rom_address_user_stun),
	
	.rom_address_opp_attack(rom_address_opp_attack),
	.rom_address_opp_stun(rom_address_opp_stun),
	
	.rom_address_text(rom_address_text),
	
	.attack_user_on(attack_user_on),
	.health_user_on(health_user_on),
	.stun_user_on(stun_user_on),
	.attack_opp_on(attack_opp_on),
	.stun_opp_on(stun_opp_on),
	
	.text_on(text_on),
	.boss_bit(boss_bit)
);

character_motion  char_mot(
    .reset(reset_ah),
    .clk(vsync),
	.DrawX(drawX), 
	.DrawY(drawY),
    .BallX(ballxsig),
    .BallY(ballysig),
    .keycode(keycode0_gpio[7:0]),

    .rom_address(rom_addr_char),
    .battle_bit(battle_on),
    
    .FrameX(framex),
    .FrameY(framey),
    
    .battle_state(battle_status),
    
    .health_opp(health_opp),
    .health_user(health_user),
    
    .rom_address_user_attack(rom_address_user_attack),
    .rom_address_user_health(rom_address_user_health),
    .rom_address_user_stun(rom_address_user_stun),
    
    .rom_address_opp_attack(rom_address_opp_attack),
    .rom_address_opp_stun(rom_address_opp_stun),
    
    .rom_address_text(rom_address_text),
    
    .attack_user_on(attack_user_on),
    .health_user_on(health_user_on),
    .stun_user_on(stun_user_on),
    .attack_opp_on(attack_opp_on),
    .stun_opp_on(stun_opp_on),
    
    .text_on(text_on),
    
    .boss_bit(boss_bit),
    
    .credits(credits),
    .num_attack_potions(num_attack_potions),
    .num_heal_potions(num_heal_potions),
    .num_stun_potions(num_stun_potions)
);
endmodule
