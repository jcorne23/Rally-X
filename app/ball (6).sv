//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk,crash_on, 
               input [4:0]map_on,
					input [7:0] keycode,
					input [3:0] flagcount,
					output [2:0] livesCount, //Counts amoutn of lives, at 0 the game over screen will appear
					output Winscreen,flagreset, GameOver,
					output [1:0] levelindex,
					output [3:0] playerVelocity,
               output [10:0]  BallX, BallY, BallS );
    
    logic [10:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 logic [10:0] Ball_X_Offset,Ball_Y_Offset;    //These offsets will be used to remove the player from collided
	 logic colliding,crashed; //Used to detect when crashing, will be used in determining the state of our statemachine and game
	
	 //logic [3:0] prevCollision;
	 
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [10:0] Ball_X_Max=1279;     // Rightmost point on the X axis //Originally 639
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=959;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
	 


    assign Ball_Size = 16;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin
		      colliding <= 0; //Set the collide condition to not colliding 
				crashed <= 0; //This is set when the car crashes 
				livesCount <=2'b10; //We have 3 lives
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_X_Offset<=0;
				Ball_Y_Offset<=0;  //No offset at beginning because we do not start at a collision
				Ball_Y_Pos <= 480;
				Ball_X_Pos <= 640;
				levelindex <= 2'b00;
				Winscreen <= 1'b0;
				GameOver <= 1'b0;
        end
		  
		  else
		  begin
		  if (crashed && livesCount!=0)  // Asynchronous Reset
        begin
		      colliding <= 0; //Set the collide condition to not colliding 
				crashed <= 0; //This is set when the car crashes 
				livesCount <= livesCount - 1;
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_X_Offset<=0;
				Ball_Y_Offset<=0;  //No offset at beginning because we do not start at a collision
				Ball_Y_Pos <= 480;
				Ball_X_Pos <= 640;
        end
		  
		  else
		  begin
		  if(flagcount>=3'b100 && levelindex == 2'b00)          //The case where we collect all flags and set the win screen
		  begin
		      colliding <= 0; //Set the collide condition to not colliding 
				crashed <= 0; //This is set when the car crashes 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_X_Offset<=0;
				Ball_Y_Offset<=0;  //No offset at beginning because we do not start at a collision
				Ball_Y_Pos <= 480;
				Ball_X_Pos <= 640;
				flagreset <= 1'b1;
		      levelindex<=2'b01;
		  end
		  
		  else        ///The case where we collect all flags on level 2
		  begin
		  if(flagcount>=3'b100 && levelindex ==2'b01)
		  begin
		  Winscreen<=1'b1;
		  
		  end
		  
		  else
		  begin
		  if(crashed && livesCount==0) //This is the gameover states, send game over signal, draw gameover screen
		  begin
		      colliding <= 0; //Set the collide condition to not colliding 
				crashed <= 1; //This is set when the car crashes 
				livesCount <= 0;
            Ball_Y_Motion <= 10'd111; //Ball_Y_Step;
				Ball_X_Motion <= 10'd111; //Ball_X_Step;
				GameOver <= 1'b1;
		  end
		  
           
        else 
        begin
		       if(flagreset)   //resetting flagreset back to 0 so the flags dont infinitely reset
				 flagreset<=1'b0;
				 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max )  // Ball is at the bottom edge, We follow our collision rules below
					 begin
				  Ball_Y_Offset <= -1;
				 Ball_X_Offset <= 0;
				 
				   colliding <= 1'b1;
				 Ball_Y_Motion <= 0;
				 Ball_X_Motion <= -3;
				 playerVelocity<= 4'b1000;
					 end
					  
				 else if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, We follow our collision rules below
					  begin
					   
				 
				   Ball_Y_Offset <= 1;
				  Ball_X_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_Y_Motion <= 0;
				  Ball_X_Motion <= 3;
				  playerVelocity <= 4'b0100;
				 
					  end
					  
					  
				  else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max )  // Ball is at the Right edge, We follow our collision rules below
					  begin
					  Ball_X_Offset <= -1;
				  Ball_Y_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (3);
				  playerVelocity <= 4'b0010;
					  end
					 
					  
				 else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min )  // Ball is at the Left edge, We follow our collision rules below
					  begin
					  Ball_X_Offset <= 1;
				  Ball_Y_Offset <= 0;
				  
				    colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (-3);
			     playerVelocity <= 4'b0001;
					  end
					  
//////////////These next 4 if statements are to deal with collision with walls					  
				 else if ( map_on != 5'b00000 && ~colliding && playerVelocity==4'b0001)  //player hits under wall
				 begin
				  
				  Ball_Y_Offset <= 1;
				  Ball_X_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_Y_Motion <= 0;
				  Ball_X_Motion <= 3;
				  playerVelocity <= 4'b0100;
				  
				  
				 end
				 
				 else if ( map_on != 5'b00000 && ~colliding && playerVelocity==4'b0010)  //player hits top wall
				 begin
				 
				 
				 Ball_Y_Offset <= -1;
				 Ball_X_Offset <= 0;
				 
				   colliding <= 1'b1;
				 Ball_Y_Motion <= 0;
				 Ball_X_Motion <= -3;
				 playerVelocity<= 4'b1000;
				 
				 
				 end
				 
				 else if ( map_on != 5'b00000 && ~colliding && playerVelocity==4'b0100)  //player hits right wall
				 begin
				
				  Ball_X_Offset <= -1;
				  Ball_Y_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (3);
				  playerVelocity <= 4'b0010;
				  
				  
				 end
				 
				 else if ( map_on != 5'b00000 && ~colliding &&playerVelocity==4'b1000)  //player hits left wall
				 begin
				  
				  
				  Ball_X_Offset <= 1;
				  Ball_Y_Offset <= 0;
				  
				    colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (-3);
			     playerVelocity <= 4'b0001;
				 
			    end	  
					  
				 else begin
				  
					  Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					  
				 
				 case (keycode)
					8'h04 : begin
                        if(~colliding ||( colliding && playerVelocity!=4'b0001))
								begin
								Ball_X_Motion <= -3;//A
								Ball_Y_Motion<= 0;
								playerVelocity<=4'b1000;
								end
							  end
					        
					8'h07 : begin
								
							  if(~colliding ||( colliding && playerVelocity!=4'b0010))
							  begin 
					        Ball_X_Motion <= 3;//D
							  Ball_Y_Motion <= 0;
							  playerVelocity<=4'b0100;
							  end
							  end

							  
					8'h16 : begin
                       if(~colliding ||( colliding && playerVelocity!=4'b1000)) //0100
							  begin
					        Ball_Y_Motion <= 3;//S
							  Ball_X_Motion <= 0;
							  playerVelocity <=4'b0010;
							  end
							 end
							  
					8'h1A : begin
					        if(~colliding ||( colliding && playerVelocity!=4'b0100))
							  begin
					        Ball_Y_Motion <= -3;//W
							  Ball_X_Motion <= 0;
							  playerVelocity=4'b0001;
							  end
							 end	  
					default: ;
			   endcase
				 
				  if(~colliding)
				 begin
				  Ball_X_Offset<=0;
				 Ball_Y_Offset<=0;
				 end
				
				
				
				 
				
			 end	
			   
			 
			   if(crash_on)
				begin
				crashed <=1;
				Ball_X_Motion<=0;
				Ball_Y_Motion<=0;
				end
				
				if(crashed)
				begin
				Ball_X_Motion<=0;
				Ball_Y_Motion<=0;
				end
			    
			 
				
				 if(map_on == 5'b00000) //If the map has no wall then we set colliding to 0
				colliding<=1'b0; 
				
				 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion + Ball_Y_Offset);  // Update ball position
				 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion + Ball_X_Offset);
				
				
			
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of Ball_Y_pos.  Will the new value of Ball_Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
      
			
		end  
    end
    
	 
	     end
		  end
		  end
		  end
		  
	 assign BallX = Ball_X_Pos;
	 assign BallY = Ball_Y_Pos;
	 
    assign BallS = Ball_Size;
	 
	 
    

endmodule
