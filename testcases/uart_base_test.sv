class uart_base_test extends uvm_test;

  `uvm_component_utils(uart_base_test)

  string msg = "[TEST TOP]";

  /* Interface for test component 
  * Including uart_vif, ahb_vif and intr_vif */
  virtual uart_if	uart_vif;
  virtual ahb_if	ahb_vif;
  virtual interrupt_if	intr_vif;

  /* Components inside test: env and sequence 
  * UART VIP Config */
  uart_environment	uart_env;
  uart_configuration	uart_vip_config;
  //uart_sequence	uart_seq;
  //ahb_sequence	ahb_seq;

  /* Regmodel comp */
  uart_reg_block	uart_ip_regmodel;

  // Error catcher and report server
  uvm_report_server	svr_reporter;
  uart_error_catcher	err_catcher;

  // Read data reference argument
  bit [31:0] rdata;

  // Registers' properties - enum type
  `include "../regmodel/register/uart_reg_field_define.sv"

  // Timeout if TB is hang
  time usr_timeout = 1s;

  function new(string name = "uart_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    `uvm_info({msg, "[build_phase]"}, "Entered...", UVM_FULL)

    //----------------------------------------------------------
    // uvm_config_db get()
    // Get virtual interface from testbench and other data
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_key", uart_vif))
      `uvm_fatal({msg, "[build_phase]"}, "Cannot get uart vif via config_db")  
    else   
      `uvm_info({msg, "[build_phase]"}, "Get uart vif successful", UVM_FULL)

    if (!uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_key", ahb_vif))
      `uvm_fatal({msg, "[build_phase]"}, "Cannot get ahb vif via config_db")
    else
      `uvm_info({msg, "[build_phase]"}, "Get ahb vif successful", UVM_FULL)

    if (!uvm_config_db #(virtual interrupt_if)::get(this, "", "intr_key", intr_vif))
      `uvm_fatal({msg, "[build_phase]"}, "Cannot get intr vif via config_db")
    else
      `uvm_info({msg, "[build_phase]"}, "Get intr vif successful", UVM_FULL)

    //----------------------------------------------------------

    //----------------------------------------------------------
    // Object creating for components inside test
    uart_vip_config = uart_configuration::type_id::create("uart_vip_config");
    uart_env = uart_environment::type_id::create("uart_env", this);
    err_catcher = uart_error_catcher::type_id::create("err_catcher");
    uvm_report_cb::add(null, err_catcher);

    //----------------------------------------------------------

    //----------------------------------------------------------
    // uvm-config_db set()
    // Set virtual interface to environment comp
    // No need interrupt interface in environment
    // Send UART VIP config from test to UART VIP agent (drv/mon)
    uvm_config_db #(virtual uart_if)::set(this, "uart_env", "uart_key", uart_vif);
    uvm_config_db #(virtual ahb_if)::set(this, "uart_env", "ahb_key", ahb_vif);
    uvm_config_db #(uart_configuration)::set(this, "uart_env", "uart_vip_key", uart_vip_config);

    //----------------------------------------------------------
    // Set timeout
    uvm_top.set_timeout(usr_timeout);

    `uvm_info({msg, "[build_phase]"}, "Exited...", UVM_FULL)

  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.uart_ip_regmodel = uart_env.uart_ip_regmodel;
  endfunction: connect_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info({msg, "[start_of_simulation_phase]"}, "Entered...", UVM_FULL)
    uvm_top.print_topology();
    `uvm_info({msg, "[start_of_simulation_phase]"}, "Exited...", UVM_FULL)
  endfunction: start_of_simulation_phase

  virtual function void final_phase(uvm_phase phase);

  // Get report server database to track fatal and error
  //uvm_report_server svr;
  super.final_phase(phase);
  `uvm_info({msg, $sformatf("[%s]", get_type_name()), "[final_phase]"}, "Entered...", UVM_HIGH)
  svr_reporter = uvm_report_server::get_server();

  // If global counts of uvm fatal and error detected
  // Then test fails, later can handle error by report catcher
  if (svr_reporter.get_severity_count(UVM_FATAL) + svr_reporter.get_severity_count(UVM_ERROR) > 0) begin
    $display("###################################################################################################");
    $display("###############                         DETECT FATAL OR ERROR                   ###################");
    $display("###############                         STATUS: TEST FAILED                     ###################");
    $display("###################################################################################################");
  end
  else begin
    $display("###################################################################################################");
    $display("##############                          NO FATAL OR ERROR                       ###################");
    $display("##############                          STATUS: TEST PASSED                     ###################");
    $display("###################################################################################################");
  end

  `uvm_info({msg, $sformatf("[%s]", get_type_name()), "[final_phase]"}, "Exited...", UVM_HIGH)

  endfunction: final_phase
  
endclass: uart_base_test
