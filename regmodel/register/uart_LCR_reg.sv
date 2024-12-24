class uart_LCR_reg extends uvm_reg;

  `uvm_object_utils(uart_LCR_reg)

  uvm_reg_field		rsvd;
  rand uvm_reg_field	BGE;
  rand uvm_reg_field	EPS;
  rand uvm_reg_field	PEN;
  rand uvm_reg_field	STB;
  rand uvm_reg_field	WLS;

  function new(string name = "uart_LCR_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();

    rsvd = uvm_reg_field::type_id::create("rsvd");
    BGE = uvm_reg_field::type_id::create("BGE");
    EPS = uvm_reg_field::type_id::create("EPS");
    PEN = uvm_reg_field::type_id::create("PEN");
    STB = uvm_reg_field::type_id::create("STB");
    WLS = uvm_reg_field::type_id::create("WLS");

    // Configure reg fields
    rsvd.configure(this, 26, 6, "RO", 1'b0, 26'h0, 1, 1, 1);
    BGE.configure(this, 1, 5, "RW", 1'b0, 1'b0, 1, 1, 1);
    EPS.configure(this, 1, 4, "RW", 1'b0, 1'b0, 1, 1, 1);
    PEN.configure(this, 1, 3, "RW", 1'b0, 1'b0, 1, 1, 1);
    STB.configure(this, 1, 2, "RW", 1'b0, 1'b0, 1, 1, 1);
    WLS.configure(this, 2, 0, "RW", 1'b0, 2'b11, 1, 1, 1);

  endfunction: build

endclass: uart_LCR_reg
