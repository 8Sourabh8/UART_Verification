`timescale 1ns / 1ps

module baud_generator(
    input clk,rst,
    input [7:0]data_in,
    input [1:0]reg_load,
    output baud_pulse
    );
reg [7:0] DL,DM;
reg b_pulse;
integer divisor;
integer clk_count;

always@(posedge clk)                         // Loading of internal Registers
begin
    if(rst)
    begin
        DL <= 8'h00;
        DM <= 8'h00;
    end
    else if(!reg_load[1] && reg_load[0])
    begin
        DL <= data_in;
        DM <= DM;
    end
    else if(reg_load[1] && !reg_load[0])
    begin
        DL <= DL;
        DM <= data_in;
    end
    else
    begin
        DL <= DL;
        DM <= DM;
    end
end

always@(posedge clk)                       // Counter for generation of baud pulse based on divisor
begin
    if(rst)
    begin
        clk_count <= 0;
        b_pulse <= 1'b0;
    end
    else if(reg_load == 2'b00)
    begin
        if(clk_count < divisor-1)
        begin
            clk_count <= clk_count +1'b1;
            b_pulse <= 1'b0;
        end
        else
        begin
            clk_count <= 0;
            b_pulse <= 1'b1;
        end
    end
    else
    begin
        clk_count <= clk_count;
        b_pulse <= 1'h0;
    end
end

always@(DL,DM,rst)                    // Updataing divisor values based on loaded registers
begin
    if(rst)
        divisor = 0;
    else
        divisor = {DM,DL};
end

//assign baud_pulse = (reg_load == 2'h00)?b_pulse:1'h0;
assign baud_pulse = b_pulse;
endmodule
