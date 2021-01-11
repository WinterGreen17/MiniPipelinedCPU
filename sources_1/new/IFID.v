`timescale 1ns / 1ps

module IFID(input clk, input wire [31:0]a_in, output reg[31:0]do_out); // use wire to carry IM output over...?
always @ (posedge clk)
begin
 do_out<=a_in;
end
endmodule
