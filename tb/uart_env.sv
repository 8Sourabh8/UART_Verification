class uart_env extends uvm_env;
	`uvm_component_utils(uart_env)
	uart_src_agt src_agt;
	uart_dst_agt dst_agt;

	function new(string name = "uart_env", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		src_agt = uart_src_agt::type_id::create("src_agt",this);
		dst_agt = uart_dst_agt::type_id::create("dst_agt",this);
	endfunction
endclass