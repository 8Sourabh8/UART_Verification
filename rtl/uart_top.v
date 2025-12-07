`timescale 1ns / 1ps

module uart_top(
    input clk, rst,
    input new_data,
    input [1:0]reg_load,
    input [7:0]data_in,
    output [7:0] data_out,
    output busy,rx_done
    );
wire [7:0]dout;
wire comm_start;
wire [7:0]din = comm_start?dout:data_in;

baud_generator BAUD_GEN(clk,rst,data_in,reg_load,baud_pulse);    
uart_fifo FIFO(clk,rst,new_data,fifo_read,data_in,fifo_empty,busy,dout);
uart_cont CONTROLLER(clk,rst,fifo_empty,tx_done,fifo_read,comm_start);
transmitter DUT2(clk,rst,baud_pulse,reg_load,comm_start,din,txrx,tx_done);
receiver RECV(clk,rst,baud_pulse,reg_load,data_in,txrx,data_out,rx_done);

endmodule
