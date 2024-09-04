////-------------------------------------------------------------------------
////    Color_Mapper.sv                                                    --
////    Stephen Kempf                                                      --
////    3-1-06                                                             --
////                                                                       --
////    Modified by David Kesler  07-16-2008                               --
////    Translated by Joe Meng    07-07-2013                               --
////    Modified by Zuofu Cheng   08-19-2023                               --
////                                                                       --
////    Fall 2023 Distribution                                             --
////                                                                       --
////    For use with ECE 385 USB + HDMI                                    --
////    University of Illinois ECE Department                              --
////-------------------------------------------------------------------------


//module  Color_Mapper ( 
//                       input  logic [9:0] BallX, BallY, 
//                       input  logic [9:0] DrawX, DrawY, 
////                       input logic [31:0] slave_reg_data_in,
//                       input logic [31:0] palette_in [16],
////                       input logic [31:0] slave_reg_control,
//                       input  logic [9:0] Ball_size,
//                       output logic [7:0]  Red, Green, Blue );
    
////    logic ball_on;
//    logic shape_on;

    
//    logic [7:0] n;
    
////    logic [1:0] bucket_num; 
//    logic bucket_num;
//    logic inv;
    
//    int DistX, DistY, Size;
//    assign DistX = DrawX - BallX;
//    assign DistY = DrawY - BallY;
//    assign Size = Ball_size;
//    logic ball_on;
    
    
//    always_comb
//    begin:Ball_on_proc
//        if ( (DistX*DistX + DistY*DistY) <= (Size * Size) )
//            ball_on = 1'b1;
//        else 
//            ball_on = 1'b0;
//     end 

//    logic [10:0] sprite_addr;
//    logic [7:0] sprite_data;
////    font_rom fr1(.addr(sprite_addr), .data(sprite_data));
    
//    logic [3:0] background;
//    logic [3:0] foreground;
//    logic [9:0] tempX;
//    logic [9:0] tempY;	 
//    logic offscreen;
//    logic [15:0]background_addr;
//    logic [3:0] background_index;



//always_comb
//begin 
//    if (DrawX < 200 || DrawY<160 || DrawX > 440 ||DrawY >320)
//    begin
//        offscreen = 1;
//        tempX = 0;
//        tempY = 0;
//    end
//    else
//    begin
//        offscreen = 0;
//        tempX = DrawX-200;
//        tempY = DrawY-160;
//    end
//end

//assign background_addr = (tempX + tempY*240);

//backram bckrm(.read_address(background_addr),.data_Out(background_index));



//logic [31:0] reg_clr;
//assign reg_clr = palette_in[background_index];

//always_comb
//begin
//    if(offscreen)
//    begin 
//        Red = 8'hFF;
//        Green = 8'hFF;
//        Blue = 8'hFF;
//     end
//    else
//    begin
//        if(ball_on)
//        begin
//            Red = 4'hf;
//            Green = 4'h7;
//            Blue = 4'h0;
//        end 
//        else
//        begin
//            Red = reg_clr[7:0];
//            Green = reg_clr[15:8];
//            Blue = reg_clr[23:16];
//        end
//    end
//end
//endmodule
