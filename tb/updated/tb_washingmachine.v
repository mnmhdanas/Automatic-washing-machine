`timescale 1ms / 1ms

module tb_washingmachine();
  
  reg i_clk,i_lid,i_start,i_cancel,i_coin,i_mode_1,i_mode_2,i_mode_3;
  wire o_idle,o_ready,o_soak,o_wash,o_rinse,o_spin,o_coinreturn,o_waterinlet,o_done;
  
washingmachine DUT(i_clk,i_lid,i_start,i_cancel,i_coin,i_mode_1,i_mode_2,i_mode_3,
                        o_idle,o_ready,o_soak,o_wash,o_rinse,o_spin,o_coinreturn,o_waterinlet,o_done);  
  
  parameter TIMEPERIOD = 4; 
  initial
     begin
       i_clk = 1'b0;
       forever #(TIMEPERIOD/2) i_clk = ~ i_clk; //gives 250hz since 1/4ms = 250hz
     end
  /* Scenario 1 : Mode 1 and lid is opened during wash phase for 8 secs  */
  
    task scenario_1();
	  begin
	    
	    @(posedge i_clk) i_start = 1'b0; i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_1 = 1'b1;
		repeat(75010) @(posedge i_clk); //  with 75010 clock cycle delay, state goes to wash phase 
		repeat(2000)              // 8 secs => 8 * 250 = 2000
		 begin
		  @(posedge i_clk) i_lid = 1'b1;
		 end
		@(posedge i_clk) i_lid = 1'b0;
		 
		wait(DUT.o_done) 
		  @(posedge i_clk);
		  i_mode_1 = 1'b0;
	  end
	endtask
	
  /* Scenario 2 : Mode 2 and lid is opened during rinse phase for 10 seconds  */
  
    task scenario_2();
	  begin
	    @(posedge i_clk) i_start = 1'b0; i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_2 = 1'b1;
		repeat(345010) @(posedge i_clk); //  with 345010 clock cycle delay, state goes to rinse phase 
		repeat(2500)  // 10 secs => 10*250 = 2500
		 begin
		  @(posedge i_clk) i_lid = 1'b1;
		 end
		@(posedge i_clk) i_lid = 1'b0;
		 
		wait(DUT.o_done) 
		  @(posedge i_clk);
		  i_mode_2 = 1'b0;
	  end
	endtask

  /* Scenario 3 : Mode 2 and lid is opened during spin phase for 5 seconds  */
  
    task scenario_3();
	  begin
	    @(posedge i_clk) i_start = 1'b0; i_coin = 1'b1;
		@(posedge i_clk) i_coin = 1'b0; i_mode_2 = 1'b1;
		repeat(465010) @(posedge i_clk);  //  with 465010 clock cycle delay, state goes to rinse phase 
		repeat(1250)  // 5 seconds =>  5 * 250 = 1250
		 begin
		  @(posedge i_clk) i_lid = 1'b1;
		 end
		@(posedge i_clk) i_lid = 1'b0;
		 
		wait(DUT.o_done) 
		  @(posedge i_clk);
		  i_mode_2 = 1'b0;
	  end
	endtask

  /* Scenario 4 : Mode 3 and lid is never opened    so process will complete in 50mins*60= 3000secs = 30,00,000ms */
  
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
	   
	   /* remove comment markers as per your requirement 
       running all below scenarios might need (6840+8+5+10)*1000 = 68,63,000 ms to finish the entire simulation,so you need to be patient */
     //scenario_1;
	   //scenario_2;
	   //scenario_3;
     scenario_4;
	   //scenario_5;
	   //scenario_6;
       
       
       #10000; //10 secs delay not neeeded tho 
       $finish;
     end  
  initial
    begin
      $dumpfile("test.vcd");
      $dumpvars;
    end
endmodule

       
