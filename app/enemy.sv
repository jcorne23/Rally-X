module  enemy #(parameter StartX=320, StartY=440,Velocity=1)( input Reset, frame_clk,
					input [7:0] keycode,
					input [10:0] PlayerX, PlayerY, //These are the players cordinates, will be used to reference when
               input [4:0] mapE_on,
					output [3:0] enemyVelocity,
					output [10:0]  BallX, BallY);
    
	 
	 parameter [10:0] PlayerXCenter=320;  // Center position on the X axis 
    parameter [10:0] PlayerYCenter=240;  // Center position on the Y axis 
                                        // In the scrolling implementation, the player will no longer move with regard to the map
													 // He will be on the center of the screen while the map moves around them
													 //This means the enemies should always move toward 320,240 (center) as player sprite will always be e
													 //there
	 
    logic [10:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 logic [10:0] Ball_X_Offset,Ball_Y_Offset;    //These offsets will be used to remove the player from collided
	 logic colliding;
	 
    parameter [9:0] Ball_X_Center=StartX;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=StartY;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [10:0] Ball_X_Max=1279;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=959;     // Bottommost point on the Y axis

    logic [9:0] Ball_X_Step;      // Step size on the X axis
    logic [9:0] Ball_Y_Step;      // Step size on the Y axis
	 
	 always_comb
	 begin                        //One here is representative of step
	 if(BallX-PlayerX < 1)
	 Ball_X_Step=BallX-PlayerX;
	 else
	 Ball_X_Step=1;
	 
	 if(BallY-PlayerY < 1)
	 Ball_Y_Step=BallY-PlayerY;
	 else
	 Ball_Y_Step=1;
	 
	 end

    assign Ball_Size = 16;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd1; //Ball_Y_Step;   //This will start as 1 as enemies are spawned under player at beginning
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_X_Offset<=0;
				Ball_Y_Offset<=0;  //No offset at beginning because we do not start at a collision
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
           
        else 
        begin 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max )  // Ball is at the bottom edge, Enemies turn instead of bouncing
					 begin
					  Ball_Y_Offset <= -1;
				 Ball_X_Offset <= 0;
				 
				   colliding <= 1'b1;
				 Ball_Y_Motion <= 0;
				 Ball_X_Motion <= -Velocity;
				 enemyVelocity<= 4'b1000;
					 end
					  
				 else if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, Enemies turn instead of bouncing
					  begin
					  Ball_Y_Offset <= 1;
				  Ball_X_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_Y_Motion <= 0;
				  Ball_X_Motion <= Velocity;
				  enemyVelocity <= 4'b0100;
					  end
					  
				  else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max )  // Ball is at the Right edge, Enemies turn instead of bouncing
					  begin
				  Ball_X_Offset <= -1;
				  Ball_Y_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (Velocity);
				  enemyVelocity <= 4'b0010;
					  end
					  
				 else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min )  // Ball is at the Left edge, Enemies turn instead of bouncing
					  begin
					   Ball_X_Offset <= 1;
				  Ball_Y_Offset <= 0;
				  
				    colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (-Velocity);
			     enemyVelocity <= 4'b0001;
					  end
				 
		       //////////////These next 4 if statements are to deal with collision with walls					  
				else if ( mapE_on != 5'b00000 && ~colliding && enemyVelocity==4'b0001)  //player hits under wall
				 begin
				  
				  Ball_Y_Offset <= 0;
				  Ball_X_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_Y_Motion <= 0;
				  Ball_X_Motion <= Velocity;
				  enemyVelocity <= 4'b0100;
				  
				  
				 end
				 
				 else if ( mapE_on != 5'b00000 && ~colliding && enemyVelocity==4'b0010)  //player hits top wall
				 begin
				 
				 
				 Ball_Y_Offset <= -0;
				 Ball_X_Offset <= 0;
				 
				   colliding <= 1'b1;
				 Ball_Y_Motion <= 0;
				 Ball_X_Motion <= -Velocity;
				 enemyVelocity<= 4'b1000;
				 
				 
				 end
				 
				 else if ( mapE_on != 5'b00000 && ~colliding && enemyVelocity==4'b0100)  //player hits right wall
				 begin
				
				  Ball_X_Offset <= -0;
				  Ball_Y_Offset <= 0;
				  
				  colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (Velocity);
				  enemyVelocity <= 4'b0010;
				  
				  
				 end
				 
				 else if ( mapE_on != 5'b00000 && ~colliding && enemyVelocity==4'b1000)  //player hits left wall
				 begin
				  
				  
				  Ball_X_Offset <= 0;
				  Ball_Y_Offset <= 0;
				  
				    colliding <= 1'b1;
				  Ball_X_Motion <= (0);
				  Ball_Y_Motion <= (-Velocity);
			     enemyVelocity <= 4'b0001;
				 
			    end	  
				 
				 else  begin
					  Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					  
				 // logic [1:0] DistanceAwayXY;
				 
				                              //These statements calculate the distance between enemy and player
														//and then sets the DistanceAway bit which will tell enemy which
														//direction to travel in
           
	 
				 if(BallX-PlayerX<=4 && colliding==1'b0)
				 begin
				 Ball_X_Motion<=0;
				   if(BallY-PlayerY<=4)
				    Ball_Y_Motion<=0;  
				else begin if(BallY-PlayerY > Ball_Y_Max && BallY-PlayerY != 0 )        
				  
					 begin                       //Moving in postive Y direction (UP)
					 Ball_X_Motion <= 0;
				    Ball_Y_Motion<= Velocity;
					 enemyVelocity <= 4'b0010;
					 end
				 else
				 begin
				    if(BallY-PlayerY < Ball_Y_Max && BallY-PlayerY != 0)
				   
					 begin                       //Moving in negative Y direction (DOWN)
					 Ball_X_Motion <= 0;       
				    Ball_Y_Motion<= -Velocity;
					 enemyVelocity <= 4'b0001;
					 end
					
				 end
				 end
			
	          end
				 
				 else begin if(BallX-PlayerX > Ball_X_Max && BallX-PlayerX != 0  && colliding==1'b0)        //
				   
					 begin                         //Moving in postive X direction (RIGHT)
					 Ball_X_Motion <= Velocity;
				    Ball_Y_Motion<= 0;
					 enemyVelocity <= 4'b0100;
					 end
				 else
				 begin  //Moving in negative X direction (LEFT)
				    if(BallX-PlayerX < Ball_X_Max && BallX-PlayerX != 0 && colliding==1'b0) //The zero check is so the enemy isnt oscillating trying to get to the correct cordinate
					  //begin
					  //if(!colliding || (colliding && enemyVelocity!=4'b1000))
					  begin
					  Ball_X_Motion <= -Velocity;
					  Ball_Y_Motion<= 0;
					  enemyVelocity <= 4'b1000;
					  end
					  //end
					  
				 end
				 end
				 
				 
				 
				  
				 
				 
				 
				 
				 
				// case (keycode) //The enemies are not controlled by us, so we don't need key codes
				//	2'b01 : begin//Instead they will be controlled on the distance away from the ball

				//				Ball_X_Motion <= -1;//A
				//				Ball_Y_Motion<= 0;
				//			  end
					        
				//	8'h07 : begin
								
				//	        Ball_X_Motion <= 1;//D
				//			  Ball_Y_Motion <= 0;
				//			  end

							  
				//	8'h16 : begin

				//	        Ball_Y_Motion <= 1;//S
				//			  Ball_X_Motion <= 0;
				//			 end
							  
				//	8'h1A : begin
				//	        Ball_Y_Motion <= -1;//W
				//			  Ball_X_Motion <= 0;
				//			 end	  
				//	default: ;
			   //endcase
				if(~colliding)
				 begin
				  Ball_X_Offset<=0;
				 Ball_Y_Offset<=0;
				 end
				 
			 end	
				
				  if(mapE_on == 5'b00000) //If the map has no wall then we set colliding to 0
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
    
   
	 
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule
