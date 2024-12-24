class uart_FSR_reg extends uvm_reg;

  `uvm_object_utils(uart_FSR_reg)

  uvm_reg_field		rsvd;
  rand uvm_reg_field	parity_error_status;
  rand uvm_reg_field	rx_empty_status;
  rand uvm_reg_field	rx_full_status;
  rand uvm_reg_field	tx_empty_status;
  rand uvm_reg_field	tx_full_status;

  function new(string name = "uart_FSR_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();

    rsvd = uvm_reg_field::type_id::create("rsvd");
    parity_error_status = uvm_reg_field::type_id::create("parity_error_status");
    rx_empty_status = uvm_reg_field::type_id::create("rx_empty_status");
    rx_full_status = uvm_reg_field::type_id::create("rx_full_status");
    tx_empty_status = uvm_reg_field::type_id::create("tx_empty_status");
    tx_full_status = uvm_reg_field::type_id::create("tx_full_status");

    // Volatile 5th argument -> field is triggered by hardware device
    rsvd.configure(this, 27, 5, "RO", 1'b0, 27'h0, 1, 1, 1);
    parity_error_status.configure(this, 1, 4, "W1C", 1'b1, 1'b0, 1, 1, 1);
    rx_empty_status.configure(this, 1, 3, "RO", 1'b1, 1'b1, 1, 1, 1);
    rx_full_status.configure(this, 1, 2, "RO" , 1'b1, 1'b0, 1, 1, 1);
    tx_empty_status.configure(this, 1, 1, "RO", 1'b1, 1'b1, 1, 1, 1);
    tx_full_status.configure(this, 1, 0, "RO", 1'b1, 1'b0, 1, 1, 1);

  endfunction: build

endclass: uart_FSR_reg
