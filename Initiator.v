module DEVICE(force_request,AddressToContact,own_address,D,control,clk,req,GNT,frame,irdy,i_am_owner ,GLOBAL_IRDY,b_enable,N,ad_global,cbe_global,GLOBAL_TRDY,GLOBAL_DIVSEL,GLOBAL_FRAME);
reg [3:0]cont;
input GLOBAL_FRAME;
integer mem_pointer=0;
integer flag4=0;
integer flag=0;
integer flag2=0;
integer flag3=0;
input [3:0] b_enable;
output wire GLOBAL_TRDY;
output wire GLOBAL_DIVSEL;
inout [31:0] ad_global;
inout [3:0] cbe_global;
reg[3:0]CBE_GLOBAL_reg;
input [3:0]N;
integer n=0;
reg [31:0] mem [9:0];
input wire clk,GNT,force_request;
input wire [31:0]D;
input wire GLOBAL_IRDY;
input wire [31:0]own_address;
input wire [31:0]AddressToContact;
input wire [3:0]control ;
reg REQ = 1,FRAME =1,I_AM_OWNER = 0,IRDY =1,global_trdy=1,global_divsel=1;
reg [31:0]AD_global;
reg [3:0] CBE_GLOBAL;
reg [31:0] DATA;
output wire req,frame,i_am_owner,irdy;
assign GLOBAL_TRDY=global_trdy;
assign GLOBAL_DIVSEL=global_divsel;
assign req=REQ;
assign frame=FRAME;
assign i_am_owner=I_AM_OWNER;
assign irdy=IRDY;
integer counter=0;
wire IDLE ;
assign cbe_global=CBE_GLOBAL;
assign ad_global=AD_global;
assign IDLE = GLOBAL_FRAME & GLOBAL_IRDY ;
always @(posedge clk)
begin
if(force_request)
begin
	counter=counter+1;
end
end
always @(posedge clk)
begin
if(counter && (GNT) && FRAME )
begin
	@(negedge clk)
	REQ<=0;
end
else if ((~GNT)  && GLOBAL_FRAME && (!(counter==0)))
begin
	@(negedge clk)
	flag4=1;
	counter=counter-1;
	FRAME = 0;
	REQ=1;
	AD_global=AddressToContact;
	CBE_GLOBAL=control;
end
end

always @(posedge clk)//just for observing the graphs
begin

 if ((~GNT)  && IDLE & (~ REQ) )
begin
	@(negedge clk)
	I_AM_OWNER<=1;
end

end


always @(posedge clk)
begin
if((~FRAME)&&(control==4'b0000)) //read **Initiator**
begin	//handling frames of intiator in case of read 
	@(negedge clk)
	AD_global=32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz;
	if((N>n)&&(N-n!=0))
	begin
	IRDY<=0;
	CBE_GLOBAL<=b_enable;
	n=n+1;
	if((N-n==0))
	begin
	#20
	FRAME = 1;
	#10
	IRDY<=1;
	n=0;
	end
	end
	
end
else if((~FRAME)&&(control==4'b0001)) //write **Initiator**
begin	//handling frames of intiator in case of write
	@(negedge clk)
	if(N>n)
	IRDY<=0;
	AD_global<=D;
	CBE_GLOBAL<=b_enable;
	n=n+1;
	if((N-n==0))
	begin
	FRAME = 1;
	#10
	IRDY<=1;
	n=0;
	end

	
end

end

always @(posedge clk) // in case of read transction to diable the other divce (not the initator nor the target) for read
begin
if((flag4==0)&&(!(own_address==AddressToContact)))
begin
AD_global=32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz;
CBE_GLOBAL=4'bzzzz;
end
end

always @(posedge clk)
begin
if((own_address==AddressToContact)&&(control==4'b0000)) //read mem **target** 
begin //handling the target frames
	if(flag3==0)//
	begin
	AD_global=32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz; 
	CBE_GLOBAL=4'bzzzz;
	flag3=1;
	end
	@(negedge clk)
	if(flag==0)
	begin
	flag=1;
	@(negedge clk)
	#10
	global_trdy=0;
	global_divsel=0;
	flag=1;
	end
	else if(flag==1)
	#20
	if(N-1<=mem_pointer)
	begin
	global_trdy=1;
	global_divsel=1;
	end
	
end
end
always @(posedge clk)
begin
if((own_address==AddressToContact)&&(control==4'b0000)) //read mem **target** 
begin   // handling memory part
	if(flag3==0)
	begin
	AD_global=32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz;
	CBE_GLOBAL=4'bzzzz;
	flag3=1;
	end
	@(negedge clk)
	if(flag2==0)
	begin
	flag2=1;
	@(negedge clk)
	flag2=1;
	end
	else if(flag2==1)
	begin
	AD_global=mem[mem_pointer];
	if(N-1>mem_pointer)
	mem_pointer=mem_pointer+1;
	end
	
end
end 

always@(negedge clk)// handling the frames of target for the target
begin
if((GLOBAL_FRAME==0)&&(own_address==AddressToContact)&&(control==4'b0001))
begin
global_trdy=0;
global_divsel=0;
end
end
always@(negedge clk)
begin
if((GLOBAL_FRAME==1)&&(own_address==AddressToContact)&&(control==4'b0001))
begin
global_trdy=1;
global_divsel=1;
end
end
always @(posedge clk)
begin
if((own_address==AddressToContact)&&(control==4'b0001)&& (!(ad_global==AddressToContact))) //write mem **target** 
begin
	AD_global=32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz;//to make only the initiator control the path
	CBE_GLOBAL=4'bzzzz;
	case(cbe_global)// a case for byte enable 
	4'b0000:DATA=ad_global&32'h00000000;
	4'b0001:DATA=ad_global&32'h000000ff;
	4'b0010:DATA=ad_global&32'h0000ff00;
 	4'b0011:DATA=ad_global&32'h0000ffff;
	4'b0100:DATA=ad_global&32'h00ff0000;
	4'b0101:DATA=ad_global&32'h00ff00ff;
	4'b0110:DATA=ad_global&32'h00ffff00;
	4'b0111:DATA=ad_global&32'h00ffffff;
	4'b1000:DATA=ad_global&32'hff000000;
	4'b1001:DATA=ad_global&32'hff0000ff;
	4'b1010:DATA=ad_global&32'hff00ff00;
	4'b1011:DATA=ad_global&32'hff00ffff;
	4'b1100:DATA=ad_global&32'hffff0000;
	4'b1101:DATA=ad_global&32'hffff00ff;
	4'b1110:DATA=ad_global&32'hffffff00;
	4'b1111:DATA=ad_global&32'hffffffff;
	endcase
	if (flag==0) // flag for timming of clk to ensure that only the required data is saved in the memory
	begin
	mem[mem_pointer]=DATA;
	mem_pointer=mem_pointer+1;
	flag=1;
	end
	else if (flag==1)
	begin
	@(negedge clk)
	mem[mem_pointer]=DATA;
	if(N-2>mem_pointer)
	mem_pointer=mem_pointer+1;
	end
end
	else if((control==4'b0001)&&(flag4==0)) // in case of read transction to diable the other divce (not the initator nor the target) for write
	begin
	AD_global=32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz;
	CBE_GLOBAL=4'bzzzz;
	end

end


endmodule
