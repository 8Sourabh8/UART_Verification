`timescale 1ns / 1ps

module uart_fifo(
    input clk,rst,wr,rd,
    input [7:0]din,
    output empty,full,
    output reg [7:0] dout
    );
reg [4:0]waddr,raddr;
reg [7:0]fifo[15:0]; 
integer i;

always@(posedge clk)  // Write operation
begin
  if(rst)  
  begin  // Reset applied
    waddr<= 5'b00000;
    for (i=0; i<16; i=i+1) //FIFO initialization to 0
      fifo[i] <= 8'b00000000;
  end
  else if((wr && !full)||(rd && !empty)) // Writing into fifo
  begin
    case({wr,rd})
	 2'b10: begin
	          fifo[waddr[3:0]]<= din;
				 waddr<= waddr+1'b1;
			  end
	 2'b1x: begin
	          fifo[waddr[3:0]]<= din;
				 waddr<= waddr+1'b1;
			  end
	 2'b01: fifo[raddr[3:0]]<= 8'b00000000;
	 2'bx1: fifo[raddr[3:0]]<= 8'b00000000;
	 2'b11: begin
	          fifo[waddr[3:0]]<= din;
				 waddr<= waddr+1'b1;
	          fifo[raddr[3:0]]<= 8'b00000000;
	        end
	 default: fifo[waddr[3:0]]<= fifo[waddr[3:0]];
	 endcase
  end
  else
    fifo[waddr[3:0]]<= fifo[waddr[3:0]];
end

always@(posedge clk)  // Read operation
begin
  if(rst)  
  begin  // Reset applied
    raddr<= 5'b00000;
    dout<= 8'h00;
  end
  else if(rd && !empty)
  begin
    dout<= fifo[raddr[3:0]][7:0];
    raddr<= raddr+1'b1;
  end
  else
    dout<= dout;
end

assign empty = (waddr==raddr);
assign full = ((waddr[4]!=raddr[4]) && (waddr[3:0]==raddr[3:0]));

endmodule