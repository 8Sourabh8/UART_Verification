`timescale 1ns / 1ps

module receiver(
    input clk,rst,baud_pulse,
    input [1:0]reg_load,
    input [7:0]data_in,
    input rx,
    output [7:0] data_out,
    output rx_done
    );
reg [3:0] over_sampling;
reg b_pulse;
reg [7:0] recv_data;
reg [3:0] bit_count;
reg [3:0] baud_count;
reg [1:0]state,next_state;
localparam IDLE = 2'b00, START = 2'b01, RECEIVE = 2'b10, STOP = 2'b11;

always@(posedge clk)                     // Loading over sampling value in internal register
begin
    if(rst)
        over_sampling <= 4'h0;
    else if(reg_load[1] && reg_load[0])
        over_sampling <= data_in[3:0];
    else
        over_sampling <= over_sampling;
end

always@(posedge clk)                     // Oversamplinjg baud pulse counter
begin
    if(rst)
    begin
        baud_count <= 4'h0;
    end
    else if(!rx && state == IDLE)
    begin
        baud_count <= 4'h0;
    end
    else if(baud_count == over_sampling)
    begin
        baud_count <= 4'h0;
    end
    else if(baud_pulse)
    begin
        baud_count <= baud_count +1'b1;
    end
    else
    begin
        baud_count <= baud_count;
    end
end

always@(posedge clk)                       // Baud pulse generator for sampling rx
begin
    if(rst)
        b_pulse <= 1'h0;
    else if((baud_count == (over_sampling-1)/2) && baud_pulse)
        b_pulse <= 1'h1;
    else
        b_pulse <= 1'h0;
end

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
                recv_data = 8'h00;
                if(!rx)
                    next_state = START;
                else
                    next_state = IDLE;
           end
    START : begin
                recv_data = 8'h00;
                bit_count = 4'h0;
                if(baud_count == over_sampling-1 && baud_pulse)
                    next_state = RECEIVE;
                else 
                    next_state = START;
            end
    RECEIVE : begin
                if(bit_count == 8 && baud_count == over_sampling)
                    next_state = STOP;
                else
                begin
                    if(b_pulse)
                    begin
                        recv_data = {rx,recv_data[7:1]};
                        bit_count = bit_count +1'b1;
                        next_state = RECEIVE;
                    end
                    else
                    begin
                        recv_data = recv_data;
                        bit_count = bit_count;
                        next_state = RECEIVE;
                    end
                end
              end
    STOP : begin
                if(baud_count == over_sampling-1 && baud_pulse)
                    next_state = IDLE;
                else 
                    next_state = STOP;
           end
    default : next_state = IDLE;
    endcase
end

assign data_out = (state == RECEIVE && bit_count == 4'h8 && baud_count == over_sampling-1 && baud_pulse)?recv_data:8'h00;
assign rx_done = (state == RECEIVE && bit_count == 4'h8 && baud_count == over_sampling-1 && baud_pulse)?1'h1:1'h0;
endmodule
