class uart_base_seqs extends uvm_sequence#(uart_src_xtn);
	`uvm_object_utils(uart_base_seqs)

	function new(string name = "uart_base_seqs");
		super.new(name);
	endfunction

	task body();
		req = uart_src_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize()) else
			`uvm_error(get_type_name(),"RANDOMIZATION FAILED")
		req.reg_load = 2'b00;
		req.new_data = 1'b1;
		finish_item(req);
	endtask
endclass