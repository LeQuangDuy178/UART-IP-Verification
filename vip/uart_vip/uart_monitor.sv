class uart_monitor extends uvm_monitor;

  `uvm_component_utils(uart_monitor);

  virtual uart_if uart_vif;
  //virtual uart_if rhs_vif;

  typedef enum bit [2:0] {
    IDLE = 3'b000,
    START = 3'b001,
    DATA = 3'b010,
    PARITY = 3'b011,
    STOP = 3'b100
  } state_enum;
  state_enum	state;
  state_enum	state_rx;

  event finish_capture;

  int state_nums;
  real tx_transfer_time;
  real tx_half_transfer_time;
  real rx_transfer_time;
  real rx_half_transfer_time;

  bit uart_trans_queue[$]; // Array queue capture RX

  uart_configuration uart_config;

  uvm_analysis_port #(uart_transaction) item_observed_port;
  //uvm_analysis_port #(uart_transaction) item_observed_port_RX;

  uart_transaction uart_trans; // uart_trans_tx
  uart_transaction uart_trans_rx; // Actually 2 obj for TX and RX

  // Stored uart_trans_tx/rx to other vars
  //uart_transaction uart_trans_tx_cache;
  //uart_transaction uart_trans_rx_cache;

  local string msg = "[UART_VIP][UART_MONITOR]";

  function new(string name = "uart_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);

    `uvm_info({msg, "[build_phase]"}, "Entered...", UVM_MEDIUM)

    /* Get interface from agent via uvm_config_db 
    * Hierarchy: "uvm_test_top.uart_env.uart_agt.uart_mon.uart_vif" 
    * Get from lhs or rhs based on wildcard*/
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "vif", uart_vif))
      `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")

    //if (!uvm_config_db #(virtual uart_if)::get(null, "", "*.rhs_vif", uart_vif))
    //  `uvm_fatal(msg, "Cannot get virtual interface via uvm_config_db")

    /* Get uart_configuration from test hierarchy via uvm_config_db 
    * Hierarchy: "uvm_test_top.uart_env.uart_agt.uart_mon.uart_config" */
    if (!uvm_config_db #(uart_configuration)::get(this, "", "config", uart_config)) 
      `uvm_fatal(msg, "Cannot get configuration via uvm_config_db")

    item_observed_port = new("item_observed_port", this);
    uart_trans = uart_transaction::type_id::create("uart_trans_tx");
    uart_trans_rx = uart_transaction::type_id::create("uart_trans_rx");
    //uart_trans_tx_cache = uart_transaction::type_id::create("tx_cache");
    //uart_trans_rx_cache = uart_transaction::type_id::create("rx_cache");

    `uvm_info({msg, "[build_phase]"}, "Exited...", UVM_MEDIUM)

  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
  
    `uvm_info({msg, "[run_phase]"}, "Entered...", UVM_MEDIUM)

    //------------------------------------------------------
    /* Monitor task 
    * Capture pin-level activity -> Translate to transaction-level packet
    * Send to scoreboard via analysis port by write() */
    /*
    //tx_transfer_time = 1000000 / uart_config.baud_rate;
    //tx_half_transfer_time = tx_transfer_time / 2;
    //`uvm_info(msg, $sformatf("Check time %f", tx_transfer_time), UVM_LOW)
    //#1;
    forever begin
      tx_transfer_time = 1000000 / uart_config.baud_rate;
      tx_half_transfer_time = tx_transfer_time / 2;
      `uvm_info(msg, $sformatf("Check time %f", tx_transfer_time), UVM_LOW)
      capture(uart_trans, uart_trans_rx);
      
      fork 
	capture_tx(uart_trans);
	capture_rx(uart_trans_rx);
      join_any
      
      //item_obsserved_port.write(uart_trans, uart_trans_rx);
    end
    //#10000000;
    //------------------------------------------------------
    */

    fork 
      capture_tx(uart_trans);
      capture_rx(uart_trans_rx);
    join

    `uvm_info({msg, "[run_phase]"}, "Exited...", UVM_MEDIUM)

  endtask: run_phase

  //extern virtual task capture(inout uart_transaction uart_trans, inout uart_transaction uart_trans_rx);
  extern virtual task capture_tx(inout uart_transaction uart_trans);
  extern virtual task capture_rx(inout uart_transaction uart_trans_rx);

  // SVA tracking start behavior
// Track negedge of rx
/*
sequence seq_start_rx;
  !uart_vif.rx ##tx_transfer_time;
endsequence

property prop_start_rx;
  @(negedge uart_vif.rx) |=> !uart_vif.rx ##tx_transfer_time;
endproperty
*/
endclass: uart_monitor
/*
task uart_monitor::capture(inout uart_transaction uart_trans, inout uart_transaction uart_trans_rx);

  //----------------------------------------------------
  // Capture RX: Stop -> Parity (opt) -> Data (5 to 9) -> Start 
  // Capture RX in this order
  // Capture TX also
  // Also apply FSM
  // 5 states: IDLE - START - DATA - PARITY - STOP  

  fork
    capture_tx(uart_trans);
    capture_rx(uart_trans_rx);
  join_any
  
  //----------------------------------------------------
  // Display transaction to be sent to scoreboard (TX and RX)
  `uvm_info({msg, "[TX]"}, $sformatf("Check transaction TX: \n%s", uart_trans_tx_cache.sprint()), UVM_NONE)

  `uvm_info({msg, "[RX]"}, $sformatf("Check transaction RX: \n%s", uart_trans_rx_cache.sprint()), UVM_NONE)

  //-----------------------------------------------------
  // Perform checker to check TX and RX equivalance of LHS and RHS
  if (uart_trans_tx_cache.data == uart_trans_rx_cache.data) begin
    `uvm_info(msg, "Compare TX and RX success", UVM_MEDIUM)
  end
  else begin
    `uvm_error(msg, "Compare TX and RX fail")
  end

endtask: capture 
*/
task uart_monitor::capture_tx(inout uart_transaction uart_trans);
 
  forever begin     	
 
  `uvm_info({msg, "[run_phase]"}, $sformatf("Check config: \n %s", uart_config.sprint()), UVM_HIGH)

  tx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
  tx_half_transfer_time = tx_transfer_time / 2;
  `uvm_info(msg, $sformatf("Check time TX %f", tx_transfer_time), UVM_LOW)

  state = IDLE;
  uart_vif.state_tx = state;

  if (uart_config.parity_mode == uart_configuration::NO_PARITY) begin
    state_nums = 4;
    `uvm_info({msg, "[TX]"}, "No parity mode then 4 states only", UVM_LOW)
  end
  else begin
    state_nums = 5;
    `uvm_info({msg, "[TX]"}, "Odd and even parity mode then 5 states", UVM_LOW)
  end

  //---------------------------------------------------
  // Capture TX -> MSB first 
  // Start capture when @(negedge uart_vif.tx) in TX pin
  // FSM applied
  `uvm_info({msg, "[run_phase]"}, "Start capturing TX", UVM_LOW)

  for (int i = 0; i < state_nums; i++) begin
  case(state)

    IDLE: begin
      `uvm_info({msg, "[TX]", "[IDLE State]"}, "Entered...", UVM_LOW)
      // Capture empty transfer 
      
      // Get TX transfer time in idle state
      tx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
      tx_half_transfer_time = tx_transfer_time / 2;
      `uvm_info(msg, $sformatf("Check time TX %f", tx_transfer_time), UVM_LOW)

      // Wait for tx transite from 1 to 0
      //#10;
      @(negedge uart_vif.tx);
      state = START;
      uart_vif.state_tx = state;
      /*if (state == IDLE) begin
        state = START;
	uart_vif.state_tx = state;
      end*/
    end

    START: begin
      `uvm_info({msg, "[TX]", "[START State]"}, "Entered...", UVM_LOW)
      // Capture nothing for 1 bit period
      
      tx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
      tx_half_transfer_time = tx_transfer_time / 2;
      `uvm_info({msg, "[TX]"}, $sformatf("Check time TX %f", tx_transfer_time), UVM_NONE)

      #tx_transfer_time;
      // Next state
      state = DATA;
      uart_vif.state_tx = state;
    end

    DATA: begin
      `uvm_info({msg, "[TX]", "[DATA State]"}, "Entered...", UVM_LOW)
      `uvm_info({msg, "[TX Capture]"}, $sformatf("Check loop time TX data: %0b", uart_trans.data), UVM_NONE)
      uart_trans.data = 8'h00; // Reset uart_trans.data
      #tx_half_transfer_time; // Move to middle of transfer
      for(int i = 0; i < uart_config.data_width; i++) begin
        //#tx_transfer_time/2; // Move to middle of transfer
	uart_trans.data[i] = uart_vif.tx; // Capture at middle of 1-bit period
	#tx_transfer_time; // Delay to next middle of 1-bit period	
	//if (i == uart_config.data_width - 1) 
		//`uvm_info({msg, "[TX Capture]"}, $sformatf("Check loop time TX data: %0b", uart_trans.data[i]), UVM_NONE)
      end

      // Checker check TX data
      `uvm_info({msg, "[TX Capture]"}, $sformatf("Check data TX 'h%h", uart_trans.data), UVM_NONE)

      // Move to PARITY or STOP
      if (uart_config.parity_mode == uart_configuration::NO_PARITY) begin
        state = STOP;
	uart_vif.state_tx = state;
      end
      else begin
	state = PARITY;
	uart_vif.state_tx = state;
      end
    end

    PARITY: begin
      `uvm_info({msg, "[TX]", "[PARITY State]"}, "Entered...", UVM_LOW)
      uart_trans.parity = uart_vif.tx;
      #tx_transfer_time;
      
      // Checker check TX parity (later implement reference parity)
      `uvm_info({msg, "[TX capture]"}, $sformatf("Check parity TX 'h%h", uart_trans.parity), UVM_NONE)

      state = STOP;
      uart_vif.state_tx = state;
    end

    STOP: begin
      `uvm_info({msg, "[TX]", "[STOP State]"}, "Entered...", UVM_LOW)
      if (uart_config.stop_bit_width == uart_configuration::ONE_STOP_BIT) begin
        //uart_vif.tx = 1'b1;
        #tx_transfer_time;
      end
      else if (uart_config.stop_bit_width == uart_configuration::TWO_STOP_BIT) begin
        //uart_vif.tx = 1'b1;
        repeat (2) #tx_transfer_time;
      end

      // Move to IDLE or START
      //#tx_half_transfer_time; // Delay half more to finish same as driver
      /*
      if (uart_vif.tx != 0) begin
        //#tx_transfer_time/2;
	state = IDLE;
      end
      else begin
        state = START;
      end
      */
      //state = IDLE;
      //uart_vif.state_tx = state;
    end

  endcase
  end
  //----------------------------------------
  `uvm_info({msg, "[run_phase]"}, "Finish capturing TX", UVM_LOW)
  
  // Set transfer_type in uart_transaction is TX
  uart_trans.transfer_type = uart_transaction::TX;

  //uart_trans_tx_cache = uart_trans;  // Shallow copy
  `uvm_info({msg, "[TX]"}, $sformatf("Check transaction TX: \n%s", uart_trans.sprint()), UVM_HIGH)

  // Send TX to scoreboard via analysis port
  item_observed_port.write(uart_trans);

  // Trigger event to afterward drop objection from test run_phase
  //->finish_capture;

  end

endtask: capture_tx


task uart_monitor::capture_rx(inout uart_transaction uart_trans_rx);

  forever begin

  `uvm_info({msg, "[run_phase]"}, $sformatf("Check config: \n %s", uart_config.sprint()), UVM_HIGH)

  rx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
  rx_half_transfer_time = rx_transfer_time / 2;
  `uvm_info(msg, $sformatf("Check time RX %f", rx_transfer_time), UVM_LOW)	  

  // If TX drive in LHS, RHS capture RX
  // Start capture RX when @(negedge uart_vif.rx) in rx pin of interface
  state_rx = IDLE;
  uart_vif.state_rx = state_rx;

  if (uart_config.parity_mode == uart_configuration::NO_PARITY) begin
    state_nums = 4;
    `uvm_info({msg, "[RX]"}, "No parity then 4 states only", UVM_LOW)
  end
  else begin
    state_nums = 5;
    `uvm_info({msg, "[RX]"}, "Odd and even parity then 5 states", UVM_LOW)
  end

  //-------------------------------------------------------------------
  // Capture RX -> LSB first -> 0 to 1 transition
  //FSM applied
  `uvm_info({msg, "[run_phase]"}, "Start capturing RX", UVM_LOW)
  
  for (int i = 0; i < state_nums; i++) begin
  case (state_rx)  
     
    IDLE: begin
      // Empty capture
      `uvm_info({msg, "[RX]", "[IDLE State]"}, "Entered...", UVM_LOW)

      // Get rx transfer time
      rx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
      rx_half_transfer_time = rx_transfer_time / 2;
      `uvm_info(msg, $sformatf("Check time RX %f", rx_transfer_time), UVM_LOW)

      // Next state, flag is stop bit - MSB first
      @(negedge uart_vif.rx);
      state_rx = START;
      uart_vif.state_rx = state_rx;
    end

    START: begin
      `uvm_info({msg, "[RX]", "[START State]"}, "Entered...", UVM_LOW)

      rx_transfer_time = 64'd1000000000 / uart_config.baud_rate;
      rx_half_transfer_time = rx_transfer_time / 2;
      `uvm_info({msg, "[RX]"}, $sformatf("Check time RX %f", rx_transfer_time), UVM_NONE)

      #rx_transfer_time;
      state_rx = DATA;
      uart_vif.state_rx = state_rx;

      // SVA tracking start behavior
      // Track negedge of rx
      /*
      sequence seq_start_rx;
        !uart_vif.rx ##tx_transfer_time;
      endsequence

      property prop_start_rx;
        @(negedge uart_vif.rx) |=> !uart_vif.rx ##tx_transfer_time;
      endproperty
      
      assert property (prop_start_rx) else `uvm_error({msg, "[RX}", "[Start state]", "[SVA report]"}, "Wrong pattern for RX START", UVM_LOW) 
      */
    end

    DATA: begin
      `uvm_info({msg, "[RX]", "[DATA State]"}, "Entered...", UVM_LOW)
      
      uart_trans_rx.data = 8'h00; // Reset data
      #rx_half_transfer_time;	    
      for (int i = 0; i < uart_config.data_width; i++) begin
        //#tx_transfer_time/2; // Should capture at middle
	//uart_trans_queue.push_front(uart_vif.tx); // Already reverse to {MSB,LSB}
	uart_trans_rx.data[i] = uart_vif.rx;
	#rx_transfer_time;
      end
      `uvm_info({msg, "[RX]"}, $sformatf("Check data RX 'h%h", uart_trans_rx.data), UVM_LOW)

      // Next state
      if (uart_config.parity_mode == uart_configuration::NO_PARITY) begin
        state_rx = STOP;
	uart_vif.state_rx = state_rx;
      end
      else begin
        state_rx = PARITY;
	uart_vif.state_rx = state_rx;
      end
    end

    PARITY: begin
      `uvm_info({msg, "[RX]", "[PARITY State]"}, "Entered...", UVM_LOW)

      uart_trans_rx.parity = uart_vif.rx;
      #rx_transfer_time;

      `uvm_info({msg, "[RX]"}, $sformatf("Check parity 'h%h", uart_trans_rx.parity), UVM_MEDIUM)

      state_rx = STOP;
      uart_vif.state_rx = state_rx;
    end

    STOP: begin
      `uvm_info({msg, "[RX]", "[STOP State]"}, "Entered...", UVM_LOW)

      if (uart_config.stop_bit_width == uart_configuration::ONE_STOP_BIT) begin
        #rx_transfer_time;
      end
      else if (uart_config.stop_bit_width == uart_configuration::TWO_STOP_BIT) begin
        repeat (2) #rx_transfer_time;
      end

      //state_rx = IDLE;
      //uart_vif.state_rx = state_rx;
    end

  endcase	  
  end

  //-----------------------------------------------
  `uvm_info({msg, "[run_phase]"}, "Finish capturing RX", UVM_LOW)

  // Set transfer_type in uart_transaction is RX
  uart_trans_rx.transfer_type = uart_transaction::RX;

  //uart_trans_rx_cache = uart_trans_rx; // Shallow copy
  `uvm_info({msg, "[RX]"}, $sformatf("Check transaction RX: \n%s", uart_trans_rx.sprint()), UVM_HIGH)

  // Send to scoreboard via analysis port
  item_observed_port.write(uart_trans_rx);

  end

endtask: capture_rx

