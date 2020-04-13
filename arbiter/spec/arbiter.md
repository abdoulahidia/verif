Specification for round-robin arbiter with three masters
========================================================

Hypotheses / Assumptions
------------------------

H1: Every request will remain stable until it is acknowledged.
H2: Every granted request will be released eventually.

Properties / Assertions
-----------------------

P1: One clock cycle after reset, there is no grant. 
P2: There is never more than one grant active simultaneously (mutual exclusion).
P3: Every request will be granted eventually (non-starvation).
P4: A grant will remain stable until the corresponding request has been released.
P5: If there are no other requests, the first incoming request will be granted
    after one clock cycle.
P6: A grant can only be active when there is a corresponding request (no spurious
    grants).
P7: The arbiter is fair.

