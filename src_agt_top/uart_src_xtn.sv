class uart_src_xtn extends uvm_sequence_item;
	bit new_data;
	bit [1:0]reg_load;
	rand bit [7:0]data_in;
	logic busy;

	`uvm_object_utils_begin(uart_src_xtn)
	`uvm_field_int(new_data,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(reg_load,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(busy,UVM_ALL_ON|UVM_BIN)
	`uvm_field_int(data_in,UVM_ALL_ON|UVM_HEX)
	`uvm_object_utils_end

	function new(string name = "uart_src_xtn");
		super.new(name);
	endfunction
endclass