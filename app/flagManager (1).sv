module flagManager(input Clk, Reset,
                   input [4:0]flagBurst, //input from color mapper that uses collision to tell which flags to display
						 output [4:0]flagDisplay,
						 output [3:0]flagcount


);
/////////This module deals with controlling whether or not a flag is being drawn as well as counting the flags 
/////////based on nonrepeating collisions


always_ff @ (posedge Clk or posedge Reset) 
begin:flag_manage
if(Reset)
begin
flagcount<=4'b0000;
flagDisplay<=5'b11111;
end

else
if(flagBurst[0] && flagDisplay[0]) //If a collision with flag0 was detected, we set it's display to 0
begin
flagDisplay[0]<=1'b0;
flagcount<=flagcount+1;
end

else
begin
if(flagBurst[1] && flagDisplay[1]) //If a collision with flag1 was detected, we set it's display to 0
begin
flagDisplay[1]<=1'b0;
flagcount<=flagcount+1;
end

else
begin
if(flagBurst[2] && flagDisplay[2]) //If a collision with flag2 was detected, we set it's display to 0
begin
flagDisplay[2]<=1'b0;
flagcount<=flagcount+1;
end

else
if(flagBurst[3] && flagDisplay[3]) //If a collision with flag3 was detected, we set it's display to 0
begin
flagDisplay[3]<=1'b0;
flagcount<=flagcount+1;
end

else
begin
if(flagBurst[4] && flagDisplay[4]) //If a collision with flag4 was detected, we set it's display to 0
begin
flagDisplay[4]<=1'b0;
flagcount<=flagcount+1;
end



end
end
end
end

endmodule