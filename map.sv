`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2024 01:51:29 PM
// Design Name: 
// Module Name: map
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module map(
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [7:0]  keycode,

    output logic [9:0]  FrameX, 
    output logic [9:0]  FrameY,
    
//    input logic collision_bit
    input logic [3:0] pelette_index,
    
    input logic [1:0] battle_bit
    );
    
    parameter [9:0] Frame_X_Corner=0;  // Top-left starting X axis
    parameter [9:0] Frame_Y_Corner=0;  // Top-left starting on the Y axis
    parameter [9:0] Frame_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Frame_X_Max=379;     // Rightmost point on the X axis
    parameter [9:0] Frame_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Frame_Y_Max=406;     // Bottommost point on the Y axis
    parameter [9:0] Frame_X_Step=2;      // Step size on the X axis
    parameter [9:0] Frame_Y_Step=2;      // Step size on the Y axis
    
    
    logic [9:0] Frame_X_Motion;
    logic [9:0] Frame_X_Motion_next;
    logic [9:0] Frame_Y_Motion;
    logic [9:0] Frame_Y_Motion_next;

    logic [9:0] Frame_X_next;
    logic [9:0] Frame_Y_next;

    always_comb begin
        Frame_X_Motion_next = Frame_X_Motion; // set default motion to be same as prev clock cycle 
        Frame_Y_Motion_next = Frame_Y_Motion;
        
        if (pelette_index != 4'd2 && pelette_index != 4'd13 && pelette_index != 4'd0 && pelette_index != 4'd15) begin
            Frame_Y_Motion_next = 10'd0;
            Frame_X_Motion_next = 10'd0;
        end
        else begin

            //modify to control ball motion with the keycode
            if ((battle_bit == 1) || (battle_bit == 2) ) begin
                Frame_Y_Motion_next = 10'd0;
                Frame_X_Motion_next = 10'd0;
            end
            else if (keycode == 8'h1A) begin
                if (FrameY <= Frame_Y_Min)
                    Frame_Y_Motion_next = 10'd0;
                else
                    Frame_Y_Motion_next = -10'd1;
                    
                Frame_X_Motion_next = 10'd0;
                end
            
            else if(keycode == 8'h16) begin
                if ((FrameY + 160) >= Frame_Y_Max)
                    Frame_Y_Motion_next = 10'd0;
                else
                    Frame_Y_Motion_next = 10'd1;
                    
                Frame_X_Motion_next = 10'd0;
                end
    
            else if(keycode == 8'h04) begin
                if (FrameX <= Frame_X_Min)
                    Frame_X_Motion_next = 10'd0;
                else
                    Frame_X_Motion_next = -10'd1;
                    
                Frame_Y_Motion_next = 10'd0;
                end
                            
            else if(keycode == 8'h07) begin
                if ((FrameX + 240) >= Frame_X_Max)
                    Frame_X_Motion_next = 10'd0;
                else
                    Frame_X_Motion_next = 10'd1;
                    
                Frame_Y_Motion_next = 10'd0;
                end
            else begin
                Frame_X_Motion_next = 10'd0;
                Frame_Y_Motion_next = 10'd0;    
            end
        end
    end




    assign Frame_X_next = (FrameX + Frame_X_Motion_next);
    assign Frame_Y_next = (FrameY + Frame_Y_Motion_next);
   
    always_ff @(posedge frame_clk) //make sure the frame clock is instantiated correctly
    begin: Move_Frame
        if (Reset)
        begin 
            Frame_Y_Motion <= 10'd0; //Ball_Y_Step;
			Frame_X_Motion <= 10'd0; //Ball_X_Step;
            
			FrameX <= Frame_X_Corner;
			FrameY <= Frame_Y_Corner;
        end
        else 
        begin 

			Frame_Y_Motion <= Frame_Y_Motion_next; 
			Frame_X_Motion <= Frame_X_Motion_next; 

            FrameY <= Frame_Y_next;  // Update ball position
            FrameX <= Frame_X_next;
			
		end  
    end
    
    
endmodule
