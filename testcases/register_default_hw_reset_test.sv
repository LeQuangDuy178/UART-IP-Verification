class register_default_hw_reset_test extends uart_base_test;

  `uvm_component_utils(register_default_hw_reset_test)

  ahb_write_sequence	ahb_write_seq;

  //bit rdata;

  function new(string name = "register_default_hw_reset_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    /* Pre-defined sequence uvm_reg_hw_reset_seq */
    uvm_reg_hw_reset_seq reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset");
    //ahb_write_seq = ahb_write_sequence::type_id::create("ahb_write_seq");
    uvm_status_e	status;

    phase.raise_objection(this);

    /* UART VIP config by register */
    assert (uart_vip_config.randomize() with 
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::ODD;}) 
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")
    
    ahb_write_seq = ahb_write_sequence::type_id::create("ahb_write_seq");
    
    //--------------------------------------------------------
    // Register model config
    
    //ahb_write_seq.model = uart_ip_regmodel;
    //ahb_write_seq.start(uart_env.ahb_agt.sequencer);
    /*
    uart_ip_regmodel.MDR.write(status, 1'b1);
    uart_ip_regmodel.MDR.read(status, rdata);
    uart_ip_regmodel.MDR.get();
    uart_ip_regmodel.MDR.get_mirrored_value();
    uart_ip_regmodel.MDR.OSM_SEL.set(1'b1);
    uart_ip_regmodel.MDR.write(status, uart_ip_regmodel.MDR.get());
    */
    //--------------------------------------------------------
    
    //uart_ip_regmodel.MDR.update(status);

    reg_hw_reset_seq.model = uart_ip_regmodel;
    reg_hw_reset_seq.start(null);

    phase.drop_objection(this);

  endtask: run_phase

endclass: register_default_hw_reset_test
