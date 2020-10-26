library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
	
	generic(
		dataWidth : natural := 32;   -- cada instrucao possui 32 bits, ou, 4 bytes
		romAddrWidth : natural := 6  -- Numero maximo de enderecos na rom : 63 enderecos
	);
	port(
		clk, rst : in std_logic;
		instrucao : out std_logic_vector((dataWidth - 1) downto 0)
	);
end entity;

architecture comportamento of fetch is
	signal pcOut, proxInst : std_logic_vector((dataWidth - 1) downto 0);
--	signal  : std_logic_vector((romAddrWidth - 1) downto 0);
	signal constanteSoma : std_logic_vector((dataWidth - 1) downto 0) := "00000000000000000000000000000100";

	begin
	
		PC   : entity work.registradorGenerico generic map (larguraDados => dataWidth)
									   		  port map(DIN => proxInst,
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
		
end architecture;