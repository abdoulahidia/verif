###### Define Variables ########################################################
VLIB = vlib
VMAP = vmap
VLOG = vlog
VCOM = vcom

###### Compile Design ##########################################################
compile:
	$(VLIB) work
	$(VMAP) work work
	$(VLOG) ../src/arbiter.sv 
	$(VLOG) -sv -mfcu -cuname my_bind_sva \
		bind.sv check_arbiter.sv

###### Run Formal Analysis #####################################################
check_batch: compile
	qverify -c -od results -do check.tcl

check_gui: compile
	qverify -od results -do check.tcl

check: check_batch


###### Debug Results ###########################################################
debug: 
	qverify results/formal_verify.db &

###### Clean Data ##############################################################
clean:
	qverify_clean
	\rm -rf work modelsim.ini *.wlf *.log replay* transcript *.db
	\rm -rf results
