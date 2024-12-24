class uart_frame_baud_rate_19200_test extends uart_base_test;

  `uvm_component_utils(uart_frame_baud_rate_19200_test)

  //bit [31:0] rdata;
  
  // Setting: baud rate 2400 -> 16x/13x -> Full duplex
  bit MDR_OSM_SEL_arr[] = {OSM_SEL_16X, OSM_SEL_13X};
  bit [7:0] DLL_arr[] = {8'h45, 8'h91};
  bit [7:0] DLH_arr[] = {8'h01, 8'h01}; 

  uart_simplex_sequence		uart_simplex_seq;

  // Baud gen properties
  ahb_transaction	ahb_checker;
  bit [7:0] divisor_DLL;
  bit [7:0] divisor_DLH;
  bit [15:0] divisor_total;
  int uart_input_clk_freq = 100; // 100 MHz
  int desired_baud_rate;
  int oversampling_mode;
  real uart_ip_transfer_duration;
  real uart_vip_transfer_duration;
  shortreal bit_duration_tolerance;

  function new(string name = "uart_frame_baud_rate_19200_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e	status;

    phase.raise_objection(this);

    ahb_checker = ahb_transaction::type_id::create("ahb_checker");
    
    for (int i = 0; i < MDR_OSM_SEL_arr.size(); i++) begin
    assert (uart_vip_config.randomize() with 
      {uart_vip_config.data_width == WIDTH_8;
       uart_vip_config.parity_mode == NO_PARITY;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 19200;})
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")

    uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_seq");
    uart_simplex_seq.uart_config = uart_vip_config;

    // Get UART IP transmit duration
    uart_vip_transfer_duration = 64'd1000000000 / uart_vip_config.baud_rate;

    //-------------------------------------------
    // Regmodel config
    // Configure oversampling mode, divisor and baud gen enb
    // Via MDR, DLL, DLH, LCR and TBR

    // write() method
    uart_ip_regmodel.MDR.write(status, MDR_OSM_SEL_arr[i]);
    uart_ip_regmodel.DLL.write(status, DLL_arr[i]);
    uart_ip_regmodel.DLH.write(status, DLH_arr[i]);
    uart_ip_regmodel.LCR.write(status, 8'h23);

    // Full duplex
    fork 
      uart_ip_regmodel.TBR.write(status, 8'hd5); // d5 = 11010101
      uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
    join
    wait (uart_vif.state_tx == uart_monitor::IDLE);
    uart_ip_regmodel.RBR.read(status, rdata);

    // set(), get() and get_mirrored_value() handshake
    

    //-------------------------------------------
    // Checker: check bit duration based on bclk signal
    // 16x/13x -> 1 bit duration in UART frame requires 16/13 bclk posedge

    // 1st: Get the bit duration via divisor, oversampling and baud rate
    // Get oversampling mode
    uart_ip_regmodel.MDR.read(status, rdata);
    ahb_checker.data = rdata;
    //uart_ip_regmodel.MDR.OSM_SEL.get();
    if (ahb_checker.data == 1'b0) begin
      oversampling_mode = 16;
    end 
    else if (ahb_checker.data == 1'b1) begin
      oversampling_mode = 13;
    end
    `uvm_info(get_type_name(), $sformatf("Check oversampling: %0dx", oversampling_mode), UVM_LOW)

    // Get divisor value
    uart_ip_regmodel.DLL.read(status, rdata);
    ahb_checker.data = rdata;
    divisor_DLL = ahb_checker.data;
    uart_ip_regmodel.DLH.read(status, rdata);
    ahb_checker.data = rdata;
    divisor_DLH = ahb_checker.data;
    divisor_total = {divisor_DLH, divisor_DLL}; // Concatenate: {MSBs, LSBs}
    `uvm_info(get_type_name(), $sformatf("Check divisor: %0d", divisor_total), UVM_LOW)

    // Get desired baud rate and calculatio of transfer time for UART IP
    desired_baud_rate = ((uart_input_clk_freq * 1000000 / divisor_total) / oversampling_mode);
    `uvm_info(get_type_name(), $sformatf("Check desired baud rate of UART IP: %0d", desired_baud_rate), UVM_LOW)
    uart_ip_transfer_duration = 64'd1000000000 / desired_baud_rate;

    // Set the offset tolerance accepetable with baud rate difference
    bit_duration_tolerance = 31;

    // Bit duration compatibility check between UART IP and UART VIP 
    if ((desired_baud_rate - uart_vip_config.baud_rate) < bit_duration_tolerance) begin
      `uvm_info(get_type_name(), $sformatf("Matched baud rate in tolerance range: %0d", desired_baud_rate), UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), $sformatf("Unmatched baud rate, should be: %0d", uart_vip_config.baud_rate))
    end
    
    //------------------------------------------
    #2400000;
    end

    phase.drop_objection(this);

  endtask: run_phase

endclass: uart_frame_baud_rate_19200_test
