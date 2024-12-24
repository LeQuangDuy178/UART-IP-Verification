class uart_simplex_wrong_parity_sequence extends uvm_sequence #(uart_transaction);

  `uvm_object_utils(uart_simplex_wrong_parity_sequence)

  uart_configuration uart_config;

  function new(string name = "uart_simplex_wrong_parity_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    $display("\n################################################################# NEW UART VIP SIMPLEX TRANSFER ###########################################################################\n");
    req = uart_transaction::type_id::create("req");
    req.parity_constraint.constraint_mode(0);
    req.uart_config = this.uart_config;
    start_item(req);
    assert(req.randomize() with 
      {req.data == 8'h55;
       req.parity == 1'b1;
       req.transfer_type == uart_transaction::UNKNOWN;}) 
    else `uvm_error(get_type_name(), "Randomization failed!")
    `uvm_info(get_type_name(), $sformatf("Send req to driver: \n %s", req.sprint()), UVM_LOW)
    finish_item(req);
    `uvm_info(get_type_name(), "Finish item successful", UVM_MEDIUM)
    $display("\n################################################################# END UART VIP SIMPLEX TRANSFER ##########################################################################\n");
  endtask: body

endclass: uart_simplex_wrong_parity_sequence
