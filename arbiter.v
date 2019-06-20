module Arbiter (clk,RST,FRAME,mux_control,REQ,GNT);
input clk,RST,FRAME;
integer flag=0;
output [2:0] mux_control;
input [2:0] REQ ; 
output [2:0] GNT;
reg [2:0] mux_control_reg;
reg [2:0] GNT_REG=7;
assign mux_control=mux_control_reg;
assign GNT= GNT_REG;
always@(*)
begin
	if ((FRAME)&&(flag==0))
	begin
	case (REQ) 
	// A gets GNT
	3'b000: begin
	GNT_REG<=3'b110;
	mux_control_reg=3'b001;
	flag=1;
	end
	3'b010: begin
	GNT_REG<=3'b110;
	mux_control_reg=3'b001;
	flag=1;
	end
	3'b100: begin
	GNT_REG<=3'b110;
	mux_control_reg=3'b001;
	flag=1;
	end
	3'b110: begin
	GNT_REG<=3'b110;
	mux_control_reg=3'b001;
	flag=1;
	end
 	//B gets GNT
	3'b001: begin
	GNT_REG <=3'b101;
	mux_control_reg=3'b010;
	flag=1;
	end
	3'b101:begin
 	GNT_REG <=3'b101;
	mux_control_reg=3'b010;
	flag=1;
	end
	//C gets GNT
	011: begin
	GNT_REG <=3'b011;
	mux_control_reg=3'b100;
	flag=1;
	end
	endcase
	end
	else if(!(FRAME))
	begin
	flag=2;
	case (REQ) 
	// A gets GNT
	3'b000: begin
	GNT_REG<=3'b110;
	end
	3'b010: begin
	GNT_REG<=3'b110;
	end
	3'b100: begin
	GNT_REG<=3'b110;
	end
	3'b110: begin
	GNT_REG<=3'b110;
	end
 	//B gets GNT
	3'b001: begin
	GNT_REG <=3'b101;
	end
	3'b101:begin
 	GNT_REG <=3'b101;
	end
	//C gets GNT
	3'b011: begin
	GNT_REG <=3'b011;
	end
	endcase
	end
	else if((FRAME)&&(flag==2))
	begin
	flag=0;
	case (REQ) 
	// A gets GNT
	3'b000: begin
	mux_control_reg=3'b001;
	end
	3'b010: begin
	mux_control_reg=3'b001;
	end
	3'b100: begin
	mux_control_reg=3'b001;
	end
	3'b110: begin
	mux_control_reg=3'b001;
	end
 	//B gets GNT
	3'b001: begin
	mux_control_reg=3'b010;
	end
	3'b101:begin
 	mux_control_reg=3'b010;
	end
	//C gets GNT
	3'b011: begin
	mux_control_reg=3'b100;
	end
	endcase
	end
	
end
endmodule



