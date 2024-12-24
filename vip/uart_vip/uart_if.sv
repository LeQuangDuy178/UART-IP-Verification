interface uart_if();

  logic tx;
  logic rx;

  import uart_pkg::uart_monitor;

  uart_monitor::state_enum state_tx;
  uart_monitor::state_enum state_rx;

endinterface
