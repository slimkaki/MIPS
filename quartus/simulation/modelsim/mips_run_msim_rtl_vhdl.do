transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/somadorULA.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/muxGenerico4x2.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/muxAllLogic2x1.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/constants.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/bitShift.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/LogicAnd.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/extensorSinal.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/RAM.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/muxGenerico2x1.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/bancoRegistradores.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/ROMMIPS.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/registradorGenerico.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/somador.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/UnidadeControleULA.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/ULA.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/fetch.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/UnidadeControle.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/FluxoDados.vhd}
vcom -2008 -work work {/home/rafaelalmada/Documents/MIPS/quartus/CPU.vhd}

