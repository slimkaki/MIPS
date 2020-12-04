library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FluxoDados is
    generic(
        instructWidth : natural := 32
    );
    port(
        clk, rst        :  in std_logic;
        palavraControle :  in std_logic_vector(15 downto 0);
        opCodeFunct     :  out std_logic_vector(11 downto 0);
        saida_PC        :  out std_logic_vector(31 downto 0);
        mSaidaULA, saidaMegaMux : out std_logic_vector(31 downto 0)
    );
end entity;

architecture comportamento of FluxoDados is
	constant zero : std_logic_vector(31 downto 0) := (others => '0');
    signal endA, endB, endC : std_logic_vector(4 downto 0);
    signal outA, outB : std_logic_vector((instructWidth - 1) downto 0);
    signal flagZ : std_logic;
    signal saidaULA : std_logic_vector((instructWidth - 1) downto 0);
    signal extendInstruc : std_logic_vector(15 downto 0);
    signal saidaSigExt, sigExtZero : std_logic_vector((instructWidth - 1) downto 0);
    signal andBEQZero, andBNEZero : std_logic;
    signal saida_MUXimed : std_logic_vector((instructWidth-1) downto 0);
    signal saidaRAM : std_logic_vector((instructWidth-1) downto 0);
    signal saida_MUXulaRAM : std_logic_vector((instructWidth-1) downto 0);
    signal saida_MUXRd : std_logic_vector(4 downto 0);
    signal pc_in, sigSaida_PC : std_logic_vector(instructWidth-1 downto 0);
    signal saidaR31, saida_mux_jr : std_logic_vector(4 downto 0);
	 signal saidaULA_final, saida_lui, saida_ext : std_logic_vector(31 downto 0);
	 signal vai_1_all : std_logic_vector((instructWidth-1) downto 0);  
    signal entradaB_ULA_inv : std_logic_vector(31 downto 0);
	 signal overflow_slt : std_logic;
	 signal result_slt, instrucao : std_logic_vector(31 downto 0);
	 
	 
	 -- Dividindo a palavra controle
    alias BNE           : std_logic is palavraControle(15);
    alias muxJR         : std_logic is palavraControle(14);
    alias muxR31        : std_logic is palavraControle(13);
    alias muxJUMP       : std_logic_vector is palavraControle(12 downto 11);
    alias muxRtRd       : std_logic is palavraControle(10);
    alias habEscritaReg : std_logic is palavraControle(9);
    alias muxRtImed     : std_logic is palavraControle(8);
    alias ULActrl         : std_logic_vector(2 downto 0) is palavraControle(7 downto 5);
    alias muxULAMem     : std_logic_vector(1 downto 0) is palavraControle(4 downto 3);
    alias BEQ           : std_logic is palavraControle(2);
    alias habLeituraMEM : std_logic is palavraControle(1);
    alias habEscritaMEM : std_logic is palavraControle(0);

    begin
		  -- Instruction Fetch
        fetchInstruction : entity work.fetch generic map (dataWidth => instructWidth)
                                             port map(clk => clk,
                                                      rst => rst,
                                                      extendedInst => saidaSigExt,
                                                      andBEQZero => andBEQZero,
                                                      muxJUMP =>  muxJUMP,
                                                      bne => andBNEZero,
                                                      jr => muxJR,
                                                      reg_jr => outA,
                                                      instrucao => instrucao,
                                                      saida_PC => sigSaida_PC);
		  -- Program Counter para passar para o output
		  saida_PC <= sigSaida_PC;

		  -- Separando a instrucao 
		  -- em OpCode + Funct
        opCodeFunct(11 downto 6) <= instrucao(31 downto 26);
        opCodeFunct(5 downto 0)  <= instrucao(5 downto 0);
		  
		  -- Endereco dos registradores selecionados
        endA                     <= instrucao(25 downto 21); -- rs
        endB                     <= instrucao(20 downto 16); -- rt
        endC                     <= instrucao(15 downto 11); -- rd
		  
		  -- Imediato das instrucoes do tipo I
        extendInstruc            <= instrucao(15 downto 0);
		  
		  -- MUX JR para definir entrada no banco de registradores no primeiro endereco
			mux_JR : entity work.muxGenerico2x1 generic map (larguraDados => 5)
																port map (entradaA_MUX  => endA,
                                                          entradaB_MUX  => std_logic_vector(TO_UNSIGNED(31, 5)),
                                                          seletor_MUX   => muxJR,
                                                          saida_MUX     => saida_mux_jr);
		  -- Banco de registradores
        BancoReg : entity work.bancoRegistradores port map (clk => clk,
                                                            enderecoA => saida_mux_jr,
                                                            enderecoB => endB,
                                                            enderecoC => saidaR31,
                                                            dadoEscritaC => saida_MUXulaRAM,
                                                            escreveC => habEscritaReg,
                                                            saidaA => outA,
                                                            saidaB => outB);
		  -- inverte a entrada B da ULA e soma 1 para os casos em que
		  -- ULActrl seleciona a inversao de B
        soma1inv : entity work.somador generic map(larguraDados => instructWidth)
                                       port map(entradaA => (not saida_MUXimed),
                                                entradaB => "00000000000000000000000000000001",
                                                saida => entradaB_ULA_inv);
		  -- saida de overflow da ULA
		  overflow_slt <= vai_1_all(30) xor vai_1_all(31);
		  
		  -- Sinal usado para o caso da instrucao selecionar SLT
		  -- concatena 31 zeros com o xor da saida da ULA e o overflow
		  result_slt <= "0000000000000000000000000000000" & (saidaULA(31) xor overflow_slt);
		  
		  -- ULA bit a bit
        ULA_bit0   : entity work.ULA port map (entradaA => outA(0),
                                               entradaB => saida_MUXimed(0),
                                               seletor => ULActrl,
                                               vem_1 => '0',
															  vai_1 => vai_1_all(0),
                                               saida => saidaULA(0),
                                               entradaB_inv => entradaB_ULA_inv(0));

        ULA_bit1   : entity work.ULA port map (entradaA => outA(1),
                                                entradaB => saida_MUXimed(1),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(0),
                                                vai_1 => vai_1_all(1),
                                                saida => saidaULA(1),
                                                entradaB_inv => entradaB_ULA_inv(1));

        ULA_bit2   : entity work.ULA port map (entradaA => outA(2),
                                                entradaB => saida_MUXimed(2),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(1),
                                                vai_1 => vai_1_all(2),
                                                saida => saidaULA(2),
                                                entradaB_inv => entradaB_ULA_inv(2));
                                                
        ULA_bit3   : entity work.ULA port map (entradaA => outA(3),
                                                entradaB => saida_MUXimed(3),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(2),
                                                vai_1 => vai_1_all(3),
                                                saida => saidaULA(3),
                                                entradaB_inv => entradaB_ULA_inv(3));

        ULA_bit4   : entity work.ULA port map (entradaA => outA(4),
                                                entradaB => saida_MUXimed(4),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(3),
                                                vai_1 => vai_1_all(4),
                                                saida => saidaULA(4),
                                                entradaB_inv => entradaB_ULA_inv(4));

        ULA_bit5   : entity work.ULA port map (entradaA => outA(5),
                                                entradaB => saida_MUXimed(5),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(4),
                                                vai_1 => vai_1_all(5),
                                                saida => saidaULA(5),
                                                entradaB_inv => entradaB_ULA_inv(5));

        ULA_bit6   : entity work.ULA port map (entradaA => outA(6),
                                                entradaB => saida_MUXimed(6),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(5),
                                                vai_1 => vai_1_all(6),
                                                saida => saidaULA(6),
                                                entradaB_inv => entradaB_ULA_inv(6));

        ULA_bit7   : entity work.ULA port map (entradaA => outA(7),
                                                entradaB => saida_MUXimed(7),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(6),
                                                vai_1 => vai_1_all(7),
                                                saida => saidaULA(7),
                                                entradaB_inv => entradaB_ULA_inv(7));

        ULA_bit8   : entity work.ULA port map (entradaA => outA(8),
                                                entradaB => saida_MUXimed(8),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(7),
                                                vai_1 => vai_1_all(8),
                                                saida => saidaULA(8),
                                                entradaB_inv => entradaB_ULA_inv(8));

        ULA_bit9   : entity work.ULA port map (entradaA => outA(9),
                                                entradaB => saida_MUXimed(9),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(8),
                                                vai_1 => vai_1_all(9),
                                                saida => saidaULA(9),
                                                entradaB_inv => entradaB_ULA_inv(9));

        ULA_bit10   : entity work.ULA port map (entradaA => outA(10),
                                                entradaB => saida_MUXimed(10),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(9),
                                                vai_1 => vai_1_all(10),
                                                saida => saidaULA(10),
                                                entradaB_inv => entradaB_ULA_inv(10));

        ULA_bit11   : entity work.ULA port map (entradaA => outA(11),
                                                entradaB => saida_MUXimed(11),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(10),
                                                vai_1 => vai_1_all(11),
                                                saida => saidaULA(11),
                                                entradaB_inv => entradaB_ULA_inv(11));

        ULA_bit12   : entity work.ULA port map (entradaA => outA(12),
                                                entradaB => saida_MUXimed(12),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(11),
                                                vai_1 => vai_1_all(12),
                                                saida => saidaULA(12),
                                                entradaB_inv => entradaB_ULA_inv(12));

        ULA_bit13   : entity work.ULA port map (entradaA => outA(13),
                                                entradaB => saida_MUXimed(13),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(12),
                                                vai_1 => vai_1_all(13),
                                                saida => saidaULA(13),
                                                entradaB_inv => entradaB_ULA_inv(13));

        ULA_bit14   : entity work.ULA port map (entradaA => outA(14),
                                                entradaB => saida_MUXimed(14),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(13),
                                                vai_1 => vai_1_all(14),
                                                saida => saidaULA(14),
                                                entradaB_inv => entradaB_ULA_inv(14));
                                                
        ULA_bit15   : entity work.ULA port map (entradaA => outA(15),
                                                entradaB => saida_MUXimed(15),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(14),
                                                vai_1 => vai_1_all(15),
                                                saida => saidaULA(15),
                                                entradaB_inv => entradaB_ULA_inv(15));
                                                
        ULA_bit16   : entity work.ULA port map (entradaA => outA(16),
                                                entradaB => saida_MUXimed(16),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(15),
                                                vai_1 => vai_1_all(16),
                                                saida => saidaULA(16),
                                                entradaB_inv => entradaB_ULA_inv(16));
                                                
        ULA_bit17   : entity work.ULA port map (entradaA => outA(17),
                                                entradaB => saida_MUXimed(17),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(16),
                                                vai_1 => vai_1_all(17),
                                                saida => saidaULA(17),
                                                entradaB_inv => entradaB_ULA_inv(17));

        ULA_bit18   : entity work.ULA port map (entradaA => outA(18),
                                                entradaB => saida_MUXimed(18),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(17),
                                                vai_1 => vai_1_all(18),
                                                saida => saidaULA(18),
                                                entradaB_inv => entradaB_ULA_inv(18));

        ULA_bit19   : entity work.ULA port map (entradaA => outA(19),
                                                entradaB => saida_MUXimed(19),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(18),
                                                vai_1 => vai_1_all(19),
                                                saida => saidaULA(19),
                                                entradaB_inv => entradaB_ULA_inv(19));

        ULA_bit20   : entity work.ULA port map (entradaA => outA(20),
                                                entradaB => saida_MUXimed(20),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(19),
                                                vai_1 => vai_1_all(20),
                                                saida => saidaULA(20),
                                                entradaB_inv => entradaB_ULA_inv(20));

        ULA_bit21   : entity work.ULA port map (entradaA => outA(21),
                                                entradaB => saida_MUXimed(21),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(20),
                                                vai_1 => vai_1_all(21),
                                                saida => saidaULA(21),
                                                entradaB_inv => entradaB_ULA_inv(21));

        ULA_bit22   : entity work.ULA port map (entradaA => outA(22),
                                                entradaB => saida_MUXimed(22),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(21),
                                                vai_1 => vai_1_all(22),
                                                saida => saidaULA(22),
                                                entradaB_inv => entradaB_ULA_inv(22));
                                                
        ULA_bit23   : entity work.ULA port map (entradaA => outA(23),
                                                entradaB => saida_MUXimed(23),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(22),
                                                vai_1 => vai_1_all(23),
                                                saida => saidaULA(23),
                                                entradaB_inv => entradaB_ULA_inv(23));

        ULA_bit24   : entity work.ULA port map (entradaA => outA(24),
                                                entradaB => saida_MUXimed(24),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(23),
                                                vai_1 => vai_1_all(24),
                                                saida => saidaULA(24),
                                                entradaB_inv => entradaB_ULA_inv(24));
                                                
        ULA_bit25   : entity work.ULA port map (entradaA => outA(25),
                                                entradaB => saida_MUXimed(25),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(24),
                                                vai_1 => vai_1_all(25),
                                                saida => saidaULA(25),
                                                entradaB_inv => entradaB_ULA_inv(25));
                                                
        ULA_bit26   : entity work.ULA port map (entradaA => outA(26),
                                                entradaB => saida_MUXimed(26),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(25),
                                                vai_1 => vai_1_all(26),
                                                saida => saidaULA(26),
                                                entradaB_inv => entradaB_ULA_inv(26));
                                                
        ULA_bit27   : entity work.ULA port map (entradaA => outA(27),
                                                entradaB => saida_MUXimed(27),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(26),
                                                vai_1 => vai_1_all(27),
                                                saida => saidaULA(27),
                                                entradaB_inv => entradaB_ULA_inv(27));

        ULA_bit28   : entity work.ULA port map (entradaA => outA(28),
                                                entradaB => saida_MUXimed(28),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(27),
                                                vai_1 => vai_1_all(28),
                                                saida => saidaULA(28),
                                                entradaB_inv => entradaB_ULA_inv(28));

        ULA_bit29   : entity work.ULA port map (entradaA => outA(29),
                                                entradaB => saida_MUXimed(29),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(28),
                                                vai_1 => vai_1_all(29),
                                                saida => saidaULA(29),
                                                entradaB_inv => entradaB_ULA_inv(29));

        ULA_bit30   : entity work.ULA port map (entradaA => outA(30),
                                                entradaB => saida_MUXimed(30),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(29),
                                                vai_1 => vai_1_all(30),
                                                saida => saidaULA(30),
                                                entradaB_inv => entradaB_ULA_inv(30));

        ULA_bit31   : entity work.ULA port map (entradaA => outA(31),
                                                entradaB => saida_MUXimed(31),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(30),
                                                vai_1 => vai_1_all(31),
                                                saida => saidaULA(31),
                                                entradaB_inv => entradaB_ULA_inv(31));
																
		
		 -- Flag Zero da saida da ULA								
		 flagZ <= '1' when unsigned(saidaULA) = unsigned(zero) else '0';
		 
		 -- Para o caso LUI
		 -- concatena o imediato da instrucao com 16 bits de valor zero
		 saida_lui <= extendInstruc & std_logic_vector(TO_UNSIGNED(0, 16));
		 
		 -- sinal que garante que o resultado do LUI sera salvo no banc de registradores
		 saida_ext <= saida_lui WHEN instrucao(31 downto 26) = "001111" ELSE
							saidaSigExt;
		 
		 -- saida da ULA adicionando o caso SLT e o caso LUI
       saidaULA_final <= result_slt WHEN instrucao(5 downto 0) = "101010" or instrucao(31 downto 26) = "001010"
								  ELSE saida_lui WHEN instrucao(31 downto 26) = "001111"
								  ELSE saidaULA;
								  
		 -- Salvando a saida da ULA como output do fluxo de dados
		 mSaidaULA <= saidaULA_final;
			
       -- Extensor de sinal que concatena os 15 bits do imediato da instrucao com 16 bits iguais
       -- ao ultimo bit do imediato		 
       sigExt : entity work.extensorSinal generic map (larguraDadoEntrada => 16, 
                                                        larguraDadoSaida   => instructWidth)
                                           port map (estendeSinal_IN  => extendInstruc,
                                                     estendeSinal_OUT => saidaSigExt);
	    
		 -- Seleciona se o endereco do registrador 3 no banco de registradores sera igual
		 -- a endereco B ou endereco C
		 mux_RTRD  : entity work.muxGenerico2x1 generic map (larguraDados => 5)
											   port map (entradaA_MUX  => endB,
                                                        entradaB_MUX  => endC,
                                                        seletor_MUX   => muxRtRd,
                                                        saida_MUX     => saida_MUXRd);
		  -- Para o caso de jal
		  -- Caso a instrucao seja o jal, passa como endereco do registrador 3
		  -- (endereco que guardara o dado) valor 31 em 5 bits ("11111")
        mux_R31 : entity work.muxGenerico2x1 generic map (larguraDados => 5)
                                                 port map(entradaA_MUX  => saida_MUXRd,
                                                          entradaB_MUX  => std_logic_vector(TO_UNSIGNED(31, 5)),
                                                          seletor_MUX   => muxR31,
                                                          saida_MUX     => saidaR31);

		  -- Seleciona a entrada B da ULA entre a saida do registrador 2 do banco e 
		  -- o imediato extendido
        mux_RTimed  : entity work.muxGenerico2x1 generic map (larguraDados => 32)
																port map (entradaA_MUX  => outB,
                                                          entradaB_MUX  => saida_ext,
                                                          seletor_MUX   => muxRtImed,
                                                          saida_MUX     => saida_MUXimed);

		  -- Porta logica AND entre flagZ e BEQ
		  -- importante para a instrucao BEQ no fetch
        LogicAND : entity work.LogicAnd port map(flagZ  => flagZ,
                                                 BEQ    => BEQ,
                                                 andOUT => andBEQZero);
																 
		  -- Porta logica AND entre flagZ e BNE
		  -- importante para a instrucao BNE no fetch
        LogicAND2 : entity work.LogicAnd port map(flagZ  => not flagZ,
                                                 BEQ    => BNE,
                                                 andOUT => andBNEZero);
																 

		  -- Memoria RAM ou memoria de dados
        memRAM   : entity work.RAM port map(addr     => saidaULA_final,
                                            wr       => habEscritaMEM, 
                                            re       => habLeituraMEM,
                                            clk      => clk,
                                            dado_in  => outB,
                                            dado_out => saidaRAM);
														  
		  -- Para o caso jal
		  -- soma +4 ao program counter atual
		  SOMA : entity work.somador generic map (larguraDados => 32)
								   port map (entradaA => sigSaida_PC,
										     entradaB => std_logic_vector(TO_UNSIGNED(4, 32)),
											 saida => pc_in);
		  
		  -- Mux ULA/RAM
		  -- Decide qual dado que vai ser escrito no banco de registradores
        muxULAram  : entity work.muxGenerico4x2_32 port map (entrada0 => saidaULA_final,
                                                          entrada1 => saidaRAM,
                                                          entrada2 => saida_ext,
                                                          entrada3 => pc_in,
                                                          seletor_MUX => muxULAMem,
                                                          saida_MUX => saida_MUXulaRAM);
		  
		  -- Salvando a saida do MUX ULA/RAM para o output no top level
        saidaMegaMux <= saida_MUXulaRAM;
                                                     
end architecture;