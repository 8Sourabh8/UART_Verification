`timescale 1ns / 1ps

module transmitter(
    input clk,rst,baud_pulse,
    input [1:0]reg_load,
    input new_data,
    input [7:0]data_in,
    output reg tx,
    output tx_done
    );
reg [3:0] over_sampling;
reg n_data;
reg [7:0]temp_data;
reg [3:0] bit_count;
reg [3:0] baud_count;
reg [7:0] serial_data;
reg [1:0] state,next_state;
localparam IDLE = 2'b00, START = 2'b01, TRANSFER = 2'b10, STOP = 2'b11;
reg b_pulse;

always@(posedge clk)                     // Loading over sampling value in internal register
begin
    if(rst)
        over_sampling <= 4'h0;
    else if(reg_load[1] && reg_load[0])
        over_sampling <= data_in[3:0];
    else
        over_sampling <= over_sampling;
end

always@(posedge clk)                    // new_data samping used ofr CDC
begin
    if(rst)
    begin
        n_data <= 1'h0;
        temp_data <= 8'h00;
    end
    else if(state == START)
    begin
        n_data <= 1'h0;
        temp_data <= temp_data;
    end
    else if(new_data)
    begin
        n_data <= 1'h1;
        temp_data <= data_in;
    end
    else
    begin
        n_data <= n_data;
        temp_data <= temp_data;
    end
end

always@(posedge clk)                     // Oversamplinjg baud pulse counter
begin
    if(rst)
    begin
        baud_count <= 4'h0;
        b_pulse <= 1'h0;
    end
    else if(baud_count == over_sampling)
    begin
        baud_count <= 4'h0;
        b_pulse <= 1'h1;
    end
    else if(baud_pulse)
    begin
        baud_count <= baud_count +1'b1;
        b_pulse <= 1'h0;
    end
    else
    begin
        baud_count <= baud_count;
        b_pulse <= 1'h0;
    end
end

always@(posedge clk)              // Next state FSM logic
begin
    if(rst || reg_load != 2'h0)
        state <= IDLE;
    else
        state <= next_state;
end

always@(*)                                    // FSM Next state decoder
begin
    case(state)
    IDLE : begin
                tx = 1'b1;
                if(n_data && b_pulse)
                    next_state = START;
                else
                    next_state = IDLE;
           end
    START : begin
                tx = 1'b0;
                bit_count = 4'h0;
                serial_data = temp_data;
                if(b_pulse)
                    next_state = TRANSFER;
                else
                    next_state = START;
            end
    TRANSFER : begin
                tx = serial_data[0];
                if(bit_count == 8)
                 next_state = STOP;
                else
                    if(b_pulse)
                    begin
                        serial_data = {1'b1,serial_data[7:1]};
                        bit_count = bit_count + 1'b1;
                        next_state = TRANSFER;
                    end
                    else
                    begin
                        serial_data = serial_data;
                        bit_count = bit_count;
                        next_state = TRANSFER;
                    end
               end
    STOP : begin
                tx = 1'b1;
                if(b_pulse)
                    next_state = IDLE;
                else
                    next_state = STOP;
           end
    default : next_state = IDLE;
    endcase
end

assign tx_done = (state == STOP && b_pulse);
endmodule
