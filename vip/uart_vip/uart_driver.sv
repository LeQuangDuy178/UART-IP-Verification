class uart_driver extends uvm_driver #(uart_transaction);

  `uvm_component_utils(uart_driver);

  /* FSM of driver declare */
  typedef enum bit [2:0] {
    IDLE = 3'b000,
    START = 3'b001,
    DATA = 3'b010,
    PARITY = 3'b011,
    STOP = 3'b100
  } state_enum;
  state_enum	state; 
  
  /* Time of transfer during simulation declaration */
  real tx_transfer_time;
  int states_num;

  virtual uart_if uart_vif;
  //virtual uart_if rhs_vif;

  /* Get the config from uvm_test_top via uvm_config_db 
  * Get the config and set it to the instance of uart_configuration
  * Avoid instance the object, only get via config_db and use*/
  uart_configuration uart_config;

  bit [2:0] state_str;

  local string msg = "[UART_VIP][UART_DRIVER]";

  function new(string name = "uart_driver", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info({msg, "[build_phase]"}, "Entered...", UVM_MEDIUM)

    /* Get uart_vif from agent via uvm_config_db 
    * Hierarchical: uvm_test_top.uart_env.uart_agt.uart_drv.lhs/rhs_vif"
    * Get proper data from hierarchy address, no worry*/
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", uart_vif))
      `uvm_fatal(msg, "Cannot get virtual interface via uvm_config_db")

    /*if (!uvm_config_db #(virtual uart_if)::get(this, "", "rhs_vif", uart_vif))
      `uvm_fatal(msg, "Cannot get virtual interface via uvm_config_db")

    /* Get uart_config from test hierarchy via uvm_config_db 
    * Hierarchy: "uvm_test_top.uart_env.uart_agt.uart_drv.uart_config" */
    if (!uvm_config_db #(uart_configuration)::get(this, "", "config", uart_config))
      `uvm_fatal(msg, "Cannot get configuration via uvm_config_db")
	    
    `uvm_info({msg, "[build_phase]"}, "Exited...", UVM_MEDIUM) 

  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
  
    `uvm_info({msg, "[run_phase]"}, "Entered...", UVM_MEDIUM) 

    //------------------------------------------------
    /* Driver task 
    * Data packet uart_transaction with data and parity get via req instance
    * Data transfer asynchronously, no need response
    * Use handshake get_next_item() and item_done() of sequencer-driver
    * Unless item_done() is called, next get_next_item() cannot be executed
    * Get configuration and calculate time depending on baud_rate
    * Also get appropriate parity depending on parity_mode
    * Get data and stop bit range depending on data_width and stop_bit_width*/  
    //tx_transfer_time = 1000000 / uart_config.baud_rate; // In us
    //`uvm_info(msg, $sformatf("Check time tx %f", tx_transfer_time), UVM_NONE)
    //#1;
    forever begin
      tx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
      `uvm_info({msg, "[run_phase]"}, $sformatf("Check time tx %f", tx_transfer_time), UVM_NONE)
      `uvm_info({msg, "[run_phase]"}, $sformatf("Check config: \n %s", uart_config.sprint()), UVM_HIGH)
      `uvm_info({msg, "[run_phase]"}, "Get req item from sequence", UVM_NONE)
      seq_item_port.get_next_item(req);
      `uvm_info(msg, $sformatf("Check data 'h%h", req.data), UVM_NONE)
      drive(req);
      seq_item_port.item_done(req);
      `uvm_info({msg, "[run_phase]"}, $sformatf("Item done at %0t", $time), UVM_NONE)
    end
    #1;
    //--------------------------------------------------
    //seq_item_port.item_done(req);
    `uvm_info({msg, "[run_phase]"}, "Exited...", UVM_MEDIUM)

  endtask: run_phase

  extern virtual task drive(inout uart_transaction req); // Bidirectional packet

endclass: uart_driver

task uart_driver::drive(inout uart_transaction req);
  
  //----------------------------------------------------
  /* Drive TX: Start -> Data (5 to 9) -> Parity (opt) -> Stop (1 or 2)
  * Drive TX in above order 
  * LSB first -> Receiver gets Stop bit first, last is start of TX 
  * Deploy Finite State Machine - FSM
  * 5 states: IDLE - START - DATA - PARITY - STOP
  * 1 bit of transfer time associates with its baud rate
  * 9600 baud_rate = 9600 hz = 9600bps -> 1 bit period = 1/baud_rate 
  * Data and parity constraint is configured and randomized in configuration*/
  
  // Set initial state is IDLE
  state = IDLE;

  /* Check number of states need to run in FSM 
  * If no_parity then 4 states, else 5 states */ 
  if (uart_config.parity_mode == uart_configuration::NO_PARITY) begin
    states_num = 4; // 4 states only
    `uvm_info(msg, "No parity then 4 states on transfer only", UVM_LOW)
  end
  else begin
    states_num = 5;
    `uvm_info(msg, "Odd or even parity then 5 states on transfer", UVM_LOW)
  end

  //------------------------------------------------------
  //#100; // Delay first before start driving, to see monitor behavior
  `uvm_info({msg, "[run_phase]"}, "Start driving", UVM_LOW) 

  for (int i = 0; i < states_num; i++) begin
  case (state)
    
    IDLE: begin
      `uvm_info({msg, "[IDLE state]"}, "Entered...", UVM_LOW)
      uart_vif.tx = 1'b1; // Empty/Idle transfer (Start HIGH)
      #10; // Delay slightly to see monitor behavior
      // Get user request via sequence
      /*if (req.data != 'h0) begin
        state = START;
      end */
      state = START;
    end  

    START: begin
      `uvm_info({msg, "[START state]"}, "Entered...", UVM_LOW)
 
      // Get transfer time based on config on start
      tx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
      `uvm_info({msg, "[run_phase]"}, $sformatf("Check time tx %f", tx_transfer_time), UVM_NONE)

      uart_vif.tx = 1'b0; // 1 start bit transition from 1 to 0
      #tx_transfer_time;
      //#50;  
      state = DATA; // Move to DATA state after 1 bit transfer period
    end

    DATA: begin
      `uvm_info({msg, "[DATA state]"}, "Entered...", UVM_LOW)
      for (int i = 0; i < uart_config.data_width; i++) begin
        uart_vif.tx = req.data[i]; // Get each bit serially
	#tx_transfer_time; // Delay 1 bit transfer period each data bit
        //#50;
      end

      // Move to PARITY or STOP depending on parity_mode
      if (uart_config.parity_mode == uart_configuration::NO_PARITY)
        state = STOP;
      else // uart_config.parity_mode == ODD or EVEN
        state = PARITY;
    end
    
    PARITY: begin
      `uvm_info({msg, "[PARITY state]"}, "Entered...", UVM_LOW)
      uart_vif.tx = req.parity; // If config.parity_mode = ODD or EVEN
      #tx_transfer_time; // Delay 1 bit transfer period for parity
      //#50;
      state = STOP;
    end

    STOP: begin
      `uvm_info({msg, "[STOP state]"}, "Entered...", UVM_LOW)
      if (uart_config.stop_bit_width == uart_configuration::ONE_STOP_BIT) begin
        uart_vif.tx = 1'b1;
	#tx_transfer_time;
	//#50;
      end
      else if (uart_config.stop_bit_width == uart_configuration::TWO_STOP_BIT) begin
        uart_vif.tx = 1'b1;
	repeat (2) #tx_transfer_time;
	//repeat (2) #50;
      end

      // Move to IDLE or START depending on user request
      /*
      if (req.data != 'h0) begin
        state = START;
      end
      else if (req.data == 'h0) begin
        state = IDLE;
      end
      */
      state = IDLE; // Get back to IDLE state before end transfer
    end 
     
  endcase

  end
  //----------------------------------------------------
  `uvm_info({msg, "[run_phase]"}, "Finish driving", UVM_NONE)

endtask: drive
