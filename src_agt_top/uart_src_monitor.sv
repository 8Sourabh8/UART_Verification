class uart_src_monitor extends uvm_monitor;
	`uvm_component_utils(uart_src_monitor)
	virtual uart_if src_if;
	virtual uart_if.SRC_MON_MP vif;
	uart_src_xtn tr;

	function new(string name = "uart_src_monitor", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual uart_if)::get(this,"","src_if",src_if))
			`uvm_fatal(get_type_name(),"INTERFACE GETTING FAILED")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		vif = src_if;
	endfunction

	task sample_data();
		tr = uart_src_xtn::type_id::create("tr");
		while(vif.src_mon_cb.busy !== 1'b0)
			@(vif.src_mon_cb);
		while(vif.src_mon_cb.new_data !== 1'b1)
			@(vif.src_mon_cb);
		tr.data_in = vif.src_mon_cb.data_in;
		`uvm_info(get_type_name(),$sformatf("DATA SAMPLED : \n %0s",tr.sprint()),UVM_MEDIUM)
		@(vif.src_mon_cb);
	endtask

	task run_phase(uvm_phase phase);
		forever begin
			sample_data();
		end
	endtask
endclass