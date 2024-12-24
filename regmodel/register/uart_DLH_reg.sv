class uart_DLH_reg extends uvm_reg;

  `uvm_object_utils(uart_DLH_reg)

  /* Register elements (described in AHB slave IP registers) */
  uvm_reg_field		rsvd; // Reserved region
  rand uvm_reg_field	DLH; // RW Over-sampling mode select

  function new(string name = "uart_DLH_reg");
    super.new(name, 32, UVM_NO_COVERAGE); // 32 bit regsiter and no coverage sp
  endfunction: new

  /* Build register elements */
  virtual function void build();
    
    // Object instance for each field
    rsvd = uvm_reg_field::type_id::create("rsvd");
    DLH = uvm_reg_field::type_id::create("DLH");

    /* Configure each field with propers configs
    * parent/size/lsb_pos/access/volatile/reset/has_reset/is_rand/indiv_access
    * parent is hierarchical name of is class from regmodel 
    * size of the reg element, lsb bit pos of the element 
    * access type RW/RW1C/R0/etc., volatile ...
    * reset to-be-reseted value when triggered, has_reset reset affection
    * is_rand randomization enable, access individually only this field mode */
    rsvd.configure(this, 24, 8, "RO", 1'b0, 24'h0, 1, 1, 1);
    DLH.configure(this, 8, 0, "RW", 1'b0, 8'b0, 1, 1, 1);

  endfunction: build

endclass: uart_DLH_reg
