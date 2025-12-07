interface uart_if(input clk);
    logic rst;
    logic new_data;
    logic [1:0]reg_load;
    logic [7:0]data_in;
    logic [7:0]data_out;
    logic busy,rx_done;
    
    parameter Tsetup = 1;
    parameter Thold = 1;
    
    clocking src_drv_cb @(posedge clk);
        default input #(Tsetup) output #(Thold);
        input busy;
        output rst, new_data, reg_load, data_in;
    endclocking

    clocking src_mon_cb @(posedge clk);
        default input #(Tsetup) output #(Thold);
        input busy;
        input rst, new_data, reg_load, data_in;
    endclocking

    clocking dst_mon_cb @(posedge clk);
        default input #(Tsetup) output #(Thold);
        input rx_done, data_out;
    endclocking

    modport SRC_DRV_MP(clocking src_drv_cb);
    modport SRC_MON_MP(clocking src_mon_cb);
    modport DST_MON_MP(clocking dst_mon_cb);
endinterface
