//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf     03-01-2006                           --
//                                  03-12-2007                           --
//    Translated by Joe Meng        07-07-2013                           --
//    Modified by Zuofu Cheng       08-19-2023                           --
//    Modified by Satvik Yellanki   12-17-2023                           --
//    Fall 2024 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI Lab                                --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball 
( 
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode,

    output logic [9:0]  BallX, 
    output logic [9:0]  BallY, 
//    output logic [9:0]  BallS ,
    
//    output logic [17:0] rom_address_b,
    input logic [3:0] pelette_index,
    
    input logic [9:0]  FrameX, 
    input logic [9:0]  FrameY,
    
//    output logic collision_bit,
//    input logic collision_bit,
    output logic [17:0] read_address,
    input logic [1:0] battle_bit
);
    

	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=200;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=439;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=160;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=319;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    logic [9:0] Ball_X_Motion;
    logic [9:0] Ball_X_Motion_next;
    logic [9:0] Ball_Y_Motion;
    logic [9:0] Ball_Y_Motion_next;

    logic [9:0] Ball_X_next;
    logic [9:0] Ball_Y_next;
    
//    logic [17:0] read_address;
    logic [9:0]  BallSx;
    logic [9:0]  BallSy;
//    logic collision_bit;
    
//    collision_map colide(.readaddr(read_address), .col_bit(collision_bit));
    

    always_comb begin
        Ball_Y_Motion_next = Ball_Y_Motion; // set default motion to be same as prev clock cycle 
        Ball_X_Motion_next = Ball_X_Motion;
        read_address = 0;

        //modify to control ball motion with the keycode
        if ((battle_bit == 1) || (battle_bit == 2) ) begin
            Ball_Y_Motion_next = 0;
            Ball_X_Motion_next = 0;
            read_address = 0;
        end
        else if (keycode == 8'h1A) begin
            read_address = (FrameX + BallX + 8 + 0 - 200) + ((BallY + 17 - 160 - 1 + FrameY) *380);
            if (pelette_index == 4'd2 || pelette_index == 4'd13 || pelette_index == 4'd0 || pelette_index == 4'd15)
                Ball_Y_Motion_next = -10'd1;
            else
                Ball_Y_Motion_next = 10'd0;
            Ball_X_Motion_next = 10'd0;
            end
        
        else if(keycode == 8'h16) begin
            read_address = (FrameX + BallX + 8 + 0 - 200) + ((BallY + (17+17) - 160 + 1 + FrameY) *380);
            if (pelette_index == 4'd2 || pelette_index == 4'd13 || pelette_index == 4'd0 || pelette_index == 4'd15)
                Ball_Y_Motion_next = 10'd1;
            else
                Ball_Y_Motion_next = 10'd0;
            Ball_X_Motion_next = 10'd0;
            end

        else if(keycode == 8'h04) begin
        read_address = (FrameX + BallX + (8-8) - 1 - 200) + ((BallY + 33 - 160 + 0 + FrameY) *380);
            if (pelette_index == 4'd2 || pelette_index == 4'd13 || pelette_index == 4'd0 || pelette_index == 4'd15)
                Ball_X_Motion_next = -10'd1;
            else
                Ball_X_Motion_next = 10'd0;
            Ball_Y_Motion_next = 10'd0;
            end
                        
        else if(keycode == 8'h07) begin
        read_address = (FrameX + BallX + (8+8) + 1 - 200) + ((BallY + 33 - 160 + 0 + FrameY) *380);
            if (pelette_index == 4'd2 || pelette_index == 4'd13 || pelette_index == 4'd0 || pelette_index == 4'd15)
                Ball_X_Motion_next = 10'd1;
            else
                Ball_X_Motion_next = 10'd0;
            Ball_Y_Motion_next = 10'd0;
            end
        else begin
            Ball_X_Motion_next = 10'd0;
            Ball_Y_Motion_next = 10'd0;    
        end
        
        
        if ( (BallY + BallSy) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
        begin
            Ball_Y_Motion_next = (~ (Ball_Y_Step) + 1'b1);  // set to -1 via 2's complement.
        end
        else if ( (BallY) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
        begin
            Ball_Y_Motion_next = Ball_Y_Step;
        end  
       //fill in the rest of the motion equations here to bounce left and right
        if ( (BallX + BallSx) >= Ball_X_Max )  // Ball is at the bottom edge, BOUNCE!
        begin
            Ball_X_Motion_next = (~ (Ball_X_Step) + 1'b1);  // set to -1 via 2's complement.
        end
        else if ( (BallX) <= Ball_X_Min )  // Ball is at the top edge, BOUNCE!
        begin
            Ball_X_Motion_next = Ball_X_Step;
        end 
    end

    assign BallSx = 17;  // default ball size
    assign BallSy = 34;  // default ball size
    assign Ball_X_next = (BallX + Ball_X_Motion_next);
    assign Ball_Y_next = (BallY + Ball_Y_Motion_next);
   
    always_ff @(posedge frame_clk) //make sure the frame clock is instantiated correctly
    begin: Move_Ball
        if (Reset)
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
			Ball_X_Motion <= 10'd0; //Ball_X_Step;
            
			BallY <= Ball_Y_Center;
			BallX <= Ball_X_Center;
        end
        else 
        begin 

			Ball_Y_Motion <= Ball_Y_Motion_next; 
			Ball_X_Motion <= Ball_X_Motion_next; 

            BallY <= Ball_Y_next;  // Update ball position
            BallX <= Ball_X_next;
			
		end  
    end






//logic boundary_check [0:154279];



    
      
endmodule
