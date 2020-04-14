// ========================================================
// FILE : arbiter.sv
// DESCR: Round-robin arbiter with three masters. 
// ========================================================

module arbiter ( clk, rst, req2, req1, req0, gnt2, gnt1, gnt0);
	input           clk;    
	input           rst;      
	input           req2;   
	input           req1;   
	input           req0;     
	output          gnt2;   
	output          gnt1;   
	output          gnt0;   
	
	//--------------Internal Registers----------------------
	wire    [1:0]   gnt       ;   
	wire            comreq    ; 
	wire            beg       ;
	wire   [1:0]    lgnt      ;
	wire            lcomreq   ;
	reg             lgnt0     ;
	reg             lgnt1     ;
	reg             lgnt2     ;
	reg             lasmask   ;
	reg             lmask0    ;
	reg             lmask1    ;
	reg             ledge     ;
	 // Ongoing tells us if one of the masters occupies the resource
	   logic              ongoing;
	  always@(negedge clk) begin
		ongoing = gnt0 || gnt1 || gnt2;  end
	  // This signal goes high when the active master releases the resource
	   logic              released;
	  always@(negedge clk) begin  
		released = (gnt0 && !req0) || (gnt1 && !req1) || (gnt2 && !req2); end 
	  
	//--------------My--Code----------------------- 
	always @ (posedge clk)
	if (rst) begin
	  lgnt0 <= 0;
	  lgnt1 <= 0;
	  lgnt2 <= 0;
	end else begin                                     
	  lgnt0 <=(~lcomreq & ~lmask1 & ~lmask0 &  ~req2 & ~req1 & req0)
			| (~lcomreq & ~lmask1 &  lmask0 &   ~req2 &  req0)
			| (~lcomreq &  lmask1 & ~lmask0 &    req0)
			| (~lcomreq &  lmask1 &  lmask0 & req0  )
			| ( lcomreq & lgnt0 );
	  lgnt1 <=(~lcomreq & ~lmask1 & ~lmask0 &  req1)
			| (~lcomreq & ~lmask1 &  lmask0 & ~req2 &  req1 & ~req0)
			| (~lcomreq &  lmask1 & ~lmask0 &  req1 & ~req0)
			| (~lcomreq &  lmask1 &  lmask0 &  req1 & ~req0)
			| ( lcomreq &  lgnt1);
	  lgnt2 <=(~lcomreq & ~lmask1 & ~lmask0 &  req2  & ~req1)
			| (~lcomreq & ~lmask1 &  lmask0 &  req2)
			| (~lcomreq &  lmask1 & ~lmask0 & &  req2  & ~req1 & ~req0)
			| (~lcomreq &  lmask1 &  lmask0 &  req2 & ~req1 & ~req0)
			| ( lcomreq &  lgnt2);
	
	end 
	
	//----------------------------------------------------
	// lasmask state machine.
	//----------------------------------------------------
	  assign beg = (req2 | req1 | req0) & ~lcomreq;
	always @ (posedge clk)
	begin                                     
	  lasmask <= (beg & ~ledge & ~lasmask);
	  ledge   <= (beg & ~ledge &  lasmask) 
			  |  (beg &  ledge & ~lasmask);
	end 
	
	//----------------------------------------------------
	// comreq logic.
	//----------------------------------------------------
	assign lcomreq =( req2 & lgnt2 )
					| ( req1 & lgnt1 )
					| ( req0 & lgnt0 );
	
	//----------------------------------------------------
	// Encoder logic.
	//----------------------------------------------------
	  assign  lgnt =  {( lgnt2 | lgnt1)};
	
	//----------------------------------------------------
	// lmask register.
	//----------------------------------------------------
	always @ (posedge clk )
	if( rst ) begin
	  lmask1 <= 0;
	  lmask0 <= 0;
	end else if(lasmask) begin
	  lmask1 <= lgnt[1];
	  lmask0 <= lgnt[0];
	end else begin
	  lmask1 <= lmask1;
	  lmask0 <= lmask0;
	end 
	
	assign comreq = lcomreq;
	assign gnt    = lgnt;
	//----------------------------------------------------
	// Drive the outputs
	//----------------------------------------------------
	
	assign gnt2   = lgnt2;
	assign gnt1   = lgnt1;
	assign gnt0   = lgnt0;
	
	  always@(negedge clk) begin if(~rst) begin 
		if(gnt1==gnt2==gnt0)  begin
		  assert (gnt2 && gnt0 && gnt1 )
			begin
			$display(" assertion error multiple resources allocated"); end  
			else 
			  begin  $display("assertion passed single resource allocated");
			  end
	  end
	  end
	  end
	  
	  
	  ////////////////////////////////////////////////////////
	  
	  
	  
	  
	  
	 /////////////////////////////////////////////////////////////
	  
	  always@(negedge clk) begin
		if(rst==1) begin
		  assert(gnt0|gnt1|gnt2)
			begin $display("assertion error reset condition failed "); end
		  else begin
			$display("assertion passed for reset condition");
		  end
		end
	  end 
	  
	  ////////////////////////////////////////////////////
		  always@(negedge clk) begin
			if(ongoing==1) begin
		  assert(gnt0||gnt1||gnt2)
			begin $display("assertion passed for ongoing condition"); end 
		  else begin
			$display("assertion failed for ongoing condition");
		  end
					 end
					 end
	 ///////////////////////////////////////////////
	  logic rel0=(gnt0 && !req0);
	  logic rel1= (gnt1 && !req1) ;
	  logic rel2=(gnt2 && !req2);
	  always@(negedge clk) begin
	   rel0=(gnt0 && !req0);
	   rel1= (gnt1 && !req1) ;
		rel2=(gnt2 && !req2); end 
	  
	  always@(posedge clk) begin
			if(released ==1) begin
			  assert(rel0 || rel1 || rel2)
			begin $display("assertion passed for relese condition"); end 
		  else begin
			$display("assertion failed for relese condition time=%t",$time);
		  end
					 end
					 end
	  
					 
					 
	 endmodule
	
	
	
