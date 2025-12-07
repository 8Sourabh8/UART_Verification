class uart_src_sequencer extends uvm_sequencer#(uart_src_xtn);
	`uvm_component_utils(uart_src_sequencer)

	function new(string name = "uart_src_sequencer", uvm_component parent = null);
		super.new(name,parent);
	endfunction
endclass