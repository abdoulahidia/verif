vlog -sv -mfcu -cuname my_bind_sva bind.sv check_arbiter.sv
do constraints.tcl
formal compile -d arbiter -cuname my_bind_sva
formal verify -init init
