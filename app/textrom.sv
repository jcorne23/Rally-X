
module  textrom
(
		input [14:0] read_address,

		input  Clk,

		output logic [3:0] data_Out
		
);

// mem has width of 3 bits and a total of 400 addresses
//logic [2:0] mem [0:255];
logic [3:0] mem [0:3709]; 

initial
begin
	 $readmemh("textfile.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];

end

endmodule


module  trophy
(
		input [13:0] read_address,

		input  Clk,

		output logic [2:0] data_Out
		
);

// mem has width of 3 bits and a total of 400 addresses
//logic [2:0] mem [0:255];
logic [2:0] mem [0:8447]; 

initial
begin
	 $readmemh("trophy.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];

end

endmodule





module  gameover
(
		input [13:0] read_address,

		input  Clk,

		output logic [2:0] data_Out
		
);

// mem has width of 3 bits and a total of 400 addresses
//logic [2:0] mem [0:255];
logic [2:0] mem [0:4751]; 

initial
begin
	 $readmemh("gameover.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];

end

endmodule




module  numbers 
(
		input [11:0] read_address,
      input [11:0] read_address1, 
		input [11:0] read_address2,
		input [11:0] read_address3, 	
		input  Clk,

		output logic [2:0] data_Out,
		output logic [2:0] data_Out1,
		output logic [2:0] data_Out2,
		output logic [2:0] data_Out3 
	

);





// mem has width of 3 bits and a total of 400 addresses
//logic [2:0] mem [0:255];
logic [2:0] mem [0:2179]; 

initial
begin
	 $readmemh("numandscoresprite.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
   data_Out1<= mem[read_address1];
	data_Out2<= mem[read_address2];
	data_Out3<= mem[read_address3];

end

endmodule
