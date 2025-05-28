/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  frameRAM
(
		input [10:0] read_address,
		input [10:0] read_address1, 
		input [10:0] read_address2, 
		input  Clk,

		output logic [2:0] data_Out,
		output logic [2:0] data_Out1,
		output logic [2:0] data_Out2
		
);

// mem has width of 3 bits and a total of 400 addresses
//logic [2:0] mem [0:255];
logic [2:0] mem [0:1023]; 

initial
begin
	 $readmemh("racecar.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
	data_Out1<= mem[read_address1];
	data_Out2<= mem[read_address2];

end

endmodule










