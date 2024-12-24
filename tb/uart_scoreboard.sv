// Analysis exports declare macros
`uvm_analysis_imp_decl(_uart);
`uvm_analysis_imp_decl(_ahb);

class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard)

  local string msg = "[UART SCOREBOARD]";

  // Coverage properties
  `include "../vip/uart_vip/uart_coverage.sv"
  `include "../vip/ahb_vip/ahb_coverage.sv"

  // TLM analysis import exports
  uvm_analysis_imp_uart #(uart_transaction, uart_scoreboard) uart_item_collected_export;
  uvm_analysis_imp_ahb #(ahb_transaction, uart_scoreboard) ahb_item_collected_export;

  // Some flags
  bit sfc_enb = 1;
  bit checker_enb = 1;

  //----------------------------------------------------------------------
  // Comparison and checker properties data
  
  // Get UART and AHB transaction from VIP monitor
  uart_transaction	sco_uart_trans;
  ahb_transaction	sco_ahb_trans;

  // Store UART and AHB transaction to queue based on transfer type
  // UART TX and RX
  uart_transaction	sco_uart_trans_tx_queue[$];
  uart_transaction	sco_uart_trans_rx_queue[$];

  // AHB TBR and RBR
  ahb_transaction	sco_ahb_trans_transmit_queue[$];
  ahb_transaction	sco_ahb_trans_receive_queue[$];

  // Store UART and AHB transaction poped out from queue
  uart_transaction      sco_uart_trans_tx_pop;
  uart_transaction	sco_uart_trans_rx_pop;
  ahb_transaction       sco_ahb_trans_transmit_pop;
  ahb_transaction	sco_ahb_trans_receive_pop;

  // Get the data width WLS from ahb_transaction
  int ahb_word_length;

  //----------------------------------------------------------------------

  function new(string name ="uart_scoreboard", uvm_component parent);
    super.new(name, parent);
    uart_group = new();
    ahb_group = new();
  endfunction: new

  virtual function void build_phase(uvm_phase phase);

    `uvm_info({msg, "[build_phase]"}, "Entered...", UVM_FULL)

    if (!uvm_config_db #(uart_configuration)::get(this, "", "config_key", uart_config_cov)) begin
      `uvm_fatal({msg, "[build_phase]"}, "Cannot get uart vip config")
    end
    else begin
      `uvm_info({msg, "[build_phase]"}, "Get uart vip config success", UVM_FULL)
    end

    uart_item_collected_export = new("uart_item_collected_export", this);
    ahb_item_collected_export = new("ahb_item_collected_export", this);

    sco_uart_trans = uart_transaction::type_id::create("sco_uart_trans");
    sco_ahb_trans = ahb_transaction::type_id::create("sco_ahb_trans");

    sco_uart_trans_tx_pop = uart_transaction::type_id::create("sco_uart_tx");
    sco_uart_trans_rx_pop = uart_transaction::type_id::create("sco_uart_rx");
    sco_ahb_trans_transmit_pop = ahb_transaction::type_id::create("sco_ahb_transmit");
    sco_ahb_trans_receive_pop = ahb_transaction::type_id::create("sco_ahb_receive");

    uart_trans_cov = uart_transaction::type_id::create("uart_trans_cov");
    ahb_trans_cov = ahb_transaction::type_id::create("ahb_trans_cov");

    `uvm_info({msg, "[build_phase]"}, "Exited....", UVM_FULL)

  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);

    `uvm_info({msg, "[run_phase]"}, "Entered...", UVM_FULL)

    forever begin
      #1000000;
      
      //-------------------------------------------------------------------
      //$display("\n####################################################### CHECKER BEGIN ######################################################################\n");

      if (sco_uart_trans_rx_queue.size() > 0) begin
        sco_uart_trans_rx_pop = sco_uart_trans_rx_queue.pop_front();
        `uvm_info({msg, "[UART VIP TRANSACTION]", "[COMPARE]"}, $sformatf("Check UART RX Transaction from queue: \n%s", sco_uart_trans_rx_pop.sprint()), UVM_NONE)
      //end

      if (sco_ahb_trans_transmit_queue.size() > 0) begin
        sco_ahb_trans_transmit_pop = sco_ahb_trans_transmit_queue.pop_front();
        `uvm_info({msg, "[AHB VIP TRANSACTION]", "[COMPARE]"}, $sformatf("Check AHB Transmit Transaction from queue: \n%s", sco_ahb_trans_transmit_pop.sprint()), UVM_NONE)
      end

      if (checker_enb) begin
      if (sco_uart_trans_rx_queue.size() == 0) begin
      if (sco_uart_trans_rx_pop.data == sco_ahb_trans_transmit_pop.data) begin
        `uvm_info({msg, "[TRANSMIT CHECKER]","[run_phase]"}, $sformatf("\nCorrect data integrity and comparison of UART RX: 8'h%h and AHB TBR: 8'h%h\n", sco_uart_trans_rx_pop.data, sco_ahb_trans_transmit_pop.data), UVM_NONE)
      end
      else begin
        `uvm_error({msg, "[TRANSMIT CHECKER]","[run_phase]"}, $sformatf("\nWrong data integrity and comparison of UART RX: 8'h%h and AHB TBR: 8'h%h", sco_uart_trans_rx_pop.data, sco_ahb_trans_transmit_pop.data))
      end
      end
      end
      end
      //-------------------------------------------------------------------

      //if (sco_uart_trans_tx_queue.size() > 0) begin
      //$display("\n####################################################### CHECKER BEGIN ######################################################################\n");
      // Check transaction and its type for receive tests
      if (sco_uart_trans_tx_queue.size() > 0) begin
        sco_uart_trans_tx_pop = sco_uart_trans_tx_queue.pop_front(); 
        `uvm_info({msg, "[UART VIP TRANSACTION]", "[COMPARE]"}, $sformatf("Check UART TX Transaction from queue: \n%s", sco_uart_trans_tx_pop.sprint()), UVM_NONE)  
      //end

      if (sco_ahb_trans_receive_queue.size() > 0) begin
        sco_ahb_trans_receive_pop = sco_ahb_trans_receive_queue.pop_front();
        `uvm_info({msg, "[AHB VIP TRANSACTION]", "[COMPARE]"}, $sformatf("Check AHB Receive Transaction from queue: \n%s", sco_ahb_trans_receive_pop.sprint()), UVM_NONE)
      end

      //$display("\n####################################################### RECEIVE CHECKER BEGIN ######################################################################\n");
      // Checker for receive tests 
      if (checker_enb) begin
      if (sco_uart_trans_tx_queue.size() == 0) begin
      if (sco_uart_trans_tx_pop.data == sco_ahb_trans_receive_pop.data) begin
        `uvm_info({msg, "[RECEIVE CHECKER]","[run_phase]"}, $sformatf("\nCorrect data integrity and comparison of UART TX: 8'h%h and AHB RBR: 8'h%h\n", sco_uart_trans_tx_pop.data, sco_ahb_trans_receive_pop.data), UVM_NONE)
      end
      else begin
        `uvm_error({msg, "[RECEIVE CHECKER]","[run_phase]"}, $sformatf("\nWrong data integrity and comparison of UART TX: 8'h%h and AHB RBR: 8'h%h", sco_uart_trans_tx_pop.data, sco_ahb_trans_receive_pop.data))
      end
      end
      end
      //$display("\n####################################################### CHECKER END ######################################################################\n");
      end

      //-------------------------------------------------------------------

      //$display("\n####################################################### FINISH DATA ANALYSIS ######################################################################\n");
    end

    `uvm_info({msg, "[run_phase]"}, "Exited...", UVM_FULL)

  endtask: run_phase

  virtual function void check_phase(uvm_phase phase);
  endfunction: check_phase

  virtual function void report_phase(uvm_phase phase);
  endfunction: report_phase

  extern virtual function void write_uart(uart_transaction uart_trans_observed);
  extern virtual function void write_ahb(ahb_transaction ahb_trans_observed);

endclass: uart_scoreboard

function void uart_scoreboard::write_uart(uart_transaction uart_trans_observed);
  
  // Get transaction UART
  `uvm_info({msg, "[UART VIP TRANSACTION]", "[COVERAGE]"}, $sformatf("Get transaction UART: \n%s", uart_trans_observed.sprint()), UVM_LOW)
  $cast(sco_uart_trans, uart_trans_observed.clone());
  `uvm_info({msg, "[UART VIP CONFIG]", "[COVERAGE]"}, $sformatf("Check UART VIP config: \n%s", uart_config_cov.sprint()), UVM_NONE)
  
  // Analysize and filter UART frame before pushing to queue
  // VIP actually filter the data based on configs before send to RBR receive

  // Push to queue based on transfer type TX and RX
  if (sco_uart_trans.transfer_type == uart_transaction::TX) begin
    sco_uart_trans_tx_queue.push_back(sco_uart_trans);
  end
  else if (sco_uart_trans.transfer_type == uart_transaction::RX) begin
    sco_uart_trans_rx_queue.push_back(sco_uart_trans);
  end

  // Cast coverage
  $cast(uart_trans_cov, sco_uart_trans);
  uart_group.sample();

endfunction: write_uart

function void uart_scoreboard::write_ahb(ahb_transaction ahb_trans_observed);
  
  // Get transaction AHB	
  `uvm_info({msg, "[AHB VIP TRANSACTION]", "[COVERAGE]"}, $sformatf("Get transaction AHB: \n%s", ahb_trans_observed.sprint()), UVM_LOW)
  $cast(sco_ahb_trans, ahb_trans_observed.clone());
  
  // Analysize and filter UART frame before pushing transaction to queue
  // IP just config the register on interface, not the TBR transmit filtering
  if (sco_ahb_trans.addr == 'h0c) begin
    if (sco_ahb_trans.data[1:0] == 2'b00) begin
      ahb_word_length = 5;
    end
    else if (sco_ahb_trans.data[1:0] == 2'b01) begin
      ahb_word_length = 6;
    end
    else if (sco_ahb_trans.data[1:0] == 2'b10) begin
      ahb_word_length = 7;
    end
    else begin
      ahb_word_length = 8;
    end
  end

  // Push to queue based on transfer type TBR and RBR (reg addr)
  if (sco_ahb_trans.addr == 'h18) begin
    if (ahb_word_length == 5) begin	  
      sco_ahb_trans.data = sco_ahb_trans.data[4:0];
    end
    else if (ahb_word_length == 6) begin
      sco_ahb_trans.data = sco_ahb_trans.data[5:0];	    
    end
    else if (ahb_word_length == 7) begin
      sco_ahb_trans.data = sco_ahb_trans.data[6:0];
    end
    else begin
      sco_ahb_trans.data = sco_ahb_trans.data[7:0];
    end
    sco_ahb_trans_transmit_queue.push_back(sco_ahb_trans);
  end
  else if (sco_ahb_trans.addr == 'h1c) begin
    sco_ahb_trans_receive_queue.push_back(sco_ahb_trans);
  end

  // Cast coverage
  $cast(ahb_trans_cov, sco_ahb_trans);
  ahb_group.sample();

endfunction: write_ahb
