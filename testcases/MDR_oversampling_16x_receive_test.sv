class MDR_oversampling_16x_receive_test extends uart_base_test;

  `uvm_component_utils(MDR_oversampling_16x_receive_test)

  uart_simplex_sequence		uart_simplex_seq;

  // Baud gen properties
  ahb_transaction       ahb_checker;
  bit [7:0] divisor_DLL;
  bit [7:0] divisor_DLH;
  bit [15:0] divisor_total;
  int uart_input_clk_freq = 100; // 100 MHz
  int desired_baud_rate;
  int oversampling_mode;
  real uart_ip_transfer_duration;
  real uart_vip_transfer_duration;
  shortreal bit_duration_tolerance;

  function new(string name = "MDR_oversampling_16x_receive_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e	status;

    phase.raise_objection(this);

    ahb_checker	= ahb_transaction::type_id::create("ahb_checker");

    assert (uart_vip_config.randomize() with
      {uart_vip_config.data_width == uart_configuration::WIDTH_8;
       uart_vip_config.parity_mode == uart_configuration::NO_PARITY;
       uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
       uart_vip_config.baud_rate == 9600;})
    else `uvm_error({msg, get_type_name()}, "Randomization Error!")

    uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_seq");
    uart_simplex_seq.uart_config = uart_vip_config;

    //----------------------------------------------------------
    // Regmodel config

    // write() method
    uart_ip_regmodel.MDR.write(status, OSM_SEL_16X);
    uart_ip_regmodel.DLL.write(status, 8'h8b);
    uart_ip_regmodel.DLH.write(status, 8'h02);
    uart_ip_regmodel.LCR.write(status, 8'h23);
  

    //----------------------------------------------------------
    // Start sequence in UART VIP
    uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);

    // Observe item in RBR after finish transfer
    uart_ip_regmodel.RBR.read(status, rdata);

    // Checker checkd data integrity
    if (rdata[7:0] == uart_simplex_seq.req.data[7:0]) begin
      `uvm_info(get_type_name(), $sformatf("Correct data: 'h%h", rdata), UVM_HIGH)
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("Wrong data: 'h%h", rdata), UVM_HIGH)
    end

    //-------------------------------------------------------------
    // Checker
    uart_ip_regmodel.MDR.read(status, rdata);
    ahb_checker.data = rdata;
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
    bit_duration_tolerance = 10;

    // Bit duration compatibility check between UART IP and UART VIP 
    if ((desired_baud_rate - uart_vip_config.baud_rate) < bit_duration_tolerance) begin
      `uvm_info(get_type_name(), $sformatf("Matched baud rate in tolerance range: %0d", desired_baud_rate), UVM_NONE)
    end
    else begin
      `uvm_error(get_type_name(), $sformatf("Unmatched baud rate, should be: %0d", uart_vip_config.baud_rate))
    end
  
    // Slight delay
    #1000000;

    phase.drop_objection(this);

  endtask: run_phase

endclass: MDR_oversampling_16x_receive_test
