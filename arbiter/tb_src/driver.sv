program driver(input clk, output reg req, input gnt);
   integer 	   i;
   integer 	   d;   

   initial begin
      req = 0;
      repeat (5 + $urandom % 20) @ (posedge clk);
      
      for (i=0;i<20;) begin
	 repeat (1) @ (posedge clk);	 
	 if (!req) begin
	    d = 3 + $urandom % 20;
	    repeat (d) @ (posedge clk);
	    req = 1;
	    i = i+1;	    
	 end else begin
	    if (gnt === 1'b1) begin
	       d = 1 + $urandom % 10;
	       repeat (d) @ (posedge clk);
	       req = 0;	       
	    end 
	 end
      end
   end   
endprogram
