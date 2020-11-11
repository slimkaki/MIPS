library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FluxoDados is
    generic(
        instructWidth : natural := 32
    );
    port(
        clk, rst        :  in std_logic;
        escritaC        :  in std_logic;
        palavraControle :  in std_logic_vector(10 downto 0);
        instrucao       :  out std_logic_vector((instructWidth - 1) downto 0);
        opCodeFunct     :  out std_logic_vector(11 downto 0)
    );
end entity;

architecture comportamento of FluxoDados is
    signal endA, endB, endC : std_logic_vector(4 downto 0);
    signal outA, outB : std_logic_vector((instructWidth - 1) downto 0);
    signal flagZ : std_logic;
    signal saidaULA : std_logic_vector((instructWidth - 1) downto 0);
    signal extendInstruc : std_logic_vector(15 downto 0);
    signal saidaSigExt : std_logic_vector((instructWidth - 1) downto 0);
    signal andBEQZero : std_logic;
    signal saida_MUXimed : std_logic_vector((instructWidth-1) downto 0);
    signal saidaRAM : std_logic_vector((instructWidth-1) downto 0);
    --signal saida_MUXimed : std_logic_vector((instructWidth-1) downto 0);
    signal saida_MUXulaRAM : std_logic_vector((instructWidth-1) downto 0);
    signal saida_MUXRd : std_logic_vector(4 downto 0);

    alias muxJUMP       : std_logic is palavraControle(10);
    alias muxRtRd       : std_logic is palavraControle(9);
    alias habEscritaReg : std_logic is palavraControle(8);
    alias muxRtImed     : std_logic is palavraControle(7);
    alias ULActrl         : std_logic_vector(2 downto 0) is palavraControle(6 downto 4);
    alias muxULAMem     : std_logic is palavraControle(3);
    alias BEQ           : std_logic is palavraControle(2);
    alias habLeituraMEM : std_logic is palavraControle(1);
    alias habEscritaMEM : std_logic is palavraControle(0);

    signal vai_1_all, flagZero_all : std_logic_vector((instructWidth-1) downto 0);  

    begin
        fetchInstruction : entity work.fetch generic map (dataWidth => instructWidth)
                                             port map(clk => clk,
                                                      rst => rst,
                                                      extendedInst => saidaSigExt,
                                                      andBEQZero => andBEQZero,
                                                      muxJUMP =>  muxJUMP,
                                                      instrucao => instrucao);

        opCodeFunct(11 downto 6) <= instrucao(31 downto 26);
        opCodeFunct(5 downto 0)  <= instrucao(5 downto 0);
        endA                     <= instrucao(25 downto 21);
        endB                     <= instrucao(20 downto 16);
        endC                     <= instrucao(15 downto 11);
        extendInstruc            <= instrucao(15 downto 0);

        BancoReg : entity work.bancoRegistradores port map (clk => clk,
                                                            enderecoA => endA,
                                                            enderecoB => endB,
                                                            enderecoC => endC,
                                                            dadoEscritaC => saida_MUXulaRAM,
                                                            escreveC => escritaC,
                                                            saidaA => outA,
                                                            saidaB => outB);

        -- ULAmips : entity work.ULA port map (entradaA => outA,
        --                                     entradaB => saida_MUXimed,
        --                                     seletor => ULActrl,
        --                                     saida => saidaULA,
        --                                     flagZero => flagZ);
        ULA_bit0   : entity work.ULA port map (entradaA => outA(0),
                                               entradaB => saida_MUXimed(0),
                                               seletor => ULActrl,
                                               vem_1 => '0',
                                               saida => saidaULA(0),
                                               flagZero => flagZero_all(0),
                                               vai_1 => vai_1_all(0));

        ULA_bit1   : entity work.ULA port map (entradaA => outA(1),
                                                entradaB => saida_MUXimed(1),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(0),
                                                vai_1 => vai_1_all(1),
                                                saida => saidaULA(1),
                                                flagZero => flagZero_all(1));

        ULA_bit2   : entity work.ULA port map (entradaA => outA(2),
                                                entradaB => saida_MUXimed(2),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(1),
                                                vai_1 => vai_1_all(2),
                                                saida => saidaULA(2),
                                                flagZero => flagZero_all(2));
                                                
        ULA_bit3   : entity work.ULA port map (entradaA => outA(3),
                                                entradaB => saida_MUXimed(3),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(2),
                                                vai_1 => vai_1_all(3),
                                                saida => saidaULA(3),
                                                flagZero => flagZero_all(3));

        ULA_bit4   : entity work.ULA port map (entradaA => outA(4),
                                                entradaB => saida_MUXimed(4),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(3),
                                                vai_1 => vai_1_all(4),
                                                saida => saidaULA(4),
                                                flagZero => flagZero_all(4));

        ULA_bit5   : entity work.ULA port map (entradaA => outA(5),
                                                entradaB => saida_MUXimed(5),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(4),
                                                vai_1 => vai_1_all(5),
                                                saida => saidaULA(5),
                                                flagZero => flagZero_all(5));

        ULA_bit6   : entity work.ULA port map (entradaA => outA(6),
                                                entradaB => saida_MUXimed(6),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(5),
                                                vai_1 => vai_1_all(6),
                                                saida => saidaULA(6),
                                                flagZero => flagZero_all(6));

        ULA_bit7   : entity work.ULA port map (entradaA => outA(7),
                                                entradaB => saida_MUXimed(7),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(6),
                                                vai_1 => vai_1_all(7),
                                                saida => saidaULA(7),
                                                flagZero => flagZero_all(7));

        ULA_bit8   : entity work.ULA port map (entradaA => outA(8),
                                                entradaB => saida_MUXimed(8),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(7),
                                                vai_1 => vai_1_all(8),
                                                saida => saidaULA(8),
                                                flagZero => flagZero_all(8));

        ULA_bit9   : entity work.ULA port map (entradaA => outA(9),
                                                entradaB => saida_MUXimed(9),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(8),
                                                vai_1 => vai_1_all(9),
                                                saida => saidaULA(9),
                                                flagZero => flagZero_all(9));

        ULA_bit10   : entity work.ULA port map (entradaA => outA(10),
                                                entradaB => saida_MUXimed(10),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(9),
                                                vai_1 => vai_1_all(10),
                                                saida => saidaULA(10),
                                                flagZero => flagZero_all(10));

        ULA_bit11   : entity work.ULA port map (entradaA => outA(11),
                                                entradaB => saida_MUXimed(11),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(10),
                                                vai_1 => vai_1_all(11),
                                                saida => saidaULA(11),
                                                flagZero => flagZero_all(11));

        ULA_bit12   : entity work.ULA port map (entradaA => outA(12),
                                                entradaB => saida_MUXimed(12),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(11),
                                                vai_1 => vai_1_all(12),
                                                saida => saidaULA(12),
                                                flagZero => flagZero_all(12));

        ULA_bit13   : entity work.ULA port map (entradaA => outA(13),
                                                entradaB => saida_MUXimed(13),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(12),
                                                vai_1 => vai_1_all(13),
                                                saida => saidaULA(13),
                                                flagZero => flagZero_all(13));

        ULA_bit14   : entity work.ULA port map (entradaA => outA(14),
                                                entradaB => saida_MUXimed(14),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(13),
                                                vai_1 => vai_1_all(14),
                                                saida => saidaULA(14),
                                                flagZero => flagZero_all(14));
                                                
        ULA_bit15   : entity work.ULA port map (entradaA => outA(15),
                                                entradaB => saida_MUXimed(15),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(14),
                                                vai_1 => vai_1_all(15),
                                                saida => saidaULA(15),
                                                flagZero => flagZero_all(15));
                                                
        ULA_bit16   : entity work.ULA port map (entradaA => outA(16),
                                                entradaB => saida_MUXimed(16),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(15),
                                                vai_1 => vai_1_all(16),
                                                saida => saidaULA(16),
                                                flagZero => flagZero_all(16));
                                                
        ULA_bit17   : entity work.ULA port map (entradaA => outA(17),
                                                entradaB => saida_MUXimed(17),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(16),
                                                vai_1 => vai_1_all(17),
                                                saida => saidaULA(17),
                                                flagZero => flagZero_all(17));

        ULA_bit18   : entity work.ULA port map (entradaA => outA(18),
                                                entradaB => saida_MUXimed(18),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(17),
                                                vai_1 => vai_1_all(18),
                                                saida => saidaULA(18),
                                                flagZero => flagZero_all(18));

        ULA_bit19   : entity work.ULA port map (entradaA => outA(19),
                                                entradaB => saida_MUXimed(19),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(18),
                                                vai_1 => vai_1_all(19),
                                                saida => saidaULA(19),
                                                flagZero => flagZero_all(19));

        ULA_bit20   : entity work.ULA port map (entradaA => outA(20),
                                                entradaB => saida_MUXimed(20),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(19),
                                                vai_1 => vai_1_all(20),
                                                saida => saidaULA(20),
                                                flagZero => flagZero_all(20));

        ULA_bit21   : entity work.ULA port map (entradaA => outA(21),
                                                entradaB => saida_MUXimed(21),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(20),
                                                vai_1 => vai_1_all(21),
                                                saida => saidaULA(21),
                                                flagZero => flagZero_all(21));

        ULA_bit22   : entity work.ULA port map (entradaA => outA(22),
                                                entradaB => saida_MUXimed(22),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(21),
                                                vai_1 => vai_1_all(22),
                                                saida => saidaULA(22),
                                                flagZero => flagZero_all(22));
                                                
        ULA_bit23   : entity work.ULA port map (entradaA => outA(23),
                                                entradaB => saida_MUXimed(23),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(22),
                                                vai_1 => vai_1_all(23),
                                                saida => saidaULA(23),
                                                flagZero => flagZero_all(23));

        ULA_bit24   : entity work.ULA port map (entradaA => outA(24),
                                                entradaB => saida_MUXimed(24),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(23),
                                                vai_1 => vai_1_all(24),
                                                saida => saidaULA(24),
                                                flagZero => flagZero_all(24));
                                                
        ULA_bit25   : entity work.ULA port map (entradaA => outA(25),
                                                entradaB => saida_MUXimed(25),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(24),
                                                vai_1 => vai_1_all(25),
                                                saida => saidaULA(25),
                                                flagZero => flagZero_all(25));
                                                
        ULA_bit26   : entity work.ULA port map (entradaA => outA(26),
                                                entradaB => saida_MUXimed(26),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(25),
                                                vai_1 => vai_1_all(26),
                                                saida => saidaULA(26),
                                                flagZero => flagZero_all(26));
                                                
        ULA_bit27   : entity work.ULA port map (entradaA => outA(27),
                                                entradaB => saida_MUXimed(27),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(26),
                                                vai_1 => vai_1_all(27),
                                                saida => saidaULA(27),
                                                flagZero => flagZero_all(27));

        ULA_bit28   : entity work.ULA port map (entradaA => outA(28),
                                                entradaB => saida_MUXimed(28),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(27),
                                                vai_1 => vai_1_all(28),
                                                saida => saidaULA(28),
                                                flagZero => flagZero_all(28));

        ULA_bit29   : entity work.ULA port map (entradaA => outA(29),
                                                entradaB => saida_MUXimed(29),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(28),
                                                vai_1 => vai_1_all(29),
                                                saida => saidaULA(29),
                                                flagZero => flagZero_all(29));

        ULA_bit30   : entity work.ULA port map (entradaA => outA(30),
                                                entradaB => saida_MUXimed(30),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(29),
                                                vai_1 => vai_1_all(30),
                                                saida => saidaULA(30),
                                                flagZero => flagZero_all(30));

        ULA_bit31   : entity work.ULA port map (entradaA => outA(31),
                                                entradaB => saida_MUXimed(31),
                                                seletor => ULActrl,
                                                vem_1 => vai_1_all(30),
                                                vai_1 => vai_1_all(31),
                                                saida => saidaULA(31),
                                                flagZero => flagZero_all(31));
                                                
        sigExt : entity work.extensorSinal generic map (larguraDadoEntrada => 16, 
                                                        larguraDadoSaida   => instructWidth)
                                           port map (estendeSinal_IN  => extendInstruc,
                                                     estendeSinal_OUT => saidaSigExt);

		mux_RTRD  : entity work.muxGenerico2x1 generic map (larguraDados => 5)
											   port map (entradaA_MUX  => endB,
                                                        entradaB_MUX  => endC,
                                                        seletor_MUX   => muxRtRd,
                                                        saida_MUX     => saida_MUXRd);

        mux_RTimed  : entity work.muxGenerico2x1 generic map (larguraDados => 32)
																port map (entradaA_MUX  => outB,
                                                          entradaB_MUX  => saidaSigExt,
                                                          seletor_MUX   => muxRtImed,
                                                          saida_MUX     => saida_MUXimed);


        LogicAND : entity work.LogicAnd port map(flagZ  => flagZ,
                                                 BEQ    => BEQ,
                                                 andOUT => andBEQZero);

        memRAM   : entity work.RAM port map(addr     => saidaULA,
                                            wr       => habEscritaMEM, 
                                            re       => habLeituraMEM,
                                            clk      => clk,
                                            dado_in  => outB,
                                            dado_out => saidaRAM);
        
        muxULAram  : entity work.muxGenerico2x1 generic map (larguraDados => 32)
												port map (entradaA_MUX  => saidaULA,
                                                          entradaB_MUX  => saidaRAM,
                                                          seletor_MUX   => muxULAmem,
                                                          saida_MUX     => saida_MUXulaRAM);
        
                                            
                                            
end architecture;