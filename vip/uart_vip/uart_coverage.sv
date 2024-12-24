uart_configuration	uart_config_cov;
uart_transaction	uart_trans_cov;

covergroup uart_group;

  uart_data: coverpoint uart_trans_cov.data {
    bins data_cov = {[9'h00:9'h1ff]};
  }

  uart_parity: coverpoint uart_trans_cov.parity {
    bins parity_true = {1'h1};
    bins parity_false = {1'h0};
  }

  uart_transfer: coverpoint uart_trans_cov.transfer_type {
    //bins transfer_type_UNKNOWN = {uart_transaction::UNKNOWN}; 
    bins transfer_type_TX = {uart_transaction::TX};
    bins transfer_type_RX = {uart_transaction::RX};
  }

  uart_baud_rate: coverpoint uart_config_cov.baud_rate {
    bins uart_common_baud_rate = {9600, 4800, 19200, 57600, 115200};
    // Maybe use wildcard [*]
    //bins uart_random_baud_rate = {[1:4799], [4801:9599], [9601:19199], [19201:57599], [57601:115199]};
  }

  uart_parity_mode: coverpoint uart_config_cov.parity_mode {
    bins uart_no_parity = {uart_configuration::NO_PARITY};
    bins uart_odd_parity = {uart_configuration::ODD};
    bins uart_even_parity = {uart_configuration::EVEN};
  }

  uart_stop_bit_width: coverpoint uart_config_cov.stop_bit_width {
    bins uart_one_stop_bit = {uart_configuration::ONE_STOP_BIT};
    bins uart_two_stop_bit = {uart_configuration::TWO_STOP_BIT};
  }

  uart_data_width: coverpoint uart_config_cov.data_width {
    bins uart_5_bit_data = {uart_configuration::WIDTH_5};
    bins uart_6_bit_data = {uart_configuration::WIDTH_6};
    bins uart_7_bit_data = {uart_configuration::WIDTH_7};
    bins uart_8_bit_data = {uart_configuration::WIDTH_8};
    bins uart_9_bit_data = {uart_configuration::WIDTH_9};
  }
 
  cross_uart_trans: cross uart_data, uart_parity, uart_transfer;

  // With user-defined crosspoint
  cross_uart_config: cross uart_baud_rate, uart_parity_mode, uart_stop_bit_width, uart_data_width; 

endgroup
