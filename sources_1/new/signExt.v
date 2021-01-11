`timescale 1ns / 1ps

module signExt(input wire [31:0]ifid_out, output reg [31:0] e_out); // cat 16-32 bits
always @(ifid_out) 
begin
e_out = {{16{ifid_out[15]}},ifid_out[15:0]}; // concatenation
end
endmodule
