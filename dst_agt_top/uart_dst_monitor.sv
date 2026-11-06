class uart_dst_monitor extends uvm_monitor;
	`uvm_component_utils(uart_dst_monitor)
	virtual uart_if dst_if;
	virtual uart_if.DST_MON_MP vif;
	uart_dst_xtn tr;
	uvm_analysis_port #(uart_dst_xtn) dst_ap;	// sends every byte the receiver outputs to the scoreboard

	function new(string name = "uart_dst_monitor", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual uart_if)::get(this,"","dst_if",dst_if))
			`uvm_fatal(get_type_name(),"INTERFACE GETTING FAILED")
		dst_ap = new("dst_ap",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = dst_if;
	endfunction

	// rx_done is a one-clock pulse; data_out is valid only in that clock
	task collect_data();
		tr = uart_dst_xtn::type_id::create("tr");
		while(vif.dst_mon_cb.rx_done !== 1'b1)
			@(vif.dst_mon_cb);
		tr.rx_done  = vif.dst_mon_cb.rx_done;
		tr.data_out = vif.dst_mon_cb.data_out;
		`uvm_info(get_type_name(),$sformatf("NEW DATA RECEIVED : \n %0s",tr.sprint()),UVM_MEDIUM)
		dst_ap.write(tr);
		@(vif.dst_mon_cb);
	endtask

	task run_phase(uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask

endclass
