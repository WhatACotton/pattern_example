VIVADO = /media/cotton/HDD0/Xilinx/Vivado/2022.2/bin/vivado

flow :
	$(VIVADO) -mode batch -source ./tcl/flow.tcl  -nolog -nojournal

all: flow
