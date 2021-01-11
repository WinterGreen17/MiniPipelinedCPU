`timescale 1ns / 1ps


module regFile(input wire[31:0]ifid_o, output reg[31:0] qa, output reg[31:0] qb); // similar to IM
   reg[31:0] rF [0:31]; //31 x 31 array
   reg[4:0] rs;
   reg[4:0] rt;

always @(ifid_o)
begin
    // extracting rs & rt
    rs = ifid_o[25:21]; // rna, which is also rs
    rt = ifid_o[20:16]; // rnb, which is also rt (may fix both in later labs)
    qa = rF[rs];
    qb = rF[rt];
end
endmodule
