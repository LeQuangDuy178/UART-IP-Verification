class uart_reg_block extends uvm_reg_block;

  `uvm_object_utils(uart_reg_block)

  rand uart_MDR_reg 	MDR;
  rand uart_DLL_reg 	DLL;
  rand uart_DLH_reg 	DLH;
  rand uart_LCR_reg 	LCR;
  rand uart_IER_reg 	IER;
  rand uart_FSR_reg 	FSR;
  rand uart_TBR_reg 	TBR;
  rand uart_RBR_reg 	RBR;

  // Address map for register memory access
  uvm_reg_map ahb_map;

  function new (string name = "uart_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction: new

  virtual function void build();
  
    /* Register create factory 
    * Register fields configuration*/
    MDR = uart_MDR_reg::type_id::create("MDR");
    MDR.configure(this);
    MDR.build();

    DLL = uart_DLL_reg::type_id::create("DLL");
    DLL.configure(this);
    DLL.build();
	 
    DLH = uart_DLH_reg::type_id::create("DLH");
    DLH.configure(this);
    DLH.build();

    LCR = uart_LCR_reg::type_id::create("LCR");
    LCR.configure(this);
    LCR.build();

    IER = uart_IER_reg::type_id::create("IER");
    IER.configure(this);
    IER.build();

    FSR = uart_FSR_reg::type_id::create("FSR");
    FSR.configure(this);
    FSR.build();
   
    TBR = uart_TBR_reg::type_id::create("TBR");
    TBR.configure(this);
    TBR.build();

    RBR = uart_RBR_reg::type_id::create("RBR");
    RBR.configure(this);
    RBR.build();

    /* Configure these regs using AHB bus then create AHB map 
    * To access register offset addr and their fields*/
    ahb_map = create_map("ahb_map", 0, 4, UVM_LITTLE_ENDIAN);

    ahb_map.add_reg(MDR, `UVM_REG_ADDR_WIDTH'h00, "RW");
    ahb_map.add_reg(DLL, `UVM_REG_ADDR_WIDTH'h04, "RW");
    ahb_map.add_reg(DLH, `UVM_REG_ADDR_WIDTH'h08, "RW");
    ahb_map.add_reg(LCR, `UVM_REG_ADDR_WIDTH'h0C, "RW");
    ahb_map.add_reg(IER, `UVM_REG_ADDR_WIDTH'h10, "RW");
    ahb_map.add_reg(FSR, `UVM_REG_ADDR_WIDTH'h14, "RO");
    ahb_map.add_reg(TBR, `UVM_REG_ADDR_WIDTH'h18, "WO");
    ahb_map.add_reg(RBR, `UVM_REG_ADDR_WIDTH'h1C, "RO");

    // Lock model avoid unexpected change to regmodel
    lock_model();

  endfunction: build

endclass: uart_reg_block
