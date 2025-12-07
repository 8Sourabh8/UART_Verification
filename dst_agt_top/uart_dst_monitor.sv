class uart_dst_monitor extends uvm_monitor;
	`uvm_component_utils(uart_dst_monitor)
	virtual uart_if dst_if;
	virtual uart_if.DST_MON_MP vif;
	uart_dst_xtn tr;
	uart_config uart_cfg;

	function new(string name = "uart_dst_monitor", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual uart_if)::get(this,"","dst_if",dst_if))
			`uvm_fatal(get_type_name(),"INTERFACE GETTING FAILED")
		//if(!uvm_config_db#(uart_config)::get(this,"","uart_config",uart_cfg))
		//	`uvm_fatal(get_type_name(),"FAILED TO GET CONFIGURATION DATA")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = dst_if;
	endfunction

	task collect_data();
		//uvm_event e1 = uart_cfg.event_pool.get("e1");
		tr = uart_dst_xtn::type_id::create("tr");
		while(vif.dst_mon_cb.rx_done !== 1'b1)
		begin
			@(vif.dst_mon_cb);
			$display("RX_DONE : %0b",vif.dst_mon_cb.rx_done);
			$display("TIME : %0t",$time());
		end
		tr.rx_done = vif.dst_mon_cb.rx_done;
		tr.data_out = vif.dst_mon_cb.data_out;
		`uvm_info(get_type_name(),$sformatf("NEW DATA RECEIVED : \n %0s",tr.sprint()),UVM_LOW)
		@(vif.dst_mon_cb);
		//e1.trigger();
	endtask

	task run_phase(uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask

endclass
