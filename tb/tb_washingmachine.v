

module tb_washingmachine();
  
  reg i_clk,i_lid,i_start,i_cancel,i_coin,i_mode_1,i_mode_2,i_mode_3;
  wire o_idle,o_ready,o_soak,o_wash,o_rinse,o_spin,o_coinreturn,o_waterinlet,o_done;
  
washingmachine DUT(i_clk,i_lid,i_start,i_cancel,i_coin,i_mode_1,i_mode_2,i_mode_3,
                        o_idle,o_ready,o_soak,o_wash,o_rinse,o_spin,o_coinreturn,o_waterinlet,o_done);  
  
  initial
     begin
       i_clk = 1'b0;
       forever #5 i_clk = ~ i_clk;
     end
  
  /* Scenario 1 : Mode 1 and lid is opened during wash phase for 8 clock cycles  */
  
    task scenario_1();
	  begin
	    
	    @(posedge i_clk) i_start = 1'b0; i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_1 = 1'b1;
		repeat(10) @(posedge i_clk); //  with 10 clock cycle delay, state goes to wash phase 
		repeat(8)
		 begin
		  @(posedge i_clk) i_lid = 1'b1;
		 end
		@(posedge i_clk) i_lid = 1'b0;
		 
		wait(DUT.o_done) 
		  @(posedge i_clk);
		  i_mode_1 = 1'b0;
	  end
	endtask
	
  /* Scenario 2 : Mode 2 and lid is opened during rinse phase for 10 clock cycles  */
  
    task scenario_2();
	  begin
	    @(posedge i_clk) i_start = 1'b0; i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_2 = 1'b1;
		repeat(27) @(posedge i_clk); //  with 27 clock cycle delay, state goes to rinse phase 
		repeat(10)
		 begin
		  @(posedge i_clk) i_lid = 1'b1;
		 end
		@(posedge i_clk) i_lid = 1'b0;
		 
		wait(DUT.o_done) 
		  @(posedge i_clk);
		  i_mode_2 = 1'b0;
	  end
	endtask

  /* Scenario 3 : Mode 2 and lid is opened during spin phase for 5 clock cycles  */
  
    task scenario_3();
	  begin
	    @(posedge i_clk) i_start = 1'b0; i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_2 = 1'b1;
		repeat(37) @(posedge i_clk);
		repeat(5)
		 begin
		  @(posedge i_clk) i_lid = 1'b1;
		 end
		@(posedge i_clk) i_lid = 1'b0;
		 
		wait(DUT.o_done) 
		  @(posedge i_clk);
		  i_mode_2 = 1'b0;
	  end
	endtask

  /* Scenario 4 : Mode 3 and lid is never opened  */
  
    task scenario_4();
	  begin
	    @(posedge i_clk) i_start = 1'b0;i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_3 = 1'b1;
		
		 
		wait(DUT.o_done) 
		  @(posedge i_clk);
		  i_mode_3 = 1'b0;
	  end
	endtask	
	
	/* Scenario 5: Mode 1 and i_cancel during ready phase */
	
	task scenario_5();
	  begin
	    @(posedge i_clk) i_start = 1'b0;i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_1 = 1'b1; i_cancel = 1'b1;
		@(posedge i_clk);
		@(posedge i_clk);
		@(posedge i_clk);
		@(posedge i_clk) i_cancel = 1'b0;
	  end
	endtask
	
	
	/* Scenario 6: Mode 1 and i_cancel during wash phase */
	task scenario_6();
	  begin
	    @(posedge i_clk) i_start = 1'b0;i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_1 = 1'b1;
		repeat(10) @(posedge i_clk); //  with 10 clock cycle delay, state goes to wash phase 
		i_cancel = 1'b1;
		@(posedge i_clk);
		@(posedge i_clk);
		@(posedge i_clk);
		@(posedge i_clk) i_cancel = 1'b0;
	  end
	endtask
	
	
	
  initial
     begin
       {i_lid,i_start,i_cancel,i_coin,i_mode_1,i_mode_2,i_mode_3} = 0;
       @(posedge i_clk) i_start = 1'b1;  //goes to idle state
	   
	   
       scenario_1;
	   scenario_2;
	   scenario_3;
       scenario_4;
	   scenario_5;
	   scenario_6;
       
       
       #100 $finish;
       
       
       
     end  
  initial
    begin
      $dumpfile("test.vcd");
      $dumpvars;
    end
endmodule

       
