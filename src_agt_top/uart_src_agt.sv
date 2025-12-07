class uart_src_agt extends uvm_agent;
	`uvm_component_utils(uart_src_agt)
	uart_src_driver src_drv;
	uart_src_monitor src_mon;
	uart_src_sequencer src_seqr;

	function new(string name = "uart_src_agt", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		src_drv = uart_src_driver::type_id::create("src_drv",this);
		src_mon = uart_src_monitor::type_id::create("src_mon",this);
		src_seqr = uart_src_sequencer::type_id::create("src_seqr",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		src_drv.seq_item_port.connect(src_seqr.seq_item_export);
	endfunction
endclass