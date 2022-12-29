transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/sanji/Documents/GitHub/VeoPixels {C:/Users/sanji/Documents/GitHub/VeoPixels/Tester.sv}
vlog -sv -work work +incdir+C:/Users/sanji/Documents/GitHub/VeoPixels {C:/Users/sanji/Documents/GitHub/VeoPixels/SingleLEDEncoder.sv}
vlog -sv -work work +incdir+C:/Users/sanji/Documents/GitHub/VeoPixels {C:/Users/sanji/Documents/GitHub/VeoPixels/SingleBinaryEncoder.sv}
vlog -sv -work work +incdir+C:/Users/sanji/Documents/GitHub/VeoPixels {C:/Users/sanji/Documents/GitHub/VeoPixels/MultipleLEDEncoder.sv}

