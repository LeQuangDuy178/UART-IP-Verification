// Coverage property target
ahb_transaction		ahb_trans_cov;

covergroup ahb_group;

  ahb_data: coverpoint ahb_trans_cov.data {
    bins data_cov = {[8'h00:8'hff]};
  }

  ahb_addr: coverpoint ahb_trans_cov.addr {
    // This property change depending on IP reg addr
    bins MDR_addr = {'h000};
    bins DLL_addr = {'h004};
    bins DLH_addr = {'h008};
    bins LCR_addr = {'h00c};
    bins IER_addr = {'h010};
    bins FSR_addr = {'h014};
    bins TBR_addr = {'h018};
    bins RBR_addr = {'h1c};
    //bins reserved_addr = {*}; // 0x020 -> 0x3FF
  }

  ahb_xact_type: coverpoint ahb_trans_cov.xact_type {
    bins ahb_write = {ahb_transaction::WRITE};
    bins ahb_read = {ahb_transaction::READ};
  }

  ahb_xfer_size: coverpoint ahb_trans_cov.xfer_size {
    bins size_8_bit = {ahb_transaction::SIZE_8BIT};
    bins size_16_bit = {ahb_transaction::SIZE_16BIT};
    bins size_32_bit = {ahb_transaction::SIZE_32BIT};
    bins size_64_bit = {ahb_transaction::SIZE_64BIT};
    bins size_128_bit = {ahb_transaction::SIZE_128BIT};
    bins size_256_bit = {ahb_transaction::SIZE_256BIT};
    bins size_512_bit = {ahb_transaction::SIZE_512BIT};
    bins size_1024_bit = {ahb_transaction::SIZE_1024BIT};
  }

  ahb_burst_type: coverpoint ahb_trans_cov.burst_type {
    bins burst_single = {ahb_transaction::SINGLE};
    bins burst_incr = {ahb_transaction::INCR};
    bins burst_wrap4 = {ahb_transaction::WRAP4};
    bins burst_incr4 = {ahb_transaction::INCR4};
    bins burst_wrap8 = {ahb_transaction::WRAP8};
    bins burst_incr8 = {ahb_transaction::INCR8};
    bins burst_wrap16 = {ahb_transaction::WRAP16};
    bins burst_incr16 = {ahb_transaction::INCR16};
  }

  ahb_prot: coverpoint ahb_trans_cov.prot {
    bins no_protect = {4'b0000};
    bins is_protect = {4'b0001};
  }

  ahb_lock: coverpoint ahb_trans_cov.lock {
    bins no_lock = {1'b0};
    bins is_lock = {1'b1};
  }

  // With user-defined crosspoint
  cross_ahb_reg_access_feature: cross ahb_addr, ahb_xact_type;

  cross_ahb_transfer_feature: cross ahb_xfer_size, ahb_burst_type, ahb_xact_type;

  cross_ahb_additional_feature: cross ahb_lock, ahb_prot;

endgroup
