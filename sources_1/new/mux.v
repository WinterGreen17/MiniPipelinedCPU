`timescale 1ns / 1ps

module mux(input [31:0]ifid_out, input s_regrt, output reg [4:0] m_out);
   reg [4:0] rd;
   reg [4:0] rt;

always @(*)
begin
    if (ifid_out[31:26] != 6'b100011) // check if opcode is lw
    begin
        rd = ifid_out[15:11];
    end else begin
        rt = ifid_out[20:16];
    end
   m_out = s_regrt ? rd : rt; // selecting
end

endmodule
