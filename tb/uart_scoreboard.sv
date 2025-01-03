// Analysis exports declare macros
`uvm_analysis_imp_decl(_uart);
`uvm_analysis_imp_decl(_ahb);

class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard)

  local string msg = "[UART SCOREBOARD]";

  // Register field define
  `include "../regmodel/register/uart_reg_field_define.sv"

  // Coverage properties
  `include "../vip/uart_vip/uart_coverage.sv"
  `include "../vip/ahb_vip/ahb_coverage.sv"

  // TLM analysis import exports
  uvm_analysis_imp_uart #(uart_transaction, uart_scoreboard) uart_item_collected_export;
  uvm_analysis_imp_ahb #(ahb_transaction, uart_scoreboard) ahb_item_collected_export;

  // Some controlling flags
  bit sfc_enb = 1;
  bit checker_enb = 1;
  bit parity_checker_enb = 1;
  bit trans_disp_enb = 1;
  bit single_trans_enb = 0;
  bit full_duplex_trans_enb = 1;

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

  // Store parity bit by UART transaction TX and RX
  bit sco_uart_parity_tx_queue[$];
  bit sco_uart_parity_rx_queue[$];
  bit sco_uart_parity_tx;
  bit sco_uart_parity_rx;
  bit sco_uart_parity_queue[$];
  bit sco_uart_parity;

  // Store parity mode by AHB transaction
  // Check parity transmitted by IP and received to the IP
  typedef enum bit [1:0] {NO_PARITY = 0, ODD = 1, EVEN = 2} ahb_parity_mode_enum;
  ahb_parity_mode_enum	ahb_parity_mode;
  bit sco_ahb_parity;
  bit sco_ahb_parity_transmit;
  bit sco_ahb_parity_receive;
  bit [7:0] ahb_data_transmit;
  bit [7:0] ahb_data_receive;
  string ip_transfer_type;

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
      if (trans_disp_enb) begin
      if (sco_uart_trans_rx_queue.size() > 0) begin
        sco_uart_trans_rx_pop = sco_uart_trans_rx_queue.pop_front();
        `uvm_info({msg, "[UART VIP TRANSACTION]", "[COMPARE]"}, $sformatf("Check UART RX Transaction from queue: \n%s", sco_uart_trans_rx_pop.sprint()), UVM_NONE)
      //end

      if (sco_ahb_trans_transmit_queue.size() > 0) begin
        sco_ahb_trans_transmit_pop = sco_ahb_trans_transmit_queue.pop_front();
        `uvm_info({msg, "[AHB VIP TRANSACTION]", "[COMPARE]"}, $sformatf("Check AHB Transmit Transaction from queue: \n%s", sco_ahb_trans_transmit_pop.sprint()), UVM_NONE)
      end
      //end

      if (checker_enb) begin
      if (sco_uart_trans_rx_queue.size() == 0) begin
      wait (sco_uart_trans_rx_pop.data != 8'h00 && sco_ahb_trans_transmit_pop.data != 8'h00);
      if (sco_uart_trans_rx_pop.data == sco_ahb_trans_transmit_pop.data) begin
        `uvm_info({msg, "[TRANSMIT CHECKER]","[run_phase]"}, $sformatf("\nCorrect data integrity and comparison of UART RX: 8'h%h and AHB TBR: 8'h%h\n", sco_uart_trans_rx_pop.data, sco_ahb_trans_transmit_pop.data), UVM_NONE)
      end
      else begin
        `uvm_error({msg, "[TRANSMIT CHECKER]","[run_phase]"}, $sformatf("\nWrong data integrity and comparison of UART RX: 8'h%h and AHB TBR: 8'h%h", sco_uart_trans_rx_pop.data, sco_ahb_trans_transmit_pop.data))
      end
      sco_uart_trans_rx_pop.data = 8'h00;
      sco_ahb_trans_transmit_pop.data = 8'h00;
      end
      end
      end
      end
      //-------------------------------------------------------------------

      //if (sco_uart_trans_tx_queue.size() > 0) begin
      //$display("\n####################################################### CHECKER BEGIN ######################################################################\n");
      // Check transaction and its type for receive tests
      if (trans_disp_enb) begin
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
       wait (sco_uart_trans_tx_pop.data != 8'h00 && sco_ahb_trans_receive_pop.data != 8'h00);
      if (sco_uart_trans_tx_pop.data == sco_ahb_trans_receive_pop.data) begin
        `uvm_info({msg, "[RECEIVE CHECKER]","[run_phase]"}, $sformatf("\nCorrect data integrity and comparison of UART TX: 8'h%h and AHB RBR: 8'h%h\n", sco_uart_trans_tx_pop.data, sco_ahb_trans_receive_pop.data), UVM_NONE)
      end
      else begin
        `uvm_error({msg, "[RECEIVE CHECKER]","[run_phase]"}, $sformatf("\nWrong data integrity and comparison of UART TX: 8'h%h and AHB RBR: 8'h%h", sco_uart_trans_tx_pop.data, sco_ahb_trans_receive_pop.data))
      end
      sco_uart_trans_tx_pop.data = 8'h00;
      sco_ahb_trans_receive_pop.data = 8'h00;
      end
      end
      //$display("\n####################################################### CHECKER END ######################################################################\n");
      end
      end

      //-------------------------------------------------------------------
      // Parity checker for single transfer
      if (trans_disp_enb) begin
      if (single_trans_enb) begin
      if (sco_uart_parity_queue.size() > 0) begin
	//if (single_trans_enb) begin
        full_duplex_trans_enb = 0;
	sco_uart_parity = sco_uart_parity_queue.pop_front();
	`uvm_info({msg, "[PARITY CHECKER]", "[run_phase]"}, $sformatf("\n[%s] - Check parity of AHB Transaction: 1'b%b and UART Transaction: 1'b%b\n", ip_transfer_type, sco_ahb_parity, sco_uart_parity), UVM_NONE)
        //end
	//`uvm_info({msg, "[PARITY CHECKER]", "[run_phase]"}, $sformatf("\n[%s] - Check parity of AHB Transaction: 1'b%b and UART Transaction: 1'b%b\n", ip_transfer_type, sco_ahb_parity_receive, sco_uart_parity), UVM_NONE)
      //end
      //end

      if (parity_checker_enb) begin
      if (sco_uart_parity_queue.size() == 0) begin // Duplicate checker even when new transfer occur -> accidental wrong parity
	if (sco_uart_parity == sco_ahb_parity) begin
          `uvm_info({msg, "[PARITY_CHECKER]", "[COMPARE]"}, "\nCorrect parity comparison for AHB Transaction and UART Transaction\n", UVM_NONE)
	end
        else begin
          `uvm_error({msg, "[PARITY_CHECKER]", "[COMPARE]"}, "\nWrong parity comparison for AHB Transaction and UART Transaction")
        end
      end
      end
      end
      end
      end
      //-------------------------------------------------------------------
      // Parity check for full duplex transfer
      if (trans_disp_enb) begin
      if (full_duplex_trans_enb) begin
        single_trans_enb = 0;

	// Receive
	if (sco_uart_parity_tx_queue.size() > 0) begin
          sco_uart_parity_tx = sco_uart_parity_tx_queue.pop_front();
	  `uvm_info({msg, "[PARITY CHECKER]", "[RECEIVE]"}, $sformatf("\nCheck parity between UART TX: 1'b%b and AHB Receive: 1'b%b\n", sco_uart_parity_tx, sco_ahb_parity_receive), UVM_NONE)
	  if (parity_checker_enb) begin
          if (sco_uart_parity_tx_queue.size() == 0) begin
            if (sco_uart_parity_tx == sco_ahb_parity_receive) begin
              `uvm_info({msg, "[PARITY CHECKER]", "[RECEIVE]"}, $sformatf("\nCorrect parity compare between UART TX: 1'b%b and AHB Receive: 1'b%b\n", sco_uart_parity_tx, sco_ahb_parity_receive), UVM_NONE)
	    end
	    else begin
              `uvm_error({msg, "[PARITY CHECKER]", "[RECEIVE]"}, $sformatf("\nWrong parity compare between UART TX: 1'b%b and AHB Receive: 1'b%b\n", sco_uart_parity_tx, sco_ahb_parity_receive))
	    end
	  end
          end
	end

	// Transmit
	else if (sco_uart_parity_rx_queue.size() > 0) begin
          sco_uart_parity_rx = sco_uart_parity_rx_queue.pop_front();
	  `uvm_info({msg, "[PARITY CHECKER]", "[TRANSMIT]"}, $sformatf("\nCheck parity between UART RX: 1'b%b and AHB Transmit: 1'b%b\n", sco_uart_parity_rx, sco_ahb_parity_transmit), UVM_NONE)
	  if (parity_checker_enb) begin
	  if (sco_uart_parity_rx_queue.size() == 0) begin
            if (sco_uart_parity_rx == sco_ahb_parity_transmit) begin
	      `uvm_info({msg, "[PARITY CHECKER]", "[TRANSMIT]"}, $sformatf("\nCorrect parity compare between UART RX: 1'b%b and AHB Transmit: 1'b%b\n", sco_uart_parity_rx, sco_ahb_parity_transmit), UVM_NONE)
	    end
	    else begin
 	      `uvm_error({msg, "[PARITY CHECKER]", "[TRANSMIT]"}, $sformatf("\nWrong parity compare between UART RX: 1'b%b and AHB Transmit: 1'b%b\n", sco_uart_parity_rx, sco_ahb_parity_transmit))
	    end
	  end
          end
        end 
      end
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
    sco_uart_parity_tx_queue.push_back(sco_uart_trans.parity);
  end
  else if (sco_uart_trans.transfer_type == uart_transaction::RX) begin
    sco_uart_trans_rx_queue.push_back(sco_uart_trans);
    sco_uart_parity_rx_queue.push_back(sco_uart_trans.parity);
  end

  // Get UART TX and RX parity
  sco_uart_parity_queue.push_back(sco_uart_trans.parity);

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
  if (sco_ahb_trans.addr == LCR_ADDR) begin
    if (sco_ahb_trans.data[1:0] == WLS_5BITS) begin
      ahb_word_length = 5;
    end
    else if (sco_ahb_trans.data[1:0] == WLS_6BITS) begin
      ahb_word_length = 6;
    end
    else if (sco_ahb_trans.data[1:0] == WLS_7BITS) begin
      ahb_word_length = 7;
    end
    else begin
      ahb_word_length = 8;
    end
  end

  // Get the parity mode based on AHB LCR config
  if (sco_ahb_trans.addr == LCR_ADDR) begin
    if (sco_ahb_trans.data[3] == PEN_ENBPARITY) begin
      if (sco_ahb_trans.data[4] == EPS_ODD) begin
        ahb_parity_mode = ODD;
      end
      else if (sco_ahb_trans.data[4] == EPS_EVEN) begin
        ahb_parity_mode = EVEN;
      end
    end
    else if(sco_ahb_trans.data[3] == PEN_NOPARITY) begin
      ahb_parity_mode = NO_PARITY;
    end
  end


  // Push to queue based on transfer type TBR and RBR (reg addr)
  if (sco_ahb_trans.addr == TBR_ADDR) begin
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
    ahb_data_transmit = sco_ahb_trans.data; // IP transmit data -> need filter
    sco_ahb_trans_transmit_queue.push_back(sco_ahb_trans);
  end
  else if (sco_ahb_trans.addr == RBR_ADDR) begin
    ahb_data_receive = sco_ahb_trans.data; // VIP transmit data -> no need filter
    sco_ahb_trans_receive_queue.push_back(sco_ahb_trans);
  end

  /* Get the parity bit based on AHB LCR config
  if (sco_ahb_trans.addr == LCR_ADDR) begin
    if (sco_ahb_trans.data[3] == PEN_ENBPARITY) begin
      if (sco_ahb_trans.data[4] == EPS_ODD) begin
        ahb_parity_mode = ODD;
      end
      else if (sco_ahb_trans.data[4] == EPS_EVEN) begin
        ahb_parity_mode = EVEN;
      end
    end
  end*/

  // Get parity bit on transmit or receive
  if (sco_ahb_trans.addr == TBR_ADDR) begin
    if (ahb_parity_mode == ODD) begin
      sco_ahb_parity_transmit = ~^ahb_data_transmit;
      sco_ahb_parity = ~^ahb_data_transmit;
      ip_transfer_type = "TRANSMIT";
    end
    else if (ahb_parity_mode == EVEN) begin
      sco_ahb_parity_transmit = ^ahb_data_transmit;
      sco_ahb_parity = ^ahb_data_transmit;
      ip_transfer_type = "TRANSMIT";
    end
  end
  else if (sco_ahb_trans.addr == RBR_ADDR) begin
    if (ahb_parity_mode == ODD) begin
      sco_ahb_parity_receive = ~^ahb_data_receive;
      sco_ahb_parity = ~^ahb_data_receive;
      ip_transfer_type = "RECEIVE";
    end
    else if (ahb_parity_mode == EVEN) begin
      sco_ahb_parity_receive = ^ahb_data_receive;
      sco_ahb_parity = ^ahb_data_receive;
      ip_transfer_type = "RECEIVE";
    end
  end
  else begin
    sco_ahb_parity = 0;
  end

  // Cast coverage
  $cast(ahb_trans_cov, sco_ahb_trans);
  ahb_group.sample();

endfunction: write_ahb
