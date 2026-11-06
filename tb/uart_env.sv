class uart_env extends uvm_env;
	`uvm_component_utils(uart_env)
	uart_src_agt src_agt;
	uart_dst_agt dst_agt;
	uart_scoreboard sco;

	function new(string name = "uart_env", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		src_agt = uart_src_agt::type_id::create("src_agt",this);
		dst_agt = uart_dst_agt::type_id::create("dst_agt",this);
		sco     = uart_scoreboard::type_id::create("sco",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		src_agt.src_mon.src_ap.connect(sco.src_fifo.analysis_export);
		dst_agt.dst_mon.dst_ap.connect(sco.dst_fifo.analysis_export);
	endfunction
endclass
