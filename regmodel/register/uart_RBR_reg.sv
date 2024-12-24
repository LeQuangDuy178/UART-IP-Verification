class uart_RBR_reg extends uvm_reg;

  `uvm_object_utils(uart_RBR_reg)

  uvm_reg_field		rsvd;
  rand uvm_reg_field	rx_data;

  function new (string name = "uart_RBR_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();
    
    rsvd = uvm_reg_field::type_id::create("rsvd");
    rx_data = uvm_reg_field::type_id::create("rx_data");

    rsvd.configure(this, 24, 8, "RO", 1'b0, 24'h0, 1, 1, 1);
    rx_data.configure(this, 8, 0, "RO", 1'b0, 8'hxx, 1, 1, 1);
    
  endfunction: build

endclass: uart_RBR_reg
