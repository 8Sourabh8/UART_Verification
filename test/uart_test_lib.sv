class uart_base_test extends uvm_test;
	`uvm_component_utils(uart_base_test)
	uart_env env;
	uart_config uart_cfg;
	bit [15:0]divisor = 5;
	bit [3:0]over_sampling = 2;
	int period;
	int baud_rate;
	uart_base_seqs seq1;

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
		seq1 = uart_base_seqs::type_id::create("seq1");
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
		`uvm_info(get_type_name(),$sformatf("BAUD RATE : %0d",baud_rate),UVM_LOW)
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		repeat(1)
			seq1.start(env.src_agt.src_seqr);
		//#1000000000;
		phase.drop_objection(this);
	endtask
endclass
