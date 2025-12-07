class uart_config extends uvm_object;
	`uvm_object_utils(uart_config)
	bit [7:0]div_L, div_M;
	bit [3:0]over_sampling;
	//uvm_event_pool event_pool = uvm_event_pool::get_global_pool();	

	function new(string name = "uart_config");
		super.new(name);
	endfunction
endclass
