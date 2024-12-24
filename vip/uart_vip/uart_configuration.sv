class uart_configuration extends uvm_object;

  //`uvm_object_utils(uart_configuration);

  function new(string name = "uart_configuration");
    super.new(name);
  endfunction: new

  //----------------------------------------
  /* UART Configurations 
  * Configure 1 time and transfer data multiple times
  * Mostly setup the config of parity mode, baud rate, etc. here*/

  typedef enum bit [1:0] {NO_PARITY = 0, ODD = 1, EVEN = 2} parity_mode_enum;
  typedef enum bit {ONE_STOP_BIT = 0, TWO_STOP_BIT = 1} stop_bit_enum;
  typedef enum int {
    WIDTH_5 = 5,
    WIDTH_6 = 6,
    WIDTH_7 = 7,
    WIDTH_8 = 8,
    WIDTH_9 = 9
  } data_width_enum;

  rand parity_mode_enum 	parity_mode;
  rand stop_bit_enum 		stop_bit_width;
  rand data_width_enum		data_width;
  rand int 			baud_rate;
  //-----------------------------------------
  /* UVM Field register */

  `uvm_object_utils_begin (uart_configuration)
    `uvm_field_enum	(parity_mode_enum, parity_mode, UVM_ALL_ON |UVM_HEX)
    `uvm_field_enum	(stop_bit_enum, stop_bit_width, UVM_ALL_ON |UVM_HEX)
    `uvm_field_enum	(data_width_enum, data_width, UVM_ALL_ON |UVM_HEX)
    `uvm_field_int	(baud_rate, UVM_ALL_ON| UVM_DEC)
  `uvm_object_utils_end
  //-----------------------------------------
  /* Constraint (later using in-line constraint randomize) */
  
  constraint parity_mode_constraint {
    parity_mode dist {NO_PARITY :/ 70, [ODD:EVEN] := 50};
  }
  constraint stop_bit_constraint {
    stop_bit_width inside {ONE_STOP_BIT, TWO_STOP_BIT};
  }
  constraint data_width_constraint {
    data_width inside {WIDTH_5, WIDTH_6, WIDTH_7, WIDTH_8, WIDTH_9};
  }
  constraint baud_rate_constraint {
    //baud_rate dist {9600 :/ 60, 19200 := 50, 4800 :/ 40, 115200 :/ 20, 57600 :/ 30};
    baud_rate inside {2400, 4800, 9600, 19200, 38400, 76800, 115200};
    // Can be disable if need configuring various other baud rates
  }
  
  //------------------------------------------

endclass: uart_configuration
