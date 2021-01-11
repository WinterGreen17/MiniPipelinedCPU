`timescale 1ns / 1ps

module CU(input wire [31:0] ifid_out, input wire [4:0] mrn, input wire mm2reg, input wire mwreg, input wire [4:0] ern, 
            input wire em2reg, input wire ewreg, input wire [4:0] wrn,
          output reg wreg, output reg m2reg, output reg wmem, output reg [3:0] aluc, output reg aluimm, output reg regrt,
          output reg [1:0] fwda, output reg [1:0] fwdb // need checking
    );
    
    reg [5:0] op;
    reg [4:0] rs;
    reg [4:0] rt;
    reg [5:0] func;
    
    /*initial begin
    op = ifid_out[31:26]; // func doesn't exist for lw
    rs = ifid_out[25:21];
    rt = ifid_out[20:16];
    func = ifid_out[5:0];
    end*/
    
    always @ (*)
    begin
    op = ifid_out[31:26]; // func doesn't exist for lw
    rs = ifid_out[25:21];
    rt = ifid_out[20:16];
    func = ifid_out[5:0];
    
    if (op == 6'b000000) // check if add
        begin
            if (func == 6'b100000)  // add instruc
        begin
            wreg <= 1;
            m2reg <= 0;
            wmem <= 0;
            aluc <= 4'b0010; //add
            aluimm <= 0;
            regrt <=0;
        end
      else if (func == 6'b100010) //sub instruc
          begin
          wreg <= 1;
          m2reg <= 0;
          wmem <= 0;
          aluc <=4'b0110;
          aluimm <=0;
          regrt <= 0;
                end      
       else if (func == 6'b100100) //and instruc
           begin
           wreg <= 1;
           m2reg <= 0;
           wmem <= 0;
           aluc <=4'b0000;
           aluimm <=0;
           regrt <= 0;
           end
        else if (func == 6'b100101) //or instruc
            begin
            wreg <= 1;
            m2reg <= 0;
            wmem <= 0;
            aluc <=4'b0001;
            aluimm <=0;
            regrt <= 0;
            end
       else if (func == 6'b100110) //xor instruc
            begin
            wreg <= 1;
            m2reg <= 0;
            wmem <= 0;
            aluc <=4'b1011;
            aluimm <=0;
            regrt <= 0;
            end
        end
      
            
// implement forwarding: (CONFUSED W THE CONDITIONS)
if (ewreg != 0 && regrt != 1 && ern == rs)
begin
    fwda = 2'b01; // exe hazard
end else if (mrn != 0 && ern != rs && mrn == rs)
begin
    fwda = 2'b10; // mem hazard
end 
else if (rs == wrn && wrn != 0 && mrn != rs) begin
    fwda = 2'b11;
 end
else begin
fwda = 2'b00;
end

if (ewreg != 0 && regrt != 1 && ern == rt)
begin
    fwdb = 2'b01; // exe hazard
end
else if (mrn != 0 && ern != rt && mrn == rt)
begin
    fwdb = 2'b10; // mem hazard
end
else begin
fwdb = 2'b00;
end
end

endmodule


module IM(input wire [31:0]pc_out,output reg [31:0]do); 
reg [31:0] a;
reg [31:0] IM[0:511];

// modified for final
initial begin
IM[100] = 32'h00221820;
IM[104] = 32'h01232022; 
IM[108] = 32'h00692825; 
IM[112] = 32'h00693026; 
IM[116] = 32'h00693824; 
end

always @(pc_out,do)
begin
 a = pc_out;
 do = IM[a];
 
end
endmodule


module regFile(input clk, input wire[31:0]ifid_o, input wire[4:0] wn, input wire[31:0] d, input wire wwreg, output reg[31:0] qa, output reg[31:0] qb, output reg [4:0]rs); // similar to IM
// modify testbench
   reg[31:0] rF [0:31]; //31 x 31 array
   //reg[4:0] rs;
   reg[4:0] rt;
   integer i;
initial begin
    for (i=0; i<32;i=i+1) begin rF[i] <= 32'h00000000; end// set everu value in array to 0;
    rF[0] <= 32'h00000000;
    rF[1] <= 32'hA00000AA;
    rF[2] <= 32'h10000011;
    rF[3] <= 32'h20000022;
    rF[4] <= 32'h30000033;
    rF[5] <= 32'h40000044;
    rF[6] <= 32'h50000055;
    rF[7] <= 32'h60000066;
    rF[8] <= 32'h70000077;
    rF[9] <= 32'h80000088;
    rF[10] <= 32'h90000099;
end

always @(ifid_o, posedge clk)
begin
    // extracting rs & rt
    rs = ifid_o[25:21]; // rna, which is also rs
 
    rt = ifid_o[20:16]; // rnb, which is also rt (may fix both in later labs)
    qa = rF[rs];
    qb = rF[rt];
    end
  always @(negedge clk,ifid_o)
    begin
    if (wwreg == 1'b1) //writing
    begin
        // writing into reg
        // wn: addr
        // d: value that will be written into addr
       rF[wn] <= d;
    end
 end
 
endmodule


module mux(input wire [31:0]ifid_out, input wire s_regrt, output reg [4:0] m_out);
   reg [4:0] rd;
   reg [4:0] rt;
   


always @(ifid_out,s_regrt)
begin
 rd = ifid_out[15:11];
 rt = ifid_out[20:16];
    /*if (ifid_out[31:26] != 6'b100011) // check if opcode is lw
    begin
        rd <= ifid_out[15:11];
    end else begin
        rt <= ifid_out[20:16];
    end*/
   m_out <= s_regrt ? rt : rd; // selecting
end

endmodule


module PC(input clk, input wire [31:0]pc_in, output reg[31:0]pc_out); 
/*initial begin
 pc_out = 32'h00000064; 
end*/
always @(posedge clk)
begin
    pc_out<=pc_in;
end

endmodule


module signExt(input wire [31:0]ifid_out, output reg [31:0] e_out); // cat 16-32 bits
always @(ifid_out) 
begin
e_out = {{16{ifid_out[15]}},ifid_out[15:0]}; // concatenation
end
endmodule


module adder(input wire [31:0] in_pc, output reg [31:0] out_s);

 initial begin
 out_s = 32'h00000064; // pass this into PC
 end
 
 always @(*) 
 begin // I'm confused
    out_s <= in_pc + 32'h00000004;
end
  
endmodule


module IFID(input clk, input wire [31:0]a_in, output reg[31:0]do_out); // use wire to carry IM output over...?
always @ (posedge clk)
begin
 do_out<=a_in;
end
endmodule


module IDEXE(input wire clk, input wire wreg, input wire m2reg, input wire wmem, input wire [3:0] aluc, input wire aluimm, input wire [31:0] qa, input wire [31:0] qb, 
input wire [4:0] mux_o, input wire [31:0] e_o,
output reg wreg_o, output reg [3:0] aluc_o, output reg m2reg_o, output reg wmem_o, output reg aluimm_o, 
output reg [31:0] qa_o, output reg [31:0] qb_o
    , output reg [4:0] mux_o3, output reg [31:0] e_o2); // set output to input @ posedge clk
    always @(posedge clk)
    begin
     wreg_o<=wreg;
     aluc_o<=aluc;
     m2reg_o<=m2reg;
     aluimm_o<=aluimm;
     qa_o<=qa;
     qb_o<=qb;
     mux_o3 <= mux_o;
     e_o2 <= e_o;
     wmem_o<=wmem;
     // need to add mux & sign extender (resolved...?)
    end
endmodule


// LAB4 STARTS HERE:
module EXEMEM(input wire clk, input wire ewreg, input wire em2reg, input wire ewmem, input wire [31:0] ALUr, input wire [31:0] qb, input wire [4:0] mux_o,
output reg mwreg, output reg mm2reg, output reg mwmem, output reg [31:0] ALUr_o, output reg [31:0] qb_o, output reg [4:0] mux_o2
    ); // set output to input @ posedge clk
    always @(posedge clk)
    begin
       mwreg <= ewreg;
       mm2reg<=em2reg;
       mwmem<=ewmem;
       ALUr_o<=ALUr;
       qb_o<=qb;
       mux_o2<=mux_o;
    end
endmodule


module MEMWB(input clk, input wire mwreg, input wire mm2reg, input wire [31:0] ALUr,input wire [4:0] mux_o, input wire [31:0] do,
output reg wwreg, output reg wm2reg, output reg [4:0] mux_o1, output reg [31:0] do_o, output reg [31:0] ALUr_o
    ); // set output to input @ posedge clk
    always @(posedge clk)
    begin
       wwreg<=mwreg;
       wm2reg<=mm2reg;
       mux_o1<=mux_o;
       do_o<=do;
       ALUr_o<=ALUr;
    end
endmodule


module mux2(input [31:0]qb, input wire [31:0] e_o, input wire ealuimm, output reg [31:0] m2_out);
always @(qb,e_o,ealuimm,m2_out) 
begin
   m2_out <= ealuimm ? e_o : qb; // selecting
end
endmodule 


module ALU(input wire [31:0] qa, input wire [31:0] mux2_o, input wire [3:0] ealuc, output reg [31:0] r);
always @(mux2_o,qa,ealuc) 
begin
    case(ealuc)
        4'b0000: // AND
           r = qa & mux2_o; 
        4'b0001: // OR
           r = qa | mux2_o ;
        4'b0010: // add
           r = qa + mux2_o;
        4'b0110: // sub
           r = qa - mux2_o;
        4'b1100: // NOR
           r = ~(qa | mux2_o);
//        4'b0111: // set-on-less-than
//           if (qa<mux2_o)
//           begin
//            r <=1;
//           end else begin
//            r<=0;
//           end
        4'b1011: // XOR
           r = qa ^ mux2_o;
        //default:
            //r = qa + mux2_o; // default is addition
    endcase
end
endmodule

module DM(input wire [31:0] a, input wire [31:0] di, input wire mwmem, output reg [31:0] do);
reg [31:0] dataMem[0:511];
integer i;
initial begin
    for (i=0; i<512;i=i+1) begin dataMem[i] <= 32'h00000000; end// set every value in array to 0;
    dataMem[0] <= 32'hA00000AA;
    dataMem[4] <= 32'h10000011;
    dataMem[8] <= 32'h20000022;
    dataMem[12] <= 32'h30000033;
    dataMem[16] <= 32'h40000044;
    dataMem[20] <= 32'h50000055;
    dataMem[24] <= 32'h60000066;
    dataMem[28] <= 32'h70000077;
    dataMem[32] <= 32'h80000088;
    dataMem[36] <= 32'h90000099;
    //dataMem[40] <= 32'h90000099;
end

always @(a,di,mwmem,do)
begin
    if (mwmem == 1'b0) begin
    do <= dataMem[a];
  end
  //do <= dataMem[a];
  else if (mwmem == 1'b1) begin
    dataMem[di] <= dataMem[a];
  end
end
endmodule


// LAB5 stuff here:
module mux3(input wire [31:0] ALUr_o, input wire [31:0] do_o, input wire wm2reg, output reg [31:0] m3_out);
always @(ALUr_o,do_o,wm2reg) 
begin
   m3_out <= wm2reg ? do_o : ALUr_o; // selecting
end
endmodule 

// Final project stage: 
module qaMux(input wire [31:0] qa, input wire [31:0] ALUr_o, input wire [31:0] ALUr_o2, input wire [31:0] do, input wire [1:0] fwda, output reg [31:0] a);
always @(*)
begin
     case( fwda )
       2'b00 : a <= qa;
       2'b01 : a <= ALUr_o;
       2'b10 : a <= ALUr_o2;
       2'b11 : a <= do;
   endcase
end
endmodule

module qbMux(input wire [31:0] qb, input wire [31:0] ALUr_o, input wire [31:0] ALUr_o2, input wire [31:0] do, input wire [1:0] fwdb, output reg [31:0] b);
always @(*)
begin
    case( fwdb )
       2'b00 : b <= qb;
       2'b01 : b <= ALUr_o;
       2'b10 : b <= ALUr_o2;
       2'b11 : b <= do;
   endcase
end
endmodule


