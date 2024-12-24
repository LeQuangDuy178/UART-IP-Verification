package env_pkg;

  import uvm_pkg::*;
  import ahb_pkg::*;
  import uart_pkg::*;
  import uart_regmodel_pkg::*;
  //import seq_pkg::*;
  //import test_pkg::*;

  // No include interface in pkg, instead in tb.f compilation scope

  //`include "interrupt_if.sv"
  `include "uart_scoreboard.sv"
  `include "uart_environment.sv"
  //`include "testbench.sv"
  //`include "uart_ip_interface.sv"

endpackage
