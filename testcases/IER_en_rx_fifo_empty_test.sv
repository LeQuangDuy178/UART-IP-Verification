class IER_en_rx_fifo_empty_test extends uart_base_test;

  `uvm_component_utils(IER_en_rx_fifo_empty_test)

  uart_simplex_sequence		uart_simplex_seq;

  function new(string name = "IER_en_rx_fifo_empty_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e	status;

    phase.raise_objection(this);

    // Basic transmit test
    // Enable IER en_rx_fifo_empty field

    // UART VIP config
    assert (uart_vip_config.randomize() with
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::NO_PARITY;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 9600;})
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")

    uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_seq");
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
    uart_ip_regmodel.LCR.PEN.set(PEN_NOPARITY);
    uart_ip_regmodel.LCR.BGE.set(BGE_ENBBAUDGEN);
    uart_ip_regmodel.LCR.write(status, uart_ip_regmodel.LCR.get());

    uart_ip_regmodel.IER.en_rx_fifo_empty.set(EN_RX_EMPTY);
    uart_ip_regmodel.IER.write(status, uart_ip_regmodel.IER.get());

    #1000000;
    uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
    
    if (intr_vif.interrupt == 1'b0) begin
      uart_ip_regmodel.FSR.rx_empty_status.read(status, rdata);
      if (rdata == intr_vif.interrupt) begin
        `uvm_info(get_type_name(), "Interrupt matched with polling RX Empty", UVM_NONE)
      end
      else begin
        `uvm_error(get_type_name(), "Interrupt mismatched with polling RX Empty")
      end
    end

    uart_ip_regmodel.RBR.read(status, rdata);
    #1000000;
    
    //uart_ip_regmodel.TBR.tx_data.set(8'h84);
    //uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());

    // Checker with interrupt flag for tx_empty_status polling and intr
    /*@(negedge intr_vif.interrupt == 1'b0);
    uart_ip_regmodel.FSR.tx_empty_status.read(status, rdata);
    if (rdata == intr_vif.interrupt) begin
      `uvm_info(get_type_name(), "Interrupt matched with polling TX Empty", UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), "Interrupt mismatched with polling TX Empty")
    end*/

    //#3000000;

    phase.drop_objection(this);

  endtask: run_phase

endclass: IER_en_rx_fifo_empty_test
