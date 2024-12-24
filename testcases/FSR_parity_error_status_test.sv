class FSR_parity_error_status_test extends uart_base_test;

  `uvm_component_utils(FSR_parity_error_status_test)

  uart_simplex_wrong_parity_sequence	uart_simplex_seq;

  function new(string name = "FSR_parity_error_status_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e	status;

    err_catcher.add_error_catcher_msg("Parity error polling flag is not triggered!");

    phase.raise_objection(this);

    // Basic transmit test
    // Enable IER en_parity_error field
    // Config same parity mode for 2 devices for error asserting
    // Create stimulus with wrong parity associated to data and parity mode

    // UART VIP config
    assert (uart_vip_config.randomize() with
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::EVEN;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 9600;})
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")

    uart_simplex_seq = uart_simplex_wrong_parity_sequence::type_id::create("uart_simplex_seq");
    uart_simplex_seq.uart_config = uart_vip_config;

    // UART IP config
    uart_ip_regmodel.MDR.OSM_SEL.set(OSM_SEL_16X);
    uart_ip_regmodel.MDR.write(status, uart_ip_regmodel.MDR.get());

    uart_ip_regmodel.DLL.DLL.set(8'h8b);
    uart_ip_regmodel.DLL.write(status, uart_ip_regmodel.DLL.get());

    uart_ip_regmodel.DLH.DLH.set(8'h02);
    uart_ip_regmodel.DLH.write(status, uart_ip_regmodel.DLH.get());

    uart_ip_regmodel.LCR.WLS.set(WLS_8BITS);
    uart_ip_regmodel.LCR.STB.set(STB_1STOP);
    uart_ip_regmodel.LCR.PEN.set(PEN_ENBPARITY);
    uart_ip_regmodel.LCR.EPS.set(EPS_EVEN);
    uart_ip_regmodel.LCR.BGE.set(BGE_ENBBAUDGEN);
    uart_ip_regmodel.LCR.write(status, uart_ip_regmodel.LCR.get());

    uart_ip_regmodel.IER.en_parity_error.set(EN_PARITY_ERR);
    uart_ip_regmodel.IER.write(status, uart_ip_regmodel.IER.get());

    #1000000;
    //uart_ip_regmodel.TBR.tx_data.set(8'h81);
    //uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());

    uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
    uart_ip_regmodel.RBR.read(status, rdata);

    //@(negedge ahb_vif.HCLK); // Middle half of HCLK cycle
    uart_ip_regmodel.FSR.parity_error_status.read(status, rdata);

    if (rdata == PARITY_IS_ERROR_WRITE_1_TO_CLEAR) begin
      `uvm_info(get_type_name(), "Parity is error, clear the polling parity_error_status flag", UVM_NONE)
      #100000;
      uart_ip_regmodel.FSR.parity_error_status.set(PARITY_IS_ERROR_WRITE_1_TO_CLEAR);
      uart_ip_regmodel.FSR.write(status, uart_ip_regmodel.FSR.get());
      `uvm_info(get_type_name(), $sformatf("Check parity_error_status flag after clear: 'b%b", uart_ip_regmodel.FSR.get()), UVM_NONE)
      uart_ip_regmodel.FSR.parity_error_status.read(status, rdata);
      if (rdata == 1'b0) `uvm_info(get_type_name(), "Parity error status is clear", UVM_NONE)
    end
    else if (rdata == PARITY_NOT_ERROR) begin
      `uvm_error(get_type_name(), "Parity error polling flag is not triggered!")
    end


    #1000000;

    phase.drop_objection(this);

  endtask: run_phase

endclass: FSR_parity_error_status_test
