library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
	
	generic(
		dataWidth : natural := 32;   -- cada instrucao possui 32 bits, ou, 4 bytes
	);
	port(
		clk, rst : in std_logic;
		extendedInst : in std_logic_vector((dataWidth - 1) downto 0);
		andBEQZero : in std_logic;
		instrucao : out std_logic_vector((dataWidth - 1) downto 0)
	);
end entity;

architecture comportamento of fetch is
	signal pcOut, proxInst : std_logic_vector((dataWidth - 1) downto 0);
	signal constanteSoma : std_logic_vector((dataWidth - 1) downto 0) := "00000000000000000000000000000100";
	signal saidaSoma2, bitShiftInst, instrucFinal : std_logic_vector((dataWidth - 1) downto 0);

	begin
	
		PC   : entity work.registradorGenerico generic map (larguraDados => dataWidth)
									   		  port map(DIN => instrucFinal,
												  DOUT => pcOut,
												  ENABLE => '1',
												  CLK => clk,
												  RST => rst);

		ROM  : entity work.ROMMIPS port map (clk => clk,
											 Endereco => pcOut,
											 Dado => instrucao); 
	
		SOMA : entity work.somador generic map (larguraDados => dataWidth)
								   port map (entradaA => constanteSoma,
										     entradaB => pcOut,
											 saida => proxInst);

		SOMAEXT : entity work.somador generic map (larguraDados => dataWidth)
									  port map (entradaA => proxInst,
									  			entradaB => extendedInst,
									  			saida => saidaSoma2);
		
		bitShiftInst <= shift_right(unsigned(saidaSoma2), 2);
													  
		MUX  : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth)
										  port map (entradaA_MUX => proxInst,
										  entradaB_MUX =>  bitShiftInst,
										  seletor_MUX => andBEQZero,
										  saida_MUX => instrucFinal);
		
end architecture;