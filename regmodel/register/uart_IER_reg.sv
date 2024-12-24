class uart_IER_reg extends uvm_reg;

  `uvm_object_utils(uart_IER_reg)

  uvm_reg_field		rsvd;
  rand uvm_reg_field	en_parity_error;
  rand uvm_reg_field	en_rx_fifo_empty;
  rand uvm_reg_field	en_rx_fifo_full;
  rand uvm_reg_field	en_tx_fifo_empty;
  rand uvm_reg_field	en_tx_fifo_full;

  function new(string name = "uart_IER_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();
  
    rsvd = uvm_reg_field::type_id::create("rsvd");
    en_parity_error = uvm_reg_field::type_id::create("en_parity_error");
    en_rx_fifo_empty = uvm_reg_field::type_id::create("en_rx_fifo_empty");
    en_rx_fifo_full = uvm_reg_field::type_id::create("en_tx_fifo_full");
    en_tx_fifo_empty = uvm_reg_field::type_id::create("en_tx_fifo_empty");
    en_tx_fifo_full = uvm_reg_field::type_id::create("en_tx_fifo_full");

    rsvd.configure(this, 27, 5, "RO", 1'b0, 27'h0, 1, 1, 1);
    en_parity_error.configure(this, 1, 4, "RW", 1'b0, 1'b0, 1, 1, 1);
    en_rx_fifo_empty.configure(this, 1, 3, "RW", 1'b0, 1'b0, 1, 1, 1);
    en_rx_fifo_full.configure(this, 1, 2, "RW", 1'b0, 1'b0, 1, 1, 1);
    en_tx_fifo_empty.configure(this, 1, 1, "RW", 1'b0, 1'b0, 1, 1, 1);
    en_tx_fifo_full.configure(this, 1, 0, "RW", 1'b0, 1'b0, 1, 1, 1);    

  endfunction: build

endclass: uart_IER_reg
