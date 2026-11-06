// Base test: builds the environment, configures the baud rate, sends one random byte
// and waits until the scoreboard has received every byte that was sent.
class uart_base_test extends uvm_test;
	`uvm_component_utils(uart_base_test)
	uart_env env;
	uart_config uart_cfg;
	bit [15:0]divisor = 5;
	bit [3:0]over_sampling = 2;
	int period;
	int baud_rate;
	int unsigned bytes_to_send;	// set by send_bytes(), used to know when the test is finished

	function new(string name = "uart_base_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(int)::get(this,"","clk_period",period))
			`uvm_error(get_type_name(),"FAILED TO CALCULATE BAUD RATE....... DISPLAYED VALUE IS WRONG")
		uart_cfg = uart_config::type_id::create("uart_cfg");
		uart_cfg.div_L = divisor[7:0];
		uart_cfg.div_M = divisor[15:8];
		uart_cfg.over_sampling = over_sampling;
		baud_rate = (10**9/period)/(divisor*over_sampling);
		uvm_config_db#(uart_config)::set(this,"*","uart_config",uart_cfg);
		super.build_phase(phase);
		env = uart_env::type_id::create("env",this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
		`uvm_info(get_type_name(),$sformatf("BAUD RATE : %0d",baud_rate),UVM_LOW)
	endfunction

	// Each test overrides this to choose its stimulus
	virtual task send_bytes();
		uart_base_seqs seq = uart_base_seqs::type_id::create("seq");
		seq.start(env.src_agt.src_seqr);
		bytes_to_send = 1;
	endtask

	// Wait until every byte has come out of the receiver, with a timeout so a lost byte cannot hang the test.
	// One frame is start + 8 data + stop bits; allow 12 bit-times per byte plus margin.
	task wait_for_rx();
		int unsigned clocks_per_bit = divisor * (over_sampling + 1) + 1;
		int unsigned timeout_ns = (bytes_to_send + 4) * 12 * clocks_per_bit * period;
		fork begin	// outer fork isolates "disable fork" so it only kills the two threads below
			fork
				wait(env.sco.bytes_received >= bytes_to_send);
				begin
					#(timeout_ns * 1ns);
					`uvm_error(get_type_name(),$sformatf("TIMEOUT : only %0d of %0d bytes received after %0d ns",
						env.sco.bytes_received, bytes_to_send, timeout_ns))
				end
			join_any
			disable fork;
		end join
	endtask

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		send_bytes();
		wait_for_rx();
		phase.drop_objection(this);
	endtask
endclass

// 20 random bytes written back to back. The TX FIFO is 16 deep, so it fills up
// and the driver must wait while busy (FIFO full) is high.
class uart_random_test extends uart_base_test;
	`uvm_component_utils(uart_random_test)

	function new(string name = "uart_random_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	task send_bytes();
		uart_random_seqs seq = uart_random_seqs::type_id::create("seq");
		seq.no_of_bytes = 20;
		seq.start(env.src_agt.src_seqr);
		bytes_to_send = seq.no_of_bytes;
	endtask
endclass

// Corner-case patterns (00, FF, 55, AA, 01, 80) followed by 10 random bytes
class uart_corner_test extends uart_base_test;
	`uvm_component_utils(uart_corner_test)

	function new(string name = "uart_corner_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	task send_bytes();
		uart_corner_seqs cseq = uart_corner_seqs::type_id::create("cseq");
		uart_random_seqs rseq = uart_random_seqs::type_id::create("rseq");
		rseq.no_of_bytes = 10;
		cseq.start(env.src_agt.src_seqr);
		rseq.start(env.src_agt.src_seqr);
		bytes_to_send = cseq.patterns.size() + rseq.no_of_bytes;
	endtask
endclass

// 64 random bytes: four times the FIFO depth, so the FIFO fills and drains repeatedly
class uart_long_test extends uart_base_test;
	`uvm_component_utils(uart_long_test)

	function new(string name = "uart_long_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	task send_bytes();
		uart_random_seqs seq = uart_random_seqs::type_id::create("seq");
		seq.no_of_bytes = 64;
		seq.start(env.src_agt.src_seqr);
		bytes_to_send = seq.no_of_bytes;
	endtask
endclass
