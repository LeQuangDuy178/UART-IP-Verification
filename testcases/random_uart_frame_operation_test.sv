class random_uart_frame_operation_test extends uart_base_test;

  `uvm_component_utils(random_uart_frame_operation_test)

  uart_rand_operation		uart_rand_oper;
  uart_configuration		uart_vip_config_ref;
  uart_simplex_sequence		uart_simplex_seq;

  function new(string name = "random_uart_frame_operation_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  // Get baud clock for VIP config and delay 
  bit [7:0] divisor_DLL;
  bit [7:0] divisor_DLH;
  bit [15:0] divisor_total;
  int uart_input_clk_freq = 100; // 100 MHz
  int desired_baud_rate;
  int oversampling_mode;
  real uart_ip_transfer_time;
  real uart_ip_read_time;
  shortreal bit_duration_tolerance;

  int operation_nums = 5;

  virtual task run_phase(uvm_phase phase);

    uvm_status_e	status;

    phase.raise_objection(this);

    //uart_env.uart_sco.trans_disp_enb = 0;
    uart_env.uart_sco.parity_checker_enb = 1;

    for (int i = 0; i < operation_nums; i++) begin

    `uvm_info(get_type_name(), $sformatf("Operation number: %0d", i + 1), UVM_NONE)

    uart_env.uart_sco.single_trans_enb = 0;
    uart_env.uart_sco.full_duplex_trans_enb = 1;
    
    uart_rand_oper = uart_rand_operation::type_id::create("uart_rand_oper");
    uart_vip_config_ref = uart_configuration::type_id::create("uart_vip_config_ref");
    uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_sequence");

    assert(uart_rand_oper.randomize()
      //with {uart_rand_oper.trans_oper == IP_FULL_DUPLEX
      //with {uart_rand_oper.LCR_WLS_config == WLS_5BITS;}
    ) else `uvm_error(get_type_name(), "Randomization Error!")

    `uvm_info(get_type_name(), $sformatf("Get randomized UART operation instructions: \n%s", uart_rand_oper.sprint()), UVM_NONE)
    
    //get_transmit_transfer_time(uart_rand_oper, desired_baud_rate, oversampling_mode, uart_ip_transfer_time);

    //--------------------------------------------------------------
    // Analyze baud clock
    divisor_DLL = uart_rand_oper.DLL_DLL_config;
    divisor_DLH = uart_rand_oper.DLH_DLH_config;
    divisor_total = {divisor_DLH, divisor_DLL};
    oversampling_mode = (uart_rand_oper.MDR_OSM_SEL_config == OSM_SEL_16X) ? 16 : 13;
    desired_baud_rate = ((uart_input_clk_freq * 1000000 / divisor_total) / oversampling_mode);
    uart_ip_transfer_time = 12 * (64'd1000000000 / desired_baud_rate);
    uart_ip_read_time = 3 * (64'd1000000000 / desired_baud_rate);
    `uvm_info(get_type_name(), $sformatf("Get transmit time: %0f", uart_ip_transfer_time), UVM_NONE)
    //---------------------------------------------------------------
    // Analyze UART mode for VIP
    // Baud rate
    uart_vip_config_ref.baud_rate = desired_baud_rate;
    // Parity mode
    if (uart_rand_oper.LCR_PEN_config == PEN_NOPARITY) begin
      uart_vip_config_ref.parity_mode = uart_configuration::NO_PARITY;
    end
    else if (uart_rand_oper.LCR_PEN_config == PEN_ENBPARITY && uart_rand_oper.LCR_EPS_config == EPS_ODD) begin
      uart_vip_config_ref.parity_mode = uart_configuration::ODD;
    end
    else if (uart_rand_oper.LCR_PEN_config == PEN_ENBPARITY && uart_rand_oper.LCR_EPS_config == EPS_EVEN) begin
      uart_vip_config_ref.parity_mode = uart_configuration::EVEN;
    end
    // Stop bit
    uart_vip_config_ref.stop_bit_width = (uart_rand_oper.LCR_STB_config == STB_1STOP) ? uart_configuration::ONE_STOP_BIT : uart_configuration::TWO_STOP_BIT;
    // Data width
    if (uart_rand_oper.LCR_WLS_config == WLS_5BITS) begin
       uart_vip_config_ref.data_width = uart_configuration::WIDTH_5;
    end
    else if (uart_rand_oper.LCR_WLS_config == WLS_6BITS) begin
       uart_vip_config_ref.data_width = uart_configuration::WIDTH_6;
    end
    else if (uart_rand_oper.LCR_WLS_config == WLS_7BITS) begin
       uart_vip_config_ref.data_width = uart_configuration::WIDTH_7;
    end
    else begin
      uart_vip_config_ref.data_width = uart_configuration::WIDTH_8;
    end
    //-----------------------------------------------------------------
    //wait (uart_vif.state_tx == uart_monitor::IDLE || uart_vif.state_rx == uart_monitor::IDLE);
    //uart_env.uart_sco.single_trans_enb = 1;
    //uart_env.uart_sco.full_duplex_trans_enb = 0;
    wait (uart_vif.state_tx == uart_monitor::IDLE || uart_vif.state_rx == uart_monitor::IDLE);

    if (uart_rand_oper.trans_oper == uart_rand_operation::IP_TRANSMIT) begin
      `uvm_info(get_type_name(), "IP_TRANSMIT operation start", UVM_NONE)
      uart_transmit_operation(status, uart_rand_oper);
      //#uart_ip_transfer_time; // Delay by baud clock generated (12x of 1-bit duration)
    end

    if (uart_rand_oper.trans_oper == uart_rand_operation::IP_RECEIVE) begin
      `uvm_info(get_type_name(), "IP_RECEIVE operation start", UVM_NONE)
      uart_receive_operation(status, uart_rand_oper);
      //#uart_ip_read_time;
    end

    if (uart_rand_oper.trans_oper == uart_rand_operation::IP_FIRST_HALF_DUPLEX) begin
      `uvm_info(get_type_name(), "IP_FIRST_HALF_DUPLEX operation start", UVM_NONE)
      uart_half_duplex_IP_first_operation(status, uart_rand_oper);
    end

    if (uart_rand_oper.trans_oper == uart_rand_operation::IP_SECOND_HALF_DUPLEX) begin
      `uvm_info(get_type_name(), "IP_SECOND_HALF_DUPLEX operation start", UVM_NONE)
      uart_half_duplex_IP_second_operation(status, uart_rand_oper);
    end

    if (uart_rand_oper.trans_oper == uart_rand_operation::IP_FULL_DUPLEX) begin
      `uvm_info(get_type_name(), "IP_FULL_DUPLEX operation start", UVM_NONE)
      uart_env.uart_sco.single_trans_enb = 0;
      uart_env.uart_sco.full_duplex_trans_enb = 1;
      uart_full_duplex_operation(status, uart_rand_oper);
    end

    #uart_ip_read_time;

    end

    #uart_ip_read_time;

    phase.drop_objection(this);

  endtask: run_phase

  //extern virtual function void get_transmit_transfer_time(uart_rand_oper, desired_baud_rate, oversampling_mode, uart_ip_transfer_time);
  extern virtual task uart_transmit_operation(status, uart_rand_operation uart_rand_oper);
  extern virtual task uart_receive_operation(status, uart_rand_operation uart_rand_oper);
  extern virtual task uart_half_duplex_IP_first_operation(status, uart_rand_operation uart_rand_oper);
  extern virtual task uart_half_duplex_IP_second_operation(status, uart_rand_operation uart_rand_oper);
  extern virtual task uart_full_duplex_operation(status, uart_rand_operation uart_rand_oper);

endclass: random_uart_frame_operation_test
/*
function void random_uart_frame_operation_test::get_transmit_transfer_time(uart_rand_oper, desired_baud_rate, oversampling_mode, uart_ip_transfer_time);
  
  //bit [7:0] divisor_DLL;
  divisor_DLL = uart_rand_oper.DLL_DLL_config;
  //bit [7:0] divisor_DLH;
  divisor_DLH = uart_rand_oper.DLH_DLH_config;
  //bit [15:0] divisor_total;
  divisor_total = {divisor_DLH, divisor_DLL};
  oversampling_mode = (uart_rand_oper.MDR_OSM_SEL_config == OSM_SEL_16X) ? 16 : 13;
  desired_baud_rate = ((uart_input_clk_freq * 1000000 / divisor_total) / oversampling_mode);   
  uart_ip_transfer_time = 12 * (64'd1000000000 / desired_baud_rate);
  `uvm_info(get_type_name(), $sformatf("Get transmit time: %0f", desired_baud_rate), UVM_NONE)

endfunction: get_transmit_transfer_time
*/
task random_uart_frame_operation_test::uart_transmit_operation(status, uart_rand_operation uart_rand_oper);

  // VIP config
  uart_vip_config.baud_rate_constraint.constraint_mode(0); // Disable common baud rate constraint
  assert (uart_vip_config.randomize() with {
    uart_vip_config.baud_rate == uart_vip_config_ref.baud_rate;
    uart_vip_config.data_width == uart_vip_config_ref.data_width;
    uart_vip_config.stop_bit_width == uart_vip_config_ref.stop_bit_width;
    uart_vip_config.parity_mode == uart_vip_config_ref.parity_mode;
  }) else `uvm_error(get_type_name(), "Randomization uart vip configuration failed!")
  
  // IP config
  uart_ip_regmodel.MDR.write(status, uart_rand_oper.MDR_OSM_SEL_config);
  uart_ip_regmodel.DLL.write(status, uart_rand_oper.DLL_DLL_config);
  uart_ip_regmodel.DLH.write(status, uart_rand_oper.DLH_DLH_config);
  uart_ip_regmodel.LCR.write(status, {uart_rand_oper.LCR_BGE_config, uart_rand_oper.LCR_EPS_config, uart_rand_oper.LCR_PEN_config, uart_rand_oper.LCR_STB_config, uart_rand_oper.LCR_WLS_config});
  uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);

  #uart_ip_transfer_time;

endtask: uart_transmit_operation

task random_uart_frame_operation_test::uart_receive_operation(status, uart_rand_operation uart_rand_oper);

  // VIP config
  uart_vip_config.baud_rate_constraint.constraint_mode(0); // Disable common baud rate constraint
  assert (uart_vip_config.randomize() with {
    uart_vip_config.baud_rate == uart_vip_config_ref.baud_rate;
    uart_vip_config.data_width == uart_vip_config_ref.data_width;
    uart_vip_config.stop_bit_width == uart_vip_config_ref.stop_bit_width;
    uart_vip_config.parity_mode == uart_vip_config_ref.parity_mode;
  }) else `uvm_error(get_type_name(), "Randomization uart vip configuration failed!")

  // IP config
  uart_ip_regmodel.MDR.write(status, uart_rand_oper.MDR_OSM_SEL_config);
  uart_ip_regmodel.DLL.write(status, uart_rand_oper.DLL_DLL_config);
  uart_ip_regmodel.DLH.write(status, uart_rand_oper.DLH_DLH_config);
  uart_ip_regmodel.LCR.write(status, {uart_rand_oper.LCR_BGE_config, uart_rand_oper.LCR_EPS_config, uart_rand_oper.LCR_PEN_config, uart_rand_oper.LCR_STB_config, uart_rand_oper
.LCR_WLS_config});
  //uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);

  uart_simplex_seq.uart_config = uart_vip_config;
  uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
  uart_ip_regmodel.RBR.read(status, uart_rand_oper.RBR_rx_data_config);

  #uart_ip_read_time;

endtask: uart_receive_operation

task random_uart_frame_operation_test::uart_half_duplex_IP_first_operation(status, uart_rand_operation uart_rand_oper);

  // VIP config
  uart_vip_config.baud_rate_constraint.constraint_mode(0); // Disable common baud rate constraint
  assert (uart_vip_config.randomize() with {
    uart_vip_config.baud_rate == uart_vip_config_ref.baud_rate;
    uart_vip_config.data_width == uart_vip_config_ref.data_width;
    uart_vip_config.stop_bit_width == uart_vip_config_ref.stop_bit_width;
    uart_vip_config.parity_mode == uart_vip_config_ref.parity_mode;
  }) else `uvm_error(get_type_name(), "Randomization uart vip configuration failed!")
  uart_simplex_seq.uart_config = uart_vip_config;

  // IP config
  uart_ip_regmodel.MDR.write(status, uart_rand_oper.MDR_OSM_SEL_config);
  uart_ip_regmodel.DLL.write(status, uart_rand_oper.DLL_DLL_config);
  uart_ip_regmodel.DLH.write(status, uart_rand_oper.DLH_DLH_config);
  uart_ip_regmodel.LCR.write(status, {uart_rand_oper.LCR_BGE_config, uart_rand_oper.LCR_EPS_config, uart_rand_oper.LCR_PEN_config, uart_rand_oper.LCR_STB_config, uart_rand_oper
.LCR_WLS_config});
  //uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);

  uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);
  #uart_ip_transfer_time;

  //uart_simplex_seq.uart_config = uart_vip_config;
  uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
  uart_ip_regmodel.RBR.read(status, uart_rand_oper.RBR_rx_data_config);
  #uart_ip_read_time;

endtask: uart_half_duplex_IP_first_operation

task random_uart_frame_operation_test::uart_half_duplex_IP_second_operation(status, uart_rand_operation uart_rand_oper);

  // VIP config
  uart_vip_config.baud_rate_constraint.constraint_mode(0); // Disable common baud rate constraint
  assert (uart_vip_config.randomize() with {
    uart_vip_config.baud_rate == uart_vip_config_ref.baud_rate;
    uart_vip_config.data_width == uart_vip_config_ref.data_width;
    uart_vip_config.stop_bit_width == uart_vip_config_ref.stop_bit_width;
    uart_vip_config.parity_mode == uart_vip_config_ref.parity_mode;
  }) else `uvm_error(get_type_name(), "Randomization uart vip configuration failed!")

  // IP config
  uart_ip_regmodel.MDR.write(status, uart_rand_oper.MDR_OSM_SEL_config);
  uart_ip_regmodel.DLL.write(status, uart_rand_oper.DLL_DLL_config);
  uart_ip_regmodel.DLH.write(status, uart_rand_oper.DLH_DLH_config);
  uart_ip_regmodel.LCR.write(status, {uart_rand_oper.LCR_BGE_config, uart_rand_oper.LCR_EPS_config, uart_rand_oper.LCR_PEN_config, uart_rand_oper.LCR_STB_config, uart_rand_oper
.LCR_WLS_config});
  //uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);

  //uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);
  //#uart_ip_transfer_time;

  uart_simplex_seq.uart_config = uart_vip_config;
  uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
  uart_ip_regmodel.RBR.read(status, uart_rand_oper.RBR_rx_data_config);
  #uart_ip_read_time;

  uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);
  #uart_ip_transfer_time;

endtask: uart_half_duplex_IP_second_operation

task random_uart_frame_operation_test::uart_full_duplex_operation(status, uart_rand_operation uart_rand_oper);

  // VIP config
  uart_vip_config.baud_rate_constraint.constraint_mode(0); // Disable common baud rate constraint
  assert (uart_vip_config.randomize() with {
    uart_vip_config.baud_rate == uart_vip_config_ref.baud_rate;
    uart_vip_config.data_width == uart_vip_config_ref.data_width;
    uart_vip_config.stop_bit_width == uart_vip_config_ref.stop_bit_width;
    uart_vip_config.parity_mode == uart_vip_config_ref.parity_mode;
  }) else `uvm_error(get_type_name(), "Randomization uart vip configuration failed!")
  uart_simplex_seq.uart_config = uart_vip_config; 
  // uart transaction need to have config first before transfer, put in fork-join -> error in order

  // IP config
  uart_ip_regmodel.MDR.write(status, uart_rand_oper.MDR_OSM_SEL_config);
  uart_ip_regmodel.DLL.write(status, uart_rand_oper.DLL_DLL_config);
  uart_ip_regmodel.DLH.write(status, uart_rand_oper.DLH_DLH_config);
  uart_ip_regmodel.LCR.write(status, {uart_rand_oper.LCR_BGE_config, uart_rand_oper.LCR_EPS_config, uart_rand_oper.LCR_PEN_config, uart_rand_oper.LCR_STB_config, uart_rand_oper
.LCR_WLS_config});
  //uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);

  //uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);
  //#uart_ip_transfer_time;

  // Can full duplex have different configs between 2 pins txd and rxd?

  fork
  //uart_simplex_seq.uart_config = uart_vip_config;
  uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
  //uart_ip_regmodel.RBR.read(status, uart_rand_oper.RBR_rx_data_config);
  //#uart_ip_read_time;

  uart_ip_regmodel.TBR.write(status, uart_rand_oper.TBR_tx_data_config);
  //#uart_ip_transfer_time;
  join
  uart_ip_regmodel.RBR.read(status, uart_rand_oper.RBR_rx_data_config);
  #uart_ip_read_time;

endtask: uart_full_duplex_operation

