-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "12/01/2020 16:24:08"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          TopLevel
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY TopLevel_vhd_vec_tst IS
END TopLevel_vhd_vec_tst;
ARCHITECTURE TopLevel_arch OF TopLevel_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clock : STD_LOGIC;
SIGNAL HEX0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX3 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX4 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL HEX5 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL inA : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL inB : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL inB_inv : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL KEY : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL LEDR : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL saida : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL saida_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL saidaMegaMux : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SW : STD_LOGIC_VECTOR(9 DOWNTO 0);
COMPONENT TopLevel
	PORT (
	clock : IN STD_LOGIC;
	HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	inA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	inB : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	inB_inv : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	LEDR : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
	saida : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	saida_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	saidaMegaMux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : TopLevel
	PORT MAP (
-- list connections between master ports and signals
	clock => clock,
	HEX0 => HEX0,
	HEX1 => HEX1,
	HEX2 => HEX2,
	HEX3 => HEX3,
	HEX4 => HEX4,
	HEX5 => HEX5,
	inA => inA,
	inB => inB,
	inB_inv => inB_inv,
	KEY => KEY,
	LEDR => LEDR,
	saida => saida,
	saida_PC => saida_PC,
	saidaMegaMux => saidaMegaMux,
	SW => SW
	);

-- clock
t_prcs_clock: PROCESS
BEGIN
LOOP
	clock <= '0';
	WAIT FOR 10000 ps;
	clock <= '1';
	WAIT FOR 10000 ps;
	IF (NOW >= 1000000 ps) THEN WAIT; END IF;
END LOOP;
END PROCESS t_prcs_clock;
END TopLevel_arch;
