class uart_dst_agt extends uvm_agent;
	`uvm_component_utils(uart_dst_agt)
	uart_dst_monitor dst_mon;

	function new(string name = "uart_dst_agt", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		dst_mon = uart_dst_monitor::type_id::create("dst_mon",this);
	endfunction
endclass