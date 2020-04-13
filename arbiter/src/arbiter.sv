// ========================================================
// FILE : arbiter.sv
// DESCR: Round-robin arbiter with three masters. 
// ========================================================
module arbiter (input  logic clk,  // clock 
		input logic  rst,  // reset
		input logic  req0, // request inputs
		input logic  req1,
		input logic  req2, 
		output logic gnt0, // grant outputs
		output logic gnt1,
		output logic gnt2
		);

   // Ongoing tells us if one of the masters occupies the resource
   logic 		     ongoing;
   assign ongoing = gnt0 || gnt1 || gnt2;

   // This signal goes high when the active master releases the resource
   logic 		     released;
   assign released = (gnt0 && !req0) || (gnt1 && !req1) || (gnt2 && !req2);
      
   always @(posedge clk) begin
      if (rst) begin
	 {gnt0, gnt1, gnt2} <= '0;
      end else begin
	 if (!ongoing || released) begin

	    // priority 0 > 1 > 2
	    if (req0) begin
	       {gnt0, gnt1, gnt2} <= 3'b100;
	    end else if (req1) begin
	       {gnt0, gnt1, gnt2} <= 3'b010;
	    end else if (req2) begin
	       {gnt0, gnt1, gnt2} <= 3'b001;
	    end else
	      {gnt0, gnt1, gnt2} <= 3'b000;
	 end // if (!ongoing || released)	 
      end // else: !if(rst)
   end // always @ (posedge clk)

endmodule
