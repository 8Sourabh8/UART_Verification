// One random byte
class uart_base_seqs extends uvm_sequence#(uart_src_xtn);
	`uvm_object_utils(uart_base_seqs)

	function new(string name = "uart_base_seqs");
		super.new(name);
	endfunction

	task send_byte(bit [7:0] value, bit randomize_value);
		req = uart_src_xtn::type_id::create("req");
		start_item(req);
		if(randomize_value) begin
			assert(req.randomize()) else
				`uvm_error(get_type_name(),"RANDOMIZATION FAILED")
		end
		else
			req.data_in = value;
		req.reg_load = 2'b00;
		req.new_data = 1'b1;
		finish_item(req);
	endtask

	task body();
		send_byte(8'h00, 1'b1);
	endtask
endclass

// no_of_bytes random bytes, written back to back (more than 16 fills the TX FIFO)
class uart_random_seqs extends uart_base_seqs;
	`uvm_object_utils(uart_random_seqs)
	int unsigned no_of_bytes = 20;

	function new(string name = "uart_random_seqs");
		super.new(name);
	endfunction

	task body();
		repeat(no_of_bytes)
			send_byte(8'h00, 1'b1);
	endtask
endclass

// Corner-case data patterns: every bit 0, every bit 1, alternating bits, single LSB and MSB
class uart_corner_seqs extends uart_base_seqs;
	`uvm_object_utils(uart_corner_seqs)
	bit [7:0] patterns[$] = '{8'h00, 8'hFF, 8'h55, 8'hAA, 8'h01, 8'h80};

	function new(string name = "uart_corner_seqs");
		super.new(name);
	endfunction

	task body();
		foreach(patterns[i])
			send_byte(patterns[i], 1'b0);
	endtask
endclass
