package test_pkg;

  import uvm_pkg::*;
  import uart_pkg::*;
  import ahb_pkg::*;
  import seq_pkg::*;
  import env_pkg::*;
  import uart_regmodel_pkg::*;

  // Base test
  `include "uart_error_catcher.sv"
  `include "uart_base_test.sv"
  
  // Register test
  `include "register_default_hw_reset_test.sv"
  `include "register_default_bit_bash_test.sv"
  `include "register_reset_on_fly_test.sv"
  `include "register_reserved_address_test.sv"
  
  // Function test
  // Basic transfer test
  `include "basic_transmit_test.sv"
  `include "basic_receive_test.sv"
  
  // MDR register test
  `include "MDR_oversampling_16x_transmit_test.sv"
  `include "MDR_oversampling_16x_receive_test.sv"
  `include "MDR_oversampling_13x_transmit_test.sv"
  `include "MDR_oversampling_13x_receive_test.sv"
  `include "MDR_oversampling_change_mode_OTF_transmit_test.sv"
  `include "MDR_oversampling_change_mode_OTF_receive_test.sv"
  `include "MDR_oversampling_no_baud_gen_transmit_test.sv"
  `include "MDR_oversampling_no_baud_gen_receive_test.sv"

  // UART frame test - transmit only
  `include "uart_frame_WLS_noparity_1stop_transmit_only_test.sv"
  `include "uart_frame_WLS_oddparity_1stop_transmit_only_test.sv"
  `include "uart_frame_WLS_evenparity_1stop_transmit_only_test.sv"
  `include "uart_frame_WLS_noparity_2stop_transmit_only_test.sv"
  `include "uart_frame_WLS_oddparity_2stop_transmit_only_test.sv"
  `include "uart_frame_WLS_evenparity_2stop_transmit_only_test.sv"
  `include "uart_frame_change_mode_OTF_transmit_only_test.sv"

  // UART frame test - receive only
  `include "uart_frame_WLS_noparity_1stop_receive_only_test.sv"
  `include "uart_frame_WLS_oddparity_1stop_receive_only_test.sv"
  `include "uart_frame_WLS_evenparity_1stop_receive_only_test.sv"
  `include "uart_frame_WLS_noparity_2stop_receive_only_test.sv"
  `include "uart_frame_WLS_oddparity_2stop_receive_only_test.sv"
  `include "uart_frame_WLS_evenparity_2stop_receive_only_test.sv"
  `include "uart_frame_change_mode_OTF_receive_only_test.sv"

  // UART frame test - half duplex - IP to VIP
  `include "uart_frame_WLS_noparity_1stop_half_duplex_IP_first_test.sv"
  `include "uart_frame_WLS_oddparity_1stop_half_duplex_IP_first_test.sv"
  `include "uart_frame_WLS_evenparity_1stop_half_duplex_IP_first_test.sv"
  `include "uart_frame_WLS_noparity_2stop_half_duplex_IP_first_test.sv"
  `include "uart_frame_WLS_oddparity_2stop_half_duplex_IP_first_test.sv"
  `include "uart_frame_WLS_evenparity_2stop_half_duplex_IP_first_test.sv"
  `include "uart_frame_change_mode_middle_half_duplex_IP_first_test.sv"

  // UART frame test - half duplex - VIP to IP
  `include "uart_frame_WLS_noparity_1stop_half_duplex_VIP_first_test.sv"
  `include "uart_frame_WLS_oddparity_1stop_half_duplex_VIP_first_test.sv"
  `include "uart_frame_WLS_evenparity_1stop_half_duplex_VIP_first_test.sv"
  `include "uart_frame_WLS_noparity_2stop_half_duplex_VIP_first_test.sv"
  `include "uart_frame_WLS_oddparity_2stop_half_duplex_VIP_first_test.sv"
  `include "uart_frame_WLS_evenparity_2stop_half_duplex_VIP_first_test.sv"
  `include "uart_frame_change_mode_middle_half_duplex_VIP_first_test.sv"

  // UART frame test - full duplex
  `include "uart_frame_WLS_noparity_1stop_full_duplex_test.sv"
  `include "uart_frame_WLS_oddparity_1stop_full_duplex_test.sv"
  `include "uart_frame_WLS_evenparity_1stop_full_duplex_test.sv"
  `include "uart_frame_WLS_noparity_2stop_full_duplex_test.sv"
  `include "uart_frame_WLS_oddparity_2stop_full_duplex_test.sv"
  `include "uart_frame_WLS_evenparity_2stop_full_duplex_test.sv"
  `include "uart_frame_change_mode_middle_and_OTF_full_duplex_test.sv"

  // Interrupt test - IER interrupt
  `include "IER_en_tx_fifo_full_test.sv"
  `include "IER_en_tx_fifo_empty_test.sv"
  `include "IER_en_rx_fifo_full_test.sv"
  `include "IER_en_rx_fifo_empty_test.sv"
  `include "IER_en_parity_error_test.sv"

  // Polling status test - FSR status
  `include "FSR_tx_full_status_test.sv"
  `include "FSR_tx_empty_status_test.sv"
  `include "FSR_rx_full_status_test.sv"
  `include "FSR_rx_empty_status_test.sv"
  `include "FSR_parity_error_status_test.sv"

  // UART frame - baud rate test - in 2 MDR mode - in full duplex mode
  `include "uart_frame_baud_rate_2400_test.sv"
  `include "uart_frame_baud_rate_4800_test.sv"
  `include "uart_frame_baud_rate_9600_test.sv"
  `include "uart_frame_baud_rate_19200_test.sv"
  `include "uart_frame_baud_rate_38400_test.sv"
  `include "uart_frame_baud_rate_76800_test.sv"
  `include "uart_frame_baud_rate_115200_test.sv"
  `include "uart_frame_change_baud_rate_OTF_same_MDR_transmit_test.sv"
  `include "uart_frame_change_baud_rate_OTF_diff_MDR_transmit_test.sv"
  `include "uart_frame_change_baud_rate_OTF_same_MDR_receive_test.sv"
  `include "uart_frame_change_baud_rate_OTF_diff_MDR_receive_test.sv"

  // FIFO test
  `include "TX_FIFO_16_byte_size_test.sv"
  `include "RX_FIFO_16_byte_size_test.sv"
  `include "TX_RX_FIFO_full_full_duplex_test.sv"
  `include "TX_RX_FIFO_empty_full_duplex_test.sv"
  `include "TX_FIFO_overflow_test.sv"
  `include "RX_FIFO_underflow_test.sv"

  // Error cases test
  //`include "error_HRESP_test.sv"
  //`include "error_TX_FIFO_overflow_test.sv"
  //`include "error_RX_FIFO_underflow_test.sv"
  //`include "error_PARITY_test.sv"

endpackage
