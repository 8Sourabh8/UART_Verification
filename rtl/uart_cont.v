`timescale 1ns / 1ps

module uart_cont(
    input clk,rst,
    input fifo_empty,
    input tx_done,
    output reg fifo_read,comm_start
    );
reg [1:0]state,next_state;
localparam IDLE = 2'b00, LOAD = 2'b01, START = 2'b10, DONE = 2'b11;    
    
always@(posedge clk)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;    
end

always@(*)
begin
    case(state)
    IDLE : begin
                comm_start = 1'h0;
                fifo_read = 1'b0;
                if(!fifo_empty)
                    next_state = LOAD;
                else
                    next_state = IDLE;
           end
    LOAD : begin
                fifo_read = 1'b1;
                comm_start = 1'h0;
                next_state = START;
           end
    START : begin
                fifo_read = 1'b0;
                comm_start = 1'h1;
                next_state = DONE;
            end        
    DONE : begin
               fifo_read = 1'b0;
               comm_start = 1'h0; 
               if(!fifo_empty && tx_done)
                    next_state = LOAD;
               else if(tx_done)
                    next_state = IDLE;
               else
                    next_state = DONE;
           end
    endcase
end
endmodule
