package seq_pkg;

  import uvm_pkg::*;
  import uart_pkg::*;
  import ahb_pkg::*;

  `include "ahb_write_sequence.sv"
  `include "ahb_read_sequence.sv"
  `include "ahb_write_rsvd_sequence.sv"
  `include "ahb_read_rsvd_sequence.sv"
  `include "uart_simplex_sequence.sv" 
  `include "uart_half_duplex_sequence.sv"
  `include "uart_full_duplex_sequence.sv"
  `include "uart_simplex_wrong_parity_sequence.sv"

endpackage
