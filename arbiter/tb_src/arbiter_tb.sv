module tb_arbiter ();

   logic  clk, rst;    
   logic  req0, req1, req2;
   logic  gnt0, gnt1, gnt2;

   // Connect the DUT
   arbiter U (.*);   
   
   // Clock generator
   always #1 clk = ~clk;

   // Test stimuli driver
   driver drv0(clk, req0, gnt0);
   driver drv1(clk, req1, gnt1);
   driver drv2(clk, req2, gnt2);
   
   initial begin
      clk = 0;
      rst = 1;
      #10 rst = 0;
      #400 $finish;
   end 
endmodule
