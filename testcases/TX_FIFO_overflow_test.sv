class TX_FIFO_overflow_test extends uart_base_test;

  `uvm_component_utils(TX_FIFO_overflow_test)

  //`include "../tb/interrupt_if.sv"

  int tx_fifo_size;
  uart_transaction uart_data;

  function new(string name = "TX_FIFO_overflow_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e	status;

    phase.raise_objection(this);

    // Basic transmit test
    // Enable IER en_tx_fifo_full field
    // 16-byte TX FIFO is full as data in TBR sets 16 times during 1st trans
    uart_env.uart_sco.checker_enb = 0;

    uart_data = uart_transaction::type_id::create("uart_data");
    
    // Disable parity constraint
    //uart_data.parity_constraint.constraint_mode(0);

    //assert(uart_data.randomize()) else `uvm_error(get_type_name(), "Randomization failed!")

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
    for (int i = 0; i < 18; i++) begin

    //#1000000;

    uart_data.parity_constraint.constraint_mode(0);    
    assert(uart_data.randomize()) else `uvm_error(get_type_name(), "Randomization failed!")

    uart_ip_regmodel.TBR.tx_data.set(uart_data.data);
    uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());

    //#1600000;
    // Checker for interrupt trigger alongside polling
    //if (i == 17) begin
      
      if (intr_vif.interrupt == 1'b1) begin
        uart_ip_regmodel.FSR.tx_full_status.read(status, rdata);
        if (rdata == intr_vif.interrupt) begin
          `uvm_info(get_type_name(), "Interrupt is triggered with polling TX Full", UVM_NONE)
        end
        else begin
          `uvm_info(get_type_name(), "Interrupt is not triggered with polling TX Full", UVM_NONE)
        end

        // Get size of 16-byte FIFO when interrupt trigger
	tx_fifo_size = i - 1;
	`uvm_info(get_type_name(), $sformatf("TX FIFO is full at %0d-byte boundary", tx_fifo_size), UVM_NONE)

      end
      else begin
        `uvm_info(get_type_name(), "TX FIFO is not full, data is accessible!", UVM_NONE)
      end

    //end

    end

    // Write data to TX FIFO to check if the FIFO is overflow or not
    uart_ip_regmodel.TBR.tx_data.set(8'h24);
    uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());
    if (intr_vif.interrupt == 1'b1) begin
      `uvm_info(get_type_name(), "TX FIFO is overflow, cannot get new data!", UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), "TX FIFO is not overflow")
    end

    #24000000;

    // Checker check if there is 8'h24 being transmitted in the UART frame
    

    phase.drop_objection(this);

  endtask: run_phase

endclass: TX_FIFO_overflow_test
