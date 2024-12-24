class uart_MDR_reg extends uvm_reg;

  `uvm_object_utils(uart_MDR_reg)

  /* Register elements (described in AHB slave IP registers) */
  uvm_reg_field		rsvd; // Reserved region
  rand uvm_reg_field	OSM_SEL; // RW Over-sampling mode select

  function new(string name = "uart_MDR_reg");
    super.new(name, 32, UVM_NO_COVERAGE); // 32 bit regsiter and no coverage sp
  endfunction: new

  /* Build register elements */
  virtual function void build();
    
    // Object instance for each field
    rsvd = uvm_reg_field::type_id::create("rsvd");
    OSM_SEL = uvm_reg_field::type_id::create("OSM_SEL");

    /* Configure each field with propers configs
    * parent/size/lsb_pos/access/volatile/reset/has_reset/is_rand/indiv_access
    * parent is hierarchical name of is class from regmodel 
    * size of the reg element, lsb bit pos of the element 
    * access type RW/RW1C/R0/etc., volatile trigger by hardware or software?
    * reset to-be-reseted value when triggered, has_reset reset affection
    * is_rand randomization enable, access individually only this field mode */
    rsvd.configure(this, 31, 1, "RO", 1'b0, 31'h0, 1, 1, 1); 
    OSM_SEL.configure(this, 1, 0, "RW", 1'b0, 1'b0, 1, 1, 1);

  endfunction: build

endclass: uart_MDR_reg
