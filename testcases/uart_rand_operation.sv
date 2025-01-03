class uart_rand_operation extends uvm_sequence_item;

  //`uvm_object_utils(uart_rand_operation);

  function new (string name = "uart_rand_operation");
    super.new(name);
  endfunction: new

  //----------------------------------------------------
  // Rand transfer opeartion
  typedef enum bit[2:0] {
    IP_TRANSMIT = 3'b000,
    IP_RECEIVE = 3'b001,
    IP_FIRST_HALF_DUPLEX = 3'b010,
    IP_SECOND_HALF_DUPLEX = 3'b011,
    IP_FULL_DUPLEX = 3'b100,
    IP_NO_TRANSFER = 3'b101
  } transfer_operation_enum;
  rand transfer_operation_enum trans_oper;

  //----------------------------------------------------
  // Rand register fields
  `include "../regmodel/register/uart_reg_field_define.sv" 
  rand reg_base_offset_enum		reg_addr;
  rand MDR_OSM_SEL_enum			MDR_OSM_SEL_config;
  rand bit [7:0]			DLL_DLL_config;
  rand bit [7:0]			DLH_DLH_config;
  rand LCR_WLS_enum			LCR_WLS_config;
  rand LCR_STB_enum			LCR_STB_config;
  rand LCR_PEN_enum			LCR_PEN_config;
  rand LCR_EPS_enum			LCR_EPS_config;
  rand LCR_BGE_enum			LCR_BGE_config;
  rand IER_en_tx_fifo_full_enum	  	IER_en_tx_fifo_full_config;
  rand IER_en_tx_fifo_empty_enum	IER_en_tx_fifo_empty_config;
  rand IER_en_rx_fifo_full_enum		IER_en_rx_fifo_full_config;
  rand IER_en_rx_fifo_empty_enum	IER_en_rx_fifo_empty_config;
  rand IER_en_parity_error_enum		IER_en_parity_error_config;
  rand FSR_tx_status_full_enum		FSR_tx_full_status_config;
  rand FSR_tx_status_empty_enum		FSR_tx_empty_status_config;
  rand FSR_rx_status_full_enum		FSR_rx_full_status_config;
  rand FSR_rx_status_empty_enum		FSR_rx_empty_status_config;
  rand FSR_parity_error_status_enum	FSR_parity_error_status_config;
  rand bit [7:0]			TBR_tx_data_config;
  rand bit [7:0]			RBR_rx_data_config;

  //---------------------------------------------------
  // Field macros registry to factory
  `uvm_object_utils_begin (uart_rand_operation)
    `uvm_field_enum	(transfer_operation_enum, trans_oper, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(reg_base_offset_enum, reg_addr, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(MDR_OSM_SEL_enum, MDR_OSM_SEL_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int	(DLL_DLL_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int	(DLH_DLH_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(LCR_WLS_enum, LCR_WLS_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(LCR_STB_enum, LCR_STB_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(LCR_PEN_enum, LCR_PEN_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(LCR_EPS_enum, LCR_EPS_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(LCR_BGE_enum, LCR_BGE_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(IER_en_tx_fifo_full_enum, IER_en_tx_fifo_full_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(IER_en_tx_fifo_empty_enum, IER_en_tx_fifo_empty_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(IER_en_rx_fifo_full_enum, IER_en_rx_fifo_full_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(IER_en_rx_fifo_empty_enum, IER_en_rx_fifo_empty_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(IER_en_parity_error_enum, IER_en_parity_error_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(FSR_tx_status_full_enum, FSR_tx_full_status_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(FSR_tx_status_empty_enum, FSR_tx_empty_status_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(FSR_rx_status_full_enum, FSR_rx_full_status_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(FSR_rx_status_empty_enum, FSR_rx_empty_status_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum	(FSR_parity_error_status_enum, FSR_parity_error_status_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int	(TBR_tx_data_config, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int	(RBR_rx_data_config, UVM_ALL_ON | UVM_HEX)
  `uvm_object_utils_end

  //----------------------------------------------------
  // Constraint controlling rand register fields base on transfer type
  constraint random_uart_frame_test_constraint {
    trans_oper inside {IP_TRANSMIT, IP_RECEIVE, IP_FIRST_HALF_DUPLEX, IP_SECOND_HALF_DUPLEX, IP_FULL_DUPLEX};
    trans_oper dist {[IP_TRANSMIT:IP_RECEIVE] := 50, [IP_FIRST_HALF_DUPLEX:IP_SECOND_HALF_DUPLEX] := 30, IP_FULL_DUPLEX :/ 80};
    FSR_tx_full_status_config == TX_NOT_FULL;
    FSR_tx_empty_status_config == TX_IS_EMPTY;
    FSR_rx_full_status_config == RX_NOT_FULL;
    FSR_rx_empty_status_config == RX_IS_EMPTY;
    FSR_parity_error_status_config == PARITY_NOT_ERROR;
    LCR_PEN_config dist {PEN_NOPARITY :/ 10, PEN_ENBPARITY :/ 40};
    LCR_EPS_config dist {EPS_ODD :/ 20, EPS_EVEN :/ 20};
    LCR_BGE_config == BGE_ENBBAUDGEN;
    reg_addr inside {MDR_ADDR, DLL_ADDR, DLH_ADDR, LCR_ADDR, IER_ADDR, FSR_ADDR, TBR_ADDR, RBR_ADDR};
    if (trans_oper == IP_NO_TRANSFER) LCR_BGE_config == BGE_NOBAUDGEN;
    RBR_rx_data_config == 8'h00;
  }

endclass: uart_rand_operation
