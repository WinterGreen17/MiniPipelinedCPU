`timescale 1ns / 1ps

module adder(input [31:0] in_pc, output reg [31:0] out_s);
// need checking & understanding

 initial 
 begin
 out_s <= 96; 
 end
 
 always @(*) begin // I'm confused
    // set in_pc to 100 in testbench
    out_s = in_pc + 4;
end
  
endmodule