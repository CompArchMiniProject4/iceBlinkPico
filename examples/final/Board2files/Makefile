filename = top
pcf_file = ../Comp_Arch/mp4github/iceBlinkPico/examples/final/Board2files/board2.pcf

build:
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

clean:
	del /s /q $(filename).blif $(filename).asc $(filename).json $(filename).bin
