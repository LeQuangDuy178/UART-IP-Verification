class uart_environment extends uvm_env;

  `uvm_component_utils(uart_environment) 

  local string msg = "[UART_ENVIRONMENT]";

  /* Interface */
  virtual uart_if	uart_vif;
  virtual ahb_if	ahb_vif;

  /* Components inside environment 
  * Scorebaord, agents, regmodel 
  * Registers inside UART IP DUT is configured by AHB Bus
  * Where ahb_transaction is capable of actual instruction
  * Therefore ahb_predictor and ahb_adapter is needed */
  uart_configuration	uart_vip_config;
  uart_scoreboard	uart_sco;
  uart_agent		uart_agt;
  ahb_agent		ahb_agt;
  uvm_reg_predictor #(ahb_transaction) ahb_predictor;
  uart_reg_block	uart_ip_regmodel;
  uart_reg2ahb_adapter	ahb_adapter;

  function new(string name = "uart_environment", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    
    `uvm_info({msg, "[build_phase]"}, "Entered...", UVM_FULL)

    //----------------------------------------------------------------
    // uvm_config_db get()
    // Get virtual interface from test for uart agent and ahb agent
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_key", uart_vif))
      `uvm_fatal({msg, "[build_phase]"}, "Cannot get uart vif via config_db")
    else
      `uvm_info({msg, "[build_phase]"}, "Get uart vif successful", UVM_FULL)

    if (!uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_key", ahb_vif))
      `uvm_fatal({msg, "[build_phase]"}, "Cannot get ahb vif via config_db")
    else
      `uvm_info({msg, "[build_phase]"}, "Get ahb vif successful", UVM_FULL)

    if (!uvm_config_db #(uart_configuration)::get(this, "", "uart_vip_key", uart_vip_config))
      `uvm_fatal({msg, "[build_phase]"}, "Cannot get uart vip config")
    else
      `uvm_info({msg, "[build_phase]"}, "Get uart vip config successful", UVM_FULL)

    //----------------------------------------------------------------
    // Object creating inside env components
    uart_sco = uart_scoreboard::type_id::create("uart_sco", this);
    uart_agt = uart_agent::type_id::create("uart_agt", this);
    ahb_agt = ahb_agent::type_id::create("ahb_agt", this);
    ahb_adapter = uart_reg2ahb_adapter::type_id::create("ahb_adapter");
    uart_ip_regmodel = uart_reg_block::type_id::create("uart_ip_regmodel", this);
    uart_ip_regmodel.build();
    ahb_predictor = uvm_reg_predictor #(ahb_transaction)::type_id::create("ahb_predictor", this);

    // Active/passive mode for agents
    //ahb_agt.is_active = UVM_PASSIVE;
    //uart_agt.is_active = UVM_PASSIVE; 

    //----------------------------------------------------------------
    // uvm_config_db set()
    // Set virtual interface to uart_agent and ahb_agent
    // Set UART VIP config to UART VIP agent
    // SET UART VIP config to UART Scoreboard
    uvm_config_db #(virtual uart_if)::set(this, "uart_agt", "uart_key", uart_vif);
    uvm_config_db #(virtual ahb_if)::set(this, "ahb_agt", "ahb_key", ahb_vif);
    uvm_config_db #(uart_configuration)::set(this, "uart_agt", "config_key", uart_vip_config);
    uvm_config_db #(uart_configuration)::set(this, "uart_sco", "config_key", uart_vip_config);
    //----------------------------------------------------------------

    `uvm_info({msg, "[build_phase]"}, "Exited...", UVM_FULL)

  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
  
    super.connect_phase(phase);

    `uvm_info({msg, "[connect_phase]"}, "Entered...", UVM_FULL)

    /* Connect analysis port of 2 agents' monitor
    * To associated analysis export of scoreboard pre-defined by protocol */
    uart_agt.uart_mon.item_observed_port.connect(uart_sco.uart_item_collected_export);
    ahb_agt.monitor.item_observed_port.connect(uart_sco.ahb_item_collected_export);

    /* Regmodel, adapter and predictor connection */
    if (uart_ip_regmodel.get_parent() == null)
      uart_ip_regmodel.ahb_map.set_sequencer(ahb_agt.sequencer, ahb_adapter);

    ahb_predictor.map = uart_ip_regmodel.ahb_map;
    ahb_predictor.adapter = ahb_adapter;
    ahb_agt.monitor.item_observed_port.connect(ahb_predictor.bus_in);

    `uvm_info({msg, "[connect_phase]"}, "Exited...", UVM_FULL)

  endfunction: connect_phase

endclass: uart_environment
