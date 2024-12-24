class IER_en_tx_fifo_full_test extends uart_base_test;

  `uvm_component_utils(IER_en_tx_fifo_full_test)

  //`include "../tb/interrupt_if.sv"

  function new(string name = "IER_en_tx_fifo_full_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e	status;

    phase.raise_objection(this);

    // Basic transmit test
    // Enable IER en_tx_fifo_full field
    // 16-byte TX FIFO is full as data in TBR sets 16 times during 1st trans
    uart_env.uart_sco.checker_enb = 0;

    // UART VIP config
    assert (uart_vip_config.randomize() with
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::NO_PARITY;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 9600;})
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")

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

    uart_ip_regmodel.IER.en_tx_fifo_full.set(EN_TX_FULL);
    uart_ip_regmodel.IER.write(status, uart_ip_regmodel.IER.get());

    // Write to TBR 16 times before it finish 1st transmit
    for (int i = 0; i < 20; i++) begin

    //#1000000;
    uart_ip_regmodel.TBR.tx_data.set($urandom());
    uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());

    //#1600000;
    // Checker for interrupt trigger alongside polling
    if (i == 17) begin
      
      if (intr_vif.interrupt == 1'b1) begin
        uart_ip_regmodel.FSR.tx_full_status.read(status, rdata);
        if (rdata == intr_vif.interrupt) begin
          `uvm_info(get_type_name(), "Interrupt is triggered with polling TX Full", UVM_NONE)
        end
        else begin
          `uvm_info(get_type_name(), "Interrupt is not triggered with polling TX Full", UVM_NONE)
        end
      end

    end

    end

    #24000000;

    phase.drop_objection(this);

  endtask: run_phase

endclass: IER_en_tx_fifo_full_test
