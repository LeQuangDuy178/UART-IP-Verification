class uart_frame_WLS_evenparity_2stop_half_duplex_IP_first_test extends uart_base_test;

  `uvm_component_utils(uart_frame_WLS_evenparity_2stop_half_duplex_IP_first_test)

  uart_simplex_sequence 	uart_simplex_seq;

  bit [1:0] uart_ip_WLS_arr[] = {WLS_5BITS, WLS_6BITS, WLS_7BITS, WLS_8BITS};
  int uart_vip_data_width_arr[] = {uart_configuration::WIDTH_5, uart_configuration::WIDTH_6, uart_configuration::WIDTH_7, uart_configuration::WIDTH_8};

  function new(string name = "uart_frame_WLS_evenparity_2stop_half_duplex_IP_first_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  virtual task run_phase(uvm_phase phase);

    uvm_status_e 	status;

    phase.raise_objection(this);

    //wait (ahb_vif.HRESETn == 1'b1);
    //@(posedge ahb_vif.HCLK);

    for (int i = 0; i < 4; i++) begin
    
      // Half-duplex transfer between UART IP and UART VIP devices
      // UART IP send first, then UART VIP send after that, and vice versa

      // UART VIP frame
      assert (uart_vip_config.randomize() with 
        {uart_vip_config.data_width == uart_vip_data_width_arr[i];
         uart_vip_config.parity_mode == uart_configuration::EVEN;
         uart_vip_config.stop_bit_width == uart_configuration::TWO_STOP_BIT;
         uart_vip_config.baud_rate == 9600;})
      else `uvm_error(get_type_name(), "Randomization Error!")

      // UART IP frame
      uart_ip_regmodel.MDR.OSM_SEL.set(OSM_SEL_16X);
      uart_ip_regmodel.MDR.write(status, uart_ip_regmodel.MDR.get());

      uart_ip_regmodel.DLL.DLL.set(8'h8b);
      uart_ip_regmodel.DLL.write(status, uart_ip_regmodel.DLL.get());

      uart_ip_regmodel.DLH.DLH.set(8'h02);
      uart_ip_regmodel.DLH.write(status, uart_ip_regmodel.DLH.get());

      uart_ip_regmodel.LCR.WLS.set(uart_ip_WLS_arr[i]);
      uart_ip_regmodel.LCR.STB.set(STB_2STOP);
      uart_ip_regmodel.LCR.PEN.set(PEN_ENBPARITY);
      uart_ip_regmodel.LCR.EPS.set(EPS_EVEN);
      uart_ip_regmodel.LCR.BGE.set(BGE_ENBBAUDGEN);
      uart_ip_regmodel.LCR.write(status, uart_ip_regmodel.LCR.get());

      uart_ip_regmodel.TBR.tx_data.set(8'ha6);
      //uart_ip_regmodel.TBR.update(status);
      uart_ip_regmodel.TBR.write(status, uart_ip_regmodel.TBR.get());

      #3000000; // Delay between each transfers (can be adjusted via baud gen)

      // Flag trigger finish transfer for next transfer
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

    end

    //#12000000;

    phase.drop_objection(this);

  endtask: run_phase

endclass: uart_frame_WLS_evenparity_2stop_half_duplex_IP_first_test
