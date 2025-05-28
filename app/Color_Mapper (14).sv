//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [10:0] BallX, BallY, DrawX, DrawY, Ball_size,
                       input        [10:0] enemyX,enemyY, enemy1X,enemy1Y,
							  input [2:0] livesCount, //input thats keeps track of lives
							  input [3:0] playerVelocity, enemyVelocity, enemy1Velocity,
							  input Clk,Reset, Winscreen,GameOver,
							  input [4:0] flagDisplay, //Determines which flags are displayed
							  input [3:0] flagcount,      //Tells score what flagcount is
							  output [4:0] flagBurst, //detects collision with flag
							  
							  input [1:0] levelindex, //determines which map is drawn
							  output crash_on,
							  //output [9:0] enemyOffsetX, enemyOffsetY,
							  output[4:0] map_on,mapE_on,map1E_on,
                       output logic [7:0]  Red, Green, Blue );
    
    
	 
	 parameter [10:0] BallXCenter=320;  // Center position on the X axis 
    parameter [10:0] BallYCenter=240;  // Center position on the Y axis 
                                        // In the scrolling implementation, the player will no longer move with regard to the map
													 // He will be on the center of the screen while the map moves around them
  
	 logic [10:0] BallMapX,BallMapY,enemyMapX,enemyMapY,enemy1MapX,enemy1MapY;
	 logic ball_on,ballmap_on;
	 logic enemy_on,enemy1_on; //displaying the enemy sprite
	 logic enemymap_on,enemy1map_on; //displaying the minimap enemy
	 logic flag0_on,flag1_on,flag2_on,flag3_on; //Used for flag display
    logic [10:0] enemyOffsetX,enemyOffsetY,collideEnemyOffsetX,collideEnemyOffsetY; //This is used for moving the enemies away as we move, this makes it so that the enemy shifts with the map
	 
	 
	 assign enemyOffsetX=BallX-BallXCenter;  //This handles deciding the offset when drawing enemies for scrolling
	 assign enemyOffsetY=BallY-BallYCenter;  //If the offset is negative we have to manually set the offset to be in
	 
	 always_comb                             //This handles moving the collision hitbox depending on what quadrant they are being scrolled on
	 begin                                   //With the original playercenter as the origin
	 if(BallX>BallXCenter)
	 collideEnemyOffsetX=0;
	 else
	 collideEnemyOffsetX=-16;
	 
	 if(BallY>BallYCenter)
	 collideEnemyOffsetY=0;
	 else
	 collideEnemyOffsetY=-16;
	 end
	 
//////////////// The enemy cars were facing some stranger rendering glitches due to scrolling, this area adjusts
///////////////  the indexes so that the cars are show the correct pixel depending on the quadrant with ball center being origin	 
	 int EdistIndexX,EdistIndexY,E1distIndexX,E1distIndexY;  //
	 always_comb
	 begin
	 if(BallX>BallXCenter)
	 EdistIndexX=EdistX;
	 else
	 EdistIndexX=EdistX+16;
	 
	 if(BallX>BallXCenter)
	 E1distIndexX=E1distX;
	 else
	 E1distIndexX=E1distX+16;
	 
	 if(BallY>BallYCenter)
	 EdistIndexY=EdistY;
	 else
	 EdistIndexY=EdistY+16;
	 
	 if(BallY>BallYCenter)
	 E1distIndexY=E1distY;
	 else
	 E1distIndexY=E1distY+16;
	 
	 
	 end
	 
///Colliding of cars
always_comb
begin:car_collision
    if((BallXCenter >= (collideEnemyOffsetX+enemyX-enemyOffsetX) && ((collideEnemyOffsetX+enemyX-enemyOffsetX+16) >= BallXCenter) &&  (BallYCenter >= (collideEnemyOffsetY+enemyY-enemyOffsetY)) && collideEnemyOffsetY+enemyY-enemyOffsetY+16 >= BallYCenter)) //Checking Top left corner collision with enemy0
	 crash_on=1;
	 else if((BallXCenter >= (collideEnemyOffsetX+enemy1X-enemyOffsetX)) && ((collideEnemyOffsetX+enemy1X-enemyOffsetX+16) >= BallXCenter) &&  (BallYCenter >= (collideEnemyOffsetY+enemy1Y-enemyOffsetY) && (collideEnemyOffsetY+enemy1Y-enemyOffsetY+16) >= BallYCenter)) //Checking Top left corner collision with enemy1
	 crash_on=1;
	 else if((BallXCenter+16 >= (collideEnemyOffsetX+enemy1X-enemyOffsetX) && (collideEnemyOffsetX+enemy1X-enemyOffsetX+16) >= BallXCenter+16) &&  (BallYCenter+16 >= collideEnemyOffsetY+enemy1Y -enemyOffsetY && collideEnemyOffsetY+enemy1Y-enemyOffsetY+16 >= BallYCenter+16))//Checking bottom right corner collision enemy1 
	 crash_on=1;
	 else if((BallXCenter+16 >= collideEnemyOffsetX+enemyX-enemyOffsetX && collideEnemyOffsetX+enemyX-enemyOffsetX+16 >= BallXCenter+16) &&  (BallYCenter+16 >= collideEnemyOffsetY+enemyY-enemyOffsetY && collideEnemyOffsetY+enemyY-enemyOffsetY+16 >= BallYCenter+16))//Checking bottom right corner collision enemy0 
	 crash_on=1;
	 else
	 crash_on=0;
end

//Colliding of flags
always_comb
begin:flag0_collision
    if((BallXCenter >= (1024-enemyOffsetX) && ((1024-enemyOffsetX+16) >= BallXCenter) &&  (BallYCenter >= (624-enemyOffsetY)) && 624-enemyOffsetY+16 >= BallYCenter)) //Checking Top left corner collision with enemy0
	 flagBurst[0]=1'b1;
	 else if((BallXCenter+16 >= (1024-enemyOffsetX) && (1024-enemyOffsetX+16) >= BallXCenter+16) &&  (BallYCenter+16 >= 624-enemyOffsetY && 624-enemyOffsetY+16 >= BallYCenter+16))//Checking bottom right corner collision enemy1 
	 flagBurst[0]=1'b1;	
	 else
	 flagBurst[0]=1'b0;
end

always_comb
begin:flag1_collision
    if((BallXCenter >= (768-enemyOffsetX) && ((768-enemyOffsetX+16) >= BallXCenter) &&  (BallYCenter >= (688-enemyOffsetY)) && 688-enemyOffsetY+16 >= BallYCenter)) //Checking Top left corner collision with enemy0
	 flagBurst[1]=1'b1;
	 else if((BallXCenter+16 >= (768-enemyOffsetX) && (768-enemyOffsetX+16) >= BallXCenter+16) &&  (BallYCenter+16 >= 688-enemyOffsetY && 688-enemyOffsetY+16 >= BallYCenter+16))//Checking bottom right corner collision enemy1 
	 flagBurst[1]=1'b1;
	 else
	 flagBurst[1]=1'b0;
end

always_comb
begin:flag2_collision
    if((BallXCenter >= (1200-enemyOffsetX) && ((1200-enemyOffsetX+16) >= BallXCenter) &&  (BallYCenter >= (928-enemyOffsetY)) && 928-enemyOffsetY+16 >= BallYCenter)) //Checking Top left corner collision with enemy0
	 flagBurst[2]=1'b1;
	 else if((BallXCenter+16 >= (1200-enemyOffsetX) && (1200-enemyOffsetX+16) >= BallXCenter+16) &&  (BallYCenter+16 >= 928-enemyOffsetY && 928-enemyOffsetY+16 >= BallYCenter+16))//Checking bottom right corner collision enemy1 
	 flagBurst[2]=1'b1;
	 else
	 flagBurst[2]=1'b0;
end

always_comb
begin:flag3_collision
    if((BallXCenter >= (480-enemyOffsetX) && ((480-enemyOffsetX+16) >= BallXCenter) &&  (BallYCenter >= (800-enemyOffsetY)) && 800-enemyOffsetY+16 >= BallYCenter)) //Checking Top left corner collision with enemy0
	 flagBurst[3]=1'b1;
	 else if((BallXCenter+16 >= (480-enemyOffsetX) && (480-enemyOffsetX+16) >= BallXCenter+16) &&  (BallYCenter+16 >= 800-enemyOffsetY && 800-enemyOffsetY+16 >= BallYCenter+16))//Checking bottom right corner collision enemy1 
	 flagBurst[3]=1'b1;
	 else
	 flagBurst[3]=1'b0;
end
///////This is for the collision of the player, bit 0 top left, 1 top right, 2 bottom left, 3 bottom right, 4 center

	 assign map_on[0]=mapC_data[(BallXCenter/16)]; //will tell us if there is a wall at given cordinate, used for collision
    assign map_on[1]=mapC_data[((BallXCenter+16)/16)];     //Top Right
	 assign map_on[2]=mapC1_data[(BallXCenter/16)];    //Bottom Left
	 assign map_on[3]=mapC1_data[((BallXCenter+16)/16)];   //Bottom Right
	 assign map_on[4]=mapC_data[((BallXCenter+8)/16)];  //Center
	
//////This is for collision of the enemy with walls, bit 0 top left, 1 top right, 2 bottom left, 3 bottom right, 4 center
	 assign mapE_on[0]=mapE_data[((enemyX-enemyOffsetX)/16)]; //will tell us if there is a wall at given cordinate, used for collision
    assign mapE_on[1]=mapE_data[((enemyX-enemyOffsetX+16)/16)];     //Top Right
	 assign mapE_on[2]=mapE1_data[((enemyX-enemyOffsetX)/16)];    //Bottom Left
	 assign mapE_on[3]=mapE1_data[((enemyX-enemyOffsetX+16)/16)];   //Bottom Right
	 
//////This is for collision of the enemy with walls, bit 0 top left, 1 top right, 2 bottom left, 3 bottom right, 4 center
	 assign map1E_on[0]=map1E_data[((enemy1X-enemyOffsetX)/16)]; //will tell us if there is a wall at given cordinate, used for collision
    assign map1E_on[1]=map1E_data[((enemy1X-enemyOffsetX+16)/16)];     //Top Right
	 assign map1E_on[2]=map1E1_data[((enemy1X-enemyOffsetX)/16)];    //Bottom Left
	 assign map1E_on[3]=map1E1_data[((enemy1X-enemyOffsetX+16)/16)];   //Bottom Right
	 
//////

	 logic[10:0] sprite_addr;
	 logic[15:0] sprite_data,sprite_enemy,sprite_enemy1;  //Holds the sprite data for player and enemy cars
	 logic[39:0] map_data,mapC_data,mapC1_data,mapE_data,mapE1_data,map1E_data,map1E1_data; //holds the data for the map
	                                            //mapC_data holds data for player's top corners used to check collision
															  //mapC1_data holds data for player's bottom corners used to check collision
	 
////////////////////////////These case statements determine the index we will use to grab the correct sprite for enemies and player

	 int playerIndex,enemyIndex,enemy1Index,leadindex; //This index will be used to index through the sprite sheet for the player
	 
	 always_comb  //This always comb takes the velocity and picks the sprite based on the orientation through index
	 begin
	 if(crash_on == 0)
	 begin
	 case(playerVelocity)
	 4'b0001:
	 playerIndex=  0;
	 4'b0010:
	 playerIndex= 512;
	 4'b0100:
	 playerIndex= 256;
	 4'b1000:
	 playerIndex= 768;
	 default: playerIndex=0;
	 endcase
	 end 
	 else 
	 playerIndex = 1024; 
	 end
	 
	 always_comb
	 begin
	 case(enemyVelocity)
	 4'b0001:
	 enemyIndex=0;
	 4'b0010:
	 enemyIndex=512;
	 4'b0100:
	 enemyIndex=256;
	 4'b1000:
	 enemyIndex=768;
	 default: enemyIndex=0;
	 endcase
	 
	 case(enemy1Velocity)
	 4'b0001:
	 enemy1Index=0;
	 4'b0010:
	 enemy1Index=512;
	 4'b0100:
	 enemy1Index=256;
	 4'b1000:
	 enemy1Index=768;
	 default: enemy1Index=0;
	 endcase
	 
	 case(flagcount)
	 3'b000:
	 leadindex=1536;
	 3'b001:
	 leadindex=1024;
	 3'b010:
	 leadindex=1152;
	 3'b011:
	 leadindex=1280;
	 3'b100:
	 leadindex=1408;
	 default: leadindex=1536;
	 endcase
	 
	 end
	 
	 ///////////////////////////////////////////To draw multicolored sprites we will used these variables and modules
	 logic[2:0] color_car; 
	 logic[2:0] colore1;
	 logic[2:0] colore2; 
	 logic[3:0] logo_data;
	 logic[3:0] text_data; 
	 logic[2:0] zero_data; 
	 logic[2:0] lead_data;
	 logic[2:0] ysl;
	 logic[2:0] troph;
	 logic[2:0] gol; 
	 
	 frameRAM(.read_address(playerIndex + (DistX + (DistY * 16))),
	 .read_address1(enemyIndex  + (EdistIndexX  + (EdistIndexY * 16))),
	 .read_address2(enemy1Index + (E1distIndexX + (E1distIndexY * 16))), .Clk(Clk), .data_Out(color_car), .data_Out1(colore1),.data_Out2(colore2));
	 
	 textrom text(.read_address((DrawX-513) + (DrawY * 106)),. Clk(Clk), .data_Out(logo_data));
	 
	 numbers num(.read_address((DrawX - 513) + ((DrawY-35) * 40)), .read_address1(1764 + ((DrawX - 520) + ((DrawY - 51) * 26))),.Clk(Clk), .data_Out(text_data), .data_Out1(zero_data),
	 .read_address2(leadindex + ((DrawX - 514) + ((DrawY - 51) * 8))), .data_Out2(lead_data),
	 .read_address3(1664 + ((DrawX - 514) + ((DrawY - 460) * 10))), .data_Out3(ysl));
	 
	 
	 trophy tro(.read_address((DrawX - 208) + ((DrawY-196) * 96)),. Clk(Clk), .data_Out(troph));
	 gameover go(.read_address((DrawX - 184) + ((DrawY-223) * 144)),. Clk(Clk), .data_Out(gol));
	 	 
	 //////////////////////////////////////////Initialization of font_roms that hold sprite data and map data
	   
	 spritefont_rom spriterom(.addr(DrawY%16),.data(sprite_data),.addr1(enemyIndex+EdistIndexY),.data1(sprite_enemy),.addr2(enemy1Index+E1distIndexY),.data2(sprite_enemy1));
	 flag_rom flagrom(.addr(f0distY),.data(f0data),.addr1(f1distY),.data1(f1data),.addr2(f2distY),.data2(f2data),.addr3(f3distY),.data3(f3data));
	 
	 logic[15:0] f0data,f1data,f2data,f3data;
	 
	 logic[10:0]screenAddr;
	 logic[39:0]screenData;
	 
	 logic[10:0]Levelindex;
	 assign Levelindex=72;
	 ScreenScroller ourscroller(.ScreenX(BallX/16),.ScreenY(BallY/16),.screenAddr(screenAddr),.screenData(screenData),.Clk(Clk),.levelindex(levelindex));
	 
	 screen_rom map1_rom(.addr(DrawY/16),.data(map_data),.addr1(BallYCenter/16),.data1(mapC_data),.addr2((BallYCenter+14)/16),.data2(mapC1_data),.addr3((enemyY-enemyOffsetY)/16),.data3(mapE_data),.addr4((enemy1Y-enemyOffsetY)/16),.data4(map1E_data)
	 ,.addr5((enemyY-enemyOffsetY+16)/16),.data5(mapE1_data),.addr6((enemy1Y-enemyOffsetY+16)/16),.data6(map1E1_data),.screenAddr(screenAddr),.screenData(screenData),.Clk(Clk),.Reset(Reset));
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, Size;
	 assign DistX = DrawX - BallXCenter; //BallXCenter
    assign DistY = DrawY - BallYCenter; //BallYCenter;
    assign Size = Ball_size;
	 
	  
	  
	 assign BallMapX=BallX/10 + 513;  ///THIS SCALING IS USED TO DISPLAY THE MINIMAP PLAYER
	 assign BallMapY=BallY/6 +160;   //For the new scrolling method we will change to ballX divded by 10, ball Y divided by 6, originally 5 and 3
	 
	 int DistMapX, DistMapY;
	 assign DistMapX = DrawX - BallMapX;//+(639-BallX)/639;
    assign DistMapY = DrawY - BallMapY; //(BallY/160) + 160;
	 
	  assign enemyMapX=enemyX/10 + 513;  ///THIS SCALING IS USED TO DISPLAY THE MINIMAP ENE<Y
	 assign enemyMapY=enemyY/6 +160; 
	 
	 int DistEMapX, DistEMapY;
	 assign DistEMapX = DrawX - enemyMapX;//+(639-BallX)/639;
    assign DistEMapY = DrawY - enemyMapY; //(BallY/160) + 160;
	 
	  assign enemy1MapX=enemy1X/10 + 513;  ///THIS SCALING IS USED TO DISPLAY THE MINIMAP ENE<Y
	 assign enemy1MapY=enemy1Y/6 +160; 
	 
	 int DistE1MapX, DistE1MapY;
	 assign DistE1MapX = DrawX - enemy1MapX;//+(639-BallX)/639;
    assign DistE1MapY = DrawY - enemy1MapY; //(BallY/160) + 160;
    
	 
	 int EdistX, EdistY;
	 assign EdistX = DrawX - enemyX +enemyOffsetX;
    assign EdistY = DrawY - enemyY +enemyOffsetY;
	 
	 int E1distX, E1distY;
	 assign E1distX = DrawX - enemy1X +enemyOffsetX;
    assign E1distY = DrawY - enemy1Y +enemyOffsetY;
	 
	 ///////////////////////////These will represent the flags cordiantes
	 int f0distX, f0distY;
	 assign f0distX = DrawX - 1024 + enemyOffsetX;
	 assign f0distY = DrawY - 624 + enemyOffsetY;
	 
	 int f1distX, f1distY;
	 assign f1distX = DrawX - 768 + enemyOffsetX;
	 assign f1distY = DrawY - 688 + enemyOffsetY;
	 
	 
	 int f2distX, f2distY;
	 assign f2distX = DrawX - 1200 + enemyOffsetX;
	 assign f2distY = DrawY - 928+ enemyOffsetY;
	 
	 
	 int f3distX, f3distY;
	 assign f3distX = DrawX - 480 + enemyOffsetX;
	 assign f3distY = DrawY - 800 + enemyOffsetY;
	 
	 
	 //int E2distX, E2distY;
	 //assign E2distX = DrawX - enemy2X;
    //assign E2distY = DrawY - enemy2Y;
	  always_comb
	 begin:E1map_on_proc
	 if ( ( DistE1MapX) <= (3) && DistE1MapY<=3 && DistE1MapX>=0 && DistE1MapY>=0 ) 
            enemy1map_on = 1'b1;
        else 
            enemy1map_on = 1'b0;
     end 
	  
	  always_comb
	 begin:Emap_on_proc
	 if ( ( DistEMapX) <= (3) && DistEMapY<=3 && DistEMapX>=0 && DistEMapY>=0 ) 
            enemymap_on = 1'b1;
        else 
            enemymap_on = 1'b0;
     end 
	  
	 always_comb
	 begin:map_on_proc
	 if ( ( DistMapX) <= (3) && DistMapY<=3 && DistMapX>=0 && DistMapY>=0 ) 
            ballmap_on = 1'b1;
        else 
            ballmap_on = 1'b0;
     end 
	  
    always_comb
    begin:Ball_on_proc
        if ( ( DistX) <= (15) && DistY<=15 && DistX>=0 && DistY>=0 ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
	
	
	 always_comb  //Checks if the pixel is with in the range for drawing the enemy
    begin:enemy_on_proc
	 
	 //
        if ( ((EdistX) <= (15) && EdistY<=15 && EdistX>=0 && EdistY>=0) ^ (EdistX>=11'b11111110000 && EdistX<=11'b11111111111 && EdistY>=11'b11111110000 && EdistY<=11'b11111111111) ^ (EdistX>=0 && EdistX<=15 && EdistY>=11'b11111110000 && EdistY<=11'b11111111111) ^ (EdistX>=11'b11111110000 && EdistX<=11'b11111111111 && EdistY>=0 && EdistY<=15))
            enemy_on = 1'b1;
        else 
            enemy_on = 1'b0;
     end 
	
	always_comb
   begin:enemy1_on_proc	
		if ( ((E1distX) <= (15) && E1distY<=15 && E1distX>=0 && E1distY>=0) ^ (E1distX>=11'b11111110001 && E1distX<=11'b11111111111 && E1distY>=11'b11111110001 && E1distY<=11'b11111111111) ^ (E1distX>=0 && E1distX<=15 && E1distY>=11'b11111110001 && E1distY<=11'b11111111111) ^ (E1distX>=11'b11111110001 && E1distX<=11'b11111111111 && E1distY>=0 && E1distY<=15)) 
            enemy1_on = 1'b1;
        else 
            enemy1_on = 1'b0;
	end
	
	always_comb
	begin:flag0_on_proc
	 if ( ( f0distX) <= (15) && f0distY<=15 && f0distX>=0 && f0distY>=0 ) 
            flag0_on = 1'b1;
        else 
            flag0_on = 1'b0;
     end 
	  
	always_comb
	begin:flag1_on_proc
	 if ( ( f1distX) <= (15) && f1distY<=15 && f1distX>=0 && f1distY>=0 ) 
            flag1_on = 1'b1;
        else 
            flag1_on = 1'b0;
     end 
	  
	always_comb
	begin:flag2_on_proc
	 if ( ( f2distX) <= (15) && f2distY<=15 && f2distX>=0 && f2distY>=0 ) 
            flag2_on = 1'b1;
        else 
            flag2_on = 1'b0;
     end 
	  
	always_comb
	begin:flag3_on_proc
	 if ( ( f3distX) <= (15) && f3distY<=15 && f3distX>=0 && f3distY>=0 ) 
            flag3_on = 1'b1;
        else 
            flag3_on = 1'b0;
     end 
	  
       
    always_comb
    begin:RGB_Display
      /////////////////Winscreen and Gameover Screen have earlier    
			 ////DRAWING THE TROPHY 
	
		  if (DrawX > 208 && DrawX<304 && DrawY>=196 && DrawY <= 283 && Winscreen && troph == 1)
		  begin 
		  Red=8'h5C;
		  Green=8'h23;
		  Blue=8'h23;
		  end 
		  
		    else  //first digit of scorescore 
		  begin 
		  if (DrawX > 208 && DrawX<304 && DrawY>=196 && DrawY <= 283 && Winscreen && troph == 2 )
		  begin 
		  Red=8'hB9;
		  Green=8'h5B;
		  Blue=8'h18;
		  end 
		  
		   else  //first digit of scorescore 
		  begin 
		  if (DrawX > 208 && DrawX<304 && DrawY>=196 && DrawY <= 283 && Winscreen && troph == 3 )
		  begin 
		  Red=8'hD3;
		  Green=8'hB9;
		  Blue=8'h31;
		  end 
		  
		   else  //first digit of scorescore 
		  begin 
		  if (DrawX > 208 && DrawX<304 && DrawY>=196 && DrawY <= 283 && Winscreen && troph == 4 )
		  begin 
		  Red=8'hEF;
		  Green=8'hEE;
		  Blue=8'h9A;
		  end 
		  
		  
		  
		  //DRAWING GAME OVER SCREEN
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  	    else  //first digit of scorescore 
		  begin 
		  if (DrawX > 184 && DrawX< 328 && DrawY>=223 && DrawY <= 255 && GameOver && gol == 1)
		  begin 
		  Red=8'h00;
		  Green=8'h00;
		  Blue=8'h00;
		  end 
		  
		    else  //first digit of scorescore 
		  begin 
		  if (DrawX > 184 && DrawX< 328 && DrawY>=223 && DrawY <= 255 && GameOver && gol == 2 )
		  begin 
		  Red=8'hFF;
		  Green=8'hFF;
		  Blue=8'hFF;
		  end 
		  
		   else  //first digit of scorescore 
		  begin 
		  if (DrawX > 184 && DrawX< 328 && DrawY>=223 && DrawY <= 255 && GameOver && gol == 3 )
		  begin 
		  Red=8'hC7;
		  Green=8'h3C;
		  Blue=8'h3C;
		  end 
		  
		   else  //first digit of scorescore 
		  begin 
		  if (DrawX > 184 && DrawX< 328 && DrawY>=223 && DrawY <= 255 && GameOver && gol == 4 )
		  begin 
		  Red=8'h54;
		  Green=8'h8B;
		  Blue=8'hE5;
		  end 
		  
		  
		  
		    
		  ///DRAWING STRIPE FOR FLAG BACKGROUND 
		  
		  else  //Lives
		  begin 
		  if (DrawX>0 && DrawX<513 && DrawY>=181 && DrawY <= 298 &&  (GameOver || Winscreen))
		  begin 
		  Red=8'h00;
		  Green=8'h00;
		  Blue=8'h00;
		  end 
		 
		  
///////////////////////////////Draw the cars		  
			
			else
			begin
		  if ((ball_on == 1'b1) && color_car == 3 && DrawX < 513 )//sprite_data[-DistX-1])    //The case where we draw the player
        begin 
            Red = 8'h25;       //blue case car chasis 
            Green = 8'h4D;
            Blue = 8'hDB;
        end       
		  
		  
		   else  //the case where we draw the player 
		  begin 
		  if (ball_on == 1'b1 && color_car == 1 && DrawX  <  513 )   //black where we draw wheels 
		  begin 	
		      Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h00;
				
		  end
		  
		    else  //the case where we draw the player 
		  begin 
		  if (ball_on == 1'b1 && color_car == 2 && DrawX <  513 && !crash_on )  //where we draw Windows indigo 
		  begin 	
		      Red = 8'hFF; 
            Green = 8'hFE;
            Blue = 8'h9E;
				
		  end
		  
		   else  //the case where we BANG crash
		  begin 
		  if (ball_on == 1'b1 && color_car == 2 && DrawX <  513 && crash_on )  //where we draw Windows indigo 
		  begin 	
		      Red = 8'hFF; 
            Green = 8'h01;
            Blue = 8'h00;
				
		  end
		  
////////////////////////////////////////////////////////////////////////////The case where we draw the flags
		 else
		 begin
		 if(flag0_on == 1'b1 && flagDisplay[0] && f0data[f0distX] && DrawX < 513)
		 begin
		  Red = 8'hFF; 
        Green = 8'hFF;
        Blue = 8'h00;
		 end
		 
		  else
		 begin
		 if(flag1_on == 1'b1 && flagDisplay[1] && f1data[f1distX] && DrawX < 513)
		 begin
		  Red = 8'hFF; 
        Green = 8'hFF;
        Blue = 8'h00;
		 end
		 
		  else
		 begin
		 if(flag2_on == 1'b1 && flagDisplay[2] && f2data[f2distX] && DrawX < 513)
		 begin
		  Red = 8'hFF; 
        Green = 8'hFF;
        Blue = 8'h00;
		 end
       
		  else
		 begin
		 if(flag3_on == 1'b1 && flagDisplay[3] && f3data[f3distX] && DrawX < 513)
		 begin
		  Red = 8'hFF; 
        Green = 8'hFF;
        Blue = 8'h00;
		 end
		 
	   
		  else 
		  begin
		  if(enemy_on && colore1 == 3 && DrawX < 513)//|| enemy2_on        //The case where we draw the enemy
		  
		  begin
		  Red = 8'hDC;
        Green = 8'h0A;
        Blue = 8'h16;
		  end
		  
     else 
		  begin
		  if(enemy_on && colore1 == 1 && DrawX < 513)//|| enemy2_on        //The case where we draw the enemy
		  
		  begin
		  Red = 8'h00;
        Green = 8'h00;
        Blue = 8'h00;
		  end
		  
     else 
		  begin
		  if(enemy_on && colore1 == 2 && DrawX< 513)//|| enemy2_on        //The case where we draw the enemy
		  
		  begin
		  Red = 8'h34;
        Green = 8'hdf;
        Blue = 8'hde;
		  end
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
		 else
		  begin
		  if(enemy1_on && colore2 == 1 && DrawX < 513 )//|| enemy2_on        //The case where we draw the enemy
		  begin
		  Red = 8'h00;
        Green = 8'h00;
        Blue = 8'h00;
		  end
		  
		  
		  else 
		  begin
		  if(enemy1_on && colore2 == 3 && DrawX < 513 )//|| enemy2_on        //The case where we draw the enemy
		  
		  begin
		  Red = 8'h0A;
        Green = 8'hDC;
        Blue = 8'h06;
		  end
		  
		  
		  else 
		  begin
		  if(enemy1_on && colore2 == 2 && DrawX < 513 )//|| enemy2_on        //The case where we draw the enemy
		  
		  begin
		  Red = 8'h34;
        Green = 8'hdf;
        Blue = 8'hde;
		  end
		  
		  
		
		  
		  
		  else                       
		  begin
		  if(map_data[(DrawX/16)] && DrawX<513 && levelindex==1'b0)  //The case where we draw the walls of map LEVEL 1
        begin 
            Red = 8'h00; 
            Green = 8'h7f - DrawX[9:3];
            Blue = 8'h00;
        end
		  
		  else                       
		  begin
		  if(map_data[(DrawX/16)] && DrawX<513 && levelindex==1'b1)  //The case where we draw the walls of map LEVEL 2
        begin 
            Red = 8'h00; 
            Green = 8'h0f + DrawY[9:3];
            Blue = 8'h7f - DrawX[9:3];
        end
		  
		  else             ///The case where we draw the background
		  begin
		  if(DrawX<513)                         

		  begin
		   Red = 8'hE1;  //A biege sandy/dirt color
         Green = 8'hC6-DrawX[9:3];
         Blue = 8'h99;
		  end
		  
		  else
		  begin
		  if(DrawX>512 && ballmap_on && DrawY>160)  //The minimap player case
		  begin
		   Red = 8'hff;
         Green = 8'hff;
         Blue = 8'hff;
		  end
		  
		  else
		  begin
		  if(DrawX>512 && enemymap_on && DrawY>160)  //The minimap enemy case
		  begin
		  Red = 8'h00;
        Green = 8'hff;
        Blue = 8'hff;
		  end
		  
		  else
		  begin
		  if(DrawX>512 && enemy1map_on && DrawY>160)  //The minimap enemy 1 case
		  begin
		  Red = 8'h00;
        Green = 8'hff;
        Blue = 8'hff;
		  end
		  
		  else                               //The area where score and map are shown
		  begin
		  if(DrawX>512 && DrawY>160 && DrawY<320)
		  begin
		  Red = 8'h99;
        Green = 8'h00;
        Blue = 8'h00;
		  end
		 
		  
		  
		  
		  else  //color1 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY<= 35 && logo_data == 1)
		  begin 
		  Red=8'hBE;
		  Green=8'h1a;
		  Blue=8'h1d;
		  end 
		  
		  
		  else  //color2
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY<= 35 && logo_data == 2)
		  begin 
		  Red=8'h9b;
		  Green=8'h14;
		  Blue=8'h23;
		  end 
		  
		  
		  else  //color3 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY<= 35 && logo_data == 3)
		  begin 
		  Red=8'h45;
		  Green=8'h08;
		  Blue=8'h0f;
		  end 
		  
		   
		  else  //color4
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY<= 35 && logo_data == 4)
		  begin 
		  Red=8'h4e;
		  Green=8'h10;
		  Blue=8'h43;
		  end 
		  
		   
		  else  //color5 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY<= 35 && logo_data == 5)
		  begin 
		  Red=8'h00;
		  Green=8'h58;
		  Blue=8'hf8;
		  end 
		  
		  
		  
		  else  //color6 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 6)
		  begin 
		  Red=8'h2e;
		  Green=8'h0e;
		  Blue=8'h4d;
		  end 
		  
		  
		  else  //color7 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 7)
		  begin 
		  Red=8'h1f;
		  Green=8'h0e;
		  Blue=8'h55;
		  end 
		  
		  
		  else  //color8 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 8)
		  begin 
		  Red=8'h00;
		  Green=8'h1d;
		  Blue=8'hcf;
		  end 
		  
		  
		  
		  else  //color9 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 9)
		  begin 
		  Red=8'h00;
		  Green=8'h0d;
		  Blue=8'h5e;
		  end 
		  
		  
		  else  //color10 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 10)
		  begin 
		  Red=8'hec;
		  Green=8'h67;
		  Blue=8'h02;
		  end 
		  
		  
		  else  //color11 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 11)
		  begin 
		  Red=8'hea;
		  Green=8'h32;
		  Blue=8'h16;
		  end 
		  
		  
		  else  //color12 
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 12)
		  begin 
		  Red=8'hc8;
		  Green=8'h1d;
		  Blue=8'h1b;
		  end 
		  
		  
		  
		  else  //color13 of the Logo
		  begin 
		  if (DrawX>512 && DrawX<618 && DrawY>=0 && DrawY <= 35 && logo_data == 13)
		  begin 
		  Red=8'h00;
		  Green=8'h02;
		  Blue=8'h08;
		  end 
		  
		/////////////// Drawing the Score
		
		  else  //the word score  
		  begin 
		  if (DrawX>512 && DrawX<552 && DrawY>=35 && DrawY <= 51 && text_data == 1)
		  begin 
		  Red=8'h00;
		  Green=8'h00;
		  Blue=8'h00;
		  end 
		  
		  
		  
		  else  //the word score 
		  begin 
		  if (DrawX>512 && DrawX<552 && DrawY>=35 && DrawY <= 51 && text_data == 2)
		  begin 
		  Red=8'hFF;
		  Green=8'hFF;
		  Blue=8'hFF;
		  end 
		  
		  
		  else  // 000's in the score
		  begin 
		  if (DrawX>521 && DrawX<548 && DrawY>=51 && DrawY <= 67 && zero_data == 1)
		  begin 
		  Red=8'h00;
		  Green=8'h00;
		  Blue=8'h00;
		  end 
		  
		  
		  
		  else  // 000's in the score 
		  begin 
		  if (DrawX>521 && DrawX<548 && DrawY>=51 && DrawY <=  67 && zero_data == 2)
		  begin 
		  Red=8'h21;
		  Green=8'hDE;
		  Blue=8'hDE;
		  end 
		  
		   else  //first digit of score  
		  begin 
		  if (DrawX > 513 && DrawX<521 && DrawY>=51 && DrawY <= 67 && lead_data == 1)
		  begin 
		  Red=8'h00;
		  Green=8'h00;
		  Blue=8'h00;
		  end 
		  
		  
		  
		  else  //first digit of scorescore 
		  begin 
		  if (DrawX > 513 && DrawX<521 && DrawY>=51 && DrawY <= 67 && lead_data == 2)
		  begin 
		  Red=8'h21;
		  Green=8'hDE;
		  Blue=8'hDE;
		  end 
		  
		  
		  
		   
		    else  //Lives
		  begin 
		  if (DrawX>513 && DrawX<529 && DrawY>=454 && DrawY <= 470 && sprite_data[ (DrawX-513) % 16] && livesCount>=1)
		  begin 
		  Red=8'hFF;
		  Green=8'hF7;
		  Blue=8'h00;
		  end 
		  
		   else  //Lives
		  begin 
		  if (DrawX>530 && DrawX<546 && DrawY>=454 && DrawY <= 470 && sprite_data[(DrawX-530) % 16] == 1'b1 && livesCount>=2)
		  begin 
		  Red=8'hFF;
		  Green=8'hF7;
		  Blue=8'h00;
		  end 
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		   else
		  begin
		  Red=8'h00;
		  Green=8'h00;
		  Blue=8'h00;
		  end
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  
		  end
		  end 
		  end 
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end 
		  end 
		  end 
		  end 
		  end
		  end
		  end
        end
		  end
		  end
		  end
		  
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  end
		  
    end
    
endmodule
