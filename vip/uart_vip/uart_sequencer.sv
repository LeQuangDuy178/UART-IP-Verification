class uart_sequencer extends uvm_sequencer #(uart_transaction);

  `uvm_component_utils(uart_sequencer);

  local string msg = "[UART_VIP][UART_SEQUENCER]";

  function new(string name = "uart_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  /*
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase
  */

endclass: uart_sequencer
