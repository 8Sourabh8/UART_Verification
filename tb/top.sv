module top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import uart_pkg::*;

    bit clk;
    parameter period = 10;

    always #(period/2) clk = ~clk;

    uart_if src_if(clk);
    uart_if dst_if(clk);

    uart_top DUT(clk, src_if.rst, src_if.new_data, src_if.reg_load, src_if.data_in, dst_if.data_out, src_if.busy, dst_if.rx_done);

    initial begin
        uvm_config_db#(int)::set(null,"uvm_test_top","clk_period",period);
        uvm_config_db#(virtual uart_if)::set(null,"uvm_test_top.env.src_agt.*","src_if",src_if);
        uvm_config_db#(virtual uart_if)::set(null,"uvm_test_top.env.dst_agt.*","dst_if",dst_if);

        run_test();
    end

    initial begin
        `ifdef VCS
            $fsdbDumpvars(0,top);
        `endif
    end
endmodule