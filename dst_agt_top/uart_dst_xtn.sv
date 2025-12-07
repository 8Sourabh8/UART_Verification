class uart_dst_xtn extends uvm_sequence_item;
	bit [7:0]data_out;
	bit rx_done;

	`uvm_object_utils_begin(uart_dst_xtn)
	`uvm_field_int(rx_done,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(data_out,UVM_ALL_ON|UVM_HEX)
	`uvm_object_utils_end

	function new(string name = "uart_dst_xtn");
		super.new(name);
	endfunction
endclass