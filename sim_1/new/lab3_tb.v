`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2020 08:38:37 PM
// Design Name: 
// Module Name: lab3_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab3_tb();
reg clk_tb;
//wire [31:0] PC_tb;
wire [31:0] pc_out_tb;
wire [31:0] out_s_tb;
wire [31:0] do_tb;

// up to IF/ID
wire [31:0] ifid_out_tb;
wire wreg_tb;
wire m2reg_tb;
wire wmem_tb;
wire [3:0] aluc_tb;
wire aluimm_tb;
wire regrt_tb;
wire [4:0]mux_out_tb;
wire [31:0] qa_tb;
wire [31:0] qb_tb;

// up to ID/EXE
//wire wreg_o_tb;
//wire [3:0] aluc_o_tb;
//wire m2reg_o_tb;
//wire wmem_o_tb;
//wire aluimm_o_tb;
//wire [31:0] qa_o_tb;
//wire [31:0] qb_o_tb;

wire [31:0] e_out_tb;

//Up to EXE/MEM:
wire [4:0] mux_o3_tb;
wire [31:0] e_o2_tb;
//wire [31:0] qa_o2_tb;
//wire [31:0] qb_o2_tb;
wire ealuimm_tb;
wire [3:0] ealuc_tb;
wire ewmem_tb;
wire em2reg_tb;
wire ewreg_tb;
wire [31:0] ALUr_o_tb;
wire [31:0] ALUr_o2_tb;
wire [31:0] mux2_o_tb;


// up to MEM/WB:
wire [4:0] mux_o2_tb;
//wire [31:0] e_o3_tb
wire mm2reg_tb;
wire mwreg_tb;
wire mwmem_tb;
wire [31:0] ALUr_o2_tb;
//wire [31:0] qb_o2_tb;
wire [31:0] do_o_tb;

wire [4:0] mux_o1_tb;
wire [31:0] do_o2_tb;
wire [31:0] ALUr_o3_tb;

// WB:
wire [31:0] m3_out_tb;

// Final Muxs & CU:
wire [31:0] a_tb;
wire [31:0] b_tb;
wire [31:0] a_o_tb;
wire [31:0] b_o_tb;
wire [31:0] b_o2_tb;

wire [1:0] fwda_tb;
wire [1:0] fwdb_tb;

wire [4:0] rs;



initial begin
clk_tb = 0;
end

always begin
#5;
clk_tb =~clk_tb;
end 

PC pc(clk_tb,out_s_tb, pc_out_tb);

adder PCadder(pc_out_tb,out_s_tb);

IM instMem(pc_out_tb, do_tb);

IFID ifid(clk_tb, do_tb,ifid_out_tb);

CU cu(ifid_out_tb, mux_o2_tb, mm2reg_tb, mwreg_tb, mux_o3_tb,em2reg_tb, ewreg_tb, mux_o1_tb,
wreg_tb,m2reg_tb,wmem_tb,aluc_tb,aluimm_tb,regrt_tb, fwda_tb, fwdb_tb);

/* CU(input wire [31:0] ifid_out, input wire [4:0] mrn, input wire mm2reg, input wire mwreg, input wire [4:0] ern, 
            input wire em2reg, input wire ewreg, wrn
          output reg wreg, output reg m2reg, output reg wmem, output reg [3:0] aluc, output reg aluimm, output reg regrt,
          output reg [1:0] fwda, output reg [1:0] fwdb // need checking
    );*/

mux regrtMux(ifid_out_tb, regrt_tb, mux_out_tb);

qaMux qamux(qa_tb,ALUr_o_tb,ALUr_o2_tb,do_o_tb,fwda_tb,a_tb);
//module qaMux(input wire qa, input wire [31:0] ALUr_o, input wire [31:0] ALUr_o2, input wire [31:0] do, input wire [1:0] fwda, output reg [31:0] a);


qbMux qbmux(qb_tb,ALUr_o_tb,ALUr_o2_tb,do_o_tb,fwdb_tb,b_tb);

signExt signExtension(ifid_out_tb,e_out_tb);

IDEXE idexe(clk_tb, wreg_tb, m2reg_tb,wmem_tb,aluc_tb,aluimm_tb,a_tb,b_tb,mux_out_tb,e_out_tb,
ewreg_tb,ealuc_tb,em2reg_tb,ewmem_tb,ealuimm_tb,a_o_tb,b_o_tb,mux_o3_tb,e_o2_tb); // need checking
//module IDEXE(input wire clk, input wire wreg, input wire m2reg, input wire wmem, input wire [3:0] aluc, input wire aluimm, input wire [31:0] qa, input wire [31:0] qb, input wire [4:0] mux_o, input wire [31:0] e_o,
//output reg wreg_o, output reg [3:0] aluc_o, output reg m2reg_o, output reg wmem_o, output reg aluimm_o, output reg [31:0] qa_o, output reg [31:0] qb_o
//    , output reg [4:0] mux_o3, output reg [31:0] e_o2)

mux2 mux2(b_o_tb, e_o2_tb, ealuimm_tb, mux2_o_tb);

ALU alu(a_o_tb,mux2_o_tb,ealuc_tb, ALUr_o_tb);

EXEMEM exemem(clk_tb, ewreg_tb, em2reg_tb, ewmem_tb,ALUr_o_tb,b_o_tb,mux_o3_tb,
mwreg_tb, mm2reg_tb,mwmem_tb, ALUr_o2_tb,b_o2_tb,mux_o2_tb);
//module EXEMEM(input wire clk, input wire ewreg, input wire em2reg, input wire ewmem, input wire [31:0] ALUr, input wire [31:0] qb, input wire [4:0] mux_o,
//output reg mwreg, output reg mm2reg, output reg mwmem, output reg [31:0] ALUr_o, output reg [31:0] qb_o, output reg [4:0] mux_o2
   // ); // set output to input @ posedge clk

DM dm(ALUr_o2_tb, b_o2_tb, mwmem_tb, do_o_tb);


MEMWB memwb(clk_tb, mwreg_tb, mm2reg_tb, ALUr_o2_tb,mux_o2_tb, do_o_tb,
wwreg_tb, wm2reg_tb, mux_o1_tb, do_o2_tb, ALUr_o3_tb);
//module MEMWB(input clk, input wire mwreg, input wire mm2reg, input wire ALUr,input wire [4:0] mux_o, input wire [31:0] do,
//output reg wwreg, output reg wm2reg, output reg [4:0] mux_o1, output reg [31:0] do_o, output reg [31:0] ALUr_o
   // );

mux3 mux3(ALUr_o3_tb, do_o2_tb, wm2reg_tb, m3_out_tb);

regFile regF(clk_tb, ifid_out_tb, mux_o1_tb, m3_out_tb, wwreg_tb, qa_tb, qb_tb, rs);
//input wire[31:0]ifid_o, input wire[4:0] wn, input wire[31:0] d, input wire wwreg, output reg[31:0] qa, output reg[31:0] qb





endmodule
