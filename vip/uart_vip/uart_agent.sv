class uart_agent extends uvm_agent;

  `uvm_component_utils(uart_agent);

  //virtual uart_if lhs_vif;
  virtual uart_if uart_vif;

  local string msg = "[UART_VIP][UART_AGENT]";

  uart_sequencer 	uart_seqr;
  uart_driver		uart_drv;
  uart_monitor		uart_mon;
  uart_configuration	uart_config;

  function new(string name = "uart_agent", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info({msg, "[build_phase]"}, "Entered...", UVM_MEDIUM)
    `uvm_info(get_type_name(), this.get_full_name(), UVM_MEDIUM)
    /* Get virtual interface from env via config_db
    * Hierarchy lhs: "uvm_test_top.uart_env.uart_lhs_agt.lhs_vif" 
    * Wildcard * will match any component name 
    * Hierarchy rhs: "uvm_test_top.uart_env.uart_rhs_agt.rhs_vif
    * get_full_name() return hierarchy of uvm_config_db path
    * this.get_full_name() also return hierarchical name of every class*/
    `uvm_info(get_type_name(), this.get_full_name(), UVM_FULL)
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_key", uart_vif))
      `uvm_fatal(get_type_name(), {"Cannot get lhs/rhs interface hierarchy ", get_full_name()})

    if (!uvm_config_db #(uart_configuration)::get(this, "", "config_key", uart_config))
      `uvm_fatal(get_type_name(), {"cannot get lhs/rhs config hierarchy ", get_full_name()})

    //if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", rhs_vif))
    //  `uvm_fatal(get_type_name(), "Cannot get rhs interface via config_db")

    /* Configure VIP working mode to setup components and send interface 
    * Later get configration setting from uart_configuration
    * */
    if (is_active == UVM_ACTIVE) begin
      `uvm_info(get_type_name(), $sformatf("Active agent is configured"), UVM_LOW)
      uart_seqr = uart_sequencer::type_id::create("uart_seqr", this);
      uart_drv = uart_driver::type_id::create("uart_drv", this);
      uart_mon = uart_monitor::type_id::create("uart_mon", this);

      /* Set virtual interface to drv and mon via uvm_config_db 
      * Return hierarchy: "uvm_test_top.uart_env.uart_agt.uart_drv.uart_vif"
      * Return hierarchy: "uvm_test_top.uart_env.uart_agt.uart_mon.uart_vif" */
      uvm_config_db #(virtual uart_if)::set(this, "uart_drv", "vif", uart_vif);
      uvm_config_db #(virtual uart_if)::set(this, "uart_mon", "vif", uart_vif);
      uvm_config_db #(uart_configuration)::set(this, "uart_drv", "config", uart_config);
      uvm_config_db #(uart_configuration)::set(this, "uart_mon", "config", uart_config);
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("Passive agent is configured"), UVM_LOW)
      uart_mon = uart_monitor::type_id::create("uart_mon", this);

      /* Set virtual interface to monitor */
      uvm_config_db #(virtual uart_if)::set(this, "uart_mon", "vif", uart_vif);
      uvm_config_db #(uart_configuration)::set(this, "uart_mon", "config", uart_config);
    end

    `uvm_info({msg, "[build_phase]"}, "Exited...", UVM_MEDIUM) 

  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);
    
    /* Connect driver port to sequencer export */
    if(get_is_active() == UVM_ACTIVE) begin
      uart_drv.seq_item_port.connect(uart_seqr.seq_item_export);
    end

  endfunction: connect_phase

endclass: uart_agent
