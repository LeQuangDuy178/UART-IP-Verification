//=============================================================================
// Project       : AHB VIP
//=============================================================================
// Filename      : ahb_pkg.sv
// Author        : Huy Nguyen
// Date          : 19-Oct-2024
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_AHB_PACKAGE__SV
`define GUARD_AHB_PACKAGE__SV

package ahb_pkg;
  import uvm_pkg::*;

  `include "ahb_define.sv"
  `include "ahb_transaction.sv"
  `include "ahb_sequencer.sv"
  `include "ahb_driver.sv"
  `include "ahb_monitor.sv"
  `include "ahb_agent.sv"
  //`include "ahb_scoreboard.sv"

endpackage: ahb_pkg

`endif


