//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : uart_pkg.sv
// Author        : Le Quang Duy
// Date          : 12-Nov-2024
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_PACKAGE__SV
`define GUARD_UART_PACKAGE__SV

package uart_pkg;
  
  import uvm_pkg::*;

  //`include "uart_define.sv"
  `include "uart_configuration.sv"
  `include "uart_transaction.sv"
  `include "uart_sequencer.sv"
  `include "uart_driver.sv"
  `include "uart_monitor.sv"
  `include "uart_agent.sv"
  
  //`include "uart_scoreboard.sv"

endpackage: uart_pkg

`endif


