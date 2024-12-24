class uart_frame_change_baud_rate_OTF_same_MDR_transmit_test extends uart_base_test;

  `uvm_component_utils(uart_frame_change_baud_rate_OTF_same_MDR_transmit_test)

  uart_simplex_sequence 	uart_simplex_seq;
/*
  bit [1:0] uart_ip_WLS_arr[] = {WLS_5BITS, WLS_6BITS, WLS_7BITS, WLS_8BITS};
  int uart_vip_data_width_arr[] = {uart_configuration::WIDTH_5, uart_configuration::WIDTH_6, uart_configuration::WIDTH_7, uart_configuration::WIDTH_8};

  bit uart_ip_EPS_arr[] = {EPS_EVEN, EPS_ODD, EPS_EVEN, EPS_ODD};
  bit uart_ip_PEN_arr[] = {PEN_NOPARITY, PEN_ENBPARITY, PEN_ENBPARITY, PEN_NOPARITY};
  bit [1:0] uart_vip_parity_mode_arr[] = {uart_configuration::NO_PARITY, uart_configuration::ODD, uart_configuration::EVEN, uart_configuration::NO_PARITY};

  bit uart_ip_STB_arr[] = {STB_1STOP, STB_2STOP, STB_1STOP, STB_2STOP};
  bit uart_vip_stop_bit_width_arr[] = {uart_configuration::ONE_STOP_BIT, uart_configuration::TWO_STOP_BIT, uart_configuration::ONE_STOP_BIT, uart_configuration::TWO_STOP_BIT};
*/
  int uart_vip_baud_rate_arr[] = {9600, 19200};
  bit [7:0] uart_ip_DLL_arr[] = {8'h8b, 8'h45}; 
  bit [7:0] uart_ip_DLH_arr[] = {8'h02, 8'h01};

  function new(string name = "uart_frame_change_baud_rate_OTF_same_MDR_transmit_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e 	status;

    phase.raise_objection(this);

    //wait (ahb_vif.HRESETn == 1'b1);
    //@(posedge ahb_vif.HCLK);

    for (int i = 0; i < uart_vip_baud_rate_arr.size(); i++) begin
    
      // Full-duplex transfer between UART IP and UART VIP devices
      // UART VIP and UART IP send simultaneously

      if (uart_vif.state_tx == uart_monitor::IDLE && uart_vif.state_rx == uart_monitor::IDLE) begin
      // UART VIP frame
      assert (uart_vip_config.randomize() with 
        {uart_vip_config.data_width == uart_configuration::WIDTH_8;
         uart_vip_config.parity_mode == uart_configuration::NO_PARITY;
         uart_vip_config.stop_bit_width == uart_configuration::ONE_STOP_BIT;
         uart_vip_config.baud_rate == uart_vip_baud_rate_arr[i];})
      else `uvm_error(get_type_name(), "Randomization Error!")

      //uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_seq");
      //uart_simplex_seq.uart_config = uart_vip_config;
      /*
      uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
      wait (uart_vif.state_tx == uart_monitor::IDLE);
      uart_ip_regmodel.RBR.read(status, rdata);
      #1000000;
      */
      // UART IP frame
      //wait (uart_vif.state_tx == uart_monitor::IDLE);
      uart_ip_regmodel.MDR.OSM_SEL.set(OSM_SEL_16X);
      uart_ip_regmodel.MDR.write(status, uart_ip_regmodel.MDR.get());

      uart_ip_regmodel.DLL.DLL.set(uart_ip_DLL_arr[i]);
      uart_ip_regmodel.DLL.write(status, uart_ip_regmodel.DLL.get());

      uart_ip_regmodel.DLH.DLH.set(uart_ip_DLH_arr[i]);
      uart_ip_regmodel.DLH.write(status, uart_ip_regmodel.DLH.get());

      uart_ip_regmodel.LCR.WLS.set(WLS_8BITS);
      uart_ip_regmodel.LCR.STB.set(STB_1STOP);
      uart_ip_regmodel.LCR.PEN.set(PEN_NOPARITY);
      //uart_ip_regmodel.LCR.EPS.set(EPS_ODD);
      uart_ip_regmodel.LCR.BGE.set(BGE_ENBBAUDGEN);
      uart_ip_regmodel.LCR.write(status, uart_ip_regmodel.LCR.get());

      #2000000;
      end

      //fork
      // 1st: VIP transfer via uart_vif.tx, observed in uart_rxd
      //uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
      //wait (uart_vif.state_tx == uart_monitor::IDLE);
      //uart_ip_regmodel.RBR.read(status, rdata);
      //#1000000;

      // 2nd: IP transfer via uart_txd, observed in uart_vif.rx
      wait (uart_vif.state_rx == uart_monitor::IDLE);
      uart_ip_regmodel.TBR.tx_data.set(8'ha6);
      //uart_ip_regmodel.TBR.update(status);
      uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());
      //join

      //wait (uart_vif.state_rx == uart_monitor::IDLE);
      //#50000;
      //uart_ip_regmodel.RBR.read(status, rdata);
      //#1000000;

      #1500000; // Delay between each UART IP transfers (can be adjusted via baud gen)

      // Flag trigger finish transfer for next transfer
      /*
      if (uart_vif.state_rx == uart_monitor::IDLE) begin
        uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_seq");
	uart_simplex_seq.uart_config = uart_vip_config;
	uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
	uart_ip_regmodel.RBR.read(status, rdata);
	#1000000;
      end
      
      else begin 
        #2400000;
	uart_simplex_seq = uart_simplex_sequence::type_id::create("uart_simplex_seq");
	uart_simplex_seq.uart_config = uart_vip_config;
        uart_simplex_seq.start(uart_env.uart_agt.uart_seqr);
	uart_ip_regmodel.RBR.read(status, rdata);
	#1000000;
      end
      */
    end

    //#12000000;

    phase.drop_objection(this);

  endtask: run_phase

endclass: uart_frame_change_baud_rate_OTF_same_MDR_transmit_test
