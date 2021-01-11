`timescale 1ns / 1ps

module IM(input [31:0]pc_out,output reg [31:0]do); 
reg [31:0] a;
reg [31:0] IM[0:511];

initial begin
IM[100] = 32'h8C220000;
IM[104] = 32'h8C230004; 
end

always @(*)
begin
 a = pc_out;
 do = IM[a];
 
end
endmodule
