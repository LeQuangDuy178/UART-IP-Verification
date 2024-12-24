module testbench;

  // Interrupt interface used in test_pkg -> compile it first
  //`include "interrupt_if.sv"

  import uvm_pkg::*;
  import uart_pkg::*;
  import ahb_pkg::*;
  import test_pkg::*;
  //import vip_pkg::*;
  //import reg_pkg::*;
  
  // Allow entire environment have this file information
  // Since testbench.sv is the top level hierarchical file seen by compiler
  //`include "interrupt_if.sv"

  /* Interface declare and instantiate 
  * Interconnection */
  uart_if	uart_if();
  ahb_if	ahb_if();
  interrupt_if	intr_if();
  //uart_ip_if	uart_ip_if();
  
  /* Interconnect with uart_top 
  * ."RTL Signal"("Interface Signal") */
  uart_top uart_ip_if_ins(
  	  
	  // AHB-Lite VIP interface
	  .HCLK(ahb_if.HCLK),
	  .HRESETN(ahb_if.HRESETn),
	  .HADDR(ahb_if.HADDR),
	  .HTRANS(ahb_if.HTRANS),
	  .HBURST(ahb_if.HBURST),
	  .HSIZE(ahb_if.HSIZE),
	  .HPROT(ahb_if.HPROT),
	  .HWRITE(ahb_if.HWRITE),
	  .HSEL(ahb_if.HSEL),
	  .HWDATA(ahb_if.HWDATA),
	  .HREADYOUT(ahb_if.HREADYOUT),
	  .HRDATA(ahb_if.HRDATA),
	  .HRESP(ahb_if.HRESP),

	  // UART VIP interface
	  .uart_rxd(uart_if.tx),
	  .uart_txd(uart_if.rx),

	  // Interrupt interface
	  .interrupt(intr_if.interrupt)

  );

  assign ahb_if.HSEL = 1'b1;

  initial begin
    ahb_if.HRESETn = 0;
    #100ns ahb_if.HRESETn = 1;
  end

  initial begin
    ahb_if.HCLK = 0;
    forever begin
      #5ns;
      ahb_if.HCLK = ~ahb_if.HCLK;
    end
  end

  initial begin

    /* Set uart and ahb interface to 2 agents inside test environment 
    * Component need these inf: test, env, drv, mon 	    
    * Hierarchical path: "uvm_test_top.uart/ahb_key" 
    * Set interrupt interface to test environment
    * Component need this inf: test since we need the info of intr in test 
    * Interrupt flag will be sent to scoreboard inside env 
    * Hierarchical path: "uvm_test_top.intr_key" */ 	  
    uvm_config_db #(virtual uart_if)::set(uvm_root::get(), "uvm_test_top", "uart_key", uart_if);
    uvm_config_db #(virtual ahb_if)::set(uvm_root::get(), "uvm_test_top", "ahb_key", ahb_if);
    uvm_config_db #(virtual interrupt_if)::set(uvm_root::get(), "uvm_test_top", "intr_key", intr_if);

    run_test();

  end

endmodule
