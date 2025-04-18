VIVADO = /media/cotton/HDD0/Xilinx/Vivado/2022.2/bin/vivado

flow :
	$(VIVADO) -mode batch -source tcl/flow.tcl  -nolog -nojournal
test :
	$(VIVADO) -mode batch -source tcl/sim.tcl -nolog -nojournal;\
	cd post_route/xsim/ && ./pattern_tb.sh

image : test
	python3 ./util/convert.py ./post_route/xsim/image.tmp ./post_route/xsim/image.bmp
	
all: test flow

clean:
	rm -rf export_sim