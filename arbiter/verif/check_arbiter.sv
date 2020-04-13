// ========================================================
// FILE : check_arbiter.sv
// DESCR: Checker module for round-robin arbiter 
// ========================================================
module check_arbiter 
  (input logic clk,
   input logic 	     rst,
   input logic 	     req0,
   input logic 	     req1,
   input logic 	     req2,
   input logic 	     gnt0,
   input logic 	     gnt1,
   input logic 	     gnt2
  );

   // H1: Every request will remain stable until it is acknowledged
   property request_stable_p(req, gnt);
      @ (posedge clk)
	disable iff (rst)
	  req && !gnt |=> req;
   endproperty

   // H2: Every granted request will be released eventually
   property release_granted_p(req, gnt);
      @ (posedge clk)
	disable iff (rst)
	  req && gnt |-> s_eventually !req;
   endproperty
   
   // ================================ Properties

   // P1: One clock cycle after reset, there is no grant
   property reset_p;
      @ (posedge clk)
	$past(rst) |-> !gnt0 && !gnt1 && !gnt2;
   endproperty

   // P2: There is never more than one grant active simultaneously
   property mutex_p;
      @ (posedge clk) 
	disable iff (rst)
	  gnt0 + gnt1 + gnt2 <= 1;
   endproperty

   // P3: Every request will be granted eventually 
   property request_granted_p(req, gnt);
      @ (posedge clk)
	disable iff (rst)
	  req |-> s_eventually gnt;
   endproperty

   // P4: A grant will remain stable until the corresponding request has been released
   property grant_stable_p(req, gnt);
      @ (posedge clk)
	disable iff (rst)
	  $rose(gnt) |-> gnt s_until !req
   endproperty

   // Here, we use a sequence declaration as a shortcut to express
   // that req is the only active request.
   sequence single_request(req);
      $rose(req) && (req0 + req1 + req2 == 1);
   endsequence;

   // P5: If there are no other requests, the first incoming request
   //     will be granted after one clock cycle
   property grant_single_request_p(req, gnt);
      @ (posedge clk)
	disable iff (rst)
	  single_request(req) |=> gnt;
   endproperty

   // P6: A grant can only be active when there is a corresponding request
   // --------------------------------------------------------------------
   // Note that the textual specification is ambiguous here. We could also
   // use a stronger property than that below, requiring that the grant be
   // deactivated in the same cycle as the request. Instead, we only require
   // this one cycle later. 
   property no_spurious_grant_p(req, gnt);
     @ (posedge clk)
       disable iff (rst)
	 !req |=> !gnt;
   endproperty

   // P7: The arbiter is fair
   // -----------------------   
   // Following the round-robin scheme, the abstract notion of
   // fairness is expressed as follows: For each of the requesting
   // masters, between a request and the corresponding grant, none of
   // the other masters should be given access more than once. We
   // express this using the SVA operator within: The "forbidden"
   // sequence is ($rose(gnt_other) [->2]) (gnt_other going from low
   // to high twice). This sequence should not fit into the sequence
   // (req ##0 gnt [->1]) (request followed by grant). 
   property fair_p(req, gnt, gnt_other1, gnt_other2);
      @ (posedge clk)
	disable iff (rst)
	  not ($rose(gnt_other1) [->2] within (req ##0 gnt [->1])) and
	    not ($rose(gnt_other2) [->2] within (req ##0 gnt [->1]));      
   endproperty
   
   // ================================ Verification directives

   H1_request_stable_0: assume property (request_stable_p(req0, gnt0));
   H1_request_stable_1: assume property (request_stable_p(req1, gnt1));
   H1_request_stable_2: assume property (request_stable_p(req2, gnt2));

   H2_release_granted_0: assume property (release_granted_p(req0, gnt0));
   H2_release_granted_1: assume property (release_granted_p(req1, gnt1));
   H2_release_granted_2: assume property (release_granted_p(req2, gnt2));

   P1_reset: assert property (reset_p);
   P2_mutex: assert property (mutex_p);
   
   P3_request_granted_0: assert property (request_granted_p(req0, gnt0));
   P3_request_granted_1: assert property (request_granted_p(req1, gnt1));
   P3_request_granted_2: assert property (request_granted_p(req2, gnt2));

   P4_grant_stable_0: assert property (grant_stable_p(req0, gnt0));
   P4_grant_stable_1: assert property (grant_stable_p(req1, gnt1));
   P4_grant_stable_2: assert property (grant_stable_p(req2, gnt2));

   P5_single_request_0: assert property (grant_single_request_p(req0, gnt0));
   P5_single_request_1: assert property (grant_single_request_p(req1, gnt1));
   P5_single_request_2: assert property (grant_single_request_p(req2, gnt2));

   P6_no_spurious_grant_0: assert property (no_spurious_grant_p(req0, gnt0));
   P6_no_spurious_grant_1: assert property (no_spurious_grant_p(req1, gnt1));
   P6_no_spurious_grant_2: assert property (no_spurious_grant_p(req2, gnt2));

   P7_fair_0: assert property (fair_p(req0, gnt0, gnt1, gnt2));
   P7_fair_1: assert property (fair_p(req1, gnt1, gnt0, gnt2));
   P7_fair_2: assert property (fair_p(req2, gnt2, gnt0, gnt1));
   
endmodule
