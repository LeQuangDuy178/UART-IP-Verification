class register_reserved_address_test extends uart_base_test;

  `uvm_component_utils(register_reserved_address_test)

  ahb_write_rsvd_sequence	ahb_write_seq;
  ahb_read_rsvd_sequence	ahb_read_seq;

 // bit [31:0] rdata;

  function new(string name = "register_reserved_address_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    /* Pre-defined sequence uvm_reg_bit_bash_seq */
    //uvm_reg_bit_bash_seq reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash");
    //ahb_write_seq = ahb_write_rsvd_sequence::type_id::create("ahb_write_seq");
    //uvm_status_e	status;

    phase.raise_objection(this);

    /* UART VIP config by register */
    assert (uart_vip_config.randomize() with 
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::NO_PARITY;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 9600;}) 
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")
    
    /* Write AHB sequence to reserved region address 
    * Write should not affect, and read should return 32'hffff_ffff */
    ahb_write_seq = ahb_write_rsvd_sequence::type_id::create("ahb_write_seq");
    ahb_read_seq = ahb_read_rsvd_sequence::type_id::create("ahb_read_seq");

    ahb_write_seq.start(uart_env.ahb_agt.sequencer);
  
    // Check the HRESP trigger for write sequence
    // If at HRESP, wdata = wdata of sequence then write is not affected

    if (ahb_vif.HRESP == 1'b1) begin
    `uvm_info(get_type_name(), "Write to reserved address where HRESP is triggered", UVM_NONE)
    if (ahb_vif.HWDATA == ahb_write_seq.req.data) begin
      `uvm_info(get_type_name(), $sformatf("Write not affect to this addr: 'h%h", ahb_vif.HWDATA), UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), "Write is affected, Error")
    end
    end

    ahb_read_seq.start(uart_env.ahb_agt.sequencer);

    if (ahb_vif.HRESP == 1'b1) begin
    `uvm_info(get_type_name(), "Read from reserved address where HRESP is triggered", UVM_NONE)
    if (ahb_vif.HRDATA == 32'hffffffff) begin
      `uvm_info(get_type_name(), $sformatf("Read this addr as: 'h%h", ahb_vif.HRDATA), UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), "Not read as ffff_ffff, Error");
    end
    end

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

    /* Start bit bash sequence 
    * Bit bash = write 1 and 0 sequentially to each field of the register
    * 32-bit register = 32 fields total = 64 sequence item sent */
    //reg_bit_bash_seq.model = uart_ip_regmodel;
    //reg_bit_bash_seq.start(null);

    phase.drop_objection(this);

  endtask: run_phase

endclass: register_reserved_address_test
