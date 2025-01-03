// Define all register fields in enum type

// Register addresses
typedef enum bit [11:0] {
  MDR_ADDR = 'h000,
  DLL_ADDR = 'h004,
  DLH_ADDR = 'h008,
  LCR_ADDR = 'h00c,
  IER_ADDR = 'h010,
  FSR_ADDR = 'h014,
  TBR_ADDR = 'h018,
  RBR_ADDR = 'h01c,
  RSVD_ADDR = 'h020
} reg_base_offset_enum;

//class uart_reg_field_define;
typedef enum bit {
  OSM_SEL_16X = 1'b0,
  OSM_SEL_13X = 1'b1
} MDR_OSM_SEL_enum;

typedef enum bit [1:0] {
  WLS_5BITS = 2'b00,
  WLS_6BITS = 2'b01,
  WLS_7BITS = 2'b10,
  WLS_8BITS = 2'b11
} LCR_WLS_enum;

typedef enum bit {
  STB_1STOP = 1'b0,
  STB_2STOP = 1'b1
} LCR_STB_enum;

typedef enum bit {
  PEN_NOPARITY = 1'b0,
  PEN_ENBPARITY = 1'b1
} LCR_PEN_enum;

typedef enum bit {
  EPS_ODD = 1'b0,
  EPS_EVEN = 1'b1
} LCR_EPS_enum;

typedef enum bit {
  BGE_NOBAUDGEN = 1'b0,
  BGE_ENBBAUDGEN = 1'b1
} LCR_BGE_enum;

typedef enum bit {
  DIS_TX_FULL = 1'b0,
  EN_TX_FULL = 1'b1
} IER_en_tx_fifo_full_enum;

typedef enum bit {
  DIS_TX_EMPTY = 1'b0,
  EN_TX_EMPTY = 1'b1
} IER_en_tx_fifo_empty_enum;

typedef enum bit {
  DIS_RX_FULL = 1'b0,
  EN_RX_FULL = 1'b1
} IER_en_rx_fifo_full_enum;

typedef enum bit {
  DIS_RX_EMPTY = 1'b0,
  EN_RX_EMPTY = 1'b1
} IER_en_rx_fifo_empty_enum;

typedef enum bit {
  DIS_PARITY_ERR = 1'b0,
  EN_PARITY_ERR = 1'b1
} IER_en_parity_error_enum;

typedef enum bit {
  TX_NOT_FULL = 1'b0,
  TX_IS_FULL = 1'b1
} FSR_tx_status_full_enum; // RO - TX = 0 not full, = 1 is full

typedef enum bit {
  TX_NOT_EMPTY = 1'b0,
  TX_IS_EMPTY = 1'b1
} FSR_tx_status_empty_enum; // RO - TX = 0 not empty, = 1 is empty

typedef enum bit {
  RX_NOT_FULL = 1'b0,
  RX_IS_FULL = 1'b1
} FSR_rx_status_full_enum; // RO - RX = 0 not full, = 1 is full

typedef enum bit {
  RX_NOT_EMPTY = 1'b0,
  RX_IS_EMPTY = 1'b1
} FSR_rx_status_empty_enum; // RO - RX = 0 not empty, = 1 is empty

typedef enum bit {
  PARITY_NOT_ERROR = 1'b0,
  PARITY_IS_ERROR_WRITE_1_TO_CLEAR = 1'b1
} FSR_parity_error_status_enum; // R/W1C - PE = 0 not error, = 1 is error -> W1C

//endclass: uart_reg_field_define
