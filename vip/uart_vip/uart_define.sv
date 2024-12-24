//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : uart_define.sv
// Author        : Le Quang Duy
// Email         : ?
// Date          : 12-Nov-2024
//=============================================================================
// Description   : Define can override by environment
//
//
//
//=============================================================================
`ifndef GUARD_UART_DEFINE__SV
`define GUARD_UART_DEFINE__SV

  `ifndef FORK_GUARD_BEGIN
    `define FORK_GUARD_BEGIN fork begin
  `endif

  `ifndef FORK_GUARD_END
    `define FORK_GUARD_END   fork end
  `endif
  `ifndef UART_STOPBIT_WIDTH
     `define UART_STOPBIT_WIDTH   1 
  `endif
  `ifndef UART_DATA_WIDTH
     `define UART_DATA_WIDTH   5 
  `endif

`endif


