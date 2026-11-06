// UART scoreboard
// The DUT is a loopback UART: a byte written on data_in goes into the TX FIFO,
// is sent serially by the transmitter, received by the receiver and appears on
// data_out together with a one-clock rx_done pulse.
// So the reference model is simple: bytes must come out unchanged and in the
// same order they went in.
class uart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_scoreboard)

	uvm_tlm_analysis_fifo #(uart_src_xtn) src_fifo;	// bytes written by the source monitor
	uvm_tlm_analysis_fifo #(uart_dst_xtn) dst_fifo;	// bytes received by the destination monitor

	uart_src_xtn src_tr;
	uart_dst_xtn dst_tr;

	int unsigned bytes_received;	// bytes compared so far
	int unsigned bytes_matched;
	int unsigned bytes_mismatched;
	bit waiting_for_rx;		// a sent byte has been taken from src_fifo and is waiting for its received copy

	bit [7:0] cov_data;

	// Functional coverage on the data that was actually transferred
	covergroup uart_data_cg;
		option.per_instance = 1;
		DATA : coverpoint cov_data {
			bins all_zeros  = {8'h00};
			bins all_ones   = {8'hFF};
			bins alt_01010101 = {8'h55};
			bins alt_10101010 = {8'hAA};
			bins lsb_only   = {8'h01};
			bins msb_only   = {8'h80};
			bins low_range  = {[8'h02:8'h7F]};
			bins high_range = {[8'h81:8'hFE]};
		}
	endgroup

	function new(string name = "uart_scoreboard", uvm_component parent = null);
		super.new(name,parent);
		uart_data_cg = new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		src_fifo = new("src_fifo",this);
		dst_fifo = new("dst_fifo",this);
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			src_fifo.get(src_tr);
			waiting_for_rx = 1'b1;
			dst_fifo.get(dst_tr);
			waiting_for_rx = 1'b0;
			compare_byte(src_tr, dst_tr);
		end
	endtask

	function void compare_byte(uart_src_xtn sent, uart_dst_xtn rcvd);
		bytes_received++;
		if(rcvd.data_out === sent.data_in) begin
			bytes_matched++;
			`uvm_info(get_type_name(),$sformatf("BYTE %0d MATCHED : sent 0x%2h, received 0x%2h",
				bytes_received, sent.data_in, rcvd.data_out),UVM_LOW)
		end
		else begin
			bytes_mismatched++;
			`uvm_error(get_type_name(),$sformatf("BYTE %0d MISMATCH : sent 0x%2h, received 0x%2h",
				bytes_received, sent.data_in, rcvd.data_out))
		end
		cov_data = sent.data_in;
		uart_data_cg.sample();
	endfunction

	// At the end of the test nothing may be left over on either side
	function void check_phase(uvm_phase phase);
		int unsigned lost = src_fifo.used() + waiting_for_rx;
		super.check_phase(phase);
		if(lost != 0)
			`uvm_error(get_type_name(),$sformatf("%0d byte(s) were written into the UART but never came out of the receiver", lost))
		if(dst_fifo.used() != 0)
			`uvm_error(get_type_name(),$sformatf("the receiver produced %0d byte(s) that were never written", dst_fifo.used()))
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(),$sformatf("\n---------- UART SCOREBOARD SUMMARY ----------\n bytes compared   : %0d\n bytes matched    : %0d\n bytes mismatched : %0d\n data coverage    : %0.2f %%\n---------------------------------------------",
			bytes_received, bytes_matched, bytes_mismatched, uart_data_cg.get_inst_coverage()),UVM_LOW)
	endfunction
endclass
