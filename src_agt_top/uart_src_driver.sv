class uart_src_driver extends uvm_driver#(uart_src_xtn);
	`uvm_component_utils(uart_src_driver)
	virtual uart_if src_if;
	virtual uart_if.SRC_DRV_MP vif;
	uart_config uart_cfg;

	function new(string name = "uart_src_driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual uart_if)::get(this,"","src_if",src_if))
			`uvm_fatal(get_type_name(),"INTERFACE GETTING FAILED")
		if(!uvm_config_db#(uart_config)::get(this,"","uart_config",uart_cfg))
			`uvm_fatal(get_type_name(),"FAILED TO GET CONFIGURATION DATA")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = src_if;
	endfunction

	task reset_uart();
		@(vif.src_drv_cb);
		vif.src_drv_cb.rst <= 1'b1;
		@(vif.src_drv_cb);
		vif.src_drv_cb.rst <= 1'b0;
		`uvm_info(get_type_name(),"RESET DONE",UVM_LOW)
	endtask

	task conifgure_uart();
		@(vif.src_drv_cb);
		vif.src_drv_cb.reg_load <= 2'b01;
		vif.src_drv_cb.data_in <= uart_cfg.div_L;
		@(vif.src_drv_cb);
		vif.src_drv_cb.reg_load <= 2'b10;
		vif.src_drv_cb.data_in <= uart_cfg.div_M;
		@(vif.src_drv_cb);
		vif.src_drv_cb.reg_load <= 2'b11;
		vif.src_drv_cb.data_in <= uart_cfg.over_sampling;
		@(vif.src_drv_cb);
		vif.src_drv_cb.reg_load <= 2'b00;
		@(vif.src_drv_cb);
		`uvm_info(get_type_name(),"UART CONFIGURATION DONE",UVM_LOW)
	endtask

	task drive_dut(uart_src_xtn tr);
		//uvm_event e1 = uart_cfg.event_pool.get("e1");
		@(vif.src_drv_cb);
		while(vif.src_drv_cb.busy !== 1'b0)
			@(vif.src_drv_cb);
		vif.src_drv_cb.new_data <= tr.new_data;
		vif.src_drv_cb.data_in <= tr.data_in;
		`uvm_info(get_type_name(),$sformatf("NEW DATA SENT : \n %0s",tr.sprint()),UVM_LOW)
		@(vif.src_drv_cb);
		vif.src_drv_cb.new_data <= 1'b0;
		//e1.wait_trigger();
	endtask

	task run_phase(uvm_phase phase);
		reset_uart();
		conifgure_uart();
		forever begin
			seq_item_port.get_next_item(req);
			drive_dut(req);
			seq_item_port.item_done();
		end
	endtask
endclass
