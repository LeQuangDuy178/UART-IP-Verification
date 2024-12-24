class register_reset_on_fly_test extends uart_base_test;

  `uvm_component_utils(register_reset_on_fly_test)

  //bit [31:0] rdata;

  function new(string name = "register_reset_on_fly_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_reg_bit_bash_seq reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
    uvm_reg_hw_reset_seq reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset_seq");
    uvm_status_e	status;

    phase.raise_objection(this);

    assert (uart_vip_config.randomize() with 
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::NO_PARITY;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 9600;})
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")

    reg_bit_bash_seq.model = uart_ip_regmodel;
    reg_bit_bash_seq.start(null);

    ahb_vif.HRESETn = 1'b0;
    #10000;
    ahb_vif.HRESETn = 1'b1;

    reg_hw_reset_seq.model = uart_ip_regmodel;
    reg_hw_reset_seq.start(null);

    phase.drop_objection(this);

  endtask: run_phase

endclass: register_reset_on_fly_test
