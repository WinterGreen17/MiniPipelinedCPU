`timescale 1ns / 1ps


module IDEXE(input clk, input wreg, input m2reg, input wmem, input [3:0] aluc, input aluimm, input [31:0] qa, input [31:0] qb, 
output reg wreg_o, output reg [3:0] aluc_o, output reg m2reg_o, output reg wmem_o, output reg aluimm_o, output reg [31:0] qa_o, output reg [31:0] qb_o
    ); // set output to input @ posedge clk
    always @(posedge clk)
    begin
     wreg_o<=wreg;
     aluc_o<=aluc;
     m2reg_o<=m2reg;
     aluimm_o<=aluimm;
     qa_o<=qa;
     qb_o<=qb;
    end
endmodule
