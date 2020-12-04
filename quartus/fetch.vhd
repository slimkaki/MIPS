library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
	
	generic(
		dataWidth : natural := 32   -- cada instrucao possui 32 bits
	);
	port(
		clk, rst : in std_logic;
		extendedInst : in std_logic_vector((dataWidth - 1) downto 0);
		andBEQZero, bne, jr : in std_logic;
		muxJUMP : in std_logic_vector(1 downto 0);
		reg_jr : in std_logic_vector((dataWidth-1) downto 0);
		instrucao : out std_logic_vector((dataWidth - 1) downto 0);
		saida_PC : out std_logic_vector((dataWidth - 1) downto 0)
	);
end entity;

architecture comportamento of fetch is
	signal pcOut, proxInst : std_logic_vector((dataWidth - 1) downto 0);
	signal constanteSoma : std_logic_vector((dataWidth - 1) downto 0) := "00000000000000000000000000000100";
	signal saidaSoma2, bitShift3, instrucMuxBEQ, instrucFinal, preInstruc, jumpAddr : std_logic_vector((dataWidth - 1) downto 0);
	signal jumpCaseInstruct : std_logic_vector((dataWidth-1) downto 0);
	signal saidaJR, saidaBNE : std_logic_vector((dataWidth-1) downto 0);

	begin
	   -- Program counter que registra o endereco da instrucao atual
		PC   : entity work.registradorGenerico generic map (larguraDados => dataWidth)
									   		  port map(DIN => instrucFinal,
												  DOUT => pcOut,
												  ENABLE => '1',
												  CLK => clk,
												  RST => rst);
		
		-- Memoria ROM ou memoria de instrucoes
		-- recebe a saida do program counter (proxima instrucao)
		-- retorna a instrucao (32 bits)
		ROM  : entity work.ROMMIPS port map (clk => clk,
											 Endereco => pcOut,
											 Dado => instrucao);
											 
		-- Salvando o output do Program Counter para uso no Fluxo de Dados	 
		saida_PC <= pcOut;
		
		-- Soma: PC + 4
		SOMA : entity work.somador generic map (larguraDados => dataWidth)
								   port map (entradaA => constanteSoma,
										     entradaB => pcOut,
											 saida => proxInst);
		
		-- Operacao de bitshift de 2 bits para esquerdas
		-- operacao necessaria para o imediato da instrucao
		shiftLeftImedExt : entity work.bitShift generic map (dataWidth => dataWidth)
										  port map(clock => clk,
												   entrada => extendedInst,
												   saida => bitShift3);
		
		-- Soma da instrucao atual com a saida do bitshift anterior
		SOMASIGEXT : entity work.somador generic map (larguraDados => dataWidth)
									  port map (entradaA => proxInst,
									  			entradaB => bitShift3,
									  			saida => saidaSoma2);
		
		-- MUX para o caso de BEQ
		-- Seleciona entre a proxima instrucao e a saida da soma entre a proxima instrucao e o bitshift
		MUXBEQ  : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth)
										  port map (entradaA_MUX => proxInst,
										  			entradaB_MUX =>  saidaSoma2,
										  			seletor_MUX => andBEQZero,
										  			saida_MUX => instrucMuxBEQ);
		
		-- MUX para o caso JR
		-- Seleciona entre a proxima instrucao e o valor da saida do registrador 1 do banco de registradores
		-- (especificado na propria instrucao JR)
		MUXJR  : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth)
											port map (entradaA_MUX => proxInst,
													  entradaB_MUX => reg_jr,
													  seletor_MUX => jr,
													  saida_MUX => saidaJR);
		-- MUX para o caso de BNE
		-- Seleciona entre a proxima instrucao e a saida da soma entre a proxima instrucao e o bitshift
		MUXBNE : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth)
											port map (entradaA_MUX => proxInst,
													  entradaB_MUX => saidaSoma2,
													  seletor_MUX => bne,
													  saida_MUX => saidaBNE);
		
		-- Concatenacao de bits para formar o endereco do jump
		jumpCaseInstruct(31 downto 28) <= proxInst(31 downto 28);
		jumpCaseInstruct(27 downto 2) <= instrucao(25 downto 0);
		jumpCaseInstruct(1 downto 0) <= "00";
		
		-- MUX para escolher qual o proximo passo do program counter:
		-- pode ser passar para a proxima instrucao (PC + 4)
		-- pode ser realizar o BEQ
		-- pode ser ir para o endereco do jr
		-- pode ser realizar o BNE
		-- pode ser realizar um jump apenas
		PROX_PC : entity work.muxGenerico4x2_32
											 port map (entrada0 => instrucMuxBEQ,
											 		   entrada1 => saidaJR,
														entrada2 => saidaBNE,
														entrada3 => jumpCaseInstruct,
											 		   seletor_MUX => muxJUMP,
														saida_MUX => instrucFinal);
													
		
end architecture;