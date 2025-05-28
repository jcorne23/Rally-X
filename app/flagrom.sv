module flag_rom ( input [10:0]	addr, addr1, addr2, addr3,
						output [15:0]	data, data1, data2, data3
					 );

					  logic [15:0] reg_file[16];  //Instatiating our ROM

always_comb         ////////////////////////////Extra Flag Rom made for easy accessing instead of adding it onto 


begin                        


reg_file[0]=            16'b0001000000000000; // 0  Flag
reg_file[1]=            16'b0001110000000000; // 1
reg_file[2]=            16'b0001111110000000; // 2  
reg_file[3]=            16'b0001111111100000; // 3 
reg_file[4]=            16'b0001111111111100; // 4 
reg_file[5]=            16'b0001111111100000; // 5 
reg_file[6]=            16'b0001111110000000; // 6
reg_file[7]=            16'b0001000000000000; // 7 
reg_file[8]=            16'b0001000000000000; // 8 
reg_file[9]=            16'b0001000000000000; // 9       
reg_file[10]=           16'b0001000000000000; // a     
reg_file[11]=           16'b0001000000000000; // b  
reg_file[12]=           16'b0011100000000000; // c
reg_file[13]=           16'b0111110000000000; // d
reg_file[14]=           16'b0111110000000000; // e
reg_file[15]=           16'b1111111000000000; // f


end

assign data = reg_file[addr];
assign data1 = reg_file[addr1];
assign data2 = reg_file[addr2];
assign data3 = reg_file[addr3];

endmodule 
