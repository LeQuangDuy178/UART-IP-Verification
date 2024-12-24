class basic_receive_test extends uart_base_test;

  `uvm_component_utils(basic_receive_test)

  ahb_write_sequence	ahb_write_seq;
  uart_simplex_sequence	uart_simplex_seq;

  //bit [31:0] rdata;

  function new(string name = "basic_receive_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    /* Pre-defined sequence uvm_reg_bit_bash_seq */
    uvm_reg_bit_bash_seq reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash");
    //ahb_write_seq = ahb_write_sequence::type_id::create("ahb_write_seq");
    uvm_status_e	status;

    phase.raise_objection(this);

    /* UART VIP config by register 
    * UART IP: Parity config by PEN and EPS 
    * Stop bit config by STB
    * Data width config by WLS
    * Baud rate 9600 and divisor 651 and 16x oversampling -> 104.167us 
    * Start the UART sequence to its driver 
    * Observe the transaction in RBR after complete transaction */
    assert (uart_vip_config.randomize() with 
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::NO_PARITY;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 9600;}) 
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")
   
    uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_seq");
    uart_simplex_seq.uart_config = uart_vip_config;

    //ahb_write_seq = ahb_write_sequence::type_id::create("ahb_write_seq");
    
    //--------------------------------------------------------
    // Register model config
    
    //------------------------------------------------------------
    // Config stages - Frontdoor access
    // write(status, "write data"); read(status, "read data") to config reg
    // set(), get() and get_mirrored_value() adjust regmodel only, ignore DUT
    // get() to get desired value, ge_mirrored_value() return mirrored one
    // Once the desired and mirrored value is different, update() will work
    // update() update DUT via seqr and drv, mon pass to pred updated value
    // update() or write(status, regmodel.reg.get()) will update DUT if diff
    // 1st: Configure Baud generator for IP clock in LCR, MDR, DLL, DLH
    // 2nd: Configure UART frame in LCR
    // 3rd: Configure Interrupt in IER, FSR
    // 4th: Configure Transmit data buffer in TBR
    //------------------------------------------------------------

    // Configure LCR
    //uart_ip_regmodel.LCR.write(status, 8'h23);
    //uart_ip_regmodel.LCR.read(status, rdata);
    //uart_ip_regmodel.LCR.get();
    //uart_ip_regmodel.LCR.get_mirrored_value();
    //uart_ip_regmodel.LCR.BGE.set(1'b1); // Enable baud generator
    //uart_ip_regmodel.LCR.PEN.set(1'b1); // Enable parity in UART frame
    //uart_ip_regmodel.LCR.EPS.set(1'b1); // Enable EVEN parity
    //uart_ip_regmodel.LCR.STB.set(1'b1); // Enable 2 stop bit in UART frame
    //uart_ip_regmodel.LCR.WLS.set(2'b11); // Enable 8-bit UART data frame default
    //uart_ip_regmodel.LCR.read(status, rdata);
    //uart_ip_regmodel.LCR.write(status, uart_ip_regmodel.LCR.get());
     
    // Configure MDR
    uart_ip_regmodel.MDR.write(status, 1'b0);
    //uart_ip_regmodel.MDR.read(status, rdata);
    //uart_ip_regmodel.MDR.get();
    //uart_ip_regmodel.MDR.get_mirrored_value();
    //uart_ip_regmodel.MDR.OSM_SEL.set(1'b1); // Enable 16x oversampling mode
    uart_ip_regmodel.MDR.read(status, rdata);
    //uart_ip_regmodel.MDR.write(status, uart_ip_regmodel.MDR.get());
    
    // Configure DLL
    uart_ip_regmodel.DLL.write(status, 8'h8b);
    //uart_ip_regmodel.DLL.read(status, rdata);
    //uart_ip_regmodel.DLL.get();
    //uart_ip_regmodel.DLL.get_mirrored_value();
    //uart_ip_regmodel.DLL.DLL.set(8'h8b); // Divisor 651: 8-bit LSBs
    uart_ip_regmodel.DLL.read(status, rdata);
    //uart_ip_regmodel.DLL.write(status, uart_ip_regmodel.DLL.get());

    // Configure DLH
    uart_ip_regmodel.DLH.write(status, 8'h02);
    //uart_ip_regmodel.DLH.read(status, rdata);
    //uart_ip_regmodel.DLH.get();
    //uart_ip_regmodel.DLH.get_mirrored_value();
    //uart_ip_regmodel.DLH.DLH.set(8'h02); // Divisor 651: 8-bit MSBs
    uart_ip_regmodel.DLH.read(status, rdata);
    //uart_ip_regmodel.DLH.write(status, uart_ip_regmodel.DLH.get());
    
    // Configure LCR
    uart_ip_regmodel.LCR.write(status, 8'h23);
    uart_ip_regmodel.LCR.read(status, rdata);

    /*
    // Configure IER
    uart_ip_regmodel.IER.write(status, 1'b1);
    uart_ip_regmodel.IER.read(status, rdata);
    uart_ip_regmodel.IER.get();
    uart_ip_regmodel.IER.get_mirrored_value();
    uart_ip_regmodel.IER.en_tx_fifo_full.set(1'b1);
    uart_ip_regmodel.IER.write(status, uart_ip_regmodel.IER.get());

    // Configure FSR
    */
    // Configure TBR
    //uart_ip_regmodel.TBR.write(status, 8'h24);
    //uart_ip_regmodel.TBR.read(status, rdata);
    //uart_ip_regmodel.TBR.get();
    //uart_ip_regmodel.TBR.get_mirrored_value();
    //uart_ip_regmodel.TBR.tx_data.set(8'h24); // Write-only data, cannot read
    //uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());
    
    //--------------------------------------------------------
    
    //uart_ip_regmodel.MDR.update(status);

    /* Start bit bash sequence 
    * Bit bash = write 1 and 0 sequentially to each field of the register
    * 32-bit register = 32 fields total = 64 sequence item sent */
    //reg_bit_bash_seq.model = uart_ip_regmodel;
    //reg_bit_bash_seq.start(null);

    // Wait until UART VIP receive all data
    // wait(uart_env.uart_agt.uart_mon.finish_capture.triggered);
    //#4000000;
    
    //---------------------------------------------------------
    // Start the UART VIP sequence after configure UART IP
    uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);

    // After finish the item transfer, observe via RBR
    // Configure RBR
    uart_ip_regmodel.RBR.read(status, rdata);

    // Checker check data integrity
    if (rdata[7:0] == uart_simplex_seq.req.data[7:0]) begin
      `uvm_info({msg, get_full_name()}, $sformatf("Correct data: 'h%h", rdata), UVM_HIGH)
    end
    else begin
      `uvm_info({msg, get_full_name()}, $sformatf("Wrong data: 'h%h", rdata), UVM_HIGH)
    end

    // Slight delay for scoreboard analysis export UART VIP TX send
    #1000000;

    phase.drop_objection(this);

  endtask: run_phase

endclass: basic_receive_test
