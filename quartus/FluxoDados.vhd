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
    signal saidaR31 : std_logic_vector(4 downto 0);
	 signal saidaULA_final, saida_ext : std_logic_vector(31 downto 0);
    signal entradaB_ULA_inv : std_logic_vector(31 downto 0);
	 signal overflow_slt : std_logic;
	 signal instrucao : std_logic_vector(31 downto 0);
	 
	 
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
                                                      andBEQZero => flagZ and BEQ,
                                                      muxJUMP =>  muxJUMP,
                                                      bne => ((not flagZ) and BNE),
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
			-- mux_JR : entity work.muxGenerico2x1 generic map (larguraDados => 5)
			-- 													port map (entradaA_MUX  => endA,
            --                                               entradaB_MUX  => std_logic_vector(TO_UNSIGNED(31, 5)),
            --                                               seletor_MUX   => muxJR,
            --                                               saida_MUX     => saida_mux_jr);
		  -- Banco de registradores
        BancoReg : entity work.bancoRegistradores port map (clk => clk,
                                                            enderecoA => endA,
                                                            enderecoB => endB,
                                                            enderecoC => saidaR31,
                                                            dadoEscritaC => saida_MUXulaRAM,
                                                            escreveC => habEscritaReg,
                                                            saidaA => outA,
                                                            saidaB => outB);	
		  
		  ULA_32bits : entity work.ULA_32 port map(clk => clk, rst => rst,
																 ULActrl => ULActrl,
																 entradaA => outA,
																 entradaB => saida_MUXimed,
                                                                 mSaidaULA => saidaULA,
                                                                 flagZ => flagZ);
								  
		 -- Salvando a saida da ULA como output do fluxo de dados
		 mSaidaULA <= saidaULA_final;
		 -- ================================================================
		 
			
        -- Extensor de sinal que concatena os 15 bits do imediato da instrucao com 16 bits iguais
        -- ao ultimo bit do imediato		 
         ExtensorSinal : entity work.extensorSinal generic map (larguraDadoEntrada => 16, 
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
                                                          entradaB_MUX  => saidaSigExt,
                                                          seletor_MUX   => muxRtImed,
                                                          saida_MUX     => saida_MUXimed);

		  -- Porta logica AND entre flagZ e BEQ
		  -- importante para a instrucao BEQ no fetch
        -- LogicAND : entity work.LogicAnd port map(flagZ  => flagZ,
        --                                          BEQ    => BEQ,
        --                                          andOUT => andBEQZero);
																 
		--   -- Porta logica AND entre flagZ e BNE
		--   -- importante para a instrucao BNE no fetch
        -- LogicAND2 : entity work.LogicAnd port map(flagZ  => not flagZ,
        --                                          BEQ    => BNE,
        --                                          andOUT => andBNEZero);
																 
			-- Memoria RAM ou memoria de dados
			memRAM    : entity work.RAMMIPS port map(clk => clk,
															 Endereco => saidaULA_final,
															 Dado_in => outB,
															 Dado_out => saidaRAM,
															 we => habEscritaMEM);
														  
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
                                                          entrada2 => saidaSigExt,
                                                          entrada3 => pc_in,
                                                          seletor_MUX => muxULAMem,
                                                          saida_MUX => saida_MUXulaRAM);
		  
		  -- Salvando a saida do MUX ULA/RAM para o output no top level
        saidaMegaMux <= saida_MUXulaRAM;
                                                     
end architecture;