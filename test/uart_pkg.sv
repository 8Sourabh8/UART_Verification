package uart_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "uart_config.sv"

	`include "uart_src_xtn.sv"
	`include "uart_src_seqs.sv"
	`include "uart_src_driver.sv"
	`include "uart_src_monitor.sv"
	`include "uart_src_sequencer.sv"
	`include "uart_src_agt.sv"

	`include "uart_dst_xtn.sv"
	`include "uart_dst_monitor.sv"
	`include "uart_dst_agt.sv"

	`include "uart_env.sv"
	`include "uart_test_lib.sv"
endpackage