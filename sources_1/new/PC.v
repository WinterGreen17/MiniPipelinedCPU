`timescale 1ns / 1ps

module PC(input clk, input [31:0]pc_in, output reg[31:0]pc_out);
always @(posedge clk)
begin
    pc_out<=pc_in;
end

endmodule
