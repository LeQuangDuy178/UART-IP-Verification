#!/bin/bash -f

setup_dva

## UVM library path
export UVM_HOME=./../uvm_library/uvm-1.2

## Verify root path
export UART_IP_VERIF_PATH=./..

## AHB VIP Design root path
export AHB_VIP_ROOT=$UART_IP_VERIF_PATH/vip/ahb_vip

## UART VIP Design root path
export UART_VIP_ROOT=$UART_IP_VERIF_PATH/vip/uart_vip
