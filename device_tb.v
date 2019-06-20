
module deviceTB;

reg RST ;
wire [2:0] mux_control;
wire [2:0] REQ;
wire [2:0] GNT;
wire [31:0] GLOBAL_AD ;
wire [3:0] GLOBAL_C_BE;
reg [3:0] N;
reg [3:0] b_enable;
reg clk;
reg force_request1;
reg force_request2;
reg force_request3;
reg [31:0]D1;
reg [31:0]D2;
reg [31:0]D3;
wire GLOBAL_DIVSEL2;
wire GLOBAL_DIVSEL1;
wire GLOBAL_DIVSEL3;
wire GLOBAL_IRDY;
wire GLOBAL_TRDY2;
wire GLOBAL_TRDY3;
wire GLOBAL_TRDY1;
wire GLOBAL_FRAME;
reg [31:0]own_address1;
reg [31:0]own_address2;
reg [31:0]own_address3;
reg [31:0]AddressToContact;
reg [3:0]control ;
wire REQ1,REQ2,REQ3,FRAME1,FRAME2,FRAME3,I_AM_OWNER1,I_AM_OWNER2,I_AM_OWNER3 ,IRDY1,IRDY2,IRDY3;
reg [2:0]I_AM_OWNERS;
wire [2:0]IRDYS;
wire [2:0]FRAMES;
assign IRDYS={IRDY3,IRDY2,IRDY1};
assign FRAMES={FRAME3,FRAME2,FRAME1};
assign REQ={REQ3,REQ2,REQ1};
always 
begin
#5
clk <= ~ clk;
end

//read test
//***********when you run this pleas comment the other test cases******** 


/*
initial
begin
N=1;
force_request1=1;
clk <= 0;
AddressToContact=2;
own_address1=1;
own_address2=2;
own_address3=3;
control=4'b0000;
#10
force_request1=0;
end
*/



//write test
//***********when you run this pleas comment the other test cases******** 



/*
initial
begin
N=4;
force_request1=1;
clk <= 0;
AddressToContact=2;
own_address1=1;
own_address2=2;
own_address3=3;
control=4'b0001;
#10
force_request1=0;
end
initial
begin
D1=32'HAAAA_AAAA;
#40
D1=32'HBBBB_BBBB;
#5
D1=32'HCCCC_CCCC;
end
initial
begin
b_enable=4'b0001;
#30
b_enable=4'b0010;
#10
b_enable=4'b0100;
#10
b_enable=4'b1000;
end
*/


//***********when you run this pleas comment the other test cases******** 
//integration(multipale transactions)
//***************run continuously or for 500 ns for example to see the full graph ************

initial
begin
N=4;
force_request1=1;
force_request2=0;
force_request3=0;
clk <= 0;
AddressToContact=2;
own_address1=1;
own_address2=2;
own_address3=3;
control=4'b0001;
#10
force_request1=0;
#51
N=3;
force_request1=0;
force_request2=1;
force_request3=0;
own_address1=1;
own_address2=2;
own_address3=3;
control=4'b0001;
#10
force_request2=0;
#5
AddressToContact=1;
#35
N=3;
force_request1=1;
force_request2=0;
force_request3=1;
own_address1=1;
own_address2=2;
own_address3=3;
control=4'b0001;
#10
force_request1=0;
#5
AddressToContact=3;
#5
force_request3=0;
#40
AddressToContact=2;
end

initial 
begin
b_enable=4'b1111;
#60
b_enable=4'bzzzz;
#20
b_enable=4'b1111;
#30
b_enable=4'bzzzz;
#20
b_enable=4'b1111;
#30
b_enable=4'bzzzz;
#10
b_enable=4'b1111;
#20
b_enable=4'bzzzz;
#20
b_enable=4'b1111;
#20
b_enable=4'bzzzz;
end

initial
begin
D1=32'HAAAA_AAAA;
#40
D1=32'HBBBB_BBBB;
#5
D1=32'HCCCC_CCCC;
#15
D1=32'Hzzzz_zzzz;
D2=32'HAAAA_AAAA;
#40
D2=32'HBBBB_BBBB;
#5
D2=32'Hzzzz_zzzz;
D1=32'HAAAA_AAAA;
#40
D1=32'HBBBB_BBBB;
D3=32'HAAAA_AAAA;
#10
D1=32'Hzzzz_zzzz;
#30
D3=32'Hzzzz_zzzz;
#20
D3=32'HBBBB_BBBB;
#25
D3=32'Hzzzz_zzzz;
end

Mux mmm(mux_control,IRDYS,FRAMES,GLOBAL_IRDY,GLOBAL_FRAME);
DEVICE DivA(force_request1,AddressToContact,own_address1,D1,control,clk,REQ1,GNT[0],FRAME1,IRDY1,I_AM_OWNER1 ,GLOBAL_IRDY,b_enable,N,GLOBAL_AD,GLOBAL_C_BE,GLOBAL_TRDY1,GLOBAL_DIVSEL1,GLOBAL_FRAME);
DEVICE DivB(force_request2,AddressToContact,own_address2,D2,control,clk,REQ2,GNT[1],FRAME2,IRDY2,I_AM_OWNER2  ,GLOBAL_IRDY,b_enable,N,GLOBAL_AD,GLOBAL_C_BE,GLOBAL_TRDY2,GLOBAL_DIVSEL2,GLOBAL_FRAME);
DEVICE DivC(force_request3,AddressToContact,own_address3,D3,control,clk,REQ3,GNT[2],FRAME3,IRDY3,I_AM_OWNER3  ,GLOBAL_IRDY,b_enable,N,GLOBAL_AD,GLOBAL_C_BE,GLOBAL_TRDY3,GLOBAL_DIVSEL3,GLOBAL_FRAME);
Arbiter A1(clk,RST,GLOBAL_FRAME,mux_control,REQ,GNT);
endmodule

