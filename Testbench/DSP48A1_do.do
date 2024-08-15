vlib work
vlog ../RTL/mux_with_reg.v ../RTL/DSP48A1.v DSP48A1_tb.v
vsim -voptargs=+acc work.DSP48A1_tb
add wave -color White CLK
add wave -expand -group {Clock Enable} -color Gray80 CEA
add wave -expand -group {Clock Enable} -color Gray80 CEB
add wave -expand -group {Clock Enable} -color Gray80 CEC
add wave -expand -group {Clock Enable} -color Gray80 CECARRYIN
add wave -expand -group {Clock Enable} -color Gray80 CED
add wave -expand -group {Clock Enable} -color Gray80 CEM
add wave -expand -group {Clock Enable} -color Gray80 CEOPMODE
add wave -expand -group {Clock Enable} -color Gray80 CEP
add wave -expand -group Reset -color Magenta RSTA
add wave -expand -group Reset -color Magenta RSTB
add wave -expand -group Reset -color Magenta RSTC
add wave -expand -group Reset -color Magenta RSTCARRYIN
add wave -expand -group Reset -color Magenta RSTD
add wave -expand -group Reset -color Magenta RSTM
add wave -expand -group Reset -color Magenta RSTOPMODE
add wave -expand -group Reset -color Magenta RSTP
add wave -color White -radix binary OPMODE
quietly virtual function -install /DSP48A1_tb -env /DSP48A1_tb/#INITIAL#53 { &{D, A, B }} D_A_B
add wave -expand -group Inputs -radix unsigned D_A_B
add wave -expand -group Inputs -radix unsigned D
add wave -expand -group Inputs -radix unsigned B
add wave -expand -group Inputs -radix unsigned A
add wave -expand -group Inputs -radix unsigned C
add wave CARRYIN
add wave -expand -group Output -color Yellow -radix unsigned M
add wave -expand -group Output -color Yellow -radix unsigned P
add wave -expand -group Output -color Yellow CARRYOUT
add wave -expand -group Output -color Yellow CARRYOUTF
add wave -expand -group {Cascade Ports} BCIN
add wave -expand -group {Cascade Ports} -radix unsigned PCIN
add wave -expand -group {Cascade Ports} -color Yellow -radix unsigned BCOUT
add wave -expand -group {Cascade Ports} -color Yellow -radix unsigned PCOUT
run -all