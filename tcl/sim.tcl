# step#0: Define output directory location.
set top_module_name pattern_hdmi
set outputDir ./synth_tmp
file mkdir $outputDir


set_part xc7z020clg400-1
# step#1: Setup design sources and constraints.
read_verilog -sv [ glob ./src/new/*.sv ]
read_verilog -sv [ glob ./src/tb/*.sv ]

read_xdc ./src/const/pattern.xdc
read_vhd -library xil_defaultlib [ glob ./src/imports/src/lib/*.vhd ]
read_vhd ./src/imports/src/rgb2dvi.vhd

set_property top top [current_fileset]
set_property top pattern_tb [current_fileset -simset]
# 
#read_verilog [ glob ./ip/pll/*.v ]

# step#2: Run synthesis, report utilization and timing estimates, write checkpoint design.
synth_ip [get_ips pll] -force

synth_design -top $top_module_name -verilog_define SYNTHESIS
write_checkpoint -force $outputDir/post_synth
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_power -file $outputDir/post_synth_power.rpt
report_clock_interaction -delay_type min_max -file $outputDir/post_synth_clock_interaction.rpt
report_high_fanout_nets -fanout_greater_than 200 -max_nets 50 -file $outputDir/post_synth_high_fanout_nets.rpt

# step#3: Run placement and logic optimization, report utilization and timing estimates, write checkpoint design.

opt_design
place_design
phys_opt_design
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt


# step#4: Run router, report actual utilization and timing, write checkpoint design, run drc, write verilog and xdc out.


route_design
write_checkpoint -force $outputDir/post_route
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -max_paths 100 -path_type summary -slack_lesser_than 0 -file $outputDir/post_route_setup_timing_violations.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/top_impl_netlist.v
write_xdc -no_fixed_only -force $outputDir/top_impl.xdc

update_compile_order -fileset sim_1
set_property top pattern_tb [current_fileset -simset]

export_simulation -force -simulator xsim -directory ./post_route -runtime 20000000ns -define SYNTHESIS
