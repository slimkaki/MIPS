library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
	
	generic(
		dataWidth : natural := 32   -- cada instrucao possui 32 bits, ou, 4 bytes
	);
	port(
		clk, rst : in std_logic;
		extendedInst : in std_logic_vector((dataWidth - 1) downto 0);
		andBEQZero, muxJUMP, bne, jr : in std_logic;
		reg_jr : in std_logic_vector((dataWidth-1) downto 0);
		instrucao : out std_logic_vector((dataWidth - 1) downto 0);
		saida_PC : out std_logic_vector((dataWidth - 1) downto 0)
	);
end entity;

architecture comportamento of fetch is
	signal pcOut, proxInst : std_logic_vector((dataWidth - 1) downto 0);
	signal constanteSoma : std_logic_vector((dataWidth - 1) downto 0) := "00000000000000000000000000000100";
	signal saidaSoma2, bitShift3, instrucMuxBEQ, instrucFinal : std_logic_vector((dataWidth - 1) downto 0);
	signal bitShiftInst1 : std_logic_vector(25 downto 0);
	signal jumpCaseInstruct : std_logic_vector((dataWidth-1) downto 0);
	signal barramentoInstrucao : std_logic_vector((dataWidth-1) downto 0);
	signal saidaJR, saidaBNE : std_logic_vector((dataWidth-1) downto 0);

	begin
	
		PC   : entity work.registradorGenerico generic map (larguraDados => dataWidth)
									   		  port map(DIN => instrucFinal,
												  DOUT => pcOut,
												  ENABLE => '1',
												  CLK => clk,
												  RST => rst);
		
		-- colocar a ROM no fluxo de dados para poder se comunicar com o shiftRight1
		ROM  : entity work.ROMMIPS port map (clk => clk,
											 Endereco => pcOut,
											 Dado => instrucao);
											 
		barramentoInstrucao <= instrucao;
		saida_PC <= pcOut;
		-- pc_in <= instrucFinal;
		
		shiftRightImedJump : entity work.bitShift generic map (dataWidth => 26)
														port map (clock => clk,
													 entrada => barramentoInstrucao(25 downto 0),
													 saida => bitShiftInst1);
	
		SOMA : entity work.somador generic map (larguraDados => dataWidth)
								   port map (entradaA => constanteSoma,
										     entradaB => pcOut,
											 saida => proxInst);
		
		shiftRightImedExt : entity work.bitShift generic map (dataWidth => dataWidth)
										  port map(clock => clk,
												   entrada => extendedInst,
												   saida => bitShift3);
		
		SOMASIGEXT : entity work.somador generic map (larguraDados => dataWidth)
									  port map (entradaA => proxInst,
									  			entradaB => bitShift3,
									  			saida => saidaSoma2);
													  
		MUXBEQ  : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth) -- JUMP NORMAL
										  port map (entradaA_MUX => proxInst,
										  			entradaB_MUX =>  saidaSoma2,
										  			seletor_MUX => andBEQZero,
										  			saida_MUX => instrucMuxBEQ);

		MUXJR  : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth)
											port map (entradaA_MUX => instrucMuxBEQ,
													  entradaB_MUX => reg_jr,
													  seletor_MUX => jr,
													  saida_MUX => saidaJR);

		MUXBNE : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth)
											port map (entradaA_MUX => saidaJR,
													  entradaB_MUX => saidaSoma2,
													  seletor_MUX => bne,
													  saida_MUX => saidaBNE);
		

		jumpCaseInstruct(31 downto 28) <= proxInst(31 downto 28);
		jumpCaseInstruct(25 downto 0) <= bitShiftInst1(25 downto 0);
		jumpCaseInstruct(27 downto 26) <= "00";

		PROX_PC : entity work.muxGenerico2x1 generic map (larguraDados => dataWidth)
											 port map (entradaA_MUX => saidaBNE,
											 		   entradaB_MUX => jumpCaseInstruct,
											 		   seletor_MUX => muxJUMP,
														saida_MUX => instrucFinal);
													
		
end architecture;